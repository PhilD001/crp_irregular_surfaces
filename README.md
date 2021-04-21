## Continuous relative phase analysis for gait on irregular surfaces
This repository contains code associated with the following manuscript:

P. Ippersiel, S.M. Robbins, P.C. Dixon. Lower-limb coordination and variability during gait: The effects of age and walking surface,
Gait & Posture, 85, 2021, 251-257. https://doi.org/10.1016/j.gaitpost.2021.02.009.

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


