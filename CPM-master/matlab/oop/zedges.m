
clear T1 T2 T3 conn zconn meanmat stdmat

load('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/WUSL/connectome.mat');
load('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/WUSL/T1_PCL_WUSL.mat');
load('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/WUSL/T2_PCL_WUSL.mat');
load('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/WUSL/T3_PCL_WUSL.mat');
load('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/WUSL/WUSL_PIDN_list.mat');


%%
for i = size(conn,3):-1:1

    if isnan(conn(1,2,i))
        conn(:,:,i) = [];
        T1(i) = [];
        T2(i) = [];
        T3(i) = [];
        PIDNs(i) = [];
    elseif isinf(conn(1,2,i))
        conn(:,:,i) = [];
        T1(i) = [];
        T2(i) = [];
        T3(i) = [];
        PIDNs(i) = [];
    end

end

save('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/WUSL/connectome.mat','conn');
save('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/WUSL/T1_PCL_WUSL.mat','T1');
save('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/WUSL/T2_PCL_WUSL.mat','T2');
save('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/WUSL/T3_PCL_WUSL.mat','T3');
save('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/WUSL/WUSL_PIDN_list.mat','PIDNs');

%%

meanmat = squeeze(mean(conn,3));
stdmat = squeeze(std(conn,0,3));
for r = 1:size(conn,1)
    for c = 1:size(conn,2)
        for s = 1:size(conn,3)
            zconn(r,c,s) = (conn(r,c,s) - meanmat(r,c)) / stdmat(r,c);
        end
    end
end

save('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/WUSL/connectome_zedges.mat','zconn');

