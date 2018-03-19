%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    print_tidal_range1.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_tidal_range1(num_tidal_range, start_tide, end_tide, tr_esf)

current_path=pwd;

%num = end_tide - start_tide + 1;
num = size(num_tidal_range,2);

%%% CALC ADDITIONAL RANGE
add = num_tidal_range*1.2;

figure;
for i=1:num
    %tr = num_tidal_range(i);
    tr = add(i);
    
    if(tr<=1)       x=0;
    elseif(tr==2)   x=[0 1];
    else            x=[-(ceil(tr/2)-1):floor(tr/2)];
    end
    print_esf = tr_esf(:,i);
    
    if( tr < max(add) ) 
        print_esf(tr+1:max(add)) = [];
    end
    
    %if( tr < max(num_tidal_range) ) 
    %    print_esf(tr+1:max(num_tidal_range)) = [];
    %end
        
    if(tr==2) x, print_esf
    end

    plot(x,print_esf,'color', [i*0, i*0.1, i*0.2],'Linewidth',2); 
    hold on; 
    xlim([-(max(num_tidal_range)/2), max(num_tidal_range)/2]);
    %axis([-(max(num_tidal_range)/2) max(num_tidal_range)/2 0 0.2]);
end

%xlabel('x [cm]');
%ylabel('y [a.u.]');

filename=[current_path, '\tidal_range.jpg'];
saveas(gcf, filename); clf;
close;