% 1. load connectome

% 2. vectorize the connectivity matrix for each subject, so we end up with an
% edge (all) x subject 2D matrix

% 3. load PCL data

% 4. create vector indicating 3 categories of patients: 1) didn't end up 
% with PTSD, 2) began with trauma response & ended up with PTSD, and 3)
% didn't have an initial trauma response but ended up with PTSD
%       !! For the first attempt, I will only use 2 categories: met
    %          diagnostic criteria and didn't meet diagnostic criteria
    % - Make sure that this varible is categorical (use 'categorical')
    % - The last category is the reference category (should be #1 -- those 
    %   who didn't end up with PTSD)

% 5. Select features that exceed alpha
%       !! does the CPM code correct for multiple comparisons?


%% Load relevant files
load('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/Combined/connectome.mat');
load('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/Combined/T3_PCL.mat');

%% remove NaNs
for i = length(T3):-1:1
    if isnan(T3(i))
        T3(i) = [];
        conn(:,:,i) = [];
    end
end

%% Format categorical variable 
for i = 1:length(T3)
    
    if T3(i,1) > 35
        categ{i,1} = 'PTSD';
    else 
        categ{i,1} = 'Healthy';
    end

end

PTSD = categorical(categ);

%% Format connectivity matrices 
%  Using the whole matrix will exceed the computer's memory capacity

for s = 1:size(conn,3)
    ix = 0;
    for r = 1:size(conn,1)
        for c = 1:r-1
            ix=ix+1;
            conn_trans(s,ix) = conn(r,c,s);
        end
    end
end


