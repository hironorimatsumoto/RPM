%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    srec_break_p_distri.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [srec_p_brea0,srec_p_brea3,srec_p_brea7,srec_p_brea0_sub,srec_p_brea3_sub,srec_p_brea7_sub,srec_brea0_dist1,srec_brea0_dist2,srec_brea3_dist1,srec_brea3_dist2,srec_brea7_dist1,srec_brea7_dist2] =  srec_break_p_distri(height)

    %%%
    % P for BREAKING wave by gaussian 
    %%%
    %clear p_brea0 p_brea3 p_brea7 p_brea0_sub p_brea3_sub p_brea7_sub
    
	% chift parameter
	g_shift = [0.0 0.3 0.7];
    
	for i=1:3
		% upper and lower limit
		srec_brea0_dist1(i) = height(i);
		srec_brea0_dist2(i) = height(i);
		srec_brea3_dist1(i) = ceil(height(i)*1.3);
		srec_brea3_dist2(i) = floor(height(i)*0.7);
		srec_brea7_dist1(i) = ceil(height(i)*1.7);
		srec_brea7_dist2(i) = floor(height(i)*0.3);
	
		if((srec_brea3_dist1(i)+srec_brea3_dist2(i)) ~= (height(i)*2) | (srec_brea7_dist1(i)+srec_brea7_dist2(i)) ~= (height(i)*2)) 
			str='ERROR at sec_break_p_distri';
			display(str);
			pause;
		end
		
		% calculate total
		q_break = 1/(2*height(i)+1);
	
		% put the value into arrays
		for k=1:(2*height(i)+1)
			srec_p_brea0(i,k) = q_break;
			srec_p_brea3(i,k) = q_break;
			srec_p_brea7(i,k) = q_break;
		end
        
		srec_p_brea0_sub(i)	= q_break;
		srec_p_brea3_sub(i)	= q_break;
		srec_p_brea7_sub(i)	= q_break;
    
end