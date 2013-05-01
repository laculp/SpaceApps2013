% Function G = MyGaussianBlur(F, sigma)
%
%  Blur an image (2D or 3D) using a Gaussian filter.
%
%  Input:
%    F is an image array (2D or 3D)
%    sigma is the standard deviation of the Gaussian blurring kernel
%
%  Output:
%    G is an image array the same size as F containing the
%      blurred image
function G = MyGaussianBlur(F, sigma)

    % Get the dimensions of F
    [d1,d2,d3] = size(F)
    
    % 2D case
    if d3 == 1
       % Create the gaussian kernel
       g1 = Gaussian(sigma, [d1, d2]);
       % Take the DFT of the shifted g1
       % We need to shift the kernel origin to (1,1) 
       g2 = fft2(fftshift(g1));
       % do the 2d DFT of F
       f = fft2(F);
       
       % Convolve f and g2 in the frequency domain, and invert
       % to get back to the spatial domain.
       G = ifft2( f .* g2);
    else % 3d Case
       % Create the gaussian kernel
       g1 = Gaussian(sigma, [d1, d2, d3]);
       % Take the DFT of the shifted kernel as before
       g2 = fftn(fftshift(g1)) ;
       % do the 3d DFT of F 
       f =  fftn(F) ;

       % Convolve f and g2 in the frequency domain, and invert
       % to get back to the spatial domain.
       G = ifftn( f .* g2 );
    end
    
    
    
    
