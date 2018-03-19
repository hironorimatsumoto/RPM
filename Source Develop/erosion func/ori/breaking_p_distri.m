%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    breaking_p_distri.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ori_p_break, ori_p_break_sub, ori_break_dist1, ori_break_dist2] =  breaking_p_distri(height, shift, FH, UD)

    %%%
    % P for BREAKING wave by gaussian 
    %%%
    
    clear p_break p_break_sub break_dist1 break_dist2
    cof = [2.6 1.3 0.65];
    
    if (FH)
        ori_brea_dist1 = ceil(round(height/2)*(1+shift));
        ori_brea_dist2 = floor(round(height/2)*(1+shift));
    elseif (FH==false)
        if (UD==1)
            ori_brea_dist1 = ceil(round(height/2)*(1+shift));
            ori_brea_dist2 = [0 0 0];
        else
            ori_brea_dist1 = [0 0 0];
            ori_brea_dist2 = floor(round(height/2)*(1+shift));
        end
    end
    
    
	for h=1:3
					
		sigma(h)=height(h)/cof(h);
	   	q_brea_gauss(h) = 0;
	
        for k=(ori_break_dist1(h)-1):-1:(-ori_break_dist2(h)+1)
			q_brea_gauss(h) = q_brea_gauss(h)+exp(-((k-shift*height(h))^2)/(2*sigma(h)))/sqrt(2*pi*sigma(h));
		end
                    
		i=1;
		for k=(ori_break_dist1(h)-1):-1:(-ori_break_dist2(h)+1)
			i = i+1;
			ori_p_break(h,i) = exp(-((k-shift*height(h))^2)/(2*sigma(h)))/sqrt(2*pi*sigma(h))/q_brea_gauss(h);
			if(k==0) ori_p_break_sub(h) =   exp(-((k-shift*height(h))^2)/(2*sigma(h)))/sqrt(2*pi*sigma(h))/q_brea_gauss(h);  end
        end
        
        i = i+1;
		ori_p_break(h,i) = 0;
		
    end

    
end