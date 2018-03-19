%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    make_wet_dry_funcv1.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [wd1, wd2]=make_wet_dry_funcv1(num_tidal_range, start_tide, end_tide, current_path, tidal_values)

	%%% INITIAL SETTING
    %num =  end_tide -  start_tide + 1;
    num = size(num_tidal_range,2);
    max_wd = max(num_tidal_range);
    
    wd1 = zeros(max_wd, num);
    wd2 = zeros(max_wd, num);
    
    %%% ERROR DISPLAY
    for i=1:num
        tr = num_tidal_range(i);
        if( mod(tr,2)==0 )
        else ('tide/gridsize range must be integer even number')
        end
    end
    
    
    for j=1:num
        tide=round(num_tidal_range(j))
        if(tide<=1)
            wd1(1,j)= 1;    wd2(1,j)= 1;
        elseif(tide==2)
            wd1(1,j)= 1/2;  wd1(2,j)= 1/2;
            wd2(1,j)= 1/2;  wd2(2,j)= 1/2;
        elseif(tide==3)
            wd1(1,j)= 0;    wd1(2,j)= 1/2;  wd1(3,j)= 0;
            wd2(1,j)= 0;    wd2(2,j)= 1/2;  wd2(3,j)= 0;
        else
            for i=2:ceil(tide/4)                wd1(i,j)=exp(-((i-ceil(tide/4))^2)/(ceil(tide/2)));            end
            for i=ceil(tide/4)+1:tide-1         wd1(i,j)=exp(-((i-ceil(tide/4))^2)/(tide*ceil(tide/10)));      end
            sum_wd1 = sum(wd1(:,j));
            
            % NORMALIZATION
            %wd1(:,j) = wd1(:,j)/sum_wd1;
            
            
            for i=2:ceil(tide/4)				wd2(i,j)=exp(-((i-ceil(tide/4))^2)/(ceil(tide/2)));            end
            for i=ceil(tide/4)+1:ceil(tide*3/4) wd2(i,j)=1;                                                    end
            for i=ceil(tide*3/4)+1:tide-1		wd2(i,j)=exp(-((i-ceil(tide*3/4))^2)/(ceil(tide/2)));          end
            sum_wd2 = sum(wd2(:,j));

            % NORMALIZATION
            %wd2(:,j) = wd2(:,j)/sum_wd2;
            
        
        end
        
        if(true)
            figure; 
            x=[1:tide];
            print_wd1 = wd1(:,j);
            print_wd2 = wd2(:,j);
            if (tide < max(num_tidal_range))
                print_wd1(tide+1:max(num_tidal_range)) = [];
                print_wd2(tide+1:max(num_tidal_range)) = [];
            end
            plot(x, print_wd1, x, print_wd2, 'linewidth', 2);	
            filename = ['\', num2str(tidal_values(j)), '-wet&dry.jpg'];
            filename = [current_path, filename];
            saveas(gcf, filename);
            close;
        end
    end
    
    stop
    
end