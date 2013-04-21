function new_phi = calcInitalPhi(phi)
% By: Jeff Orchard
% calInitalPhi: calculates inital phi, using a distance function.
% In other words it calculates all the inital level sets.

[n m] = size(phi);
new_phi = zeros(n,m);
in_or_out = ones(n,m);
%initalize new array to a large number.
new_phi(:) = Inf;

% First look for the zero level set.
for i=2:n-1
    for j = 2:n-1
        if (phi(i,j) < 100)
            if (max(max(phi(i-1:i+1,j-1:j+1))) > 200)
                % if its on the contour, mark it as 0.
                new_phi(i,j) = 0;
            end
        else
            % otherwise, give it a small value.
            in_or_out(i,j) = -1;
        end
    end
end

% Now set each element new_phi(i,j) to d(i,j) where d(i,j) = the distance to the nearest point on the zero levelset.

% For now, I'm just doing the nieve O(n^4) implementation

% for i = 1:n
%     for j = 1:m
%         for x = 1:n
%             for y = 1:m
%                 if new_phi(x,y) == 0
%                     if (abs(new_phi(i,j)) > sum(([i j]-[x y]).^2).^0.5)
%                         if (new_phi(i,j) < 0)
%                             new_phi(i,j) = (-1)*sum(([i j]-[x y]).^2).^0.5;
%                         else
%                             new_phi(i,j) = sum(([i j]-[x y]).^2).^0.5;
%                         end
%                     end
%                 end
%             end
%         end
%     end
% end

maxd = ceil(sqrt(m^2+n^2))

for x = 1:maxd
    old_phi = new_phi;
    x
	for i= 2:n-1
        for j = 2:m-1
            if (new_phi(i,j) > 0)
                new_phi(i,j) = min(min(new_phi(i-1:i+1,j-1:j+1))) + 1;
            end
        end
	end
    diff = size(old_phi(:),1) - sum(sum(old_phi==new_phi)) 
    if (old_phi == new_phi)
        break
    end

end


new_phi(1,1) = min(min(new_phi(1:2,1:2)))+1;
new_phi(n,m) = min(min(new_phi(n-1:n,m-1:m)))+1;
new_phi(1,m) = min(min(new_phi(1:2,m-1:m)))+1;
new_phi(n,1) = min(min(new_phi(n-1:n,1:2)))+1;
new_phi(2:n-1,1)= new_phi(2:n-1,2)+1;
new_phi(2:n-1,m)= new_phi(2:n-1,m-1)+1;
new_phi(1,2:m-1)= new_phi(2,2:m-1)+1;
new_phi(n,2:m-1)= new_phi(n-1,2:m-1)+1;

new_phi = new_phi .* in_or_out;
