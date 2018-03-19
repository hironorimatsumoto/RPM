%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    rpm_v1.m
%    Copyright (c) 2017 Hironori Matsumoto
%    This software is released under the MIT License.
%    Last update : 18 March 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all
close all


%%%
%%% START OF CALCULATION 
%%%
startT = clock();        



%%%
%%% Process selection
%%%
bw              = true;		% Back-wearing erosion
dw              = true;		% Down-wearing erosion
weathering      = true;		% Weathering
spr_weathering  = false;    % Supla tidal weathering
rsl_flag        = false;     % Sea level change
tec_flag        = false;     % Tectonic event



%%%
%%% READ INPUT VARIABLES
%%% 
maxit = input('Maximum Iteration [year]? ( Recommendation range: 100-6000 ) ');
maxcell = input('Maximum Erosion Distance [m]? ( Recommendation range: 50-200 ) ');
height_values = input('Wave Height [m]? ( Recommendation range: 1-4.5 ) ');
resi_values = input('Material Resistance ? ( Recommendation range: 0.01-10 ) ');
tidal_values = input('Mean Tidal Rnage [m]? ( Recommendation range: 1-8 ) ');
wav_erodi = input('Wave erodibility? ( Recommendation range: 0.01-1 ) ');
wea_const = input('Weathering efficacy [mm/year]? ( Recommendation range: 0.1-100 ) ');
i_angle = input('Initial Profile Angle [degrees]? ( Recommendation range: 20-90 ) ');
p_mov = input('Make movie? Yes = 1, No = 0. '); 



%%%
%%% FLAG FOR OUTPUTTING
%%%
final_prof_to_txt = false;  % >> WRITE FINAL MODELLED PROFILE INTO A TEXT FILE
print_wvsw_to_fig = true;  % >> PLOT WAVE EROSION AND WEATHERING CONTRIBUTION FIGURE
print_wvsw_to_txt = true;  % >> WRITE WAVE EROSION AND WEATHERING CONTRIBUTION INTO A TEXT FILE
print_break_point = false;  % >> PLOT BREAKING POINT FIGURE
print_prof_to_txt = true;   % >> WRITE TEMPORAL CHNAGES OF MODELLED PROFILE INTO A TEXT FILE
print_waty_to_txt = false;  % >> WRITE TEMPORAL CHNAGES OF MODELLED WAVE-TYPE INTO A TEXT FILE
print_pcom_to_fig = true;   % >> PLOT FINAL MODELLED PROFILE FIGURE 
if(p_mov==1)                % >> MAKE MOVIE
    print_snap_to_mov = true;  
else
    print_snap_to_mov = false;
end



%%%
%%% GRID LOOP USED TO TEST GRID SIZE SENSITIVITY
%%%
gridsize_values = [0.1]; % >> 0.1 m / cell



%%% FOR TESTING GRIDSIZE SENSITIVITY IN GEOMORPH PAPER (Matsumoto et al., 2016)
for gridloop = 1:length(gridsize_values)
        
    %clearvars -except gridloop gridsize_values sec
    clf
    gridsize = gridsize_values(gridloop);   % >> SET GRIDSIZE


    %%% 
    %%% SET CONTROLLING VARIABLES : 
    %%%
    x_maxcell	= ceil(maxcell/gridsize);               % HORIZONTAL MAXCELL 
    y_maxcell	= ceil(maxcell/2/gridsize);            % VERTICAL MAXCELL
    
    num_resi_values = resi_values*gridsize;             % CONVERT TO NUMMERICAL RESISTANCE VALUE
    num_height      = round(height_values / gridsize);  % CONVERT TO NUMMERICAL WAVE HEIGHT VALUE
    num_tidal_range = round(tidal_values / gridsize);   % CONVERT TO NUMMERICAL MEAN TIDAL RANGE VALUE

    for gg=1:size(tidal_values,2)   % IN CASE OF FINER GRIDSIZE ...
        if (num_tidal_range(gg)<1)  num_tidal_range(gg)=1;  end 
    end 
    start_tide  = 1;                            % STARTING INDEX IF TIDAL RANGE LOOP
    end_tide    = length(tidal_values);         % ENDING INDEX OF TIDAL RANGE LOOP

    
    %%% 
    %%% NON-CONTROLLING VARIABLES : 
    %%% see Matsumoto et al. 2016 for details
    %%%
    sub_decay_const = 1e-1;         % SUBMARINE DECAY CONST
    stan_const  = 0.01;             % CONSTANT FOR UNBROKEN WAVE   
    brea_const  = 10;               % CONSTANT FOR BREAKING WAVE
    brok_const  = 1;                % CONSTANT FOR BROKEN WAVE
    brea_const_tmp = brea_const;    % COPY BREAKING WAVE CONSTANT
    %swd1        = 1e-1;             % WAVE HEIGHT DECAY FOR BREAKING WAVE
    %swd2        = 1e-2;             % WAVE HEIGHT DECAY FOR BROKEN WAVE

    %%% FLAG FOR MAX EROSION        % WHETHER WAVE ERODE MORE THAN ONE ROCK CELL
    change    = 2;

    %%% variables for multiple erosion
    max_we_erosion = 1*0.1/gridsize_values(gridloop);     % Flag for weathering multiple erosion
    max_we_erosion = 2;                                   % TEMPORARY  



    %%%  
    %%% Other : 
    %%%
    %%% STR
    profile =   'p';	
    connect =   '-';
        

    
    %%% CURRENT_PATH(=pwd) DEFINITION
    current_path = pwd;
    current_path = [current_path,'\'];
    addpath(genpath(current_path)); % ADD SEARCH PATH


    %%%
    %%% CREATE INITIAL PROFILE 
    %%%
    mat 	= ones(x_maxcell,y_maxcell);
    if( i_angle~= 90 )
        for y=1:y_maxcell
            x_dist = round(y/tan(i_angle*pi/180));
            for x=1:x_dist mat(x,y)=0; end
        end
    end
    
    
    %%% EROSION FLAG AND RESISTANCE
    field1  = 'flag';                       % STRUCTURE MEMBER FOR EROSION		 
    field2  = 'resistance';                 % STRUCTURE MEMBER FOR MATERIAL
    value1  = ones(x_maxcell,y_maxcell);
    value2  = ones(x_maxcell,y_maxcell);
    s       = struct(field1,value1,field2,value2);
    clear value1 value2
       
    
    %%%
    %%% CREATE EROSION SHAPE FUNCTION
    %%%
    [tr_esf]=make_tidal_range(num_tidal_range,start_tide,end_tide, gridsize);
    
    %%%
    %%% CREATE WETTING & DRYING SPATIAL FUNCTION
    %%% wd1 ... Trenhaile and Kanyaya, 2005
    %%% wd2 ... Stephenson and Kirk, 2000b
    [wd1, wd2] = make_wet_dry_func_v1(num_tidal_range, start_tide, end_tide, current_path, tidal_values, gridsize);


    
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%% %%%%%%%%% %%%%%%%%%%%  %%%%%%%%%%%%%%     %%%%%%%%%% %%%%%%%%% %%%%%
    %%%%% % %%%%% % %%%%%%%%%% %% %%%%%%%%%%%%%%% %%%%%%%%%%%% % %%%%%%% %%%%%
    %%%%% %% %%% %% %%%%%%%%% %%%% %%%%%%%%%%%%%% %%%%%%%%%%%% %% %%%%%% %%%%%
    %%%%% %%% % %%% %%%%%%%% %%%%%% %%%%%%%%%%%%% %%%%%%%%%%%% %%% %%%%% %%%%%
    %%%%% %%%% %%%% %%%%%%%          %%%%%%%%%%%% %%%%%%%%%%%% %%%% %%%% %%%%%
    %%%%% %%%%%%%%% %%%%%% %%%%%%%%%% %%%%%%%%%%% %%%%%%%%%%%% %%%%% %%% %%%%%
    %%%%% %%%%%%%%% %%%%% %%%%%%%%%%%% %%%%%%%%%% %%%%%%%%%%%% %%%%%% %% %%%%%
    %%%%% %%%%%%%%% %%%% %%%%%%%%%%%%%% %%%%%%%     %%%%%%%%%% %%%%%%% % %%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %%%	
    %%% TIDE LOOP
    %%% 
    for tr=start_tide:end_tide

        %%% TIDE RELATED SETTING
        tide        = num_tidal_range(tr);
        mwl         = round(y_maxcell/2);
        reset_mwl   = mwl;
        
        %%% RESTORE EROSION SHAPE FUNCTION
        clear esf
        esf         = tr_esf(:,tr);
        wetdry_a    = wd1(:,tr);    %%% WEATHERING SHAPE FUNCTION BY TRENHAILE AND KANYAYA (2005) 
        wetdry_b    = wd2(:,tr);    %%% WEATHERING SHAPE FUNCTION BY STEPHENSON AND KIRK (2000b)
        
           
		%%% 
		%%% PRESSURE DISTRIBUTION
		%%%
        %%% p_stan ... unbroken wave pressure
		%%% p_breaking ... breaking wave pressure
		%%% p_broken ... broken wave pressure (p_broken=1...Homma & Horikawa, p_broken=2...CERC )
        %%% 
        %%% PRESSURE DISTRIBUTION SENSITIVITY TEST IN GEOMORPH PAPER (Matsumoto et al., 2016)
        %%%
        %%% range...vertidal range of wave pressure
        %%% shift...vertical shift of wave pressure, 0... no shift, 0.5...shift by half the wave height
        %%% fh_brea...vertical range of breaking wave pressure, true...full range of vertical breaking wave pressure, false...half range of vertical breaking wave pressure 
        %%% fh_brok...vertical range of broken wave pressure, true...full range of vertical broken wave pressure, false...half range of vertical broken wave pressure 
        %%% ud_brea.. consideration of upper or lower part of breaking wave pressure when fh_brea is false
        %%% ud_brok.. consideration of upper or lower part of broken wave pressure when fh_brok is false
        
        for pressure=25:25
        
            %%% SET SHAPE OF PRESSURE : 
            clear p_stan p_break p_brok
            clear stan_dist1 stan_dist2 break_dist1 break_dist2 brok_dist1 brok_dist2
            clear p_stan_sub p_break_sub p_brok_sub

            fh_brea = true;
            ud_brea = 1;
            ud_brok = 1;
            
            jump=0;
            
            if ( pressure==1 | pressure==2 | pressure==3 | pressure==4 | pressure==5 | pressure==6 | pressure==7 | pressure==8 ) % RECTANGULAR & RECTANGULAR

                if (pressure == 1)      range = height_values/gridsize;     shift = 0;      fh_brok = true; 
                elseif (pressure == 2)  range = height_values*0.5/gridsize; shift = 0;      fh_brok = true;
                elseif (pressure == 3)  range = height_values/gridsize;     shift = 0.5;    fh_brok = true;
                elseif (pressure == 4)  range = height_values*0.5/gridsize; shift = 0.5;    fh_brok = true;
                elseif (pressure == 5)  range = height_values/gridsize;     shift = 0;      fh_brok = false;  
                elseif (pressure == 6)  range = height_values*0.5/gridsize; shift = 0;      fh_brok = false;
                elseif (pressure == 7)  range = height_values/gridsize;     shift = 0.5;    fh_brok = false;
                elseif (pressure == 8)  range = height_values*0.5/gridsize; shift = 0.5;    fh_brok = false;
                end
               
                [p_stan, p_stan_sub, stan_dist1, stan_dist2]        = ssrec_stan_p_distri(range, true, 1);
                [p_break, p_break_sub, break_dist1, break_dist2]    = ssrec_break_p_distri(range, shift, fh_brea, ud_brea);
                [p_brok, p_brok_sub, brok_dist1, brok_dist2]        = ssrec_brok_p_distri(range, fh_brok, ud_brok);
            

            elseif ( pressure==9 | pressure==10 | pressure==11 | pressure==12 | pressure==13 | pressure==14 | pressure==15 | pressure==16) % RECTANGULAR & TRIANGLE
            
                if (pressure == 9)      range = height_values/gridsize;     shift = 0;      fh_brok = true; 
                elseif (pressure == 10) range = height_values*0.5/gridsize; shift = 0;      fh_brok = true;
                elseif (pressure == 11) range = height_values/gridsize;     shift = 0.5;    fh_brok = true;
                elseif (pressure == 12) range = height_values*0.5/gridsize; shift = 0.5;    fh_brok = true;
                elseif (pressure == 13) range = height_values/gridsize;     shift = 0;      fh_brok = false;  
                elseif (pressure == 14) range = height_values*0.5/gridsize; shift = 0;      fh_brok = false;
                elseif (pressure == 15) range = height_values/gridsize;     shift = 0.5;    fh_brok = false;
                elseif (pressure == 16) range = height_values*0.5/gridsize; shift = 0.5;    fh_brok = false;
                end
                
                [p_stan, p_stan_sub, stan_dist1, stan_dist2]        = ssrec_stan_p_distri(range, true, 1);
                [p_break, p_break_sub, break_dist1, break_dist2]    = ssrec_break_p_distri(range, shift, fh_brea, ud_brea);
                [p_brok, p_brok_sub, brok_dist1, brok_dist2]        = sstri_brok_p_distri(range, fh_brok,ud_brok);

                
            elseif ( pressure==17 | pressure==18 | pressure==19 | pressure==20 | pressure==21 | pressure==22 | pressure==23 | pressure==24 ) % TRIANGLE & RECTANGULAR

                if (pressure == 17)      range = height_values/gridsize;     shift = 0;      fh_brok = true; 
                elseif (pressure == 18)  range = height_values*0.5/gridsize; shift = 0;      fh_brok = true;
                elseif (pressure == 19)  range = height_values/gridsize;     shift = 0.5;    fh_brok = true;
                elseif (pressure == 20)  range = height_values*0.5/gridsize; shift = 0.5;    fh_brok = true;
                elseif (pressure == 21)  range = height_values/gridsize;     shift = 0;      fh_brok = false;  
                elseif (pressure == 22)  range = height_values*0.5/gridsize; shift = 0;      fh_brok = false;
                elseif (pressure == 23)  range = height_values/gridsize;     shift = 0.5;    fh_brok = false;
                elseif (pressure == 24)  range = height_values*0.5/gridsize; shift = 0.5;    fh_brok = false;
                end
                
                [p_stan, p_stan_sub, stan_dist1, stan_dist2]        = ssrec_stan_p_distri(range, true, 1);
                [p_break, p_break_sub, break_dist1, break_dist2]    = sstri_break_p_distri(range, shift, fh_brea, ud_brea);
                [p_brok, p_brok_sub, brok_dist1, brok_dist2]        = ssrec_brok_p_distri(range, fh_brok,ud_brok);
            
            elseif ( pressure==25 | pressure==26 | pressure==27 | pressure==28 | pressure==29 | pressure==30 | pressure==31 | pressure==32) % TRIANGLE & TRIANGLE
            
                if (pressure == 25)     range = height_values/gridsize;    shift = 0;      fh_brok = true; 
                elseif (pressure == 26) range = height_values*0.5/gridsize; shift = 0;      fh_brok = true;
                elseif (pressure == 27) range = height_values/gridsize;     shift = 0.5;    fh_brok = true;
                elseif (pressure == 28) range = height_values*0.5/gridsize; shift = 0.5;    fh_brok = true;
                elseif (pressure == 29) range = height_values/gridsize;     shift = 0;      fh_brok = false;  
                elseif (pressure == 30) range = height_values*0.5/gridsize; shift = 0;      fh_brok = false;
                elseif (pressure == 31) range = height_values/gridsize;     shift = 0.5;    fh_brok = false;
                elseif (pressure == 32) range = height_values*0.5/gridsize; shift = 0.5;    fh_brok = false;
                end
                
                %[p_stan, p_stan_sub, stan_dist1, stan_dist2]        = ssrec_stan_p_distri(range, true, 1);
                %[p_break, p_break_sub, break_dist1, break_dist2]    = sstri_break_p_distri(range, shift, fh_brea, ud_brea);
                %[p_brok, p_brok_sub, brok_dist1, brok_dist2]        = sstri_brok_p_distri(range, fh_brok,ud_brok);

                [p_stan, p_stan_sub, stan_dist1, stan_dist2]        = ssrec_stan_p_distri_v1(range, true, 1);
                [p_break, p_break_sub, break_dist1, break_dist2]    = sstri_break_p_distri_v1(range, shift, fh_brea, ud_brea);
                [p_brok, p_brok_sub, brok_dist1, brok_dist2]        = sstri_brok_p_distri_v1(range, fh_brok,ud_brok);

                
            elseif ( pressure==33 | pressure==34 | pressure==35 | pressure==36 | pressure==37 | pressure==38 | pressure==39 | pressure==40 ) % EXPPONENTIAL & RECTANGULAR

                if (pressure == 33)      range = height_values/gridsize;     shift = 0;      fh_brok = true; 
                elseif (pressure == 34)  range = height_values*0.5/gridsize; shift = 0;      fh_brok = true;
                elseif (pressure == 35)  range = height_values/gridsize;     shift = 0.5;    fh_brok = true;
                elseif (pressure == 36)  range = height_values*0.5/gridsize; shift = 0.5;    fh_brok = true;
                elseif (pressure == 37)  range = height_values/gridsize;     shift = 0;      fh_brok = false;  
                elseif (pressure == 38)  range = height_values*0.5/gridsize; shift = 0;      fh_brok = false;
                elseif (pressure == 39)  range = height_values/gridsize;     shift = 0.5;    fh_brok = false;
                elseif (pressure == 40)  range = height_values*0.5/gridsize; shift = 0.5;    fh_brok = false;
                end
                
                [p_stan, p_stan_sub, stan_dist1, stan_dist2]        = ssrec_stan_p_distri(range, true, 1);
                [p_break, p_break_sub, break_dist1, break_dist2]    = ori_break_p_distri(range, shift, fh_brea, ud_brea);
                [p_brok, p_brok_sub, brok_dist1, brok_dist2]        = ssrec_brok_p_distri(range, fh_brok,ud_brok);
            
            elseif ( pressure==41 | pressure==42 | pressure==43 | pressure==44 | pressure==45 | pressure==46 | pressure==47 | pressure==48) % EXPONENTIAL & TRIANGLE
            
                if (pressure == 41)     range = height_values/gridsize;     shift = 0;      fh_brok = true; 
                elseif (pressure == 42) range = height_values*0.5/gridsize; shift = 0;      fh_brok = true;
                elseif (pressure == 43) range = height_values/gridsize;     shift = 0.5;    fh_brok = true;
                elseif (pressure == 44) range = height_values*0.5/gridsize; shift = 0.5;    fh_brok = true;
                elseif (pressure == 45) range = height_values/gridsize;     shift = 0;      fh_brok = false;  
                elseif (pressure == 46) range = height_values*0.5/gridsize; shift = 0;      fh_brok = false;
                elseif (pressure == 47) range = height_values/gridsize;     shift = 0.5;    fh_brok = false;
                elseif (pressure == 48) range = height_values*0.5/gridsize; shift = 0.5;    fh_brok = false;
                end
                
                [p_stan, p_stan_sub, stan_dist1, stan_dist2]        = ssrec_stan_p_distri(range, true, 1);
                [p_break, p_break_sub, break_dist1, break_dist2]    = ori_break_p_distri(range, shift, fh_brea, ud_brea);
                [p_brok, p_brok_sub, brok_dist1, brok_dist2]        = sstri_brok_p_distri(range, fh_brok,ud_brok); 
            
            elseif ( pressure==49 | pressure==50 ) % NO SPATIAL VARIATION IN WAVE PRESSURE 
                if(pressure==49)    jump = 0;   shift = 0;
                elseif(pressure==50)jump = 0.5; shift = 0;
                end
                range = height_values/gridsize;
                p_stan   = (1./range)';   p_stan_sub = 1./range;  stan_dist1     = [1 1 1] ;     stan_dist2    = [0 0 0];
                p_break  = (1./range)';   p_break_sub= 1./range;  break_dist1    = [1 1 1] ;     break_dist2   = [0 0 0];
                p_brok   = (1./range)';   p_brok_sub = 1./range;  brok_dist1     = [1 1 1] ;     brok_dist2    = [0 0 0];
                
            end
            clear range bd
			
          
            %%%
            %%% Weathering LOOP  
            %%% 

            %%% WEATHERING EFFICACY TYPE >> USE WEA 1 
            %%% after Porter et al.(2010a,b,c)
            for wea=1:1
				if ( wea == 1 ) weathering = true;  wetdry=wetdry_a;                % 
				elseif (wea==2) weathering = true;  wetdry=wetdry_a;    wea_flag=1; % NO WEATHEIRNG BUT ONLY INITIAL LOOP
                elseif (wea==3) weathering = false; wetdry=wetdry_a;                % NO WEATHEIRNG
                end
            
                
                %%%
                %%% WEATHERING EFFICACY CONSTANT
                %%%
                for weasd=1:length(wea_const)
              
                    wt_const = wea_const(weasd);
                    
                
                    %%%
                    %%% WAVE ERODIBILITY
                	%%%
                    for we=1:length(wav_erodi)
                                        
                        swd2 = wav_erodi(we);
                    
                        %%% FOR CREATION OF FOLDER                
                        %dir_path = [current_path, 'profileangle-', num2str(i_angle), '/tide-', num2str(tidal_values(tr)), '/weatheringefficacy-', num2str(wt_const), '/waveerodibility-', num2str(wav_erodi(we))];
                        %dir_path = [current_path, 'IPA-', num2str(i_angle), '/MTR-', num2str(tidal_values(tr))];
                        dir_path = [current_path, '/Result'];
                        mkdir(dir_path);
                        output_path = [dir_path, '/']; 

            
                        %%%
                        %%% WAVE HEIGHT LOOP
                        %%% 
                        for h=1:length(height_values)
            
                            %%% CLEAR WAVE HEIGHT RELATING VARIABLE
                            clear height bd decay_sw1
                        
                            %%% WAVE EROSION FORCE IS NOW PROPORTIONAL TO THE SQUARE OF WAVE HEIGHT 
                            height = [height_values(h)];
                            wave_height = [num2str(height_values(h)), 'm'];     %%% STRING

                            %%% 
                            %break_wave_dist     = num_height(h)/2;                      % HORIZONTAL DISTANCE OF BREAKING WAVE RANGE 
                            bd                  = round(num_height(h)/0.78);            % BREAKING DEPTH : Hb / hb = 0.78
                            %decay_sw1           = -log(swd1)/(break_wave_dist);         % WAVE ATTENUATION CONSTANT1
                   
                            %%% WAVE HEIGHT DECAY FROM BREAKING TO BROKEN WAVE
                            swd1 = 0.1;
                
                            %%% INITIALIZATION OF FINAL PROF FOR RESULT PROTTING
                            final_prof  =   zeros(y_maxcell,size(resi_values,2));
                                
	
                            %%%  
                            %%% MATERIAL RESISTANCE LOOP  
                            %%%
                            for resi=1:length(resi_values)
				
                            
                                s.flag              = mat;
                                s.resistance        = mat*num_resi_values(resi);
                                effec_resi          = num_resi_values(resi);
                                ix_posi=1;
                                while(s.flag(ix_posi,end)==0) ix_posi=ix_posi+1; end
                                ix_max              = ix_posi;
                    
                                %%% STR OF MATERIAL RESISNTACE
                                material_resistance = ['resi',num2str(resi_values(resi))];
                                
                                %%% FILE NAME
                                f_name = ['IPA', num2str(i_angle), '-MTR', num2str(tidal_values(tr)),'-WAE',num2str(wav_erodi(we)),'-WEC',num2str(wt_const),'-FW',num2str(height_values(h)),'-FR',num2str(resi_values(resi))];
   
                            
                                %%%
                                %%% VARIABLES FOR PLOTTING
                                %%% 
                                bw_erosion		    = zeros(y_maxcell,1);       % BACK WEARING EROSION
                                total_bw_erosion	= zeros(y_maxcell,maxit);	% TOTAL BACK-WEARING EROSION
                                dw_erosion		    = zeros(x_maxcell,1);       % DOWN WEARING EROSION
                                total_dw_erosion	= zeros(x_maxcell,maxit);	% TOTAL DOWN WEARING ERSION
                                wea_erosion		    = zeros(y_maxcell,1);       % WEATHERING EROSION
                                total_wea_erosion	= zeros(y_maxcell,maxit);	% TOTAL WEATHERING EROSION

                                tidal_posi		    = zeros(tide,1);            % PROFILE POSITION AT TIDAL RANGE
                                posi                = zeros(y_maxcell,1);       % PROFILE POSITION OF WHOLE VERTICAL RANGE
                                save_profile	    = zeros(maxit,y_maxcell);	% SAVE PROFILE ITERATIVELY
                    
                                count_wave_erosion      = zeros(maxit,1);           % COUNT THE WAVE EROSION FORCE IN EACH ITERATION
                                count_wea_erosion       = zeros(maxit,1);           % COUNT THE WEATHERING IN EACH ITERATION
                                count_wave              = zeros(maxit,1);           % COUNT THE NUMBER OF BLOCKS Y WAVE EROSION
                                count_wave_int          = zeros(maxit,1);           % COUNT THE NUMBER OF INTERTIDAL BLOCKS ERODED BY WAVE
                                count_wea               = zeros(maxit,1);           % COUNT THE NUMBER OF BLOCKS ERODED BY WEATHERING
                                count_vert_wave         = zeros(maxit,y_maxcell);   % STORE WAVE EROSION FORCE IN EACH ITERATION
                                count_vert_wea          = zeros(maxit,y_maxcell);   % STORE THE WEATHERING EROSION IN EACH ITERATION
                            
                            
                                %%% RESET OR CLEAR VARIABLES
                                ox_tidal_posi = 0;                              % OUTER PROFILE X POSITION WITHIN TIDAL RANGE
                                ix_tidal_posi = 0;                              % INNER PROFILE X POSITION WITHIN TIDAL RANGE
                                oy_tidal_posi = mwl-ceil(tide/2);               % OUTER PROFILE Y POSITION WITHIN TIDAL RANGE
                                iy_tidal_posi = mwl+ceil(tide/2)-1;             % INNER PROFILE Y POSITION WITHIN TIDAL RANGE

                                ox_posi = 0;                                    % OUTER PROFILE X POSITION 
                                oy_posi	= 1;                                    % OUTER PROFILE Y POSITION 
                                iy_posi = mwl+ceil(tide/2)-1;                   % INNER PROFILE Y POSITION 
					
            					sw2_decay 		= zeros(tide, maxit);           % DECAY CONSTAT FOR BROKEN WAVE
                    			%surf_width		= zeros(tide, maxit);           % SURF WIDTH
                            	angle_l		= zeros(tide, maxit);               % LOCAL ANGLE
                				angle_g		= zeros(maxit,1);                   % GLOBAL ANGLE
                                angle_g_tidal 	= zeros(maxit,1);               % GLOBAL INTERTIDAL ANGLE
					
                            	break_point_x   = zeros(tide,maxit);            % X BREAK POINT at TIDAL RANGE
                                break_point_y   = zeros(tide,maxit);            % Y BREAK POINT at TIDAL RANGE
                                break_wdist     = zeros(tide,maxit);
                                break_wcont     = zeros(tide,maxit);
                                tidal_x_posi    = zeros(tide,maxit);            % X POSITION AT INTERTIDAL ELEVATION
                                wave_type       = zeros(tide,maxit);            % WAVE TYPE at TIDAL RANGE
                                y_depth         = zeros(x_maxcell,1);
                                local_angle     = zeros(tide,maxit);
			
                    
                                %%%  
                                %%% variables for multiple erosion
                                %%%
                                bw_ero_flag     = ones(maxit,1);  % Flag for bw multiple erosion
                                dw_ero_flag     = ones(maxit,1);  % Flag for dw multiple erosion
                                nex_bw_force  = zeros(y_maxcell,maxit);
                                nex_dw_force  = zeros(1,x_maxcell);
                    
                    
                                %%% RESET FOR NON WEATHERING CASE
                                if (wea==2) 
                                    weathering = true;
                                    wea_flag = 1;
                                end
                    
                                mwl = reset_mwl;    % STORE INITIAL MWL
                                tec_flag = false;   % RESET TEC_FLAG
                                rsl_con = 1;        % RSL COUNTER
            
                                
                    
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
                                %%% MAIN EROSION LOOP  
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
                            
                                loop = 0;
                                while (loop<maxit) & ((ix_max<(x_maxcell-(1/gridsize))) |(ix_posi<(x_maxcell-(1/gridsize)))|(ix_tidal_posi<(x_maxcell-(1/gridsize))))                
                                    loop=loop+1;
                        
                        
                                    %%% 
                                    %%% RSL CHANGE DUE TO HOLOCENE SEA LEVEL FLUCTUATION
                                    %%%                       
                                    if(rsl_flag)
                                        if(loop==event(rsl_con))
                                            ver_rsl = rsl(rsl_con+1) - rsl(rsl_con);
                                            hor_rsl = event(rsl_con+1) - event(rsl_con);
                                            mwl = mwl + round(((ver_rsl/hor_rsl)*(loop-event(rsl_con)))/gridsize);
                                            rsl_con = rsl_con + 1;
                                        end
                                    end
                            
                                    %%% 
                                    %%% RSL CHANGE DUE TO TECTONIC EVENTS
                                    %%%
                                    if(tec_flag)
                                        for i=1:length(ttic)
                                            if( tec_flag & loop==ttic(i) )
                                                mwl = mwl - tectonic(i,co)/gridsize; 
                                                break
                                                if(length(ttic)==i) tec_flag = false; end
                                            end	
                                        end
                                    end
                        
                                    
                                
                                    %%%
                                    %%% 
                                    %%% CALCULATE BACK WEARING EROSION FORCE
                                    %%% 
                                    %%%
                                    if ( bw )
							
                                        %%% CLEAR PREVIOUS VALUES
                                        i=0; w_type=0; bw_erosion(:) = 0;   
                                
                                        %%% FOR ALL INTERTIDAL ELEVATION
                                        for y=mwl-ceil(tide/2):mwl+ceil(tide/2)-1
                                            i=i+1;
								
                                        
                                            %%% ESF SIZE CHECK
                                            if( i > size(esf,1))
                                                break
                                            end

                                            %%% FIND X POSITIONS OF SURFICIAL ROCKS
        					                x=1+round(y/tan(i_angle*pi/180));
                                            while (x<=x_maxcell)&(s.flag(x,y)==0)   x = x+1;    end
                
                                            %%% 
                                            tmp_p       = h;                                
                                            tmp_h       = height/gridsize;
                                            
                                            %%% ESTIMATE HORIZONTAL BREAKING POINT
                                            %%% bp_x ... X POSITION OF BREAKING POINT
                                            y_bd = 0;
                                            if (x==1) bp_x=x; bp_y=0;
                                            else			
                                                bp_x=x;
                                                for xx=x-1:-1:1
                                                    for yy=(y-bd):y-1
                                                        if ( s.flag(xx,yy+1)==0 & s.flag(xx,yy)==1)
                                                            bp_y=yy;
                                                            if ( bp_x > xx ) bp_x = xx; end
                                                        end
                                                    end
                                                end
                                            end
                                
                                            %%%
                                            %%% NEW FIND LOCAL SLOPE AND BREAKER
                                            %%% SURF WIDTH
                                            %%%
                                            if( loop == 1 )
                                                locals = i_angle;
                                            elseif( bp_x-(tmp_h)> 0)
                                                xx = bp_x-tmp_h;
                                                yy = bp_y;
                                                while( yy > 0 & s.flag(xx,yy)==0 ) yy=yy-1; end
                                                locals = atan2d(bp_y-yy,tmp_h);
                                            else
                                                xx = 1;
                                                yy = bp_y;
                                                while( yy > 0 & s.flag(xx,yy)==0 ) yy=yy-1; end
                                                locals = atan2d(bp_y-yy,bp_x);
                                            end
                                            if(locals > 90)  stop;
                                            else
                                                break_wave_dist     = tmp_h*cos(locals*pi/180)*10;
                                                brea_const          = brea_const_tmp*sin(locals*pi/180);
                                                if( brea_const < brok_const )    brea_const = brok_const; end
                                                decay_sw1           = -log(swd1)/break_wave_dist; 
                                            end
                                           

                                            
                                            %%% SET WAVE TYPE... UNBROKEN? BREAKING? BROKEN?
                                            if (x==1)                                               w_type = 1; %%% UNBROKEN WAVE
                                            elseif ( (x-bp_x)<0 )                                   w_type = 1; %%% UNBROKEN WAVE    
                                            elseif ( ((x-bp_x)<break_wave_dist )&((x-bp_x)>=0) )    w_type = 2; %%% BREAKING WAVE at bp_x
                                            elseif ( (x-bp_x)>=break_wave_dist )                    w_type = 3; %%% BROKEN WAVE at bp_x
                                            end
                                   
                                        
                                            %%% FORCE WEATHEIRNG INACTIVE
                                            if ( wea==2 & wea_flag==1 & w_type==2 )
                                        	    weathering  = false;
                                        	    wea_flag    = 0;
                                            end
                        
                            
                                            %%% SET SLOPE ANGLE BETA TO DETERMINE SURF WIDTH
                                            if ( loop==1 | w_type == 1 ) 
                                                angle = i_angle;
                                            elseif ( w_type==2 | w_type==3 )
                                                if ((x-bp_x+1) >= 2)
                                                    clear tmp_y_posi
                                                    tmp_x_posi = (1:(x-bp_x+1));
                                                    tmp_y_posi = zeros(1,(x-bp_x+1));
                                                    tmp_y_posi(1)		= bp_y;
                                                    tmp_y_posi(x-bp_x+1)= y;
                    
                                                    tmp_i = 1;
                                                    for tmp_x=bp_x+1:x-1
                                                        tmp_y = bp_y; 
                                                        tmp_i = tmp_i + 1;
                                                        while (s.flag(tmp_x,tmp_y)==1) tmp_y=tmp_y+1; end
                                                        tmp_y_posi(tmp_i)=tmp_y-1;
                                                    end
                                                    pol=polyfit(tmp_x_posi, tmp_y_posi, 1);
                                                    angle= atan(pol(1))*180/pi;    
                                                else
                                                    angle = i_angle;
                                                end
                                            end
                                    
                                        
                                            %%% SET SURF WIDTH (cell)
                                            %%% SET WAVE ATTENUATION CONSTANT2
                                            %if ( angle < 90 )
                                            %    sw = abs(num_height/tan(angle*pi/180));
                                            %    decay_sw2 = -log(swd2)/sw;
                                            %else
                                            %    sw = 0;
                                            %    decay_sw2 = Inf;
                                            %end
									
                                        
                                            %%%%%%%%%%%%%%%%%%
                                            %%% SPECIAL CHANGE	by HIRO 30/06/2017
                                            %%%%%%%%%%%%%%%%%%
                                            decay_sw1 = wav_erodi(we)*gridsize;
                                            decay_sw2 = wav_erodi(we)*gridsize;
                                            swd1      = exp(-decay_sw1*break_wave_dist);
                  
                                            
                                            
                                            %%% PRIMARY EROSION
                                            %%% IN CASE OF STANDING WAVE
                                            if ( w_type == 1 )
                                                k=0;
                                                for yy=y+(stan_dist1-1):-1:y-stan_dist2
                                                    k=k+1;
                                                    xx=1;
                                                    while (xx<=(x_maxcell-1)) & (s.flag(xx,yy)==0)    xx=xx+1;    end
                                                    force = stan_const*height*esf(i)*p_stan(k); 
                                                    bw_erosion(yy) = bw_erosion(yy) + force;
                                                end
									
                                            %%% IN CASE OF BREAKING WAVE
                                            elseif ( w_type == 2 )			
                                                k=0;    
                                                k1=-((break_dist1(tmp_p)-1)-(stan_dist1(tmp_p)-1));  
                                                k2=-((break_dist1(tmp_p)-1)-(brok_dist1(tmp_p)-1));
                
                                                % this loop is the same as the one above because jump=0
                                                for yy=round(jump*(height/gridsize))+y+(break_dist1(tmp_p)-1):-1:round(jump*(height/gridsize))+y-break_dist2(tmp_p)
                                                    k=k+1;  k1=k1+1;    k2=k2+1;
    
                                                    xx=1;
                                                    xx=1+round(y/tan(i_angle*pi/180));
                                                    while (xx<=(x_maxcell-1))&(s.flag(xx,yy)==0) xx=xx+1; end
                
                                                    %%% SPATIALLY BEHAVE AS A STANDING WAVE
                                                    if ( xx < bp_x ) & ( (stan_dist1(tmp_p)-1) >= (yy-y) ) & ( stan_dist2(tmp_p) >= (y-yy) )                                                    
                                                        force = stan_const*height*esf(i)*p_stan(k1);
                                                        bw_erosion(yy) = bw_erosion(yy) + force;
                                    
                                                    %%% SPATIALLY BEHAVE AS A BROKEN WAVE                                              
                                                    elseif ( ( (xx-bp_x)>= break_wave_dist ) & ( (brok_dist1(tmp_p)-1) >= (yy-y) ) & ( brok_dist2(tmp_p) >= (y-yy)) ) 
                                                        force = brok_const*p_brok(k2)*height*swd1*esf(i)*exp(-decay_sw2*(xx-(bp_x+break_wave_dist)));
                                                        bw_erosion(yy) = bw_erosion(yy) + force;
                                                    
                                                    %%% OR...    
            										elseif (( xx >= bp_x ) & ( (xx-bp_x) < break_wave_dist(tmp_p) ) & ( break_dist1(tmp_p)-1 >= (yy-y) ) & ( break_dist2(tmp_p) >= (y-yy) ))
                                                        force = brea_const*height*esf(i)*p_break(k)*exp(-decay_sw1*(xx-(bp_x)));
                                                       	bw_erosion(yy) = bw_erosion(yy) + force;
                    
                                                    end    
                                                end
									
                                            %%% IN CASE OF BROKEN WAVE
                                            elseif ( w_type == 3 )
										
                                                k=0;    
                                                k1=-((brok_dist1(tmp_p)-1)-(stan_dist1(tmp_p)-1));    
                                                k2=-((brok_dist1(tmp_p)-1)-(break_dist1(tmp_p)-1));
										
                                                for yy=y+brok_dist1(tmp_p)-1:-1:y-brok_dist2(tmp_p)
                                                    k=k+1;     k1=k1+1;    k2=k2+1;
                                                
                                                    xx=1;   
                                                    while (xx<=(x_maxcell-1)) & (s.flag(xx,yy)==0)    xx=xx+1;    end
                    
                                                    %%% SPATIALLY BEHAVE AS A STANDING WAVE
                                                    if ( xx < bp_x ) & ( (stan_dist1(tmp_p)-1) >= yy-y ) & ( stan_dist2(tmp_p) > y-yy )       
                                                        force = stan_const*height*esf(i)*p_stan(k1);
                                    					bw_erosion(yy) = bw_erosion(yy) + force;
                                        
                                            		%%% SPATIALLY BEHAVE AS A BREAKING WAVE
                                                    elseif ( (xx>=bp_x) & ((xx-bp_x)<break_wave_dist) & ( (break_dist1(tmp_p)-1) >= (yy-y) ) & ( break_dist2(tmp_p) >= (y-yy) ) ) 
                                        
                                                        force  = brea_const*height*esf(i)*p_break(k2)*exp(-decay_sw1*(xx-(bp_x)));
                                                    	bw_erosion(yy) = bw_erosion(yy) + force;
            
                                                    %%% OR...
                                    				elseif ( ((xx-bp_x) >= break_wave_dist) & ( (brok_dist1(tmp_p)-1) >= (yy-y) ) & ( brok_dist2(tmp_p) >= (y-yy)) )
                        
                                                        force = brok_const*height*swd1*esf(i)*p_brok(k)*exp(-decay_sw2*(xx-(bp_x+break_wave_dist)));
                                                		bw_erosion(yy) = bw_erosion(yy) + force;
                                                    end
                                                end
                                            end
									
                                            %%% STORE WAVE TYPE & BREAK POINT
                                            break_point_x(i,loop)   = bp_x;
                                            break_point_y(i,loop)   = bp_y; 
                							break_wdist(i,loop)     = break_wave_dist;
                                            break_wcont(i,loop)     = brea_const;
                                            wave_type(i,loop)       = w_type;
                    						%surf_width(i,loop)      = sw;
                            				sw2_decay(i,loop)       = decay_sw2;
                                            angle_l(i,loop)			= angle;
                                            tidal_x_posi(i,loop)    = x;
                                            local_angle(i,loop)     = locals;
                                            
                                    
                                        	if(force==inf)  stop; end
                                
                                        end
                                        total_bw_erosion(:,loop)  	= bw_erosion;
                                    
                                    end

                                    
                                
                                    %%%
                                    %%%
                                    %%% CALCULATE DOWN WEARING EROSION FORCE
                                    %%%
                                    %%%
                                    if (dw)
							
                                        %%% CLEAR PREVIOUS VALUE
                                        dw_erosion(:) = 0;
            
                                        %%% ESTIMATE SURFICIAL ROCKS WITHIN INTERTIDAL RANGE
                                        i=0; x_tidal_max = 0;   y_tidal_max = 0;
                                        for y=mwl-ceil(tide/2):(mwl+ceil(tide/2)-1)
                                            x=1; 
                                            i=i+1;
                                            while( s.flag(x,y)==0 & x<=ix_max-1 )	x=x+1;	end
                                            tidal_posi(i) = x;
                                            if ( x > x_tidal_max )
                                                x_tidal_max = x;
                                                y_tidal_max = y;
                                            end
                                        end
						
                                		%%% ESTIMATE VERTICAL POSITION OF SUBMARINE SURFICIAL ROCKS
                        				if ( x_tidal_max >= 1 )	
                            				for x=1:x_tidal_max-1
                                    			y = y_tidal_max;
                                            	while (s.flag(x,y)==0) & (y > 1)  y=y-1;    end
                                            	if (y > 1)      y_depth(x) = y;	
                                                else            y_depth(x)=1;
                                                end
                                            end
								
                                            i = 0;
                                            for y=mwl-ceil(tide/2):mwl+ceil(tide/2)-1
                                                i = i + 1;
                                    
                                                %%% ESF SIZE CHECK
                                                if( i > size(esf,1))
                                                    break
                                                end
                                                bp_x = break_point_x(i,loop);   % OBTAIN BREAKING POINT
                                        		decay_sw2 = sw2_decay(i,loop);  % BROKEN WAVE DECAY COEFFICIENT
                                                break_wave_dist = break_wdist(i,loop);  % OBTAIN BREAKING WAVE DISTANCE
                                                brea_const = break_wcont(i,loop);       % OBTAIN BREAKING WAVE CONST
                                                
                                                %%% RECALCULATE LOCAL SLOPE
                                                if ( bp_x >= 1 )
                                                
                                                    x=1;
                                                    while ( x < tidal_posi(i) )
                                                        %%% IN CASE OF STANDING WAVE
                                                        if (x<bp_x)	
                                                            force = stan_const*height*esf(i)*p_stan_sub;
                                                            decay_dc = -log(sub_decay_const)/(height);
                                                        %%% IN CASE OF BREAKING WAVE
                                                        elseif( x>=bp_x & x<(bp_x+break_wave_dist) ) 
                                                            force = brea_const*height*esf(i)*p_break_sub*exp(-decay_sw1*(x-(bp_x)));
                                                            decay_dc = -log(sub_decay_const)/(height*exp(-decay_sw1*(x-(bp_x))));
                                                        %%% IN CASE OF BROKEN WAVE
                                                        else 
                                                            force = brok_const*height*swd1*esf(i)*p_brok_sub*exp(-decay_sw2*(x-(bp_x+break_wave_dist)));
                                                            decay_dc = -log(sub_decay_const)/(height*swd1*exp(-decay_sw2*(x-(bp_x+break_wave_dist))));
                                                        end

                                                        %%% ESTIMATE FORCE SURFICIAL ROCKS
                        								yy=y-y_depth(x);
                            							if ( yy > 0 )
                                        					dw_erosion(x) = dw_erosion(x) + force * exp(-decay_dc*yy);
                                            				if ( y_depth(x) >= (mwl-ceil(tide/2)) & (y_depth(x) < mwl+ceil(tide/2)-1) )
                                                    			dur=y_depth(x)-(mwl-ceil(tide/2))+1;
                                                            end
                                                        end											
                                                        x=x+1;											
                                                    end
                                                end									
                                            end
                
                                        end
                        
                                        %%% STORE FOR OUTPUTTING
                                        if(dw_ero_flag(loop))   total_dw_erosion(:,loop) = dw_erosion;
                                        else                    total_dw_erosion(:,loop) = nex_dw_force;
                                        end
                                    end
						
                                    
                                
                                %%%
                                %%%
        						%%% Judge erosion ( FW >= FR? )
            					%%%
                                %%%
                
                                %%%
                        		%%% BACK WEARING EROSION
                            	%%%
                                if(bw)
                                
                                    bw_ero_flag(loop) = 1;

                                    for y=1:(mwl+ceil(tide/2)-1+break_dist1)
	
                                        x=1; 
                                        while ( (s.flag(x,y)==0) & ( x < (x_maxcell-10) ) ) x=x+1; end
							
                                        bw_force=total_bw_erosion(y,loop);
                                        if ( bw_force >= s.resistance(x,y) )
                                            tmp_resi = s.resistance(x,y);
                
                                            %%% IN CASE OF WAVES IS ABLE TO ACHIVE ONLY ONE ROCK CELL EROSION 
                                            if (change == 1) 
                                    
                                            s.flag(x,y)             = 0;	
                                            s.resistance(x,y)       = 0;
                                    		count_vert_wave(loop,y) = count_vert_wave(loop,y) + tmp_resi;
                                            count_wave(loop)        = count_wave(loop) + 1; 
                                    
                                            if ( y >= mwl-ceil(tide/2) & y <= mwl+ceil(tide/2)-1 )
                                                count_wave_erosion(loop)    = count_wave_erosion(loop)    + tmp_resi;
                                                count_wave_int(loop)        = count_wave_int(loop) + 1;
                                            end
                                            if ( ix_max < (x+1) )  ix_max = (x+1); end
                                            if ( ix_max >= x_maxcell ) ix_max = x_maxcell-1; end
								
                                        %%% IN CASE OF WAVE IS ABLE TO ACHIVE MORE THAN ONE ROCK CELL EROSION 
                                        elseif (change ==2)

                                            %%% CAN ERODE MORE THAN ONE CELL!!
                                            if (bw_force >= (s.resistance(x,y)+effec_resi))
                                                tmp_ero = bw_force-s.resistance(x,y); 
                                                q       = floor(tmp_ero/effec_resi); 
                                                r       = mod(tmp_ero,effec_resi);

                                                ero_count   = 0;
                                                for p=0:q
                                                    if ((x+p)<=x_maxcell)
                                                        s.flag(x+p,y)=0; 
                                                        s.resistance(x+p,y)=0;
                                                        count_vert_wave(loop,y) = count_vert_wave(loop,y) + effec_resi;
                                                        count_wave(loop)        = count_wave(loop) + 1;
                                                    
                                                        if ( y >= mwl-ceil(tide/2) & y <= mwl+ceil(tide/2)-1 )
                                                            count_wave_erosion(loop)    = count_wave_erosion(loop)  + effec_resi;
                                                            count_wave_int(loop)        = count_wave_int(loop) + 1;
                                                        end
                                                        if ( ix_max < (x+p+1) )     ix_max = (x+p+1); end
                                                        if ( ix_max >= x_maxcell )  ix_max = x_maxcell-1; end
                                                    end
                                                end
                                        
                                            %%% CAN ERODE ONLY ONE CELL    
                                            else
                                                s.flag(x,y)             = 0;	
                                                s.resistance(x,y)       = 0;
                                                count_vert_wave(loop,y) = count_vert_wave(loop,y) + tmp_resi;
                                                count_wave(loop)        = count_wave(loop) + 1;
                                        
                                                if ( (y >= mwl-ceil(tide/2)) & (y <= mwl+ceil(tide/2)-1) )
                                                    count_wave_erosion(loop)    = count_wave_erosion(loop) + tmp_resi;
                                                    count_wave_int(loop)        = count_wave_int(loop) + 1;
                                                end
                                                if ( ix_max < (x+1) )  ix_max = (x+1); end
                                                if ( ix_max >= x_maxcell ) ix_max = x_maxcell-1; end
                                        
                                            end
                                        end
                                    end
                                end		
                            end     %%% END OF BACK WEARING EROSION
                        

                            %%% 
                            %%% DOWN WEARING  EROSION
                            %%%
                            if(dw)
                                dw_ero_flag(loop) = 1;
                        
                                %%% FOR ALL THE SURFICIAL ROCK CELLS ...
                                for x=1:x_tidal_max-1
                                    y = y_depth(x);	
                                    dw_force = total_dw_erosion(x,loop);
							
                                    if (s.flag(x,y)==1)
							
                                        while ((s.flag(x,y)==0)&y>1) y=y-1; end 
								
                                        if ( dw_force >= s.resistance(x,y) )
                                            tmp_resi = s.resistance(x,y);
									
                                            %%% IN CASE OF WAVES ACHIVING ONE ROCK CELL EROSION 
                                            if (change==1)
                                                s.flag(x,y)=0;	s.resistance(x,y)=0;
                                                count_vert_wave(loop,y) = count_vert_wave(loop,y) + tmp_resi;
                                                count_wave(loop)        = count_wave(loop) + 1;
                                        
                                                if ( (y >= mwl-ceil(tide/2)) & (y <= mwl+ceil(tide/2)-1) )
                                                    dur=y-(mwl-ceil(tide/2))+1;
                                                    count_wave_erosion(loop)    = count_wave_erosion(loop)  + tmp_resi;
                                                    count_wave_int(loop)        = count_wave_int(loop) + 1;
                                                end
									
                                            %%% IN CASE OF WAVE IS ABLE TO ACHIVE MORE THAN ONE ROCK CELL EROSION 
                                            elseif (change==2)
                                        
                                                %%% CAN ERODE MORE THAN ONE CELL!!
                                                if ( dw_force >= s.resistance(x,y)+effec_resi )
                                                    tmp_ero=dw_force-s.resistance(x,y); 
                                                    q=floor(tmp_ero/effec_resi); 
                                                    r=mod(tmp_ero,effec_resi);
										
                                                    ero_count   = 0;
                                                    for p=0:q
                                                        if ( (y-p) >= 1 )
                                                            s.flag(x,y-p)=0; s.resistance(x,y-p)=0;
                                                            count_vert_wave(loop,y-p)   = count_vert_wave(loop,y-p) + effec_resi;
                                                            count_wave(loop)            = count_wave(loop) + 1;
													
                                                            if ( ( (y-p) >= mwl-ceil(tide/2) ) & ( ( (y-p) <= mwl+ceil(tide/2)-1 ) ) )
                                                                count_wave_erosion(loop)    = count_wave_erosion(loop)  + effec_resi;
                                                                count_wave_int(loop)        = count_wave_int(loop) + 1;
                                                            end
                                                        end
                                                    end
                                                    
                                                %%% CAN ERODE ONLY ONE CELL    
                                                else
                                                    s.flag(x,y)=0;	s.resistance(x,y)=0;
                                                    count_vert_wave(loop,y) = count_vert_wave(loop,y) + tmp_resi;
                                                    count_wave(loop)            = count_wave(loop) + 1;
    										
                                                    if ( y >= mwl-ceil(tide/2) & (y <= mwl+ceil(tide/2)-1) )
                                                        count_wave_erosion(loop)    = count_wave_erosion(loop)  + tmp_resi;
                                                        count_wave_int(loop)        = count_wave_int(loop) + 1;
                                                    end
                                            
                                                end
                                            end				
                                        end
                                    end
                				end		
                            end    %%% END OF BACK WEARING EROSION
              
                            
			  
                            %%%
                            %%% CALCULATE MASS FAILURE : version 2
                            %%% 
                            %%% ORIGINALLY A MINIMUM CEL NUMBER WITH WICHIH CANTILEVER MASS COLLAPSE CALCULATED, 
                            %%% BUT NOW ALL THE CANTILEVER BLOCK IS REMOVED WHEN EROSION DEPTH IS 1 METRE.   
                            %%%  
                            x_dist=0;   y=mwl-ceil(tide/2)-break_dist1-1;
                            while (y <= (mwl+ceil(tide/2)+break_dist1) & y<=y_maxcell-2 )
                                y=y+1;  x=1;
            					while (s.flag(x,y)==0) & (x <= (ix_max-1)) x=x+1;  end
        
                                %%% COUNT THE WIGHT and ARM LENGTH
                                count=0; x_dist=0;
                                if (x>1+round(y/tan(i_angle*pi/180)))
                                    if (s.flag(x-1,y+1)==1) 
                                        yy=y+1; x_dist=1;
                                        while (yy<=(y_maxcell-1))&(s.flag(x-1,yy)==1)
        									yy=yy+1;
            								if(yy == mwl+ceil(tide/2)+(break_dist1(tmp_p)-1)+1) count = count+600;
                							else	count=count+1;
                                            end
                                        end
                                        in=1; xx=x-2;
                                        while (xx>0) & (in==1)
                                            yyy=y+1;
                                            count_old=count;
                                            while (yyy <= yy)
                                                if ((s.flag(xx,yyy)==1)&(s.flag(xx+1,yyy)==1))
                                                    if (yy == mwl+ceil(tide/2)+(break_dist1(tmp_p)-1)+1) count=count+600;
    												else count=count+1;
                                                    end
                                                end
                                                yyy=yyy+1;
                                            end
                                            if (count_old == count) in=0;
                                            else    xx=xx-1; x_dist=x_dist+1;
                                            end
                                        end
                                    end
                                end
                                
                                %%% ORIGINAL CRITERIA
                                %if ( count*x_dist > (y_maxcell*y_maxcell)/10 )
                                %%% NOW CHANGES TO ... IF x_dist IS LARGER THAN 1 m... 
                                if ( x_dist > 10 )
                                    for xxx=x-1:-1:(x-x_dist)
                                        for yyyy=y+1:yy s.flag(xxx,yyyy)=0; end
                                    end
                                end
                            end
                            
                            
                            
                            
                            %%%
                            %%% FIND INNER and OUTER POSITIONS
                            %%%
                            %%% find inner and outer position below MLWS
        					ox_posi	= min(posi);		
            				ix_posi = max(posi);
                			oy_temp = find( posi==ox_posi );
                    		iy_temp = find( posi==ix_posi );
                            oy_posi = max(oy_temp);
                        	iy_posi = min(iy_temp);
                        	g_angle = atan ((iy_posi-oy_posi)/(ix_posi-ox_posi))*(180/pi);
                            if ( ox_posi==ix_posi ) 
                                g_angle =90;
                                oy_posi = iy_posi;
                            end
							% find inner position within tidal range
                            ix_tidal_posi 	= max(tidal_posi);
                            ox_tidal_posi	= min(tidal_posi);
                            iy_tidal_temp 	= find( tidal_posi==ix_tidal_posi );
                            oy_tidal_temp 	= find( tidal_posi==ox_tidal_posi );
                            iy_tidal_posi 	= mwl-(ceil(tide/2))-1+min(iy_tidal_temp);
                            oy_tidal_posi 	= mwl-(ceil(tide/2))-1+max(oy_tidal_temp);
                            if ( ox_tidal_posi==ix_tidal_posi ) 
                                oy_tidal_posi = mwl-ceil(tide/2);
                                iy_tidal_posi = mwl+ceil(tide/2)-1;
                            end
                               
                            
                            
						
                            %%%
                            %%%
                            %%% WEATHERING PROCESS
                            %%%					
                            %%%
                            if (weathering)
                				i=0;

                    			% clear previous value
                        		wea_erosion(:) = 0;
                                for y=(mwl+ceil(tide/2)-1):-1:(mwl-ceil(tide/2))
                                    i=i+1;
                                
                                    %%% ESF SIZE CHECK
                                    if( i > size(esf,1))    break;  end
                    
                                    %force = effec_resi*wt_const*wetdry(i);
                                    previous = 0;
                                    for x=1+round(y/tan(i_angle*pi/180)):ix_tidal_posi %%% CHECK ALL THE SURFICIAL ROCKS
                                    
                                        %%% WEATHEIRNG FORCEz`
                                        %force = wt_const*(gridsize/0.1)*wetdry(i);
                                        %force = effec_resi/(100/(wt_const*(gridsize/0.1)))*wetdry(i);
                                        force = effec_resi/(100/(wt_const*(gridsize/0.1)))*wetdry(i);
                                    
                                        %%% FIND ROCK CELL
                                        if( s.flag(x,y)==1 )
                                        
                                            %%% IF INITIAL POSITION, NO NEED TO CHECK EXPOSURE
                                            if ( x==1+round(y/tan(i_angle*pi/180)) ) 
                                                for yy=0:max_we_erosion-1
                                                
                                                    if( y-yy <= mwl+ceil(tide/2)-1 & y-yy >= (mwl-ceil(tide/2)) )
                                                        left = s.resistance(x,y-yy);
                                                        s.resistance(x,y-yy)        = s.resistance(x,y-yy)      - force;
                                                        wea_erosion(y-yy)           = force;
                                                        count_wea_erosion(loop)     = count_wea_erosion(loop)   + force;
                                                        count_vert_wea(loop,y-yy)   = count_vert_wea(loop,y-yy) + force;

                                                        if( s.resistance(x,y-yy) < 0 )
                                                            previous = x;
                                                            s.flag(x,y-yy)              = 0;	
                                                            s.resistance(x,y-yy)        = 0;
                                                            count_wea_erosion(loop)     = count_wea_erosion(loop)   - (force-left);
                                                            count_vert_wea(loop,y-yy)   = count_vert_wea(loop,y-yy) - (force-left);
                                                            count_wea(loop)             = count_wea(loop) + 1;
                                                            force                       = force-left;
                                                        
                                                            if ( ix_max < x )           ix_max          = x; end
                                                            if ( ix_max >= x_maxcell )  ix_max          = x_maxcell-1; end
                                                            if ( iy_tidal_posi < y-yy ) iy_tidal_posi   = y-yy; end
                                                        end
                                                    end
                                                end
                                            
                                            %%% IF X_MAXCELL POSITION
                                            elseif ( x == x_maxcell )
                                            
                                                for yy=0:max_we_erosion-1
                                                    if( y-yy <= mwl+ceil(tide/2)-1 & y-yy >= (mwl-ceil(tide/2)) )
                                                        if ( (s.flag(x-1,y-yy)==0) | (s.flag(x,y+1-yy)==0) | (s.flag(x,y-1-yy)==0) )  
                
                                                            left = s.resistance(x,y-yy);
                                                            s.resistance(x,y-yy)        = s.resistance(x,y-yy)      - force;
                                                            wea_erosion(y-yy)           = force;
                                                            count_wea_erosion(loop)     = count_wea_erosion(loop)   + force;
                                                            count_vert_wea(loop,y-yy)   = count_vert_wea(loop,y-yy) + force;
                               			
                                                            if( s.resistance(x,y-yy) < 0 )
                                                    
                                                                previous = x;
                                                                s.flag(x,y-yy)              = 0;	
                                                                s.resistance(x,y-yy)        = 0;
                                                                count_wea_erosion(loop)     = count_wea_erosion(loop)   - (force-left);
                                                                count_vert_wea(loop,y-yy)   = count_vert_wea(loop,y)     - (force-left);
                                                                count_wea(loop)             = count_wea(loop) + 1;
                                                                force                       = force - left;
                                                       
                                                                if ( ix_max < x )           ix_max = x; end
                                                                if ( ix_max >= x_maxcell )  ix_max = x_maxcell-1; end
                                                                if ( iy_tidal_posi < y-yy ) iy_tidal_posi = y-yy;	end
                                                        
                                                            end
                                                        end
                                                    end
                                                end
                                       
                                            %%% OTHER ....    
                                            else
        
                                                for yy=0:max_we_erosion-1
        
                                                    if( ((s.flag(x-1,y-yy)==0)&(previous~=(x-1))) | (s.flag(x,y+1-yy)==0) | (s.flag(x,y-1-yy)==0) | (s.flag(x+1,y-yy)==0))
                    
                                                        if( y-yy <= mwl+ceil(tide/2)-1 & y-yy >= (mwl-ceil(tide/2)) ) 
                                                    
                                                            left = s.resistance(x,y-yy);
                                                            s.resistance(x,y-yy)        = s.resistance(x,y-yy)      - force;
                                                            wea_erosion(y-yy)           = force;
                                                            count_wea_erosion(loop)     = count_wea_erosion(loop)   + force;
                                                            count_vert_wea(loop,y-yy)   = count_vert_wea(loop,y-yy) + force;
                                                
                                                            if( s.resistance(x,y-yy) < 0 )
                                                                previous                    = x;
                                                                s.flag(x,y-yy)              = 0;	
                                                                s.resistance(x,y-yy)        = 0;
                                                                count_wea_erosion(loop)     = count_wea_erosion(loop)   - (force-left);
                                                                count_vert_wea(loop,y-yy)   = count_vert_wea(loop,y-yy) - (force-left);
                                                                count_wea(loop)             = count_wea(loop) + 1;
                                                                force                       = force - left;
                                                            
                                                                if ( ix_max < x )           ix_max = x; end
                                                                if ( ix_max >= x_maxcell )  ix_max = x_maxcell-1; end
                                                                if ( iy_tidal_posi < y-yy ) iy_tidal_posi = y-yy; end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
							
                                total_wea_erosion(:,loop)  = wea_erosion(:);
                            end

                            
                            
                            %%%    
                            %%% UPDATE X_&Y_PROFILE, INNER_POSISION
                            %%% AND ANGLE CALCULATION
                            %%%
                            posi = zeros(y_maxcell,1);	% set size of posi
                            tidal_posi=0; 
                            f=0;
                            %%% FIND INNER POSITION 
                            for y=1:y_maxcell
							    x=1+round(y/tan(i_angle*pi/180));
                                while( s.flag(x,y)==0 & x <= ix_max-1 )	x=x+1;	end
                                posi(y)=x;
                                if( (y>=(mwl-ceil(tide/2))) & (y<=(mwl+ceil(tide/2)-1)) )
                                    f=f+1;
                                    tidal_posi(f)=x;
                                end
                            end
                            %%% FIND INNER AND OUTER POSITION BELOW MLWS
        					ox_posi	= min(posi);		
            				ix_posi = max(posi);
                			oy_temp = find( posi==ox_posi );
                    		iy_temp = find( posi==ix_posi );
                            oy_posi = max(oy_temp);
                        	iy_posi = min(iy_temp);
                        	g_angle = atan ((iy_posi-oy_posi)/(ix_posi-ox_posi))*(180/pi);
                            if ( ox_posi==ix_posi ) 
                                g_angle =90;
                                oy_posi = iy_posi;
                            end
							%%% FIND INNER POSITION WITHIN TIDAL RANGE
                            ix_tidal_posi 	= max(tidal_posi);
                            ox_tidal_posi	= min(tidal_posi);
                            iy_tidal_temp 	= find( tidal_posi==ix_tidal_posi );
                            oy_tidal_temp 	= find( tidal_posi==ox_tidal_posi );
                            iy_tidal_posi 	= mwl-(ceil(tide/2))-1+min(iy_tidal_temp);
                            oy_tidal_posi 	= mwl-(ceil(tide/2))-1+max(oy_tidal_temp);
                            if ( ox_tidal_posi==ix_tidal_posi ) 
                                oy_tidal_posi = mwl-ceil(tide/2);
                                iy_tidal_posi = mwl+ceil(tide/2)-1;
                            end
                            %%% CALCULATE INTERTIDAL PROFILE GRADIENT
                            if(wea == 1)
                                if (ix_tidal_posi==ox_tidal_posi)
                                    oy_tidal_posi = iy_tidal_posi;
                                    g_tidal_angle = 90;
                                elseif (iy_tidal_posi == (mwl-ceil(tide/2)))
                                    ox_tidal_posi = ix_tidal_posi;
                                    oy_tidal_posi = iy_tidal_posi;
                                    g_tidal_angle = 90;
                                else
                                    g_tidal_angle   = atan((iy_tidal_posi-(mwl-ceil(tide/2)))/(ix_tidal_posi-tidal_posi(1)))*(180/pi);
                                end
                            elseif(wea == 2)
                                oy_posi = 1;
                                while (s.flag(1,oy_posi)==1) oy_posi = oy_posi + 1; end
                                g_tidal_angle = atan((iy_posi-oy_posi)/(ix_posi))*(180/pi);
                            end
                            
                            
                        
                        
                            %%%    
                            %%% CREATE MOVIE
                            %%%
							if (print_snap_to_mov)
                                
                                if ( mod(loop,round(maxit/100))==0 | loop==1 )
                                    
                                    if ( ix_max+10 > x_maxcell )	ix_max = x_maxcell-10;	end
                                    x_temp1	=1:ix_max+10;   
                                    x_temp2	=1:ix_max+10;   
                                    x_line	=1:ix_max+10;
                                    for i=2:y_maxcell     x_temp1=horzcat(x_temp1,x_temp2);   end
                                
                                    %%% ADD CASE OF LOOP=0;
                                    if(loop==1)
                                        filename=[output_path, f_name,'.avi'];  
                                        aviobj=avifile(filename, 'fps', 4);
                                        
                                        y_temp1	= mat(1:ix_max+10,1)';
                                        for i=2:y_maxcell     
                                            y_temp2	= i*mat(1:ix_max+10,i)';    y_temp1	= horzcat(y_temp1,y_temp2);
                                        end
                                        y_high(1:size(x_temp2))=mwl+ceil(tide/2)-1;
                                        y_low(1:size(x_temp2))=mwl-ceil(tide/2);
                                        winsize = [ 0 0 1920 1080];

                                        %%% OPEN FIGURE
                                        figure('visible', 'off', 'Position', winsize); hold on;  axis([1 x_maxcell 1 y_maxcell]);
                                        plot(x_temp1,y_temp1, '.');
                                        plot(x_line, y_high, '--r', 'linewidth', 10);
                                        plot(x_line, y_low, '--r','linewidth',10);
                                        text(0,mwl+ceil(tide/2)-1,'MHWS','Fontsize',10,'Backgroundcolor',[1 1 1]);
                                        text(0,mwl-ceil(tide/2),'MLWS','Fontsize',10,'Backgroundcolor',[1 1 1]);
                                        text(0.1,0.9,['Iteration=',num2str(loop-1)],'Units','Normalized','Fontsize',10,'Backgroundcolor',[.7 .9 .7]);
                                        text(0.1,0.85,['Intertidal profile angle=',num2str(g_tidal_angle)],'Units','Normalized','Fontsize',10,'Backgroundcolor',[.7 .9 .7]);
                                        xlabel('Horizontal distance [x0.1 m]'); ylabel('Vertical distance [x0.1 m]'); 
                                        aviobj=addframe(aviobj,gcf);
                                        close;
                                    end
                                    
                                    y_temp1	= s.flag(1:ix_max+10,1)';
                                    for i=2:y_maxcell     
                                        y_temp2	= i*s.flag(1:ix_max+10,i)';
                                        y_temp1	= horzcat(y_temp1,y_temp2);
                                    end
                                    y_high(1:size(x_temp2))=mwl+ceil(tide/2)-1;
                                    y_low(1:size(x_temp2))=mwl-ceil(tide/2);
                                    winsize = [ 0 0 1920 1080];

                                    %%% OPEN FIGURE
                                    figure('visible', 'off', 'Position', winsize); hold on;  axis([1 x_maxcell 1 y_maxcell]);
                                    plot(x_temp1,y_temp1, '.');
                                    plot(x_line, y_high, '--r', 'linewidth', 10);
                                    plot(x_line, y_low, '--r','linewidth',10);
                                    text(0,mwl+ceil(tide/2)-1,'MHWS','Fontsize',10,'Backgroundcolor',[1 1 1]);
                                    text(0,mwl-ceil(tide/2),'MLWS','Fontsize',10,'Backgroundcolor',[1 1 1]);
                                    text(0.1,0.9,['Iteration=',num2str(loop)],'Units','Normalized','Fontsize',10,'Backgroundcolor',[.7 .9 .7]);
                                    text(0.1,0.85,['Intertidal profile angle=',num2str(g_tidal_angle)],'Units','Normalized','Fontsize',10,'Backgroundcolor',[.7 .9 .7]);
                                    xlabel('Horizontal distance [x0.1 m]'); ylabel('Vertical distance [x0.1 m]'); 
                                    aviobj=addframe(aviobj,gcf);
                                    close;
                                end
                            end
							
						
                            %%%
                            %%% STORE VALUABLES
                            %%%
                            angle_g(loop)			= g_angle;
                            angle_g_tidal(loop)		= g_tidal_angle;
                            
                            %%%
                            %%% SAVE PROFILE
                            %%%
                            for y=1:y_maxcell
                                x=1;
                                while ( s.flag(x,y)==0 & x < x_maxcell ) x=x+1; end
                                save_profile(loop,y) = x;
                            end
						
                        end
                        
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%% END OF EROSION MAIN LOOP
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        

                        %%% CLOSE AVI FILE
                        if(print_snap_to_mov)
                            aviobj=close(aviobj);   
                        end
                    
                        %%% COPY TOTAL RESULT
        				final_prof(:,resi)	= save_profile(loop,:);
            			final_it(resi)		= loop;
                        
                    

                        
                        %%%
                        %%% PRINT FIGURES 
                        %%%           
                
                        %%% OUTPUT final_PROF to txt
                        if(final_prof_to_txt)
                            filename=[output_path, f_name, '-final_prof.txt'];  
                            txt = s.flag;
                            t_txt = flipud(txt.');
                            dlmwrite(filename, t_txt);
                            clear txt t_txt
                        end
                        
                        %%% OUTPUT break_point_x to txt
                        if(print_break_point)
                            filename=[output_path, f_name, '-break_point_x.txt'];  
                            dlmwrite(filename, break_point_x(:,:));
                        end                    
                    
                        %%% OUTPUT OF WAVE vs. WEATHEIRNG TO FIG
                        if (loop ~= maxit)	
                            x=[1:loop];
                            count_wave_erosion(loop+1:maxit)= [];
                            count_wea_erosion(loop+1:maxit) = [];
                            count_vert_wave(loop+1:maxit,:) = [];
                            count_vert_wea(loop+1:maxit,:)  = [];
                            count_wave(loop+1:maxit)        = [];
                            count_wave_int(loop+1:maxit)    = [];
                            count_wea(loop+1:maxit)        = [];
                        else
                            x=[1:maxit];
                        end
                    
                    
                        %%% OUTPUT OF WAVE vs. WEATHEIRNG TO TXT
                        if(print_wvsw_to_txt)
                           
                            filename=[output_path, f_name, '-WVSW.txt'];
                            
                            txt = x;
                            txt = vertcat(txt,count_wave_erosion');
                            txt = vertcat(txt,count_wea_erosion');
                        
                            %%% NUMBER OF ERODED BLOCKS
                            txt = vertcat(txt,count_wave');
                            txt = vertcat(txt,count_wave_int');
                            txt = vertcat(txt,(count_wea/num_resi_values(resi))');
                        
                            dlmwrite(filename, txt);
                            clear txt
                            
                        end
                    
                        
                        %%% OUTPUT OF WAVE vs. WEATHEIRNG TO TXT
                        if(print_wvsw_to_fig)
                    
                            sss=15;
                            
                            filename=[output_path, f_name, '-WVSW.tiff'];
                            step_num = 30;
                            step = round(loop/step_num)-1;
                            
                            equi_count_wea_erosion = count_wea_erosion/num_resi_values(resi);
                            for j=1:step_num
                                tot_wav(j) = sum(count_wave((j-1)*step+1:j*step))/step;
                                int_wav(j) = sum(count_wave_int((j-1)*step+1:j*step))/step;
                                int_wea(j) = sum(equi_count_wea_erosion((j-1)*step+1:j*step))/step;
                            end
                            
                            %%% NORMALIZE
                            ttt=horzcat(int_wea,tot_wav);
                            max_ttt = max(ttt);
                            int_wea = 100*int_wea/max_ttt;
                            tot_wav = 100*tot_wav/max_ttt;
                            
                            %%% RELATIVE CONTRIBUTION
                            sum_wav = sum(tot_wav);
                            sum_wea = sum(int_wea);
                            rel_wav = sum_wav/(sum_wav+sum_wea);
                            rel_wea = sum_wea/(sum_wav+sum_wea);
                                                        
                            %%% zeros
                            flag = find(int_wav==0); int_wav(flag)=nan;
                            flag = find(int_wea==0); int_wea(flag)=nan;
                            flag = find(tot_wav==0); tot_wav(flag)=nan;
                            
                            figure()
                            hold on;
                            plot([1:step:step*step_num],tot_wav,'ko-','markerfacecolor',[0.8 0.8 0.8],'markersize',sss);
                            plot([1:step:step*step_num],int_wea,'ko-','markerfacecolor',[1.0 1.0 1.0],'markersize',sss);
                            xlabel('Iteration')
                            text(0.3,0.5,['Wave : Weathering = ', num2str(round(rel_wav*100)),' % : ',  num2str(round(rel_wea*100)), '%'],'Units','Normalized')
                            %text(0.3,0.5,['Weathering contbituion = ',num2str(round(rel_wea*100)),' %'],'Units','Normalized')
                            
                            ylabel('Process dominance relative to maximum dominance [%]')
                            legend('Wave erosion contribution','Weathering contribution')
                            axis([0 step*step_num 0 100])
                            print(gcf,filename,'-dtiff', '-r300')
                            
                            close
                        end
                        
                        
                        %%% OUTPUT SAVE_PROFILE TO txt
                        if(print_prof_to_txt)
                            filename=[output_path, f_name, '.txt'];
                            txt = save_profile;
                            dlmwrite(filename, txt);
                            clear txt
                        end
                    
                    					
                        %%% OUTPUT WAVE-TYPE TO TXT
                        if(print_waty_to_txt)
                            xaxis = loop;
                            clear x_w_type1 x_w_type2 x_w_type3 y_w_type1 y_w_type2 y_w_type3
                            totalx_type1 = zeros(1,maxit*tide);
                            totalx_type2 = zeros(1,maxit*tide);
                            totalx_type3 = zeros(1,maxit*tide);
                            totaly_type1 = zeros(1,maxit*tide);
                            totaly_type2 = zeros(1,maxit*tide);
                            totaly_type3 = zeros(1,maxit*tide);
                            x_w_type1     = zeros(1,maxit*tide);
                            x_w_type2     = zeros(1,maxit*tide);
                            x_w_type3     = zeros(1,maxit*tide);
                            y_w_type1     = zeros(1,maxit*tide);
                            y_w_type2     = zeros(1,maxit*tide);
                            y_w_type3     = zeros(1,maxit*tide);
                            count_type1   = zeros(1,tide);
                            count_type2   = zeros(1,tide);
                            count_type3   = zeros(1,tide);
                    
                            filename=[output_path, f_name, '-wave_type.jpg'];
                    
                            wave_type_tmp 	= zeros(tide,maxit);
                            for wt=1:tide
                                tmp = wave_type(wt,1);
                                tmp_num = 2;
                               count_num = 1;
                                move_num = 1;
                                while ( tmp_num < maxit )
                                    while( tmp_num < maxit && tmp == wave_type(wt, tmp_num))
                                        tmp_num = tmp_num + 1;
                                        count_num = count_num + 1;
                                    end
                                    wave_type_tmp(wt,move_num)=count_num;
                                    move_num = move_num + 1;
                                    count_num = 1;
                                    tmp_num = tmp_num + 1;
                                    if(tmp_num<maxit) tmp = wave_type(wt,tmp_num); end
                                end
                            end
                    
                            %%% TXT
                            %total_type1 = x_w_type1;    total_type1 = vertcat(total_type1, y_w_type1);  
                            %total_type2 = x_w_type2;    total_type2 = vertcat(total_type2, y_w_type2);  
                            %total_type3 = x_w_type3;    total_type3 = vertcat(total_type3, y_w_type3);  
    
        					total_type1 = horzcat(totalx_type1',totaly_type1'); 
            				total_type2 = horzcat(totalx_type2',totaly_type2'); 
                			total_type3 = horzcat(totalx_type3',totaly_type3'); 
                    
                            extension1 = '-wave_type1.txt';
                            extension2 = '-wave_type2.txt';
                            extension3 = '-wave_type3.txt';
                            filename=[output_path, profile, num2str(i_angle), connect, wave_height, connect, material_resistance, extension1];
                            dlmwrite(filename,total_type1);
                            filename=[output_path, profile, num2str(i_angle), connect, wave_height, connect, material_resistance, extension2];
                            dlmwrite(filename,total_type2);
                            filename=[output_path, profile, num2str(i_angle), connect, wave_height, connect, material_resistance, extension3];
                            dlmwrite(filename,total_type3);
                    
                            extension1 = '-wave_type11.txt';
                            extension2 = '-wave_type22.txt';
                            extension3 = '-wave_type33.txt';
                            filename=[output_path, profile, num2str(i_angle), connect, wave_height, connect, material_resistance, extension1];
                            dlmwrite(filename,count_type1);
                            filename=[output_path, profile, num2str(i_angle), connect, wave_height, connect, material_resistance, extension2];
                            dlmwrite(filename,count_type2);
                            filename=[output_path, profile, num2str(i_angle), connect, wave_height, connect, material_resistance, extension3];
                            dlmwrite(filename,count_type3);
    
            				extension1 = 'wave_type.txt';
                			filename=[output_path, profile, num2str(i_angle), connect, wave_height, connect, material_resistance, extension1];
                            dlmwrite(filename,wave_type(:,:,1));
                            extension1 = 'wave_type_tmp.txt';
                            filename=[output_path, profile, num2str(i_angle), connect, wave_height, connect, material_resistance, extension1];
                            dlmwrite(filename,wave_type_tmp);
                    
                        end
                    
                    

                        %%%
                        %%% PROFILE COMPARISON
                        %%%
                        if(print_pcom_to_fig)
					
                            y_line_high(1:x_maxcell)=mwl+ceil(tide/2);
                            y_line_low(1:x_maxcell)=mwl-ceil(tide/2);
                            x_temp=1:x_maxcell;
                    
                            figure();
                            hold on;
                            for ll=1:9
                                plot(save_profile(ll*round(maxit/10),:),[1:y_maxcell] , 'k', 'linewidth',0.5);
                                text(save_profile(ll*round(maxit/10),end),y_maxcell,num2str(ll*round(maxit/10)),'Fontsize',8,'Backgroundcolor',[1 1 1]);
                            end
                            if(10*round(maxit/10) > maxit)      
                                plot(save_profile(ll*round(maxit/10),:),[1:y_maxcell] , 'k', 'linewidth',2);
                                text(save_profile(ll*round(maxit/10),end),y_maxcell,num2str(ll*round(maxit/10)),'Fontsize',8,'Backgroundcolor',[1 1 1]);
                            else
                                plot(save_profile((ll+1)*round(maxit/10),:),[1:y_maxcell] , 'k', 'linewidth',2);
                                text(save_profile((ll+1)*round(maxit/10),end),y_maxcell,num2str((ll+1)*round(maxit/10)),'Fontsize',8,'Backgroundcolor',[1 1 1]);
                            end
                            
                            plot(x_temp, y_line_high, '--r', x_temp, y_line_low, '--r');
                            text(0.1,0.1,['Total Iteration=',num2str(final_it(resi))],'Units','Normalized','Fontsize',10,'Backgroundcolor',[.7 .9 .7]);
                            text(x_maxcell-(x_maxcell/10),mwl+ceil(tide/2),['MHWS'],'Fontsize',10,'Backgroundcolor',[1 1 1]);
                            text(x_maxcell-(x_maxcell/10),mwl-ceil(tide/2),['MLWS'],'Fontsize',10,'Backgroundcolor',[1 1 1]);
                            axis([1 x_maxcell 1 y_maxcell]);
                            xlabel('Horizontal distance  [x0.1 m]')
                            ylabel('Vertical distance  [x0.1 m]')
							
                            filename=[output_path, f_name, '.tiff'];
                            print(gcf,filename,'-dtiff', '-r300') 
                            %saveas(gcf, filename);
                            hold off;
                            close;
                        end
                   
                        
                        
                        
                    end %%% RESISTANCE LOOP
                end % WAVE HEIHGT LOOP
                
            end % WE LOOP
            
            end % WEA SPEED LOOP
            end % WEA LOOP
            
           
        end % PRESSURE DISTRIBUTION LOOP
        
                        
    end % TIDAL RANGE LOOP
    


end

endT = clock();
ntime = etime(endT,startT);
nhour = floor(ntime/60/60);
nmin = floor((ntime-nhour*3600)/60);
nsec = ntime-nhour*3600-nmin*60;
disp(sprintf('%s%s', 'Start time  =  ',datestr(startT,31)));
disp(sprintf('%s%s', 'Finish time  =  ',datestr(endT,31)));
disp(sprintf('%s%d%s%02d%s%04.1f%s', 'Elapsed time  =  ',nhour,' hour  ',nmin,' min  ',nsec,' sec  '));
