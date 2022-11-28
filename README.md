# YTHDF2-Analysis   
This repository is for circularity analysis and single particle MSD analysis of wonkicholab.  
Site for wonkicholab: _https://www.wonkicholab.com/_  
Codes are optimized for wonkicholab, so you need to modify the code for use.  
The codes are run on the MATLAB (R2021b): _https://matlab.mathworks.com/_  
Just like .m file, you can just run the file by type code file's name on the terminal of matlab.
* * *

### **Circularity_analysis_CYS.M**  
From the clusters using DBSCAN, we investigated the circularity of each cluster. 
Based on the image of aggresome, this code defines its boundary by finding disk-shaped structure.  
The boundary is converted into (x,y) coordinates to calculated its perimeter and circularity by using ‘roundness metric’.  
The output will display the image with detected boundary of the structure and measured circularity.  
This computational analysis will take less than 1 minute for each image.  
    
### **Alpha_D_MSD_analysis_GHK.m**  
From the single particles' tracks using ImageJ TrackMate plug-in, we investigated the MSD, diffusion coefficient and alpha values.  
Particle trajectories in XML file format from ImageJ TrackMate plugin are used for analyzing MSD, D value (diffusion coefficient), and alpha value of each track.  
(x,y) coordinates recordered from each timepoint/frame is used for the calculations of which are based on ‘msdanalyzer’ code from Tinevez group; _Jean-Yves Tinevez (2022). Mean square displacement analysis of particles trajectories (https://github.com/tinevez/msdanalyzer), GitHub._  
Exceptionally, initial and final (x,y) coordinates are used for finding the displacement of each track.  
Each output will be saved in xlsx format.  
This computational analysis will take less than 1 minute for each dataset.  
  
### **Demo data**  
  This folder includes example datasets to demo each code and expected results.
  
  
  
* * *
### Version info    
Operating System: Microsoft Windows 10 Pro Version 10.0   
MATLAB                                                Version 9.11        (R2021b)  
Computer Vision Toolbox                               Version 10.1        (R2021b)  
Curve Fitting Toolbox                                 Version 3.6         (R2021b)  
Image Processing Toolbox                              Version 11.4        (R2021b)  
Statistics and Machine Learning Toolbox               Version 12.2        (R2021b)  
  
###### Latest update: 22.11.26
