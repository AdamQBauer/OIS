function [R_seed]=fcManySeed(datahb,seeds, isbrain1, meth, isbrain2)

if ~exist('isbrain2','var'); isbrain2=[]; end

nVx=128;

  if ndims(datahb)>3
      [datahb3]=gsr_stroke2(datahb,isbrain1, meth, isbrain2);
  else
     datahb3=datahb;
 end

datahb3=reshape(datahb3,nVx*nVx,[]);

m=1; 
mm=10;
mpp=mm/nVx;
seedradmm=0.25;
seedradpix=seedradmm/mpp;

R_seed=zeros(size(seeds,1),size(seeds,1),'single');
strace=zeros(size(seeds,1),size(datahb3,2));

for n=1:size(seeds,1);
    P=zeros(128,128);
    xc=seeds(n,1);
    yc=seeds(n,2);
    for y=1:nVx
        for x=1:nVx
            if norm([x y]-[xc yc])<=seedradpix
                P(y,x)=1;
            end
        end
    end
    %P=rot90(P);
    strace(n,:)=mean(datahb3(P==1,:),1);
end

R_seed=makeRs(datahb3,strace);
length=size(seeds,1);
map=[(1:2:length-1) (2:2:length)]; % All the right Seeds first, then the left.
R_seed=R_seed(map, map); %to go back to original layout, R_Seed(map, map)=R_Seed

end
