function [Phi delta_t] = lsStep(phi, delta_t, I, direction, Dtype, epsilon, sigma) 
% By: Jeff Orchard
    %LSSTEP - updates the level set phi(t) to phi(t+1).
    %  Phi = LSSTEP(phi, delta_t, I, type, epsilon, sigma).
    %   Phi is the output, phi(t+1).
    %   Input:
    %      phi - the level-set phi at t.
    %      delta_t - the timestep.  It should be in the range 0.3 to 0.9.
    %                   The larger the timestep, the faster the front progresses, however
    %                   too large and it will lead to instability.
    %      I - the image that the level set is forming against.
    %      direction - the way the front should move. Options are:
    %               'contract' - If the level set at t=0 is larger then the area of interest in the image,
    %                             this will cause the front to contract around the area of interest.
    %               'expand' - If the level set at t=0 is smaller then the area of interest,
    %                             this will casue the front to expand around the area of interest.
    %      Dtype - the way of computing the gradient of phi
    %               'upwind' - use upwinding scheme
    %               'central' - central differences.  It is NOT stable and will cause
    %                             multiple additional fronts.
    %      epsilon - the curvature constraint function.  Use very small values, otherwise instablity will result.
    %      sigma - stdev for image smoothing.  Values between 0 and 1 work well.
    %
    %  Version 3.0

    if nargin<5
        Dtype = 'upwind';
    end
    if nargin<6
        epsilon = 0;
    end
    if nargin<7
        sigma = 0;
    end
    
    % Calculate the image gradient.
    [Vx Vy] = joGradient('central',I);
    V = (Vx.^2 + Vy.^2);

    % Calculate the smoothing function if needed.
    if (sigma ~= 0)
        % Smooth the gradient to reduce curvature.
        G = fspecial('gaussian',5,sigma);
        V = filter2(G,V,'same');
    end




    % Calculate the speed function from the image gradient.  As we approach a large gradient,
    % the speed function approaches 0.  For small gradients, the speed function approaches 1 (unity).
    Vn = 1 ./ (1+V);
    %Vn = exp(-V);

    % In the contracting case, we increase the height of the embedding
    % function, thus decreasing the area of the zero level set.
    % In the expanding case, we decrease the height of the embedding
    % function, thus increasing the area of the zero level set.
    if strcmp(direction, 'contract')
        Vn = -Vn;
    end

    
    % Update phi moving the front in the desired direction.
    if strcmp(Dtype,'upwind')

        % Calculate the direction of phi.
        [dxf dyf] = joGradient('forward', phi);
        [dxb dyb] = joGradient('backward', phi);

        Del_plus = realsqrt(max(dxf,0).^2 + min(dxb,0).^2 + max(dyf,0).^2 + min(dyb,0).^2);
        Del_minus = realsqrt(min(dxf,0).^2 + max(dxb,0).^2 + min(dyf,0).^2 + max(dyb,0).^2);

        % Calculate Gradients for determining curvature if needed.
        if (epsilon ~= 0)
            curve = lsCurve(phi, epsilon);
        else
            curve = zeros(size(phi));
        end

        Vn = Vn .* (1 + curve);
                
        phi_grad = (Vn<=0).*Del_plus + (Vn>0).*Del_minus;
        Phi = phi - delta_t*Vn.*phi_grad;
        
    else % direction == 'central'
        
        % This is using finite differences, instead of uphill or downhill.
        [dx dy] = joGradient('central', phi);
        Phi = phi - delta_t*Vn.*sqrt(dx.^2 + dy.^2);
        
    end

        
