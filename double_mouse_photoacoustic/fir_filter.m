function data_after = fir_filter(data,fs,low_frq,high_frq)

if((low_frq==0)&&(high_frq==fs/2))
    data_after = data;
end

if((low_frq==0)&&(high_frq<fs/2))
   b = fir1(100,high_frq/(fs/2),'low',hamming(51));
   data_after = filter(b,1,data);
end 

if((low_frq>0)&&(high_frq<fs/2))
  b = fir1(100,[low_frq/(fs/2) high_frq/(fs/2)],'bandpass',chebwin(51,50));
  data_after = filter(b,1,data);
end 

if((low_frq>0)&&(high_frq==fs/2))
  b=fir1(100,low_frq/(fs/2),'high');  
  data_after=filter(b,1,data);
end

end 