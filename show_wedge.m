function ret = show_wedge(ISS_latlon, ISS_alt, next_frame, degrees_off_ISS_axis, horizon_segmented, aurora_segmented, degrees_off_horizontal)

% ISS_latlon given in [lat; lon] 
% (altitude in kilometers)
% orbit dir given in [lat; lon] of next frame

tic 

% Calculate horizon
R = earthRadius('kilometers');
%	at the horizon, the surface is tangent to the viewing direction (pi/2 angle)
%	thus, (distance(center of earth to ISS)^2 
%		   - distance(center of earth to surface)^2)^0.5
%		= distance(ISS to horizon)
d_ISS_horiz = sqrt( (R + ISS_alt).^2 - R.^2 );
% 	then, we can use the sine law to calculate the angle between the horizon and
%	the ISS
alpha = asin( d_ISS_horiz * sin(pi/2) / (R + ISS_alt) );
%	then, get the distance on the earth
d_horiz = alpha * R;

% Find a vector representing the direction of the ISS
ISS_dir(2) = next_frame(1) - ISS_latlon(1);
ISS_dir(1) = next_frame(2) - ISS_latlon(2);

% Find the unit direction of view
dpos = [ISS_dir(1); ISS_dir(2)];
dpos = dpos / norm(dpos);

% Create a rotation matrix for the offset
ROT = [cos(degrees_off_ISS_axis) -sin(degrees_off_ISS_axis); sin(degrees_off_ISS_axis) cos(degrees_off_ISS_axis)];
% Apply rotation matrix to get the approximate viewing direction
dview = ROT * dpos;

% Find the wedge based on the field of view (in degrees)
camera_fov = 65;
camera_fov = degtorad(camera_fov);
% Divide the field of view in half to get how much we should rotate the viewing dir each way
fov_half = camera_fov/2;
% Rotate by fov_half to get the left, and -fov_half to get the right
ROT = [cos(fov_half) -sin(fov_half); sin(fov_half) cos(fov_half)];
dedge_l = ROT * dview;
ROT = [cos(-fov_half) -sin(-fov_half); sin(-fov_half) cos(-fov_half)];
dedge_r = ROT * dview;

dedge_l = [dedge_l(2); dedge_l(1)];
dedge_r = [dedge_r(2); dedge_r(1)];

% Find the points on the horizon at the edges of the field of view
% We are given the length in meters that we want to go, and the direction
% We apprixomate by just adding a fraction of the direction
% FIXME: we really should not do this approximation...
temp = [ISS_latlon(1) + dedge_l(1) ISS_latlon(2) + dedge_l(2)];
mult_dist = m_lldist( [ISS_latlon(2) temp(2)], [ISS_latlon(1) temp(1)] );
dist_left = d_horiz / mult_dist;

temp = [ISS_latlon(1) + dedge_r(1) ISS_latlon(2) + dedge_r(2)];
mult_dist = m_lldist( [ISS_latlon(2) temp(2)], [ISS_latlon(1) temp(1)] );
dist_right = d_horiz / mult_dist;

left_top_pt = dedge_l * dist_left + ISS_latlon;
right_top_pt = dedge_r * dist_right + ISS_latlon;

% TODO: check this!

% Get the max latitude, min latitude, min longitude, max longitude
min_lat = min([ISS_latlon(1) left_top_pt(1) right_top_pt(1)]);
max_lat = max([ISS_latlon(1) left_top_pt(1) right_top_pt(1)]);
min_lon = min([ISS_latlon(2) left_top_pt(2) right_top_pt(2)]);
max_lon = max([ISS_latlon(2) left_top_pt(2) right_top_pt(2)]);


% Set up the projection
%m_proj( 'oblique', 'lat', [min_lat max_lat], 'lon', [min_lon max_lon], 'aspect', 1 );
figure
worldmap( [(min_lat-5) (max_lat+5)], [(min_lon-5) (max_lon+5)]);

% Plot the contours
%m_coast('patch', [.6 .6 .6]);
%load coast;
%plotm(lat, long);
geoshow('landareas.shp', 'FaceColor', [0.5 0.5 0.5]);


% Plot the grid
%m_grid('box', 'fancy', 'tickdir', 'in');

% Plot lines between the ISS [lat lon] to these points to indicate the 
% view wedge
plotm([ISS_latlon(1) left_top_pt(1)], [ISS_latlon(2) left_top_pt(2)],'r');
plotm([ISS_latlon(1) right_top_pt(1)], [ISS_latlon(2) right_top_pt(2)], 'r');
plotm([ISS_latlon(1) next_frame(1)], [ISS_latlon(2) next_frame(2)], 'b');

% Calculate where the aurora is
% We know where the aurora is in the image... we can calculate the
% 'midpoint' very roughly...
% Given this midpoint, and radius of circle, we need to calculate where the
% 

% Calculate where the horizon is... the fraction of black to white when cutting
% out the earth
% 

% So, read in the segmented image file (should be black and white)
horizon_IM = horizon_segmented;

[nrows, ncols, depth] = size(horizon_IM);

% Get the proportion that is black vs white
total = nrows * ncols;
horizon_IM = (horizon_IM(:,:,1) == 0);
num_black = sum(sum(horizon_IM(:,:,1)));
black_proportion = num_black/total;
white_proportion = 1 - black_proportion;

% We can then figure out at what approximate row we have the horizon (very very approximate)
% This assumes the horizon is straight... this is a bad approximation
horizon = nrows * white_proportion;

% Angle to horizon
angle_to_horizon = pi/2 - alpha;

aurora_IM = aurora_segmented;
aurora_IM = (aurora_IM(:,:,1) == 1);

[nrows, ncols, depth] = size(aurora_IM);


% For each black point, we project it onto the image
pts = [];
for row = 1:nrows
	for col = 1:ncols
		if( aurora_IM(row, col,1) == 1 )
	%		col
			[pt_lat pt_lon] = ll_of_xy_in_image( ISS_latlon, ISS_alt, dview, angle_to_horizon, horizon, nrows, ncols, row, col );
            pts(end+1,:) = [pt_lat pt_lon];
            %	[pt_lat pt_lon]
			
		end
	end
end

plotm(pts, '*', 'Color', 'green'); 
title('ISS Camera FOV and approximate aurora location over earth');

end