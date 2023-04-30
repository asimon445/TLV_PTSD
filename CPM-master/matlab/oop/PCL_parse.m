ix=0;

for i = 1:length(PIDNs)

    ma = 0;
    it = 1;
    while ma == 0
        try
            it=it+1;
            if PIDNs(i,1) == str2num(rawcsvdata{it,1})
                
                ix = ix+1;

                if ~isempty(str2num(rawcsvdata{it,3}))
                    T1(ix,1) = str2num(rawcsvdata{it,3});
                else
                    T1(ix,1) = NaN;
                end

                if ~isempty(str2num(rawcsvdata{it,6}))
                    T2(ix,1) = str2num(rawcsvdata{it,6});
                else
                    T2(ix,1) = NaN;
                end

                if ~isempty(str2num(rawcsvdata{it,7}))
                    T3(ix,1) = str2num(rawcsvdata{it,7});
                else
                    T3(ix,1) = NaN;
                end

                ma = 1;
            end

        catch
            ix = ix+1;
            T1(ix,1) = NaN;
            T2(ix,1) = NaN;
            T3(ix,1) = NaN;
            ma = 1;
        end
    end

end