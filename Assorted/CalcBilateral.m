function [BiCorIm]=CalcBilateral(R_LR, SeedsUsed)

numseeds=size(R_LR,1);
bilatdiag=numseeds./2+1;
BiCorIm=zeros(128,128);

j=1;
m=bilatdiag-1;

for n=1:bilatdiag-1;
    m=m+1;
    BiCorIm(SeedsUsed(j,2),SeedsUsed(j,1))=R_LR(m,n); %left deleted "129-" in y coord
    BiCorIm(SeedsUsed(j+1,2),SeedsUsed(j+1,1))=R_LR(m,n); %right deleted "129-" in y coord
    j=j+2;
end

end
