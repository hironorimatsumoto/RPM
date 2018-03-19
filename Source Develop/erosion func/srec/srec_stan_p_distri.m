%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    srec_stan_p_distri.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [srec_p_stan, srec_p_stan_sub, srec_stan_dist1, srec_stan_dist2] =  srec_stan_p_distri(height)
   
    % P for SATNDING wave
    %clear p_stan p_stan_sub stan_dist1 stan_dist2
    
	for i=1:3
		% upper & lower limit
		srec_stan_dist1(i)  =   round(height(i)/2);    
		srec_stan_dist2(i)  =   round(height(i)/2);
    
		% calculate total
		q_stan=1/(srec_stan_dist1(i)+srec_stan_dist2(i)+1);
	
		% put the value into array
		for k=1:(srec_stan_dist1(i)+srec_stan_dist2(i)+1) 	
			srec_p_stan(i,k)=q_stan;
		end
	
		% for submarine erosion
		srec_p_stan_sub(i) = q_stan;
    end    
	
end