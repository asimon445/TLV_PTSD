% this will build connectomes from faces stimuli during the Hariri task 
% connectomes will be run through CPM

clear;

FMRIS = dir('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/TelAviv/Hariri/timecourse/*.csv');

load('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/TelAviv/Hariri/CPM_data/T1_CAPS5_﻿Subject ID.mat');
subnum = y; clear y;

FACES_ON = [2,90,178,266,354];  %[40,128,216,304];
FACES_DUR = [36,36,36,36,36];  %[48,48,48,48];

for i = 1:length(FMRIS)
    fmrinum(i,1) = str2num(FMRIS(i).name(5:8));
end

[sameix,ia] = intersect(fmrinum,subnum);

fMRIS_use = FMRIS(ia);
failures = {};
ixf = 0;

for i = 1:length(fMRIS_use)

    FID = fopen([fMRIS_use(i).folder '/' fMRIS_use(i).name]);

    % don't mess with the line below!
    d = textscan(FID,'%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s'...
        ,'Delimiter',',');
    for c = 1:size(d,2)
        fmri_TS(:,c)=d{1,c};
    end

    FID(close);

    fmri_TS = str2double(fmri_TS);
    fmri_TS(1,:) = [];

    % this file is formatted TR x node. Transpose it to make it easier for
    % me to think about!
    fmri_TS = fmri_TS';
    
    % aggregate data from only 'faces' blocks
    try
        fmri_faces=[];
        for tr = 1:length(FACES_ON)
            fmri_faces = [fmri_faces fmri_TS(:,(FACES_ON(tr)/2):(FACES_ON(tr)/2)+(FACES_DUR(tr)/2)-1)];
        end

        conn_raw = corr(fmri_faces');

        %z-score the connectome
        avg = mean(conn_raw,"all");
        stdv = std(conn_raw,0,"all");

        for r = 1:size(conn_raw,1)
            for c = 1:size(conn_raw,2)
                conn(r,c,i) = (conn_raw(r,c) - avg) / stdv;
            end
        end

    catch
        ixf = 1;
        failures{ixf,1} = fMRIS_use(i).name;
        
        for r = 1:268
            for c = 1:268
                conn(r,c,i) = NaN;
            end
        end
    end

    clear avg stdv conn_raw fmri_faces fmri_TS d c FID 
    
end

save('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/TelAviv/Hariri/CPM_data/connectome_shapesOnly.mat','conn');
save('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/TelAviv/Hariri/CPM_data/shapesConn_failures.mat','failures');


%% run CPM
for i = length(y):-1:1
    if isnan(y(i))
        y(i) = [];
        conn(:,:,i) = [];
    end
    if isnan(conn(1,1,i))
        y(i) = [];
        conn(:,:,i) = [];
    end
end
results = main(conn,y,10,'dingleberry');
