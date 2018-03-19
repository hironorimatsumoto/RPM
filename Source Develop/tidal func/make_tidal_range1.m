%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    make_tidal_range1.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tr_esf]=make_tidal_range1(num_tidal_range, start_tide, end_tide, gridsize)

	%%% INITIAL SETTING
    total   = 0;
    
    %num     = end_tide - start_tide + 1;
    num =  size(num_tidal_range,2);
    %tr_max  = max(num_tidal_range);
    tr_max  = max(num_tidal_range*1.2);
    tr_esf  = zeros(tr_max,num);
    
    if ( gridsize == 0.1 )
        bottom = 1;
    %elseif ( gridsize < 0.1 )
    else
        bottom  = gridsize / 0.1;
    end
    
    %%% ERROR DISPLAY
    for i=1:num
        if ( ceil(num_tidal_range(i))==floor(num_tidal_range(i)) )
        else ('tide/gridsize range must be integer number')
            num_tidal_range(i)
            stop
        end
    end
    
    %%% CALC ADDITIONAL RANGE
    add = num_tidal_range*1.2;
    
    
    %%%
    %%% MAKE
    %%%
    for j=1:num
        total=0;
        %tr = num_tidal_range(j);
        tr = add(j);
        if(tr <= 2)
            for i=1:tr
                tr_esf(i,j) = 1;
                total = total + tr_esf(i,j)*bottom;
            end
            tr_esf(:,j) = tr_esf(:,j)/total;
        elseif ( ceil(tr)==3 )
            tr_esf(1,j) = 0;    tr_esf(2,j) = 1/bottom;    tr_esf(3,j) = 0;
        elseif ( ceil(tr)==4 )
            tr_esf(1,j) = 0;
            tr_esf(2,j) = 1;    total=total+tr_esf(2,j)*bottom;
            tr_esf(3,j) = 1;    total=total+tr_esf(3,j)*bottom;
            tr_esf(4,j) = 0;
            tr_esf(:,j) = tr_esf(:,j)/total;
        elseif ( tr > 4 & tr < 20)
            if(ceil(0.5*tr)~=floor(0.5*tr))
                for i=1:ceil(0.5*tr)+1      
                    tr_esf(i,j) = sin((i-1)*pi/ceil(tr*0.5));
                    total = total + tr_esf(i,j)*bottom;
                end
                for i=floor(0.5*tr):tr     
                    tr_esf(i,j) = tr_esf(i,j) + ... 
                            sin((i-floor(tr*0.5))*pi/ceil(tr*0.5));
                    total = total + tr_esf(i,j)*bottom;
                end
            else
                for i=1:0.5*tr+1      
                    tr_esf(i,j) = sin((i-1)*pi/(0.5*tr));
                    total = total + tr_esf(i,j)*bottom;
                end
                for i=0.5*tr:tr
                    tr_esf(i,j) = tr_esf(i,j) + ... 
                            sin((i-tr*0.5)*pi/(tr*0.5));
                    total = total + tr_esf(i,j)*bottom;
                end
            end
            tr_esf(:,j) = tr_esf(:,j)/total;
            
        elseif ( tr >= 20)
            for i=1:ceil(0.55*tr)+1     
                tr_esf(i,j) = sin((i-1)*pi/ceil(tr*0.55));
                total = total + tr_esf(i,j)*bottom;
            end
            for i=floor(0.45*tr):tr     
                tr_esf(i,j) = tr_esf(i,j) + ... 
                            sin((i-(tr-floor(tr*0.55)))*pi/ceil(tr*0.55));
                total = total + tr_esf(i,j)*bottom;
            end
            tr_esf(:,j) = tr_esf(:,j)/total;
            
        end
            
        %elseif(tr <= 20)
        %    for i=1:ceil(0.55*tr)+1     tr_esf(i,j) = sin((i-1)*pi/ceil(tr*0.55));  end
        %    for i=floor(0.45*tr):tr     tr_esf(i,j) = tr_esf(i,j) + ... 
        %                    sin((i-(tr-floor(tr*0.55)))*pi/ceil(tr*0.55));          end
        %    total = sum(tr_esf(:,j));
        %    for i=1:tr                  tr_esf(i,j) = tr_esf(i,j)/total;            end
        %elseif(tr <= 40 & tr > 20)
        %    for i=1:ceil(0.55*tr)+1     tr_esf(i,j) = sin((i-1)*pi/ceil(tr*0.55));  end
        %    for i=floor(0.45*tr):tr     tr_esf(i,j) = tr_esf(i,j) + ...
        %                    sin((i-(tr-floor(tr*0.55)))*pi/ceil(tr*0.55));          end
        %    total = sum(tr_esf(:,j));
        %    for i=1:tr                  tr_esf(i,j) = tr_esf(i,j)/total;            end
        %elseif(tr >= 80 )
        %    for i=1:ceil(0.55*tr)+1     tr_esf(i,j) = sin((i-1)*pi/ceil(tr*0.55));  end
        %    for i=floor(0.45*tr):tr     tr_esf(i,j) = tr_esf(i,j) + ...
        %                    sin((i-(tr-floor(tr*0.55)))*pi/ceil(tr*0.55));          end
        %    total = sum(tr_esf(:,j));
        %    for i=1:tr                  tr_esf(i,j) = tr_esf(i,j)/total;            end
        %end
    end
end