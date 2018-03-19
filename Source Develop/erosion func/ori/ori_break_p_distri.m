%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    ori_break_p_distri.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [exp_p_brea, exp_p_brea_sub, exp_brea_dist1, exp_brea_dist2] = ori_break_p_distri(range, shift, FH, UD)

    clear exp_p_brea exp_p_brea_sub exp_brea_dist1 exp_brea_dist2
    
    range = ceil(range);
    exp_p_brea = zeros(3,range(3));
    
    if (FH)
        exp_brea_dist1 = ceil((range/2)*(1+shift));
        exp_brea_dist2 = floor((range/2)*(1-shift));
    else
        if (UD==1)
            exp_brea_dist1 = ceil((range/2)*(1+shift));
            exp_brea_dist2 =  -(exp_brea_dist1 - ceil(range/2));
        else
            exp_brea_dist2 = floor((range/2)*(1-shift));
            exp_brea_dist1 = -ssrec_brea_dist2 + floor(range/2);
        end
    end
    
    for h=1:3
        total = 0;
        if ( mod(range(h),2)==0 )
            i = range(h)/2+1;
            j = range(h)/2;
            for k=range(h)/2:-1:2
                i=i-1;
                j=j+1;
                exp_p_brea(h,i) = exp(-abs(range(h)/2-k)/(0.1*(range(h)/2)));
                exp_p_brea(h,j) = exp(-abs(range(h)/2-k)/(0.1*(range(h)/2)));
            end
            j=j+1;
            exp_p_brea(h,1) = 0;
            exp_p_brea(h,j) = 0;
            
            if (FH)       
                total = sum(exp_p_brea,2);
                exp_p_brea(h,:) = exp_p_brea(h,:) / total(h);
                if(floor((1-shift)*(range(h)/2))==0)    exp_p_brea_sub(h) = exp_p_brea(h,1);
                else                                    exp_p_brea_sub(h) = exp_p_brea(h,floor((1-shift)*(range(h)/2)));
                end
            else
                if (UD==1) 
                    exp_p_brea(h,range(h)/2+1:range(h)) = 0;
                    total = sum(exp_p_brea,2);
                    exp_p_brea(h,:) = exp_p_brea(h,:) / total(h);
                    exp_p_brea_sub(h) = exp_p_brea(h,floor((1-shift)*(range(h)/2)));
                else
                    exp_p_brea(h,1:range(h)/2) = exp_p_brea(h,range(h)/2+1:range(h));
                    exp_p_brea(h,range(h)/2+1:range(h)) = 0;
                    total = sum(exp_p_brea,2);
                    exp_p_brea(h,:) = exp_p_brea(h,:) / total(h);
                    exp_p_brea_sub(h) = exp_p_brea(h,floor((1-shift)*(range(h)/2)));
                end
            end
            
        elseif ( mod(range(h),2)==1 )
            i = ceil(range(h)/2);
            j = i;
            exp_p_brea(h,i)=1;
            for k=floor(range(h)/2):-1:2
                i=i-1;
                j=j+1;
                exp_p_brea(h,i) = exp(-abs(ceil(range(h)/2)-k)/(0.1*floor(range(h)/2)));
                exp_p_brea(h,j) = exp(-abs(ceil(range(h)/2)-k)/(0.1*floor(range(h)/2)));
            end
            j=j+1;
            exp_p_brea(h,1) = 0;
            exp_p_brea(h,j) = 0;
            
            if(FH)
                total = sum(exp_p_brea,2);
                exp_p_brea(h,:) = exp_p_brea(h,:) / total(h);
                exp_p_brea_sub(h) = exp_p_brea(h,ceil((1-shift)*(range(h)/2)));
            else
                if(UD==1)
                    exp_p_brea(h,ceil(range(h)/2)+1:ceil(range(h)/2)+floor(range(h)/2)) = 0;
                    total = sum(exp_p_brea,2);
                    exp_p_brea(h,:) = exp_p_brea(h,:) / total(h);
                    exp_p_brea_sub(h) = exp_p_brea(h,floor((1-shift)*(range(h)/2)));
                else
                    exp_p_brea(h,1:ceil(range(h)/2)) = exp_p_brea(h,ceil(range(h)/2):ceil(range(h)/2)+floor(range(h)/2));
                    exp_p_brea(h,ceil(range(h)/2)+1:ceil(range(h)/2)+floor(range(h)/2)) = 0;
                    total = sum(exp_p_brea,2);
                    exp_p_brea(h,:) = exp_p_brea(h,:) / total(h);
                    exp_p_brea_sub(h) = exp_p_brea(h,floor((1-shift)*(range(h)/2)));
                end
            end
        end
        
    end
    
	
end