% This script will read in the list of data collection sites, and group
% participants based on where their data came from

clc; clear;

FID = fopen('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/SiteList.csv');  %the 't' is important!

% create file list for fmri data
MRIS = dir('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/AURORA_Shen_Connectivity_ForZiv/*.csv');

% convert MRI name list to cell array
for m = 1:size(MRIS,1)
    MRInames{m,1} = MRIS(m).name;
end

d = textscan(FID,'%s%s','Delimiter',',');

for c = 1:size(d,2)
    sitedata(:,c)=d{1,c};
end

SITES = {'McLean','Emory','Temple','WSU','WUSL'};

% loop through all subjects and store their PIDN in a list for each site
% separately
ix1 = 0; ix2 = 0; ix3 = 0; ix4 = 0; ix5 = 0;
for sb = 2:size(sitedata,1)

    site_ix = strcmp(sitedata{sb,2},SITES);
    wsite = find(site_ix == 1);
    eval(sprintf('ix%d = ix%d + 1;',wsite,wsite));
    eval(sprintf('%s_PID_list(ix%d,1) = str2num(sitedata{sb,1});',SITES{1,wsite},wsite));

    clear site_ix wsite

end   % for sb = 2:size(sitedata,1)

clear ix* sb c FID d

% loop through each site, load each participant's MRI, store in a conn
% matrix, and save the 1) matrix and 2) PID list

for s = 5:size(SITES,2)

    ix=0; ixf=0;
    for p = 1:size(eval(sprintf('%s_PID_list',SITES{1,s})),1)

        MR_ix = strfind(MRInames,num2str(eval(sprintf('%s_PID_list(p,1)',SITES{1,s}))));
                
        MR_loc = find(~cellfun(@isempty,MR_ix));

        if ~isempty(MR_loc)

            ix=ix+1;
            fmri = csvread([MRIS(MR_loc).folder '/' MRIS(MR_loc).name]);

            try
                if size(fmri,1) == 269
                    conn(:,:,ix) = fmri(2:end,:);
                    fmri = fmri(2:end,:);
                elseif size(fmri,2) == 269
                    conn(:,:,ix) = fmri(:,2:end);
                    fmri = fmri(:,2:end);
                else
                    conn(:,:,ix) = fmri(:,:);
                end

                eval(sprintf('%s_PID_list_final(ix,1) = %s_PID_list(p,1);',SITES{1,s},SITES{1,s}));

            catch
                ixf=ixf+1;
                eval(sprintf('%s_failed{ixf,1} = MRIS(MR_loc).name;',SITES{1,s}));
                ix=ix-1;
            end

            clear fmri

        end   %~isempty(MR_ix) 

        clear MR_ix MR_loc

    end   %for p = 1:size(eval(sprintf('%s_PID_list',SITES{1,s})),1)

    outdir = sprintf('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/%s/',SITES{1,s});
    
    if ~exist(outdir,'dir')
        mkdir(outdir)
    end

    %save matrices and sublist
    %do one final QC check that 'conn' and 'PIDN_list_final' dims match
    if size(conn,3) == size(eval(sprintf('%s_PID_list_final',SITES{1,s})),1)
        save(sprintf('%s/connectome.mat',outdir),'conn');

        PIDNs = eval(sprintf('%s_PID_list_final',SITES{1,s}));
        save(sprintf('%s/%s_PIDN_list.mat',outdir,SITES{1,s}),'PIDNs');

    else
        error('there is a mismatch between the number of people in the file list and the number of MRIs in the connectomes');
    end

    clear conn outdir PIDNs
end   % for s = 1:size(SITES,2)




