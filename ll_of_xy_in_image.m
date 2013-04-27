function [lat, lon] = ll_of_xy_in_image( ISS_latlon, ISS_alt, direction_of_view, angle_to_horizon, horizon_row_in_image, nrows, ncols, row, col )


% Recalculate angle to horizon
R = earthRadius('kilometers');
aurora_alt = 350; % We assume the top of the aurora occurs at 250km
angle_to_horizon = asin( sin(pi/2) * (R + aurora_alt) / (R + 387) );

% Floor the horizon row in the image
horizon_row_in_image = floor(horizon_row_in_image);


% direction_of_view : vector direction of view for the camera
% angle_to_horizon : angle between the vector from the earth's core to the ISS and the horizon point
% 

vertical_fov = 45;
vertical_fov = deg2rad(vertical_fov);

horizontal_fov = 60;
horizontal_fov = deg2rad(horizontal_fov)/2;

vert_fov_per_pixel = vertical_fov / nrows;
horiz_fov_per_pixel = horizontal_fov / ncols;

% Get percent off horizon (top is at 22.5, bottom at -22.5)
row_displacement = horizon_row_in_image - row;

% Get percent off center
col_displacement = ncols/2 - col;

% FIXME: projective transform needs to be done
% (We assume an orthographic transformation)

% Get angle towards pixel
vert_angle = row_displacement * vert_fov_per_pixel + angle_to_horizon;
horiz_angle = col_displacement * horiz_fov_per_pixel;

% Project this onto the earth
% First, figure out the angle between the ISS, the core, and the point in the atmosphere we are projecting to
beta = asin( (aurora_alt + R) * sin( vert_angle ) / ( ISS_alt + R ) ) ;

% Second, figure out the distance to the aurora using this angle
dist_to_pt = sin(pi - vert_angle - beta) * ( aurora_alt + R ) / sin( vert_angle );

% Third, rotate the direction of view by the horizontal offset
ROT = [sin(horiz_angle) -cos(horiz_angle); cos(horiz_angle) sin(horiz_angle)];
pt_dir = ROT * direction_of_view;
pt_dir = pt_dir / norm(pt_dir);

% Find the length of this vector
temp = ISS_latlon + pt_dir;
mult_dist = m_lldist( [ISS_latlon(2) temp(2)], [ISS_latlon(1) temp(1)] );

% FIXME: we are approximating here...
% Get the distance to multiply this vector by to get the new lat lon
mult = dist_to_pt / mult_dist;

% Get the lat lon
final_pos = mult*pt_dir + ISS_latlon;
lat = final_pos(1);
lon = final_pos(2);

%A check:
%mult_dist = m_lldist( [ISS_latlon(2) final_pos(2)], [ISS_latlon(1) final_pos(1)] )

end
