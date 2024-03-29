function maskdata=mask0104(img,up,down)%up:mask上表面距离皮肤表面的像素点；down:mask下表面距离皮肤表面的像素点；
[nx,ny]=size(img);
data0=zeros(nx,ny);
for i=1:1:ny
    for j=50:1:nx-up
        if(img(j,i)==0)
            if(j+down>=nx)
                m=nx;
            else
                m=j+down;
            end
            if(j+up>=nx)
                n=nx;
            else
                n=j+up;
            end            
            data0(n:1:m,i)=1;
            break;
        end
    end
end
maskdata=data0;
end