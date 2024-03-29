%% 3D Figure Reconstruction
clc;clear;close all;
dirfigure = '..\data\jpg3d';
figure3d=zeros(430,401,401);
for i = 1:1:430
    file_path=[dirfigure 'm' num2str(i,'%04d') '.jpg'];
    img = imread(file_path);
    figure3d(i,:,:)=img;
    i
end
dirmask = '..\data\png_mask3d';
mask=zeros(430,401,401);
for i = 1:1:430
    file_path=[dirmask 'm' num2str(i,'%04d') '.png'];
    img = imread(file_path);
    mask(i,:,:)=mask0104(img,10,100);
    i
end
processed_figure=mask.*figure3d;
imagesc(processed_figure);




