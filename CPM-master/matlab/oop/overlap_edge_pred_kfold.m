%%%% If we want to go down this road, I'll need to set this up so that each
%%%% cohort is split into k-folds, each fold is run one at a time, and then
%%%% within each fold, overlapping edges are identified and used to predict
%%%% in each cohort within each iteration

clear; 

load('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/connectome.mat');
load('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/T1_PCL.mat');
x=conn; clear conn
%y=T3; clear T3

for i = length(y):-1:1
    if isnan(y(i))
        y(i) = [];
        x(:,:,i) = [];
    end
end


T1_AU = main(x,y,length(y),'results');  
%save('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/TelAviv/Hariri/CPM_data/output/T3_CAPS5_arousal.mat','results');

%%

pos_ix_AU = sum(T1_AU.all_pos_edges, 2) == size(T1_AU.all_pos_edges, 2);
pos_AU = find(pos_ix_AU == 1);

neg_ix_AU = sum(T1_AU.all_neg_edges, 2) == size(T1_AU.all_neg_edges, 2);
neg_AU = find(neg_ix_AU == 1);

%%
testconn = load('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/connectome.mat');
testconn = testconn.conn;

ytest = load('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/T3_PCL.mat');
ytest = ytest.y;

for i = length(ytest):-1:1
    if isnan(ytest(i))
        ytest(i) = [];
        testconn(:,:,i) = [];
    end
end

T3_AU_test = main_forceEdges(testconn,ytest,length(ytest),pos_ix_overlap,neg_ix_overlap,'results',1);