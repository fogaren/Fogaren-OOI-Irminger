% Set up workspace 
clearvars
addpath('G:\My Drive\Matlab_work\BC\Irminger\colab-workspace\CTD_Processing')
addpath('G:\My Drive\Matlab_work\BC\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Sea-Bird-Toolbox')
addpath(genpath('G:\My Drive\Matlab_work\Functions\GSW'))

cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year2')
load Year2_Processed_KF.mat 
btlsum = btlsum_yr2;
%% =======================================================================
% Same oxygen sensor for whole cruise 

% From SBE factory calibration 
Voffset = cal.VOFFSET;
A = cal.A;
B = cal.B; 
C = cal.C;

% Calculate oxygen solubility calculated using calibrated CTD data
[btlsum.oxsol_mLL, btlsum.oxsol_uM] = sbsoxygensol(btlsum.t, btlsum.SP, 'sbs');
btlsum.oxsol_umolkg = btlsum.oxsol_uM*1000./btlsum.prho;

Winklers = btlsum.Winkler_umolkg; % umol/kg calculated using calibrated CTD data 

% Model variables 
X = [btlsum.oxy_volts,btlsum.oxsol_umolkg,btlsum.t,btlsum.prs];

% SBE functional form 
modelfun = @(b,x)(b(1)*(x(:,1) + Voffset)).*x(:,2)...
    .*(1 + A*x(:,3) + B*x(:,3).^2 + C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0 = [0 0]; % Starting values for coefficient iterations 

%Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
%functional form using all Winklers 
mdl1 = fitnlm(X,Winklers,modelfun,beta0)

figure
boxplot(mdl1.Residuals.Raw)
ylabel('DO Residuals, Winkler - NLMR output (\mumol/kg), it = 1')

figure
histfit(mdl1.Residuals.Raw)
title('Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')


%% Find outliers based on median filter it = 2 
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,'median') == 1);
mdl2 = fitnlm(X,Winklers,modelfun,beta0,'Exclude',Winkler_outliers1)

figure
histfit(mdl2.Residuals.Raw)
title('Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

%% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl2.Residuals.raw,'median') == 1);
Winkler_outliers2 = [ind; Winkler_outliers1];
% Exclude outliers from NLMR model 
mdl3 = fitnlm(X,Winklers,modelfun,beta0,'Exclude',Winkler_outliers2)

figure
histfit(mdl3.Residuals.Raw)
title('Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
%% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl3.Residuals.raw,'median') == 1);
Winkler_outliers3 = [ind; Winkler_outliers2];
% Exclude outliers from NLMR model 
mdl4 = fitnlm(X,Winklers,modelfun,beta0,'Exclude',Winkler_outliers3)

figure
histfit(mdl4.Residuals.Raw)
title('Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

%% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl4.Residuals.raw,'median') == 1);
Winkler_outliers4 = [ind; Winkler_outliers3];
% Exclude outliers from NLMR model 
mdl5 = fitnlm(X,Winklers,modelfun,beta0,'Exclude',Winkler_outliers4)

figure
histfit(mdl5.Residuals.Raw)
title('Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

%% Find outliers based on median filter it = 6 
ind = find(isoutlier(mdl5.Residuals.raw,'median') == 1);
Winkler_outliers5 = [ind; Winkler_outliers4];
% Exclude outliers from NLMR model 
mdl6 = fitnlm(X,Winklers,modelfun,beta0,'Exclude',Winkler_outliers5)

figure
histfit(mdl6.Residuals.Raw)
title('Residuals with Outliers Removed, it = 6')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

%% Find outliers based on median filter it = 7 
ind = find(isoutlier(mdl6.Residuals.raw,'median') == 1);
Winkler_outliers6 = [ind; Winkler_outliers5];
% Exclude outliers from NLMR model 
mdl7 = fitnlm(X,Winklers,modelfun,beta0,'Exclude',Winkler_outliers6)

figure
histfit(mdl7.Residuals.Raw)
title('Residuals with Outliers Removed, it = 7')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
%%
%Plot residuals versus pressure, time, station, DO concentration with outliers removed   
mdl = mdl2;
Winkler_outliers = Winkler_outliers2;

cal.SOCcalc = mdl.Coefficients.Estimate(1);
cal.Ecalc = mdl.Coefficients.Estimate(2);
cal.gain_calc = cal.SOCcalc/cal.SOC;

figure
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum.prs, mdl.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number 
subplot(2,2,2)
plot(datenum(btlsum.Date) - min(datenum(btlsum.Date)), mdl.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel(['Days since ' datestr(min(datenum(btlsum.Date)))])
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum.t, mdl.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum.Winkler_umolkg, mdl.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Winkler (\mumol/kg)')
grid on
sgtitle('Irminger Year 2: NLMR')
%%
% Use calculated E term to look at drift of SOC in time and by cast number 
Tempcorr = 1 + A*btlsum.t + B*btlsum.t.^2 + C*btlsum.t.^3;
Prescorr = exp(cal.Ecalc*btlsum.prs./(btlsum.t + 273.15));

% Group SOC calculations by cast number 
cn = unique(btlsum.Cast(~isnan(btlsum.Winkler_umolkg)));
% Remove outliers from Winklers 
btlsum.Winkler_umolkg_wout_outliers = Winklers;
btlsum.Winkler_umolkg_wout_outliers(Winkler_outliers) = NaN;

% Preallocate arrays 
driftdt = NaN(1,length(cn));
SOCdt = NaN(1,length(cn));
SOCstd = NaN(1,length(cn));

% Calculate SOC for each Winkler sample 
btlsum.SOCcalc = btlsum.Winkler_umolkg_wout_outliers...
    ./(Tempcorr.*Prescorr.*btlsum.oxsol_umolkg.*(btlsum.oxy_volts+Voffset));

% calculate mean time, mean SOC, and std of SOC by cast number  
for i = 1:length(cn)
    driftdt(i) = nanmean(datenum(btlsum.Date(btlsum.Cast == cn(i))));
    SOCdt(i) = nanmean(btlsum.SOCcalc(btlsum.Cast == cn(i)));
    SOCstd(i) = nanstd(btlsum.SOCcalc(btlsum.Cast == cn(i)));
end

figure
subplot(1,2,1)
errorbar(cn,SOCdt,SOCstd,'o')
ylabel('Calculated SOC')
grid on
xlabel('By Cast Number')
title('By Cast')
sgtitle('Irminger 2: SOC Drift')

subplot(1,2,2)
errorbar(driftdt,SOCdt,SOCstd,'o')
ylabel('Calculated SOC')
datetick
grid on
title('By Time')

%% Calculate linear drift of SOC in time using cast number or time 
cn_all = unique(btlsum.Cast);
Cast_dt = [];
drift_dt_all = [];
for i = 1:length(cn_all)
    driftdt_all(i) = nanmean(datenum(btlsum.Date(btlsum.Cast == cn_all(i))));
    Cast_dt(btlsum.Cast == cn_all(i)) = driftdt_all(i);
end
btlsum.dt_days = Cast_dt' - min(Cast_dt); 

dtx = driftdt_all-min(driftdt_all); % Days since start of cruise

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
sgtitle('Irminger 2: SOC drift')
%% Calculate drift with variable SOC with time 
btlsum.dt = datenum(btlsum.Date) - datenum(2015,08,07,20,14,21); % minus first cast time
% X = [btlsum.oxy_volts,btlsum.oxsol_umolkg,btlsum.t,btlsum.prs,btlsum.Cast];
X_dt = [btlsum.oxy_volts,btlsum.oxsol_umolkg,btlsum.t,btlsum.prs,btlsum.dt];

% SBE functional form with SOC as a function of station 
modelfun_dt = @(b,x)((b(1)*x(:,5) + b(3)).*(x(:,1) + Voffset)).*x(:,2)...
    .*(1 + A*x(:,3) + B*x(:,3).^2 + C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0_dt = [0 0 cal.SOC]; % Starting values for coefficient iterations 

mdl_dt1 = fitnlm(X_dt,Winklers,modelfun_dt,beta0_dt)

figure
boxplot(mdl_dt1.Residuals.Raw)
ylabel('DO Residuals, Winkler - NLMR output (\mumol/kg), it = 1')

figure
histfit(mdl_dt1.Residuals.Raw)
title('Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR_d_t output (\mumol/kg)')

%% Find outliers based on median filter it = 2 
Winkler_outliers1_dt = find(isoutlier(mdl_dt1.Residuals.Raw,'median') == 1);
mdl_dt2 = fitnlm(X_dt,Winklers,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers1_dt)

figure
histfit(mdl_dt2.Residuals.Raw)
title('Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

%% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl_dt2.Residuals.raw,'median') == 1);
Winkler_outliers2_dt = [ind; Winkler_outliers1_dt];
% Exclude outliers from NLMR model 
mdl_dt3 = fitnlm(X_dt,Winklers,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers2_dt)

figure
histfit(mdl_dt3.Residuals.Raw)
title('Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
%% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl_dt3.Residuals.raw,'median') == 1);
Winkler_outliers3_dt = [ind; Winkler_outliers2_dt];
% Exclude outliers from NLMR model 
mdl_dt4 = fitnlm(X_dt,Winklers,modelfun_dt,beta0_dt,'Exclude',Winkler_outliers3_dt)

figure
histfit(mdl_dt4.Residuals.Raw)
title('Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
%% Calculate SOC that varies by station 

X_cn = [btlsum.oxy_volts,btlsum.oxsol_umolkg,btlsum.t,btlsum.prs,btlsum.Cast];

% SBE functional form with SOC as a function of station 
modelfun_cn = @(b,x)((b(1)*x(:,5) + b(3)).*(x(:,1) + Voffset)).*x(:,2)...
    .*(1 + A*x(:,3) + B*x(:,3).^2 + C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0_cn = [0 0 cal.SOC]; % Starting values for coefficient iterations 

mdl_cn1 = fitnlm(X_cn,Winklers,modelfun_cn,beta0_cn)

figure
boxplot(mdl_cn1.Residuals.Raw)
ylabel('DO Residuals, Winkler - NLMR output (\mumol/kg), it = 1')

figure
histfit(mdl_cn1.Residuals.Raw)
title('Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR_c_n output (\mumol/kg)')

%% Find outliers based on median filter it = 2 
Winkler_outliers1_cn = find(isoutlier(mdl_cn1.Residuals.Raw,'median') == 1);
mdl_cn2 = fitnlm(X_cn,Winklers,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers1_cn)

figure
histfit(mdl_cn2.Residuals.Raw)
title('Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

%% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl_cn2.Residuals.raw,'median') == 1);
Winkler_outliers2_cn = [ind; Winkler_outliers1_cn];
% Exclude outliers from NLMR model 
mdl_cn3 = fitnlm(X_cn,Winklers,modelfun_cn,beta0_cn,'Exclude',Winkler_outliers2_cn)

figure
histfit(mdl_cn3.Residuals.Raw)
title('Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')
