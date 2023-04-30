% Use predictive edges from domino (T1) in Tel Aviv to predict T1 PCL in
% Aurora from Rest


% 1. Identify edges in domino that are predictive across all cross validation
%    folds
% 2. Sum posititve and negative edges
% 3. Put those into a predictive model with rest data and try to predict T1
%    PCL
%%
clear; 

load('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/TelAviv/Resting/CPM_data/connectome.mat');
load('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/TelAviv/Resting/CPM_data/T1_PCL4_converted_PCL5.mat');
x=conn; clear conn
%y=T3; clear T3

for i = length(y):-1:1
    if isnan(y(i))
        y(i) = [];
        x(:,:,i) = [];
    end
end


T1_TLV = main(x,y,length(y),'results');  
%save('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/TelAviv/Hariri/CPM_data/output/T3_CAPS5_arousal.mat','results');

%%

pos_ix_TLV = sum(T1_TLV.all_pos_edges, 2) == size(T1_TLV.all_pos_edges, 2);
pos_TLV = find(pos_ix_TLV == 1);

neg_ix_TLV = sum(T1_TLV.all_neg_edges, 2) == size(T1_TLV.all_neg_edges, 2);
neg_TLV = find(neg_ix_TLV == 1);

%%
testconn = load('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/connectome.mat');
testconn = testconn.conn;

ytest = load('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/T1_PCL.mat');
ytest = ytest.y;

for i = length(ytest):-1:1
    if isnan(ytest(i))
        ytest(i) = [];
        testconn(:,:,i) = [];
    end
end

T1_AU_test = main_forceEdges(testconn,ytest,length(ytest),pos_ix_TLV,neg_zeros,'results',1);

% 
% % Categorical
% for i = 1:length(ytest)
%     if ytest(i) <= 35   %the SVM code won't work if a category is defined as 0, so we're changing 0 -> 1 and 1 -> 2
%         PTSD(i) = 1;
%     else
%         PTSD(i) = 2;
%     end
% end
% 
% 
% [ptsd_pred, acc, sensitivity, specificity, precision] = cpm_classifier_main_forceEdegs(testconn,PTSD,all_pos_ix,all_neg_ix,'per_feat',0.1,'kfolds',10,'learner','svm');
% 
