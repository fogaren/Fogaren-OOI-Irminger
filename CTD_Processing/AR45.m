clearvars
addpath('G:\My Drive\Matlab_work\BC\Irminger\colab-workspace\CTD_Processing')
addpath('G:\My Drive\Matlab_work\BC\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Sea-Bird-Toolbox')
addpath(genpath('G:\My Drive\Matlab_work\Functions\GSW'))

dir = ('C:\Users\fogaren\Documents\SBE\AR45\ctd_data\raw'); % processed SBE cnvs
Leahbtldir = ('C:\Users\fogaren\Documents\SBE\AR45\From_Leah'); % Leah's calibrated bottle product
mybtldir = ('C:\Users\fogaren\Documents\SBE\AR45\btl_data'); % my processed bottle product 

%% Read in Winkler values, my processed bottle files and Leah's calibrated files and combine them
cd('C:\Users\fogaren\Documents\SBE\AR45')
Winklers = readtable('Winkler AR45_KF.xlsx','TextType','string');

cd(Leahbtldir)
btlfiles = ls('*.cbot_s'); % List of Leah's calibrated bottle files 
btlcasts = str2num(btlfiles(:,6:8)); % Pulls out cast numbers that have bottle files 

cd(mybtldir)
mybtlfiles = ls('*.csv'); % List of my processed bottle files 
mybtlcasts = str2num(mybtlfiles(:,6:8)); % Pulls out cast numbers that have bottle files 

% Make sure that there is a Leah bottle file for each of my bottle files 
if mybtlcasts == btlcasts 
    disp('Btl Casts Line Up')
    addpath(Leahbtldir)
    addpath(mybtldir)
    
else
    disp('Caution: Issue with Btl Cast Numbers!')
end

btlsum = []; % Indexes by cast number leah_btl{5} == cast 5; 

CTD_sen = 1; % Choose CTD primary or secondary CTD package 

% Combine files and calculate sea water properties for CTD sensor number 
for i = 1:height(btlcasts) % Number of bottle summary files 
    btlsum{i} = combine_btl_files(btlfiles(i,:),mybtlfiles(i,:),Winklers(Winklers.Cast == btlcasts(i),:),CTD_sen) ;
end

% Pull all bottle files and create one large table 
btlsum_all = [];
for i = 1:length(btlsum)
    btlsum_all = [btlsum_all; btlsum{i}];
end
%%
% From SBE factory calibration 
% Serial number 1960, Calibration Date 15-May-2019
cal.SOC = 4.48650e-001;
cal.Voffset = -4.98500e-001;
cal.A = -4.56920e-003;
cal.B = 2.39370e-004; 
cal.C = -3.42490e-006;
cal.E = 3.60000e-002;
%% non linear multiple regression 

% Calculate oxygen solubility using calibrated CTD data     *** Check this
% equation
[~, oxsol_uM] = sbsoxygensol(btlsum_all.t, btlsum_all.SP, 'sbs');
btlsum_all.oxsol_umolkg = oxsol_uM*1000./btlsum_all.prho; % Convert to umol/kg

% Model variables 
X = [btlsum_all.oxy_volts,btlsum_all.oxsol_umolkg,btlsum_all.t,btlsum_all.prs];
% X = [btlsum_all.oxy_volts,btlsum_all.O2sol_umolkg,btlsum_all.t,btlsum_all.prs];

% SBE functional form 
modelfun = @(b,x)(b(1)*(x(:,1) + cal.Voffset)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

% % SBE functional form with tau 
% modelfun = @(b,x)b(1)...
%     *(x(:,1) + Voffset + b(3)*(exp((D1*x(:,4)) + (D2*(x(:,3) - 20)))).*x(:,5))...
%     .*x(:,2)...
%     .*(1 + A*x(:,3) + B*x(:,3).^2 + C*x(:,3).^3)...
%     .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0 = [0 0]; % Starting values for coefficient iterations 

%Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
%functional form using all Winklers_umolkg (from calibrated T/S data) 
% Run non linear model fit with all Winkler/CTD oxygen (volts) values
mdl0 = fitnlm(X,btlsum_all.Winkler_umolkg,modelfun,beta0)

figure
boxplot(mdl0.Residuals.raw)
ylabel('DO Residuals, Winkler - NLMR output (\mumol/kg)')

figure
histfit(mdl0.Residuals.raw)
title('Residuals with Outliers')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

%% Run non linear model fit with outlying Winkler-CTD(DO) residuals removed 
% Find outliers 
Winkler_outliers = find(isoutlier(mdl0.Residuals.raw,'median') == 1);

% Exclude outliers from NLMR model 
mdl = fitnlm(X,btlsum_all.Winkler_umolkg,modelfun,beta0,'Exclude',Winkler_outliers)

figure
boxplot(mdl.Residuals.raw)
ylabel('DO Residuals, Winkler - NLMR output (\mumol/kg)')

figure
histfit(mdl.Residuals.raw,16)
title('Residuals with Outliers Removed')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

%%
%Plot residuals versus pressure, time, station, DO concentration with outliers removed   

figure
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_all.prs, mdl.Residuals.raw, 'k.','Markersize',20); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Pressure (db)')
ylim([-2 2]); grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(datenum(btlsum_all.Date) - min(datenum(btlsum_all.Date)), mdl.Residuals.raw, 'k.','Markersize',20); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel(['Days since ' datestr(min(datenum(btlsum_all.Date)))])
ylim([-2 2]); grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_all.t, mdl.Residuals.raw, 'k.','Markersize',20); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Temperature (\circC)')
ylim([-2 2]); grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_all.Winkler_umolkg, mdl.Residuals.raw, 'k.','Markersize',20); hold on;
ylabel({'Residual, Winkler - NLMR output','(\mumol/kg)'})
xlabel('Winkler (\mumol/kg)')
ylim([-2 2]); grid on
sgtitle('Irminger Year 9: NLMR')

%%
% Use calculated E term to look at drift of SOC in time and by cast number 
cal.SOCcalc = mdl.Coefficients.Estimate(1);
cal.Ecalc = mdl.Coefficients.Estimate(2);
cal.gain = cal.SOCcalc/cal.SOC;
Tempcorr = 1 + cal.A*btlsum_all.t + cal.B*btlsum_all.t.^2 + cal.C*btlsum_all.t.^3;
Prescorr = exp(cal.Ecalc*btlsum_all.prs./(btlsum_all.t + 273.15));

% Group SOC calculations by cast number 
cn = unique(btlsum_all.Cast(~isnan(btlsum_all.Winkler_umolkg)));

% Remove outliers from Winklers 
btlsum_all.Winkler_umolkg_wout_outliers = btlsum_all.Winkler_umolkg;
btlsum_all.Winkler_umolkg_wout_outliers(Winkler_outliers) = NaN;

% Preallocate arrays 
driftdt = NaN(1,length(cn));
SOCdt = NaN(1,length(cn));
SOCstd = NaN(1,length(cn));

% Calculate SOC for each Winkler sample 
btlsum_all.SOCcalc = btlsum_all.Winkler_umolkg_wout_outliers...
    ./(Tempcorr.*Prescorr.*btlsum_all.oxsol_umolkg.*(btlsum_all.oxy_volts+cal.Voffset));

% calculate mean time, mean SOC, and std of SOC by cast number  
for i = 1:length(cn)
    driftdt(i) = nanmean(datenum(btlsum_all.Date(btlsum_all.Cast == cn(i))));
    SOCdt(i) = nanmean(btlsum_all.SOCcalc(btlsum_all.Cast == cn(i)));
    SOCstd(i) = nanstd(btlsum_all.SOCcalc(btlsum_all.Cast == cn(i)));
end

figure
subplot(1,2,1)
errorbar(cn,SOCdt,SOCstd,'o')
ylabel('Calculated SOC')
grid on
xlabel('By Cast Number')
title('By Cast')
sgtitle('Irminger 9: SOC Drift')

subplot(1,2,2)
errorbar(driftdt,SOCdt,SOCstd,'o')
ylabel('Calculated SOC')
datetick
grid on
title('By Time')
%%
cn_all = unique(btlsum_all.Cast);
Cast_dt = [];
drift_dt_all = [];
for i = 1:length(cn_all)
    driftdt_all(i) = nanmean(datenum(btlsum_all.Date(btlsum_all.Cast == cn_all(i))));
    Cast_dt(btlsum_all.Cast == cn_all(i)) = driftdt_all(i);
end
btlsum_all.dt_days = Cast_dt' - min(Cast_dt); 

dtx = driftdt-min(driftdt); % Days since start of cruise

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
xlabel(['Days since ' datestr(min(datenum(btlsum_all.Date)))])
grid on
text(min(dtx)+1,max(SOCdt)+0.0005,{['SOC = ' num2str(b_dt(1),6) ' + ' num2str(b_dt(2)) '*time (days)' ],...
    ['R-squared = ' num2str(SOClm_dt.Rsquared.Ordinary)]})
title('By time (days)')
legend('Location','SE')
sgtitle('Irminger 9: SOC drift')

%% Calculate residuals with constant SOC and calculated E term
x = [btlsum_all.oxy_volts,btlsum_all.oxsol_umolkg,btlsum_all.t,btlsum_all.prs];
% SBE functional form without SOC drift 
btlsum_all.CTDDO_umolkg = cal.SOCcalc*(x(:,1) + cal.Voffset).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));

btlsum_all.CTDDO_umolkg_SBEcal = cal.SOC*(x(:,1) + cal.Voffset).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));

lm_fit_Winklers = fitlm(btlsum_all.CTDDO_umolkg,btlsum_all.Winkler_umolkg_wout_outliers)
lm_fit_SBEcal = fitlm(btlsum_all.CTDDO_umolkg_SBEcal,btlsum_all.Winkler_umolkg_wout_outliers)

figure
histfit(lm_fit_SBEcal.Residuals.raw,16)
title('Residuals with Outliers Removed')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

figure
plot(btlsum_all.Winkler_umolkg_wout_outliers,btlsum_all.CTDDO_umolkg,'.b','MarkerSize',20)
hold on
plot(btlsum_all.Winkler_umolkg_wout_outliers,btlsum_all.CTDDO_umolkg_SBcal,'r.','Markersize',20)
plot(250:310,250:310,'k--','Linewidth',2)
daspect([1 1 1]); grid on
ylabel('CTD-DO (\mumol/kg)')
xlabel('Winkler-DO (\mumol/kg)')
legend('CTD-DO w/ Winkler Calibration','CTD-DO w/SBE factory Calibration','1:1 Ratio','Location','NW')
%% Calculate residuals with drifting SOC and calculated E term
% By cast number 
x = [btlsum_all.oxy_volts,btlsum_all.oxsol_umolkg,btlsum_all.t,btlsum_all.prs,btlsum_all.Cast];
btlsum_all.CTDDO_cn_umolkg = ((b_cn(1) + (b_cn(2).*x(:,5))).*(x(:,1) + cal.Voffset)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));

% By cruise time 
x = [btlsum_all.oxy_volts,btlsum_all.oxsol_umolkg,btlsum_all.t,btlsum_all.prs,btlsum_all.dt_days];
btlsum_all.CTDDO_dt_umolkg = ((b_dt(1) + (b_dt(2).*x(:,5))).*(x(:,1) + cal.Voffset)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));

% fitlm(X,y)
lm_fit_cn = fitlm(btlsum_all.CTDDO_cn_umolkg,btlsum_all.Winkler_umolkg_wout_outliers)
btlsum_all.resid_cn = lm_fit_cn.Residuals.Raw;

lm_fit_dt = fitlm(btlsum_all.CTDDO_dt_umolkg,btlsum_all.Winkler_umolkg_wout_outliers)
btlsum_all.resid_dt = lm_fit_dt.Residuals.Raw;

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
sgtitle('Irminger 9: SOC drift')
%%

figure
plot(btlsum_all.Winkler_umolkg_wout_outliers,btlsum_all.CTDDO_umolkg,'.','MarkerSize',10)
hold on
plot(btlsum_all.Winkler_umolkg_wout_outliers,btlsum_all.DO_cn_umolkg,'*')
plot(btlsum_all.Winkler_umolkg_wout_outliers,btlsum_all.DO_dt_umolkg,'o')
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
sgtitle('Irminger Year 9: NLMR with SOC_d_t drift correction')
%% Look at Linear Regression Model for comparison

cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year9')
load Year9_Processed_KF.mat 
% btlsum_yr9 = [btlsum07; btlsum08; btlsum10; btlsum11; btlsum12; btlsum13; btlsum14;...
%     btlsum16; btlsum17; btlsum18; btlsum19; btlsum20; btlsum21; btlsum22]; 
% Volts with hysteresis correction 
X = [btlsum_yr9.t, btlsum_yr9.oxy_volts, datenum(btlsum_yr9.Date), btlsum_yr9.prs];

lm0 = fitlm(X,btlsum_yr9.Winkler_umolkg)
resid_outliers = find(isoutlier(lm0.Residuals.Raw,'median') == 1)

% y = btlsum0.t901*0.010011 + btlsum0.CTDoxy_mLL_nohyst*1.0498 + btlsum0.Cast*0.0031966 + btlsum0.prs*0.00010029 + -0.12737;
lm = fitlm(X,btlsum_yr9.Winkler_umolkg,'Exclude',resid_outliers)
%%
lmresid = (btlsum0.Winkler_mLL - y)*44.661;
%myresid = (btlsum0.Winkler_mLL -btlsum0. - btlsum_yr9.DOcorr_mLL)*44.661,'*','Color',red)
grid on

%%

cd(dir)
files = ls('*.cnv');

upcast = [];
downcast = [];

addpath('.\upcasts')
addpath('.\downcasts')

for i = 1:length(files)
    upcast{i} = readSBScnv(['u' files(i,:)]);
    downcast{i} = readSBScnv(['d' files(i,:)]);
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
    
    % Format structure for conversion to table and convert to table 
    btl = readtable(my_btl_file,'TextType','string');
    vars = {'Bottle','Date','PrDM','DepSM','Latitude','Longitude','Sbeox0V','Sbeox0ML_L'};
    btl = btl(:,vars);
    btl.Properties.VariableNames = {'Bottle','Date','PrDM','depth','lat','lon','oxy_volts','CTDoxy_mLL_hyst'};
%     btl.sal1_uncorr = gsw_SP_from_C(btl.cond1,btl.temp1,btl.PrDM);
%     btl.sal2_uncorr = gsw_SP_from_C(btl.cond2,btl.temp2,btl.PrDM);
    btl.CTDcal(:) = {'True'};
    btl.CTDcal = string(btl.CTDcal);
    
    % Combine tables by Bottle variable 
    btlsum0 = join(leah_btl,btl,'Keys','Bottle');
    btlsum = join(btlsum,btlsum0,'Keys','Bottle');
 
    % Decide if using primary or secondary CTD sensor for temp and sal
    if CTD_sen == 1 % primary sensor (use unless something wrong with data)
        btlsum.t = btlsum.temp1; 
        btlsum.SP = btlsum.sal1; 
%         [oxsol_uncal,~] = sbsoxygensol( btlsum.temp1, btlsum.sal1_uncorr, 'sbs' );
     end
    
    if CTD_sen == 2 % secondary sensor (use if primary sensor bad)
        btlsum.t = btlsum.temp2; 
        btlsum.SP = btlsum.sal2; 
%         [oxsol_uncal,~] = sbsoxygensol( btlsum.temp2, btlsum.sal2_uncorr, 'sbs' );
    end    

    btlsum.CTD_sen = ones(length(btlsum.prs),1)*CTD_sen; 
    btlsum.SA = gsw_SA_from_SP(btlsum.SP,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.CT = gsw_CT_from_t(btlsum.SA,btlsum.t,btlsum.prs);
    btlsum.pt = gsw_pt_from_CT(btlsum.SA,btlsum.CT);
    btlsum.test = gsw_O2sol_SP_pt(btlsum.SP,btlsum.pt);
    btlsum.O2sol_umolkg = gsw_O2sol(btlsum.SA,btlsum.CT,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.rho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,btlsum.prs); % in situ density
    btlsum.prho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,0); % potential density with ref == surf
    btlsum.sigma0 = gsw_sigma0_CT_exact(btlsum.SA,btlsum.CT); % btlsum.prho - 1000 = btlsum.sigma0
%     btlsum.DOcorr_umolkg = btlsum.DOcorr_mLL*1000*44.661./btlsum.prho;  % uses potential density
    btlsum.Winkler_umolkg = btlsum.Winkler_mLL*1000*44.661./btlsum.prho; % uses potential density 

%     [oxsol_cal,~] = sbsoxygensol( t, SP, 'sbs' ); % Calculates solubility using calibrated data 
%     
%     % Oxygen (ml/l) = [Soc * (V + Voffset)] * Oxsol (T,S) * (1.0 + A*T + B*T2 + C*T3) * e (E*P/K)
%     btlsum.CTDoxy_mLL_cal = btlsum.CTDoxy_mLL_hyst./oxsol_uncal.*oxsol_cal;

     % Reorder variables and remove unnecessary ones
    btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2','Meas_SAL','CTDcal',...
    'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','CTDoxy_mLL_nohyst','CTDoxy_mLL_hyst','Winkler_mLL','Winkler_umolkg','O2sol_umolkg'};
    btlsum = btlsum(:,btlvars);
end


function [cast] = combine_CTD_files(leah_cast,cast,CTD_sen)

    % Format structure for conversion to table and convert to table 
    fields = {'woce','date','time'};
    leah_cast = rmfield(leah_cast,fields);
    leah_cast.station = leah_cast.station.*ones(length(leah_cast.prs),1);
    leah_cast.lat = leah_cast.lat.*ones(length(leah_cast.prs),1);
    leah_cast.lon = leah_cast.lon.*ones(length(leah_cast.prs),1);
    leah_cast = struct2table(leah_cast);
    
    % Format structure for conversion to table and convert to table 
    cast.station = str2num(cast.source(7:9))*ones(length(cast.pm),1);
    fields = {'source','DataFileType','instrumentheaders','userheaders','vars','longname','units','span','mvars','mvars_format'...
        'scan','lat','lon','nbin','flag','SeasaveVersion','softwareheaders'};
    cast = rmfield(cast,fields);
    cast = struct2table(cast);
    cast.Properties.VariableNames = {'CastTimeS','prs','depth','temp1','temp2','cond1','cond2','oxy_volts','oxy_mLL_preproc','oxy_mLL_derived'};
    cast.StartTimeUTC = ones(length(cast.CastTimeS),1)*datenum(cast0.instrumentheaders.SystemUTC); 
    cast.StartTimeUTC = datetime(cast.StartTimeUTC,'ConvertFrom','datenum');
    cast.CastTimeUTC = cast.StartTimeUTC + cast.CastTimeS/3600/24;
    cast.sal1_uncorr = gsw_SP_from_C(cast.cond1,cast.temp1,cast.prs);
    cast.sal2_uncorr = gsw_SP_from_C(cast.cond2,cast.temp2,cast.prs);
    cast.CTDcal(:) = {'True'};
    cast.CTDcal = string(cast.CTDcal);
    cast = cast(:,{'prs','depth','temp1','temp2','cond1','cond2','sal1_uncorr','sal2_uncorr','oxy_volts','oxy_mLL_preproc','oxy_mLL_derived','CastTimeS','CastTimeUTC','StartTimeUTC','CTDcal'});  

    % Combine tables by prs variable 
    cast = join(leah_cast,cast,'Keys','prs');
   
    % Decide if using primary or secondary CTD sensor for temp and sal
    if CTD_sen == 1 % primary sensor (use unless something wrong with data)
        t = cast.t901; 
        SP = cast.sal1; 
        [oxsol_uncal,~] = sbsoxygensol( cast.temp1, cast.sal1_uncorr, 'sbs' );
    end
    
    if CTD_sen == 2 % secondary sensor (use if primary sensor bad)
        t = cast.t902; 
        SP = cast.sal2; 
        [oxsol_uncal,~] = sbsoxygensol( cast.temp2, cast.sal2_uncorr, 'sbs' );
    end    
        
    if CTD_sen == 3 % average of primary and secondary sensors (not recommended by Leah)
        t = mean([cast.t901 cast.t902],2,'omitnan'); 
        SP = mean([cast.sal1 cast.sal2],2,'omitnan'); 
        oldt = mean([cast.temp1 cast.temp2],2,'omitnan');
        oldsal = mean([cast.sal1_uncorr cast.sal2_uncorr],2,'omitnan');
        [oxsol_uncal,~] = sbsoxygensol( oldt, oldsal, 'sbs' );
    end
    
    [oxsol_cal,~] = sbsoxygensol( t, SP, 'sbs' ); % Calculates solubility using calibrated data 
    
    % Oxygen (ml/l) = [Soc * (V + Voffset)] * Oxsol (T,S) * (1.0 + A*T + B*T2 + C*T3) * e (E*P/K)
    cast.oxy_mLL_oxsolcorr = cast.oxy_mLL_derived./oxsol_uncal.*oxsol_cal;
    

end
