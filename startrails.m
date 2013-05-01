% Reads images from the downloaded ISS data and
% computes extracts the stars in each frame then 
% outputs a star trail map with only the stars.

% This is used to get a clean set of star trails
% which are used later to extract trail distances.
function trails = startrails(path, mission, start_num, frames, img_size, max_row, resize_factor)

    % Setup the process by getting the image size and setting
    % up a new image for adding the star trails to.
    nx = img_size(2)*resize_factor;
    ny = img_size(1)*resize_factor;
    
    trails = zeros(nx,ny);

    % This could be cleaner, and made more automatic.
    % At the moment this uses 60 images to form the star trails.
    % Since we are taking from a data set where each frame
    % is taken at a one second interval, the trails are effectly
    % a 1 minute arc.
    for i = start_num:(start_num+frames)
        % Starting star locations are panted with a value of 1
        % middle star locations are painted with a value of 100
        % and end star locations are painted with a value of 10000
        % So even if we have overlapping stars start stars shouldn't get 50
        % 100, and middle stars shouldn't get above 5000, meaning we can
        % tell the start middle and end apart.
        if i >= start_num && i < (start_num+5)
            star_value = 1;
        elseif i > (start_num+frames-5) && i <= (start_num+frames)
            star_value = 10000; 
        else
            star_value = 100;
        end
            
        star_extract = extractstars(strcat(path, '/', mission,  num2str(i) , '.jpg'), star_value, max_row, resize_factor);
        
        trails = trails + star_extract;
        
        display(strcat('Star Trails: Added image: ', num2str((i-start_num) + 1), ' of ', num2str(frames)));
    end

    % This median filter removes any hot pixles that made it into the
    % stacked star trails.
    trails = double(medfilt2(trails,[2,2]));

end
