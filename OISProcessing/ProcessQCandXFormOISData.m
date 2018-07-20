database='/Users/kenny/Documents/GitHub/BauerLab/data/NewProbeSample.xlsx';
ledLoc = '/Users/kenny/Documents/GitHub/OIS/Spectroscopy/LED Spectra';
excelfiles=2;  % Rows from Excell Database

for n=excelfiles
    
    [~, ~, raw]=xlsread(database,1, ['A',num2str(n),':F',num2str(n)]);
    Date=num2str(raw{1});
    Mouse=raw{2};
    rawdatadir=raw{3};
    saveloc=raw{4};
    system=raw{5};
    sessiontype=eval(raw{6});
    rawdataloc=fullfile(rawdatadir, Date);
    if ~isdir(rawdataloc)
        rawdataloc = fullfile(rawdatadir);
    end
    directory=fullfile(saveloc, Date);
    
    GetLandMarksandMask(Date, Mouse, directory, rawdataloc, system);
end

% poolobj = gcp('nocreate'); % If no pool, do not create new one.
% if isempty(poolobj)
%     parpool('local',8)
% end

for n=excelfiles
    
    [~, ~, raw]=xlsread(database,1, ['A',num2str(n),':F',num2str(n)]);
    Date=num2str(raw{1});
    Mouse=raw{2};
    rawdatadir=raw{3};
    saveloc=raw{4};
    system=raw{5};
    sessiontype=eval(raw{6});
    rawdataloc=fullfile(rawdatadir, Date);
    if ~isdir(rawdataloc)
        rawdataloc = fullfile(rawdatadir);
    end
    directory=fullfile(saveloc, Date);
    
    if ~exist(directory)
        mkdir(directory);
    end
    
    for t=1:numel(sessiontype)
        if ~exist('info', 'var')
            if strcmp(sessiontype{t},'fc')
                info.framerate=16.8;
                info.freqout=1;
                info.lowpass=0.5;
                info.highpass=0.009;
            elseif strcmp(sessiontype{t},'stim')
                info.framerate=29.76;
                info.freqout=1;
                info.lowpass=0.5;
                info.highpass=0.009;
                info.stimblocksize=60;
                info.stimbaseline=5;
                info.stimduration=10;
            end
        end
        fileName = fullfile(rawdataloc,[Date,'-',Mouse, '.tif']);
        [datahb, WL, op, E, info]=procOISData(fileName, info, system,ledLoc);
%         OISQC(Date, Mouse, sessiontype{t}, directory, rawdataloc, info, system);
        cd(directory)
        TransformDatahb(Date, Mouse, sessiontype{t});
        clear info
    end
end

