%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    sttri_brok_p_distri.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sstri_p_bro, sstri_p_bro_sub, sstri_bro_dist1, sstri_bro_dist2] = sstri_brok_p_distri(range,FH,UD)
    
    clear sstri_p_bro sstri_p_bro_sub sstri_bro_dist1 sstri_bro_dist2
    range=ceil(range);
    sstri_p_bro = zeros(3,range(3)+1);
    
    if(FH)
        sstri_bro_dist1 = ceil(range/2);
		sstri_bro_dist2 = floor(range/2);
    else
        if (UD==1)
            sstri_bro_dist1 = ceil(range/2);
    		sstri_bro_dist2 = [0 0 0];
        else
            sstri_bro_dist1 = [0 0 0];
    		sstri_bro_dist2 = floor(range/2);
        end
    end

    
    for h=1:length(range)
        
        total = 0;
        
        if ( mod(range(h),2)==0 )
            i = range(h)/2+1;
            j = range(h)/2;
            for k=range(h)/2:-1:1
                i=i-1;
                j=j+1;
                sstri_p_bro(h,i) = (k-1)/(range(h)/2-1);
                sstri_p_bro(h,j) = sstri_p_bro(h,i);
            end
            
            if(FH)           
                total = sum(sstri_p_bro,2);
                sstri_p_bro(h,:) = sstri_p_bro(h,:)/total(h);
                sstri_p_bro_sub(h) = sstri_p_bro(h,range(h)/2);
            else
                if(UD==1)
                    sstri_p_bro(h,range(h)/2+1:range(h)) = 0;
                    total = sum(sstri_p_bro,2);
                    sstri_p_bro(h,:) = sstri_p_bro(h,:) / total(h);
                    sstri_p_bro_sub(h) = sstri_p_bro(h,range(h)/2);
                elseif (UD==2)
                    sstri_p_bro(h,1:range(h)/2) = sstri_p_bro(h,range(h)/2+1:range(h)); 
                    sstri_p_bro(h,range(h)/2+1:range(h)) = 0;
                    total = sum(sstri_p_bro,2);
                    sstri_p_bro(h,:) = sstri_p_bro(h,:) / total(h);
                    sstri_p_bro_sub(h) = sstri_p_bro(h,range(h)/2);
                end
            end     
            
        elseif ( mod(range(h),2)==1 )
            
            i = ceil(range(h)/2);
            j = i;
            sstri_p_bro(h,i)=i/ceil(range(h)/2);
            for k=1:ceil(range(h)/2)-1
                i=i-1;
                j=j+1;
                sstri_p_bro(h,i) = ((ceil(range(h)/2)-1)-k) / (ceil(range(h)/2)-1);
                sstri_p_bro(h,j) = sstri_p_bro(h,i);
            end
            if(FH)
                total = sum(sstri_p_bro,2);
                sstri_p_bro(h,:) = sstri_p_bro(h,:)/total(h);
                sstri_p_bro_sub(h) = sstri_p_bro(h,ceil(range(h)/2));
            else
                if (UD==1)
                    sstri_p_bro(h,ceil(range(h)/2)+1:range(h)) = 0;
                    total = sum(sstri_p_bro,2);
                    sstri_p_bro(h,:) = sstri_p_bro(h,:) / total(h);
                    sstri_p_bro_sub(h) = sstri_p_bro(h,ceil(range(h)/2));
                elseif (UD==2)
                    sstri_p_bro(h,1:ceil(range(h)/2)) = sstri_p_bro(h,ceil(range(h)/2):range(h));
                    sstri_p_bro(h,range(h)/2+1:range(h)) = 0;
                    total = sum(sstri_p_bro,2);
                    sstri_p_bro(h,:) = sstri_p_bro(h,:) / total(h);
                    sstri_p_bro_sub(h) = sstri_p_bro(h,1);
                end
            end
            
        end    
        
    end
       
end