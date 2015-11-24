function VisualizefcMaps(R, R_LR, R_AP, WL, isbrain, SeedsUsed, tag, directory)

Seed=figure('Units','inches','Position',[7 3 10 7],'PaperPositionMode','auto','PaperOrientation','Landscape');
set(Seed,'Units','normalized','visible','on');
seednames={'Olf','Fr','Cg','M','SS','RS','V','Au'};
sides={'L','R'};
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
    'LineStyle','none','String',[tag],...
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

output=[directory, tag,'.jpg'];
orient portrait
print ('-djpeg', '-r300', output);
