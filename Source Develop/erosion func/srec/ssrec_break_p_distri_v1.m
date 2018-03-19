%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    srec_break_p_distri_v1.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ssrec_p_brea, ssrec_p_brea_sub, ssrec_brea_dist1, ssrec_brea_dist2] =  ssrec_break_p_distri_v1(range, shift, FH, UD)

    clear ssrec_p_brea ssrec_p_brea_sub ssrec_brea_dist1 ssrec_brea_dist2
    range=ceil(range);
    ssrec_p_brea = zeros(size(range,2),max(range)+1);
    
    if (FH)
        ssrec_brea_dist1 = ceil((range/2)*(1+shift));
        ssrec_brea_dist2 = floor((range/2)*(1-shift));
    elseif (FH==false)
        if (UD==1)
            ssrec_brea_dist1 = ceil((range/2)*(1+shift))
            ssrec_brea_dist2 = -(ssrec_brea_dist1 - ceil(range/2));
        else
            ssrec_brea_dist2 = floor((range/2)*(1-shift));
            ssrec_brea_dist1 = -ssrec_brea_dist2 + floor(range/2);
        end
    end
        
    for h=1:size(range,2)
        
        % calculate total
        q_break = 1 / abs(ssrec_brea_dist1(h)+ssrec_brea_dist2(h));
	
        % put the value into arrays
        for k=1:(ssrec_brea_dist1(h)+ssrec_brea_dist2(h))
            ssrec_p_brea(h,k) = q_break;
            %ssrec_p_brea(i,k) = 1;
        end
        
        ssrec_p_brea_sub(h)= q_break;
        %ssrec_p_brea_sub(i)= 1;
        
    end
end