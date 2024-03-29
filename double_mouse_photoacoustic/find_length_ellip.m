function [L1,L2] = find_length_ellip1(Rx,Ry,x0,y0,xs,ys,xd,yd,alpha)
% all parameters in mm
% definition see note 8/18
% used in the reconstruction algorithm
% xs and ys are matrices
% set all L1, L2 values outside ellipse to zero
%anglecorrect=[cos(alpha),-sin(alpha);sin(alpha),cos(alpha)];

k = (yd-ys)./(xd-xs);
b = ys-k.*xs;

%%
m = Ry.^2*(cos(alpha)).^2 + Rx.^2*(sin(alpha)).^2 + k.^2*(Ry.^2*(sin(alpha)).^2 + Rx.^2*(cos(alpha)).^2) -(Ry^2+Rx^2)*sin(2*alpha)*k;
n = -2*x0*(Ry.^2*(cos(alpha)).^2 + Rx.^2*(sin(alpha)).^2) + 2*k.*(b-y0)*(Ry.^2*(sin(alpha)).^2 + Rx.^2*(cos(alpha)).^2) -(Ry^2+Rx^2)*sin(2*alpha).*(b-y0-k*x0);
q = x0^2*(Ry.^2*(cos(alpha)).^2 + Rx.^2*(sin(alpha)).^2) +(b-y0).^2*(Ry.^2*(sin(alpha)).^2 + Rx.^2*(cos(alpha)).^2) + (Ry^2+Rx^2)*sin(2*alpha).*(x0.*(b-y0)) - Rx^2*Ry^2;

x1 = (-n+sqrt(n.^2-4*m.*q))/2./m;
x2 = (-n-sqrt(n.^2-4*m.*q))/2./m;
x=zeros(size(xs));
xt = zeros(size(xs));

% x代表第一个交点
% xt 代表第二个交点或者xs本身
% 如果没有第一个交点，则x和xt均为0

%整条直线没有交点情况
x(x1~=real(x1)) = 0;
xt(x1~=real(x1)) = 0;

%直线有交点，线段无交点情况
x(x1==real(x1)&(xs-x1).*(xs-x2)>0 & (x2-xs).*(xd-xs)<0) =  0;% xs在外部 无交点
xt(x1==real(x1)&(xs-x1).*(xs-x2)>0&(x2-xs).*(xd-xs)<0) =  0;% xs在外部 无交点


%有一个交点情况
x(x1==real(x1)&(xs-x1).*(xs-x2)<0 & (x2-xs).*(xd-xs)>0) = x2(x1==real(x1)&(xs-x1).*(xs-x2)<0&(x2-xs).*(xd-xs)>0); % xs在内部，x2是第一个交点
x(x1==real(x1)&(xs-x1).*(xs-x2)<0 & (x1-xs).*(xd-xs)>0) = x1(x1==real(x1)&(xs-x1).*(xs-x2)<0&(x1-xs).*(xd-xs)>0); % xs在内部，x1是第一个交点
xt(x1==real(x1)&(xs-x1).*(xs-x2)<0) = xs(x1==real(x1)&(xs-x1).*(xs-x2)<0);

%有两个交点
x(x1==real(x1)&(xs-x1).*(xs-x2)>0 & (x2-xs).*(xd-xs)>0 & (x1-xd).*(x1-x2) <0) = x1(x1==real(x1)&(xs-x1).*(xs-x2)>0 & (x2-xs).*(xd-xs)>0 & (x1-xd).*(x1-x2) <0);% xs在外部, x1在xs x2中间
xt(x1==real(x1)&(xs-x1).*(xs-x2)>0 & (x2-xs).*(xd-xs)>0 & (x1-xd).*(x1-x2) <0) = x2(x1==real(x1)&(xs-x1).*(xs-x2)>0 & (x2-xs).*(xd-xs)>0 & (x1-xd).*(x1-x2) <0);% xs在外部, x1在xs x2中间

x(x1==real(x1)&(xs-x1).*(xs-x2)>0 & (x2-xs).*(xd-xs)>0 & (x1-xd).*(x1-x2) >0) = x2(x1==real(x1)&(xs-x1).*(xs-x2)>0 & (x2-xs).*(xd-xs)>0 & (x1-xd).*(x1-x2) >0);% xs在外部, x2在xs x1中间
xt(x1==real(x1)&(xs-x1).*(xs-x2)>0 & (x2-xs).*(xd-xs)>0 & (x1-xd).*(x1-x2) >0) = x1(x1==real(x1)&(xs-x1).*(xs-x2)>0 & (x2-xs).*(xd-xs)>0 & (x1-xd).*(x1-x2) >0);% xs在外部, x2在xs x1中间


y = k.*x+b;
yt = k.*xt+b;


L1 = sqrt((x-xt).^2+(y-yt).^2);
L = sqrt((xd-xs).^2+(yd-ys).^2);
L2 = L-L1;
% figure(4);imagesc(L1);colormap gray;title('L1 animal')
% figure(5);imagesc(L2);colormap gray;title('L2 water')

return
