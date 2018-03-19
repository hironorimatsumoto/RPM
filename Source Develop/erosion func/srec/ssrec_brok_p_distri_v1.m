%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    srec_brok_p_distri_v1.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ssrec_p_bro, ssrec_p_bro_sub, ssrec_bro_dist1, ssrec_bro_dist2] = ssrec_brok_p_distri_v1(range, FH, UD)

    clear ssrec_p_bro ssrec_p_bro_sub ssrec_bro_dist1 ssrec_bro_dist2
    range=ceil(range);
    ssrec_p_bro = zeros(size(range,2),max(range)+1);
    
    if (FH)
        ssrec_bro_dist1 = ceil(range/2);
        ssrec_bro_dist2 = floor(range/2);
    else
        if(UD==1)
            ssrec_bro_dist1 = ceil(range/2);
            ssrec_bro_dist2 = [0 0 0];
        else
            ssrec_bro_dist1 = [0 0 0];
            ssrec_bro_dist2 = floor(range/2);
        end
    end

    for i=1:size(range,2)
		
        q_bro	= 1/(ssrec_bro_dist1(i)+ssrec_bro_dist2(i));
	
		for k=1:(ssrec_bro_dist1(i)+ssrec_bro_dist2(i))
			ssrec_p_bro(i,k) = q_bro;
            %ssrec_p_bro(i,k) = 1;
        end
        
		ssrec_p_bro_sub(i) = q_bro;
        %ssrec_p_bro_sub(i) = 1;
    
    end
    
end