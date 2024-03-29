clc;clear;close all;
imagepath='../SAM_segmentation/result9/pic.png';
maskpath='../SAM_segmentation/result9/mpic.tif'
image=imread(imagepath);
mpic=imread(maskpath);
d = mpic;
d(d<2) = 0;
for i = 2:1:34
    if(mean(mean(image(mpic == i)))<75)
         d(mpic == i) = 0;
    end
end
d(d~=0) = 1;
%%
for i = 1:1:500
   for j = 1:1:500
       if(image(i,j)>200)
           d(i,j) = 1;
       end
   end
end
imagesc(d),axis image;