% Set up workspace 
clearvars
addpath('G:\My Drive\Matlab_work\BC\Irminger\colab-workspace\CTD_Processing')
addpath('G:\My Drive\Matlab_work\BC\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Sea-Bird-Toolbox')
addpath(genpath('G:\My Drive\Matlab_work\Functions\GSW'))

% Read in calibrated bottle files, Winkler sample values and oxygen files
% processed with default hysteresis correction and user-determined time lag
% correction 
btl_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Bottle_Files\Year9';
cal_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year9\From_Leah';
samp_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year9'; % Winkler file location 
Winkler_file = 'Irminger_Sea-09_AR69-01_CTD_Sampling_Summary_KF.xlsx'; % Winkler file name 

% Use Bottle samples to calculate new SOC (gain) and E terms for CTD data 
CTD_sen = 1; % Use primary or secondary CTD temp and sal

% Read in Winkler file 
cd(samp_dir)
btl = readtable(Winkler_file,'TextType','string');
btl.Winkler_mLL = double(btl.Winkler_mLL);
btl.Discrete_Salinity_psu = double(btl.Discrete_Salinity_psu);

btlsum07 = btl(btl.Cast == 7,:);
btlsum08 = btl(btl.Cast == 8,:); % No Winklers 
% btlsum09 = btl(btl.Cast == 9,:);
btlsum10 = btl(btl.Cast == 10,:);
btlsum11 = btl(btl.Cast == 11,:);
btlsum12 = btl(btl.Cast == 12,:);
btlsum13 = btl(btl.Cast == 13,:);
btlsum14 = btl(btl.Cast == 14,:);
btlsum16 = btl(btl.Cast == 16,:); % No Winklers 
btlsum17 = btl(btl.Cast == 17,:);
btlsum18 = btl(btl.Cast == 18,:);
btlsum19 = btl(btl.Cast == 19,:);
btlsum20 = btl(btl.Cast == 20,:); % No Winklers
btlsum21 = btl(btl.Cast == 21,:);
btlsum22 = btl(btl.Cast == 22,:); % No Winklers

addpath(btl_dir); addpath(cal_dir); 

% [btlsum] = combine_btl_files(leah_btl_file,btl_file,btlsum,CTD_sen)
btlsum07 = combine_btl_files('ar69-01_007.cbot_s','ar69-01_007.csv',btlsum07,CTD_sen);
btlsum08 = combine_btl_files('ar69-01_008.cbot_s','ar69-01_008.csv',btlsum08,CTD_sen);
% btlsum09 =
% combine_btl_files('ar69-01_009.cbot_s','ar69-01_009.csv',btlsum09,CTD_sen);
% % missing bottle file from Leah 
btlsum10 = combine_btl_files('ar69-01_010.cbot_s','ar69-01_010.csv',btlsum10,CTD_sen);
btlsum11 = combine_btl_files('ar69-01_011.cbot_s','ar69-01_011.csv',btlsum11,CTD_sen);
btlsum12 = combine_btl_files('ar69-01_012.cbot_s','ar69-01_012.csv',btlsum12,CTD_sen);
btlsum13 = combine_btl_files('ar69-01_013.cbot_s','ar69-01_013.csv',btlsum13,CTD_sen);
btlsum14 = combine_btl_files('ar69-01_014.cbot_s','ar69-01_014.csv',btlsum14,CTD_sen);
btlsum16 = combine_btl_files('ar69-01_016.cbot_s','ar69-01_016.csv',btlsum16,CTD_sen);
btlsum17 = combine_btl_files('ar69-01_017.cbot_s','ar69-01_017.csv',btlsum17,CTD_sen);
btlsum18 = combine_btl_files('ar69-01_018.cbot_s','ar69-01_018.csv',btlsum18,CTD_sen);
btlsum19 = combine_btl_files('ar69-01_019.cbot_s','ar69-01_019.csv',btlsum19,CTD_sen);
btlsum20 = combine_btl_files('ar69-01_020.cbot_s','ar69-01_020.csv',btlsum20,CTD_sen);
btlsum21 = combine_btl_files('ar69-01_021.cbot_s','ar69-01_021.csv',btlsum21,CTD_sen);
btlsum22 = combine_btl_files('ar69-01_022.cbot_s','ar69-01_022.csv',btlsum22,CTD_sen);

btlsum_yr9 = [btlsum07; btlsum08; btlsum10; btlsum11; btlsum12; btlsum13; btlsum14;...
    btlsum16; btlsum17; btlsum18; btlsum19; btlsum20; btlsum21; btlsum22];

btl_num = unique(btl.Cast); % Find cast numbers with btl samples 
 
% btlsum = [];
% for i = 1:length(btl_num)
%     btlsum{i} = btl(btl.Cast == btl_num(i),:);
% end

% Same Oxygen Sensor for whole cruise 
% Calibration standards from SBE xmlcon file 

cal.SOC = double(4.46780e-001);
cal.VOFFSET = double(-5.08600e-001);
cal.A = double(-5.00190e-003);
cal.B = double(2.51320e-004);
cal.C = double(-3.59380e-006);
cal.E = double(3.60000e-002);
cal.Tau20 = double(1.22000e+000);
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '1960';
cal.OCALDATE = '31-Jul-21';

H = [-0.033, 5000, 1450]; % Default 
%% =======================================================================
% Same oxygen sensor for whole cruise 

% From SBE factory calibration 
Voffset = cal.VOFFSET;
A = cal.A;
B = cal.B; 
C = cal.C;

btlsum = btlsum_yr9; 
% Calculate oxygen solubility calculated using calibrated CTD data
[oxsol_mLL, oxsol_uM] = sbsoxygensol(btlsum.t, btlsum.SP, 'sbs');
btlsum.SBE_oxsol_umolkg = oxsol_uM*1000./btlsum.prho;

Winklers = btlsum.Winkler_umolkg; % umol/kg calculated using calibrated CTD data 

% Model variables 
X = [btlsum.oxy_volts,btlsum.SBE_oxsol_umolkg,btlsum.t,btlsum.prs];

% SBE functional form 
modelfun = @(b,x)(b(1)*(x(:,1) + Voffset)).*x(:,2)...
    .*(1 + A*x(:,3) + B*x(:,3).^2 + C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0 = [cal.SOC 0]; % Starting values for coefficient iterations 

%Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
%functional form using all Winklers 
mdl1 = fitnlm(X,Winklers,modelfun,beta0)

figure
boxplot(mdl1.Residuals.Raw)
ylabel('DO Residuals, Winkler - NLMR output (\mumol/kg), it = 1')

figure
histfit(mdl1.Residuals.Raw)
title('SOC_k Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,'median') == 1);
mdl2 = fitnlm(X,Winklers,modelfun,beta0,'Exclude',Winkler_outliers1)

figure
histfit(mdl2.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl2.Residuals.raw,'median') == 1);
Winkler_outliers2 = [ind; Winkler_outliers1];
% Exclude outliers from NLMR model 
mdl3 = fitnlm(X,Winklers,modelfun,beta0,'Exclude',Winkler_outliers2)

figure
histfit(mdl3.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl3.Residuals.raw,'median') == 1);
Winkler_outliers3 = [ind; Winkler_outliers2];
% Exclude outliers from NLMR model 
mdl4 = fitnlm(X,Winklers,modelfun,beta0,'Exclude',Winkler_outliers3)

figure
histfit(mdl4.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl4.Residuals.raw,'median') == 1);
Winkler_outliers4 = [ind; Winkler_outliers3];
% Exclude outliers from NLMR model 
mdl5 = fitnlm(X,Winklers,modelfun,beta0,'Exclude',Winkler_outliers4)

figure
histfit(mdl5.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 6 
ind = find(isoutlier(mdl5.Residuals.raw,'median') == 1);
Winkler_outliers5 = [ind; Winkler_outliers4];
% Exclude outliers from NLMR model 
mdl6 = fitnlm(X,Winklers,modelfun,beta0,'Exclude',Winkler_outliers5)

figure
histfit(mdl6.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 6')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 7 
ind = find(isoutlier(mdl6.Residuals.raw,'median') == 1);
Winkler_outliers6 = [ind; Winkler_outliers5];
% Exclude outliers from NLMR model 
mdl7 = fitnlm(X,Winklers,modelfun,beta0,'Exclude',Winkler_outliers6)

figure
histfit(mdl7.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 7')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
%%
%Plot residuals versus pressure, time, station, DO concentration with outliers removed   
mdlcal = mdl7;
cal.Winkler_outliers = Winkler_outliers6;

cal.SOCcalc = mdlcal.Coefficients.Estimate(1);
cal.Ecalc = mdlcal.Coefficients.Estimate(2);

figure
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum.prs, mdlcal.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number 
subplot(2,2,2)
plot(datenum(btlsum.Date) - min(datenum(btlsum.Date)), mdlcal.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel(['Days since ' datestr(min(datenum(btlsum.Date)))])
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum.t, mdlcal.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum.Winkler_umolkg, mdlcal.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Winkler (\mumol/kg)')
grid on
sgtitle('Irminger Year 9: SOC_k')
%%
% Use calculated E term to look at drift of SOC in time and by cast number 
Tempcorr = 1 + A*btlsum.t + B*btlsum.t.^2 + C*btlsum.t.^3;
Prescorr = exp(cal.Ecalc*btlsum.prs./(btlsum.t + 273.15));

% Group SOC calculations by cast number 
cn = unique(btlsum.Cast(~isnan(btlsum.Winkler_umolkg)));
% Remove outliers from Winklers 
Winkler_umolkg_wout_outliers = Winklers;
Winkler_umolkg_wout_outliers(cal.Winkler_outliers) = NaN;

% Preallocate arrays 
driftdt = NaN(1,length(cn));
SOCdt = NaN(1,length(cn));
SOCstd = NaN(1,length(cn));

% Calculate SOC for each Winkler sample 
SOCcalc = Winkler_umolkg_wout_outliers...
    ./(Tempcorr.*Prescorr.*btlsum.SBE_oxsol_umolkg.*(btlsum.oxy_volts+Voffset));

% calculate mean time, mean SOC, and std of SOC by cast number  
for i = 1:length(cn)
    driftdt(i) = nanmean(datenum(btlsum.Date(btlsum.Cast == cn(i))));
    SOCdt(i) = nanmean(SOCcalc(btlsum.Cast == cn(i)));
    SOCstd(i) = nanstd(SOCcalc(btlsum.Cast == cn(i)));
end

figure
subplot(1,2,1)
errorbar(cn,SOCdt,SOCstd,'o')
ylabel('Calculated SOC')
grid on
xlabel('By Cast Number')
title('By Cast')
sgtitle('Irminger 9: SOC Drift')

subplot(1,2,2)
errorbar(driftdt,SOCdt,SOCstd,'o')
ylabel('Calculated SOC')
datetick
grid on
title('By Time')

% Calculate linear drift of SOC in time using cast number or time 

dtx = driftdt - datenum(btlsum.Date(1)); % Days since start of cruise

% Calculate linear drift of SOC in time using cast number or time 
SOClm_cn = fitlm(cn,SOCdt) % By cast number 
SOClm_dt = fitlm(dtx,SOCdt) % By days of cruise 
b_cn = SOClm_cn.Coefficients.Estimate;
b_dt = SOClm_dt.Coefficients.Estimate;

figure
subplot(1,2,1)
plot(SOClm_cn)
ylabel('SOC Calculated by Cast')
xlabel('Cast number')
grid on
text(min(cn)+1,max(SOCdt)+0.0005,{['SOC = ' num2str(b_cn(1),6) ' + ' num2str(b_cn(2)) '*cast number' ],...
    ['R-squared = ' num2str(SOClm_cn.Rsquared.Ordinary)]})
title('By Cast Number')
legend('Location','SE')

subplot(1,2,2)
plot(SOClm_dt)
ylabel('SOC Calculated by Cast')
xlabel(['Days since ' datestr(min(datenum(btlsum.Date)))])
grid on
text(min(dtx)+1,max(SOCdt)+0.0005,{['SOC = ' num2str(b_dt(1),6) ' + ' num2str(b_dt(2)) '*time (days)' ],...
    ['R-squared = ' num2str(SOClm_dt.Rsquared.Ordinary)]})
title('By time (days)')
legend('Location','SE')
sgtitle('Irminger 9: SOC drift')
%% Calculate drift with variable SOC with time 
dt = datenum(btlsum.Date) - datenum(btlsum.Date(1)); % minus first cast time
X_dt = [btlsum.oxy_volts,btlsum.SBE_oxsol_umolkg,btlsum.t,btlsum.prs,dt];

% SBE functional form with SOC as a function of station 
modelfun_dt = @(b,x)((b(3)*x(:,5) + b(1)).*(x(:,1) + Voffset)).*x(:,2)...
    .*(1 + A*x(:,3) + B*x(:,3).^2 + C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0_dt = [cal.SOC 0 0]; % Starting values for coefficient iterations 

mdl_dt1 = fitnlm(X_dt,Winklers,modelfun_dt,beta0_dt)

figure
boxplot(mdl_dt1.Residuals.Raw)
ylabel('DO Residuals, Winkler - NLMR output (\mumol/kg), it = 1')

figure
histfit(mdl_dt1.Residuals.Raw)
title('SOC_d_t Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR_d_t output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1_dt = find(isoutlier(mdl_dt1.Residuals.Raw,'median') == 1);
mdl_dt2 = fitnlm(X_dt,Winklers,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers1_dt)

figure
histfit(mdl_dt2.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl_dt2.Residuals.raw,'median') == 1);
Winkler_outliers2_dt = [ind; Winkler_outliers1_dt];
% Exclude outliers from NLMR model 
mdl_dt3 = fitnlm(X_dt,Winklers,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers2_dt)

figure
histfit(mdl_dt3.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl_dt3.Residuals.raw,'median') == 1);
Winkler_outliers3_dt = [ind; Winkler_outliers2_dt];
% Exclude outliers from NLMR model 
mdl_dt4 = fitnlm(X_dt,Winklers,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers3_dt)

figure
histfit(mdl_dt4.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl_dt4.Residuals.raw,'median') == 1);
Winkler_outliers4_dt = [ind; Winkler_outliers3_dt];
% Exclude outliers from NLMR model 
mdl_dt5 = fitnlm(X_dt,Winklers,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers4_dt)

figure
histfit(mdl_dt5.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
%%
mdlcal_dt = mdl_dt5;
% cal for SOC_dt 
cal.Winkler_outliers_dt = Winkler_outliers4_dt;
cal.SOCcalc_dt = mdlcal_dt.Coefficients.Estimate(1);
cal.Ecalc_dt = mdlcal_dt.Coefficients.Estimate(2);
cal.SOCrate_dt = mdlcal_dt.Coefficients.Estimate(3);

figure
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum.prs, mdlcal_dt.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number 
subplot(2,2,2)
plot(datenum(btlsum.Date) - min(datenum(btlsum.Date)), mdlcal_dt.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel(['Days since ' datestr(min(datenum(btlsum.Date)))])
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum.t, mdlcal_dt.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum.Winkler_umolkg, mdlcal_dt.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Winkler (\mumol/kg)')
grid on
sgtitle('Irminger Year 9: SOC_d_t')
%% Calculate SOC that varies by station 

X_cn = [btlsum.oxy_volts,btlsum.SBE_oxsol_umolkg,btlsum.t,btlsum.prs,btlsum.Cast];

% SBE functional form with SOC as a function of station 
modelfun_cn = @(b,x)((b(3)*x(:,5) + b(1)).*(x(:,1) + Voffset)).*x(:,2)...
    .*(1 + A*x(:,3) + B*x(:,3).^2 + C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0_cn = [cal.SOC 0 0]; % Starting values for coefficient iterations 

mdl_cn1 = fitnlm(X_cn,Winklers,modelfun_cn,beta0_cn)

figure
histfit(mdl_cn1.Residuals.Raw)
title('SOC_c_n Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1_cn = find(isoutlier(mdl_cn1.Residuals.Raw,'median') == 1);
mdl_cn2 = fitnlm(X_cn,Winklers,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers1_cn)

figure
histfit(mdl_cn2.Residuals.Raw)
title('SOC_c_n Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl_cn2.Residuals.raw,'median') == 1);
Winkler_outliers2_cn = [ind; Winkler_outliers1_cn];
% Exclude outliers from NLMR model 
mdl_cn3 = fitnlm(X_cn,Winklers,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers2_cn)

figure
histfit(mdl_cn3.Residuals.Raw)
title('SOC_c_n Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl_cn3.Residuals.raw,'median') == 1);
Winkler_outliers3_cn = [ind; Winkler_outliers2_cn];
% Exclude outliers from NLMR model 
mdl_cn4 = fitnlm(X_cn,Winklers,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers3_cn)

figure
histfit(mdl_cn4.Residuals.Raw)
title('SOC_c_n Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl_cn4.Residuals.raw,'median') == 1);
Winkler_outliers4_cn = [ind; Winkler_outliers3_cn];
% Exclude outliers from NLMR model 
mdl_cn5 = fitnlm(X_cn,Winklers,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers4_cn)

figure
histfit(mdl_cn5.Residuals.Raw)
title('SOC_c_n Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
%%
mdlcal_cn = mdl_cn5;
cal.Winkler_outliers_cn = Winkler_outliers4_cn;
cal.SOCcalc_cn = mdlcal_cn.Coefficients.Estimate(1);
cal.Ecalc_cn = mdlcal_cn.Coefficients.Estimate(2);
cal.SOCrate_cn = mdlcal_cn.Coefficients.Estimate(3);

figure
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum.prs, mdlcal_cn.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number 
subplot(2,2,2)
plot(datenum(btlsum.Date) - min(datenum(btlsum.Date)), mdlcal_cn.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel(['Days since ' datestr(min(datenum(btlsum.Date)))])
grid on

%Plot residuals versus temperature cal
subplot(2,2,3)
plot(btlsum.t, mdlcal_cn.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum.Winkler_umolkg, mdlcal_cn.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Winkler (\mumol/kg)')
grid on
sgtitle('Irminger Year 9: SOC_c_n')

%%

clear btl btl_dir btlsum 
cd(samp_dir)
save Year9_DOcal.mat btl* cal mdlcal
%%
function [btlsum] = combine_btl_files(leah_btl_file,btl_file,btlsum,CTD_sen)

    % Format structure for conversion to table and convert to table 
    leah_btl = readtable(leah_btl_file,'FileType','text','TextType','string');
    if width(leah_btl) == 14
        leah_btl.Properties.VariableNames = {'Bottle','prs','t901','t902','th168','th268','sal1','sal2','CTDoxy_mLL_nohyst','CTDoxy_umolkg_nohyst','flur_mgm3','tran','Meas_SAL','QUAL'};
    else
        leah_btl.Properties.VariableNames = {'Bottle','prs','t901','t902','th168','th268','sal1','sal2','CTDoxy_mLL_nohyst','flur_mgm3','tran','Meas_SAL','QUAL'};
    end
    leah_btl.Meas_SAL(leah_btl.Meas_SAL == -9) = NaN; % replaces no data flag with NaN
    
    % Format structure for conversion to table and convert to table 
    btl = readtable(btl_file,'TextType','string');
    vars = {'Bottle','Date','PrDM','DepSM','Latitude','Longitude','Sbeox0V'};
    btl = btl(:,vars);
    btl.Properties.VariableNames = {'Bottle','Date','PrDM','depth','lat','lon','oxy_volts'};
    btl.CTDcal(:) = {'True'};
    btl.CTDcal = string(btl.CTDcal);
    btl.CTDsen(:) = CTD_sen;
    
    % Combine tables by Bottle variable 
    btlsum0 = join(leah_btl,btl,'Keys','Bottle');
    btlsum = join(btlsum0,btlsum,'Keys','Bottle');  

    if height(btlsum) ~= 1
        btlsum.temp1 = btlsum.t901; btlsum.temp2 = btlsum.t902;
    
        % Decide if using primary or secondary CTD sensor for temp and sal
        if CTD_sen == 1 % primary sensor (use unless something wrong with data)
            btlsum.t = btlsum.temp1; 
            btlsum.SP = btlsum.sal1; 
        end
        
        if CTD_sen == 2 % secondary sensor (use if primary sensor bad)
            btlsum.t = btlsum.temp2; 
            btlsum.SP = btlsum.sal2; 
        end    
        

        btlsum.CTD_sen = ones(length(btlsum.prs),1)*CTD_sen; 
        btlsum.SA = gsw_SA_from_SP(btlsum.SP,btlsum.prs,btlsum.lon,btlsum.lat);
        btlsum.CT = gsw_CT_from_t(btlsum.SA,btlsum.t,btlsum.prs);
        btlsum.pt = gsw_pt_from_CT(btlsum.SA,btlsum.CT); 
        btlsum.GSW_oxsol_umolkg = gsw_O2sol(btlsum.SA,btlsum.CT,btlsum.prs,btlsum.lon,btlsum.lat);
        btlsum.rho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,btlsum.prs); % in situ density
        btlsum.prho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,0); % potential density with ref == surf
        btlsum.sigma0 = gsw_sigma0_CT_exact(btlsum.SA,btlsum.CT); % btlsum.prho - 1000 = btlsum.sigma0
        btlsum.Winkler_umolkg = btlsum.Winkler_mLL*1000*44.661./btlsum.prho; % uses potential density 
        [~, oxsol_uM] = sbsoxygensol(btlsum.t, btlsum.SP, 'sbs');
        btlsum.SBE_oxsol_umolkg = oxsol_uM*1000./btlsum.prho;
    
        % Reorder variables and remove unnecessary ones
        btlvars = {'Bottle','Date','prs','depth','lat','lon','temp1','temp2','sal1','sal2','Discrete_Salinity_psu','Cruise','Asset','Cast','CTDcal',...
        'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','Winkler_mLL','Winkler_umolkg','GSW_oxsol_umolkg','SBE_oxsol_umolkg'};
        btlsum = btlsum(:,btlvars);
    end
        
end

