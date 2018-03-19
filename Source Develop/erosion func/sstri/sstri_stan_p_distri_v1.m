%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    sttri_stan_p_distri_v1.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sstri_p_stan, sstri_p_stan_sub, sstri_stan_dist1, sstri_stan_dist2] =  sstri_stan_p_distri_v1(range, FH, UD)
   
    clear sstri_p_stan sstri_p_stan_sub sstri_stan_dist1 sstri_stan_dist2
    range=ceil(range);
    sstri_p_stan = zeros(size(range,2),max(range)+1);
    
    if(FH)
        sstri_stan_dist1 = ceil(range/2);    
		sstri_stan_dist2 = floor(range/2);
    else
        if (UD==1)
            sstri_stan_dist1 = ceil(range/2);    
    		sstri_stan_dist2 = [0 0 0];
        else
            sstri_stan_dist1 = [0 0 0];    
        	sstri_stan_dist2 = floor(range/2);
        end
    end
 
	for h=1:length(range)
     
        total = 0;
        
		if (sstri_stan_dist1(h)==sstri_stan_dist2(h))
            i=1;
            j=sstri_stan_dist1(h)+sstri_stan_dist2(h);
            for k=sstri_stan_dist1(h)-1:-1:1
                i=i+1;
                sstri_p_stan(h,i) = ((sstri_stan_dist1(h)-1)-(k-1))/(sstri_stan_dist1(h)-1);
                total = total + sstri_p_stan(h,i);
                j=j-1;
                sstri_p_stan(h,j) = sstri_p_stan(h,i);
                total = total + sstri_p_stan(h,j);
                if (k==1) sstri_p_stan_sub(h) = 1; end
            end
            for k=1:sstri_stan_dist1(h)+sstri_stan_dist2(h)
                sstri_p_stan(h,k) = sstri_p_stan(h,k)/total;
            end
                
        elseif (sstri_stan_dist1(h)~=sstri_stan_dist2(h))
            i=1;
            j=sstri_stan_dist1(h)+sstri_stan_dist2(h);
            for k=sstri_stan_dist1(h)-1:-1:2
                i=i+1;
                sstri_p_stan(h,i) = ((sstri_stan_dist1(h)-1)-(k-1))/(sstri_stan_dist1(h)-1);
                total = total + sstri_p_stan(h,i);
                j=j-1;
                sstri_p_stan(h,j) = sstri_p_stan(h,i);
                total = total + sstri_p_stan(h,j);
            end
            i=i+1;
            sstri_p_stan(h,i) = ((sstri_stan_dist1(h)-1))/(sstri_stan_dist1(h)-1);
            total = total + sstri_p_stan(h,i);
            sstri_p_stan_sub(h) = 1;
            for k=1:sstri_stan_dist1(h)+sstri_stan_dist2(h)
                sstri_p_stan(h,k) = sstri_p_stan(h,k)/total;
            end
   
        end      
	
    end
            
end