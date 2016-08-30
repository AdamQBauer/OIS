function [R, R_LR, SeedsUsed, strace, P]=fcseed(datahb, WL, isbrain, tag, meth, seeds, isbrain2)

%Calculates functional connectivity patterns and values for seed locations

% datahb: processed rawdata (hemoglobin data)
% WL: White Light image of mouse, fc pattersn are overlaid on this image
% isbrain: binary brain mask
% tag: label for figure
% seeds: optional input with coordinates of seed locations. if not
% specified, you'll be asked to click locations
% isbrain2: optional mask for 2 signal regression

% (c) 2009 Washington University in St. Louis
% All Right Reserved
%
% Licensed under the Apache License, Version 2.0 (the "License");
% You may not use this file except in compliance with the License.
% A copy of the License is available is with the distribution and can also
% be found at:
%
% http://www.apache.org/licenses/LICENSE-2.0
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE, OR THAT THE USE OF THE SOFTWARD WILL NOT INFRINGE ANY PATENT
% COPYRIGHT, TRADEMARK, OR OTHER PROPRIETARY RIGHTS ARE DISCLAIMED. IN NO
% EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
% OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
% STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
% ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

if ~exist('tag','var'); tag=''; elseif isempty(tag); tag=''; else tag=tag; end
if ~exist('isbrain2','var'); isbrain2=[]; end
if ~exist('signal1','var'); isbrain2=[]; end

seednames={'Olf','Fr','Cg','M','SS','RS','V','Au'};
sides={'L','R'};

numseeds=numel(seednames);
numsides=numel(sides);
[nVy,nVx]=size(isbrain);

mm=10;                          % field of view
mpp=mm/nVx;                     % mm to pixel conversion
seedradmm=0.25;                 % radius of seed in mm
seedradpix=seedradmm/mpp;       % radius of seed in pixels
isbrain=single(isbrain);

datahb(isnan(datahb))=0;
WL(isnan(WL))=0;
isbrain(isnan(isbrain))=0;

%% Signal Regression
if ndims(datahb)>3
    [datahb3]=gsr_multi(datahb,isbrain, meth, isbrain2);
else
    datahb3=datahb;
end
datahb3=real(reshape(datahb3,nVy*nVx,[]));

% [~,~,~,~,datahb2]=gsr_stroke2(datahb,isbrain, meth, isbrain2);
% [datahb3, ~]=gsr_stroke2(datahb2,isbrain, 'Each', isbrain2);
% datahb3=reshape(datahb3,nVy*nVx,[]);


%% Specifiy seeds

if ~exist('seeds','var')
    fwl=figure;
    image(WL)
    axis image
    
    for s=1:numseeds
        for n=1:numsides
            snum=2*(s-1)+n;
            disp(['Locate seed: ',seednames{s},sides{n}])
            [x, y]=ginput(1);
            x=round(x);
            y=round(y);
            seeds(snum,:)=[x y];
        end
    end
end

%% Make sure specified seeds are within field of view
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


%% Visualize fc patterns and matricies
Seed=figure('Units','inches','Position',[7 3 10 7],'PaperPositionMode','auto','PaperOrientation','Landscape');
set(Seed,'Units','normalized','visible','on');

numseeds=size(SeedsUsed,1)/2;

for s=1:numseeds
    OE=0;
    if mod(s,2)==0
        OE=0.25;
    else
        OE=0.05;
    end
    
    subplot('position', [OE (0.65-((round(s/2)-1)*0.15)) 0.1 0.1]);
    Im2=overlaymouse(R(:,:,(2*(s-1)+1)),WL, isbrain,'jet',-1,1);
    image(Im2);
    hold on;
    plot(SeedsUsed(2*(s-1)+1,1),SeedsUsed(2*(s-1)+1,2),'k.','MarkerSize',14); %% remove 129- for newer data sets
    axis image off
    title([seednames{s},'L'])
    
    subplot('position', [OE+0.1 (0.65-((round(s/2)-1)*0.15)) 0.1 0.1]);
    Im2=overlaymouse(R(:,:,(2*(s-1)+2)),WL, isbrain,'jet',-1,1);
    image(Im2);
    hold on;
    plot(SeedsUsed(2*(s-1)+2,1),SeedsUsed(2*(s-1)+2,2),'k.','MarkerSize',14);
    axis image off
    title([seednames{s},'R'])
    hold off;
end

subplot('position', [0.55 0.52 0.35 0.4]);
imagesc(R_AP, [-1 1]); %title([tag, ' Correlation Map'],'FontWeight','bold','Color',[1 0 0]);
set(gca,'XTick',(1:16));
set(gca,'YTick',(1:16));
set(gca,'XTickLabel',{'OL','OR','FL','FR','CL','CR','ML','MR','SL','SR','RL','RR','VL','VR','AL','AR'});
set(gca,'YTickLabel',{'OL','OR','FL','FR','CL','CR','ML','MR','SL','SR','RL','RR','VL','VR','AL','AR'});

subplot('position', [0.55 0.05 0.35 0.4]);
imagesc(R_LR, [-1 1]);
set(gca,'XTick',(1:16));
set(gca,'YTick',(1:16));
set(gca,'XTickLabel',{'OL','FL','CL','ML','SL','RL','VL','Al','OR','FR','CR','MR','SR','RR','VR','AR'})
set(gca,'YTickLabel',{'OL','FL','CL','ML','SL','RL','VL','Al','OR','FR','CR','MR','SR','RR','VR','AR'})

annotation('textbox',[0.125 0.95 0.75 0.05],'HorizontalAlignment','center',...
    'LineStyle','none','String',[tag,' Functional Connectivity, Regression Type:  ', meth],...
    'FontWeight','bold','Color',[0 0 1]);

annotation('textbox',[0 0.78 0.5 0.05],'HorizontalAlignment','center',...
    'LineStyle','none','String','Correlation Maps',...
    'FontWeight','bold','Color',[0 0 0]);

annotation('textbox',[0.55 0.91 0.35 0.05],'HorizontalAlignment','center',...
    'LineStyle','none','String','Correlation Matrices',...
    'FontWeight','bold','Color',[0 0 0]);

cb=colorbar('location','south','position', [0.165 0.15 0.17 0.02],...
    'XAxisLocation','bottom');
set(cb,'XTick',[-1 0 1])
xlabel(cb, 'Correlation Coefficeint, r')

output=[tag,'_', meth, '_R.jpg'];
orient portrait
print ('-djpeg', '-r300', output);

%close all

end




