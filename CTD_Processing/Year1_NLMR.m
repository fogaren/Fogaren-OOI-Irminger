% Set up workspace 
clearvars
addpath('G:\My Drive\Matlab_work\BC\Irminger\colab-workspace\CTD_Processing')
addpath('G:\My Drive\Matlab_work\BC\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Sea-Bird-Toolbox')
addpath(genpath('G:\My Drive\Matlab_work\Functions\GSW'))

cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year1')
load Year1_Processed_KF.mat btlsum_yr1 cal cast06*
btlsum = btlsum_yr1;
%% =======================================================================

% From SBE factory calibration 
Voffset = cal.VOFFSET;
A = cal.A;
B = cal.B; 
C = cal.C;
% D1 = 1.92634e-004;
% D2 = -4.64803e-002;

% Calculate oxygen solubility calculated using calibrated CTD data
[btlsum.oxsol_mLL, btlsum.oxsol_uM] = sbsoxygensol(btlsum.t, btlsum.SP, 'sbs');
btlsum.oxsol_umolkg = btlsum.oxsol_uM*1000./btlsum.prho;

Winklers = btlsum.Winkler_umolkg; % umol/kg calculated using calibrated CTD data 


btlsum.dt = datenum(btlsum.Date) - datenum(2014,09,08,15,21,20); % minus first cast time
% Model variables 
X = [btlsum.oxy_volts,btlsum.oxsol_umolkg,btlsum.t,btlsum.prs];
% X = [btlsum.oxy_volts,btlsum.oxsol_umolkg,btlsum.t,btlsum.prs,btlsum.Cast];
% X = [btlsum.oxy_volts,btlsum.oxsol_umolkg,btlsum.t,btlsum.prs,btlsum.dt];
% 

% Only for cast 6 
X = [btlsum.oxy_volts(btlsum.Cast == 6),btlsum.oxsol_umolkg(btlsum.Cast == 6),...
    btlsum.t(btlsum.Cast == 6),btlsum.prs(btlsum.Cast == 6)];
Winklers = btlsum.Winkler_umolkg(btlsum.Cast == 6);
Winklers(7) = NaN;
% Winklers(4) = NaN;
% SBE functional form 
modelfun = @(b,x)(b(1)*(x(:,1) + Voffset)).*x(:,2)...
    .*(1 + A*x(:,3) + B*x(:,3).^2 + C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

% % SBE functional form with SOC as a function of station 
% modelfun = @(b,x)((b(1)*x(:,5) + b(3)).*(x(:,1) + Voffset)).*x(:,2)...
%     .*(1 + A*x(:,3) + B*x(:,3).^2 + C*x(:,3).^3)...
%     .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

% % SBE functional form with tau 
% modelfun = @(b,x)b(1)...
%     *(x(:,1) + Voffset + b(3)*(exp((D1*x(:,4)) + (D2*(x(:,3) - 20)))).*x(:,5))...
%     .*x(:,2)...
%     .*(1 + A*x(:,3) + B*x(:,3).^2 + C*x(:,3).^3)...
%     .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));


beta0 = [0 0]; % Starting values for coefficient iterations 

%Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
%functional form using all Winklers 
mdl1 = fitnlm(X,Winklers,modelfun,beta0)
% btlsum.resid0 = mdl0.Residuals.Raw;

figure
boxplot(mdl1.Residuals.Raw)
ylabel('DO Residuals, Winkler - NLMR output (\mumol/kg), it = 1')

figure
histfit(mdl1.Residuals.Raw,5)
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
%% For just cast 6
%Plot residuals versus pressure, time, station, DO concentration with outliers removed   
mdl = mdl6;
Winkler_outliers = Winkler_outliers5;
figure
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum.prs(btlsum.Cast == 6), mdl.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number 
subplot(2,2,2)
plot(datenum(btlsum.Date(btlsum.Cast == 6)) - min(datenum(btlsum.Date(btlsum.Cast == 6))), mdl.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel(['Days since ' datestr(min(datenum(btlsum.Date)))])
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum.t(btlsum.Cast == 6), mdl.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum.Winkler_umolkg(btlsum.Cast == 6), mdl.Residuals.raw, 'k.','Markersize',10); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Winkler (\mumol/kg)')
grid on
sgtitle('Irminger Year 1: NLMR')
%%
% Use calculated E term to look at drift of SOC in time and by cast number 
cal.SOCcalc = mdl1.Coefficients.Estimate(1);
cal.Ecalc = mdl1.Coefficients.Estimate(2);
% SBE functional form without SOC drift 

cast06u.oxy_volts(cast06u.oxy_volts == -9.99e-29 ) = NaN;

% Calculate oxygen solubility calculated using calibrated CTD data
[~, cast06u.oxsol_uM] = sbsoxygensol(cast06u.t, cast06u.SP, 'sbs');
cast06u.oxsol_umolkg = cast06u.oxsol_uM*1000./cast06u.prho;

[~, cast06d.oxsol_uM] = sbsoxygensol(cast06d.t, cast06d.SP, 'sbs');
 
cast06u.DO_uM = cal.SOCcalc*(cast06u.oxy_volts + cal.VOFFSET).*cast06u.oxsol_uM...
    .*(1 + cal.A*cast06u.t + cal.B*cast06u.t.^2 + cal.C*cast06u.t.^3)...
    .*exp((cal.Ecalc*cast06u.prs)./(cast06u.t + 273.15));
cast06d.DO_uM = cal.SOCcalc*(cast06d.oxy_volts + cal.VOFFSET).*cast06d.oxsol_uM...
    .*(1 + cal.A*cast06d.t + cal.B*cast06d.t.^2 + cal.C*cast06d.t.^3)...
    .*exp((cal.Ecalc*cast06d.prs)./(cast06d.t + 273.15));

cast06u.DO_umolkg = cast06u.DO_uM *1000./cast06u.prho;
cast06d.DO_umolkg = cast06d.DO_uM *1000./cast06d.prho;

figure
plot(cast06d.DOcorr_umolkg,cast06d.prs)
hold on
plot(cast06u.DOcorr_umolkg,cast06u.prs)
axis ij
plot(btlsum.Winkler_umolkg(btlsum.Cast == 6),btlsum.prs(btlsum.Cast == 6),'.k','Markersize',20)

figure
plot(cast06d.DO_umolkg,cast06d.prs)
hold on
plot(cast06u.DO_umolkg,cast06u.prs)
axis ij
plot(btlsum.Winkler_umolkg(btlsum.Cast == 6),btlsum.prs(btlsum.Cast == 6),'.k','Markersize',20)
plot(Winklers,X(:,4),'.','MarkerSize',20)
%%

%Plot residuals versus pressure, time, station, DO concentration with outliers removed   
mdl = mdl6;
Winkler_outliers = Winkler_outliers5;
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
sgtitle('Irminger Year 1: NLMR')

   

%%
% Use calculated E term to look at drift of SOC in time and by cast number 
cal.SOCcalc = mdl.Coefficients.Estimate(1);
cal.Ecalc = mdl.Coefficients.Estimate(2);
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
sgtitle('Irminger 1: SOC Drift')

subplot(1,2,2)
errorbar(driftdt,SOCdt,SOCstd,'o')
ylabel('Calculated SOC')
datetick
grid on
title('By Time')
%%
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
sgtitle('Irminger 1: SOC drift')

%% Calculate residuals with constant SOC and calculated E term

x = [btlsum.oxy_volts,btlsum.oxsol_umolkg,btlsum.t,btlsum.prs];

% SBE functional form without SOC drift 
btlsum.DO_umolkg = cal.SOCcalc*(x(:,1) + Voffset).*x(:,2)...
    .*(1 + A*x(:,3) + B*x(:,3).^2 + C*x(:,3).^3)...
    .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));


%% Calculate residuals with drifting SOC and calculated E term
% By cast number 
x = [btlsum.oxy_volts,btlsum.oxsol_umolkg,btlsum.t,btlsum.prs,btlsum.Cast];
btlsum.DO_cn_umolkg = ((b_cn(1) + (b_cn(2).*x(:,5))).*(x(:,1) + Voffset)).*x(:,2)...
    .*(1 + A*x(:,3) + B*x(:,3).^2 + C*x(:,3).^3)...
    .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));

% By cruise time 
x = [btlsum.oxy_volts,btlsum.oxsol_umolkg,btlsum.t,btlsum.prs,btlsum.dt_days];
btlsum.DO_dt_umolkg = ((b_dt(1) + (b_dt(2).*x(:,5))).*(x(:,1) + Voffset)).*x(:,2)...
    .*(1 + A*x(:,3) + B*x(:,3).^2 + C*x(:,3).^3)...
    .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));

% fitlm(X,y)
lm_fit_cn = fitlm(btlsum.DO_cn_umolkg,btlsum.Winkler_umolkg_wout_outliers)
btlsum.resid_cn = lm_fit_cn.Residuals.Raw;

lm_fit_dt = fitlm(btlsum.DO_dt_umolkg,btlsum.Winkler_umolkg_wout_outliers)
btlsum.resid_dt = lm_fit_dt.Residuals.Raw;
% figure
% plot(lm_fit)
%%
figure
subplot(1,2,1)
plot(lm_fit_cn)
% ylabel('SOC Calculated by Cast')
% xlabel('Cast number')
grid on
% text(min(cn)+1,max(SOCdt)+0.0005,{['SOC = ' num2str(b_cn(1),6) ' + ' num2str(b_cn(2)) '*cast number' ],...
%     ['R-squared = ' num2str(SOClm_cn.Rsquared.Ordinary)]})
title('By Cast Number')
% legend('Location','SE')

subplot(1,2,2)
plot(lm_fit_dt)
% ylabel('SOC Calculated by Cast')
% xlabel(['Days since ' datestr(min(datenum(btlsum.Date)))])
grid on
% text(min(dtx)+1,max(SOCdt)+0.0005,{['SOC = ' num2str(b_dt(1),6) ' + ' num2str(b_dt(2)) '*time (days)' ],...
%     ['R-squared = ' num2str(SOClm_dt.Rsquared.Ordinary)]})
title('By time (days)')
% legend('Location','SE')
sgtitle('Irminger 1: SOC drift')
%%

figure
plot(btlsum.Winkler_umolkg_wout_outliers,btlsum.DO_umolkg,'.','MarkerSize',10)
hold on
plot(btlsum.Winkler_umolkg_wout_outliers,btlsum.DO_cn_umolkg,'*')
plot(btlsum.Winkler_umolkg_wout_outliers,btlsum.DO_dt_umolkg,'o')
daspect([1 1 1])
grid on
ylabel('Oxygen NLMR with SOC drift calculation \mumol/kg')
xlabel('Oxygen Winklers \mumol/kg')



%%
%Plot residuals versus pressure, time, station, DO concentration with outliers removed   

figure
%Plot residuals versus pressure 
subplot(2,2,1)
% plot(btlsum.prs, btlsum.resid, '.','Markersize',10); hold on;
plot(btlsum.prs, btlsum.resid_dt, 'k.','Markersize',10); 
ylabel({'Residual, Winkler - NLMR output','w/ SOC drift correction (\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number 
subplot(2,2,2)
% plot(datenum(btlsum.Date) - min(datenum(btlsum.Date)), btlsum.resid,'.','Markersize',10); hold on
plot(datenum(btlsum.Date) - min(datenum(btlsum.Date)), btlsum.resid_dt,'k.','Markersize',10); 
ylabel({'Residual, Winkler - NLMR output','w/ SOC drift correction (\mumol/kg)'})
xlabel(['Days since ' datestr(min(datenum(btlsum.Date)))])
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
% plot(btlsum.t, btlsum.resid, '.','Markersize',10); hold on;
plot(btlsum.t, btlsum.resid_dt, 'k.','Markersize',10);
ylabel({'Residual, Winkler - NLMR output','w/ SOC drift correction (\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
% plot(btlsum.Winkler_umolkg, btlsum.resid, '.','Markersize',10); hold on;
plot(btlsum.Winkler_umolkg, btlsum.resid_dt, '.k','Markersize',10);
ylabel({'Residual, Winkler - NLMR output','w/ SOC drift correction (\mumol/kg)'})
xlabel('Winkler (\mumol/kg)')
grid on
sgtitle('Irminger Year 1: NLMR with SOC_d_t drift correction')

 