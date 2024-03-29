function pa_img =DAS_ring_double(Sinogram,delay,vs,pixel_size,FOV)
%% 
r=0.05;
fs=40e6;
angle_ori=0;
[nsample,nstep]=size(Sinogram);
delay_idx=ones(1,nstep)*delay/fs;
pa_data=Sinogram;
%% 
x_center=0;
y_center=0;
x_size=FOV*pixel_size;
y_size=FOV*pixel_size;
resolution_factor =1e-3/pixel_size;
Npixel_x = round(x_size*resolution_factor*1e3);%1300
Npixel_y = round(y_size*resolution_factor*1e3);
x_range = ((1:Npixel_x)-(Npixel_x)/2)*x_size/(Npixel_x)+x_center;  
y_range = ((Npixel_y:-1:1)-(Npixel_y)/2)*y_size/(Npixel_y)+y_center;
x_img = ones(Npixel_y,1)*x_range;
y_img = y_range.'*ones(1,Npixel_x);

per_step=2*pi/nstep;
angle=(0:nstep-1)*per_step+angle_ori;
r = r -40e-6 - 120e-6 * cos(2 * angle) + 5e-5;
x_receive=r.*cos(angle);
y_receive=r.*sin(angle);

%% 
pa_img = zeros(Npixel_y, Npixel_x); % image bufc
angle_sum=0;
for istep=1:nstep
    pa_data_tmp=pa_data(:,istep);
    dx=x_img-x_receive(istep);
    dy=y_img-y_receive(istep);
    r0=sqrt(x_receive(istep)^2+y_receive(istep)^2); 
    distance=sqrt(dx.^2+dy.^2); % distance to the detector
    angle_weight=abs((x_receive(istep)*dx+y_receive(istep)*dy)/r0./distance)./distance.^2; 
    angle_sum = angle_sum + angle_weight;

    idx = distance./vs-delay_idx(istep);%
    idx = round(idx*fs);
    
    idx(idx > nsample) = 1;   %2000
    idx(idx < 1) = 1;
    
    pa_img = double(pa_img) + double(pa_data_tmp(idx));
        
end
pa_img = pa_img./angle_sum;
end