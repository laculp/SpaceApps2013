function [gradx,grady]= joGradient(gtype,I)
% By: Jeff Orchard

    switch gtype

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case {'central'}
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            gradx = ( circshift(I, [0 -1]) - circshift(I, [0 1]) ) / 2;
            grady = ( circshift(I, [-1 0]) - circshift(I, [1 0]) ) / 2; %y-axis is positive-down


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case {'forward'}
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Shift I to LEFT by 1; brings I(:,j+1) to I(:,j)
            gradx = circshift(I, [0 -1]) - I;
            grady = circshift(I, [-1 0]) - I; %y-axis is positive-down

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case {'backward'}
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Shift I to RIGHT by 1; brings I(:,j-1) to I(:,j)
            gradx = I - circshift(I, [0 1]);
            grady = I - circshift(I, [1 0]); %y-axis is positive-down



            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case {'upwind'}
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            [gxf,gyf] = joGradient('forward',I);
            [gxb,gyb] = joGradient('backward',I);

            gradx = max( max(gxb, -gxf), zeros(size(gxb)) );
            grady = max( max(gyb, -gyf), zeros(size(gyb)) );

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case {'downwind'}
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            [gxf,gyf] = joGradient('forward',I);
            [gxb,gyb] = joGradient('backward',I);

            gradx = min( max(gxb, -gxf), zeros(size(gxb)) );
            grady = max( max(gyb, -gyf), zeros(size(gyb)) );

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end %% switch end


