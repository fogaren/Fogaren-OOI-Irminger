% Set up workspace 
clearvars
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')

% Read in calibrated bottle files, Winkler sample values and oxygen files
% processed with default hysteresis correction and user-determined time lag
% correction 
btl_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Bottle_Files\Year1';
samp_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year1'; % Winkler file location 
Winkler_file = 'Irminger_Sea-01_KN221-04_Discrete_Summary_KF'; % Winkler file name 
filesave = 1; % filesave == 1, save calibration output as mat file

% Use Bottle samples to calculate new SOC (gain) and E terms for CTD data 
CTD_sen = 1; % Use primary or secondary CTD temp and sal

% Read in Winkler file 
cd(samp_dir)
Winklers = readtable(Winkler_file,'TextType','string');
Winklers.Winkler1_mLL = double(Winklers.Winkler1_mLL);
Winklers.Winkler2_mLL = double(Winklers.Winkler2_mLL);
Winklers.Discrete_Salinity1_psu = double(Winklers.Discrete_Salinity1_psu);
Winklers.Discrete_Salinity2_psu = double(Winklers.Discrete_Salinity2_psu);
%% NO CALIBRATED SALINITY FOR THIS CRUISE 
% cd(cal_dir)
% 
% % Removed bottle casts before cast 5 (no Winklers)
% btlfiles = ls('*.cbot_s'); % List of Leah's calibrated bottle files 
% btlcasts = str2num(btlfiles(:,9:11)); % Pulls out cast numbers that have bottle files 
% 
cd(btl_dir)
mybtlfiles = ls('*.csv'); % List of my processed bottle files 
btlcasts = str2num(mybtlfiles(:,8:10)); % Pulls out cast numbers that have bottle files 

% 
% % Make sure that there is a Leah bottle file for each of my bottle files 
% if mybtlcasts == btlcasts 
%     disp('Btl Casts Line Up')
%     addpath(cal_dir)
%     addpath(btl_dir)
%     
% else
%     disp('Caution: Issue with Btl Cast Numbers!')
% end
%%
btlsum = []; % Indexes by cast number leah_btl{5} == cast 5; 
% Combine files and calculate sea water properties for CTD sensor number 
for i = 1:height(btlcasts) % Number of bottle summary files 
    btlsum{btlcasts(i)} = combine_btl_files_noCTDcal(mybtlfiles(i,:),Winklers(Winklers.Cast == btlcasts(i),:),CTD_sen) ;
end

% Pull all bottle files and create one large table 
btlsum_tbl = [];
for i = 1:length(btlsum)
    btlsum_tbl = [btlsum_tbl; btlsum{i}];
end
btl_num = unique(btlsum_tbl.Cast);

% Same Oxygen Sensor for whole cruise 
% Calibration standards from SBE xmlcon file 

cal.SOC = double(4.55930e-001);
cal.VOFFSET = double(-4.97100e-001);
cal.A = double(-3.66900e-003);
cal.B = double(1.91110e-004);
cal.C = double(-2.62760e-006);
cal.E = double(3.60000e-002);
cal.Tau20 = double(2.23000e+000);
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '1679';
cal.OCALDATE = '23-Oct-13';

H = [-0.033, 5000, 1450]; % Default 

%% Difference between Winklers Duplicates vs. Pressure, Cast, Temp, CTD-DO

Winkler_diff = btlsum_tbl.Winkler1_umolkg - btlsum_tbl.Winkler2_umolkg;

figure %Difference between 
subplot(2,2,1)
plot(btlsum_tbl.prs, Winkler_diff,'.k','Markersize',20); hold on
ylabel({'Winkler 1 - Winkler 2','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number 
subplot(2,2,2)
plot(btlsum_tbl.Cast, Winkler_diff, 'k.','Markersize',20); hold on;
ylabel({'Winkler 1 - Winkler 2','(\mumol/kg)'})
xlabel('Cast Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, Winkler_diff, 'k.','Markersize',20); hold on;
ylabel({'Winkler 1 - Winkler 2','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

x = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
  .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
  .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(DOuncorr_umolkg, Winkler_diff, 'k.','Markersize',20); hold on;
ylabel({'Winkler 1 - Winkler 2','(\mumol/kg)'})
xlabel('Factory Calibrated CTD-DO (\mumol/kg)')
grid on
sgtitle('KN221-4: Duplicate Winklers')

nanmean(abs(Winkler_diff))
nanstd(abs(Winkler_diff))

%% non linear multiple regression with non-averaged OOI Winkler values 
% Oxygen solubility calculated using GSW Toolbox 
% Model variables 

X = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs]];
bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use = [btlsum_tbl.Winkler1_umolkg; btlsum_tbl.Winkler2_umolkg];
pdens = [btlsum_tbl.prho; btlsum_tbl.prho];

% SBE functional form 
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0 = [cal.SOC 0]; % Starting values for coefficient iterations 
outlier_method = 'median';

%Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
%functional form using all Winklers_umolkg (from calibrated T/S data) 
% Run non linear model fit with all Winkler/CTD oxygen (volts) values
mdl1 = fitnlm(X,Winklers_to_use,modelfun,beta0)

figure
histfit(mdl1.Residuals.raw)
title('SOC_k Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,outlier_method) == 1);
mdl2 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers1)

figure
histfit(mdl2.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl2.Residuals.raw,outlier_method) == 1);
Winkler_outliers2 = [ind; Winkler_outliers1];
% Exclude outliers from NLMR model 
mdl3 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers2)

figure
histfit(mdl3.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl3.Residuals.raw,outlier_method) == 1);
Winkler_outliers3 = [ind; Winkler_outliers2];
% Exclude outliers from NLMR model 
mdl4 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers3)

figure
histfit(mdl4.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl4.Residuals.raw,outlier_method) == 1);
Winkler_outliers4 = [ind; Winkler_outliers3];
% Exclude outliers from NLMR model 
mdl5 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers4)

figure
histfit(mdl5.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 6 
ind = find(isoutlier(mdl5.Residuals.raw,outlier_method) == 1);
Winkler_outliers5 = [ind; Winkler_outliers4];
% Exclude outliers from NLMR model 
mdl6 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers5)

figure
histfit(mdl6.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 6')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

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
cal.gain = cal.SOCcalc/cal.SOC;
cal.Winkler1_outliers = Winkler_outliers6(Winkler_outliers6 < height(btlsum_tbl));
cal.Winkler2_outliers = Winkler_outliers6(Winkler_outliers6 > height(btlsum_tbl) & Winkler_outliers6 < 2*height(btlsum_tbl)) - height(btlsum_tbl);

% Prints which casts/bottles were outliers
out_NLMR = [bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)/44.661/1000.*pdens(Winkler_outliers6)]

f = figure;
f.Position = [100 100 840 500];

%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on
% legend('Winkler1','Winkler22','Location','SW','Orientation','horizontal')

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Cast, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Factory Calibrated CTD-DO (\mumol/kg)')
grid on
sgtitle('Year 1 KN221-04: SOC_k')

mdlcal_k = mdl7;
cal.SOCcalc = mdlcal_k.Coefficients.Estimate(1);
cal.Ecalc = mdlcal_k.Coefficients.Estimate(2);
cal.gain = cal.SOCcalc/cal.SOC;
cal.Winkler_outliers = Winkler_outliers6;
%%
%Plot residuals versus oxygen concentration 
figure
plot(btlsum_tbl.Winkler1_umolkg, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO(\mumol/kg)')
grid on
sgtitle('Year 1 KN221-04: SOC_k')

figure
plot(btlsum_tbl.Winkler1_umolkg, btlsum_tbl.Winkler1_umolkg./DOuncorr_umolkg, '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, btlsum_tbl.Winkler2_umolkg./DOuncorr_umolkg,'.k','Markersize',20)
ylabel('DO Gain (Winkler/CTD)')
xlabel('Winkler DO(\mumol/kg)')
grid on
sgtitle('Year 1 KN221-04: SOC_k')


figure
plot(btlsum_tbl.Winkler1_umolkg, DOuncorr_umolkg, '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, DOuncorr_umolkg,'.k','Markersize',20)
ylabel('DO Uncorrected')
xlabel('Winkler DO(\mumol/kg)')
grid on
sgtitle('Year 1 KN221-04: SOC_k')

%% For just Cast 6, Wire Following Profiler 
% Same oxygen sensor for whole cruise 

X = [btlsum_tbl.oxy_volts, btlsum_tbl.O2sol_umolkg, btlsum_tbl.t, btlsum_tbl.prs];
% Winklers_to_use = btlsum_tbl.Winkler1_umolkg;

% Use only these Winklers for regression 
cast_ind = btlsum_tbl.Cast ==6;
Winklers_to_use = btlsum_tbl.Winkler1_umolkg; 
Winklers_to_use(cast_ind == 0) = NaN; 

% SBE functional form 
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0 = [cal.SOC 0]; % Starting values for coefficient iterations 

%Non linear multiple regression to get b1 (SOC) from SBE
%functional form using all Winklers 
mdl1 = fitnlm(X,Winklers_to_use,modelfun,beta0)

figure
histfit(mdl1.Residuals.Raw)
title('Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,'median') == 1);
mdl2 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers1)

figure
histfit(mdl2.Residuals.Raw)
title('Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl2.Residuals.Raw,'median') == 1);
Winkler_outliers2 = [ind; Winkler_outliers1];
% Exclude outliers from NLMR model 
mdl3 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers2)

figure
histfit(mdl3.Residuals.Raw)
title('Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl3.Residuals.Raw,'median') == 1);
Winkler_outliers3 = [ind; Winkler_outliers2];
% Exclude outliers from NLMR model 
mdl4 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers3)

figure
histfit(mdl4.Residuals.Raw)
title('Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl4.Residuals.Raw,'median') == 1);
Winkler_outliers4 = [ind; Winkler_outliers3];
% Exclude outliers from NLMR model 
mdl5 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers4)

figure
histfit(mdl5.Residuals.Raw)
title('Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 6 
ind = find(isoutlier(mdl5.Residuals.Raw,'median') == 1);
Winkler_outliers5 = [ind; Winkler_outliers4];
% Exclude outliers from NLMR model 
mdl6 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers5)

figure
histfit(mdl6.Residuals.Raw)
title('Residuals with Outliers Removed, it = 6')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 7 
ind = find(isoutlier(mdl6.Residuals.Raw,'median') == 1);
Winkler_outliers6 = [ind; Winkler_outliers5];
% Exclude outliers from NLMR model 
mdl7 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers6)

figure
histfit(mdl7.Residuals.Raw)
title('Residuals with Outliers Removed, it = 7')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

%Plot residuals versus pressure, time, station, DO concentration with outliers removed   
mdlcal6 = mdl7;

cal.SOCcalc6 = mdlcal6.Coefficients.Estimate(1);
cal.Ecalc6 = mdlcal6.Coefficients.Estimate(2); 
cal.gain6 = cal.SOCcalc6/cal.SOC;
cal.Winkler_outliers6 = Winkler_outliers6;

% Sets outliers from SOCk 
btlsum_tbl.NLMR_Outlier1 = ones(size(btlsum_tbl.prs)); % Sets all Winklers to 1 (not evaluated)
btlsum_tbl.NLMR_Outlier2 = ones(size(btlsum_tbl.prs)); % Sets all Winklers to 1 (not evaluated)
btlsum_tbl.NLMR_Outlier1(cast_ind ==1) = 2; % Overrides Casts 2 and 4 to value 2 (acceptable)
btlsum_tbl.NLMR_Outlier2(cast_ind ==1) = 2; % Overrides Casts 2 and 4 to value 2 (acceptable)
btlsum_tbl.NLMR_Outlier1(cal.Winkler_outliers6) = 3; % Questionable from NLMR
btlsum_tbl.NLMR_Outlier1(isnan(btlsum_tbl.Winkler1_umolkg)) = 9; % QC flag for missing data 
btlsum_tbl.NLMR_Outlier2(isnan(btlsum_tbl.Winkler2_umolkg)) = 9; % QC flag for missing data 

f = figure;
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal6.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on
% legend('HIP1','HIP2','Location','SW','Orientation','horizontal')

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal6.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal6.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(DOuncorr_umolkg, mdlcal6.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Factory Calibrated CTD-DO (\mumol/kg)')
grid on
sgtitle('Year 1 KN221-04 Cast 6: SOC_k')

%% Decided on SOC calibration 
SOC_type = 1;

% Calibration to use from Cast 6
calused = cal;
calused.SOCcalc = cal.SOCcalc6;
calused.Ecalc = cal.Ecalc6; 
calused.Winkler_outliers = cal.Winkler_outliers6;

btlsum_tbl = calibrate_CTD_oxygen(btlsum_tbl,cal,SOC_type);

figure
plot(btlsum_tbl.Winkler1_umolkg, btlsum_tbl.DOcorr_umolkg, '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20)
ylabel('DO Gain (Winkler/CTD)')
xlabel('Winkler DO(\mumol/kg)')
grid on
sgtitle('Year 1 KN221-04: SOC_k')
%%
blue = [0     0.44706     0.74118];
f = figure;
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs(btlsum_tbl.Cast == 6), btlsum_tbl.Winkler1_umolkg(btlsum_tbl.Cast == 6)-btlsum_tbl.DOcorr_umolkg(btlsum_tbl.Cast == 6), '.','Markersize',20,'Color',blue); 
hold on
plot(btlsum_tbl.prs, btlsum_tbl.Winkler1_umolkg-btlsum_tbl.DOcorr_umolkg, '.k','Markersize',20); 
plot(btlsum_tbl.prs, btlsum_tbl.Winkler2_umolkg-btlsum_tbl.DOcorr_umolkg, '.k','Markersize',20);
plot(btlsum_tbl.prs(btlsum_tbl.Cast == 6), btlsum_tbl.Winkler1_umolkg(btlsum_tbl.Cast == 6)-btlsum_tbl.DOcorr_umolkg(btlsum_tbl.Cast == 6), '.','Markersize',20,'Color',blue); 
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on
legend('Cast 6','Other Casts','Location','SE')

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, btlsum_tbl.Winkler1_umolkg-btlsum_tbl.DOcorr_umolkg, '.k','Markersize',20); hold on;
plot(btlsum_tbl.Cast, btlsum_tbl.Winkler2_umolkg-btlsum_tbl.DOcorr_umolkg, '.k','Markersize',20);
plot(btlsum_tbl.Cast(btlsum_tbl.Cast == 6), btlsum_tbl.Winkler1_umolkg(btlsum_tbl.Cast == 6)-btlsum_tbl.DOcorr_umolkg(btlsum_tbl.Cast == 6), '.','Markersize',20,'Color',blue);
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, btlsum_tbl.Winkler1_umolkg-btlsum_tbl.DOcorr_umolkg, '.k','Markersize',20); hold on;
plot(btlsum_tbl.t, btlsum_tbl.Winkler2_umolkg-btlsum_tbl.DOcorr_umolkg, '.k','Markersize',20);
plot(btlsum_tbl.t(btlsum_tbl.Cast == 6), btlsum_tbl.Winkler1_umolkg(btlsum_tbl.Cast == 6)-btlsum_tbl.DOcorr_umolkg(btlsum_tbl.Cast == 6), '.','Markersize',20,'Color',blue);
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg, btlsum_tbl.Winkler1_umolkg-btlsum_tbl.DOcorr_umolkg, '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, btlsum_tbl.Winkler2_umolkg-btlsum_tbl.DOcorr_umolkg, '.k','Markersize',20);
plot(btlsum_tbl.Winkler1_umolkg(btlsum_tbl.Cast == 6), btlsum_tbl.Winkler1_umolkg(btlsum_tbl.Cast == 6)-btlsum_tbl.DOcorr_umolkg(btlsum_tbl.Cast == 6), '.','Markersize',20,'Color',blue);
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('Year 1 KN221-04: SOC_6_k')
%% Save Variables 
btlsum_yr1 = btlsum_tbl;  
if filesave == 1
    clear btlcasts btlfiles btl_dir btl_check btlsum_tbl btlsum
    cd(samp_dir)
    save Year1_DOcal.mat btl* cal mdlcal*
end 
%%
function [btlsum] = combine_btl_files_noCTDcal(btl_file,btlsum,CTD_sen)
    
    % Format structure for conversion to table and convert to table 
    btl = readtable(btl_file,'TextType','string');
    vars = {'Bottle','Date','PrDM','DepSM','Latitude','Longitude','T090C','T190C','C0mS_cm','C1mS_cm','Sbeox0V'};
    btl = btl(:,vars);
    btl.Properties.VariableNames = {'Bottle','Date','prs','depth','lat','lon','temp1','temp2','cond1','cond2','oxy_volts'};
    btl.CTDcal(:) = {'False'};
    btl.CTDcal = string(btl.CTDcal);
    btl.CTDsen(:) = CTD_sen;
    
    % Combine tables by Bottle variable 
%     btlsum0 = join(leah_btl,btl,'Keys','Bottle');
    btlsum = join(btlsum,btl,'Keys','Bottle');  

    if height(btlsum) ~= 1
        btlsum.sal1 = gsw_SP_from_C(btlsum.cond1,btlsum.temp1,btlsum.prs);
        btlsum.sal2 = gsw_SP_from_C(btlsum.cond2,btlsum.temp2,btlsum.prs);
    
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
        btlsum.Winkler1_umolkg = btlsum.Winkler1_mLL*1000*44.661./btlsum.prho; % Winklers 1 
        btlsum.Winkler2_umolkg = btlsum.Winkler2_mLL*1000*44.661./btlsum.prho; % Winklers 2 
    
        % Reorder variables and remove unnecessary ones
        btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2','Discrete_Salinity1_psu','Discrete_Salinity2_psu','CTDcal',...
        'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','Winkler1_mLL','Winkler2_mLL',...
        'Winkler1_umolkg','Winkler2_umolkg','O2sol_umolkg'};
        btlsum = btlsum(:,btlvars);
    end
        
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
    end

    if SOC_type == 3 % SOC varies with cast number 

        x = [x,btlsum.Cast];
        
        % SBE functional form with SOC as a function of cruise time
        btlsum.DOcorr_umolkg = ((cal.SOCrate_cn*x(:,5)) + cal.SOCcalc_cn*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15));
    end

        btlsum.SOC_type = ones(length(btlsum.prs),1)*SOC_type; 


            % Reorder variables and remove unnecessary ones
        btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2','Discrete_Salinity1_psu','Discrete_Salinity2_psu',...
            'CTDcal','CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','O2sol_umolkg','Winkler1_mLL','Winkler2_mLL'...
            'Winkler1_umolkg','NLMR_Outlier1','Winkler2_umolkg','NLMR_Outlier2','SOC_type','DOcorr_umolkg'};
        btlsum = btlsum(:,btlvars);
end