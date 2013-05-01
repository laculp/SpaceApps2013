%
% Input: img_name: A file name to read.
%        value: the value for the star to have.
%        max_row: The maximum row to consider starting from the top of the image.
%                 zero means do full image.
%        resize_factor: How much to resize the image before processing it.
% Output: A greyscale image with only points which are
% brighter than the surrounding background (i.e. the bright stars).
% The values are the difference between the point average and the
% background. 
function [ stars ] = extractstars( img_name, value, max_row, resize_factor )

    img = double(rgb2gray(imread(img_name)));

    % Resize image to improve speed.
    img = imresize(img, resize_factor);
    
    [nx ny depth] = size(img);
    
    if max_row == 0
        max_row = nx*resize_factor;
    end

    % Threshold between the 9*9 window average and the 3*3 window average. 
    thress = 30;

    % Compute 3*3 and 9*9 windowed averages for each pixel location.
    mean33 = zeros(nx, ny);
    mean99 = zeros(nx, ny);

    stars = zeros(nx, ny);

    % This could likely be made faster by convolution with a box filter in
    % the frequency domain.  However box filters have strange properties in the
    % frequency domain, so we will do this the long way to be safe for now.
    for i = 5:min((nx-5),max_row)
       for j = 5:(ny-5)
           mean33(i,j) = sum(sum(img(i-1:i+1, j-1:j+1)))/9;
           mean99(i,j) = sum(sum(img(i-3:i+3, j-3:j+3)))/49;

           if (mean33(i,j) > (mean99(i,j)+thress))
               stars(i,j) = value;
           end
       end    
    end

end

