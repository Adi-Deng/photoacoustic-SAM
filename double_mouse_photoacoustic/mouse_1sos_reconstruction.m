clc;clear;close all;
pathfile=pwd;
cd '..\data';
load('Sinogram_averaged_850.mat')
cd (pathfile);
FOV = 400;          % 图像窗口视野大小
pixel_size = 1e-4/2;  % 探测像元尺寸0.1/2mm
% 高通滤波器 
fs=40e6;
low_frq=3e5;      % 设置低频
high_frq=20e6;    % 设置高频
data_filt = fir_filter(Sinogram_averaged,fs,low_frq,high_frq);
figure(1);imagesc(data_filt);colormap gray;
%% 鼠轮廓 单声速重建
delay=-106;
vs =1514;
sos1data = DAS_ring_double(data_filt,delay,vs,pixel_size,FOV);
figure(1);imagesc(rot90(sos1data)),colormap gray,axis image,caxis([-0.03 0.06]),title(['单声速图像重建-水速',num2str(vs)]);
pause(1);
cd ..;
cd '.\data\mat_raw';
save('figure_1sos.mat','sos1data');
cd (pathfile);