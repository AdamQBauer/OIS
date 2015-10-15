function [data]=readtiff(filename)

info = imfinfo(filename);
numI = numel(info);
data=zeros(info(1).Height,info(1).Width,numI,'uint16');
fid=fopen(filename);
fseek(fid,info(1).Offset,'bof');

for k = 1:numI
    fseek(fid,[info(1,1).StripOffsets(1)-info(1).Offset],'cof');
    tempdata=fread(fid,info(1).Height*info(1).Width,'uint16');
    data(:,:,k) = rot90((reshape(tempdata,info(1).Height,info(1).Width)),-1);
end

fclose(fid);

end