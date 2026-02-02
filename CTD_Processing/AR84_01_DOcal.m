% Set up workspace 
clearvars; close all
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
addpath('G:\My Drive\Matlab_work\BC')
addpath(genpath('G:\My Drive\Matlab_work\Github\cmocean'))
addpath(genpath('G:\My Drive\Matlab_work\Github\GSW-Matlab'))
run('GeneralSettings.m') % For colors


% Read in salinity calibrated bottle files, Winkler sample values and oxygen files
% processed with SBE default hysteresis correction and no tau correction 

btl_dir = 'C:\Users\fogaren\Documents\SBE_Processing\AR84-01\btl'; % my processed bottle product 
cal_dir = 'C:\Users\fogaren\Documents\SBE_Processing\AR84-01\from_Leah\final_2db'; % Leah product
samp_dir = 'C:\Users\fogaren\Documents\SBE_Processing\AR84-01\cnv'; % processed SBE cnvs
Winkler_dir = 'C:\Users\fogaren\Documents\SBE_Processing\AR84-01';
Winkler_file = 'Irminger_Sea-11_AR84-01_Discrete_Summary_KF.xlsx';

filesave = 0; % filesave == 1, save calibration output as mat file

% Use Bottle samples to calculate new SOC (gain) and E terms for CTD data
% Determined during CTD salinity calibration, both reported as good
CTD_sen = 1; % Use primary or secondary CTD temp and sal

%% Check to see if calibrated salinity bottle file from Leah for each of my bottle files 

cd(cal_dir)
btlfiles = ls('*.cbot_s'); % List of Leah's calibrated bottle files 
btlcasts = str2num(btlfiles(:,9:11)); % Pulls out cast numbers that have bottle files 

cd(btl_dir)
mybtlfiles = ls('*.btl'); % List of my processed bottle files 
mybtlcasts = str2num(mybtlfiles(:,9:11)); % Pulls out cast numbers that have bottle files 

% Make sure that there is a Leah bottle file for each of my bottle files 
if btlcasts == mybtlcasts 
    disp('Btl Casts Line Up')
    
else
    disp('Caution: Issue with Btl Cast Numbers!')
end

%% Read in Winkler values, SBE bottle files and combine them
cd(Winkler_dir)
Winklers = readtable(Winkler_file,'TextType','string');
Winklers.Cast = double(Winklers.Cast);
Winklers.Bottle = double(Winklers.Bottle);
Winklers.Winkler1_mLL = double(Winklers.Winkler1_mLL);
Winklers.Winkler2_mLL = double(Winklers.Winkler2_mLL);
Winklers.Winkler3_mLL = double(Winklers.Winkler3_mLL);
Wink_casts = unique(Winklers.Cast); % Casts with Winklers

%% Create bottle summary indexed by cast number and table with all data 
cd(btl_dir)
mybtlcasts = str2num(mybtlfiles(:,9:11)); % Pulls out cast numbers that have bottle files 

SBEbtlfiles = []; % Read in all SBE bottle files 
for j = 1:length(mybtlcasts)
    SBEbtlfiles{mybtlcasts(j)} = readin_SBE_btl(mybtlfiles(j,:));
    SBEbtlfiles{mybtlcasts(j)}.Cast(:) = mybtlcasts(j);
end

SBEbtlsum_tbl = []; % Combine all SBE bottle files into one table 
for j = 1:length(mybtlcasts)
    SBEbtlsum_tbl = [SBEbtlsum_tbl; SBEbtlfiles{mybtlcasts(j)}];
end
%%
cd(cal_dir)
for j = 1:length(mybtlcasts)
    leah_btl{mybtlcasts(j)} = readtable(btlfiles(j,:),'FileType','text','MultipleDelimsAsOne',true);
    leah_btl{mybtlcasts(j)}.Properties.VariableNames = {'Bottle','prs','temp1','temp2','th90_1','th90_2','sal1','sal2','CTDoxy_mLL','Meas_SAL','QUAL'};
    leah_btl{mybtlcasts(j)}.Cast(:) = mybtlcasts(j);
    leah_btl{mybtlcasts(j)}.Meas_SAL(leah_btl{mybtlcasts(j)}.Meas_SAL == -9) = NaN; % replaces no data flag with NaN
end

leah_btl_tbl = [];
for j = 1:length(mybtlcasts)
    leah_btl_tbl = [leah_btl_tbl; leah_btl{mybtlcasts(j)}];
end

leah_btl_tbl(isnan(leah_btl_tbl.Bottle),:) = [];
%%
CTDcal = 1; % 1 == use of calibrated temperature/salinity data 
btlsum_tbl = combine_btl_files(Winklers, SBEbtlsum_tbl,leah_btl_tbl,CTD_sen,CTDcal);

%% *** same sensor for all casts ***
% From SBE factory calibration 
% Serial number 3521, 13-Feb-25
cal.SOC = 4.6319e-001;
cal.VOFFSET = -0.4882;
cal.A = -5.3551e-003;
cal.B = 2.4295e-004; 
cal.C = -3.4933e-006;
cal.E = 3.60000e-002;
cal.Tau20 = 1.1900;
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '0072';
cal.OCALDATE = '03-Oct-23';

H = [-0.020, 5000, 1850]; % Default 
%% Look at Winklers versus CTD-DO from factory calibration 

% Calculate oxygen concentration with SBE factory calibration 
x = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
  .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
  .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));

f = figure;
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, btlsum_tbl.Winkler1_umolkg - DOuncorr_umolkg,'.k','Markersize',20); hold on;
plot(btlsum_tbl.prs, btlsum_tbl.Winkler2_umolkg - DOuncorr_umolkg,'.k','Markersize',20)
plot(btlsum_tbl.prs, btlsum_tbl.Winkler3_umolkg - DOuncorr_umolkg,'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
ylim([5 25])
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, btlsum_tbl.Winkler1_umolkg - DOuncorr_umolkg,'.k','Markersize',20); hold on;
plot(btlsum_tbl.Cast, btlsum_tbl.Winkler2_umolkg - DOuncorr_umolkg,'.k','Markersize',20)
plot(btlsum_tbl.Cast, btlsum_tbl.Winkler3_umolkg - DOuncorr_umolkg,'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
ylim([5 25])
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, btlsum_tbl.Winkler1_umolkg - DOuncorr_umolkg,'.k','Markersize',20); hold on;
plot(btlsum_tbl.t, btlsum_tbl.Winkler2_umolkg - DOuncorr_umolkg,'.k','Markersize',20)
plot(btlsum_tbl.t, btlsum_tbl.Winkler3_umolkg - DOuncorr_umolkg,'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
ylim([5 25])
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg, btlsum_tbl.Winkler1_umolkg - DOuncorr_umolkg,'.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, btlsum_tbl.Winkler2_umolkg - DOuncorr_umolkg,'.k','Markersize',20)
plot(btlsum_tbl.Winkler3_umolkg, btlsum_tbl.Winkler3_umolkg - DOuncorr_umolkg,'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
ylim([5 25])
grid on
sgtitle('AR84-01: Factory Calibrated CTD-DO vs Winklers')
%% non linear multiple regression using SBE functional form 
% After using just the deep casts to calculate the E term 

% Oxygen solubility calculated using GSW Toolbox 
% Treats Winkler replicates as individual points (no averaging of Winklers)
% OOI Cruise no replicates 
 
% Treats Winklers as individual points 
X = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs; btlsum_tbl.prs]];
bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle; btlsum_tbl.Bottle];
% Winklers_to_use = [btlsum_tbl.Winkler1_umolkg; btlsum_tbl.Winkler2_umolkg; btlsum_tbl.Winkler3_umolkg];
pdens = [btlsum_tbl.prho; btlsum_tbl.prho; btlsum_tbl.prho];

Wink1 = btlsum_tbl.Winkler1_umolkg; 
Wink2 = btlsum_tbl.Winkler2_umolkg; 
Wink3 = btlsum_tbl.Winkler3_umolkg; 
Wink1(btlsum_tbl.prs < 1000) = NaN;
Wink2(btlsum_tbl.prs < 1000) = NaN;
Wink3(btlsum_tbl.prs < 1000) = NaN;
Winklers_to_use = [Wink1; Wink2; Wink3];


% SBE functional form  
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0 = [cal.SOC 0]; % Starting values for coefficient iterations 

% Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
% functional form using all Winklers_umolkg (from calibrated T/S data) 
% Run non linear model fit with all Winkler/CTD oxygen (volts) values
% Repeat until all outliers are removed 

% Find outliers based on median filter it = 1 
mdl1 = fitnlm(X,Winklers_to_use,modelfun,beta0);

figure
histfit(mdl1.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,'median') == 1);
% Exclude outliers from NLMR model 
mdl2 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers1);

figure
histfit(mdl2.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl2.Residuals.raw,'median') == 1);
Winkler_outliers2 = [ind; Winkler_outliers1];
% Exclude outliers from NLMR model 
mdl3 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers2);

figure
histfit(mdl3.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl3.Residuals.raw,'median') == 1);
Winkler_outliers3 = [ind; Winkler_outliers2];
% Exclude outliers from NLMR model 
mdl4 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers3);

figure
histfit(mdl4.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl4.Residuals.raw,'median') == 1);
Winkler_outliers4 = [ind; Winkler_outliers3];
% Exclude outliers from NLMR model 
mdl5 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers4);

figure
histfit(mdl5.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 6 
ind = find(isoutlier(mdl5.Residuals.raw,'median') == 1);
Winkler_outliers5 = [ind; Winkler_outliers4];
% Exclude outliers from NLMR model 
mdl6 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers5);

figure
histfit(mdl6.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 6')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 7 
ind = find(isoutlier(mdl6.Residuals.raw,'median') == 1);
Winkler_outliers6 = [ind; Winkler_outliers5];
% Exclude outliers from NLMR model 
mdl7 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers6);

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
cal.gain = cal.SOCcalc/cal.SOC;
cal.Winkler1_outliers = Winkler_outliers6(Winkler_outliers6 <= height(btlsum_tbl));
cal.Winkler2_outliers = Winkler_outliers6(Winkler_outliers6 > height(btlsum_tbl) & Winkler_outliers6 <= 2*height(btlsum_tbl)) - height(btlsum_tbl);
cal.Winkler3_outliers = Winkler_outliers6(Winkler_outliers6 > 2*height(btlsum_tbl) & Winkler_outliers6 <= 3*height(btlsum_tbl)) - 2*height(btlsum_tbl);
cal.casts = 1:214;
cal.mdl = mdl7;
% To identify outliers 
cal.out_NLMR = sortrows([bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)],[1 2]);
cal_deep = cal;
%% Plot of residuals with updates Calibration Coefficients
f = figure;
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Cast, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Cast, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
cast_num = unique(btlsum_tbl.Cast);
for j = 1:length(cast_num)
    ind = find(btlsum_tbl.Cast == cast_num(j));
    cast_mean = nanmean([mdlcal_k.Residuals.raw(ind); mdlcal_k.Residuals.raw(ind+height(btlsum_tbl))]);
    cast_std = nanstd([mdlcal_k.Residuals.raw(ind); mdlcal_k.Residuals.raw(ind+height(btlsum_tbl))]);
    h = errorbar(cast_num(j)+0.5,cast_mean,cast_std,cast_std,'vertical','.r','MarkerSize',20,'Color',brightpurple);
end   
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Winkler3_umolkg, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('AR84-01: SOC_k fit, whole cruise as one Group')

%% non linear multiple regression using SBE functional form 
% After using just the deep casts to calculate the E term 

% Oxygen solubility calculated using GSW Toolbox 
% Treats Winkler replicates as individual points (no averaging of Winklers)
% OOI Cruise no replicates 
 
% Treats Winklers as individual points 
X = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs; btlsum_tbl.prs]];
bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use = [btlsum_tbl.Winkler1_umolkg; btlsum_tbl.Winkler2_umolkg; btlsum_tbl.Winkler3_umolkg];
pdens = [btlsum_tbl.prho; btlsum_tbl.prho; btlsum_tbl.prho];


% SBE functional form  
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal_deep.Ecalc.*x(:,4))./(x(:,3) + 273.15));

beta0 = [cal.SOC]; % Starting values for coefficient iterations 

% Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
% functional form using all Winklers_umolkg (from calibrated T/S data) 
% Run non linear model fit with all Winkler/CTD oxygen (volts) values
% Repeat until all outliers are removed 

% Find outliers based on median filter it = 1 
mdl1 = fitnlm(X,Winklers_to_use,modelfun,beta0);

figure
histfit(mdl1.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,'median') == 1);
% Exclude outliers from NLMR model 
mdl2 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers1);

figure
histfit(mdl2.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl2.Residuals.raw,'median') == 1);
Winkler_outliers2 = [ind; Winkler_outliers1];
% Exclude outliers from NLMR model 
mdl3 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers2);

figure
histfit(mdl3.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl3.Residuals.raw,'median') == 1);
Winkler_outliers3 = [ind; Winkler_outliers2];
% Exclude outliers from NLMR model 
mdl4 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers3);

figure
histfit(mdl4.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl4.Residuals.raw,'median') == 1);
Winkler_outliers4 = [ind; Winkler_outliers3];
% Exclude outliers from NLMR model 
mdl5 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers4);

figure
histfit(mdl5.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 6 
ind = find(isoutlier(mdl5.Residuals.raw,'median') == 1);
Winkler_outliers5 = [ind; Winkler_outliers4];
% Exclude outliers from NLMR model 
mdl6 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers5);

figure
histfit(mdl6.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 6')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 7 
ind = find(isoutlier(mdl6.Residuals.raw,'median') == 1);
Winkler_outliers6 = [ind; Winkler_outliers5];
% Exclude outliers from NLMR model 
mdl7 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers6);

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
cal.gain = cal.SOCcalc/cal.SOC;
cal.Winkler1_outliers = Winkler_outliers6(Winkler_outliers6 <= height(btlsum_tbl));
cal.Winkler2_outliers = Winkler_outliers6(Winkler_outliers6 > height(btlsum_tbl) & Winkler_outliers6 <= 2*height(btlsum_tbl)) - height(btlsum_tbl);
cal.Winkler3_outliers = Winkler_outliers6(Winkler_outliers6 > 2*height(btlsum_tbl) & Winkler_outliers6 <= 3*height(btlsum_tbl)) - 2*height(btlsum_tbl);
cal.casts = 1:214;
cal.mdl = mdl7;
% To identify outliers 
cal.out_NLMR = sortrows([bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)],[1 2]);
cal_k = cal;
clear cal; 
%% Plot of residuals with updates Calibration Coefficients
f = figure;
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Cast, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Cast, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
cast_num = unique(btlsum_tbl.Cast);
for j = 1:length(cast_num)
    ind = find(btlsum_tbl.Cast == cast_num(j));
    cast_mean = nanmean([mdlcal_k.Residuals.raw(ind); mdlcal_k.Residuals.raw(ind+height(btlsum_tbl))]);
    cast_std = nanstd([mdlcal_k.Residuals.raw(ind); mdlcal_k.Residuals.raw(ind+height(btlsum_tbl))]);
    h = errorbar(cast_num(j)+0.5,cast_mean,cast_std,cast_std,'vertical','.r','MarkerSize',20,'Color',brightpurple);
end   
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Winkler3_umolkg, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('AR84-01: SOC_k fit, whole cruise as one Group')

%%
figure
plot(Winklers.Cast(~isnan(Winklers.Winkler1_mLL)),Winklers.Bottle(~isnan(Winklers.Winkler1_mLL)),'ok','MarkerFaceColor','k')
hold on
plot(cal_k.out_NLMR(:,1,1),cal_k.out_NLMR(:,2),'ok','MarkerFaceColor',red)
ylabel('Niskin Number')
xlabel('Cast Number')
xticks([min(Winklers.Cast):1:max(Winklers.Cast)])
yticks([min(Winklers.Bottle):1:max(Winklers.Bottle)])
title('RR2505')
xlim([min(Winklers.Cast)-1 max(Winklers.Cast)+1])
legend('Winkler','NLMR Outlier','location','NW','Orientation','horizontal')
grid on
%%
SOC_type = 1;
btlsum_tbl = calibrate_CTD_oxygen(btlsum_tbl,cal_k,SOC_type);
cal = cal_k;
%%
btlsum_RR2505 = btlsum_tbl; 
if filesave == 1
    cd(btl_dir)
    clear btlsum_tbl btlcasts btlfiles btl_dir 
    save RR2505_DOcal.mat btl* cal
end
%%
function btlsum = combine_btl_files(Winkler_file,my_btl_file,leah_btl_file,CTD_sen)

    btlsum0 = join(Winkler_file,my_btl_file,'Keys',{'Cast','Bottle'});
    btlsum = join(btlsum0,leah_btl_file,'Keys',{'Cast','Bottle'});

    % Decide if using primary or secondary CTD sensor for temp and sal
    if CTD_sen == 1 % primary sensor (use unless something wrong with data)
        btlsum.t = btlsum.temp1; 
        btlsum.sal = btlsum.sal1; 
    end

    if CTD_sen == 2 % secondary sensor (use if primary sensor bad)
        btlsum.t = btlsum.temp2; 
        btlsum.cond = btlsum.sal2;
    end  
    btlsum.lat = btlsum.Latitude;
    btlsum.lon = btlsum.Longitude; 
    btlsum.depth = -gsw_z_from_p(btlsum.prs,btlsum.Latitude);
    btlsum.oxy_volts = btlsum.Sbeox0V;
    btlsum.CTD_sen = ones(length(btlsum.prs),1)*CTD_sen; 
    btlsum.SP = btlsum.sal;
    btlsum.SA = gsw_SA_from_SP(btlsum.SP,btlsum.prs,btlsum.Longitude,btlsum.Latitude);
    btlsum.CT = gsw_CT_from_t(btlsum.SA,btlsum.t,btlsum.prs);
    btlsum.pt = gsw_pt_from_CT(btlsum.SA,btlsum.CT);
    btlsum.O2sol_umolkg = gsw_O2sol(btlsum.SA,btlsum.CT,btlsum.prs,btlsum.Longitude,btlsum.Latitude);
    btlsum.rho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,btlsum.prs); % in situ density
    btlsum.prho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,0); % potential density with ref == surf
    btlsum.sigma0 = gsw_sigma0_CT_exact(btlsum.SA,btlsum.CT); % btlsum.prho - 1000 = btlsum.sigma0
    btlsum.Winkler1_umolkg = btlsum.Winkler1_mLL*1000*44.661./btlsum.prho; % Winkler conc, uses pot. density 
    btlsum.Winkler2_umolkg = btlsum.Winkler2_mLL*1000*44.661./btlsum.prho; % Winkler conc, uses pot. density
    btlsum.Winkler3_umolkg = btlsum.Winkler3_mLL*1000*44.661./btlsum.prho; % Winkler conc, uses pot. density
    btlsum.CTDcal(:) = "True"; 

    btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2',...
        'CTDcal','CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','O2sol_umolkg',...
        'Winkler1_mLL','Winkler2_mLL','Winkler1_umolkg','Winkler2_umolkg','Winkler3_umolkg'};
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
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));
    end

    if SOC_type == 2 % SOC varies with cruise time
        dtx = datenum(btlsum.Date) - datenum(btlsum.Date(1)); 
        x = [x, dtx];
        
        % SBE functional form with SOC as a function of cruise time
        btlsum.DOcorr_umolkg = ((cal.SOCrate_dt*x(:,5)) + cal.SOCcalc_dt*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_dt*x(:,4))./(x(:,3) + 273.15));

        cal.Winkler1_outliers = cal.Winkler1_outliers_dt;
        cal.Winkler2_outliers = cal.Winkler2_outliers_dt;
        cal.Winkler3_outliers = cal.Winkler3_outliers_dt;
    end

    if SOC_type == 3 % SOC varies with cast number 

        x = [x,btlsum.Cast];
        
        % SBE functional form with SOC as a function of cruise time
        btlsum.DOcorr_umolkg = ((cal.SOCrate_cn*x(:,5)) + cal.SOCcalc_cn*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15));
    end

        btlsum.SOC_type = ones(length(btlsum.prs),1)*SOC_type;

        % Sets outliers from NLMR 
        btlsum.NLMR_Outlier1 = ones(size(btlsum.prs))*2; % Sets all Winklers to 2 (acceptable)
        btlsum.NLMR_Outlier1(cal.Winkler1_outliers) = 3; % Questionable from NLMR
        % btlsum.NLMR_Outlier1(btlsum.Bottle == 1) = 99; % Leaky niskin
        btlsum.NLMR_Outlier1(isnan(btlsum.Winkler1_umolkg)) = 9; % QC flag for missing data 

        btlsum.NLMR_Outlier2 = ones(size(btlsum.prs))*2; % Sets all Winklers to 2 (acceptable)
        btlsum.NLMR_Outlier2(cal.Winkler2_outliers) = 3; % Questionable from NLMR
        % btlsum.NLMR_Outlier2(btlsum.Bottle == 1) = 99; % Leaky niskin
        btlsum.NLMR_Outlier2(isnan(btlsum.Winkler2_umolkg)) = 9; % QC flag for missing data 

        btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2',...
            'CTDcal','CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','O2sol_umolkg',...
            'Winkler1_mLL','Winkler2_mLL','Winkler1_umolkg','Winkler2_umolkg','SOC_type','NLMR_Outlier1','NLMR_Outlier2','DOcorr_umolkg'};
        btlsum = btlsum(:,btlvars);
end