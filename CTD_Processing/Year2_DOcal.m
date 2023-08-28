% Set up workspace 
clearvars
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')

% Read in calibrated bottle files, Winkler sample values and oxygen files
% processed with default hysteresis correction and user-determined time lag
% correction 
btl_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Bottle_Files\Year2';
samp_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year2'; % Winkler file location 
Winkler_file = 'Irminger_Sea-02_AT30-01_Discrete_Summary_KF'; % Winkler file name 
filesave = 1; % filesave == 1, save calibration output as mat file

% Use Bottle samples to calculate new SOC (gain) and E terms for CTD data 
CTD_sen = 1; % Use primary or secondary CTD temp and sal

% Read in Winkler file 
cd(samp_dir)
Winklers = readtable(Winkler_file,'TextType','string');
Winklers.Winkler_mLL = double(Winklers.Winkler_mLL);
Winklers.Discrete_Salinity_psu = double(Winklers.Discrete_Salinity_psu);
%% NO CALIBRATED SALINITY FOR THIS CRUISE 
 
cd(btl_dir)
mybtlfiles = ls('*.csv'); % List of my processed bottle files 
btlcasts = str2num(mybtlfiles(:,7:8)); % Pulls out cast numbers that have bottle files 

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

% Same oxgen sensor whole cruise  
% Calibration standards from SBE xmlcon file 

cal.SOC = double(5.15150e-001);
cal.VOFFSET = double(-5.24000e-001);
cal.A = double(-4.56860e-003);
cal.B = double(2.57580e-004);
cal.C = double(-4.06010e-006);
cal.E = double(3.60000e-002);
cal.Tau20 = double(1.11000e+000);
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '0712';
cal.OCALDATE = '05-Nov-14';

H = [-0.033, 5000, 1450]; % Default


x = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
  .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
  .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));

%% non linear multiple regression with non-averaged OOI Winkler values 
% Oxygen solubility calculated using GSW Toolbox 
% Model variables 

X = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
Winklers_to_use = btlsum_tbl.Winkler_umolkg;


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
cal.Winkler_outliers = Winkler_outliers6;

f = figure;
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
sgtitle('Year 2 AT30-01: SOC_k')

mdlcal_k = mdl7;
cal.SOCcalc = mdlcal_k.Coefficients.Estimate(1);
cal.Ecalc = mdlcal_k.Coefficients.Estimate(2);
cal.gain = cal.SOCcalc/cal.SOC;
cal.Winkler_outliers = Winkler_outliers6;


%% Use calculated E term to look at drift of SOC in time and by cast number 
Tempcorr = 1 + cal.A*btlsum_tbl.t + cal.B*btlsum_tbl.t.^2 + cal.C*btlsum_tbl.t.^3;
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
for i = 1:length(cn)
    driftdt(i) = nanmean(datenum(Date(Cast == cn(i))));
    SOCdt(i) = nanmean(SOCcalc(Cast == cn(i)));
    SOCstd(i) = nanstd(SOCcalc(Cast == cn(i)));
end

figure
subplot(1,2,1)
errorbar(cn,SOCdt,SOCstd,'o')
ylabel('Calculated SOC')
grid on
xlabel('By Cast Number')
title('By Cast')
sgtitle('AT30-01: SOC Drift')
SOCcnR = min(min(corrcoef([cn SOCdt'],'Rows','complete')))

subplot(1,2,2)
errorbar(driftdt,SOCdt,SOCstd,'o')
ylabel('Calculated SOC')
datetick
grid on
title('By Time')
SOCdtR = min(min(corrcoef([driftdt' SOCdt'],'Rows','complete')))

%% Calculate drift with variable SOC with time 
dt = datenum(btlsum_tbl.Date) - datenum(btlsum_tbl.Date(1)); % minus first cast time
X_dt = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs,dt];
Winklers_to_use = btlsum_tbl.Winkler_umolkg; 

% % % Remove these Winklers for regression 
% cast_ind = btlsum_tbl.Cast ==3;
% Winklers_to_use = btlsum_tbl.Winkler_umolkg; 
% Winklers_to_use(cast_ind == 1) = NaN; 

% SBE functional form with SOC as a function of station 
modelfun_dt = @(b,x)((b(3)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0_dt = [cal.SOC 0 0]; % Starting values for coefficient iterations 

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
cal.Ecalc_dt = mdlcal_dt.Coefficients.Estimate(2);
cal.SOCrate_dt = mdlcal_dt.Coefficients.Estimate(3);
cal.Winkler_outliers_dt = Winkler_outliers4_dt;


f = figure;
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_dt.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_dt.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_dt.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler_umolkg, mdlcal_dt.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('Year 2 AT30-01: SOC_d_t')

%% Calculate SOC that varies by station 
X_cn = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs,btlsum_tbl.Cast];

% SBE functional form with SOC as a function of station 
modelfun_cn = @(b,x)((b(3)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0_cn = [cal.SOC 0 0]; % Starting values for coefficient iterations 

% % % Remove these Winklers for regression 
% cast_ind = btlsum_tbl.Cast ==3;
% Winklers_to_use = btlsum_tbl.Winkler_umolkg; 
% Winklers_to_use(cast_ind == 1) = NaN; 

mdl_cn1 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn)

figure
histfit(mdl_cn1.Residuals.Raw)
title('SOC_c_n Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1_cn = find(isoutlier(mdl_cn1.Residuals.Raw,'median') == 1);
mdl_cn2 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers1_cn)

figure
histfit(mdl_cn2.Residuals.Raw)
title('SOC_c_n Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl_cn2.Residuals.raw,'median') == 1);
Winkler_outliers2_cn = [ind; Winkler_outliers1_cn];
% Exclude outliers from NLMR model 
mdl_cn3 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers2_cn)

figure
histfit(mdl_cn3.Residuals.Raw)
title('SOC_c_n Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl_cn3.Residuals.raw,'median') == 1);
Winkler_outliers3_cn = [ind; Winkler_outliers2_cn];
% Exclude outliers from NLMR model 
mdl_cn4 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers3_cn)

figure
histfit(mdl_cn4.Residuals.Raw)
title('SOC_c_n Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl_cn4.Residuals.raw,'median') == 1);
Winkler_outliers4_cn = [ind; Winkler_outliers3_cn];
% Exclude outliers from NLMR model 
mdl_cn5 = fitnlm(X_cn,Winklers_to_use,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers4_cn)

figure
histfit(mdl_cn5.Residuals.Raw)
title('SOC_c_n Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
%%
mdlcal_cn = mdl_cn5;
% cal.Winkler_outliers_cn = Winkler_outliers4_cn;
cal.SOCcalc_cn = mdlcal_cn.Coefficients.Estimate(1);
cal.Ecalc_cn = mdlcal_cn.Coefficients.Estimate(2);
cal.SOCrate_cn = mdlcal_cn.Coefficients.Estimate(3);
cal.Winkler_outliers_cn = Winkler_outliers4_cn;

f = figure;
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_cn.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_cn.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_cn.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler_umolkg, mdlcal_cn.Residuals.raw, '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('Year 2 AT30-01: SOC_c_n')

%% Decided on SOC calibration 
SOC_type = 3; % variable by cast number 
Winklers_questionable = cal.Winkler_outliers_cn; 

% Sets outliers from SOCcn 
btlsum_tbl.NLMR_Outlier = ones(size(btlsum_tbl.prs))*2; % Sets all Winklers to 2 (acceptable)
btlsum_tbl.NLMR_Outlier(Winklers_questionable) = 3; % Questionable from NLMR
btlsum_tbl.NLMR_Outlier(isnan(btlsum_tbl.Winkler_umolkg)) = 9; % QC flag for missing data 

btlsum_tbl = calibrate_CTD_oxygen(btlsum_tbl,cal,SOC_type);

% btlsum = [];
% for i = 1:length(btl_num)
%         btlsum{btl_num(i)} = btlsum_tbl(btlsum_tbl.Cast == btl_num(i),:); 
% end


%% Save Variables 
btlsum_yr2 = btlsum_tbl;  
if filesave == 1
    clear btlcasts btlfiles btl_dir btl_check btlsum_tbl btlsum
    cd(samp_dir)
    save Year2_DOcal.mat btl* cal mdlcal*
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
        btlsum.Winkler_umolkg = btlsum.Winkler_mLL*1000*44.661./btlsum.prho; % Winklers 
    
        % Reorder variables and remove unnecessary ones
        btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2','Discrete_Salinity_psu','CTDcal',...
        'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','Winkler_mLL',...
        'Winkler_umolkg','O2sol_umolkg'};
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
        btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2','Discrete_Salinity_psu',...
            'CTDcal','CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','O2sol_umolkg','Winkler_mLL',...
            'Winkler_umolkg','NLMR_Outlier','SOC_type','DOcorr_umolkg'};
        btlsum = btlsum(:,btlvars);
end