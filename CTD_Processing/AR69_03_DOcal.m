% Set up workspace 
clearvars
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
run('GeneralSettings.m')

% Read in calibrated bottle files, Winkler sample values and oxygen files
% processed with default hysteresis correction and user-determined time lag
% correction 
btl_dir = 'C:\Users\fogaren\Documents\Python\Bottle_Files\AR69-03'; % my processed bottle product 
samp_dir = 'C:\Users\fogaren\Documents\Python\Bottle_Files\AR69-03'; % processed SBE cnvs
Winkler_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\AR69-03';
Winkler_file = 'AR69_03_winklers_finalized_KF.xlsx';

filesave = 0; % filesave == 1, save calibration output as mat file
% Use Bottle samples to calculate new SOC (gain) and E terms for CTD data 
CTD_sen = 1; % Use primary or secondary CTD temp and sal

% Read in Winkler values, my processed bottle files and Leah's calibrated files and combine them
cd(Winkler_dir)
Winklers = readtable(Winkler_file,'TextType','string');
Winklers.Winkler1_mLL = double(Winklers.Winkler1_mLL);
Winklers.Winkler2_mLL = double(Winklers.Winkler2_mLL);
Winklers.Winkler3_mLL = double(Winklers.Winkler3_mLL);

%% Read in calibrated CTD data from netcdfs 
cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\AR69-03\SOI_Processed')
btlfile = readtable('bottle_data.csv','FileType','text');
vars = {'SSSCC','BTLNBR','CTDPRS','CTDTMP1','CTDTMP2','CTDCOND1','CTDCOND2','CTDSAL','BTL_SAL','CTDOXY',...
    'BTL_OXY','CTDOXY1','CTDOXYVOLTS'};
btlfile = btlfile(:,vars);
newvars = {'Station','Bottle','CTDPRS','CTDTMP1','CTDTMP2','CTDCOND1','CTDCOND2','CTDSAL','BTL_SAL','CTDOXY_umolkg',...
    'BTL_OXY_umolkg','CTDOXY1_mLL','CTDOXYVOLTS'};
btlfile.Properties.VariableNames = newvars;
btlfile.CTDCOND1 = btlfile.CTDCOND1/10; btlfile.CTDCOND2 = btlfile.CTDCOND2/10; % Change cond units 
btlfile = btlfile(2:end,:);
for i = 1:height(btlfile)
    if btlfile.Bottle(i) > 13 % Difference in how bottles were counted on cruise
        btlfile.Bottle(i) = btlfile.Bottle(i)-4;
    end
end
% btlfile.CTDcal(:) = {'True'};
% btlfile.CTDcal = string(btlfile.CTDcal);
btl_num = unique(btlfile.Station); % Stations with bottles 

siobtl = [];
for i = 1:length(btl_num)
    ind = find(btlfile.Station == btl_num(i));
    siobtl{btl_num(i)} = btlfile(ind,:);
end
%%
cd(btl_dir)
mybtlfiles = ls('*.csv'); % List of my processed bottle files 
btlcasts = str2num(mybtlfiles(:,9:11)); % Pulls out cast numbers that have bottle files 
Wink_casts = unique(Winklers.Cast); % Casts with Winklers

btlsum = []; 
for i = 1:length(Wink_casts) % Number of Stations with bottles  
    ind = find(btlcasts == Wink_casts(i));
    btlsum{Wink_casts(i)} = combine_btl_files(siobtl{Wink_casts(i)},mybtlfiles(ind,:),Winklers(Winklers.Cast == Wink_casts(i),:),CTD_sen) ;
end


%%

btlsum_tbl = [];
for i = 1:length(Wink_casts)
    btlsum_tbl = [btlsum_tbl; btlsum{Wink_casts(i)}];
end
% %%
btlsum_tbl.Winkler1_umolkg(btlsum_tbl.Winkler1_umolkg > 316) = NaN;
btlsum_tbl.Winkler2_umolkg(btlsum_tbl.Winkler2_umolkg > 316) = NaN;
btlsum_tbl.Winkler3_umolkg(btlsum_tbl.Winkler3_umolkg > 316) = NaN;

%% same sensor for all casts 
% From SBE factory calibration 
% Serial number 1960, 31-Jul-21
cal.SOC = 4.46780e-001;
cal.VOFFSET = -5.08600e-001;
cal.A = -5.00190e-003;
cal.B = 2.51320e-004; 
cal.C = -3.59380e-006;
cal.E = 3.60000e-002;
cal.Tau20 = 1.22000e+000;
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '1960';
cal.OCALDATE = '31-Jul-21';

H = [-0.033, 5000, 1450]; % Default 

x = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
  .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
  .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));

%%
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
% plot(btlsum_tbl.lat, btlsum_tbl.Winkler1_umolkg - DOuncorr_umolkg,'.k','Markersize',20); hold on;
% plot(btlsum_tbl.lat, btlsum_tbl.Winkler2_umolkg - DOuncorr_umolkg,'.k','Markersize',20)
% plot(btlsum_tbl.lat, btlsum_tbl.Winkler3_umolkg - DOuncorr_umolkg,'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
% xlabel('Latitude (\circ)')
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
sgtitle('AR69-03: Factory Calibrated CTD-DO vs Winklers')

%% non linear multiple regression 
% Oxygen solubility calculated using GSW Toolbox 
% Model variables 
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
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0 = [cal.SOC 0]; % Starting values for coefficient iterations 
% 
% % SBE functional form 
% Ecalc = 0.037244927617521;
% modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
%     .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%     .*exp((Ecalc*x(:,4))./(x(:,3) + 273.15));
% 
% beta0 = [cal.SOC]; % Starting values for coefficient iterations

% Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
% functional form using all Winklers_umolkg (from calibrated T/S data) 
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
cal.Winkler3_outliers = Winkler_outliers6(Winkler_outliers6 > 2*height(btlsum_tbl) & Winkler_outliers6 < 3*height(btlsum_tbl)) - 2*height(btlsum_tbl);
cal.casts = 1:214;
cal.mdl = mdl7;
cal.out_NLMR = sortrows([bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)],[1 2]);
cal_all = cal;
clear cal; 
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

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Winkler3_umolkg, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('AR69-03: SOC_k Winklers from All Groups')
%% Deep Group Use deep casts to calculate E term 
deep = [2:24 38 70:71 78 86:95 106:107 113:126 133 154:155 196:199 207:210];%[1 25:37 39:69 72:77 79:85 96:105 108:112 127:132 134:153 156:195 200:206];
% Use deep casts to calculate E term. 
good = deep;

btlsum_tbl = [];
for i = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(i)}];
end
btlsum_tbl.Winkler1_umolkg(btlsum_tbl.Winkler1_umolkg > 316) = NaN;
btlsum_tbl.Winkler2_umolkg(btlsum_tbl.Winkler2_umolkg > 316) = NaN;
btlsum_tbl.Winkler3_umolkg(btlsum_tbl.Winkler3_umolkg > 316) = NaN;

% same sensor for all casts 
% From SBE factory calibration 
% Serial number 1960, 31-Jul-21
cal.SOC = 4.46780e-001;
cal.VOFFSET = -5.08600e-001;
cal.A = -5.00190e-003;
cal.B = 2.51320e-004; 
cal.C = -3.59380e-006;
cal.E = 3.60000e-002;
cal.Tau20 = 1.22000e+000;
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '1960';
cal.OCALDATE = '31-Jul-21';

%% non linear multiple regression 
% Oxygen solubility calculated using GSW Toolbox 
% Model variables 
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
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0 = [cal.SOC 0]; % Starting values for coefficient iterations 

% Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
% functional form using all Winklers_umolkg (from calibrated T/S data) 
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
cal.Winkler3_outliers = Winkler_outliers6(Winkler_outliers6 > 2*height(btlsum_tbl) & Winkler_outliers6 < 3*height(btlsum_tbl)) - 2*height(btlsum_tbl);
cal.casts = deep;
cal.mdl = mdl7;
cal.out_NLMR = sortrows([bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)],[1 2]);
cal_deep = cal;
clear cal; 
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

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Winkler3_umolkg, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('AR69-03: SOC_k Winklers from Deep Group')


%% Group 1 SOC k, E from Deep Group (cal_deep.Ecalc)

% same sensor for all casts 
% From SBE factory calibration 
% Serial number 1960, 31-Jul-21
cal.SOC = 4.46780e-001;
cal.VOFFSET = -5.08600e-001;
cal.A = -5.00190e-003;
cal.B = 2.51320e-004; 
cal.C = -3.59380e-006;
cal.E = 3.60000e-002;
cal.Tau20 = 1.22000e+000;
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '1960';
cal.OCALDATE = '31-Jul-21';

group1 = 1:2; % SOCk 
good = group1;
btlsum_tbl = [];
for i = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(i)}];
end

btlsum_tbl.Winkler1_umolkg(btlsum_tbl.Winkler1_umolkg > 316) = NaN;
btlsum_tbl.Winkler2_umolkg(btlsum_tbl.Winkler2_umolkg > 316) = NaN;
btlsum_tbl.Winkler3_umolkg(btlsum_tbl.Winkler3_umolkg > 316) = NaN;

% non linear multiple regression 
% Oxygen solubility calculated using GSW Toolbox 
% Model variables 
% Treats Winklers as individual points 
% Use E term calculated using deep Winklers 
 
X = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs; btlsum_tbl.prs]];
bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use = [btlsum_tbl.Winkler1_umolkg; btlsum_tbl.Winkler2_umolkg; btlsum_tbl.Winkler3_umolkg];
pdens = [btlsum_tbl.prho; btlsum_tbl.prho; btlsum_tbl.prho];

% % SBE functional form 
% modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
%     .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%     .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));
% 
% beta0 = [cal.SOC 0]; % Starting values for coefficient iterations 

% SBE functional form with predetermined E term. 
cal.Ecalc = cal_deep.Ecalc;
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));

beta0 = [cal.SOC]; % Starting values for coefficient iterations


% Non linear multiple regression to get b1 (SOC) from SBE
% functional form using all Winklers_umolkg (from calibrated T/S data) 
% Run non linear model fit with all Winkler/CTD oxygen (volts) values
mdl1 = fitnlm(X,Winklers_to_use,modelfun,beta0)

figure
histfit(mdl1.Residuals.raw)
title('SOC_k Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,'median') == 1);
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
cal.Winkler1_outliers = Winkler_outliers6(Winkler_outliers6 < height(btlsum_tbl));
cal.Winkler2_outliers = Winkler_outliers6(Winkler_outliers6 > height(btlsum_tbl) & Winkler_outliers6 < 2*height(btlsum_tbl)) - height(btlsum_tbl);
cal.Winkler3_outliers = Winkler_outliers6(Winkler_outliers6 > 2*height(btlsum_tbl) & Winkler_outliers6 < 3*height(btlsum_tbl)) - 2*height(btlsum_tbl);
cal.casts = good;
cal.mdl = mdlcal_k;
cal.out_NLMR = sortrows([bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)],[1 2]);
cal1 = cal; clear cal 


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

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Winkler3_umolkg, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('AR69-03: SOC_k Winklers from Group 1')

%% Group 2 Irminger Section SOC dt; E term calc from Deep Group  

% same sensor for all casts 
% From SBE factory calibration 
% Serial number 1960, 31-Jul-21
cal.SOC = 4.46780e-001;
cal.VOFFSET = -5.08600e-001;
cal.A = -5.00190e-003;
cal.B = 2.51320e-004; 
cal.C = -3.59380e-006;
cal.E = 3.60000e-002;
cal.Tau20 = 1.22000e+000;
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '1960';
cal.OCALDATE = '31-Jul-21';

group2 = 3:24; % irminger section SOCdt E calc from group 
good = group2;
btlsum_tbl = [];
for i = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(i)}];
end

btlsum_tbl.Winkler1_umolkg(btlsum_tbl.Winkler1_umolkg > 316) = NaN;
btlsum_tbl.Winkler2_umolkg(btlsum_tbl.Winkler2_umolkg > 316) = NaN;
btlsum_tbl.Winkler3_umolkg(btlsum_tbl.Winkler3_umolkg > 316) = NaN;

% Calculate drift with variable SOC with time 
dt = datenum(btlsum_tbl.Date) - datenum(btlsum_tbl.Date(1)); % minus first cast time

X_dt = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs; btlsum_tbl.prs],...
    [dt; dt; dt]];

bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use = [btlsum_tbl.Winkler1_umolkg; btlsum_tbl.Winkler2_umolkg; btlsum_tbl.Winkler3_umolkg];
pdens = [btlsum_tbl.prho; btlsum_tbl.prho; btlsum_tbl.prho];


% SBE functional form with SOC as a function of station 
cal.Ecalc_dt = cal_deep.Ecalc;
modelfun_dt = @(b,x)((b(2)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc_dt*x(:,4))./(x(:,3) + 273.15));

beta0_dt = [cal.SOC 0]; % Starting values for coefficient iterations 

% % SBE functional form with SOC as a function of station 
% modelfun_dt = @(b,x)((b(3)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
%     .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%     .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));
% 
% beta0_dt = [cal.SOC 0 0]; % Starting values for coefficient iterations 

mdl_dt1 = fitnlm(X_dt,Winklers_to_use,modelfun_dt,beta0_dt)

figure
histfit(mdl_dt1.Residuals.Raw)
title('SOC_d_t Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR_d_t output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1_dt = find(isoutlier(mdl_dt1.Residuals.Raw,'median') == 1);
mdl_dt2 = fitnlm(X_dt,Winklers_to_use,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers1_dt)

figure
histfit(mdl_dt2.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl_dt2.Residuals.raw,'median') == 1);
Winkler_outliers2_dt = [ind; Winkler_outliers1_dt];
% Exclude outliers from NLMR model 
mdl_dt3 = fitnlm(X_dt,Winklers_to_use,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers2_dt)

figure
histfit(mdl_dt3.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl_dt3.Residuals.raw,'median') == 1);
Winkler_outliers3_dt = [ind; Winkler_outliers2_dt];
% Exclude outliers from NLMR model 
mdl_dt4 = fitnlm(X_dt,Winklers_to_use,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers3_dt)

figure
histfit(mdl_dt4.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl_dt4.Residuals.raw,'median') == 1);
Winkler_outliers4_dt = [ind; Winkler_outliers3_dt];
% Exclude outliers from NLMR model 
mdl_dt5 = fitnlm(X_dt,Winklers_to_use,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers4_dt)

figure
histfit(mdl_dt5.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

%%
mdlcal_dt = mdl_dt5;
% cal for SOC_dt 
cal.SOCcalc_dt = mdlcal_dt.Coefficients.Estimate(1);
% cal.Ecalc_dt = mdlcal_dt.Coefficients.Estimate(2);
cal.SOCrate_dt = mdlcal_dt.Coefficients.Estimate(2);
cal.gain = cal.SOCcalc_dt/cal.SOC;
cal.Winkler1_outliers_dt = Winkler_outliers4_dt(Winkler_outliers4_dt < height(btlsum_tbl));
cal.Winkler2_outliers_dt = Winkler_outliers4_dt(Winkler_outliers4_dt > height(btlsum_tbl) & Winkler_outliers4_dt < 2*height(btlsum_tbl)) - height(btlsum_tbl);
cal.Winkler3_outliers_dt = Winkler_outliers4_dt(Winkler_outliers4_dt > 2*height(btlsum_tbl) & Winkler_outliers4_dt < 3*height(btlsum_tbl)) - 2*height(btlsum_tbl);
cal.casts = good;
cal.mdl = mdlcal_dt;
cal.out_NLMR_dt = sortrows([bad_casts(Winkler_outliers4_dt) btl_check(Winkler_outliers4_dt) Winklers_to_use(Winkler_outliers4_dt)],[1 2]);
cal2 = cal;
clear cal;

f = figure;
f.Position = [100 100 840 500];
figure(8)
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_dt.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.prs, mdlcal_dt.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.prs, mdlcal_dt.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_dt.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Cast, mdlcal_dt.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Cast, mdlcal_dt.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_dt.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.t, mdlcal_dt.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.t, mdlcal_dt.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg, mdlcal_dt.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, mdlcal_dt.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Winkler3_umolkg, mdlcal_dt.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('AR69-03: SOC_d_t Winklers from Group 2')

% For range of SOC
cal2.SOCcalc_dt
days(btlsum_tbl.Date(end) - btlsum_tbl.Date(1))*cal2.SOCrate_dt + cal2.SOCcalc_dt
(days(btlsum_tbl.Date(end) - btlsum_tbl.Date(1))*cal2.SOCrate_dt + cal2.SOCcalc_dt)/cal2.SOC
%% Group 3 SOC k, E from deep Group 

% same sensor for all casts 
% From SBE factory calibration 
% Serial number 1960, 31-Jul-21
cal.SOC = 4.46780e-001;
cal.VOFFSET = -5.08600e-001;
cal.A = -5.00190e-003;
cal.B = 2.51320e-004; 
cal.C = -3.59380e-006;
cal.E = 3.60000e-002;
cal.Tau20 = 1.22000e+000;
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '1960';
cal.OCALDATE = '31-Jul-21';

group3 = 25:63; % mid section 1 SOCk
good = group3;
btlsum_tbl = [];
for i = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(i)}];
end

btlsum_tbl.Winkler1_umolkg(btlsum_tbl.Winkler1_umolkg > 316) = NaN;
btlsum_tbl.Winkler2_umolkg(btlsum_tbl.Winkler2_umolkg > 316) = NaN;
btlsum_tbl.Winkler3_umolkg(btlsum_tbl.Winkler3_umolkg > 316) = NaN;

% non linear multiple regression 
% Oxygen solubility calculated using GSW Toolbox 
% Model variables 
% Treats Winklers as individual points 
% Use E term calculated using deep Winklers 
 
X = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs; btlsum_tbl.prs]];
bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use = [btlsum_tbl.Winkler1_umolkg; btlsum_tbl.Winkler2_umolkg; btlsum_tbl.Winkler3_umolkg];
pdens = [btlsum_tbl.prho; btlsum_tbl.prho; btlsum_tbl.prho];

% % SBE functional form 
% modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
%     .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%     .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));
% 
% beta0 = [cal.SOC 0]; % Starting values for coefficient iterations 

% SBE functional form with predetermined E
cal.Ecalc = cal_deep.Ecalc; 
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));

beta0 = [cal.SOC]; % Starting values for coefficient iterations 

% Non linear multiple regression to get b1 (SOC) from SBE
% functional form using all Winklers_umolkg (from calibrated T/S data) 
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
cal.Winkler1_outliers = Winkler_outliers6(Winkler_outliers6 < height(btlsum_tbl));
cal.Winkler2_outliers = Winkler_outliers6(Winkler_outliers6 > height(btlsum_tbl) & Winkler_outliers6 < 2*height(btlsum_tbl)) - height(btlsum_tbl);
cal.Winkler3_outliers = Winkler_outliers6(Winkler_outliers6 > 2*height(btlsum_tbl) & Winkler_outliers6 < 3*height(btlsum_tbl)) - 2*height(btlsum_tbl);
cal.casts = good;
cal.mdl = mdlcal_k;
cal.out_NLMR = sortrows([bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)],[1 2]);
cal3 = cal; 
clear cal;


f = figure;
f.Position = [100 100 840 500];
figure(8)
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

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Winkler3_umolkg, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('AR69-03: SOC_k Winklers from Group 3')

%% Group 4 SOC k, E from deep Group 

% same sensor for all casts 
% From SBE factory calibration 
% Serial number 1960, 31-Jul-21
cal.SOC = 4.46780e-001;
cal.VOFFSET = -5.08600e-001;
cal.A = -5.00190e-003;
cal.B = 2.51320e-004; 
cal.C = -3.59380e-006;
cal.E = 3.60000e-002;
cal.Tau20 = 1.22000e+000;
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '1960';
cal.OCALDATE = '31-Jul-21';

group4 = 64:82; % mid section 2 SOCk
good = group4;
btlsum_tbl = [];
for i = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(i)}];
end

btlsum_tbl.Winkler1_umolkg(btlsum_tbl.Winkler1_umolkg > 316) = NaN;
btlsum_tbl.Winkler2_umolkg(btlsum_tbl.Winkler2_umolkg > 316) = NaN;
btlsum_tbl.Winkler3_umolkg(btlsum_tbl.Winkler3_umolkg > 316) = NaN;

% non linear multiple regression 
% Oxygen solubility calculated using GSW Toolbox 
% Model variables 
% Treats Winklers as individual points 
% Use E term calculated using deep Winklers 
 
X = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs; btlsum_tbl.prs]];
bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use = [btlsum_tbl.Winkler1_umolkg; btlsum_tbl.Winkler2_umolkg; btlsum_tbl.Winkler3_umolkg];
pdens = [btlsum_tbl.prho; btlsum_tbl.prho; btlsum_tbl.prho];

% % SBE functional form 
% modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
%     .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%     .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));
% 
% beta0 = [cal.SOC 0]; % Starting values for coefficient iterations 

% SBE functional form with predetermined E
cal.Ecalc = cal_deep.Ecalc; 
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));

beta0 = [cal.SOC]; % Starting values for coefficient iterations 

% Non linear multiple regression to get b1 (SOC) from SBE
% functional form using all Winklers_umolkg (from calibrated T/S data) 
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
cal.Winkler1_outliers = Winkler_outliers6(Winkler_outliers6 < height(btlsum_tbl));
cal.Winkler2_outliers = Winkler_outliers6(Winkler_outliers6 > height(btlsum_tbl) & Winkler_outliers6 < 2*height(btlsum_tbl)) - height(btlsum_tbl);
cal.Winkler3_outliers = Winkler_outliers6(Winkler_outliers6 > 2*height(btlsum_tbl) & Winkler_outliers6 < 3*height(btlsum_tbl)) - 2*height(btlsum_tbl);
cal.casts = good;
cal.mdl = mdlcal_k;
cal.out_NLMR = sortrows([bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)],[1 2]);
cal4 = cal; 
clear cal;


f = figure;
f.Position = [100 100 840 500];
figure(8)
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

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Winkler3_umolkg, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('AR69-03: SOC_k Winklers from Group 4')

%% Group 5 Labrador Section SOC dt; E term calc from Deep Group  

% same sensor for all casts 
% From SBE factory calibration 
% Serial number 1960, 31-Jul-21
cal.SOC = 4.46780e-001;
cal.VOFFSET = -5.08600e-001;
cal.A = -5.00190e-003;
cal.B = 2.51320e-004; 
cal.C = -3.59380e-006;
cal.E = 3.60000e-002;
cal.Tau20 = 1.22000e+000;
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '1960';
cal.OCALDATE = '31-Jul-21';


group5 = 83:99; % lab section 1 SOCdt E from all 
good = group5;
btlsum_tbl = [];
for i = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(i)}];
end

btlsum_tbl.Winkler1_umolkg(btlsum_tbl.Winkler1_umolkg > 316) = NaN;
btlsum_tbl.Winkler2_umolkg(btlsum_tbl.Winkler2_umolkg > 316) = NaN;
btlsum_tbl.Winkler3_umolkg(btlsum_tbl.Winkler3_umolkg > 316) = NaN;

% Calculate drift with variable SOC with time 
dt = datenum(btlsum_tbl.Date) - datenum(btlsum_tbl.Date(1)); % minus first cast time

X_dt = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs; btlsum_tbl.prs],...
    [dt; dt; dt]];

bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use = [btlsum_tbl.Winkler1_umolkg; btlsum_tbl.Winkler2_umolkg; btlsum_tbl.Winkler3_umolkg];
pdens = [btlsum_tbl.prho; btlsum_tbl.prho; btlsum_tbl.prho];


% SBE functional form with SOC as a function of station 
cal.Ecalc_dt = cal_deep.Ecalc;
modelfun_dt = @(b,x)((b(2)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc_dt*x(:,4))./(x(:,3) + 273.15));

beta0_dt = [cal.SOC 0]; % Starting values for coefficient iterations 

% % SBE functional form with SOC as a function of station 
% modelfun_dt = @(b,x)((b(3)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
%     .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%     .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));
% 
% beta0_dt = [cal.SOC 0 0]; % Starting values for coefficient iterations 

mdl_dt1 = fitnlm(X_dt,Winklers_to_use,modelfun_dt,beta0_dt)

figure
histfit(mdl_dt1.Residuals.Raw)
title('SOC_d_t Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR_d_t output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1_dt = find(isoutlier(mdl_dt1.Residuals.Raw,'median') == 1);
mdl_dt2 = fitnlm(X_dt,Winklers_to_use,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers1_dt)

figure
histfit(mdl_dt2.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl_dt2.Residuals.raw,'median') == 1);
Winkler_outliers2_dt = [ind; Winkler_outliers1_dt];
% Exclude outliers from NLMR model 
mdl_dt3 = fitnlm(X_dt,Winklers_to_use,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers2_dt)

figure
histfit(mdl_dt3.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl_dt3.Residuals.raw,'median') == 1);
Winkler_outliers3_dt = [ind; Winkler_outliers2_dt];
% Exclude outliers from NLMR model 
mdl_dt4 = fitnlm(X_dt,Winklers_to_use,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers3_dt)

figure
histfit(mdl_dt4.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl_dt4.Residuals.raw,'median') == 1);
Winkler_outliers4_dt = [ind; Winkler_outliers3_dt];
% Exclude outliers from NLMR model 
mdl_dt5 = fitnlm(X_dt,Winklers_to_use,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers4_dt)

figure
histfit(mdl_dt5.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

%%
mdlcal_dt = mdl_dt5;
% cal for SOC_dt 
cal.SOCcalc_dt = mdlcal_dt.Coefficients.Estimate(1);
cal.gain = cal.SOCcalc_dt/cal.SOC;
cal.SOCrate_dt = mdlcal_dt.Coefficients.Estimate(2);

cal.Winkler1_outliers_dt = Winkler_outliers4_dt(Winkler_outliers4_dt < height(btlsum_tbl));
cal.Winkler2_outliers_dt = Winkler_outliers4_dt(Winkler_outliers4_dt > height(btlsum_tbl) & Winkler_outliers4_dt < 2*height(btlsum_tbl)) - height(btlsum_tbl);
cal.Winkler3_outliers_dt = Winkler_outliers4_dt(Winkler_outliers4_dt > 2*height(btlsum_tbl) & Winkler_outliers4_dt < 3*height(btlsum_tbl)) - 2*height(btlsum_tbl);
cal.casts = good;
cal.mdl = mdlcal_dt;
cal.out_NLMR_dt = sortrows([bad_casts(Winkler_outliers4_dt) btl_check(Winkler_outliers4_dt) Winklers_to_use(Winkler_outliers4_dt)],[1 2]);
cal5 = cal;
clear cal;

f = figure;
f.Position = [100 100 840 500];
figure(8)
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_dt.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.prs, mdlcal_dt.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.prs, mdlcal_dt.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_dt.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Cast, mdlcal_dt.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Cast, mdlcal_dt.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_dt.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.t, mdlcal_dt.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.t, mdlcal_dt.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg, mdlcal_dt.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, mdlcal_dt.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Winkler3_umolkg, mdlcal_dt.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('AR69-03: SOC_d_t Winklers from Group 5')

% For range of SOC
cal5.SOCcalc_dt
days(btlsum_tbl.Date(end) - btlsum_tbl.Date(1))*cal5.SOCrate_dt + cal5.SOCcalc_dt
(days(btlsum_tbl.Date(end) - btlsum_tbl.Date(1))*cal5.SOCrate_dt + cal5.SOCcalc_dt)/cal5.SOC
%% Group 6 SOC k, E from deep Group 

% same sensor for all casts 
% From SBE factory calibration 
% Serial number 1960, 31-Jul-21
cal.SOC = 4.46780e-001;
cal.VOFFSET = -5.08600e-001;
cal.A = -5.00190e-003;
cal.B = 2.51320e-004; 
cal.C = -3.59380e-006;
cal.E = 3.60000e-002;
cal.Tau20 = 1.22000e+000;
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '1960';
cal.OCALDATE = '31-Jul-21';

group6 = 100:172; % lab section 2 SOCk
good = group6;
btlsum_tbl = [];
for i = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(i)}];
end

btlsum_tbl.Winkler1_umolkg(btlsum_tbl.Winkler1_umolkg > 316) = NaN;
btlsum_tbl.Winkler2_umolkg(btlsum_tbl.Winkler2_umolkg > 316) = NaN;
btlsum_tbl.Winkler3_umolkg(btlsum_tbl.Winkler3_umolkg > 316) = NaN;

% non linear multiple regression 
% Oxygen solubility calculated using GSW Toolbox 
% Model variables 
% Treats Winklers as individual points 
% Use E term calculated using deep Winklers 
 
X = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs; btlsum_tbl.prs]];
bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use = [btlsum_tbl.Winkler1_umolkg; btlsum_tbl.Winkler2_umolkg; btlsum_tbl.Winkler3_umolkg];
pdens = [btlsum_tbl.prho; btlsum_tbl.prho; btlsum_tbl.prho];

% % SBE functional form 
% modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
%     .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%     .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));
% 
% beta0 = [cal.SOC 0]; % Starting values for coefficient iterations 

% SBE functional form with predetermined E
cal.Ecalc = cal_deep.Ecalc; 
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));

beta0 = [cal.SOC]; % Starting values for coefficient iterations 

% Non linear multiple regression to get b1 (SOC) from SBE
% functional form using all Winklers_umolkg (from calibrated T/S data) 
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
cal.Winkler1_outliers = Winkler_outliers6(Winkler_outliers6 < height(btlsum_tbl));
cal.Winkler2_outliers = Winkler_outliers6(Winkler_outliers6 > height(btlsum_tbl) & Winkler_outliers6 < 2*height(btlsum_tbl)) - height(btlsum_tbl);
cal.Winkler3_outliers = Winkler_outliers6(Winkler_outliers6 > 2*height(btlsum_tbl) & Winkler_outliers6 < 3*height(btlsum_tbl)) - 2*height(btlsum_tbl);
cal.casts = good;
cal.mdl = mdlcal_k;
cal.out_NLMR = sortrows([bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)],[1 2]);
cal6 = cal; 
clear cal;


f = figure;
f.Position = [100 100 840 500];
figure(8)
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

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Winkler3_umolkg, mdlcal_k.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('AR69-03: SOC_k Winklers from Group 6')

%% Group 7 Labrador Section SOC dt; E term calc from Deep Group  

% same sensor for all casts 
% From SBE factory calibration 
% Serial number 1960, 31-Jul-21
cal.SOC = 4.46780e-001;
cal.VOFFSET = -5.08600e-001;
cal.A = -5.00190e-003;
cal.B = 2.51320e-004; 
cal.C = -3.59380e-006;
cal.E = 3.60000e-002;
cal.Tau20 = 1.22000e+000;
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '1960';
cal.OCALDATE = '31-Jul-21';

group7 = 173:210; % last section SOCdt E from all 

good = group7;
btlsum_tbl = [];
for i = 1:length(good)
    btlsum_tbl = [btlsum_tbl; btlsum{good(i)}];
end

btlsum_tbl.Winkler1_umolkg(btlsum_tbl.Winkler1_umolkg > 316) = NaN;
btlsum_tbl.Winkler2_umolkg(btlsum_tbl.Winkler2_umolkg > 316) = NaN;
btlsum_tbl.Winkler3_umolkg(btlsum_tbl.Winkler3_umolkg > 316) = NaN;

% Calculate drift with variable SOC with time 
dt = datenum(btlsum_tbl.Date) - datenum(btlsum_tbl.Date(1)); % minus first cast time

X_dt = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs; btlsum_tbl.prs],...
    [dt; dt; dt]];

bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use = [btlsum_tbl.Winkler1_umolkg; btlsum_tbl.Winkler2_umolkg; btlsum_tbl.Winkler3_umolkg];
pdens = [btlsum_tbl.prho; btlsum_tbl.prho; btlsum_tbl.prho];


% SBE functional form with SOC as a function of station 
cal.Ecalc_dt = cal_deep.Ecalc;
modelfun_dt = @(b,x)((b(2)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc_dt*x(:,4))./(x(:,3) + 273.15));

beta0_dt = [cal.SOC 0]; % Starting values for coefficient iterations 

% % SBE functional form with SOC as a function of station 
% modelfun_dt = @(b,x)((b(3)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
%     .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%     .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));
% 
% beta0_dt = [cal.SOC 0 0]; % Starting values for coefficient iterations 

mdl_dt1 = fitnlm(X_dt,Winklers_to_use,modelfun_dt,beta0_dt)

figure
histfit(mdl_dt1.Residuals.Raw)
title('SOC_d_t Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR_d_t output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1_dt = find(isoutlier(mdl_dt1.Residuals.Raw,'median') == 1);
mdl_dt2 = fitnlm(X_dt,Winklers_to_use,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers1_dt)

figure
histfit(mdl_dt2.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl_dt2.Residuals.raw,'median') == 1);
Winkler_outliers2_dt = [ind; Winkler_outliers1_dt];
% Exclude outliers from NLMR model 
mdl_dt3 = fitnlm(X_dt,Winklers_to_use,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers2_dt)

figure
histfit(mdl_dt3.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl_dt3.Residuals.raw,'median') == 1);
Winkler_outliers3_dt = [ind; Winkler_outliers2_dt];
% Exclude outliers from NLMR model 
mdl_dt4 = fitnlm(X_dt,Winklers_to_use,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers3_dt)

figure
histfit(mdl_dt4.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl_dt4.Residuals.raw,'median') == 1);
Winkler_outliers4_dt = [ind; Winkler_outliers3_dt];
% Exclude outliers from NLMR model 
mdl_dt5 = fitnlm(X_dt,Winklers_to_use,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers4_dt)

figure
histfit(mdl_dt5.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

%%
mdlcal_dt = mdl_dt5;
% cal for SOC_dt 
cal.SOCcalc_dt = mdlcal_dt.Coefficients.Estimate(1);
cal.gain = cal.SOCcalc_dt/cal.SOC;
cal.SOCrate_dt = mdlcal_dt.Coefficients.Estimate(2);

cal.Winkler1_outliers_dt = Winkler_outliers4_dt(Winkler_outliers4_dt < height(btlsum_tbl));
cal.Winkler2_outliers_dt = Winkler_outliers4_dt(Winkler_outliers4_dt > height(btlsum_tbl) & Winkler_outliers4_dt < 2*height(btlsum_tbl)) - height(btlsum_tbl);
cal.Winkler3_outliers_dt = Winkler_outliers4_dt(Winkler_outliers4_dt > 2*height(btlsum_tbl) & Winkler_outliers4_dt < 3*height(btlsum_tbl)) - 2*height(btlsum_tbl);
cal.casts = good;
cal.mdl = mdlcal_dt;
cal.out_NLMR_dt = sortrows([bad_casts(Winkler_outliers4_dt) btl_check(Winkler_outliers4_dt) Winklers_to_use(Winkler_outliers4_dt)],[1 2]);
cal7 = cal;
clear cal;

f = figure;
f.Position = [100 100 840 500];
figure(8)
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_dt.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.prs, mdlcal_dt.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.prs, mdlcal_dt.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_dt.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Cast, mdlcal_dt.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Cast, mdlcal_dt.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_dt.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.t, mdlcal_dt.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.t, mdlcal_dt.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg, mdlcal_dt.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, mdlcal_dt.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
plot(btlsum_tbl.Winkler3_umolkg, mdlcal_dt.Residuals.raw((height(btlsum_tbl)*2+1):end),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('AR69-03: SOC_d_t Winklers from Group 7')

% For range of SOC
cal7.SOCcalc_dt
days(btlsum_tbl.Date(end) - btlsum_tbl.Date(1))*cal7.SOCrate_dt + cal7.SOCcalc_dt
(days(btlsum_tbl.Date(end) - btlsum_tbl.Date(1))*cal7.SOCrate_dt + cal7.SOCcalc_dt)/cal7.SOC
%%

cal = cal1; SOC_type = 1; %%% The line to change 
cast_num = cal.casts;
dummy = [];
for i = 1:length(cast_num)
    dummy1 = btlsum{cast_num(i)};
    dummy = [dummy; dummy1];
end

group1 = calibrate_CTD_oxygen(dummy,cal,SOC_type);

%%
cal = cal2; SOC_type = 2; %%% The line to change 
cast_num = cal.casts;
dummy = [];
for i = 1:length(cast_num)
    dummy1 = btlsum{cast_num(i)};
    dummy = [dummy; dummy1];
end
group2 = calibrate_CTD_oxygen(dummy,cal,SOC_type);
%%
cal = cal3; SOC_type = 1; %%% The line to change 
cast_num = cal.casts;
dummy = [];
for i = 1:length(cast_num)
    dummy1 = btlsum{cast_num(i)};
    dummy = [dummy; dummy1];
end
group3 = calibrate_CTD_oxygen(dummy,cal,SOC_type);
%%
cal = cal4; SOC_type = 1; %%% The line to change 
cast_num = cal.casts; 
dummy = [];
for i = 1:length(cast_num)
    dummy1 = btlsum{cast_num(i)};
    dummy = [dummy; dummy1];
end
group4 = calibrate_CTD_oxygen(dummy,cal,SOC_type);
%%
cal = cal5; SOC_type = 2; %%% The line to change 
cast_num = cal.casts;
dummy = [];
for i = 1:length(cast_num)
    dummy1 = btlsum{cast_num(i)};
    dummy = [dummy; dummy1];
end
group5 = calibrate_CTD_oxygen(dummy,cal,SOC_type);
%%

cal = cal6; SOC_type = 1; %%% The line to change 
cast_num = cal.casts;
dummy = [];
for i = 1:length(cast_num)
    dummy1 = btlsum{cast_num(i)};
    dummy = [dummy; dummy1];
end
group6 = calibrate_CTD_oxygen(dummy,cal,SOC_type);
%%
cal = cal7; SOC_type = 2; %%% The line to change 
cast_num = cal.casts;
dummy = [];
for i = 1:length(cast_num)
    dummy1 = btlsum{cast_num(i)};
    dummy = [dummy; dummy1];
end
group7 = calibrate_CTD_oxygen(dummy,cal,SOC_type);
%%
btlsum_tbl = [group1; group2; group3; group4; group5; group6; group7];
%%
% For output structure
btlsum = []; % Indexes by cast number leah_btl{5} == cast 5; 
btlcasts = unique(btlsum_tbl.Cast); 
for i = 1:length(btlcasts)% Number of bottle summary files 
    btlsum{btlcasts(i)} = btlsum_tbl(btlsum_tbl.Cast == btlcasts(i),:);
end

%%

cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\AR69-03')
btlsum_tbl_AR6903 = btlsum_tbl; 
btlsum_AR6903 = btlsum; 
clear cal btlsum btlsum_tbl
% cd(samp_dir)
save AR6903_DOcal.mat btlsum_* cal*

%
%%
function btlsum = combine_btl_files(sio_btl,my_btl_file,Winkler_table,CTD_sen)
    btlsum = Winkler_table; % Winklers for just the cast 
    btlsum.Properties.VariableNames = {'Cruise','Cast','Bottle','Winkler1_mLL','Winkler2_mLL','Winkler3_mLL'};

    
    % Format structure for conversion to table and convert to table 
    btl = readtable(my_btl_file,'TextType','string');
    vars = {'Bottle','Date','PrDM','DepSM','Latitude','Longitude','Sbeox0V'};
    btl = btl(:,vars);
    btl.Properties.VariableNames = {'Bottle','Date','PrDM','depth','lat','lon','oxy_volts'};
    btl.CTDcal(:) = {'True'};
    btl.CTDcal = string(btl.CTDcal);
    
    % Combine tables by Bottle variable 
    btlsum0 = join(btlsum,sio_btl,'Keys','Bottle');
    btlsum = join(btlsum0,btl,'Keys','Bottle');
 
    % Decide if using primary or secondary CTD sensor for temp and sal
    if CTD_sen == 1 % primary sensor (use unless something wrong with data)
        btlsum.t = btlsum.CTDTMP1; 
        btlsum.SP = btlsum.CTDSAL; % Only one calibrated salinity value 
    end
    
    if CTD_sen == 2 % secondary sensor (use if primary sensor bad)
        btlsum.t = btlsum.CTDTMP2; 
        btlsum.SP = btlsum.CTDSAL; % Only one calibrated salinity value
    end    
    
    btlsum.prs = btlsum.CTDPRS;
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
    btlsum.Winkler3_umolkg = btlsum.Winkler3_mLL*1000*44.661./btlsum.prho; % uses potential density 
%    
%      % Reorder variables and remove unnecessary ones
%     btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2','Discrete_Salinity_psu','CTDcal',...
%     'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','Winkler1_mLL','Winkler2_mLL','Winkler3_mLL',...
%     'Winkler1_umolkg','Winkler2_umolkg','Winkler3_umolkg','O2sol_umolkg'};
%     btlsum = btlsum(:,btlvars);
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
        btlsum.NLMR_Outlier1(btlsum.Winkler1_umolkg > 316) = 1; % Not evaluated in NLMR 
        btlsum.NLMR_Outlier1(isnan(btlsum.Winkler1_umolkg)) = 9; % QC flag for missing data 

        % Sets outliers from NLMR 
        btlsum.NLMR_Outlier2 = ones(size(btlsum.prs))*2; % Sets all Winklers to 2 (acceptable)
        btlsum.NLMR_Outlier2(cal.Winkler2_outliers) = 3; % Questionable from NLMR
        btlsum.NLMR_Outlier2(btlsum.Winkler2_umolkg > 316) = 1; % Not evaluated in NLMR 
        btlsum.NLMR_Outlier2(isnan(btlsum.Winkler2_umolkg)) = 9; % QC flag for missing data 

        % Sets outliers from NLMR 
        btlsum.NLMR_Outlier3 = ones(size(btlsum.prs))*2; % Sets all Winklers to 2 (acceptable)
        btlsum.NLMR_Outlier3(cal.Winkler3_outliers) = 3; % Questionable from NLMR
        btlsum.NLMR_Outlier3(btlsum.Winkler3_umolkg > 316) = 1; % Not evaluated in NLMR 
        btlsum.NLMR_Outlier3(isnan(btlsum.Winkler3_umolkg)) = 9; % QC flag for missing data 

        btlvars = {'Cruise','Date','Cast','Bottle','prs','lat','lon','CTDcal','CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','O2sol_umolkg','Winkler1_mLL','Winkler2_mLL','Winkler3_mLL',...
            'Winkler1_umolkg','Winkler2_umolkg','Winkler3_umolkg','SOC_type','NLMR_Outlier1','NLMR_Outlier2','NLMR_Outlier3','DOcorr_umolkg','CTDOXY_umolkg','BTL_OXY_umolkg','CTDOXY1_mLL','CTDOXYVOLTS'};
        btlsum = btlsum(:,btlvars);
end