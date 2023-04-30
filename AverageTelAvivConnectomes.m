% this will align the indexes of the conn files that we're averaging together

REST_MRIS = dir('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/TelAviv/Resting/corrMat/*.csv');
DOMINO_MRI = dir('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/TelAviv/Domino/corrMat/*.csv');
HARIRI_MRI = dir('/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/TelAviv/Hariri/corrMat/*.csv');

COMB = struct;

for i = 1:length(REST_MRI)
    COMB(i).rest = REST_MRI(i).name;
end

for i = 1:length(DOMINO_MRI)
    COMB(i).domino = DOMINO_MRI(i).name;
end

for i = 1:length(HARIRI_MRI)
    COMB(i).hariri = HARIRI_MRI(i).name;
end

disp('Go into COMB and align everything manually');
pause()

restpath = '/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/TelAviv/Resting/corrMat/';
dominopath = '/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/TelAviv/Domino/corrMat/';
hariripath = '/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/TelAviv/Hariri/corrMat/';

% count number of instances of each possible combo
ix_rdh = 0;
ix_rd = 0;
ix_rh = 0;
ix_dh = 0;
ix_r = 0;
ix_d = 0;
ix_h = 0;

for i = 1:length(COMB)

    if ~isempty(COMB(1,i).rest) && ~isempty(COMB(1,i).domino) && ~isempty(COMB(1,i).hariri)

        %load rest
        r = load([restpath COMB(i).rest]);

        if size(r,1) == 269
            r(1,:) = [];
        elseif size(r,2) == 269
            r(:,1) = [];
        end

        %load domino
        d = load([dominopath COMB(i).domino]);

        if size(d,1) == 269
            d(1,:) = [];
        elseif size(d,2) == 269
            d(:,1) = [];
        end

        %load hariri
        h = load([hariripath COMB(i).hariri]);

        if size(h,1) == 269
            h(1,:) = [];
        elseif size(h,2) == 269
            h(:,1) = [];
        end

        avgconn(:,:,i) = (r + d + h)/ 3;
        ix_rdh = ix_rdh+1;
        clear r d h

    elseif ~isempty(COMB(1,i).rest) && ~isempty(COMB(1,i).domino) && isempty(COMB(1,i).hariri)

        %load rest
        r = load([restpath COMB(i).rest]);

        if size(r,1) == 269
            r(1,:) = [];
        elseif size(r,2) == 269
            r(:,1) = [];
        end

        %load domino
        d = load([dominopath COMB(i).domino]);

        if size(d,1) == 269
            d(1,:) = [];
        elseif size(d,2) == 269
            d(:,1) = [];
        end

        avgconn(:,:,i) = (r + d)/ 2;
        ix_rd = ix_rd+1;
        clear r d

    elseif ~isempty(COMB(1,i).rest) && isempty(COMB(1,i).domino) && ~isempty(COMB(1,i).hariri)

        %load rest
        r = load([restpath COMB(i).rest]);

        if size(r,1) == 269
            r(1,:) = [];
        elseif size(r,2) == 269
            r(:,1) = [];
        end

        %load hariri
        h = load([hariripath COMB(i).hariri]);

        if size(h,1) == 269
            h(1,:) = [];
        elseif size(h,2) == 269
            h(:,1) = [];
        end

        avgconn(:,:,i) = (r + h)/ 2;
        ix_rh = ix_rh+1;
        clear r h

    elseif isempty(COMB(1,i).rest) && ~isempty(COMB(1,i).domino) && ~isempty(COMB(1,i).hariri)

        %load domino
        d = load([dominopath COMB(i).domino]);

        if size(d,1) == 269
            d(1,:) = [];
        elseif size(d,2) == 269
            d(:,1) = [];
        end

        %load hariri
        h = load([hariripath COMB(i).hariri]);

        if size(h,1) == 269
            h(1,:) = [];
        elseif size(h,2) == 269
            h(:,1) = [];
        end

        avgconn(:,:,i) = (d + h)/ 2;
        ix_dh = ix_dh+1;
        clear d h

    elseif ~isempty(COMB(1,i).rest) && isempty(COMB(1,i).domino) && isempty(COMB(1,i).hariri)

        %load rest
        r = load([restpath COMB(i).rest]);

        if size(r,1) == 269
            r(1,:) = [];
        elseif size(r,2) == 269
            r(:,1) = [];
        end

        avgconn(:,:,i) = r;
        ix_r = ix_r+1;
        clear r

    elseif isempty(COMB(1,i).rest) && ~isempty(COMB(1,i).domino) && isempty(COMB(1,i).hariri)

        %load domino
        d = load([dominopath COMB(i).domino]);

        if size(d,1) == 269
            d(1,:) = [];
        elseif size(d,2) == 269
            d(:,1) = [];
        end

        avgconn(:,:,i) = d;
        ix_d = ix_d+1;
        clear d

    elseif isempty(COMB(1,i).rest) && isempty(COMB(1,i).domino) && ~isempty(COMB(1,i).hariri)

        %load hariri
        h = load([hariripath COMB(i).hariri]);

        if size(h,1) == 269
            h(1,:) = [];
        elseif size(h,2) == 269
            h(:,1) = [];
        end

        avgconn(:,:,i) = h;
        ix_h = ix_h+1;
        clear h
    end

end


% load PCL data
% Make PCL vector 163 items long, with NaNs for any missing subjects
% Save PCL T1, T2, and T3 in this format
% Run CPM! 
         