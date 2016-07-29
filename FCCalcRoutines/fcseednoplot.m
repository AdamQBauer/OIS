function [R, R_LR, R_AP]=fcseednoplot(datahb, isbrain, seeds, meth, isbrain2)

if ~exist('isbrain2'); isbrain2=''; end

[nVy,nVx]=size(isbrain);
mm=10;                          % field of view
mpp=mm/nVx;                     % mm to pixel conversion
seedradmm=0.25;                 % radius of seed in mm
seedradpix=seedradmm/mpp;       % radius of seed in pixels
isbrain=single(isbrain);

datahb(isnan(datahb))=0;
isbrain(isnan(isbrain))=0;

if ndims(datahb)>3
    [datahb3]=gsr_stroke2(datahb,isbrain, meth, isbrain2);
else
    datahb3=datahb;
end

datahb3=real(reshape(datahb3,nVy*nVx,[]));

for n=1:2:size(seeds,1)-1;
    if isbrain(seeds(n,2),seeds(n,1))==1 && isbrain(seeds(n+1,2),seeds(n+1,1))==1;  %%remove 129- on y coordinate for newer data sets
        SeedsUsed(n,:)=seeds(n,:);
        SeedsUsed(n+1,:)=seeds(n+1,:);
    else
        SeedsUsed(n,:)=[NaN, NaN];
        SeedsUsed(n+1,:)=[NaN, NaN];
    end
end

P=burnseeds(SeedsUsed,seedradpix,isbrain);          % make a mask of seed locations
strace=P2strace(P,datahb3, SeedsUsed);              % strace is each seeds trace resulting from averaging the pixels within a seed region
R=strace2R(strace,datahb3, nVx, nVy);               % R is the functional connectivity maps: normalize rows in time, dot product of those rows with strce
R_AP=makeRs(datahb3,strace);                        % R_AP is a matrix of the seed-to-seed fc values

idx=find(isnan(SeedsUsed(:,1)));
R(:,:,idx)=0;
R_AP(idx, idx)=0;

length=size(SeedsUsed,1);                           %reorder so bilateral connectivity values are on the off-diagonal
map=[(1:2:length-1) (2:2:length)];
R_LR=R_AP(map, map);

end