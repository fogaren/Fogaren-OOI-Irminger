clearvars
cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Processed')
load Year1_Processed_KF.mat
load Year2_Processed_KF.mat
load Year3_Processed_KF.mat
load Year4_Processed_KF.mat
load Year5_Processed_KF.mat
load Year6_Processed_KF.mat
load Year7_Processed_KF.mat
load Year8_Processed_KF.mat
load Year9_Processed_KF.mat

%% Creating nested structure by year 
btl_num{1} = btl_num_yr1;
btl_num{2} = btl_num_yr2;
btl_num{3} = btl_num_yr3;
btl_num{4} = btl_num_yr4;
btl_num{5} = btl_num_yr5;
btl_num{6} = btl_num_yr6;
btl_num{7} = [];
btl_num{8} = btl_num_yr8;
btl_num{9} = btl_num_yr9;

cast_num{1} = cast_num_yr1;
cast_num{2} = cast_num_yr2;
cast_num{3} = cast_num_yr3;
cast_num{4} = cast_num_yr4;
cast_num{5} = cast_num_yr5;
cast_num{6} = cast_num_yr6;
cast_num{7} = cast_num_yr7;
cast_num{8} = cast_num_yr8;
cast_num{9} = cast_num_yr9;

btlsum{1} = btlsum_yr1;
btlsum{2} = btlsum_yr2;
btlsum{3} = btlsum_yr3;
btlsum{4} = btlsum_yr4;
btlsum{5} = btlsum_yr5;
btlsum{6} = btlsum_yr6;
btlsum{7} = [];
btlsum{8} = btlsum_yr8;
btlsum{9} = btlsum_yr9;

downcasts{1} = downcasts_yr1;
downcasts{2} = downcasts_yr2;
downcasts{3} = downcasts_yr3;
downcasts{4} = downcasts_yr4;
downcasts{5} = downcasts_yr5;
downcasts{6} = downcasts_yr6;
downcasts{7} = downcasts_yr7;
downcasts{8} = downcasts_yr8;
downcasts{9} = downcasts_yr9;

upcasts{1} = upcasts_yr1;
upcasts{2} = upcasts_yr2;
upcasts{3} = upcasts_yr3;
upcasts{4} = upcasts_yr4;
upcasts{5} = upcasts_yr5;
upcasts{6} = upcasts_yr6;
upcasts{7} = upcasts_yr7;
upcasts{8} = upcasts_yr8;
upcasts{9} = upcasts_yr9;

% save AllYears_Processed_KF.mat upcasts downcasts btlsum btl_num cast_num