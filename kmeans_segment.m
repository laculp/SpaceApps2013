
function ret = kmeans_segment(file)

%file = 'HighRes_quebec/ISS030-E-53334';
rgb_IM = imread([file '.jpg']);

rgb_IM = imresize(rgb_IM, 0.25);

figure
imshow(uint8(rgb_IM))
[nx, ny, depth] = size(rgb_IM)

% Blur the image
%G = fspecial('gaussian', [nx ny], 0.1);
%G = fftn(ifftshift(G));
%temp = fftn( rgb_IM );
%b_IM(:,:,1) = MyGaussianBlur(rgb_IM(:,:,1),3);%imfilter(rgb_IM(:,:,1), G);
b_IM = MyGaussianBlur(rgb_IM(:,:,2),3);%imfilter(rgb_IM(:,:,2), G);
%b_IM(:,:,3) = MyGaussianBlur(rgb_IM(:,:,3),3);%imfilter(rgb_IM(:,:,3), G);
%B = real(ifftn(b_IM));
%b_IM = imfilter(rgb_IM, G, 'same');%MyGaussianBlur(rgb_IM, );

depth = 1;

figure
imshow(b_IM, []);

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
%i = 1;
%j = 1;
%colour = 1;
%largest_area = 0;
%largest_area_size = 0;
%while( j <= ny )
%	if( ( seg(i,j) > 0 ) && ( seg(i,j) == 1 ) )
%		% We have a new area! Explore around this until we find seg(x,y) = 0
%		% (Flood-Fill method)
%		colour = colour + 1;
%		Q(1,1) = j;
%		Q(1,2) = i;
%		Q_size = 1;
%		area_size = 0;
%		while( Q_size > 0 )
%			n = Q(1,:);
%			Q(1,:) = [];
%			Q_size = Q_size - 1;
%			if( n(1) <= nx && n(2) <= ny )
%				if( seg(n(1), n(2)) == 1 )
%					area_size = area_size + 1;
%					w = n;
%					e = n;
%					while( (seg(w(1), w(2)) == 1) && w(1) > 1 )
%						w(1) = w(1) - 1;
%					end
%					while( (seg(e(1), e(2)) == 1) && e(1) < nx )
%						e(1) = e(1) + 1;
%					end
%					for x = w(1):e(1)
%						seg(x,n(2)) = colour;
%					%	if( n(2) > 1 )
%							if( seg(x,n(2)-1) == 1 )
%								Q_size = Q_size + 1;
%								Q(Q_size,1) = x;
%								Q(Q_size,2) = n(2)-1;
%%							end
%						end
%						if( n(2) < ny )
%							if( seg(x,n(2)+1) == 1 )
%								Q_size = Q_size + 1;
%								Q(Q_size,1) = x;
%%								Q(Q_size,2) = n(2) + 1;
%%							end
%						end
%					end
%				end
%			end
%		end
%		if( area_size > largest_area_size )
%			largest_area_size = area_size;
%%			largest_area = colour;
%%		end
%	end
%	if( i+1 > nx )
%		i = 1;
%		j = j + 1;
%	else
%		i = i + 1;
%	end
%end

%	figure(4)
%	imshow(seg, [0, colour+1]);

% Now, only show largest area
%aurora = seg == largest_area;

%fig5 = figure(5)
%imshow(aurora);

%print( fig5, '-djpeg', [file '_kmeans_aurora_' num2str(dispInterval) '_' num2str(end_t) '_' num2str(delta_t) '_' num2str(sigma) '_' num2str(epsilon) '.jpeg']);
%

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
imwrite( horizon_image_ ,[file '_kmeans_horizon_' '.jpg'], 'jpg');

%fig5 = figure(5);
%imshow( cut_rgb_image );
%print( fig5, '-djpeg', [file '_kmeans_cut_' '.jpeg']);
imwrite( cut_rgb_image ,[file '_kmeans_cut_' '.jpg'], 'jpg');


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
imwrite( aurora_ ,[file '_kmeans_aurora_' '.jpg'], 'jpg');

end
