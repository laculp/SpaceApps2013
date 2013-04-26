function ret = show_wedge(ISS_position, next_frame, degrees_off_normal)

% ISS_position given in [lat, lon, altitude] (altitude in meters)
% orbit dir given in [lat,lon] of next frame

% Calculate horizon
R = earthRadius('meters')
%	at the horizon, the surface is tangent to the viewing direction (pi/2 angle)
%	thus, (distance(center of earth to ISS)^2 
%		   - distance(center of earth to surface)^2)^0.5
%		= distance(ISS to horizon)
d_ISS_horiz = sqrt( (R + ISS_position(3))^2 + R^2 );
% 	then, we can use the sine law to calculate the angle between the horizon and
%	the ISS
alpha = arcsin( d_ISS_horiz * sin(pi/2) / (R + ISS_position(3)) );
%	then, get the distance on the earth
d_horiz = alpha * R;

% Find a vector representing the direction of the ISS
ISS_dir(1) = next_frame(1) - ISS_position(1);
ISS_dir(2) = next_frame(2) - ISS_position(2);
ISS_latlon = ISS_position(1:2);

% Find the direction of view
view_dir = 10;

% We somehow get the viewing direction


% Find the wedge based on the field of view (in degrees)
camera_fov = 1.4; % in radians

% Find the points on the horizon at the edges of the field of view
left_top_pt = [2 4];
right_top_pt = [5 3];

% Get the max latitude, min latitude, min longitude, max longitude
min_lat = min([ISS_latlon(1) left_top_pt(1) right_top_pt(1)]);
max_lat = max([ISS_latlon(1) left_top_pt(1) right_top_pt(1)]);
min_lon = min([ISS_latlon(2) left_top_pt(2) right_top_pt(2)]);
max_lon = max([ISS_latlon(2) left_top_pt(2) right_top_pt(2)]);

% Set up the projection
m_proj( 'oblique', 'lat', [min_lat max_lat], 'lon', [min_lon max_lon], 'aspect', 1 );

% Plot the contours
m_coast('patch', [.6 .6 .6]);

% Plot the grid
m_grid('box', 'fancy', 'tickdir', 'in');

% Plot lines between the ISS [lat lon] to these points to indicate the 
% view wedge
plotm(ISS_latlon, left_top_pt);
plotm(ISS_latlon, right_top_pt);

% Calculate where the aurora is
% We know where the aurora is in the image... we can calculate the
% 'midpoint' very roughly...
% Given this midpoint, and radius of circle, we need to calculate where the
% 


end
