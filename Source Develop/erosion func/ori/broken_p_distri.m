%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    broken_p_distri.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [p_brok, p_brok_sub, brok_dist1, brok_dist2] = broken_p_distri(height, bd, brok_type)
           
    clear p_brok p_brok_sub brok_dist1 brok_dist2	

	for h=1:3
           
        %%%
        % P for Broken wave after Hom-ma and Horikawa (1964)
        %%%
        if (brok_type==1)
            brok_dist1(h)  	=   round(1.2*bd(h)/2);
            brok_dist2(h)	=	round(bd(h)/2);
            q_brok      	=   0;
            
            for k=bro1_dist1(h):-1:0       q_brok=q_brok+(bro1_dist1(h)-k)/bro1_dist1(h);  end
            for k=-1:-1:(-bro1_dist2(h))   q_brok=q_brok+(bro1_dist2(h)+k)/bro1_dist2(h);  end
    
            i=0;    
            for k=brok_dist1(h):-1:0
                i=i+1;  
                p_brok(h,i) = (bro1_dist1(h)-k)/bro1_dist1(h)/q_brok;
                if(k==0)    p_brok_sub(h) = (bro1_dist1(h)-k)/bro1_dist1(h)/q_brok; end
            end
    
            for k=-1:-1:-brok_dist2(h)
                i=i+1;  
                p_brok(h,i) = (brok_dist2(h)+k)/brok_dist2(h)/q_brok;
            end
            
        %%%
		% P for Broken wave after CERC (1964)
		%%%
		elseif (brok_type==2)
    
        	brok_dist1(h)  	=   round(0.78*height(h));	
            brok_dist2(h)	= 	0;
		
            i=0;
            for k=brok_dist1(h):-1:0  
                i=i+1;  
                p_brok(h,i)=1/(brok_dist1(h)+1);
            end
            p_brok_sub(h)=1/(brok_dist1(h)+1);
        end
    end
end