function curve_speed = lsCurve(phi, epsilon) 
% By: Jeff Orchard
%lsCurve - calculateds the curvature of phi.

p = size(phi,1);
q = size(phi,2);

i = [2:p-1];
j = [2:q-1];


kappa = zeros(p,q);
Dx = zeros(p,q);
Dy = zeros(p,q);
Dxx = zeros(p,q);
Dyy = zeros(p,q);
Dxy = zeros(p,q);
Dx(i,j) = 1/2 * (phi(i+1,j) - phi(i-1,j));
Dy(i,j) = 1/2 * (phi(i,j+1) - phi(i, j-1));
Dxx(i,j) = phi(i+1,j) - 2*phi(i,j) + phi(i-1,j);
Dyy(i,j) = phi(i,j+1) - 2*phi(i,j) + phi(i,j-1);
%Dxy(i,j) = 1/4 *( phi(i+1,j+1) - phi(i+1,j-1) - phi(i-1,j+1) + phi(i-1,j-1));

Numerator = Dxx + Dyy;
Denominator = realsqrt(Dx.^2+Dy.^2);
%Numerator = Dxx .* (Dy.^2) - 2*Dy.*Dx.*Dxy + Dyy .* (Dx .^ 2);
%Denominator = (Dx.^2+Dy.^2).^(3/2);

INDX = find(Denominator); %Find where denominator is not zero.

kappa(INDX) = Numerator(INDX)./Denominator(INDX);

%curve_speed = abs(epsilon .* kappa .* realsqrt(Dx.^2 + Dy.^2));
curve_speed = -epsilon * kappa;
