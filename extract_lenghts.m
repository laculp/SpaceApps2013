%% Do the actual extraction of lenghts.

% Extract min max values of star trails + lengths.

% Assumes input of X

[nx ny nz] = size(X);

seen = zeros(nx,ny);
colour = 1;
result = zeros(nx,ny);
lengths = [0 0 0 0 0];


for i = 3:nx-3
    for j = 3:ny-3
        
        % No need to look at seen pixels
        if seen(i,j) == 1
            continue;
        end       
        
        % We don't care to segment the background 
        if X(i,j) == 0
           continue; 
        end
        
        % We found a new pixel, add it to queue.        
        queue = [];
        queue(1, :) = [i j];
        q_length = 1;
        seen(i, j) = 1;
        result(i,j) = colour;
        min = [i j];
        max = [i j];
        
        while q_length > 0
            
            % Pop the top element from the queue
            coord = queue(q_length, :);
            q_length = q_length - 1;            
            
            % Look at the 8-neighbourhood
            for n = -1:1
                for m = -1:1
                    % Don't look at the current pixel
                    if n == 0 && m == 0
                        continue;
                    end
                    
                    if X(coord(1) + n, coord(2) + m) > 0.001 ...
                            && seen(coord(1) + n, coord(2) + m) == 0
                                                                        
                        % Add to queue
                        queue(q_length + 1, :) = [(coord(1) + n) (coord(2) + m)];
                        q_length = q_length + 1;
                        
                        % Mark the fact we added this pixel to the current
                        % segment. 
                        seen(coord(1) + n, coord(2) + m) = 1;
                        result(coord(1) + n, coord(2) + m) = colour;
                        
                        % Update the min/max values
                        if min(1) > coord(1) + n
                            min(1) = coord(1) + n;
                            min(2) = coord(2) + m;
                        end

                        if max(1) < coord(1) + n
                            max(1) = coord(1) + n;
                            max(2) = coord(2) + m;
                        end

                    end
                    
                end
            end
        end
        
        lengths(colour, :) = [ (max(2)-1) (nx-max(1)) (min(2)-1) (nx-min(1)) sqrt((max(1) - min(1))^2 + (max(2) - min(2))^2 ) ];
        
        colour = colour + 1;
    end
end

%% Graph the result, and output only the values to text file.

out_file = fopen('star_trail_end_points.txt', 'w');

lengths2 = sortrows(lengths,5);

for c = 1:colour-1
    
    x1 = lengths2(c,1);
    y1 = lengths2(c,2);
    
    x2 = lengths2(c,3);
    y2 = lengths2(c,4);
    
    len = lengths2(c,5);
    
    
    % If one of the end values is small and the other is large
    % accept the line, else just reject the line.
    if ( X(nx - y1, x1 + 1) < 10 &&  X(nx - y2, x2 + 1) >= 5000 ) || ...
        ( X(nx - y2, x2 + 1) < 10 &&  X(nx - y1, x1 + 1) >= 5000 ) && ...
        lengths2(c,2) > 1000  % Remove this last line when segmenting is done.
    
        if ( X(nx - y1, x1 + 1) < 10 &&  X(nx - y2, x2 + 1) >= 5000 )
            % The first point is the starting point.
            fprintf(out_file, '%d %d %d %d %f\n', x1*2, y1*2, x2*2, y2*2, len*2);
        else
            % The second point is the starting point.
            fprintf(out_file, '%d %d %d %d %f\n', x2*2, y2*2, x1*2, y1*2, len*2);
        end
    
        hold on;
        plot([lengths2(c,1) lengths2(c,3)], [lengths2(c,2) lengths2(c,4)]);
        
    end
end

xlim([0 ny]);
ylim([0 nx]);
