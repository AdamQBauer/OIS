database='G:\OISProjects\Holtzman Lab\HyGly\HyGlyDataBase.xlsx';

excelfiles=[76:81];  % Rows from Excell Database

for n=excelfiles;
    
    [~, ~, raw]=xlsread(database,1, ['A',num2str(n),':K',num2str(n)]);
    Date=num2str(raw{1});
    Mouse=raw{2};
    rawdataloc=raw{3};
    saveloc=raw{4};
    sessiontype=eval(raw{6});
    directory=[saveloc, Date, '\'];
    
    if ischar(raw{10})
        GoodRuns=str2num(raw{10});
    else
        GoodRuns=raw{10};
    end
    
    if ~isnan(GoodRuns)
        load([directory, Date,'-', Mouse,'-LandmarksandMask.mat'], 'xform_isbrain', 'I');
        GoodOxyL=[];
        GoodDeOxyL=[];
        GoodOxyR=[];
        GoodDeOxyR=[];
        GoodPres=eval(raw{11});
        i=0;
        
        for sr=GoodRuns
            i=i+1;
            load([directory, Date,'-', Mouse,'-stim', num2str(sr), '-datahb.mat'], 'Oxy', 'DeOxy');
            disp(['Loading ', Date,'-', Mouse,'-stim', num2str(sr)])
            [nVy, nVx, block, numblock]=size(Oxy);
            for h=1:block;
                for m=1:numblock;
                    Oxy(:,:,h,m)=Affine(I, Oxy(:,:,h,m));
                end
            end
            
            [nVy, nVx, block, numblock]=size(DeOxy);
            for h=1:block;
                for m=1:numblock;
                    DeOxy(:,:,h,m)=Affine(I, DeOxy(:,:,h,m));
                end
            end
            
            StimPres=cell2mat(GoodPres{i,1});
            if sr<4
                GoodOxyL=cat(4,GoodOxyL, Oxy(:,:,:,StimPres));
                GoodDeOxyL=cat(4,GoodDeOxyL, DeOxy(:,:,:,StimPres));
            else
                GoodOxyR=cat(4,GoodOxyR, Oxy(:,:,:,StimPres));
                GoodDeOxyR=cat(4,GoodDeOxyR, DeOxy(:,:,:,StimPres));
            end
        end
        
        if ~isempty(GoodOxyL)
            GoodTotalL=GoodOxyL+GoodDeOxyL;
            MeanGoodOxyL=mean(GoodOxyL,4);
            MeanGoodDeOxyL=mean(GoodDeOxyL,4);
            MeanGoodTotalL=mean(GoodTotalL,4);
            
            if ~exist([directory, Date,'-', Mouse,'-Activations.mat']);
                disp(['Saving left activation for ', Date,'-', Mouse,'-stim'])
                save([directory, Date,'-', Mouse,'-Activations.mat'],'MeanGoodOxyL','MeanGoodDeOxyL','MeanGoodTotalL',...
                    'GoodOxyL', 'GoodDeOxyL', 'GoodTotalL','xform_isbrain');
            else
                disp(['Saving left activation for ', Date,'-', Mouse,'-stim'])
                save([directory, Date,'-', Mouse,'-Activations.mat'],'MeanGoodOxyL','MeanGoodDeOxyL','MeanGoodTotalL',...
                    'GoodOxyL', 'GoodDeOxyL', 'GoodTotalL','xform_isbrain', '-append');
            end
             
            MeanGoodTotalL=reshape(MeanGoodTotalL,128*128,[]);
            MeanGoodOxyL=reshape(MeanGoodOxyL,128*128,[]);
            MeanGoodDeOxyL=reshape(MeanGoodDeOxyL,128*128,[]);
            
            idx=find(MeanGoodTotalL(:,15)>0.5*max(max(MeanGoodTotalL(:,15))));
            TotalTraceL=mean(MeanGoodTotalL(idx,:),1);
            OxyTraceL=mean(MeanGoodOxyL(idx,:),1);
            DeOxyTraceL=mean(MeanGoodDeOxyL(idx,:),1);
            
            save([directory, Date,'-', Mouse,'-Activations.mat'],'TotalTraceL','OxyTraceL','DeOxyTraceL', '-append');
        end
        
        if ~isempty(GoodOxyR)
            GoodTotalR=GoodOxyR+GoodDeOxyR;
            MeanGoodOxyR=mean(GoodOxyR,4);
            MeanGoodDeOxyR=mean(GoodDeOxyR,4);
            MeanGoodTotalR=mean(GoodTotalR,4);
            
            if ~exist([directory, Date,'-', Mouse,'-Activations.mat']);
                disp(['Saving right activation for ', Date,'-', Mouse,'-stim'])
                save([directory, Date,'-', Mouse,'-Activations.mat'],'MeanGoodOxyR','MeanGoodDeOxyR','MeanGoodTotalR',...
                    'GoodOxyR', 'GoodDeOxyR', 'GoodTotalR','xform_isbrain');
            else
                disp(['Saving right activation for ', Date,'-', Mouse,'-stim'])
                save([directory, Date,'-', Mouse,'-Activations.mat'],'MeanGoodOxyR','MeanGoodDeOxyR','MeanGoodTotalR',...
                    'GoodOxyR', 'GoodDeOxyR', 'GoodTotalR','xform_isbrain', '-append');
            end
            
            MeanGoodTotalR=reshape(MeanGoodTotalR,128*128,[]);
            MeanGoodOxyR=reshape(MeanGoodOxyR,128*128,[]);
            MeanGoodDeOxyR=reshape(MeanGoodDeOxyR,128*128,[]);
            
            idx=find(MeanGoodTotalR(:,15)>0.5*max(max(MeanGoodTotalR(:,15))));
            TotalTraceR=mean(MeanGoodTotalR(idx,:),1);
            OxyTraceR=mean(MeanGoodOxyR(idx,:),1);
            DeOxyTraceR=mean(MeanGoodDeOxyR(idx,:),1);
            
            save([directory, Date,'-', Mouse,'-Activations.mat'],'TotalTraceR','OxyTraceR', 'DeOxyTraceR', '-append');
        end
        
        clearvars -except excelfiles saveloc database directory n dataloc
    else        
        disp(['No good runs for ', Date,'-', Mouse])
    end
end

clear excelfiles saveloc database directory
