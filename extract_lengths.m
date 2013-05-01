% Extract min max values of star trails + lengths.
% 
% NOTE: data returned using standard image coordinates, not matlab index coordinates!
% The data format is: [ xmax, ymax, xmin, ymin, length ]
function data = extract_lengths(trails, resize_factor, FULL)

    % Do the actual extraction of lenghts.
    [nx ny nz] = size(trails);

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
            if trails(i,j) == 0
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
                        
                        if trails(coord(1) + n, coord(2) + m) > 0.001 ...
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

    % Graph the result, and output only the values to text file.

    %out_file = fopen('star_trail_end_points4.txt', 'w');

    lengths2 = sortrows(lengths,5);

    data = [];  

    if FULL == 1
        figure;
    end
    
    for c = 1:colour-1
        
        x1 = lengths2(c,1);
        y1 = lengths2(c,2);
        
        x2 = lengths2(c,3);
        y2 = lengths2(c,4);
        
        len = lengths2(c,5);
        
        % If one of the end values is small and the other is large
        % accept the line, else just reject the line.
        if ( ( trails(nx - y1, x1 + 1) < 10 &&  trails(nx - y2, x2 + 1) >= 5000 ) || ...
             ( trails(nx - y2, x2 + 1) < 10 &&  trails(nx - y1, x1 + 1) >= 5000 ) ) % && ...
            %lengths2(c,2) > 800 && ...  % Remove this last line when segmenting is done.
            %lengths2(c,5) > 40
        
            if ( trails(nx - y1, x1 + 1) < 10 &&  trails(nx - y2, x2 + 1) >= 5000 )
                % The first point is the starting point.
                %fprintf(out_file, '%d %d %d %d %f\n', x1*2, y1*2, x2*2, y2*2, len*2);
                data(end + 1, :) = [x1/resize_factor y1/resize_factor x2/resize_factor y2/resize_factor len/resize_factor];
            else
                % The second point is the starting point.
                %fprintf(out_file, '%d %d %d %d %f\n', x2*2, y2*2, x1*2, y1*2, len*2);
                data(end + 1, :) = [x2/resize_factor y2/resize_factor x1/resize_factor y1/resize_factor len/resize_factor];
            end
        
            % Plots lines if full output is enabled.
            if FULL == 1
                hold on;
                plot([lengths2(c,1) lengths2(c,3)], [lengths2(c,2) lengths2(c,4)]);
            end
        end
    end

    if FULL == 1
        xlim([0 ny]);
        ylim([0 nx]);
        title('Star trails plotted as lines');
        hold off;
    end

end
