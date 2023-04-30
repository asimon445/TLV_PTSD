%% This script will organize and structure the PTSD data for CPM
% Run this script before running 'main.m'

clc;clear;

%% User-defined parameters
%load clinical data
FID = fopen('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/PCL_longitudinal.csv');  %the 't' is important!

% create file list for fmri data
MRIS = dir('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/AURORA_Shen_Connectivity_ForZiv/*.csv');
EXT = '.csv';  %files that I z-transformed will be .mats. 

DATASET = 'AURORA';  % use 'Aurora' for Aurora, 'Tel Aviv' for Tel Aviv

% column indexes behavioral data to save for CPM (these will be the
% predicted variables)
COLIXS = [8,9];   %[19,21,22,24];   %Tel Aviv      [2:7];   % Aurora
%HEADER = {'﻿Subject ID','intrusion','avoidance','mood','arousal'};

OUTFOLDER = '/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/';

if ~exist(OUTFOLDER,'dir')
    mkdir(OUTFOLDER)
end

%% Load the behavioral data
isTA = strncmp(DATASET,'Tel Aviv',8);
isAU = strncmp(DATASET,'AURORA',6);

if isTA
    d = textscan(FID,'%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s','Delimiter',',');
   % d = textscan(FID,'%s%s%s%s%s','Delimiter',',');
    for c = 1:size(d,2)
        rawcsvdata(:,c)=d{1,c};
    end

    FID(close);

    % header needs to be hard-coded, matlab was reading the header in a funky
    % format when it was included in the csv
    % DON'T CHANGE THIS
    HEADER = {'PIDN','MRI_file','T1_TotalCaps5','T1_TotalCaps4','T1_Is_PTSD_Final','T2_TotalCaps5',...
    'T2_TotalCaps4','T2_Is_PTSD_Final','T3_TotalCaps5','T3_TotalCaps4','T3_Is PTSD_Final','Trajectory',...
'T1_Qual_PCL','T2_Qual_PCL','T3_Qual_PCL','T1_Qual_CGI','T2_Qual_CGI','T3_Qual_CGI','T1_Qual_BDI','T2_Qual_BDI','T3_Qual_BDI',...
'T1_Qual_BAI','T2_Qual_BAI','T3_Qual_BAI','Trauma_type','Gender','Age'};

elseif isAU
    d = textscan(FID,'%s%s%s%s%s%s%s%s%s','Delimiter',',');
 %   d = textscan(FID,'%s%s%s%s%s%s%s','Delimiter',',');

    for c = 1:size(d,2)
        rawcsvdata(:,c)=d{1,c};
    end

    HEADER = {'PID','PRE_PCL5_RS','WK2_PCL5_RS','WK8_PCL5_RS','M3_PCL5_RS','M6_PCL5_RS','M12_PCL5_RS','Sex','Age'};
   % HEADER = {'PID','PRE_PCL5_RS','WK2_PCL5_RS','WK8_PCL5_RS','M3_PCL5_RS','M6_PCL5_RS','M12_PCL5_RS'};
else
    error('labeling of the dataset is incorrect');
end

% how many columns from the survey data are being indexed?
NUMSURVS = length(COLIXS);

%% Load MRIs and filter out participants from csvdata who do not have MRIs
% ix = 1;

% for s = 2:size(rawcsvdata,1)
%     fnamemtch = strmatch(MRIS(ix).name(5:5+5),rawcsvdata{s,1});
%     if ~isempty(fnamemtch)
%         for col = 1:size(rawcsvdata,2)
%             csvsfinal{ix,col} = rawcsvdata{s,col};
%         end
%         ix = ix+1;
%     end
% end


ix=1;
mrisfinal=struct;
for s = 1:size(MRIS,1)

    m=0; ixc = 0;

    while m==0
        try
            ixc = ixc+1;

            if isTA
                mrinum = str2double(MRIS(s).name(5:5+3));
            elseif isAU
                mrinum = str2double(MRIS(s).name(5:5+5));
            end

            if ixc == 1
                csvnum = 5;
            else
                csvnum = str2double(rawcsvdata{ixc,1});
            end

            if csvnum == mrinum   %~isempty(fnamemtch)
                m=1;
                for col = 1:size(rawcsvdata,2)
                    csvsfinal{ix,col} = rawcsvdata{ixc,col};
                end
                
                mrisfinal(ix).name = MRIS(s).name;
                mrisfinal(ix).folder = MRIS(s).folder;

                ix = ix+1;
            end
        catch
            m=1;
        end
    end
end

% ix=0;
% for i = size(rawcsvdata,1):-1:1
% 
%     if ~isempty(rawcsvdata{i,2})
%         ix=ix+1;
%         for c = 1:size(rawcsvdata,2)
%             usecsvdata{ix,c} = rawcsvdata{i,c};
%         end
%     end
% 
% end

mrisfinal=mrisfinal';

%% Check that filenames between fMRI and clinical datasets match

if size(csvsfinal,1) == size(mrisfinal,1)
    for i = 1:size(csvsfinal,1)
        if isTA
            fnum(i,1) = str2num(mrisfinal(i).name(5:8));
        elseif isAU
            fnum(i,1) = str2num(mrisfinal(i).name(5:10));
        end
        
        try
            fnum(i,2) = str2num(csvsfinal{i,1});
        catch 
            if isempty(str2num(csvsfinal{i,1}))
                fnum(i,2) = str2num(csvsfinal{1,1}(2:end));
            end
        end
    end
else
    error('number of csvs in list does not match number of fMRI files');
end

mismatch = find(fnum(:,1) ~= fnum(:,2));

if ~isempty(mismatch)
    error('behavioral/clinical data are misaligned with the fmri data');
end

% load fMRI connectome data and condense it all into one variable
for m = 1:size(mrisfinal,1)
    
    ismat = strncmp(EXT,'.mat',4);
    iscsv = strncmp(EXT,'.csv',4);

    if ismat
        load([mrisfinal(m).folder '/' mrisfinal(m).name]);
        fmri = z_fmri;
    elseif iscsv
        fmri = csvread([mrisfinal(m).folder '/' mrisfinal(m).name]);
    end

%     dash = strfind(mrisfinal(m).name(1:end-4),'-');
%     if ~isempty(dash)
%         name = strrep(mrisfinal(m).name(1:end-4),'-','_');
%     else
%         name = mrisfinal(m).name(1:end-4);
%     end
% 
%     fmri = eval(sprintf('%s',name));

    % remove the IX line in the first row (or column) (if there is one)
    if size(fmri,1) == 269
        conn(:,:,m) = fmri(2:end,:);
        fmri = fmri(2:end,:);
    elseif size(fmri,2) == 269
        conn(:,:,m) = fmri(:,2:end);
        fmri = fmri(:,2:end);
    else
        conn(:,:,m) = fmri(:,:);
    end

    clear fmri

end

%check that the values within 'conn' are within reasonable bounds (did the
%line that I'm supposed to delete end up in an unexpected location, and
%thus end up in the final data?)

check = squeeze(max(conn(:,:,:)));
check = max(check);
overlim = find(check > 14);
if ~isempty(overlim)
    error('There was an fMRI file that had the index line included in the connectome data. Fix this.');
end

%check for NaNs in the connectome
for i = length(check):-1:1

    if isnan(check(i))
        mrisfinal(i) = [];
        csvsfinal(i,:) = [];
        check(i) = [];
        conn(:,:,i) = [];
        fnum(i,:) = [];
    end
end

save(sprintf('%s/connectome.mat',OUTFOLDER),'conn');

for i = 1:length(COLIXS)
    
    for row = 1:size(csvsfinal,1)
        if str2double(csvsfinal{row,COLIXS(1,i)}) > 0
            y(row,1) = str2double(csvsfinal{row,COLIXS(1,i)});
        elseif isnan(str2double(csvsfinal{row,COLIXS(1,i)}))
            y(row,1) = NaN;
        else
            y(row,1) = 0;
        end
    end

    save(sprintf('%s/%s.mat',OUTFOLDER,HEADER{1,COLIXS(1,i)}),'y');
    clear y
end


