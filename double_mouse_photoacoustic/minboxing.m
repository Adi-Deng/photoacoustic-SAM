
function [ wid,hei ] = minboxing( d_x , d_y )

%minboxing Summary of this function goes here

% Detailed explanation goes here

dd = [d_x, d_y];

dd1 = dd([4 1 2 3],:);

ds = sqrt(sum((dd-dd1).^2,2));

wid = min(ds(1:2));

hei = max(ds(1:2));

end