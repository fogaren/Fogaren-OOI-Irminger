% Set up workspace 
clearvars
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')

% Read in calibrated bottle files, Winkler sample values and oxygen files
% processed with default hysteresis correction and user-determined time lag
% correction 
btl_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Bottle_Files\Year5';
cal_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year5\Final_From_Leah';
samp_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year5'; % Winkler file location 
% Winkler_file = 'Irminger_Sea-05_AR30-03_Combo_Winklers_KF.xlsx'; % Winkler file name 
Winkler_file = 'Irminger5_WinklerSamples_KF_June2023.xlsx'; % Winkler file name 
filesave = 0; % filesave == 1, save calibration output as mat file

% Use Bottle samples to calculate new SOC (gain) and E terms for CTD data 
CTD_sen = 2; % Use primary or secondary CTD temp and sal

% Read in Winkler file 
cd(samp_dir)
Winklers = readtable(Winkler_file,'TextType','string');
% Winklers.Winkler_mLL = double(Winklers.Winkler_mLL);
Winklers.Winkler_OOI_mLL = double(Winklers.Winkler_OOI_mLL);
Winklers.Winkler1_HIP_mLL = double(Winklers.Winkler1_HIP_mLL);
Winklers.Winkler2_HIP_mLL = double(Winklers.Winkler2_HIP_mLL);
Winklers.Discrete_Salinity_psu = double(Winklers.Discrete_Salinity_psu);

%%
cd(cal_dir)

% Removed bottle casts before cast 5 (no Winklers)
btlfiles = ls('*.cbot_s'); % List of Leah's calibrated bottle files 
btlcasts = str2num(btlfiles(:,9:11)); % Pulls out cast numbers that have bottle files 

cd(btl_dir)
mybtlfiles = ls('*.csv'); % List of my processed bottle files 
mybtlcasts = str2num(mybtlfiles(:,8:10)); % Pulls out cast numbers that have bottle files 

% Make sure that there is a Leah bottle file for each of my bottle files 
if mybtlcasts == btlcasts 
    disp('Btl Casts Line Up')
    addpath(cal_dir)
    addpath(btl_dir)
    
else
    disp('Caution: Issue with Btl Cast Numbers!')
end
%%
btlsum = []; % Indexes by cast number leah_btl{5} == cast 5; 
% Combine files and calculate sea water properties for CTD sensor number 
for i = 1:height(btlcasts) % Number of bottle summary files 
    btlsum{btlcasts(i)} = combine_btl_files(btlfiles(i,:),mybtlfiles(i,:),Winklers(Winklers.Cast == btlcasts(i),:),CTD_sen) ;
end

% Pull all bottle files and create one large table 
btlsum_tbl = [];
for i = 1:length(btlsum)
    btlsum_tbl = [btlsum_tbl; btlsum{i}];
end
btl_num = unique(btlsum_tbl.Cast);

% Same Oxygen Sensor for whole cruise 
% Calibration standards from SBE xmlcon file 

cal.SOC = double(4.61460e-001);
cal.VOFFSET = double(-5.04500e-001);
cal.A = double(-3.49610e-003);
cal.B = double(1.57460e-004);
cal.C = double(-2.32160e-006);
cal.E = double(3.60000e-002);
cal.Tau20 = double(1.00000e+000);
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '0113';
cal.OCALDATE = '09-May-17';

H = [-0.033, 5000, 1450]; % Default 

cal10 = cal; % To calc gain and SOC for just cast 10
cal21 = cal; % To calc gain and SOC for just cast 21 

%% Difference between HIP and OOI Winklers vs. Pressure, Cast, Temp, CTD-DO

Winkler_diff = btlsum_tbl.Winkler1_HIP_umolkg - btlsum_tbl.Winkler_OOI_umolkg;
% Winkler_diff = btlsum_tbl.Winkler2_HIP_umolkg - btlsum_tbl.Winkler2_HIP_umolkg;

figure %Difference between 
subplot(2,2,1)
plot(btlsum_tbl.prs, Winkler_diff,'.k','Markersize',20); hold on
ylabel({'HIP Winkler - OOI Winkler','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number 
subplot(2,2,2)
plot(btlsum_tbl.Cast, Winkler_diff, 'k.','Markersize',20); hold on;
ylabel({'HIP Winkler - OOI Winkler','(\mumol/kg)'})
xlabel('Cast Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, Winkler_diff, 'k.','Markersize',20); hold on;
ylabel({'HIP Winkler - OOI Winkler','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

x = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
  .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
  .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(DOuncorr_umolkg, Winkler_diff, 'k.','Markersize',20); hold on;
ylabel({'HIP Winkler - OOI Winkler','(\mumol/kg)'})
xlabel('Factory Calibrated CTD-DO (\mumol/kg)')
grid on
sgtitle('AR30-03: HIP vs OOI Winklers')

figure % Winkler concentration
subplot(2,2,1)
plot(btlsum_tbl.prs, btlsum_tbl.Winkler1_HIP_umolkg,'.','Markersize',20); hold on
plot(btlsum_tbl.prs, btlsum_tbl.Winkler_OOI_umolkg,'.','Markersize',20);
ylabel({'Winkler','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number 
subplot(2,2,2)
plot(btlsum_tbl.Cast, btlsum_tbl.Winkler1_HIP_umolkg, '.','Markersize',20); hold on;
plot(btlsum_tbl.Cast, btlsum_tbl.Winkler_OOI_umolkg, '.','Markersize',20);
ylabel({'Winkler','(\mumol/kg)'})
xlabel('Cast Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, btlsum_tbl.Winkler1_HIP_umolkg, '.','Markersize',20); hold on;
plot(btlsum_tbl.t, btlsum_tbl.Winkler_OOI_umolkg, '.','Markersize',20);
ylabel({'Winkler','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(DOuncorr_umolkg, btlsum_tbl.Winkler1_HIP_umolkg, '.','Markersize',20); hold on;
plot(DOuncorr_umolkg, btlsum_tbl.Winkler_OOI_umolkg, '.','Markersize',20);
ylabel({'Winkler','(\mumol/kg)'})
xlabel('Factory Calibrated CTD-DO (\mumol/kg)')
grid on
sgtitle('AR30-03: HIP vs OOI Winklers')
% %% non linear multiple regression with just OOI Winkler data (excludes cast 10) 
% % Oxygen solubility calculated using GSW Toolbox 
% % Model variables 
% X = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
% % 
% ind = find(btlsum_tbl.Cast == 10 | btlsum_tbl.Cast == 21);
% Winklers_to_use = [btlsum_tbl.Winkler_OOI_umolkg];
% Winklers_to_use(ind) = NaN; 
% 
% % SBE functional form 
% modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
%     .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%     .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));
% 
% beta0 = [cal.SOC 0]; % Starting values for coefficient iterations 
% 
% %Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
% %functional form using all Winklers_umolkg (from calibrated T/S data) 
% % Run non linear model fit with all Winkler/CTD oxygen (volts) values
% mdl1 = fitnlm(X,Winklers_to_use,modelfun,beta0)
% 
% figure
% histfit(mdl1.Residuals.raw)
% title('SOC_k Residuals with Outliers, it = 1')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
% 
% % Find outliers based on median filter it = 2 
% Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,'median') == 1);
% mdl2 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers1)
% 
% figure
% histfit(mdl2.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 2')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
% 
% % Find outliers based on median filter it = 3 
% ind = find(isoutlier(mdl2.Residuals.raw,'median') == 1);
% Winkler_outliers2 = [ind; Winkler_outliers1];
% % Exclude outliers from NLMR model 
% mdl3 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers2)
% 
% figure
% histfit(mdl3.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 3')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
% 
% % Find outliers based on median filter it = 4 
% ind = find(isoutlier(mdl3.Residuals.raw,'median') == 1);
% Winkler_outliers3 = [ind; Winkler_outliers2];
% % Exclude outliers from NLMR model 
% mdl4 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers3)
% 
% figure
% histfit(mdl4.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 4')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
% 
% % Find outliers based on median filter it = 5 
% ind = find(isoutlier(mdl4.Residuals.raw,'median') == 1);
% Winkler_outliers4 = [ind; Winkler_outliers3];
% % Exclude outliers from NLMR model 
% mdl5 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers4)
% 
% figure
% histfit(mdl5.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 5')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
% 
% % Find outliers based on median filter it = 6 
% ind = find(isoutlier(mdl5.Residuals.raw,'median') == 1);
% Winkler_outliers5 = [ind; Winkler_outliers4];
% % Exclude outliers from NLMR model 
% mdl6 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers5)
% 
% figure
% histfit(mdl6.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 6')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
% 
% % Find outliers based on median filter it = 7 
% ind = find(isoutlier(mdl6.Residuals.raw,'median') == 1);
% Winkler_outliers6 = [ind; Winkler_outliers5];
% % Exclude outliers from NLMR model 
% mdl7 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers6)
% 
% figure
% histfit(mdl7.Residuals.Raw)
% title('SOC_k Residuals with Outliers Removed, it = 7')
% ylabel('Frequency')
% xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
% 
% %Plot residuals versus pressure, time, station, DO concentration with outliers removed   
% mdlcal_k = mdl7;
% cal.SOCcalc = mdlcal_k.Coefficients.Estimate(1);
% cal.Ecalc = mdlcal_k.Coefficients.Estimate(2);
% cal.gain = cal.SOCcalc/cal.SOC;
% cal.Winkler_outliers = Winkler_outliers6;
% 
% figure
% %Plot residuals versus pressure 
% subplot(2,2,1)
% plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw, 'k.','Markersize',20); hold on;
% ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
% xlabel('Pressure (db)')
% grid on
% 
% %Plot residuals versus cast number/time 
% subplot(2,2,2)
% plot(datenum(btlsum_tbl.Date) - min(datenum(btlsum_tbl.Date)), mdlcal_k.Residuals.raw, 'k.','Markersize',20); hold on;
% ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
% xlabel(['Days since ' datestr(min(datenum(btlsum_tbl.Date)))])
% grid on
% 
% %Plot residuals versus temperature 
% subplot(2,2,3)
% plot(btlsum_tbl.t, mdlcal_k.Residuals.raw, 'k.','Markersize',20); hold on;
% ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
% xlabel('Temperature (\circC)')
% grid on
% 
% %Plot residuals versus oxygen concentration 
% subplot(2,2,4)
% plot(btlsum_tbl.Winkler_OOI_umolkg, mdlcal_k.Residuals.raw, 'k.','Markersize',20); hold on;
% ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
% xlabel('Winkler (\mumol/kg)')
% grid on
% sgtitle('Year 5 AR30-03: NLMR SOC_k')
% 
% out_NLMR = [btlsum_tbl.Cast(cal.Winkler_outliers) btlsum_tbl.Bottle(cal.Winkler_outliers) btlsum_tbl.Winkler_OOI_mLL(cal.Winkler_outliers)]

%% non linear multiple regression with non-averaged OOI and HIP values excludes casts 10 and 21 
% Oxygen solubility calculated using GSW Toolbox 
% Model variables 

X = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs; btlsum_tbl.prs]];
bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use = [btlsum_tbl.Winkler1_HIP_umolkg; btlsum_tbl.Winkler2_HIP_umolkg; btlsum_tbl.Winkler_OOI_umolkg];
pdens = [btlsum_tbl.prho; btlsum_tbl.prho; btlsum_tbl.prho];

% X = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
%     [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
%     [btlsum_tbl.t; btlsum_tbl.t],...
%     [btlsum_tbl.prs; btlsum_tbl.prs]];
% bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast];
% btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle];
% Winklers_to_use = [btlsum_tbl.Winkler1_HIP_umolkg; btlsum_tbl.Winkler2_HIP_umolkg];
% pdens = [btlsum_tbl.prho; btlsum_tbl.prho];

ind = find(bad_casts == 10 | bad_casts == 21);
Winklers_to_use(ind) = NaN; 

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

%Plot residuals versus pressure, time, station, DO concentration with outliers removed   
mdlcal_k = mdl7;
cal.SOCcalc = mdlcal_k.Coefficients.Estimate(1);
cal.Ecalc = mdlcal_k.Coefficients.Estimate(2);
cal.gain = cal.SOCcalc/cal.SOC;
cal.HIP_Winkler1_outliers = Winkler_outliers6(Winkler_outliers6 < height(btlsum_tbl));
cal.HIP_Winkler2_outliers = Winkler_outliers6(Winkler_outliers6 > height(btlsum_tbl) & Winkler_outliers6 < 2*height(btlsum_tbl)) - height(btlsum_tbl);
cal.OOI_Winkler_outliers = Winkler_outliers6(Winkler_outliers6 > 2*height(btlsum_tbl) & Winkler_outliers6 < 3*height(btlsum_tbl)) - 2*height(btlsum_tbl);

out_NLMR = [bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)/44.661/1000.*pdens(Winkler_outliers6)]
%%
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
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

x = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
  .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
  .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_HIP_umolkg, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_HIP_umolkg, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Winkler_OOI_umolkg, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('Year 5 AR30-03: SOC_k')

%%
f = figure;
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.','Markersize',20); hold on;
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.','Markersize',20)
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on
legend('HIP1','HIP2','OOI','Location','SW','Orientation','horizontal')

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.','Markersize',20); hold on;
plot(btlsum_tbl.Cast, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.','Markersize',20)
plot(btlsum_tbl.Cast, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.','Markersize',20); hold on;
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.','Markersize',20)
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

x = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
  .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
  .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(DOuncorr_umolkg, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.','Markersize',20); hold on;
plot(DOuncorr_umolkg, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.','Markersize',20)
plot(DOuncorr_umolkg, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Factory Calibrated CTD-DO (\mumol/kg)')
grid on
sgtitle('Year 5 AR30-03: SOC_k')
% %% Use calculated E term to look at drift of SOC in time and by cast number for OOI Winklers 
% Tempcorr = 1 + cal.A*btlsum_tbl.t + cal.B*btlsum_tbl.t.^2 + cal.C*btlsum_tbl.t.^3;
% Prescorr = exp(cal.Ecalc*btlsum_tbl.prs./(btlsum_tbl.t + 273.15));
% 
% % Group SOC calculations by cast number 
% cn = unique(btlsum_tbl.Cast(~isnan(btlsum_tbl.Winkler_OOI_umolkg)));
% 
% % Remove outliers from Winklers 
% btlsum_tbl.Winkler_umolkg_wout_outliers = btlsum_tbl.Winkler_OOI_umolkg;
% btlsum_tbl.Winkler_umolkg_wout_outliers(cal.Winkler_outliers) = NaN;
% 
% % Preallocate arrays 
% driftdt = NaN(1,length(cn));
% SOCdt = NaN(1,length(cn));
% SOCstd = NaN(1,length(cn));
% 
% % Calculate SOC for each Winkler sample 
% SOCcalc = btlsum_tbl.Winkler_umolkg_wout_outliers...
%     ./(Tempcorr.*Prescorr.*btlsum_tbl.O2sol_umolkg.*(btlsum_tbl.oxy_volts+cal.VOFFSET));
% 
% % calculate mean time, mean SOC, and std of SOC by cast number  
% for i = 1:length(cn)
%     driftdt(i) = nanmean(datenum(btlsum_tbl.Date(btlsum_tbl.Cast == cn(i))));
%     SOCdt(i) = nanmean(SOCcalc(btlsum_tbl.Cast == cn(i)));
%     SOCstd(i) = nanstd(SOCcalc(btlsum_tbl.Cast == cn(i)));
% end
% 
% figure
% subplot(1,2,1)
% errorbar(cn,SOCdt,SOCstd,'o')
% ylabel('Calculated SOC')
% grid on
% xlabel('By Cast Number')
% title('By Cast')
% sgtitle('AR390-03: SOC Drift')
% 
% subplot(1,2,2)
% errorbar(driftdt,SOCdt,SOCstd,'o')
% ylabel('Calculated SOC')
% datetick
% grid on
% title('By Time')

%% Same thing for just glider cast 10 
% Same oxygen sensor for whole cruise 

X = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs; btlsum_tbl.prs]];
bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use = [btlsum_tbl.Winkler1_HIP_umolkg; btlsum_tbl.Winkler2_HIP_umolkg; btlsum_tbl.Winkler_OOI_umolkg];
pdens = [btlsum_tbl.prho; btlsum_tbl.prho; btlsum_tbl.prho];

ind = find(bad_casts ~= 10); % For just Cast 10 
Winklers_to_use(ind) = NaN; 

% SBE functional form with E calc from previous model fit above 
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15)); 

beta0 = [cal.SOC]; % Starting values for coefficient iterations 

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
mdlcal10 = mdl7;

cal.SOCcalc10 = mdlcal10.Coefficients.Estimate(1);
cal.gain10 = cal.SOCcalc10/cal.SOC;
cal.HIP_Winkler1_outliers10 = Winkler_outliers6(Winkler_outliers6 < height(btlsum_tbl));
cal.HIP_Winkler2_outliers10 = Winkler_outliers6(Winkler_outliers6 > height(btlsum_tbl) & Winkler_outliers6 < 2*height(btlsum_tbl)) - height(btlsum_tbl);
cal.OOI_Winkler_outliers10 = Winkler_outliers6(Winkler_outliers6 > 2*height(btlsum_tbl) & Winkler_outliers6 < 3*height(btlsum_tbl)) - 2*height(btlsum_tbl);

out_NLMR_cast10 = [bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)/44.661/1000.*pdens(Winkler_outliers6)]

figure
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal10.Residuals.raw(1:height(btlsum_tbl)), '.','Markersize',20); hold on;
plot(btlsum_tbl.prs, mdlcal10.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.','Markersize',20)
plot(btlsum_tbl.prs, mdlcal10.Residuals.raw((height(btlsum_tbl)*2+1):end),'.','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on
legend('HIP1','HIP2','OOI','Location','SW','Orientation','horizontal')

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(datenum(btlsum_tbl.Date) - min(datenum(btlsum_tbl.Date)), mdlcal10.Residuals.raw(1:height(btlsum_tbl)), '.','Markersize',20); hold on;
plot(datenum(btlsum_tbl.Date) - min(datenum(btlsum_tbl.Date)), mdlcal10.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.','Markersize',20)
plot(datenum(btlsum_tbl.Date) - min(datenum(btlsum_tbl.Date)), mdlcal10.Residuals.raw((height(btlsum_tbl)*2+1):end),'.','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel(['Days since ' datestr(min(datenum(btlsum_tbl.Date)))])
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal10.Residuals.raw(1:height(btlsum_tbl)), '.','Markersize',20); hold on;
plot(btlsum_tbl.t, mdlcal10.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.','Markersize',20)
plot(btlsum_tbl.t, mdlcal10.Residuals.raw((height(btlsum_tbl)*2+1):end),'.','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_HIP_umolkg, mdlcal10.Residuals.raw(1:height(btlsum_tbl)), '.','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_HIP_umolkg, mdlcal10.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.','Markersize',20)
plot(btlsum_tbl.Winkler_OOI_umolkg, mdlcal10.Residuals.raw((height(btlsum_tbl)*2+1):end),'.','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('Year 5 AR30-03 Cast 10: NLMR SOC_k with HIP and OOI Winklers')

f = figure;
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
figure(8)
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal10.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.prs, mdlcal10.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.prs, mdlcal10.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal10.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Cast, mdlcal10.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Cast, mdlcal10.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal10.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.t, mdlcal10.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.t, mdlcal10.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_HIP_umolkg, mdlcal10.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_HIP_umolkg, mdlcal10.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Winkler_OOI_umolkg, mdlcal10.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
% sgtitle('Year 5 AR30-03 Cast 10: SOC_k')
%% For just glider cast 21
% Same oxygen sensor for whole cruise 

X = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs; btlsum_tbl.prs]];
bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use = [btlsum_tbl.Winkler1_HIP_umolkg; btlsum_tbl.Winkler2_HIP_umolkg; btlsum_tbl.Winkler_OOI_umolkg];
pdens = [btlsum_tbl.prho; btlsum_tbl.prho; btlsum_tbl.prho];

ind = find(bad_casts ~= 21); % For just Cast 21
Winklers_to_use(ind) = NaN; 

% SBE functional form with E calc from previous model fit above 
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15)); 

beta0 = [cal.SOC]; % Starting values for coefficient iterations 

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
mdlcal21 = mdl7;

cal.SOCcalc21 = mdlcal21.Coefficients.Estimate(1);
cal.gain21 = cal.SOCcalc21/cal.SOC;
cal.HIP_Winkler1_outliers21 = Winkler_outliers6(Winkler_outliers6 < height(btlsum_tbl));
cal.HIP_Winkler2_outliers21 = Winkler_outliers6(Winkler_outliers6 > height(btlsum_tbl) & Winkler_outliers6 < 2*height(btlsum_tbl)) - height(btlsum_tbl);
% no OOI samples so no outliers for cast 21 
out_NLMR_cast21 = [bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)/44.661/1000.*pdens(Winkler_outliers6)]

f = figure;
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal21.Residuals.raw(1:height(btlsum_tbl)), '.','Markersize',20); hold on;
plot(btlsum_tbl.prs, mdlcal21.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on
legend('HIP1','HIP2','Location','SW','Orientation','horizontal')

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal21.Residuals.raw(1:height(btlsum_tbl)), '.','Markersize',20); hold on;
plot(btlsum_tbl.Cast, mdlcal21.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal21.Residuals.raw(1:height(btlsum_tbl)), '.','Markersize',20); hold on;
plot(btlsum_tbl.t, mdlcal21.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_HIP_umolkg, mdlcal21.Residuals.raw(1:height(btlsum_tbl)), '.','Markersize',20); hold on;
plot(btlsum_tbl.Winkler1_HIP_umolkg, mdlcal21.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Factory Calibrated CTD-DO (\mumol/kg)')
grid on
sgtitle('Year 5 AR30-03 Cast 21: NLMR SOC_k with HIP Winklers')

f = figure;
f.Position = [100 100 840 500];
figure(8)
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal21.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.prs, mdlcal21.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal21.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Cast, mdlcal21.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal21.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.t, mdlcal21.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_HIP_umolkg, mdlcal21.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_HIP_umolkg, mdlcal21.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
% sgtitle('Year 5 AR30-03 Cast 21: SOC_k')
%%

% cal10 = cal; cal21 = cal;
% cal10.Ecalc = cal.Ecalc; cal10.SOCcalc = cal.SOCcalc10; % For different DO calibrations 
% cal21.Ecalc = cal.Ecalc; cal21.SOCcalc = cal.SOCcalc21;

OOI_outliers = [cal.OOI_Winkler_outliers; cal.OOI_Winkler_outliers10] ;
HIP1_outliers = [cal.HIP_Winkler1_outliers; cal.HIP_Winkler1_outliers10; cal.HIP_Winkler1_outliers21];
HIP2_outliers = [cal.HIP_Winkler2_outliers; cal.HIP_Winkler2_outliers10; cal.HIP_Winkler2_outliers21];

btlsum_tbl.NLMR_OOI_Outlier = zeros(length(btlsum_tbl.prs),1);
btlsum_tbl.NLMR_OOI_Outlier(OOI_outliers) = 1;

btlsum_tbl.NLMR_HIP1_Outlier = zeros(length(btlsum_tbl.prs),1);
btlsum_tbl.NLMR_HIP1_Outlier(HIP1_outliers) = 1;

btlsum_tbl.NLMR_HIP2_Outlier = zeros(length(btlsum_tbl.prs),1);
btlsum_tbl.NLMR_HIP2_Outlier(HIP2_outliers) = 1;

x = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];

SOC_type = 1; %3; % 1 = constant, % 2 = changes as a function of cruise time % 3 = changes as a function of station number 

btlsum_tbl.DOcorr_umolkg = NaN(height(btlsum_tbl),1);

% DO all but 10 and 21 with general calibration 
ind = find(btlsum_tbl.Cast ~= 10 | btlsum_tbl.Cast ~= 21);
        % SBE functional form without SOC drift 
        btlsum_tbl.DOcorr_umolkg(ind) = cal.SOCcalc*(x(ind,1) + cal.VOFFSET).*x(ind,2)...
        .*(1 + cal.A*x(ind,3) + cal.B*x(ind,3).^2 + cal.C*x(ind,3).^3)...
        .*exp((cal.Ecalc*x(ind,4))./(x(ind,3) + 273.15));

% Do cast 10 calibration 
ind10 = find(btlsum_tbl.Cast == 10);
        btlsum_tbl.DOcorr_umolkg(ind10) = cal.SOCcalc10*(x(ind10,1) + cal.VOFFSET).*x(ind10,2)...
        .*(1 + cal.A*x(ind10,3) + cal.B*x(ind10,3).^2 + cal.C*x(ind10,3).^3)...
        .*exp((cal.Ecalc*x(ind10,4))./(x(ind10,3) + 273.15));

 % Do cast 21 calibration 
ind21 = find(btlsum_tbl.Cast == 21);
        btlsum_tbl.DOcorr_umolkg(ind21) = cal.SOCcalc21*(x(ind21,1) + cal.VOFFSET).*x(ind21,2)...
        .*(1 + cal.A*x(ind21,3) + cal.B*x(ind21,3).^2 + cal.C*x(ind21,3).^3)...
        .*exp((cal.Ecalc*x(ind21,4))./(x(ind21,3) + 273.15));


btlsum_tbl.SOC_type = ones(length(btlsum_tbl.prs),1)*SOC_type; 

    % Reorder variables and remove unnecessary ones
btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2','Discrete_Salinity_psu',...
    'CTDcal','CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','Winkler_OOI_mLL','Winkler1_HIP_mLL','Winkler2_HIP_mLL',...
    'Winkler_OOI_umolkg','Winkler1_HIP_umolkg','Winkler2_HIP_umolkg','O2sol_umolkg',...
    'SOC_type','DOcorr_umolkg','NLMR_OOI_Outlier','NLMR_HIP1_Outlier','NLMR_HIP2_Outlier'};
btlsum_tbl = btlsum_tbl(:,btlvars);

%% Save Variables 
btlsum_yr5 = btlsum_tbl;  
if filesave == 1
    clear btlcasts btlfiles btl_dir btl_check btlsum_tbl btlsum
    cd(samp_dir)
    save Year5_DOcal.mat btl* cal mdlcal*
end 
%%
function [btlsum] = combine_btl_files(leah_btl_file,btl_file,btlsum,CTD_sen)

    % Format structure for conversion to table and convert to table 
    leah_btl = readtable(leah_btl_file,'FileType','text');
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
    btlsum = join(btlsum,btlsum0,'Keys','Bottle');  

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
        btlsum.O2sol_umolkg = gsw_O2sol(btlsum.SA,btlsum.CT,btlsum.prs,btlsum.lon,btlsum.lat);
        btlsum.rho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,btlsum.prs); % in situ density
        btlsum.prho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,0); % potential density with ref == surf
        btlsum.sigma0 = gsw_sigma0_CT_exact(btlsum.SA,btlsum.CT); % btlsum.prho - 1000 = btlsum.sigma0
%         btlsum.Winkler_umolkg = btlsum.Winkler_mLL*1000*44.661./btlsum.prho; % uses potential density
        btlsum.Winkler_OOI_umolkg = btlsum.Winkler_OOI_mLL*1000*44.661./btlsum.prho; % OOI Winklers
        btlsum.Winkler1_HIP_umolkg = btlsum.Winkler1_HIP_mLL*1000*44.661./btlsum.prho; % HIP WInklers 
        btlsum.Winkler2_HIP_umolkg = btlsum.Winkler2_HIP_mLL*1000*44.661./btlsum.prho; % HIP WInklers 
    
        % Reorder variables and remove unnecessary ones
%         btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2','Discrete_Salinity_psu','CTDcal',...
%         'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','Winkler_mLL','Winkler_OOI_mLL','Winkler_HIP_mLL','Winkler_umolkg',...
%         'Winkler_OOI_umolkg','Winkler_HIP_umolkg','O2sol_umolkg'};
        btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2','Discrete_Salinity_psu','CTDcal',...
        'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','Winkler_OOI_mLL','Winkler1_HIP_mLL','Winkler2_HIP_mLL',...
        'Winkler_OOI_umolkg','Winkler1_HIP_umolkg','Winkler2_HIP_umolkg','O2sol_umolkg'};
        btlsum = btlsum(:,btlvars);
    end
        
end

