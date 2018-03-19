%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    standing_p_distri.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ori_p_stan,ori_p_stan_sub,ori_stan_dist1,ori_stan_dist2] =  stangind_p_distri(height,bd,length)
   
    % P for SATNDING wave
    %clear p_stan
	
	for h=1:3
		st_length(h)   	=   length(h)/10;
   
		% upper & lower limit
		ori_stan_dist1(h)	=   round(height(h)/2);
		
		% Durham
		ori_stan_dist2(h)  	=   round(bd(h));
		
		% stan_dist2  =   round(bd*2);
    
		% p at peak, stan_dist1 above SWL, stan_dist2 below SWL
		h_zero(h)      	=   height(h)/2/cosh(2*pi*ori_stan_dist2(h)/st_length(h));
		
		p2(h)          	=   (height(h)/2)/cosh(2*pi*ori_stan_dist2(h)/st_length(h));
		p1(h)         	=   (p2(h)+ori_stan_dist2(h))*((height(h)/2+h_zero(h))/(height(h)/2+h_zero(h)+ori_stan_dist2(h)));
		p2(h)          	=   p2(h)/p1(h);
		pb(h)          	=   1/cosh(2*pi*ori_stan_dist2(h)/st_length(h));
    
		% calculate total
		q_stan=0;
		for k=ori_stan_dist1(h):-1:0       q_stan=q_stan+(ori_stan_dist1(h)-k)/(ori_stan_dist1(h));  end
		for k=-1:-1:(-ori_stan_dist2(h))   q_stan=q_stan-((1-p2(h))/ori_stan_dist2(h))*k+1;      end
    
		% calculate element
		i=0;
		for k=ori_stan_dist1(h):-1:0  
			i=h+1;  
			ori_p_stan(h,i) =  ((ori_stan_dist1(h)-k)/(ori_stan_dist1(h)))/q_stan;
			if(k==0) ori_p_stan_sub(h)  =  1/q_stan;	end
		end
		for k=-1:-1:-ori_stan_dist2(h) 
			i = i+1; % no need to reset   
			ori_p_stan(h,i) = (((1-pb(h))/ori_stan_dist2(h))*k+1)/q_stan;
		end
        
    end
	
end