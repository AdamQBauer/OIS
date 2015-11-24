database='G:\OISProjects\CulverLab\Stroke\OptoStroke.xlsx';
outname='cat';

excelfiles=[80:94];  % Rows from Excell Database

for n=excelfiles;

    [~, ~, raw]=xlsread(database,1, ['A',num2str(n),':I',num2str(n)]);
    Date=num2str(raw{1});
    Mouse=raw{2};
    rawdataloc=raw{3};
    saveloc=raw{4};
    directory=[saveloc, Date, '\'];
    cd(directory);
    
    if ~isnan(raw{9})
        if ischar(raw{9})
            Runs=str2num(char(raw{9}));
        else
            Runs=raw{9};
        end
        disp(['Concatenating files ', num2str(Runs), ' from ', Date, '-', Mouse])
        mousecat_xform(Mouse,Date,'fc',outname,[Runs]);
    end        
end