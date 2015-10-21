function Im2=overlaymouse(Im,WL,isbrain,cname,cmin,cmax)

%Im: greyscale data
%WL RGB image on which the Im data are overlaid
%isbrain is a binary mask where a "1" represents the location that Im data
%are positioned
%cname color map (e.g. jet, grey, etc)
%cmin/cmax are the range over which you'd like to plot Im data.

if max(WL(:))>1
    Im2=double(WL)/255;
else
    Im2=WL;
end

[nVy,nVx]=size(Im);

if ischar(cname)
    cmap=colormap(cname);
else
    cmap=cname;
end

if ischar(cmin)
    switch cmin
        case 'min'
            cmin=min(min(Im));
        case '-max'
            cmin=-max(max(Im));
        case 'minmax'
            cmin=-max([-min(min(Im)) max(max(Im))]);
    end
end

if ischar(cmax)
    switch cmax
        case 'max'
            cmax=max(max(Im));       
        case '-min'
            cmax=-min(min(Im));
        case 'minmax'
            cmax=max([-min(min(Im)) max(max(Im))]);       
    end
end

cnum=size(cmap,1);

cslope=(cnum-1)/(cmax-cmin);
cinter=1-cslope*cmin;

for x=1:nVx
    for y=1:nVy
        if isbrain(y,x)
            cidx=round(cslope*Im(y,x)+cinter);
            if cidx>cnum;
                cidx=cnum;
            end
            if cidx<1;
                cidx=1;
            end
            Im2(y,x,:)=cmap(cidx,:);
        end
    end
end


end