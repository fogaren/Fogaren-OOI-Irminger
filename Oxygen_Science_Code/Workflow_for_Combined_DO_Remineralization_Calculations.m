% Loads Hilary's calibrated oxygen products for gliders and WFP 
tic
clearvars; close all

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('glider_griddall_fixedPc1600db.mat')
glider = glidergrid; clear glidergrid;
glider_prs = 1:1000;

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('wfpmerge_output_fixedPc1600db.mat')
wfp_prs = 150:1:2600; % Depths of Hilary's product

%% Calculates start and end of Dremin period for each year at each depth 
% Also calculates maximum winter mixing
cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\Oxygen_Science_Code')
run('Dremin_start_end_from_Blended_MLD_product.m')
%% Flag density outliers and replace with NaN value for each asset
% This is done before combining datasets since salinty/density values are
% not calibrated or corrected using deep isotherm correction for glider
% assets. Allows for removing prho outliers before doing regression during
% Dremin period
cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\Oxygen_Science_Code')
run('Remove_prho_outliers_by_asset.m')

%% Combine and sort oxygen data from gliders and wfp into one data product
% Edit this file to add/remove particular glider data 
% Currently only ignoring data from Glider 5 (Year 3)
cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\Oxygen_Science_Code')
run('Combine_Sort_All_Assets.m')

%% Flag oxygen outliers and replace with NaN value for combined assets
cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\Oxygen_Science_Code')
run('Remove_DO_outliers_combined_asset.m')

%% Create timeseries with one profile every day
% doing this after removing oxygen and density outliers by asset
cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\Oxygen_Science_Code')
run('Retime_Combined_Product_Before_Regression.m')

%% Regression on combined daily retimed oxygen data product
cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\Oxygen_Science_Code')
run('DO_Regression_Dremin_Combined_Assets.m')

%% Determine doxy coverage during Dremin each year and Calculate inventories  
% Should calculate error bar adjustments for Reventiled values and Annually
% sequestered values when I finalize those values 
cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\Oxygen_Science_Code')
run('Calculate_Inventories_with_scaled_errorbars.m')
%% Discussion Points and other
% This code chokes 
cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\Oxygen_Science_Code')
run('Export_bias_from_Deep_isotherm_correction.m')
%% Create Figures 
% cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\Oxygen_Science_Code')
run('JGR_2024_Figures.m') % Clean this up. 
% run('JGR_Schematic.m') % Combine this into Figures and delete 

toc
