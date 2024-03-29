function [Rx,Ry,x0,y0,alpha,mask_sub] = double_vs(Sinogram,FOV,pixel_size,mask)
%% 双声速光声图像重建（小鼠肝脏）
%% 取图像分割mask
I = Sinogram(1:2000,:);
mask_sub=mask(:,:,1)./255;
Pic2=logical(mask(:,:,1));
% figure;imagesc(Pic2);title('Pic2');
boundry_pixel = edge(Pic2,'canny');  % 取边缘
[consider_I,consider_J] = find(boundry_pixel>0);
consider_I = consider_I.';    % 横坐标序列
consider_J = consider_J.';
 
%% 取最小外接矩形
[dataY,dataX] = find(Pic2==0);
[rectx,recty,area,perimeter] = minboundrect(dataX,dataY,'a'); % 'a'是按面积算的最小矩形，如果按边长用'p'
figure(1),imshow(Pic2); hold on
line(rectx,recty,'Color','red','LineStyle','-');
[Ry,Rx] = minboxing(rectx(1:4),recty(1:4));   % 返回短轴和长轴的数值

Ry = Ry*pixel_size/2;     % 长短轴数值是矩形边长的1/2
Rx = Rx*pixel_size/2;

recty(:) = FOV-recty(:);
alpha = atan((recty(2)-recty(3))/(rectx(2)-rectx(3)));

x0 = mean(rectx(1:4))*pixel_size;
y0 = mean(recty(1:4))*pixel_size;

%------------------------
rectx1 = rectx(1:4);
recty1 = recty(1:4); 
rect_point = [rectx1,recty1];
rect_point_a = rect_point-rect_point(1,:);
rect_length = sum(rect_point_a.*rect_point_a,2);
[v,p] = sort(rect_length);
alpha = atan((recty1(p(3))-recty1(1))/(rectx1(p(3))-rectx1(1)));
alpha = pi/2;
x0 = x0-FOV/2*pixel_size;  % 需要减去成像区域的一半大小才是真实数值
y0 = y0-FOV/2*pixel_size;  

end