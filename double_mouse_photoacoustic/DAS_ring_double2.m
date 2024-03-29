function pa_img =DAS_ring_double2(Sinogram,delay,Rx,Ry,x0,y0,alpha,vs_water, vs_animal,pixel_size,FOV)
%% 参数设定

r=0.05;
fs=40e6;
angle_ori=0;
% 采样角度从0度开始，设定的意义在于为了旋转图像至适合观察
[nsample,nstep]=size(Sinogram);   % 设定数据测量时间与换能器个数
delay_idx=ones(1,nstep)*delay/fs; % 对每个通道延迟时间
pa_data=Sinogram;
%% 建立坐标
%图像坐标
x_center=0;
y_center=0;
x_size=FOV*pixel_size;
y_size=FOV*pixel_size;
resolution_factor =1e-3/pixel_size; % 分辨率，线对/mm
Npixel_x = round(x_size*resolution_factor*1e3);%FOV
Npixel_y = round(y_size*resolution_factor*1e3);
x_range = ((1:Npixel_x)-(Npixel_x)/2)*x_size/(Npixel_x)+x_center;  % x轴坐标设定
y_range = ((Npixel_y:-1:1)-(Npixel_y)/2)*y_size/(Npixel_y)+y_center;
x_img = ones(Npixel_y,1)*x_range;  % 构建坐标计算矩阵
y_img = y_range.'*ones(1,Npixel_x);

%探测器坐标
per_step=2*pi/nstep;
angle=(0:nstep-1)*per_step+angle_ori;
%r = r -40e-6 - 120e-6 * cos(2 * angle) + 5e-5;
x_receive=r.*cos(angle);
y_receive=r.*sin(angle);

%% 图像计算
pa_img = zeros(Npixel_y, Npixel_x); % image buffer
angle_sum=0;
for istep=1:nstep%%***************************************************
    pa_data_tmp=pa_data(:,istep);%每次计算提取一个角度的数值
    dx=x_img-x_receive(istep);
    dy=y_img-y_receive(istep);
    r0=sqrt(x_receive(istep)^2+y_receive(istep)^2);
    distance=sqrt(dx.^2+dy.^2); % distance to the detector
    angle_weight= acos(min(abs((x_receive(istep)*dx+y_receive(istep)*dy)/r0./distance),0.999))+1.0e-5;
   
    angle_weight=real(cos(angle_weight ))./distance.^2;%向量叉乘求sin/d2作为权重
    %angle_weight=abs((x_receive(istep)*dx+y_receive(istep)*dy)/r./distance)./distance.^2;%向量叉乘求sin/d2作为权重
    angle_sum = angle_sum + angle_weight;

    [L1,L2] = find_length_ellip(Rx,Ry,x0,y0,x_img,y_img,x_receive(istep),y_receive(istep),alpha);
    idx = L1./vs_animal + L2./vs_water-delay_idx(istep); 
 
   %时间修正
    idx = round(idx*fs);
    
    idx(abs(idx) > nsample) = 1;   %2000
      idx(idx< 1) = 1;
    idx(abs(idx) < 1) = 1;%2000以上和1以下置位1
   
    pa_img = double(pa_img) + double(pa_data_tmp(idx));
    
end
pa_img = -rot90(pa_img./angle_sum,2);

end


