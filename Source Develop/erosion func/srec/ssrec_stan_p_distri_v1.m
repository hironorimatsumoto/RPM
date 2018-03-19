%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    srec_stan_p_distri_v1.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ssrec_p_stan, ssrec_p_stan_sub, ssrec_stan_dist1, ssrec_stan_dist2] =  ssrec_stan_p_distri_v1(range, HF, UD)
    
	clear ssrec_p_stan ssrec_p_stan_sub ssrec_stan_dist1 ssrec_stan_dist2
	range=ceil(range);
    ssrec_p_stan = zeros(size(range,2),max(range)+1);
    
    if (HF)
        ssrec_stan_dist1 = ceil(range/2);    
		ssrec_stan_dist2 = floor(range/2);
    else
        if (UD==1)
            ssrec_stan_dist1 = ceil(range/2);    
    		ssrec_stan_dist2 = [0 0 0];
        else
            ssrec_stan_dist1 = [0 0 0];    
    		ssrec_stan_dist2 = floor(range/2);
        end
    end
    
	for i=1:size(range,2)
    
		% calculate total
		q_stan=1/(ssrec_stan_dist1(i)+ssrec_stan_dist2(i));
	
		% put the value into array
		for k=1:(ssrec_stan_dist1(i)+ssrec_stan_dist2(i)) 	
			ssrec_p_stan(i,k)=q_stan;
            %ssrec_p_stan(i,k)=1;
		end
	
		% for submarine erosion
		ssrec_p_stan_sub(i) = q_stan;
        %ssrec_p_stan_sub(i) = 1;
        
    end
	
end