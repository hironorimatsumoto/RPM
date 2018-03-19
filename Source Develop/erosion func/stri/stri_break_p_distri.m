%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    sttri_break_p_distri.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stri_p_brea0,stri_p_brea3,stri_p_brea7,stri_p_brea0_sub,stri_p_brea3_sub,stri_p_brea7_sub,stri_brea0_dist1,stri_brea0_dist2,stri_brea3_dist1,stri_brea3_dist2,stri_brea7_dist1,stri_brea7_dist2] =  stri_break_p_distri(height)

    %%%
    % P for BREAKING wave by gaussian 
    %%%
    %clear p_brea0 p_brea3 p_brea7 p_brea0_sub p_brea3_sub p_brea7_sub
    
	% chift parameter
	g_shift = [0.0 0.3 0.7];
    
	for j=1:3
		% upper and lower limit
		stri_brea0_dist1(j) = height(j);
		stri_brea0_dist2(j) = height(j);
		stri_brea3_dist1(j) = ceil(height(j)*1.3);
		stri_brea3_dist2(j) = floor(height(j)*0.7);
		stri_brea7_dist1(j) = ceil(height(j)*1.7);
		stri_brea7_dist2(j) = floor(height(j)*0.3);
	
		if((stri_brea3_dist1+stri_brea3_dist2) ~= (height(j)*2) | (stri_brea7_dist1(j)+stri_brea7_dist2(j)) ~= (height(j)*2)) 
			str='ERROR at sec_break_p_distri';
			display(str);
			pause;
		end
		
		% calculate total
		q_break = (height(j)*height(j));
	
		% put the value into arrays
		i = 0;
		for k=stri_brea0_dist1(j):-1:-stri_brea0_dist2(j)
			i = i + 1;
			stri_p_brea0(j,i) = (height(j) - abs(k))/q_break;
			stri_p_brea3(j,i) = (height(j) - abs(k))/q_break;
			stri_p_brea7(j,i) = (height(j) - abs(k))/q_break;
			if(k==0) stri_p_brea0_sub(j) =(height(j) - abs(k))/q_break; end
		end	
	
		stri_p_brea3_sub(j) = stri_p_brea0(stri_brea3_dist1(j)+1);
		stri_p_brea7_sub(j) = stri_p_brea0(stri_brea7_dist1(j)+1);
    end
end