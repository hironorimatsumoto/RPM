%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    sttri_break_p_distri_v1.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sstri_p_brea, sstri_p_brea_sub, sstri_brea_dist1, sstri_brea_dist2] =  sstri_break_p_distri_v1(range, shift, FH, UD)

    clear sstri_p_brea sstri_p_brea_sub sstri_brea_dist1 sstri_brea_dist2
    range=ceil(range);
    sstri_p_brea = zeros(size(range,2),max(range)+1);
    
    
    if (FH)
        sstri_brea_dist1 = ceil((range/2)*(1+shift));
		sstri_brea_dist2 = floor((range/2)*(1-shift));
    else
        if (UD==1)
            sstri_brea_dist1 = ceil((range/2)*(1+shift));
            sstri_brea_dist2 = -(sstri_brea_dist1 - ceil(range/2));
        else
            sstri_brea_dist2 = floor((range/2)*(1-shift));
            sstri_brea_dist1 = -sstri_brea_dist2 + floor(range/2);
        end
    end
    
	for h=1:length(range)
        
        total=0;
        
        if ( mod(range(h),2)==0 )
            i = range(h)/2+1;
            j = range(h)/2;
            for k=range(h)/2:-1:1
                i=i-1;
                j=j+1;
                sstri_p_brea(h,i) = (k-1)/(range(h)/2-1);
                sstri_p_brea(h,j) = sstri_p_brea(h,i);
            end
            
            if(FH)           
                total = sum(sstri_p_brea,2);
                sstri_p_brea(h,:) = sstri_p_brea(h,:)/total(h);
                if(floor((1-shift)*(range(h)/2))==0)
                    sstri_p_brea_sub(h) = sstri_p_brea(h,ceil((1-shift)*(range(h)/2)));
                else
                    sstri_p_brea_sub(h) = sstri_p_brea(h,floor((1-shift)*(range(h)/2)));
                end
            else
                if(UD==1)
                    sstri_p_brea(h,range(h)/2+1:range(h)) = 0;
                    total = sum(sstri_p_brea,2);
                    sstri_p_brea(h,:) = sstri_p_brea(h,:) / total(h);
                    if(floor((1-shift)*(range(h)/2))==0)
                        sstri_p_brea_sub(h) = sstri_p_brea(h,ceil((1-shift)*(range(h)/2)));
                    else
                        sstri_p_brea_sub(h) = sstri_p_brea(h,floor((1-shift)*(range(h)/2)));
                    end
                elseif (UD==2)
                    sstri_p_brea(h,1:range(h)/2) = sstri_p_brea(h,range(h)/2+1:range(h)); 
                    sstri_p_brea(h,range(h)/2+1:range(h)) = 0;
                    total = sum(sstri_p_brea,2);
                    sstri_p_brea(h,:) = sstri_p_brea(h,:) / total(h);
                    if(floor((1-shift)*(range(h)/2))==0)
                        sstri_p_brea_sub(h) = sstri_p_brea(h,ceil((1-shift)*(range(h)/2)));
                    else
                        sstri_p_brea_sub(h) = sstri_p_brea(h,floor((1-shift)*(range(h)/2)));
                    end
                end
            end     
                    
        elseif ( mod(range(h),2)==1 )
            
            i = ceil(range(h)/2);
            j = i;
            sstri_p_brea(h,i)=i/ceil(range(h)/2);
            for k=1:ceil(range(h)/2)-1
                i=i-1;
                j=j+1;
                sstri_p_brea(h,i) = ((ceil(range(h)/2)-1)-k) / (ceil(range(h)/2)-1);
                sstri_p_brea(h,j) = sstri_p_brea(h,i);
            end
            if(FH)
                total = sum(sstri_p_brea,2);
                sstri_p_brea(h,:) = sstri_p_brea(h,:)/total(h);
                if(floor((1-shift)*(range(h)/2))==0)
                    sstri_p_brea_sub(h) = sstri_p_brea(h,ceil((1-shift)*(range(h)/2)));
                else
                    sstri_p_brea_sub(h) = sstri_p_brea(h,floor((1-shift)*(range(h)/2)));
                end
            else
                if (UD==1)
                    sstri_p_brea(h,ceil(range(h)/2)+1:range(h)) = 0;
                    total = sum(sstri_p_brea,2);
                    sstri_p_brea(h,:) = sstri_p_brea(h,:) / total(h);
                    if(floor((1-shift)*(range(h)/2))==0)
                        sstri_p_brea_sub(h) = sstri_p_brea(h,ceil((1-shift)*(range(h)/2)));
                    else
                        sstri_p_brea_sub(h) = sstri_p_brea(h,floor((1-shift)*(range(h)/2)));
                    end
            elseif (UD==2)
                    sstri_p_brea(h,1:ceil(range(h)/2)) = sstri_p_brea(h,ceil(range(h)/2):range(h));
                    sstri_p_brea(h,ceil(range(h)/2)+1:range(h)) = 0;
                    total = sum(sstri_p_brea,2);
                    sstri_p_brea(h,:) = sstri_p_brea(h,:) / total(h);
                    if(floor((1-shift)*(range(h)/2))==0)
                        sstri_p_brea_sub(h) = sstri_p_brea(h,ceil((1-shift)*(range(h)/2)));
                    else
                        sstri_p_brea_sub(h) = sstri_p_brea(h,floor((1-shift)*(range(h)/2)));
                    end
                end
            end
        end
            
	end
	
end