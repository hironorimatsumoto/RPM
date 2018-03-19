# RPM
- Code to model the long-term evolution of rocky cross-shore profiles.  
- This software is released under the MIT License, see LICENSE.txt.
- This folder contains the source code for RPM, which stands for Rocky Profile Model. It is a numerical model for the evolution of rocky cross-shore profiles.
- The model can simulate the evolution of a range of cross-shore profile geometries, emerging from the morphodynamic interactions between shore morphologies and rocky shore processes. 
- The code consists of the main code of either “rpm_v0.m”, “rpm_v1.m”, or “rpm_v2.m”, and sub-codes locating under “Source Develop”. These codes were developed by Matsumoto et al. (2016a, 2016b), and further extended based on “rpm_v0.m” (Table 1).　　
　　
　　
![Table 1](https://github.com/hironorimatsumoto/web-image/blob/master/Clipboard01.jpg)　　
　　
　　
- This code is run on Matlab (tested on Matlab 2013a on Windows).
- Please cite the following papers when using or referring to the model:  
  - Matsumoto, H., Dickson, M.E., Kench, P.S., 2016a. An exploratory numerical model of rocky shore profile evolution. Geomorphology 268, 98-109. DOI: 10.1016/j.geomorph.2016.05.017  
  - Matsumoto, H., Dickson, M.E., Kench, P.S., 2016b. Modelling the development of varied shore profile geometry on rocky coasts. Journal of Coastal Research, 75(sp1), 597-601. DOI: 10.2112/SI75-120.1　　
　　
　　
# GETTING STARTED 
- Once you downloaded the main code (either “rpm_v0.m”, “rpm_v1.m”, or “rpm_v2.m”) and the whole subdirectory (“Source Develop”), you can run the model by executing the main on Matlab. Of note, the subdirectory needs to be located at the same directory where the main code locates.
- The program immediately asks you to set parameter values (Table 2), as a command line input.  The users are encouraged to use the recommended values, as these values were tested by author (e.g. Matsumoto et al., 2016a, 2016b).　　
　　
  
![Table 2](https://github.com/hironorimatsumoto/web-image/blob/master/Clipboard02.jpg)　　
　　
  
![Figure 1](https://github.com/hironorimatsumoto/web-image/blob/master/Clipboard03.jpg)　　
　　
  
- Other parameters are set as follow (Table 3). See also the Matsumoto et al. (2016a) for detail.
　　
  
![Table 3](https://github.com/hironorimatsumoto/web-image/blob/master/Clipboard04.jpg)　　
　　
　　
# Model output
- The program outputs three files after each simulation in a "Result" directory created automatically under the directory where the main code and the subdirectory locate (Table 4).
　　
  
![Table 4](https://github.com/hironorimatsumoto/web-image/blob/master/Clipboard05.jpg)　　
　　
  
- The output files are named with a prefix "ZZZ", which shows values of IPA, MTR, WAE, WEC, FW and FR (see Table 2).
