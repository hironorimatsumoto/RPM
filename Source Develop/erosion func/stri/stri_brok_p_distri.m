%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    sttri_brok_p_distri.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stri_p_bro1, stri_p_bro2, stri_p_bro1_sub, stri_p_bro2_sub, stri_bro1_dist1, stri_bro1_dist2, stri_bro2_dist1, stri_bro2_dist2] = stri_brok_p_distri(height)
           
    %clear p_bro1 p_bro2 p_bro1_sub p_bro2_sub bro1_dist1 bro1_dist2 bro2_dist1 bro2_dist2
	
	for j=1:3
		stri_bro1_dist1(j) = round(0.78*height(j));
		stri_bro1_dist2(j) = round(0.78*height(j));
		stri_bro2_dist1(j) = round(0.78*height(j));
		stri_bro2_dist2(j) = 0;
	
		q_bro1	= stri_bro1_dist1(j) * stri_bro1_dist2(j);
		q_bro2	= stri_bro2_dist1(j) * stri_bro2_dist1(j) / 2;
	
		i = 0;
		for k=stri_bro1_dist1(j):-1:-stri_bro1_dist2(j)
			i = i + 1;
			stri_p_bro1(j,i) = (stri_bro1_dist1(j) - abs(k))/q_bro1;
			if (k==0) 
				stri_p_bro1_sub(j) = (stri_bro1_dist1(j) - abs(k))/q_bro1; 
			end
		end	
		
		i = 0;
		for k=stri_bro2_dist1(j):-1:0
			i = i + 1;
			stri_p_bro2(j,i) = (stri_bro2_dist1(j) - abs(k))/q_bro2;
			if (k==0) 
				stri_p_bro2_sub(j) = (stri_bro2_dist1(j) - abs(k))/q_bro2;
			end
		end
	end
end