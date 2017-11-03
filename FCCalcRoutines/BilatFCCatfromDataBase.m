database='H:\SarahsPumpProject\SarahsPumpProject.xlsx';
excelfiles=[3:10];

outname='cat';
regtype={'Whole'};

for n=excelfiles;
    
    [~, ~, raw]=xlsread(database,1, ['A',num2str(n),':G',num2str(n)]);
    Date=num2str(raw{1});
    Mouse=raw{2};
    rawdataloc=raw{3};
    saveloc=raw{4};
    directory=[saveloc, Date, '\'];
    cd(directory);
    
    if exist([Date,'-',Mouse, '-fc-', outname, '.mat'])
        for r=1:numel(regtype)
            vars = whos('-file',[Date,'-',Mouse, '-fc-', outname, '.mat']);
            if ismember(['BilatMap_',Mouse, '_', regtype{r}], {vars.name})
                disp(['Bilateral fc data using regression type ', regtype{r}, ' already calculated for ', 'n = ', num2str(n), ', ', Date, '-', Mouse])
                continue
            else
                disp(['Calculating Bilateral fc data for n = ' , num2str(n),', ' Mouse, '-', Date,', Regression Type: ', regtype{r}])
                
                load([Date,'-',Mouse, '-fc-', outname, '.mat'], 'xform_datahb', 'xform_isbrain', 'files')
                [R_LR]=fcManySeed(xform_datahb, SeedsUsed, xform_isbrain, regtype{r});
                BiCorIm=CalcBilateral(R_LR, SeedsUsed);
                
                v = genvarname(['BilatMap_',Mouse,'_',regtype{r}]);
                eval([v '=BiCorIm;']);
                
                disp(['Saving Bilateral fc data for ', Mouse, ' n = ',num2str(n), ', Regression Type: ', regtype{r}])
                save([directory,Date,'-',Mouse, '-fc-', outname, '.mat'], ['BilatMap_',Mouse,'_',regtype{r}],'-append');
                clear(['BilatMap_',Mouse,'_',regtype{r}], 'xform_dathb', 'xform_isbrain', 'R_LR')
                close all
            end
        end
    else
        disp(['No concatenated data found for n = ',num2str(n), ', ' Date, '-', Mouse])
    end
    
end


