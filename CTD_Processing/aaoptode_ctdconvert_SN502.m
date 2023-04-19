%% Code to process Aanderaa oxygen optode data integrated into the CTD
% Prepared by H. Palevsky, based on code used for OOI Irminger 6, Aug. 2019

%% INPUT
% volts: raw optode output from CTD in volts
% tempc: temperature (deg C) from CTD
% salin: salinity from CTD
% press: pressure from CTD

%THESE COEFFICIENTS ARE DIFFERENT FOR EACH OPTODE - they are found on the
%calibration certificate sheet
%You will need to update for specific sensor used - this is for SN502
%You should also check the salinity setting for the sensor - if it is
%something other than zero, the final line of this script will need to be
%modified
% foilcoeff = [2.82567E-3 1.20716E-4 2.4593E-6 2.30757E2 -3.09502E-1 -5.60627E1 4.5615E0];
% conccoeff = [-1.28596 1.039998];
foilcoeff = [2.798512E-03       1.179460E-04    2.512907E-06    2.262806E+02    -3.570254E-01   -6.104725E+01   4.558537E+00];
conccoeff = [0.000000E+00 1.160000E+00];

%% Check of calphase conversion with factory calibration data on calsheet
% Optional section to check that calculations match those shown on the
% calsheet
%Values from factory 2-point calibration
% phasereading_tests = [33.01 60.96]; %ENTER THESE VALUES FOR EACH SENSOR
% T_tests = [9.96 22.36]; %ENTER THESE VALUES FOR EACH SENSOR
% O2sat_tests = gsw_O2sol_SP_pt([0 0],T_tests); %calculates air-saturated O2
% 
% %Check values from 2-point calibration
% [optode_uM, optode_umolkg] = aaoptode_sternvolmer(foilcoeff, phasereading_tests, T_tests, [0 0], [0 0]);

%% Coefficients for processing data from Aanderaa optode
%Coefficients for converting from voltage to calphase
A = 10; B = 12; %note that this should be the same for all optodes
calphase = B.*volts + A; 

%% Read data in from Excel compilation of CTD casts
[optode_uM, ~] = aaoptode_sternvolmer(foilcoeff, calphase, tempc, salin, press);
optode_uM = conccoeff(1) + conccoeff(2).*optode_uM;
O2corr = aaoptode_salpresscorr(optode_uM, tempc, salin, press, 0);
