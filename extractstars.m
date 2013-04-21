%
% Input: A file name to read.
% Output: A greyscale image with only points which are
% brighter than the surrounding background (i.e. the bright stars).
% The values are the difference between the point average and the
% background. 
function [ stars ] = extractstars( img_name )

    img = double(imread(img_name));

    img2 = img(:,:,1);

    [nx, ny, depth] = size(img2);

    % Compute 3*3 and 9*9 windowed averages for each pixel location.
    mean33 = zeros(nx, ny);
    mean99 = zeros(nx, ny);

    % This could likely be made faster by convolution with a box filter in
    % the frequency domain.
    for i = 11:(nx-11)
       for j = 11:(ny-11)
           mean33(i,j) = sum(sum(img2(i-1:i+1, j-1:j+1)))/9;
           mean99(i,j) = sum(sum(img2(i-3:i+3, j-3:j+3)))/49;
       end    
    end

    % Threshold between the 9*9 window average and the 3*3 window average. 
    thress = 30;

    stars = zeros(nx, ny);

    % Require that the 3*3 windowed mean be larger than the 9*9 windowed
    % mean in both the current pixel, and one to the right and one down.
    % This takes out single bright pixels, which are often noise or dimmer
    % starts.
    for i = 11:(nx-11)
        for j = 11:(ny-11)
            if (mean33(i,j) > (mean99(i,j)+thress)) && (mean33(i,j+1) > (mean99(i,j+1)+thress)) && (mean33(i+1,j) > (mean99(i+1,j)+thress))
                stars(i,j) = mean33(i,j)-mean99(i,j);
            end
        end
    end

end

