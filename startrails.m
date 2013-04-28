
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
    % Starting star locations are panted with a value of 1
    % middle star locations are painted with a value of 100
    % and end star locations are painted with a value of 10000
    % So even if we have overlapping stars start stars shouldn't get 50
    % 100, and middle stars shouldn't get above 5000, meaning we can
    % tell the start middle and end apart.
    if i > 10 && i < 20
        star_value = 1;
    elseif i > 60 && i <= 70
        star_value = 10000; 
    else
        star_value = 100;
    end
        
    star_extract = extractstars(strcat('../resized/ISS030-E-534',  num2str(i) , '.jpg'), star_value);
    
    result = result + star_extract;
    
    display(strcat('Added image: ', num2str(i-10), 'of 60'));
end

% This median filter removes any hot pixles that made it into the
% stacked star trails.
filteredresult = double(medfilt2(result,[2,2]));

imshow(filteredresult, [0,1000]);

