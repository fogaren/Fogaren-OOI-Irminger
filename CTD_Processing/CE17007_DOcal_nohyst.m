% Set up workspace 
clearvars; close all
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
addpath(genpath('G:\My Drive\Matlab_work\Github\GSW-Matlab'))
addpath(genpath('G:\My Drive\Matlab_work\Github\cmocean'))


% Read in calibrated bottle files, Winkler sample values and oxygen files
% processed with default hysteresis correction and user-determined time lag
% correction 
btl_dir = 'C:\Users\fogaren\Desktop\CE17007\SBE-profile-data\SBE-profile-data';
cal_dir = 'C:\Users\fogaren\Desktop\CE17007\SBE-profile-data\from_leah';
samp_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Calibration_Comparison\Bottle_Sample_Data'; % Winkler file location 
Winkler_file = 'CE17007_Bottle_Data_with_Metadata.xlsx'; % Winkler file name 
filesave = 0; % filesave == 1, save calibration output as mat file

% Use Bottle samples to calculate new SOC (gain) and E terms for CTD data 
CTD_sen = 1; % Use primary or secondary CTD temp and sal

% Read in Winkler file 
cd(samp_dir)
Winklers = readtable(Winkler_file,'TextType','string');
Winklers.Station = double(strrep(Winklers.Cast,'CE17007_',''));
% Winklers.Date = datenum(Winklers.DateAndTime);
Winkler_data = table;
% Winkler_data.Date = Winklers.Date;
Winkler_data.Cast = Winklers.Station;
Winkler_data.Bottle = Winklers.Niskin;
Winkler_data.Winkler_umolL = Winklers.WinklerDOUmol_L;
% Winkler_data.Discrete_salinity = Winklers.BenchSalinity;
Winklers = Winkler_data; clear Winkler_data

%% Use calibrated salinity data for this cruise 
cd(cal_dir)
btlfiles = ls('*.cbot_s'); % List of Leah's calibrated bottle files 
btlcasts = str2num(btlfiles(:,9:11)); % Pulls out cast numbers that have bottle files 

cd(btl_dir)
mybtlfiles = ls('*.btl'); % List of my processed bottle files 
mybtlcasts = str2num(mybtlfiles(:,9:11)); % Pulls out cast numbers that have bottle files

% Make sure that there is a Leah bottle file for each of my bottle files 
if mybtlcasts == btlcasts 
    disp('Btl Casts Line Up')
    addpath(cal_dir)
    addpath(btl_dir)
    
else
    disp('Caution: Issue with Btl Cast Numbers!')
end
%%

btlsum = [];
for j = 1:length(cast_num)
    btlsum{cast_num(j)} = readSBSbtl(fn(j,:));
    btlsum{cast_num(j)}.Cast(:) = cast_num(j);
end
par23_btlsum = btlsum; 

par23_btlsum_tbl = [];
for j = 1:length(cast_num)
    par23_btlsum_tbl = [par23_btlsum_tbl; btlsum{cast_num(j)}]; 
end 
%%

CTD_sen = 1; 
btlsum = []; % Indexes by cast number leah_btl{5} == cast 5; 
% Combine files and calculate sea water properties for CTD sensor number 
for j = 1:height(btlcasts) % Number of bottle summary files 
    btlsum{btlcasts(j)} = combine_btl_files(btlfiles(j,:),mybtlfiles(j,:),Winklers(Winklers.Cast == btlcasts(j),:),CTD_sen) ;
end

% Pull all bottle files and create one large table 
btlsum_tbl = [];
for j = 1:length(btlsum)
    btlsum_tbl = [btlsum_tbl; btlsum{j}];
end
btl_num = unique(btlsum_tbl.Cast);
%%
% Only calibrating oxygen data from cast 4 on 
% Calibration standards from SBE xmlcon file 
% KF 10/28/24
cal.SOC = double(5.51830e-001);
cal.VOFFSET = double(-5.09300e-001);
cal.A = double(-2.51880e-003);
cal.B = double(1.27240e-004);
cal.C = double(-1.97350e-006);
cal.E = double(3.60000e-002);
cal.Tau20 = double(1.34000e+000);
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '1416';
cal.OCALDATE = '18-Mar-2017';
cal0 = cal; % for setting sensor cals for each group 

x = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
  .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
  .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));

%% non linear multiple regression with non-averaged OOI Winkler values to calculate E and A terms 
% Oxygen solubility calculated using GSW Toolbox 
% Model variables 

X = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
Winklers_to_use = btlsum_tbl.Winkler_umolkg;

% % SBE functional form solving for SOC, E term and A term
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + b(3)*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));
beta0 = [cal.SOC 0 -1]; % Starting values for coefficient iterations 

% % % SBE functional form solving for all coefficients 
% modelfun = @(b,x)(b(1)*(x(:,1) + b(6))).*x(:,2)...
%     .*(1 + b(3)*x(:,3) + b(4)*x(:,3).^2 + b(5)*x(:,3).^3)...
%     .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));
% beta0 = [cal.SOC 0 -1 -1 -1 -1]; % Starting values for coefficient iterations 

% % % SBE functional form solving for SOC and E term 
% modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
%     .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%     .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));
% beta0 = [cal.SOC 0]; % Starting values for coefficient iterations 

outlier_method = 'median';

%Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
%functional form using all Winklers_umolkg (from calibrated T/S data) 
% Run non linear model fit with all Winkler/CTD oxygen (volts) values
mdl1 = fitnlm(X,Winklers_to_use,modelfun,beta0);

% figure
% histfit(mdl1.Residuals.raw)
% title('SOC_k Residuals with Outliers, it = 1')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,outlier_method) == 1);
mdl2 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers1);

% figure
% histfit(mdl2.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 2')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl2.Residuals.raw,outlier_method) == 1);
Winkler_outliers2 = [ind; Winkler_outliers1];
% Exclude outliers from NLMR model 
mdl3 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers2);

% figure
% histfit(mdl3.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 3')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl3.Residuals.raw,outlier_method) == 1);
Winkler_outliers3 = [ind; Winkler_outliers2];
% Exclude outliers from NLMR model 
mdl4 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers3);

% figure
% histfit(mdl4.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 4')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl4.Residuals.raw,outlier_method) == 1);
Winkler_outliers4 = [ind; Winkler_outliers3];
% Exclude outliers from NLMR model 
mdl5 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers4);

% figure
% histfit(mdl5.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 5')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 6 
ind = find(isoutlier(mdl5.Residuals.raw,outlier_method) == 1);
Winkler_outliers5 = [ind; Winkler_outliers4];
% Exclude outliers from NLMR model 
mdl6 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers5);

% figure
% histfit(mdl6.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 6')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 7 
ind = find(isoutlier(mdl6.Residuals.raw,outlier_method) == 1);
Winkler_outliers6 = [ind; Winkler_outliers5];
% Exclude outliers from NLMR model 
mdl7 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers6)

figure
histfit(mdl7.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 7')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
%%
%Plot residuals versus pressure, time, station, DO concentration with outliers removed   
mdlcal_k = mdl7;
cal.SOCcalc = mdlcal_k.Coefficients.Estimate(1);
cal.Ecalc = mdlcal_k.Coefficients.Estimate(2);
cal.Acalc = mdlcal_k.Coefficients.Estimate(3); 
cal.gain = cal.SOCcalc/cal.SOC;
cal.Winkler_outliers = Winkler_outliers6;
cal.mdlcal_k = mdlcal_k; 
cal_all = cal; 
%%
f = figure(3);
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler_umolkg, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Factory Calibrated CTD-DO (\mumol/kg)')
grid on
sgtitle('CE17007: SOC_k Winklers Whole Cruise')
%%
f = figure;
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, btlsum_tbl.Winkler_umolkg - DOuncorr_umolkg, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - SBE Factory Cal','(\mumol/kg)'})
xlabel('Pressure (db)')
ylim([0 20])
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, btlsum_tbl.Winkler_umolkg - DOuncorr_umolkg, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - SBE Factory Cal','(\mumol/kg)'})
ylim([0 20])
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, btlsum_tbl.Winkler_umolkg - DOuncorr_umolkg, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - SBE Factory Cal','(\mumol/kg)'})
xlabel('Temperature (\circC)')
ylim([0 20])
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler_umolkg, btlsum_tbl.Winkler_umolkg - DOuncorr_umolkg, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - SBE Factory Cal','(\mumol/kg)'})
xlabel('Factory Calibrated CTD-DO (\mumol/kg)')
grid on
ylim([0 20])
sgtitle('CE17007: Factory Calibration')

%% Use calculated E term to look at drift of SOC in time and by cast number 
% equation usually used
% Tempcorr = 1 + cal.A*btlsum_tbl.t + cal.B*btlsum_tbl.t.^2 + cal.C*btlsum_tbl.t.^3;
% Prescorr = exp(cal.Ecalc*btlsum_tbl.prs./(btlsum_tbl.t + 273.15));

% Equation used because A term 
Tempcorr = 1 + cal.Acalc*btlsum_tbl.t + cal.B*btlsum_tbl.t.^2 + cal.C*btlsum_tbl.t.^3;
Prescorr = exp(cal.Ecalc*btlsum_tbl.prs./(btlsum_tbl.t + 273.15));

% Group SOC calculations by cast number 
cn = unique(btlsum_tbl.Cast(~isnan(btlsum_tbl.Winkler_umolkg)));

% Remove outliers from Winklers 
Winkler_umolkg_wout_outliers = btlsum_tbl.Winkler_umolkg; 
Winkler_umolkg_wout_outliers(cal.Winkler_outliers) = NaN;

% Preallocate arrays 
driftdt = []; %NaN(1,length(cn));
SOCdt = []; %NaN(1,length(cn));
SOCstd = []; %NaN(1,length(cn));


% Calculate SOC for each Winkler sample 
SOCcalc = Winkler_umolkg_wout_outliers...
    ./(Tempcorr.*Prescorr.*btlsum_tbl.O2sol_umolkg.*(btlsum_tbl.oxy_volts+cal.VOFFSET));
Cast = btlsum_tbl.Cast; 
Date = btlsum_tbl.Date; 
% calculate mean time, mean SOC, and std of SOC by cast number  
for j = 1:length(cn)
    driftdt(j) = nanmean(datenum(Date(Cast == cn(j))));
    SOCdt(j) = nanmean(SOCcalc(Cast == cn(j)));
    SOCstd(j) = nanstd(SOCcalc(Cast == cn(j)));
end

figure
errorbar(cn,SOCdt,SOCstd,'ok','MarkerFaceColor','k')
ylabel('Calculated SOC')
grid on
xlabel('By Cast Number')
title('By Cast')
sgtitle('AT30-01: SOC Drift')
SOCcnR = min(min(corrcoef([cn SOCdt'],'Rows','complete')))

figure
errorbar(driftdt,SOCdt,SOCstd,'ok','MarkerFaceColor','k')
ylabel('Calculated SOC')
datetick
grid on
title('By Time')
SOCdtR = min(min(corrcoef([driftdt' SOCdt'],'Rows','complete')))
%% Looking at unique calibration for Cast 4

j =4;
cal = cal0; 
X = [btlsum{btlcasts(j)}.oxy_volts,btlsum{btlcasts(j)}.O2sol_umolkg,btlsum{btlcasts(j)}.t,btlsum{btlcasts(j)}.prs];

bad_casts = btlsum{btlcasts(j)}.Cast;
btl_check = btlsum{btlcasts(j)}.Bottle; 
pdens = btlsum{btlcasts(j)}.prho;
Winklers_to_use = btlsum{btlcasts(j)}.Winkler_umolkg;

DOuncorr_umolkg = cal.SOC*(X(:,1) + cal.VOFFSET).*X(:,2)...
     .*(1 + cal.A*X(:,3) + cal.B*X(:,3).^2 + cal.C*X(:,3).^3)...
    .*exp((cal.E*X(:,4))./(X(:,3) + 273.15));

% SBE functional form 
cal.Ecalc = cal_all.Ecalc;
cal.Acalc = cal_all.Acalc; 
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
.*(1 + cal.Acalc*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
.*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));

beta0 = [cal.SOC]; % Starting values for coefficient iterations 

outlier_method = 'median';

%Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
%functional form using all Winklers_umolkg (from calibrated T/S data) 
% Run non linear model fit with all Winkler/CTD oxygen (volts) values
mdl1 = fitnlm(X,Winklers_to_use,modelfun,beta0);

% Find outliers based on median filter it = 2 
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,outlier_method) == 1);
mdl2 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers1);

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl2.Residuals.raw,outlier_method) == 1);
Winkler_outliers2 = [ind; Winkler_outliers1];
% Exclude outliers from NLMR model 
mdl3 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers2);

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl3.Residuals.raw,outlier_method) == 1);
Winkler_outliers3 = [ind; Winkler_outliers2];
% Exclude outliers from NLMR model 
mdl4 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers3);

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl4.Residuals.raw,outlier_method) == 1);
Winkler_outliers4 = [ind; Winkler_outliers3];
% Exclude outliers from NLMR model 
mdl5 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers4);

% Find outliers based on median filter it = 6 
ind = find(isoutlier(mdl5.Residuals.raw,outlier_method) == 1);
Winkler_outliers5 = [ind; Winkler_outliers4];
% Exclude outliers from NLMR model 
mdl6 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers5);

% Find outliers based on median filter it = 7 
ind = find(isoutlier(mdl6.Residuals.raw,outlier_method) == 1);
Winkler_outliers6 = [ind; Winkler_outliers5];
% Exclude outliers from NLMR model 
mdl7 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers6)

%Plot residuals versus pressure, time, station, DO concentration with outliers removed   
mdlcal_k = mdl7;
cal_cast4 = cal;
cal_cast4.SOCcalc = mdlcal_k.Coefficients.Estimate(1);
cal_cast4.gain = cal_cast4.SOCcalc/cal.SOC;
cal_cast4.Winkler_outliers = Winkler_outliers6;
cal_cast4.casts = 4; 
cal_cast4.mdl = mdlcal_k;
cal_cast4.out_NLMR_k = sortrows([bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)],[1 2]);

figure(8)
f = figure;
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum{btlcasts(j)}.prs, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum{btlcasts(j)}.Cast, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum{btlcasts(j)}.t, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum{btlcasts(j)}.Winkler_umolkg, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler Oxygen (\mumol/kg)')
grid on
sgtitle('CE17007: SOC_k Cast 4')

%% Group 1: Stations 1-13 SOC cn, E from Winklers greater than 1000 (cal_deep.Ecalc)
cal = cal0; 
group1 = [5:9, 10, 12:14]; 
good = group1; 
btlsum_tbl = [];
for j = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(j)}];
end

X = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
% Calculate drift with variable SOC with time 
cn = btlsum_tbl.Cast - min(btlsum_tbl.Cast); 

X_cn = [X, cn]; 
    
bad_casts = btlsum_tbl.Cast;
btl_check = btlsum_tbl.Bottle; 
pdens = btlsum_tbl.prho;
Winklers_to_use = btlsum_tbl.Winkler_umolkg;

% SBE functional form with SOC as a function of station 
cal.Ecalc_cn = cal_all.Ecalc;
cal.Acalc_cn = cal_all.Acalc; 
modelfun_cn = @(b,x)((b(2)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.Acalc_cn*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15));

beta0_cn = [cal.SOC 0]; % Starting values for coefficient iterations 

mdl_cn1 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn);

% figure
% histfit(mdl_cn1.Residuals.Raw)
% title('SOC_c_n Residuals with Outliers, it = 1')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1_cn = find(isoutlier(mdl_cn1.Residuals.Raw,'median') == 1);
mdl_cn2 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers1_cn);

% figure
% histfit(mdl_cn2.Residuals.Raw)
% title('SOC_c_n Residuals with Outliers Removed, it = 2')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl_cn2.Residuals.raw,'median') == 1);
Winkler_outliers2_cn = [ind; Winkler_outliers1_cn];
% Exclude outliers from NLMR model 
mdl_cn3 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers2_cn);

% figure
% histfit(mdl_cn3.Residuals.Raw)
% title('SOC_c_n Residuals with Outliers Removed, it = 3')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl_cn3.Residuals.raw,'median') == 1);
Winkler_outliers3_cn = [ind; Winkler_outliers2_cn];
% Exclude outliers from NLMR model 
mdl_cn4 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers3_cn);

% figure
% histfit(mdl_cn4.Residuals.Raw)
% title('SOC_c_n Residuals with Outliers Removed, it = 4')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl_cn4.Residuals.raw,'median') == 1);
Winkler_outliers4_cn = [ind; Winkler_outliers3_cn];
% Exclude outliers from NLMR model 
mdl_cn5 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers4_cn)

figure
histfit(mdl_cn5.Residuals.Raw)
title('SOC_c_n Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

%%
mdlcal_cn = mdl_cn5;
% cal for SOC_dt 
cal.SOCcalc_cn = mdlcal_cn.Coefficients.Estimate(1);
cal.SOCrate_cn = mdlcal_cn.Coefficients.Estimate(2);
cal.gain = cal.SOCcalc_cn/cal.SOC;
cal.Winkler_outliers_cn = Winkler_outliers4_cn(Winkler_outliers4_cn < height(btlsum_tbl));
cal.casts = good;
cal.mdl = mdlcal_cn;
cal.out_NLMR_cn = sortrows([bad_casts(Winkler_outliers4_cn) btl_check(Winkler_outliers4_cn) Winklers_to_use(Winkler_outliers4_cn)],[1 2]);
cal1 = cal;

% % For range of SOC
cal1.SOCcalc_cn % SOC at start 
cal1.SOCcalc_cn/cal1.SOC % gain at start 
(btlsum_tbl.Cast(end) - btlsum_tbl.Cast(1))*cal1.SOCrate_cn + cal1.SOCcalc_cn
(btlsum_tbl.Cast(end) - btlsum_tbl.Cast(1))*cal1.SOCrate_cn + cal1.SOCcalc_cn/cal1.SOC

f = figure(8);
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_cn.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_cn.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_cn.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler_umolkg, mdlcal_cn.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('CE17-007: SOC_c_n Winklers from Group 1')

%% Group 2: Stations 14-29 SOC k, E and A from all casts 
cal = cal0; 
group2 = [20:22,25:28];
good = group2; 
btlsum_tbl = [];
for j = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(j)}];
end

X = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
% Calculate drift with variable SOC with time 
cn = btlsum_tbl.Cast - min(btlsum_tbl.Cast);  

X_cn = [X, cn]; 
    
bad_casts = btlsum_tbl.Cast;
btl_check = btlsum_tbl.Bottle; 
pdens = btlsum_tbl.prho;
Winklers_to_use = btlsum_tbl.Winkler_umolkg;

% SBE functional form with SOC as a function of station 
cal.Ecalc_cn = cal_all.Ecalc;
cal.Acalc_cn = cal_all.Acalc; 
modelfun_cn = @(b,x)((b(2)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.Acalc_cn*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15));

beta0_cn = [cal.SOC 0]; % Starting values for coefficient iterations 

mdl_cn1 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn);

% figure
% histfit(mdl_cn1.Residuals.Raw)
% title('SOC_c_n Residuals with Outliers, it = 1')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1_cn = find(isoutlier(mdl_cn1.Residuals.Raw,'median') == 1);
mdl_cn2 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers1_cn);

% figure
% histfit(mdl_cn2.Residuals.Raw)
% title('SOC_c_n Residuals with Outliers Removed, it = 2')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl_cn2.Residuals.raw,'median') == 1);
Winkler_outliers2_cn = [ind; Winkler_outliers1_cn];
% Exclude outliers from NLMR model 
mdl_cn3 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers2_cn);

% figure
% histfit(mdl_cn3.Residuals.Raw)
% title('SOC_c_n Residuals with Outliers Removed, it = 3')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl_cn3.Residuals.raw,'median') == 1);
Winkler_outliers3_cn = [ind; Winkler_outliers2_cn];
% Exclude outliers from NLMR model 
mdl_cn4 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers3_cn);

% figure
% histfit(mdl_cn4.Residuals.Raw)
% title('SOC_c_n Residuals with Outliers Removed, it = 4')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl_cn4.Residuals.raw,'median') == 1);
Winkler_outliers4_cn = [ind; Winkler_outliers3_cn];
% Exclude outliers from NLMR model 
mdl_cn5 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers4_cn)

figure
histfit(mdl_cn5.Residuals.Raw)
title('SOC_c_n Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

%%
mdlcal_cn = mdl_cn5;
% cal for SOC_dt 
cal.SOCcalc_cn = mdlcal_cn.Coefficients.Estimate(1);
cal.SOCrate_cn = mdlcal_cn.Coefficients.Estimate(2);
cal.gain = cal.SOCcalc_cn/cal.SOC;
cal.Winkler_outliers_cn = Winkler_outliers4_cn(Winkler_outliers4_cn < height(btlsum_tbl));
cal.casts = good;
cal.mdl = mdlcal_cn;
cal.out_NLMR_cn = sortrows([bad_casts(Winkler_outliers4_cn) btl_check(Winkler_outliers4_cn) Winklers_to_use(Winkler_outliers4_cn)],[1 2]);
cal2 = cal;

% % For range of SOC
cal2.SOCcalc_cn % SOC at start 
cal2.SOCcalc_cn/cal2.SOC % gain at start 
(btlsum_tbl.Cast(end) - btlsum_tbl.Cast(1))*cal2.SOCrate_cn + cal2.SOCcalc_cn
(btlsum_tbl.Cast(end) - btlsum_tbl.Cast(1))*cal2.SOCrate_cn + cal2.SOCcalc_cn/cal2.SOC

f = figure;
f.Position = [100 100 840 500];
figure(8)
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_cn.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_cn.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_cn.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler_umolkg, mdlcal_cn.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('CE17007: SOC_c_n Winklers Group 2')

%% Group 3: Stations 29 - 43 SOC cn
cal = cal0; 
group3 = [29,31,33,35,37];
good = group3; 
btlsum_tbl = [];
for j = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(j)}];
end

X = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
% Calculate drift with variable SOC with time 
cn = btlsum_tbl.Cast - min(btlsum_tbl.Cast); 

X_cn = [X, cn]; 
    
bad_casts = btlsum_tbl.Cast;
btl_check = btlsum_tbl.Bottle; 
pdens = btlsum_tbl.prho;
Winklers_to_use = btlsum_tbl.Winkler_umolkg;

% SBE functional form with SOC as a function of station 
cal.Ecalc_cn = cal_all.Ecalc;
cal.Acalc_cn = cal_all.Acalc; 
modelfun_cn = @(b,x)((b(2)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.Acalc_cn*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15));

beta0_cn = [cal.SOC 0]; % Starting values for coefficient iterations 

mdl_cn1 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn);

% figure
% histfit(mdl_cn1.Residuals.Raw)
% title('SOC_c_n Residuals with Outliers, it = 1')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1_cn = find(isoutlier(mdl_cn1.Residuals.Raw,'median') == 1);
mdl_cn2 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers1_cn);

% figure
% histfit(mdl_cn2.Residuals.Raw)
% title('SOC_c_n Residuals with Outliers Removed, it = 2')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl_cn2.Residuals.raw,'median') == 1);
Winkler_outliers2_cn = [ind; Winkler_outliers1_cn];
% Exclude outliers from NLMR model 
mdl_cn3 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers2_cn);

% figure
% histfit(mdl_cn3.Residuals.Raw)
% title('SOC_c_n Residuals with Outliers Removed, it = 3')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl_cn3.Residuals.raw,'median') == 1);
Winkler_outliers3_cn = [ind; Winkler_outliers2_cn];
% Exclude outliers from NLMR model 
mdl_cn4 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers3_cn);

% figure
% histfit(mdl_cn4.Residuals.Raw)
% title('SOC_c_n Residuals with Outliers Removed, it = 4')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl_cn4.Residuals.raw,'median') == 1);
Winkler_outliers4_cn = [ind; Winkler_outliers3_cn];
% Exclude outliers from NLMR model 
mdl_cn5 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers4_cn)

figure
histfit(mdl_cn5.Residuals.Raw)
title('SOC_c_n Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

%%
mdlcal_cn = mdl_cn5;
% cal for SOC_dt 
cal.SOCcalc_cn = mdlcal_cn.Coefficients.Estimate(1);
cal.SOCrate_cn = mdlcal_cn.Coefficients.Estimate(2);
cal.gain = cal.SOCcalc_cn/cal.SOC;
cal.Winkler_outliers_cn = Winkler_outliers4_cn(Winkler_outliers4_cn < height(btlsum_tbl));
cal.casts = good;
cal.mdl = mdlcal_cn;
cal.out_NLMR_cn = sortrows([bad_casts(Winkler_outliers4_cn) btl_check(Winkler_outliers4_cn) Winklers_to_use(Winkler_outliers4_cn)],[1 2]);
cal3 = cal;

% % For range of SOC
cal3.SOCcalc_cn % SOC at start 
cal3.SOCcalc_cn/cal3.SOC % gain at start 
(btlsum_tbl.Cast(end) - btlsum_tbl.Cast(1))*cal3.SOCrate_cn + cal3.SOCcalc_cn
(btlsum_tbl.Cast(end) - btlsum_tbl.Cast(1))*cal3.SOCrate_cn + cal3.SOCcalc_cn/cal3.SOC

f = figure;
f.Position = [100 100 840 500];
figure(8)
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_cn.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_cn.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_cn.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler_umolkg, mdlcal_cn.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('CE17007: SOC_c_n Winklers Group 3')

%% Group 4: Stations 38-43 SOC k, 
cal = cal0; 
group4 = 39:43;
good = group4; 
btlsum_tbl = [];
for j = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(j)}];
end

X = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];

bad_casts = btlsum_tbl.Cast;
btl_check = btlsum_tbl.Bottle; 
pdens = btlsum_tbl.prho;
Winklers_to_use = btlsum_tbl.Winkler_umolkg;

cal.Ecalc = cal_all.Ecalc;
cal.Acalc = cal_all.Acalc; 
% % SBE functional form 
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal_all.Acalc*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal_all.Ecalc*x(:,4))./(x(:,3) + 273.15));

beta0 = [cal.SOC]; % Starting values for coefficient iterations 

outlier_method = 'median';

%Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
%functional form using all Winklers_umolkg (from calibrated T/S data) 
% Run non linear model fit with all Winkler/CTD oxygen (volts) values
mdl1 = fitnlm(X,Winklers_to_use,modelfun,beta0);

% figure
% histfit(mdl1.Residuals.raw)
% title('SOC_k Residuals with Outliers, it = 1')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,outlier_method) == 1);
mdl2 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers1);

% figure
% histfit(mdl2.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 2')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl2.Residuals.raw,outlier_method) == 1);
Winkler_outliers2 = [ind; Winkler_outliers1];
% Exclude outliers from NLMR model 
mdl3 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers2);
% 
% figure
% histfit(mdl3.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 3')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl3.Residuals.raw,outlier_method) == 1);
Winkler_outliers3 = [ind; Winkler_outliers2];
% Exclude outliers from NLMR model 
mdl4 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers3);

% figure
% histfit(mdl4.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 4')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl4.Residuals.raw,outlier_method) == 1);
Winkler_outliers4 = [ind; Winkler_outliers3];
% Exclude outliers from NLMR model 
mdl5 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers4);

% figure
% histfit(mdl5.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 5')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 6 
ind = find(isoutlier(mdl5.Residuals.raw,outlier_method) == 1);
Winkler_outliers5 = [ind; Winkler_outliers4];
% Exclude outliers from NLMR model 
mdl6 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers5);

% figure
% histfit(mdl6.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 6')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 7 
ind = find(isoutlier(mdl6.Residuals.raw,outlier_method) == 1);
Winkler_outliers6 = [ind; Winkler_outliers5];
% Exclude outliers from NLMR model 
mdl7 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers6)

figure
histfit(mdl7.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 7')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
%%
%Plot residuals versus pressure, time, station, DO concentration with outliers removed   
mdlcal_k = mdl7;
cal.SOCcalc = mdlcal_k.Coefficients.Estimate(1);
cal.gain = cal.SOCcalc/cal.SOC;
cal.Winkler_outliers = Winkler_outliers6;
cal.casts = good;
cal.mdl = mdlcal_k;
cal.out_NLMR_k = sortrows([bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)],[1 2]);
cal4 = cal;

f = figure;
f.Position = [100 100 840 500];
figure(8)
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler_umolkg, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Factory Calibrated CTD-DO (\mumol/kg)')
grid on
sgtitle('CE17007: SOC_k Winklers Group 4')

%% Group 5: Stations 44-50 SOC k
cal = cal0; 
group5 = 44:55;
good = group5; 
btlsum_tbl = [];
for j = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(j)}];
end

X = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];

bad_casts = btlsum_tbl.Cast;
btl_check = btlsum_tbl.Bottle; 
pdens = btlsum_tbl.prho;
Winklers_to_use = btlsum_tbl.Winkler_umolkg;

cal.Ecalc = cal_all.Ecalc;
cal.Acalc = cal_all.Acalc; 
% % SBE functional form 
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal_all.Acalc*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal_all.Ecalc*x(:,4))./(x(:,3) + 273.15));

beta0 = [cal.SOC]; % Starting values for coefficient iterations 

outlier_method = 'median';

%Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
%functional form using all Winklers_umolkg (from calibrated T/S data) 
% Run non linear model fit with all Winkler/CTD oxygen (volts) values
mdl1 = fitnlm(X,Winklers_to_use,modelfun,beta0);

% figure
% histfit(mdl1.Residuals.raw)
% title('SOC_k Residuals with Outliers, it = 1')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,outlier_method) == 1);
mdl2 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers1);

% figure
% histfit(mdl2.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 2')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl2.Residuals.raw,outlier_method) == 1);
Winkler_outliers2 = [ind; Winkler_outliers1];
% Exclude outliers from NLMR model 
mdl3 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers2);

% figure
% histfit(mdl3.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 3')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl3.Residuals.raw,outlier_method) == 1);
Winkler_outliers3 = [ind; Winkler_outliers2];
% Exclude outliers from NLMR model 
mdl4 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers3);

% figure
% histfit(mdl4.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 4')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl4.Residuals.raw,outlier_method) == 1);
Winkler_outliers4 = [ind; Winkler_outliers3];
% Exclude outliers from NLMR model 
mdl5 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers4);

% figure
% histfit(mdl5.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 5')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 6 
ind = find(isoutlier(mdl5.Residuals.raw,outlier_method) == 1);
Winkler_outliers5 = [ind; Winkler_outliers4];
% Exclude outliers from NLMR model 
mdl6 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers5);

% figure
% histfit(mdl6.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 6')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 7 
ind = find(isoutlier(mdl6.Residuals.raw,outlier_method) == 1);
Winkler_outliers6 = [ind; Winkler_outliers5];
% Exclude outliers from NLMR model 
mdl7 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers6)

figure
histfit(mdl7.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 7')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
%%
%Plot residuals versus pressure, time, station, DO concentration with outliers removed   
mdlcal_k = mdl7;
cal.SOCcalc = mdlcal_k.Coefficients.Estimate(1);
cal.gain = cal.SOCcalc/cal.SOC;
cal.Winkler_outliers = Winkler_outliers6;
cal.casts = good;
cal.mdl = mdlcal_k;
cal.out_NLMR_k = sortrows([bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)],[1 2]);
cal5 = cal;

f = figure;
f.Position = [100 100 840 500];
figure(8)
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler_umolkg, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Factory Calibrated CTD-DO (\mumol/kg)')
grid on
sgtitle('CE17007: SOC_k Winklers Group 5')
%% Group 6: Stations 56-61 SOC cn
group6 = 56:61; 
cal = cal0; 
good = group6; 
btlsum_tbl = [];
for j = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(j)}];
end
X = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
% Calculate drift with variable SOC with time 
cn = btlsum_tbl.Cast - min(btlsum_tbl.Cast);  

X_cn = [X, cn]; 
    
bad_casts = btlsum_tbl.Cast;
btl_check = btlsum_tbl.Bottle; 
pdens = btlsum_tbl.prho;
Winklers_to_use = btlsum_tbl.Winkler_umolkg;

% SBE functional form with SOC as a function of station 
cal.Ecalc_cn = cal_all.Ecalc;
cal.Acalc_cn = cal_all.Acalc; 
modelfun_cn = @(b,x)((b(2)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.Acalc_cn*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15)); %

beta0_cn = [cal.SOC 0]; % Starting values for coefficient iterations 

mdl_cn1 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn);

% figure
% histfit(mdl_cn1.Residuals.Raw)
% title('SOC_c_n Residuals with Outliers, it = 1')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1_cn = find(isoutlier(mdl_cn1.Residuals.Raw,'median') == 1);
mdl_cn2 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers1_cn);

% figure
% histfit(mdl_cn2.Residuals.Raw)
% title('SOC_c_n Residuals with Outliers Removed, it = 2')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl_cn2.Residuals.raw,'median') == 1);
Winkler_outliers2_cn = [ind; Winkler_outliers1_cn];
% Exclude outliers from NLMR model 
mdl_cn3 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers2_cn);

% figure
% histfit(mdl_cn3.Residuals.Raw)
% title('SOC_c_n Residuals with Outliers Removed, it = 3')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl_cn3.Residuals.raw,'median') == 1);
Winkler_outliers3_cn = [ind; Winkler_outliers2_cn];
% Exclude outliers from NLMR model 
mdl_cn4 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers3_cn);
% 
% figure
% histfit(mdl_cn4.Residuals.Raw)
% title('SOC_c_n Residuals with Outliers Removed, it = 4')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl_cn4.Residuals.raw,'median') == 1);
Winkler_outliers4_cn = [ind; Winkler_outliers3_cn];
% Exclude outliers from NLMR model 
mdl_cn5 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers4_cn)

figure
histfit(mdl_cn5.Residuals.Raw)
title('SOC_c_n Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')
%%
mdlcal_cn = mdl_cn5;
% cal for SOC_dt 
cal.SOCcalc_cn = mdlcal_cn.Coefficients.Estimate(1);
cal.SOCrate_cn = mdlcal_cn.Coefficients.Estimate(2);
cal.gain = cal.SOCcalc_cn/cal.SOC;
cal.Winkler_outliers_cn = Winkler_outliers4_cn(Winkler_outliers4_cn < height(btlsum_tbl));
cal.casts = good;
cal.mdl = mdlcal_cn;
cal.out_NLMR_cn = sortrows([bad_casts(Winkler_outliers4_cn) btl_check(Winkler_outliers4_cn) Winklers_to_use(Winkler_outliers4_cn)],[1 2]);
cal6 = cal;

% % For range of SOC
cal6.SOCcalc_cn % SOC at start 
cal6.SOCcalc_cn/cal6.SOC % gain at start 
(btlsum_tbl.Cast(end) - btlsum_tbl.Cast(1))*cal6.SOCrate_cn + cal6.SOCcalc_cn
(btlsum_tbl.Cast(end) - btlsum_tbl.Cast(1))*cal6.SOCrate_cn + cal6.SOCcalc_cn/cal6.SOC

f = figure;
f.Position = [100 100 840 500];
figure(8)
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_cn.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_cn.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_cn.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler_umolkg, mdlcal_cn.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('CE17-007: SOC_c_n Winklers from Group 6')
%% Group 7: Stations 62-66 SOC k
cal = cal0; 
group7 = 62:66;
good = group7; 
btlsum_tbl = [];
for j = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(j)}];
end

X = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];

bad_casts = btlsum_tbl.Cast;
btl_check = btlsum_tbl.Bottle; 
pdens = btlsum_tbl.prho;
Winklers_to_use = btlsum_tbl.Winkler_umolkg;

cal.Ecalc = cal_all.Ecalc;
cal.Acalc = cal_all.Acalc; 
% % SBE functional form 
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal_all.Acalc*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal_all.Ecalc*x(:,4))./(x(:,3) + 273.15));

beta0 = [cal.SOC]; % Starting values for coefficient iterations 

outlier_method = 'median';

%Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
%functional form using all Winklers_umolkg (from calibrated T/S data) 
% Run non linear model fit with all Winkler/CTD oxygen (volts) values
mdl1 = fitnlm(X,Winklers_to_use,modelfun,beta0);

% figure
% histfit(mdl1.Residuals.raw)
% title('SOC_k Residuals with Outliers, it = 1')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,outlier_method) == 1);
mdl2 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers1);

% figure
% histfit(mdl2.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 2')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl2.Residuals.raw,outlier_method) == 1);
Winkler_outliers2 = [ind; Winkler_outliers1];
% Exclude outliers from NLMR model 
mdl3 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers2);

% figure
% histfit(mdl3.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 3')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl3.Residuals.raw,outlier_method) == 1);
Winkler_outliers3 = [ind; Winkler_outliers2];
% Exclude outliers from NLMR model 
mdl4 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers3);

% figure
% histfit(mdl4.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 4')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl4.Residuals.raw,outlier_method) == 1);
Winkler_outliers4 = [ind; Winkler_outliers3];
% Exclude outliers from NLMR model 
mdl5 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers4);

% figure
% histfit(mdl5.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 5')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 6 
ind = find(isoutlier(mdl5.Residuals.raw,outlier_method) == 1);
Winkler_outliers5 = [ind; Winkler_outliers4];
% Exclude outliers from NLMR model 
mdl6 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers5);

% figure
% histfit(mdl6.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 6')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 7 
ind = find(isoutlier(mdl6.Residuals.raw,outlier_method) == 1);
Winkler_outliers6 = [ind; Winkler_outliers5];
% Exclude outliers from NLMR model 
mdl7 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers6)

figure
histfit(mdl7.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 7')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
%%
%Plot residuals versus pressure, time, station, DO concentration with outliers removed   
mdlcal_k = mdl7;
cal.SOCcalc = mdlcal_k.Coefficients.Estimate(1);
cal.gain = cal.SOCcalc/cal.SOC;
cal.Winkler_outliers = Winkler_outliers6;
cal.casts = good;
cal.mdl = mdlcal_k;
cal.out_NLMR_k = sortrows([bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)],[1 2]);
cal7 = cal;

f = figure;
f.Position = [100 100 840 500];
figure(8)
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler_umolkg, mdlcal_k.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Factory Calibrated CTD-DO (\mumol/kg)')
grid on
sgtitle('CE17007: SOC_k Winklers Group 7')
%%
sgtitle('CE17-007: All Fits')
%% Cast 4

cal = cal_cast4; SOC_type = 1; %%% The line to change 
cast_num = cal.casts;
dummy = [];
for j = 1:length(cast_num)
    dummy1 = btlsum{cast_num(j)};
    dummy = [dummy; dummy1];
end

group_cast4 = calibrate_CTD_oxygen(dummy,cal,SOC_type);
%%

cal = cal1; SOC_type = 3; %%% The line to change 
cast_num = cal.casts;
dummy = [];
for j = 1:length(cast_num)
    dummy1 = btlsum{cast_num(j)};
    dummy = [dummy; dummy1];
end

group1 = calibrate_CTD_oxygen(dummy,cal,SOC_type);

%%
cal = cal2; SOC_type = 3; %%% The line to change 
cast_num = cal.casts;
dummy = [];
for j = 1:length(cast_num)
    dummy1 = btlsum{cast_num(j)};
    dummy = [dummy; dummy1];
end
group2 = calibrate_CTD_oxygen(dummy,cal,SOC_type);
%%
cal = cal3; SOC_type = 3; %%% The line to change 
cast_num = cal.casts;
dummy = [];
for j = 1:length(cast_num)
    dummy1 = btlsum{cast_num(j)};
    dummy = [dummy; dummy1];
end
group3 = calibrate_CTD_oxygen(dummy,cal,SOC_type);
%%
cal = cal4; SOC_type = 1; %%% The line to change 
cast_num = cal.casts; 
dummy = [];
for j = 1:length(cast_num)
    dummy1 = btlsum{cast_num(j)};
    dummy = [dummy; dummy1];
end
group4 = calibrate_CTD_oxygen(dummy,cal,SOC_type);
%%
cal = cal5; SOC_type = 1; %%% The line to change 
cast_num = cal.casts;
dummy = [];
for j = 1:length(cast_num)
    dummy1 = btlsum{cast_num(j)};
    dummy = [dummy; dummy1];
end
group5 = calibrate_CTD_oxygen(dummy,cal,SOC_type);
%%

cal = cal6; SOC_type = 3; %%% The line to change 
cast_num = cal.casts;
dummy = [];
for j = 1:length(cast_num)
    dummy1 = btlsum{cast_num(j)};
    dummy = [dummy; dummy1];
end
group6 = calibrate_CTD_oxygen(dummy,cal,SOC_type);
%%
cal = cal7; SOC_type = 1; %%% The line to change 
cast_num = cal.casts;
dummy = [];
for j = 1:length(cast_num)
    dummy1 = btlsum{cast_num(j)};
    dummy = [dummy; dummy1];
end
group7 = calibrate_CTD_oxygen(dummy,cal,SOC_type);
%%
btlsum_tbl = [group_cast4; group1; group2; group3; group4; group5; group6; group7];
%%
% For output structure
btlsum = []; % Indexes by cast number leah_btl{5} == cast 5; 
btlcasts = unique(btlsum_tbl.Cast); 
for j = 1:length(btlcasts)% Number of bottle summary files 
    btlsum{btlcasts(j)} = btlsum_tbl(btlsum_tbl.Cast == btlcasts(j),:);
end
%% Make output table
% KF = table;
% KF.Cast = unique(btlsum_tbl.Cast);
% maxdepth = [];
% for j = 1:length(KF.Cast)
%     maxdepth(j) = max(btlsum_tbl.depth(btlsum_tbl.Cast == KF.Cast(j)));
% end
% KF.maxdepth = maxdepth';

cn = unique(btlsum_tbl.Cast);
KF = [];
for j = 1:length(cn)
    castgrab = btlsum_tbl(btlsum_tbl.Cast == cn(j),3:end);
    castgrab.RMSE(:) = rmse(castgrab.DOcorr_umolkg(castgrab.NLMR_Outlier == 2),castgrab.Winkler_umolkg(castgrab.NLMR_Outlier == 2));
    KF(j,:) = table2array(castgrab(1,:));
end
%%
KFtable = table;
KFtable.Cast = KF(:,1);
KFtable.RMSE = KF(:,28);
KFtable.MaxDepth = KF(:,4);
KFtable.SOC_type = KF(:,21);
KFtable.gain = KF(:,24);
KFtable.SOCcalc = KF(:,25);
KFtable.Ecalc = KF(:,26);
KFtable.Voffset = KF(:,27);

%% 
if filesave == 1
    clear cal_dir
    cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
    save CE17007_DOcal.mat btlsum btlsum_tbl cal*
end

%%
function btlsum = combine_btl_files(leah_btl_file,my_btl_file,Winkler_table,CTD_sen)
    btlsum = Winkler_table; % Winklers for just the cast 
    % btlsum.Properties.VariableNames = {'Cast','Bottle','Winkler_mLL'};

    % Format structure for conversion to table and convert to table 
    leah_btl = readtable(leah_btl_file,'FileType','text');%,'VariableNamingRule','preserve');
    leah_btl.Properties.VariableNames = {'Bottle','prs','temp1','temp2','th190','th290','sal1','sal2','CTDoxy_mLL','Meas_SAL','QUAL'};
    
    % Format structure for conversion to table and convert to table 
    btl = readtable(my_btl_file,'TextType','string');
    vars = {'Bottle','Date','PrDM','DepSM','Latitude','Longitude','Sbeox0V','OxsolMm_Kg'};
    btl = btl(:,vars);
    btl.Properties.VariableNames = {'Bottle','Date','PrDM','depth','lat','lon','oxy_volts','SBE_oxsol_umolkg'};
    btl.CTDcal(:) = "True";
    % btl.CTDcal = string(btl.CTDcal);
    
    % Combine tables by Bottle variable 
    btlsum0 = join(leah_btl,btl,'Keys','Bottle');
    if height(btlsum0) < height(btlsum)
        btlsum = join(btlsum0,btlsum,'Keys','Bottle'); 
    elseif height(btlsum) <= height(btlsum0)
        btlsum = join(btlsum,btlsum0,'Keys','Bottle');
    end

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
    btlsum.O2sol_umolkg = gsw_O2sol(btlsum.SA,btlsum.CT,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.rho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,btlsum.prs); % in situ density
    btlsum.prho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,0); % potential density with ref == surf
    btlsum.sigma0 = gsw_sigma0_CT_exact(btlsum.SA,btlsum.CT); % btlsum.prho - 1000 = btlsum.sigma0
    btlsum.Winkler_umolkg = btlsum.Winkler_umolL*1000./btlsum.prho; % uses potential density
    btlsum.Cruise(:) = "CE17-007";

     % Reorder variables and remove unnecessary ones
    btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2','Meas_SAL','CTDcal',...
    'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','Winkler_umolL','Winkler_umolkg','O2sol_umolkg','SBE_oxsol_umolkg'};
    btlsum = btlsum(:,btlvars);
        
end


%% Reads in bottle data and calibrates CTD oxygen 
function btlsum = calibrate_CTD_oxygen(btlsum,cal,SOC_type)

x = [btlsum.oxy_volts,btlsum.O2sol_umolkg,btlsum.t,btlsum.prs];

    if SOC_type == 0 % Seabird Factory calibration 
    
        % SBE functional form without SOC drift 
        btlsum.DOcorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));
        outliers = [];
        
    end

    if SOC_type == 1 % Constant SOC value
    
        % SBE functional form without SOC drift 
        btlsum.DOcorr_umolkg = cal.SOCcalc*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.Acalc*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));
        
        btlsum.SOCcalc = ones(height(btlsum.prs),1)*cal.SOCcalc;
        btlsum.Ecalc = ones(height(btlsum.prs),1)*cal.Ecalc;
        btlsum.gain = ones(height(btlsum.prs),1)*(cal.SOCcalc/cal.SOC);
        btlsum.Voffset = ones(height(btlsum.prs),1)*cal.VOFFSET;
   
        
    end

    if SOC_type == 2 % SOC varies with cruise time
        dtx = datenum(btlsum.Date) - datenum(btlsum.Date(1)); 
        x = [x, dtx];
        
        % SBE functional form with SOC as a function of cruise time
        btlsum.DOcorr_umolkg = ((cal.SOCrate_dt*x(:,5)) + cal.SOCcalc_dt*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_dt*x(:,4))./(x(:,3) + 273.15));

        cal.Winkler_outliers = cal.Winkler_outliers_dt;
    end

    if SOC_type == 3 % SOC varies with cast number 
        cnx = btlsum.Cast - min(cal.casts);
        x = [x,cnx];
        
        % SBE functional form with SOC as a function of cruise time
        btlsum.DOcorr_umolkg = ((cal.SOCrate_cn*x(:,5)) + cal.SOCcalc_cn*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.Acalc_cn*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15));

        cal.Winkler_outliers = cal.Winkler_outliers_cn;
        
        btlsum.SOCcalc = cal.SOCcalc_cn + (cal.SOCrate_cn.*(btlsum.Cast-min(btlsum.Cast)));
        btlsum.Ecalc = ones(length(btlsum.prs),1)*cal.Ecalc_cn;
        btlsum.gain = btlsum.SOCcalc./cal.SOC;
        btlsum.Voffset = ones(length(btlsum.prs),1)*cal.VOFFSET;
    end

        btlsum.SOC_type = ones(length(btlsum.prs),1)*SOC_type;

        % Sets outliers from NLMR 
        btlsum.NLMR_Outlier = ones(size(btlsum.prs))*2; % Sets all Winklers to 2 (acceptable)
        btlsum.NLMR_Outlier(cal.Winkler_outliers) = 3; % Questionable from NLMR
        btlsum.NLMR_Outlier(isnan(btlsum.Winkler_umolkg)) = 9; % QC flag for missing data 

        btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','CTDcal','CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','O2sol_umolkg','Winkler_umolL',...
            'Winkler_umolkg','SOC_type','NLMR_Outlier','DOcorr_umolkg','gain','SOCcalc','Ecalc','Voffset'};
        btlsum = btlsum(:,btlvars);
end

