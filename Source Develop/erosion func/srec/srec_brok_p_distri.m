%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    srec_brok_p_distri.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [srec_p_bro1, srec_p_bro2, srec_p_bro1_sub, srec_p_bro2_sub, srec_bro1_dist1, srec_bro1_dist2, srec_bro2_dist1, srec_bro2_dist2] = srec_brok_p_distri(height)
           
    %clear p_bro1 p_bro2 p_bro1_sub p_bro2_sub bro1_dist1 bro1_dist2 bro2_dist1 bro2_dist2
	
	for i=1:3
		srec_bro1_dist1(i) = round(0.78*height(i));
		srec_bro1_dist2(i) = round(0.78*height(i));
		srec_bro2_dist1(i) = round(0.78*height(i));
		srec_bro2_dist2(i) = 0;
	
		q_bro1	= 1/(srec_bro1_dist1(i)+srec_bro1_dist2(i)+1);
		q_bro2	= 1/(srec_bro2_dist1(i)+srec_bro2_dist2(i)+1);
	
		for k=1:(srec_bro1_dist1(i)+srec_bro1_dist2(i)+1)
			srec_p_bro1(i,k) = q_bro1;
		end
		srec_p_bro1_sub(i) = q_bro1;
    
		for k=1:(srec_bro2_dist1(i)+srec_bro2_dist2(i)+1)
			srec_p_bro2(i,k) = q_bro1;
		end
		srec_p_bro2_sub(i) = q_bro1;
	end
    
end