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
%% 鼠轮廓 双声速重建
maskpath='..\data\sam_segmentation\mat_mask';
resultpath='..\data\jpg_2sos_sam';
matpath='..\data\mat_2sos_sam';
pathfile=pwd;
cd (maskpath);
load('test2_sam_mask.mat');
cd(pathfile);
%去除mask的黑边
[m,n]=size(data);
for i = 1:m
    data(i,1)=1;data(1,i)=1;data(i,2)=1;
    data(2,i)=1;data(i,3)=1;data(3,i)=1;
    data(i,4)=1;data(4,i)=1;
    data(i,5)=1;data(5,i)=1;
end
delay_filt = -106;
[Rx,Ry,x0,y0,alpha,mask_sub] = double_vs(data_filt,FOV,pixel_size,data);
vs_water=1509;
vs_animal=1535;
WholeImage3 = -DAS_ring_double2(data_filt,delay_filt,Rx,Ry,x0,y0,...
         alpha,vs_water, vs_animal,pixel_size,FOV);
figure(1);imagesc(rot90(WholeImage3,3)),colormap gray,axis image,caxis([-0.03 0.06]),colorbar,...
title(['SAM双声速重建—水速：',num2str(vs_water),'鼠速：',num2str(vs_animal)]);
cd(resultpath);
exportgraphics(gca,sprintf('Sam_2sos_water_%d_animal_%d.png',vs_water,vs_animal));
cd(pathfile);
data2=rot90(WholeImage3,3);
cd(matpath);
save('test_2sos.mat','data2');
cd(pathfile);