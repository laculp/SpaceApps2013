
% Parameters:
% ===========
dispInterval = 10;
end_t = 1000;
dx = 1;
dy = 1;
% delta_t value should be around 0.3 - 0.7 or so.
delta_t = 0.25;
direction = 'contract';
Dtype = 'upwind'; % try 'upwind' or 'central'
sigma = 1;
epsilon = 0;

file = 'HighRes_quebec/ISS030-E-53334';

I = imread([file '.jpg']);
I = double( rgb2gray(I) );

I = imresize(I, 0.05);

% Vn: force in the normal direction
Vn = -0.2*ones(size(I));

[nx ny depth] = size(I);
phi = nx*ones([nx ny]);
count = 2;
for i=2:nx/2
	for k=2:count
		phi(i,k) = phi(i,k-1) -50;
	end
	for k=count:ny/2
		phi(i,k) = phi(i,k-1);
	end
	for k=1:ny/2
		phi(i,ny-k) = phi(i,k);
	end
	count=count + 1;
end
for i = 2:nx/2
	phi(nx - i,:) = phi(i,:);
end

% Comment out next line to continue evolving current phi.
%phi = calcInitalPhi(phi)
phi = floor(phi);
new_phi = phi;
phi = MyGaussianBlur(phi,8);

%phi = double(I);

b = 0.3*ones(size(phi));

disp = Inf;
fig1 = figure(1);
tic;
for n = 1:delta_t:end_t
%	phi = evolve2D(phi, dx, dy, 0.5, 15, [], [], 0, [], 0, [] ,[], 1, b);
	phi = lsStep(phi, delta_t, I, direction,Dtype,epsilon,sigma);
	disp = disp + 1;
	if disp > dispInterval
		disp = 0;
		hold off;
		pause(0.001);
		imagesc(I);colormap(gray);hold on;
		[c,h] = contour(phi,[0 0],'r');
		title(['t = ' num2str(ceil(n-1)) ]);
	end
end

toc

%greater_than_neg_1000 = phi > -500;
%phi(greater_than_neg_1000) = 0;

% Draw phi.
fig2 = figure(2)
imagesc(phi);
colorbar('vert');
hold on;
contour(phi,[0 0],'r');
hold off;

% Draw surface of phi.
fig3 = figure(3)
surfc(phi);
shading interp;

print( fig1, '-djpeg', [file '_seg_' num2str(dispInterval) '_' num2str(end_t) '_' num2str(delta_t) '_' num2str(sigma) '_' num2str(epsilon) '.jpeg']);

print( fig2, '-djpeg', [file '_end_phi_contour_' num2str(dispInterval) '_' num2str(end_t) '_' num2str(delta_t) '_' num2str(sigma) '_' num2str(epsilon) '.jpeg']);

print( fig3, '-djpeg', [file '_end_phi_' num2str(dispInterval) '_' num2str(end_t) '_' num2str(delta_t) '_' num2str(sigma) '_' num2str(epsilon) '.jpeg']);


% Make segmentation 2D
seg = phi;
seg(phi < 0) = 1;

% Find the largest area in segmentation
i = 1;
j = 1;
colour = 1;
largest_area = 0;
largest_area_size = 0;
%while( (i < nx) || (j < ny) )
while( j <= ny )
	if( ( seg(i,j) > 0 ) && ( seg(i,j) == 1 ) )
		% We have a new area! Explore around this until we find seg(x,y) = 0
		% (Flood-Fill method)
		colour = colour + 1;
		Q(1,1) = j;
		Q(1,2) = i;
		Q_size = 1;
		area_size = 0;
		while( Q_size > 0 )
			n = Q(1,:);
			Q(1,:) = [];
			Q_size = Q_size - 1;
			if( n(1) <= nx && n(2) <= ny )
			if( seg(n(1), n(2)) == 1 )
				area_size = area_size + 1;
				w = n;
				e = n;
				while( (seg(w(1), w(2)) == 1) && w(1) > 1 )
					w(1) = w(1) - 1;
				end
				while( (seg(e(1), e(2)) == 1) && e(1) < nx )
					e(1) = e(1) + 1;
				end
				for x = w(1):e(1)
					seg(x,n(2)) = colour;
					if( n(2) > 1 )
						if( seg(x,n(2)-1) == 1 )
							Q_size = Q_size + 1;
							Q(Q_size,1) = x;
							Q(Q_size,2) = n(2)-1;
						end
					end
					if( n(2) < ny )
						if( seg(x,n(2)+1) == 1 )
							Q_size = Q_size + 1;
							Q(Q_size,1) = x;
							Q(Q_size,2) = n(2) + 1;
						end
					end
				end
			end
		end
		end
		if( area_size > largest_area_size )
			largest_area_size = area_size;
			largest_area = colour;
		end
	end
	if( i+1 > nx )
		i = 1;
		j = j + 1;
	else
		i = i + 1;
	end
end

	figure(4)
	imshow(seg, [0, colour+1]);

% Now, only show largest area
aurora = seg == largest_area;

figure(5)
imshow(aurora);

