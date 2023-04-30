% Last done for harmonizing AURORA -- converted AURORA from PCL5 to PCL4
% You need to load in the PCL4 and PCL5 conversion keys first! They're
% located in the project root folder :)


PATH = '/Users/ajsimon/Documents/Data/MINDS_lab/PTSD/AURORA/CPM_data/';

files = {'T1_PCL.mat','T2_PCL.mat','T3_PCL.mat'};


for i = 1:length(files)

    load([PATH files{i}]);

    oldy = y;
    clear y

    for r = 1:size(oldy,1)

        if isnan(oldy(r,1))
            y(r,1) = NaN;
        else
            loc = find(oldy(r,1) == PCL5);

            if ~isempty(loc)
                
                %check if there were 2 of the same vals for PCL5 -> PCL4
                if size(loc,1) > 1
                    y(r,1) = (PCL4(loc(1,1),1) + PCL4(loc(2,1),1)) / 2;
                else
                    y(r,1) = PCL4(loc,1);
                end
            else
                loc1 = find(oldy(r,1)-1 == PCL5);
                loc2 = find(oldy(r,1)+1 == PCL5);
                y(r,1) = (PCL4(loc1,1) + PCL4(loc2,1))/2;
            end
        end
    end

    outfile = sprintf('%s%s5_converted_PCL4_V2.mat',PATH,files{i}(1:6));
    save(outfile,'y');
    clear y loc1 loc2 loc
end