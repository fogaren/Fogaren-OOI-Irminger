% Set up workspace 
clearvars
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
run('GeneralSettings.m')

% Read in calibrated bottle files, Winkler sample values and oxygen files
% processed with default hysteresis correction and user-determined time lag
% correction 
btl_dir = 'C:\Users\fogaren\Documents\SBE\AR45\btl_data'; % my processed bottle product 
cal_dir = 'C:\Users\fogaren\Documents\SBE\AR45\From_Leah'; % Leah's calibrated bottle product 
samp_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year7\AR45'; % processed SBE cnvs
Winkler_dir = 'C:\Users\fogaren\Documents\SBE\AR45';
Winkler_file = 'Winkler AR45_KF.xlsx';

filesave = 0; % filesave == 1, save calibration output as mat file

% Use Bottle samples to calculate new SOC (gain) and E terms for CTD data 
CTD_sen = 1; % Use primary or secondary CTD temp and sal

% Read in Winkler values, my processed bottle files and Leah's calibrated files and combine them
cd(Winkler_dir)
Winklers = readtable(Winkler_file,'TextType','string');
%%
cd(cal_dir)
btlfiles = ls('*.cbot_s'); % List of Leah's calibrated bottle files 
btlcasts = str2num(btlfiles(:,6:8)); % Pulls out cast numbers that have bottle files 

cd(btl_dir)
mybtlfiles = ls('*.csv'); % List of my processed bottle files 
mybtlcasts = str2num(mybtlfiles(:,6:8)); % Pulls out cast numbers that have bottle files 

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
%%
% From SBE factory calibration 
% Serial number 1960, Calibration Date 15-May-2019
cal.SOC = 4.48650e-001;
cal.VOFFSET = -4.98500e-001;
cal.A = -4.56920e-003;
cal.B = 2.39370e-004; 
cal.C = -3.42490e-006;
cal.E = 3.60000e-002;
cal.Tau20 = 1.07000e+000;
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '1960';
cal.OCALDATE = '15-May-2019';
%% non linear multiple regression 
% Oxygen solubility calculated using GSW Toolbox 
% Model variables 
X = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];

% SBE functional form 
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0 = [cal.SOC 0]; % Starting values for coefficient iterations 

%Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
%functional form using all Winklers_umolkg (from calibrated T/S data) 
% Run non linear model fit with all Winkler/CTD oxygen (volts) values
mdl1 = fitnlm(X,btlsum_tbl.Winkler_umolkg,modelfun,beta0)

figure
histfit(mdl1.Residuals.raw)
title('SOC_k Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,'median') == 1);
mdl2 = fitnlm(X,btlsum_tbl.Winkler_umolkg,modelfun,beta0,'Exclude',Winkler_outliers1)

figure
histfit(mdl2.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl2.Residuals.raw,'median') == 1);
Winkler_outliers2 = [ind; Winkler_outliers1];
% Exclude outliers from NLMR model 
mdl3 = fitnlm(X,btlsum_tbl.Winkler_umolkg,modelfun,beta0,'Exclude',Winkler_outliers2)

figure
histfit(mdl3.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl3.Residuals.raw,'median') == 1);
Winkler_outliers3 = [ind; Winkler_outliers2];
% Exclude outliers from NLMR model 
mdl4 = fitnlm(X,btlsum_tbl.Winkler_umolkg,modelfun,beta0,'Exclude',Winkler_outliers3)

figure
histfit(mdl4.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl4.Residuals.raw,'median') == 1);
Winkler_outliers4 = [ind; Winkler_outliers3];
% Exclude outliers from NLMR model 
mdl5 = fitnlm(X,btlsum_tbl.Winkler_umolkg,modelfun,beta0,'Exclude',Winkler_outliers4)

figure
histfit(mdl5.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 6 
ind = find(isoutlier(mdl5.Residuals.raw,'median') == 1);
Winkler_outliers5 = [ind; Winkler_outliers4];
% Exclude outliers from NLMR model 
mdl6 = fitnlm(X,btlsum_tbl.Winkler_umolkg,modelfun,beta0,'Exclude',Winkler_outliers5)

figure
histfit(mdl6.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 6')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 7 
ind = find(isoutlier(mdl6.Residuals.raw,'median') == 1);
Winkler_outliers6 = [ind; Winkler_outliers5];
% Exclude outliers from NLMR model 
mdl7 = fitnlm(X,btlsum_tbl.Winkler_umolkg,modelfun,beta0,'Exclude',Winkler_outliers6)

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
cal.Winkler_outliers = Winkler_outliers6;

figure
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw, 'k.','Markersize',20); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Pressure (db)')
ylim([-2 2]); grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(datenum(btlsum_tbl.Date) - min(datenum(btlsum_tbl.Date)), mdlcal_k.Residuals.raw, 'k.','Markersize',20); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel(['Days since ' datestr(min(datenum(btlsum_tbl.Date)))])
ylim([-2 2]); grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw, 'k.','Markersize',20); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Temperature (\circC)')
ylim([-2 2]); grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler_umolkg, mdlcal_k.Residuals.raw, 'k.','Markersize',20); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Winkler (\mumol/kg)')
ylim([-2 2]); grid on
sgtitle('AR45: NLMR SOC_k')

%%
% Use calculated E term to look at drift of SOC in time and by cast number 
Tempcorr = 1 + cal.A*btlsum_tbl.t + cal.B*btlsum_tbl.t.^2 + cal.C*btlsum_tbl.t.^3;
Prescorr = exp(cal.Ecalc*btlsum_tbl.prs./(btlsum_tbl.t + 273.15));

% Group SOC calculations by cast number 
cn = unique(btlsum_tbl.Cast(~isnan(btlsum_tbl.Winkler_umolkg)));

% Remove outliers from Winklers 
btlsum_tbl.Winkler_umolkg_wout_outliers = btlsum_tbl.Winkler_umolkg;
btlsum_tbl.Winkler_umolkg_wout_outliers(cal.Winkler_outliers) = NaN;

% Preallocate arrays 
driftdt = NaN(1,length(cn));
SOCdt = NaN(1,length(cn));
SOCstd = NaN(1,length(cn));

% Calculate SOC for each Winkler sample 
SOCcalc = btlsum_tbl.Winkler_umolkg_wout_outliers...
    ./(Tempcorr.*Prescorr.*btlsum_tbl.O2sol_umolkg.*(btlsum_tbl.oxy_volts+cal.VOFFSET));

% calculate mean time, mean SOC, and std of SOC by cast number  
for i = 1:length(cn)
    driftdt(i) = nanmean(datenum(btlsum_tbl.Date(btlsum_tbl.Cast == cn(i))));
    SOCdt(i) = nanmean(SOCcalc(btlsum_tbl.Cast == cn(i)));
    SOCstd(i) = nanstd(SOCcalc(btlsum_tbl.Cast == cn(i)));
end

figure
subplot(1,2,1)
errorbar(cn,SOCdt,SOCstd,'o')
ylabel('Calculated SOC')
grid on
xlabel('By Cast Number')
title('By Cast')
sgtitle('AR45: SOC Drift')

subplot(1,2,2)
errorbar(driftdt,SOCdt,SOCstd,'o')
ylabel('Calculated SOC')
datetick
grid on
title('By Time')

%% Calculate drift with variable SOC with time 
dt = datenum(btlsum_tbl.Date) - datenum(btlsum_tbl.Date(1)); % minus first cast time
X_dt = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs,dt];

% SBE functional form with SOC as a function of station 
modelfun_dt = @(b,x)((b(3)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0_dt = [cal.SOC 0 0]; % Starting values for coefficient iterations 

mdl_dt1 = fitnlm(X_dt,btlsum_tbl.Winkler_umolkg,modelfun_dt,beta0_dt)

figure
histfit(mdl_dt1.Residuals.Raw)
title('SOC_d_t Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR_d_t output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1_dt = find(isoutlier(mdl_dt1.Residuals.Raw,'median') == 1);
mdl_dt2 = fitnlm(X_dt,btlsum_tbl.Winkler_umolkg,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers1_dt)

figure
histfit(mdl_dt2.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl_dt2.Residuals.raw,'median') == 1);
Winkler_outliers2_dt = [ind; Winkler_outliers1_dt];
% Exclude outliers from NLMR model 
mdl_dt3 = fitnlm(X_dt,btlsum_tbl.Winkler_umolkg,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers2_dt)

figure
histfit(mdl_dt3.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl_dt3.Residuals.raw,'median') == 1);
Winkler_outliers3_dt = [ind; Winkler_outliers2_dt];
% Exclude outliers from NLMR model 
mdl_dt4 = fitnlm(X_dt,btlsum_tbl.Winkler_umolkg,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers3_dt)

figure
histfit(mdl_dt4.Residuals.Raw)
title('SOC_d_t Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl_dt4.Residuals.raw,'median') == 1);
Winkler_outliers4_dt = [ind; Winkler_outliers3_dt];
% Exclude outliers from NLMR model 
mdl_dt5 = fitnlm(X_dt,btlsum_tbl.Winkler_umolkg,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers4_dt)

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
plot(btlsum_tbl.prs, mdlcal_dt.Residuals.raw, 'k.','Markersize',20); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number 
subplot(2,2,2)
plot(datenum(btlsum_tbl.Date) - min(datenum(btlsum_tbl.Date)), mdlcal_dt.Residuals.raw, 'k.','Markersize',20); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel(['Days since ' datestr(min(datenum(btlsum_tbl.Date)))])
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_dt.Residuals.raw, 'k.','Markersize',20); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler_umolkg, mdlcal_dt.Residuals.raw, 'k.','Markersize',20); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Winkler (\mumol/kg)')
grid on
sgtitle('AR45: SOC_d_t')
%% Calculate SOC that varies by station 

X_cn = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs,btlsum_tbl.Cast];

% SBE functional form with SOC as a function of station 
modelfun_cn = @(b,x)((b(3)*x(:,5) + b(1)).*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0_cn = [cal.SOC 0 0]; % Starting values for coefficient iterations 

mdl_cn1 = fitnlm(X_cn,btlsum_tbl.Winkler_umolkg,modelfun_cn,beta0_cn)

figure
histfit(mdl_cn1.Residuals.Raw)
title('SOC_c_n Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1_cn = find(isoutlier(mdl_cn1.Residuals.Raw,'median') == 1);
mdl_cn2 = fitnlm(X_cn,btlsum_tbl.Winkler_umolkg,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers1_cn)

figure
histfit(mdl_cn2.Residuals.Raw)
title('SOC_c_n Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl_cn2.Residuals.raw,'median') == 1);
Winkler_outliers2_cn = [ind; Winkler_outliers1_cn];
% Exclude outliers from NLMR model 
mdl_cn3 = fitnlm(X_cn,btlsum_tbl.Winkler_umolkg,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers2_cn)

figure
histfit(mdl_cn3.Residuals.Raw)
title('SOC_c_n Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl_cn3.Residuals.raw,'median') == 1);
Winkler_outliers3_cn = [ind; Winkler_outliers2_cn];
% Exclude outliers from NLMR model 
mdl_cn4 = fitnlm(X_cn,btlsum_tbl.Winkler_umolkg,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers3_cn)

figure
histfit(mdl_cn4.Residuals.Raw)
title('SOC_c_n Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl_cn4.Residuals.raw,'median') == 1);
Winkler_outliers4_cn = [ind; Winkler_outliers3_cn];
% Exclude outliers from NLMR model 
mdl_cn5 = fitnlm(X_cn,btlsum_tbl.Winkler_umolkg,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers4_cn)

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
plot(btlsum_tbl.prs, mdlcal_cn.Residuals.raw, 'k.','Markersize',20); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number 
subplot(2,2,2)
plot(datenum(btlsum_tbl.Date) - min(datenum(btlsum_tbl.Date)), mdlcal_cn.Residuals.raw, 'k.','Markersize',20); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel(['Days since ' datestr(min(datenum(btlsum_tbl.Date)))])
grid on

%Plot residuals versus temperature cal
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_cn.Residuals.raw, 'k.','Markersize',20); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler_umolkg, mdlcal_cn.Residuals.raw, 'k.','Markersize',20); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Winkler (\mumol/kg)')
grid on
sgtitle('AR45: SOC_c_n')

%%
% For output structure
btlsum = []; % Indexes by cast number leah_btl{5} == cast 5; 
% Combine files and calculate sea water properties for CTD sensor number 
for i = 1:height(btlcasts) % Number of bottle summary files 
    btlsum{btlcasts(i)} = btlsum_tbl(btlsum_tbl.Cast == btlcasts(i),:);
end

%%
btlsum_AR45 = btlsum_tbl; clear btlsum_tbl
if filesave == 1
    clear btlcasts btlfiles btl_dir  
    cd(samp_dir)
    save AR45_DOcal.mat btl* cal mdlcal*
end

%%

function btlsum = combine_btl_files(leah_btl_file,my_btl_file,Winkler_table,CTD_sen)
    btlsum = Winkler_table; % Winklers for just the cast 
    btlsum.Properties.VariableNames = {'Cruise','Cast','Bottle','Winkler_mLL'};

    % Format structure for conversion to table and convert to table 
    leah_btl = readtable(leah_btl_file,'FileType','text');%,'VariableNamingRule','preserve');
    if width(leah_btl) == 14
        leah_btl.Properties.VariableNames = {'Bottle','prs','temp1','temp2','th168','th268','sal1','sal2','CTDoxy_mLL_nohyst','CTDoxy_umolkg_nohyst','flur_mgm3','tran','Meas_SAL','QUAL'};
    else
        leah_btl.Properties.VariableNames = {'Bottle','prs','temp1','temp2','th168','th268','sal1','sal2','CTDoxy_mLL_nohyst','flur_mgm3','tran','Meas_SAL','QUAL'};
    end
    leah_btl(1,:) = [];
    leah_btl.Meas_SAL(leah_btl.Meas_SAL == -9) = NaN; % replaces no data flag with NaN
    leah_btl.Discrete_Salinity_psu = leah_btl.Meas_SAL;
    % Format structure for conversion to table and convert to table 
    btl = readtable(my_btl_file,'TextType','string');
    vars = {'Bottle','Date','PrDM','DepSM','Latitude','Longitude','Sbeox0V','V7'};
    btl = btl(:,vars);
    btl.Properties.VariableNames = {'Bottle','Date','PrDM','depth','lat','lon','oxy_volts','AA_volts'};
    btl.CTDcal(:) = {'True'};
    btl.CTDcal = string(btl.CTDcal);
    
    % Combine tables by Bottle variable 
    btlsum0 = join(leah_btl,btl,'Keys','Bottle');
    btlsum = join(btlsum,btlsum0,'Keys','Bottle');
 
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
    btlsum.Winkler_umolkg = btlsum.Winkler_mLL*1000*44.661./btlsum.prho; % uses potential density 

     % Reorder variables and remove unnecessary ones
    btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2','Discrete_Salinity_psu','CTDcal',...
    'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','Winkler_mLL','Winkler_umolkg','O2sol_umolkg','AA_volts'};
    btlsum = btlsum(:,btlvars);
end