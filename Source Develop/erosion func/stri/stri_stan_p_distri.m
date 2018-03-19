%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    sttri_stan_p_distri.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stri_p_stan, stri_p_stan_sub, stri_stan_dist1, stri_stan_dist2] =  stri_stan_p_distri(height)
   
    % P for SATNDING wave
    %clear p_stan p_stan_sub stan_dist1 stan_dist2
    
	for j=1:3
		% upper & lower limit
		stri_stan_dist1(j)  =   round(height(j)/2);    
		stri_stan_dist2(j)  =   round(height(j)/2);
     
		% calculate total
		q_stan = stri_stan_dist1(j) * stri_stan_dist2(j);
	
		% put the value into array
		i = 0;
		for k=stri_stan_dist1(j):-1:-stri_stan_dist2(j)
			i = i + 1;
			stri_p_stan(j,i) = ( stri_stan_dist1(j) - abs(k) )/q_stan;
		end
	
		% for submarine erosion
		stri_p_stan_sub(j) = stri_stan_dist1(j);
    end    
end