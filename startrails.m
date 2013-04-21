
% Reads images from the downloaded ISS data and
% computes extracts the stars in each frame then 
% outputs a star trail map with only the stars.

% This is used to get a clean set of star trails
% which are used later to extract trail distances.


% Setup the process by getting the image size and setting
% up a new image.  Note we assume images have been converted to greyscale.
img = double(imread('../resized/ISS030-E-53410.jpg'));
[nx ny nz] = size(img);
result = zeros(nx,ny);

% This could be cleaner, and made more automatic.
% At the moment this uses 60 images to form the star trails.
% Since we are taking from a data set where each frame
% is taken at a one second interval, the trails are effectly
% a 1 minute arc.
for i = 11:70
    star_extract = extractstars(strcat('../resized/ISS030-E-534',  num2str(i) , '.jpg'));
    
    result = result + star_extract/60;
    
    display(strcat('Added image: ', num2str(i-10), 'of 60'));
end

% This median filter removes any hot pixles that made it into the
% stacked star trails.
filteredresult = medfilt2(result,[2,2]);

imshow(filteredresult, [0,10]);

