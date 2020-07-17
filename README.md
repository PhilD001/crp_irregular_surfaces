# Continuous relative phase analysis for gait on irregular surfaces
This repository contains code associated with the manuscript entitled:
"Lower-limb coordination and variability during gait: The effects of age and walking surface." 
by P Ippersiel, SM Robbins, PC Dixon


## CODE

### Requirements
Code must be run in Matlab (The Mathworks, Inc. Natick, USA). 
All tests performed in Matlab 2020a under Mac OS 10.15.5.


### Steps (How to run)
1. Dowload or clone the repository to your local computer
2. Open Matlab and use the set path tool to add the root folder ``Code`` 
and all subdirectories to the working path (Set Path --> Add with Subfolders)
3. type ``crp_irregular_surfaces_process.m`` in the command line

### What happens
The function ``crp_irregular_surfaces_process.m`` will :
1. Copy the raw data in the folder ``Data\raw`` to ``Data\processed``
2. Compute continuous relative phase metrics (MARP and DP) as described in the paper
3. Extract metrics to a spreadsheet located in ``Statistics\eventval.xls``

## DATA

### Details
Data contain three-dimesional lower-limb kinematic channels (hip, knee, ankle) computed from markers placed according to the plug-in gait marker set. 

### Format
Data are saved in biomechZoo format (.zoo). Essentially, these files are structured arrays saved as a mat files with a renamed extension. See the biomechZoo paper for more details: "biomechZoo: An open-source toolbox for the processing, analysis, and visualization of biomechanical movement data" by Dixon PC, Loh JJ, Michaud-Paquette Y, Pearsall DJ. Computer Methods and Programs in Biomedicine. March 2017. Volume 140. pp.1-10. 
0.1016/j.cmpb.2016.11.007 

### Statistics
This folder contains the SPSS syntax sheet and dataset. This folder will also contain the extracted data after processing (see Code above). 

### Manuscript
Contains pre peer-reviewed version of the manuscript
