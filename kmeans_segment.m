
function [ horizon_image cut_rgb_image aurora ] = kmeans_segment(file, FULL)

rgb_IM = imread(file);

rgb_IM = imresize(rgb_IM, 0.25);

[nx, ny, depth] = size(rgb_IM);

b_IM = MyGaussianBlur(rgb_IM(:,:,2),3);

depth = 1;

% Transform and segment
ab_IM = reshape(b_IM, nx*ny, 1);

ncolours = 3;

% Repeat mean shift clustering 2 times to avoid local minima
[cluster_idx cluster_center] = kmeans(ab_IM, ncolours, 'distance', 'sqEuclidean', 'Replicates', 5, 'EmptyAction', 'drop', 'start', 'cluster');

% Label every pixel in image

pixel_labels = reshape(cluster_idx, nx, ny);
clustering = figure;

hold on;
colorbar('vert');
imshow(uint8(pixel_labels),[]), title('image labeled by cluster index');
hold off;

print( clustering, '-djpeg', [file '_kmeans_cluster_'  '.jpeg']);

% Make segmentation 2D
seg = (pixel_labels == 1);

% Find the largest area in segmentation

cut_rgb_image = rgb_IM;
horizon_image = ones([size(rgb_IM,1) size(rgb_IM,2)]);

first_type = seg(1,1);

for j = 1:ny
	fill_with_0 = false;
	for i = 1:nx
		if( seg(i,j) ~= first_type )
			fill_with_0 = true;
		end
		if( fill_with_0 )
			horizon_image(i,j) = 0;
			cut_rgb_image(i,j,1) = 0;
			cut_rgb_image(i,j,2) = 0;
			cut_rgb_image(i,j,3) = 0;
		end
	end
end

%fig4 = figure(4);
horizon_image_(:,:,1) = horizon_image;
horizon_image_(:,:,2) = horizon_image;
horizon_image_(:,:,3) = horizon_image;
%imshow( horizon_image_ );
imwrite( horizon_image_ ,[file '_kmeans_horizon_'], 'jpg');

%fig5 = figure(5);
%imshow( cut_rgb_image );
%print( fig5, '-djpeg', [file '_kmeans_cut_' '.jpeg']);
imwrite( cut_rgb_image ,[file '_kmeans_cut_' ], 'jpg');


first_type = pixel_labels(1,1);

second_type = -1;
for i = 1:nx
	for j = 1:ny
		if( pixel_labels(i,j) ~= first_type )
			if( second_type == -1 )
				second_type = pixel_labels(i,j);
			end
		end
	end
end

aurora = zeros(size(pixel_labels));
for i = 1:nx
	for j = 1:ny
		if( pixel_labels(i,j) ~= first_type && pixel_labels(i,j) ~= second_type )
			aurora(i,j) = 1;
		end
	end
end


for i = ceil(2*nx/3):nx
	for j = 1:ny
		aurora(i,j) = 0;
	end
end

%fig8 = figure(8)
aurora_(:,:,1) = aurora;
aurora_(:,:,2) = aurora;
aurora_(:,:,3) = aurora;
%imshow(aurora_)
%print( fig8, '-djpeg', [file '_kmeans_aurora_' '.jpeg']);
imwrite( aurora_ ,[file '_kmeans_aurora_' ], 'jpg');

end
