% Set up workspace 
clearvars
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
addpath(genpath('G:\My Drive\Matlab_work\Github\GSW-Matlab'))
addpath(genpath('G:\My Drive\Matlab_work\Github\cmocean'))


cal_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\AR84_02\final_salinity_cal\calibrated_btl_files';
Wink_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\AR84_02\Winkler_csvs'; 
% 
% btl_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\AR84_02\btl_files';  
btl_dir = 'C:\Users\fogaren\Desktop\Irminger_2024\AR84_02\CTDdata\custom_hyst\raw'; % testing new hyst correction 
% btl_dir = 'C:\Users\fogaren\Desktop\Irminger_2024\AR84_02\CTDdata\no_hyst'; % For no hysteresis correction

filesave = 0; % filesave == 1, save calibration output as mat file
% Use Bottle samples to calculate new SOC (gain) and E terms for CTD data
 
%% Combine Winkler data with oxygen voltages and Leah's calibrated product 
cd(cal_dir)
btlfiles = ls('*.cbot_so'); % List of Leah's calibrated bottle files 
btlcasts = str2num(btlfiles(:,9:11)); % Pulls out cast numbers that have bottle files
%
cd(Wink_dir)
% removed duplicate station files to Duplicate_Stations folder
% Looks like they made some type of sal correction at sea
Winkfiles = ls('*.csv'); % List of my processed bottle files 
Winkcasts = str2num(Winkfiles(:,1:3)); % Pulls out cast numbers that have bottle files 
%
cd(btl_dir)
mybtlfiles = ls('*.btl'); % List of my processed bottle files 
mybtlcasts = str2num(mybtlfiles(:,9:11)); % Pulls out cast numbers that have bottle files 

% read in SBE bottle files
SBEbtlfile = [];
for j = 1:height(mybtlcasts)
    SBEbtlfile{mybtlcasts(j)} = readin_SBE_btl(mybtlfiles(j,:));
end

% Removed bottle files that didn't have sal or DO discrete samples 
addpath(cal_dir)
addpath(Wink_dir)
addpath(btl_dir)
%
Winkler_btl = [];
for j = 1:height(Winkcasts)
    Winkler_btl{Winkcasts(j)} = format_Winkler_files(Winkfiles(j,:));
end

%%
% CTD_sen = 1;
CTD_sen = 2; % sensor 1 did not behave normally 
btlsum = []; % Indexes by cast number leah_btl{5} == cast 5; 
for j = 1:height(Winkcasts) % Number of Winker files 
    btlfile_ind = find(btlcasts == Winkcasts(j)); % because not every cast has sal and winkler bottles 
    mybtlfile_ind = find(mybtlcasts == Winkcasts(j)); 
    btlsum{Winkcasts(j)} = combine_btl_files(Winkler_btl{Winkcasts(j)},btlfiles(btlfile_ind,:),SBEbtlfile{Winkcasts(j)},CTD_sen);
end

% Pull all bottle files and create one large table 
btlsum_tbl = [];
for j = 1:length(btlsum)
    btlsum_tbl = [btlsum_tbl; btlsum{j}];
end
%
if CTD_sen == 1
    % Oxygen, SBE 43
    % From SBE factory calibration 
    % Serial number 0449, Calibration Date 06-Mar-24
    cal.SOC = 4.63190e-001;
    cal.VOFFSET = -4.88200e-001;
    cal.A = -5.35510e-003;
    cal.B = 2.42950e-004; 
    cal.C = -3.49330e-006;
    cal.E = 3.60000e-002;
    cal.Tau20 = 1.19000e+000;
    cal.INSTRUMENT_TYPE = 'SBE43';
    cal.SERIALNO = '0072';
    cal.OCALDATE = '03-Oct-23';
    cal0 = cal; 
elseif CTD_sen == 2
    % Oxygen, SBE 43, 2
    % From SBE factory calibration 
    % Serial number 0449, Calibration Date 06-Mar-24
    cal.SOC = 3.81570e-001;
    cal.VOFFSET = -7.17000e-001;
    cal.A = -3.49850e-003;
    cal.B = 1.49470e-004; 
    cal.C = -2.69920e-006;
    cal.E = 3.60000e-002;
    cal.Tau20 = 1.12000e+000;
    cal.INSTRUMENT_TYPE = 'SBE43';
    cal.SERIALNO = '0449';
    cal.OCALDATE = '06-Mar-24';
    cal0 = cal; 
end


%% Whole cruise data 

% Oxygen solubility calculated using GSW Toolbox 
% Model variables 
% X = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
% 

btlsum_tbl = [];
for j = 1:length(btlsum)
    btlsum_tbl = [btlsum_tbl; btlsum{j}];
end

%  Use casts with bottles > 1000 to tweak the E term for the cruise 
deep_btls = find(btlsum_tbl.prs > 1000); 
group_deep = unique(btlsum_tbl.Cast(deep_btls));
good = group_deep; 
btlsum_tbl = [];
for j = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(j)}];
end

if CTD_sen == 1
    btlsum_tbl.oxy_volts = btlsum_tbl.oxy_volts1; % Duplicate sensors
elseif CTD_sen == 2
    btlsum_tbl.oxy_volts = btlsum_tbl.oxy_volts2; % Duplicate sensors
end

% Treats Winklers as individual points 
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

% beta0 = [cal.SOC 0]; % Starting values for coefficient iterations 
beta0 = [cal.SOC 0]; 
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
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,'median') == 1);
mdl2 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers1)

figure
histfit(mdl2.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl2.Residuals.raw,'median') == 1);
Winkler_outliers2 = [ind; Winkler_outliers1];
% Exclude outliers from NLMR model 
mdl3 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers2)

figure
histfit(mdl3.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl3.Residuals.raw,'median') == 1);
Winkler_outliers3 = [ind; Winkler_outliers2];
% Exclude outliers from NLMR model 
mdl4 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers3)

figure
histfit(mdl4.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl4.Residuals.raw,'median') == 1);
Winkler_outliers4 = [ind; Winkler_outliers3];
% Exclude outliers from NLMR model 
mdl5 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers4)

figure
histfit(mdl5.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 6 
ind = find(isoutlier(mdl5.Residuals.raw,'median') == 1);
Winkler_outliers5 = [ind; Winkler_outliers4];
% Exclude outliers from NLMR model 
mdl6 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers5)

figure
histfit(mdl6.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 6')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 7 
ind = find(isoutlier(mdl6.Residuals.raw,'median') == 1);
Winkler_outliers6 = [ind; Winkler_outliers5];
% Exclude outliers from NLMR model 
mdl7 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers6)
%% Deep AR84-02 with SOCk
%Plot residuals versus pressure, time, station, DO concentration with outliers removed   
mdlcal_k = mdl7;
cal.SOCcalc = mdlcal_k.Coefficients.Estimate(1);
cal.Ecalc = mdlcal_k.Coefficients.Estimate(2);
cal.gain = cal.SOCcalc/cal.SOC;
cal.Winkler1_outliers = Winkler_outliers6(Winkler_outliers6 < height(btlsum_tbl));
cal.Winkler2_outliers = Winkler_outliers6(Winkler_outliers6 > height(btlsum_tbl) & Winkler_outliers6 < 2*height(btlsum_tbl)) - height(btlsum_tbl);

out_NLMR = sortrows([bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)/44.661/1000.*pdens(Winkler_outliers6)],[1 2])
%
f = figure;
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

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
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle(['AR84-02: SOC_k CTD Sensor ' num2str(CTD_sen)])

% Rename the calibration for all casts for the cruise 
cal_all = cal;
%% Break into groups to optimize cal.
%  Sensor 2, Group 1: Stations 1-28 SOC cn

group1 = [1:28]; 
good = group1; 
btlsum_tbl = [];
for j = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(j)}];
end
if CTD_sen == 1
    btlsum_tbl.oxy_volts = btlsum_tbl.oxy_volts1; % Duplicate sensors
elseif CTD_sen == 2
    btlsum_tbl.oxy_volts = btlsum_tbl.oxy_volts2; % Duplicate sensors
end

% Treats Winklers as individual points 
X = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs]];
bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use = [btlsum_tbl.Winkler1_umolkg; btlsum_tbl.Winkler2_umolkg];
pdens = [btlsum_tbl.prho; btlsum_tbl.prho];

% Calculate drift with variable SOC with time 
% cn = btlsum_tbl.Cast - min(btlsum_tbl.Cast); 
cn = [btlsum_tbl.Cast - 1; btlsum_tbl.Cast - 1];
X_cn = [X, cn]; 

% % SBE functional form with SOC as a function of station with set E term
cal = cal0; 
cal.Ecalc_cn = cal_all.Ecalc;
modelfun_cn = @(b,x)((b(2)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15));

beta0_cn = [cal.SOC 0]; % Starting values for coefficient iterations 

% Solve for E term 
% cal = cal0;
% modelfun_cn = @(b,x)((b(3)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
%     .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%     .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));
% 
% beta0_cn = [cal.SOC 0 0]; % Starting values for coefficient iterations 
 
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

%% Save cal for group 1 
mdlcal_cn = mdl_cn5;
% cal for SOC_dt 
cal.SOCcalc_cn = mdlcal_cn.Coefficients.Estimate(1);
cal.SOCrate_cn = mdlcal_cn.Coefficients.Estimate(2);

% cal.SOCcalc_cn = mdlcal_cn.Coefficients.Estimate(1);
% cal.Ecalc_cn = mdlcal_cn.Coefficients.Estimate(2);
% cal.SOCrate_cn = mdlcal_cn.Coefficients.Estimate(3); 

cal.gain = cal.SOCcalc_cn/cal.SOC;

cal.Winkler1_outliers_cn = Winkler_outliers4_cn(Winkler_outliers4_cn < height(btlsum_tbl));
cal.Winkler2_outliers_cn = Winkler_outliers4_cn(Winkler_outliers4_cn > height(btlsum_tbl) & Winkler_outliers4_cn < 2*height(btlsum_tbl)) - height(btlsum_tbl);

out_NLMR = sortrows([bad_casts(Winkler_outliers4_cn) btl_check(Winkler_outliers4_cn) Winklers_to_use(Winkler_outliers4_cn)/44.661/1000.*pdens(Winkler_outliers4_cn)],[1 2])

cal.casts = good;
cal.mdl = mdlcal_cn;
cal.out_NLMR_cn = sortrows([bad_casts(Winkler_outliers4_cn) btl_check(Winkler_outliers4_cn) Winklers_to_use(Winkler_outliers4_cn)],[1 2]);
cal1 = cal;

% % For range of SOC
cal1.SOCcalc_cn % SOC at start 
cal1.SOCcalc_cn/cal1.SOC % gain at start 
(btlsum_tbl.Cast(end) - btlsum_tbl.Cast(1))*cal1.SOCrate_cn + cal1.SOCcalc_cn
((btlsum_tbl.Cast(end) - btlsum_tbl.Cast(1))*cal1.SOCrate_cn + cal1.SOCcalc_cn)/cal1.SOC

f = figure(8);
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot([btlsum_tbl.prs; btlsum_tbl.prs], mdlcal_cn.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot([btlsum_tbl.Cast; btlsum_tbl.Cast], mdlcal_cn.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot([btlsum_tbl.t; btlsum_tbl.t], mdlcal_cn.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(Winklers_to_use, mdlcal_cn.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('AR84-02: SOC_c_n Winklers from Group 1')
%% Break into groups to optimize cal.
%  Sensor 2, Group 2: Stations 29-223 SOC cn

group2 = [29:223]; 
good = group2; 
btlsum_tbl = [];
for j = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(j)}];
end
if CTD_sen == 1
    btlsum_tbl.oxy_volts = btlsum_tbl.oxy_volts1; % Duplicate sensors
elseif CTD_sen == 2
    btlsum_tbl.oxy_volts = btlsum_tbl.oxy_volts2; % Duplicate sensors
end

% Treats Winklers as individual points 
X = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs]];
bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use = [btlsum_tbl.Winkler1_umolkg; btlsum_tbl.Winkler2_umolkg];
pdens = [btlsum_tbl.prho; btlsum_tbl.prho];

% Calculate drift with variable SOC with time 
% cn = btlsum_tbl.Cast - min(btlsum_tbl.Cast); 
cn = [btlsum_tbl.Cast - 1; btlsum_tbl.Cast - 1];
X_cn = [X, cn]; 

% SBE functional form with SOC as a function of station with set E term
cal = cal0; 
cal.Ecalc_cn = cal_all.Ecalc;
modelfun_cn = @(b,x)((b(2)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15));

beta0_cn = [cal.SOC 0]; % Starting values for coefficient iterations 

% Solve for E term 
% cal = cal0; 
% modelfun_cn = @(b,x)((b(3)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
%     .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%     .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));
% 
% beta0_cn = [cal.SOC 0 0]; % Starting values for coefficient iterations 

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

%% Save cal for group 2 
mdlcal_cn = mdl_cn5;
% cal for SOC_dt 
cal.SOCcalc_cn = mdlcal_cn.Coefficients.Estimate(1);
cal.SOCrate_cn = mdlcal_cn.Coefficients.Estimate(2);

% cal.SOCcalc_cn = mdlcal_cn.Coefficients.Estimate(1);
% cal.Ecalc_cn = mdlcal_cn.Coefficients.Estimate(2);
% cal.SOCrate_cn = mdlcal_cn.Coefficients.Estimate(3); 

cal.gain = cal.SOCcalc_cn/cal.SOC;

cal.Winkler1_outliers_cn = Winkler_outliers4_cn(Winkler_outliers4_cn < height(btlsum_tbl));
cal.Winkler2_outliers_cn = Winkler_outliers4_cn(Winkler_outliers4_cn > height(btlsum_tbl) & Winkler_outliers4_cn < 2*height(btlsum_tbl)) - height(btlsum_tbl);

out_NLMR = sortrows([bad_casts(Winkler_outliers4_cn) btl_check(Winkler_outliers4_cn) Winklers_to_use(Winkler_outliers4_cn)/44.661/1000.*pdens(Winkler_outliers4_cn)],[1 2])

cal.casts = good;
cal.mdl = mdlcal_cn;
cal.out_NLMR_cn = sortrows([bad_casts(Winkler_outliers4_cn) btl_check(Winkler_outliers4_cn) Winklers_to_use(Winkler_outliers4_cn)],[1 2]);
cal2 = cal;

% % For range of SOC
cal2.SOCcalc_cn % SOC at start 
cal2.SOCcalc_cn/cal2.SOC % gain at start 
(btlsum_tbl.Cast(end) - btlsum_tbl.Cast(1))*cal2.SOCrate_cn + cal2.SOCcalc_cn
((btlsum_tbl.Cast(end) - btlsum_tbl.Cast(1))*cal2.SOCrate_cn + cal2.SOCcalc_cn)/cal2.SOC

f = figure(8);
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot([btlsum_tbl.prs; btlsum_tbl.prs], mdlcal_cn.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot([btlsum_tbl.Cast; btlsum_tbl.Cast], mdlcal_cn.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot([btlsum_tbl.t; btlsum_tbl.t], mdlcal_cn.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(Winklers_to_use, mdlcal_cn.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('AR84-02: SOC_c_n Winklers from Group 2')
%% Sensor 2, Group 3: Stations 224 thru end with SOCk

group3 = [224:266]; 
good = group3; 
btlsum_tbl = [];
for j = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(j)}];
end
if CTD_sen == 1
    btlsum_tbl.oxy_volts = btlsum_tbl.oxy_volts1; % Duplicate sensors
elseif CTD_sen == 2
    btlsum_tbl.oxy_volts = btlsum_tbl.oxy_volts2; % Duplicate sensors
end


% Treats Winklers as individual points 
X = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs]];
bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use = [btlsum_tbl.Winkler1_umolkg; btlsum_tbl.Winkler2_umolkg];
pdens = [btlsum_tbl.prho; btlsum_tbl.prho];

% SBE functional form 
% cal = cal0;
% modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
%     .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%     .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));
% beta0 = [0 0]; % Starting values for coefficient iterations 

cal = cal0;
cal.Ecalc = cal_all.Ecalc;
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));
beta0 = [0]; % Starting values for coefficient iterations 

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
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,'median') == 1);
mdl2 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers1)

figure
histfit(mdl2.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl2.Residuals.raw,'median') == 1);
Winkler_outliers2 = [ind; Winkler_outliers1];
% Exclude outliers from NLMR model 
mdl3 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers2)

figure
histfit(mdl3.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl3.Residuals.raw,'median') == 1);
Winkler_outliers3 = [ind; Winkler_outliers2];
% Exclude outliers from NLMR model 
mdl4 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers3)

figure
histfit(mdl4.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl4.Residuals.raw,'median') == 1);
Winkler_outliers4 = [ind; Winkler_outliers3];
% Exclude outliers from NLMR model 
mdl5 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers4)

figure
histfit(mdl5.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 6 
ind = find(isoutlier(mdl5.Residuals.raw,'median') == 1);
Winkler_outliers5 = [ind; Winkler_outliers4];
% Exclude outliers from NLMR model 
mdl6 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers5)

figure
histfit(mdl6.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 6')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 7 
ind = find(isoutlier(mdl6.Residuals.raw,'median') == 1);
Winkler_outliers6 = [ind; Winkler_outliers5];
% Exclude outliers from NLMR model 
mdl7 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers6)
%% Save cal for group 3
%Plot residuals versus pressure, time, station, DO concentration with outliers removed   
mdlcal_k = mdl7;
cal.SOCcalc = mdlcal_k.Coefficients.Estimate(1);
% cal.Ecalc = mdlcal_k.Coefficients.Estimate(2);
cal.gain = cal.SOCcalc/cal.SOC;
cal.Winkler1_outliers = Winkler_outliers6(Winkler_outliers6 < height(btlsum_tbl));
cal.Winkler2_outliers = Winkler_outliers6(Winkler_outliers6 > height(btlsum_tbl)) - height(btlsum_tbl);
cal.casts = good;
cal.mdl = mdlcal_k; 
cal.out_NLMR = sortrows([bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)/44.661/1000.*pdens(Winkler_outliers6)],[1 2])
cal3 = cal;
%
f = figure(8);
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

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
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle(['AR84-02 Group 3: SOC_k CTD Sensor ' num2str(CTD_sen)])

%%
sgtitle('AR84-02 CTD-DO Package 2: All fits Default Hysteresis')

%% Save outputs for CTD cast calibrations

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
cal = cal3; SOC_type = 1; %%% The line to change 
cast_num = cal.casts;
dummy = [];
clear dummy1
for j = 1:length(cast_num)
    dummy1 = btlsum{cast_num(j)};
    dummy = [dummy; dummy1];
end
group3 = calibrate_CTD_oxygen(dummy,cal,SOC_type);

%%
btlsum_tbl = [group1; group2; group3];
%%
% For output structure
btlsum = []; % Indexes by cast number leah_btl{5} == cast 5; 
btlcasts = unique(btlsum_tbl.Cast); 
for j = 1:length(btlcasts)% Number of bottle summary files 
    btlsum{btlcasts(j)} = btlsum_tbl(btlsum_tbl.Cast == btlcasts(j),:);
end
%% Save data for no hyst

btlsum_tbl_AR8402_nohyst = btlsum_tbl; 
btlsum_AR8402_nohyst = btlsum; 
cal1_nohyst = cal1;
cal2_nohyst = cal2;
cal3_nohyst = cal3; 
clear cal btlsum btlsum_tbl cal0 cal_dir
cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
save AR8402_DOcal_nohyst.mat btlsum_* cal1_nohyst cal2_nohyst cal3_nohyst

%% Save data for default hyst

btlsum_tbl_AR8402_defaultH = btlsum_tbl; 
btlsum_AR8402_defaultH = btlsum; 
cal1_defaultH = cal1;
cal2_defaultH = cal2;
cal3_defaultH = cal3; 
clear cal btlsum btlsum_tbl cal0 cal_dir
cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
save AR8402_DOcal_defaultH.mat btlsum_* cal1_defaultH cal2_defaultH cal3_defaultH


%% Save data for custom hyst

btlsum_tbl_AR8402_custH = btlsum_tbl; 
btlsum_AR8402_custH = btlsum; 
cal1_custH = cal1;
cal2_custH = cal2;
cal3_custH = cal3; 
clear cal btlsum btlsum_tbl cal0 cal_dir
cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
save AR8402_DOcal_custH.mat btlsum_* cal1_custH cal2_custH cal3_custH
%%
function new_Winkbtl = format_Winkler_files(Wink_btl_file)

    % Format structure for conversion to table and convert to table 
    Winkbtl = readtable(Wink_btl_file,'FileType','text');
    % Reorder variables and remove unnecessary ones
    btlvars = {'station','bottle','flask_id','draw_temp','o2mll'};
    Winkbtl = Winkbtl(:,btlvars);
    Winkbtl.Properties.VariableNames = {'Cast','Bottle','flask_id','draw_temp','Winkler_mLL'};

    cast_niskins = unique(Winkbtl.Bottle);
    new_Winkbtl = table; 
    for j = 1:length(cast_niskins)
        ind = find(Winkbtl.Bottle == cast_niskins(j));
        new_Winkbtl.Cruise(j) = "AR84-02";
        new_Winkbtl.Cast(j) = Winkbtl.Cast(ind(1));
        new_Winkbtl.Bottle(j) = Winkbtl.Bottle(ind(1)); 
        new_Winkbtl.Winkler1_mLL(j) = Winkbtl.Winkler_mLL(ind(1));
        new_Winkbtl.draw_temp1(j) = Winkbtl.draw_temp(ind(1)); 
        if length(ind) > 1
            new_Winkbtl.Winkler2_mLL(j) = Winkbtl.Winkler_mLL(ind(2));
            new_Winkbtl.draw_temp2(j) = Winkbtl.draw_temp(ind(2)); 
        elseif length(ind) == 1
            new_Winkbtl.Winkler2_mLL(j) = NaN;
            new_Winkbtl.draw_temp2(j) = NaN; 
        end
        clear ind
    end


end

function btlsum = combine_btl_files(Wink_btl_file,leah_btl_file,my_btl_file,CTD_sen)


    % Format structure for conversion to table and convert to table 
    leah_btl = readtable(leah_btl_file,'FileType','text',NumHeaderLines=4);
    leah_btl.Properties.VariableNames = {'Bottle','prs','temp1','temp2','th190','th290','sal1','sal2','CTDoxy_mLL1','CTDoxy_mLL2','Meas_SAL','Meas_OXYG','QUAL'};
    leah_btl.Meas_SAL(leah_btl.Meas_SAL == -9) = NaN; % replaces no data flag with NaN
    leah_btl.Discrete_Salinity_psu = leah_btl.Meas_SAL;
    leah_btl.Meas_OXYG(leah_btl.Meas_OXYG == -9) = NaN; % replaces no data flag with NaN
    leah_btl.CTDcal(:) = "True"; 

    % Format structure for conversion to table and convert to table 
    btl = my_btl_file;

    vars = {'Bottle','Date','PrDM','DepSM','Latitude','Longitude','Sbeox0V','Sbeox1V'};
    btl = btl(:,vars);
    btl.Properties.VariableNames = {'Bottle','Date','PrDM','depth','lat','lon','oxy_volts1','oxy_volts2'};
    
    btlsum = join(Wink_btl_file,leah_btl,'Keys','Bottle');
    btlsum = join(btlsum,btl,'Keys','Bottle');

    % Decide if using primary or secondary CTD sensor for temp and sal
    if CTD_sen == 1 % primary sensor (use unless something wrong with data)
        btlsum.t = btlsum.temp1; 
        btlsum.SP = btlsum.sal1; 
        btlsum.oxy_volts = btlsum.oxy_volts1;
     end
    
    if CTD_sen == 2 % secondary sensor (use if primary sensor bad)
        btlsum.t = btlsum.temp2; 
        btlsum.SP = btlsum.sal2; 
        btlsum.oxy_volts = btlsum.oxy_volts2;
    end   

    btlsum.CTD_sen = ones(length(btlsum.prs),1)*CTD_sen; 
    btlsum.SA = gsw_SA_from_SP(btlsum.SP,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.CT = gsw_CT_from_t(btlsum.SA,btlsum.t,btlsum.prs);
    btlsum.SA1 = gsw_SA_from_SP(btlsum.sal1,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.CT1 = gsw_CT_from_t(btlsum.SA1,btlsum.temp1,btlsum.prs);
    btlsum.SA2 = gsw_SA_from_SP(btlsum.sal2,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.CT2 = gsw_CT_from_t(btlsum.SA2,btlsum.temp2,btlsum.prs);
    btlsum.pt = gsw_pt_from_CT(btlsum.SA,btlsum.CT);
    btlsum.O2sol_umolkg = gsw_O2sol(btlsum.SA,btlsum.CT,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.rho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,btlsum.prs); % in situ density
    btlsum.prho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,0); % potential density with ref == surf
    btlsum.sigma0 = gsw_sigma0_CT_exact(btlsum.SA,btlsum.CT); % btlsum.prho - 1000 = btlsum.sigma0
    btlsum.Winkler1_umolkg = btlsum.Winkler1_mLL*1000*44.661./btlsum.prho; % uses potential density 
    btlsum.Winkler2_umolkg = btlsum.Winkler2_mLL*1000*44.661./btlsum.prho; % uses potential density 

    btlsum.CT_draw1 = gsw_CT_from_t(btlsum.SA,btlsum.draw_temp1,btlsum.prs);
    btlsum.pt_draw1 = gsw_pt_from_CT(btlsum.SA,btlsum.CT_draw1);
    btlsum.O2sol_umolkg1 = gsw_O2sol(btlsum.SA1,btlsum.CT1,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.O2sol_umolkg_draw1 = gsw_O2sol(btlsum.SA,btlsum.CT_draw1,0,btlsum.lon,btlsum.lat);
    btlsum.prho_draw1 = gsw_rho_CT_exact(btlsum.SA,btlsum.CT_draw1,0); % potential density with ref == surf

    btlsum.CT_draw2 = gsw_CT_from_t(btlsum.SA,btlsum.draw_temp2,btlsum.prs);
    btlsum.pt_draw2 = gsw_pt_from_CT(btlsum.SA,btlsum.CT_draw2);
    btlsum.O2sol_umolkg2 = gsw_O2sol(btlsum.SA2,btlsum.CT2,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.O2sol_umolkg_draw2 = gsw_O2sol(btlsum.SA,btlsum.CT_draw2,0,btlsum.lon,btlsum.lat);
    btlsum.prho_draw2 = gsw_rho_CT_exact(btlsum.SA,btlsum.CT_draw2,0); % potential density with ref == surf

    btlsum.Winkler1_umolkg_draw = btlsum.Winkler1_mLL*1000*44.661./btlsum.prho_draw1; % uses potential density 
    btlsum.Winkler2_umolkg_draw = btlsum.Winkler2_mLL*1000*44.661./btlsum.prho_draw2; % uses potential density 
    
    % Reorder variables and remove unnecessary ones
    btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','draw_temp1','draw_temp2','sal1','sal2','oxy_volts1','oxy_volts2',...
        'Discrete_Salinity_psu','CTDcal','CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','Winkler1_mLL','Winkler2_mLL'...
        'Winkler1_umolkg','Winkler2_umolkg','Winkler1_umolkg_draw','Winkler2_umolkg_draw','O2sol_umolkg','O2sol_umolkg1','O2sol_umolkg2','O2sol_umolkg_draw1','O2sol_umolkg_draw2'};
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
    end

    if SOC_type == 3 % SOC varies with cast number 
        cnx = btlsum.Cast - min(cal.casts);
        x = [x,cnx];
        
        % SBE functional form with SOC as a function of cruise time
        btlsum.DOcorr_umolkg = ((cal.SOCrate_cn*x(:,5)) + cal.SOCcalc_cn*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15));

        cal.Winkler1_outliers = cal.Winkler1_outliers_cn;
        cal.Winkler2_outliers = cal.Winkler2_outliers_cn;
    end

        btlsum.SOC_type = ones(length(btlsum.prs),1)*SOC_type;

        % Sets outliers from NLMR 
        btlsum.NLMR_Outlier1 = ones(size(btlsum.prs))*2; % Sets all Winklers to 2 (acceptable)
        btlsum.NLMR_Outlier1(cal.Winkler1_outliers) = 3; % Questionable from NLMR
        btlsum.NLMR_Outlier1(isnan(btlsum.Winkler1_umolkg)) = 9; % QC flag for missing data 

        btlsum.NLMR_Outlier2 = ones(size(btlsum.prs))*2; % Sets all Winklers to 2 (acceptable)
        btlsum.NLMR_Outlier2(cal.Winkler2_outliers) = 3; % Questionable from NLMR
        btlsum.NLMR_Outlier2(isnan(btlsum.Winkler2_umolkg)) = 9; % QC flag for missing data 

        % btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','CTDcal','CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','O2sol_umolkg','Winkler_umolL',...
        %     'Winkler_umolkg','SOC_type','NLMR_Outlier','DOcorr_umolkg'};
        % btlsum = btlsum(:,btlvars);
end
