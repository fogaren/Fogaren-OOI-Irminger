% Set up workspace 
clearvars
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
addpath(genpath('G:\My Drive\Matlab_work\Github\GSW-Matlab'))
addpath(genpath('G:\My Drive\Matlab_work\Github\cmocean'))

cal_dir = 'C:\Users\fogaren\Desktop\Irminger_2024\AR84_02\CTDdata\calibrated_btl_files'; 
Wink_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\AR84_02\Winkler_csvs'; 
btl_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\AR84_02\btl_csvs';

filesave = 0; % filesave == 1, save calibration output as mat file

% Use Bottle samples to calculate new SOC (gain) and E terms for CTD data 
% CTD_sen = 2; % Use primary or secondary CTD temp and sal and oxygen

%% Combine Winkler data with oxygen voltages and Leah's calibrated product 
cd(cal_dir)
btlfiles = ls('*.cbot_so'); % List of Leah's calibrated bottle files 
btlcasts = str2num(btlfiles(:,9:11)); % Pulls out cast numbers that have bottle files

cd(Wink_dir)
% removed duplicate station files to Duplicate_Stations folder
% Looks like they made some type of sal correction at sea
Winkfiles = ls('*.csv'); % List of my processed bottle files 
Winkcasts = str2num(Winkfiles(:,1:3)); % Pulls out cast numbers that have bottle files 

cd(btl_dir)
mybtlfiles = ls('*.csv'); % List of my processed bottle files 
mybtlcasts = str2num(mybtlfiles(:,9:11)); % Pulls out cast numbers that have bottle files 

% Removed bottle files that didn't have sal or DO discrete samples 
addpath(cal_dir)
addpath(Wink_dir)
addpath(btl_dir)
%%
Winkler_btl = [];
for j = 1:height(Winkcasts)
    Winkler_btl{Winkcasts(j)} = format_Winkler_files(Winkfiles(j,:));
end

%%
btlsum = []; % Indexes by cast number leah_btl{5} == cast 5; 
for j = 1:height(Winkcasts) % Number of Winker files 
    btlfile_ind = find(btlcasts == Winkcasts(j)); % because not every cast has sal and winkler bottles 
    mybtlfile_ind = find(mybtlcasts == Winkcasts(j)); 
    % btlsum{Winkcasts(j)} = combine_btl_files(Winkler_btl{Winkcasts(j)},btlfiles(btlfile_ind,:),mybtlfiles(mybtlfile_ind,:),CTD_sen);
    btlsum{Winkcasts(j)} = combine_btl_files2(Winkler_btl{Winkcasts(j)},btlfiles(btlfile_ind,:),mybtlfiles(mybtlfile_ind,:));
end

% Pull all bottle files and create one large table 
btlsum_tbl = [];
for j = 1:length(btlsum)
    btlsum_tbl = [btlsum_tbl; btlsum{j}];
end
%% If processing just one 
% if CTD_sen == 1
% 
%     % From SBE factory calibration 
%     % Serial number 0072, Calibration Date 3-Oct-2023
%     cal.SOC = 4.63190e-001;
%     cal.VOFFSET = -4.88200e-001;
%     cal.A = -5.35510e-003;
%     cal.B = 2.42950e-004; 
%     cal.C = -3.49330e-006;
%     cal.E = 3.60000e-002;
%     cal.Tau20 = 1.19000e+000;
%     cal.INSTRUMENT_TYPE = 'SBE43';
%     cal.SERIALNO = '0072';
%     cal.OCALDATE = '03-Oct-2023';
% 
%     btlsum_tbl.oxy_volts = btlsum_tbl.oxy_volts1;
% end
% 
% if CTD_sen == 2
% 
%     % From SBE factory calibration 
%     % Serial number 0449, Calibration Date 06-Mar-24
%     cal.SOC = 3.81570e-001;
%     cal.VOFFSET = -7.17000e-001;
%     cal.A = -3.49850e-003;
%     cal.B = 1.49470e-004; 
%     cal.C = -2.69920e-006;
%     cal.E = 3.60000e-002;
%     cal.Tau20 = 1.12000e+000;
%     cal.INSTRUMENT_TYPE = 'SBE43';
%     cal.SERIALNO = '0449';
%     cal.OCALDATE = '06-Mar-24';
% 
%     btlsum_tbl.oxy_volts = btlsum_tbl.oxy_volts2;
% end

% non linear multiple regression for just one. 
% Oxygen solubility calculated using GSW Toolbox 
% Model variables 
% X = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
% 
% btlsum_tbl.Winkler1_umolkg(btlsum_tbl.t < 2) = NaN;
% btlsum_tbl.Winkler2_umolkg(btlsum_tbl.t < 2) = NaN;
% Treats Winklers as individual points 
X = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs]];
bad_casts = [btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use = [btlsum_tbl.Winkler1_umolkg; btlsum_tbl.Winkler2_umolkg];
% Winklers_to_use = [btlsum_tbl.Winkler1_umolkg_draw; btlsum_tbl.Winkler2_umolkg_draw];
pdens = [btlsum_tbl.prho; btlsum_tbl.prho];

% SBE functional form 
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta0 = [cal.SOC 0]; % Starting values for coefficient iterations 

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
%
figure
%Plot residuals versus temperature 
plot(btlsum_tbl.Winkler1_umolkg./btlsum_tbl.O2sol_umolkg_draw1*100, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg./btlsum_tbl.O2sol_umolkg_draw2*100, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Percent Saturation')
grid on

%% Processing both sensors
% From SBE factory calibration 
% Serial number 0072, Calibration Date 3-Oct-2023
cal1.SOC = 4.63190e-001;
cal1.VOFFSET = -4.88200e-001;
cal1.A = -5.35510e-003;
cal1.B = 2.42950e-004; 
cal1.C = -3.49330e-006;
cal1.E = 3.60000e-002;
cal1.Tau20 = 1.19000e+000;
cal1.INSTRUMENT_TYPE = 'SBE43';
cal1.SERIALNO = '0072';
cal1.OCALDATE = '03-Oct-2023';

% From SBE factory calibration 
% Serial number 0449, Calibration Date 06-Mar-24
cal2.SOC = 3.81570e-001;
cal2.VOFFSET = -7.17000e-001;
cal2.A = -3.49850e-003;
cal2.B = 1.49470e-004; 
cal2.C = -2.69920e-006;
cal2.E = 3.60000e-002;
cal2.Tau20 = 1.12000e+000;
cal2.INSTRUMENT_TYPE = 'SBE43';
cal2.SERIALNO = '0449';
cal2.OCALDATE = '06-Mar-24';
%%
% non linear multiple regression for just one. 
% Oxygen solubility calculated using GSW Toolbox 
% Model variables 
% X = [btlsum_tbl.oxy_volts,btlsum_tbl.O2sol_umolkg,btlsum_tbl.t,btlsum_tbl.prs];
% 

% Treats Winklers as individual points 
X1 = [[btlsum_tbl.oxy_volts1; btlsum_tbl.oxy_volts1],...
    [btlsum_tbl.O2sol_umolkg1; btlsum_tbl.O2sol_umolkg1],...
    [btlsum_tbl.t1; btlsum_tbl.t1],...
    [btlsum_tbl.prs; btlsum_tbl.prs]];
bad_casts1 = [btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check1 = [btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use1 = [btlsum_tbl.Winkler1_umolkg1; btlsum_tbl.Winkler2_umolkg1];
pdens1 = [btlsum_tbl.prho1; btlsum_tbl.prho1];

% SBE functional form 
modelfun1 = @(b,x)(b(1)*(x(:,1) + cal1.VOFFSET)).*x(:,2)...
    .*(1 + cal1.A*x(:,3) + cal1.B*x(:,3).^2 + cal1.C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta01 = [cal1.SOC 0]; % Starting values for coefficient iterations 

%Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
%functional form using all Winklers_umolkg (from calibrated T/S data) 
% Run non linear model fit with all Winkler/CTD oxygen (volts) values
mdl1 = fitnlm(X1,Winklers_to_use1,modelfun1,beta01)

figure
histfit(mdl1.Residuals.raw)
title('SOC_k Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,'median') == 1);
mdl2 = fitnlm(X1,Winklers_to_use1,modelfun1,beta01,'Exclude',Winkler_outliers1)

figure
histfit(mdl2.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl2.Residuals.raw,'median') == 1);
Winkler_outliers2 = [ind; Winkler_outliers1];
% Exclude outliers from NLMR model 
mdl3 = fitnlm(X1,Winklers_to_use1,modelfun1,beta01,'Exclude',Winkler_outliers2)

figure
histfit(mdl3.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl3.Residuals.raw,'median') == 1);
Winkler_outliers3 = [ind; Winkler_outliers2];
% Exclude outliers from NLMR model 
mdl4 = fitnlm(X1,Winklers_to_use1,modelfun1,beta01,'Exclude',Winkler_outliers3)

figure
histfit(mdl4.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl4.Residuals.raw,'median') == 1);
Winkler_outliers4 = [ind; Winkler_outliers3];
% Exclude outliers from NLMR model 
mdl5 = fitnlm(X1,Winklers_to_use1,modelfun1,beta01,'Exclude',Winkler_outliers4)

figure
histfit(mdl5.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 6 
ind = find(isoutlier(mdl5.Residuals.raw,'median') == 1);
Winkler_outliers5 = [ind; Winkler_outliers4];
% Exclude outliers from NLMR model 
mdl6 = fitnlm(X1,Winklers_to_use1,modelfun1,beta01,'Exclude',Winkler_outliers5)

figure
histfit(mdl6.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 6')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 7 
ind = find(isoutlier(mdl6.Residuals.raw,'median') == 1);
Winkler_outliers6 = [ind; Winkler_outliers5];
% Exclude outliers from NLMR model 
mdl7 = fitnlm(X1,Winklers_to_use1,modelfun1,beta01,'Exclude',Winkler_outliers6)

%Plot residuals versus pressure, time, station, DO concentration with outliers removed   
mdlcal_k = mdl7;
cal1.SOCcalc = mdlcal_k.Coefficients.Estimate(1);
cal1.Ecalc = mdlcal_k.Coefficients.Estimate(2);
cal1.gain = cal1.SOCcalc/cal1.SOC;
cal1.Winkler1_outliers = Winkler_outliers6(Winkler_outliers6 < height(btlsum_tbl));
cal1.Winkler2_outliers = Winkler_outliers6(Winkler_outliers6 > height(btlsum_tbl) & Winkler_outliers6 < 2*height(btlsum_tbl)) - height(btlsum_tbl);

out_NLMR1 = sortrows([bad_casts1(Winkler_outliers6) btl_check1(Winkler_outliers6) Winklers_to_use1(Winkler_outliers6)/44.661/1000.*pdens1(Winkler_outliers6)],[1 2])
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
plot(btlsum_tbl.t1, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.t1, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg1, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg1, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('AR84-02: SOC_k CTD Sensor 1')
%
figure
%Plot residuals versus temperature 
plot(btlsum_tbl.Winkler1_umolkg1./btlsum_tbl.O2sol_umolkg1*100, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg1./btlsum_tbl.O2sol_umolkg1*100, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Percent Saturation')
grid on

mdlcal_k1 = mdlcal_k; % because two sets of sensors 

%% Secondary CTD package 
 % Treats Winklers as individual points 
X2 = [[btlsum_tbl.oxy_volts2; btlsum_tbl.oxy_volts2],...
    [btlsum_tbl.O2sol_umolkg2; btlsum_tbl.O2sol_umolkg2],...
    [btlsum_tbl.t2; btlsum_tbl.t2],...
    [btlsum_tbl.prs; btlsum_tbl.prs]];
bad_casts2 = [btlsum_tbl.Cast; btlsum_tbl.Cast];
btl_check2 = [btlsum_tbl.Bottle; btlsum_tbl.Bottle];
Winklers_to_use2 = [btlsum_tbl.Winkler1_umolkg2; btlsum_tbl.Winkler2_umolkg2];
pdens2 = [btlsum_tbl.prho2; btlsum_tbl.prho2];

% SBE functional form 
modelfun2 = @(b,x)(b(1)*(x(:,1) + cal2.VOFFSET)).*x(:,2)...
    .*(1 + cal2.A*x(:,3) + cal2.B*x(:,3).^2 + cal2.C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

beta02 = [cal2.SOC 0]; % Starting values for coefficient iterations 

%Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
%functional form using all Winklers_umolkg (from calibrated T/S data) 
% Run non linear model fit with all Winkler/CTD oxygen (volts) values
mdl1 = fitnlm(X2,Winklers_to_use2,modelfun2,beta02)

figure
histfit(mdl1.Residuals.raw)
title('SOC_k Residuals with Outliers, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,'median') == 1);
mdl2 = fitnlm(X2,Winklers_to_use2,modelfun2,beta02,'Exclude',Winkler_outliers1)

figure
histfit(mdl2.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 2')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 3 
ind = find(isoutlier(mdl2.Residuals.raw,'median') == 1);
Winkler_outliers2 = [ind; Winkler_outliers1];
% Exclude outliers from NLMR model 
mdl3 = fitnlm(X2,Winklers_to_use2,modelfun2,beta02,'Exclude',Winkler_outliers2)

figure
histfit(mdl3.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 3')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 4 
ind = find(isoutlier(mdl3.Residuals.raw,'median') == 1);
Winkler_outliers3 = [ind; Winkler_outliers2];
% Exclude outliers from NLMR model 
mdl4 = fitnlm(X2,Winklers_to_use2,modelfun2,beta02,'Exclude',Winkler_outliers3)

figure
histfit(mdl4.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 4')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 5 
ind = find(isoutlier(mdl4.Residuals.raw,'median') == 1);
Winkler_outliers4 = [ind; Winkler_outliers3];
% Exclude outliers from NLMR model 
mdl5 = fitnlm(X2,Winklers_to_use2,modelfun2,beta02,'Exclude',Winkler_outliers4)

figure
histfit(mdl5.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 5')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 6 
ind = find(isoutlier(mdl5.Residuals.raw,'median') == 1);
Winkler_outliers5 = [ind; Winkler_outliers4];
% Exclude outliers from NLMR model 
mdl6 = fitnlm(X2,Winklers_to_use2,modelfun2,beta02,'Exclude',Winkler_outliers5)

figure
histfit(mdl6.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 6')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 7 
ind = find(isoutlier(mdl6.Residuals.raw,'median') == 1);
Winkler_outliers6 = [ind; Winkler_outliers5];
% Exclude outliers from NLMR model 
mdl7 = fitnlm(X2,Winklers_to_use2,modelfun2,beta02,'Exclude',Winkler_outliers6)

%Plot residuals versus pressure, time, station, DO concentration with outliers removed   
mdlcal_k = mdl7;
cal2.SOCcalc = mdlcal_k.Coefficients.Estimate(1);
cal2.Ecalc = mdlcal_k.Coefficients.Estimate(2);
cal2.gain = cal2.SOCcalc/cal2.SOC;
cal2.Winkler1_outliers = Winkler_outliers6(Winkler_outliers6 < height(btlsum_tbl));
cal2.Winkler2_outliers = Winkler_outliers6(Winkler_outliers6 > height(btlsum_tbl) & Winkler_outliers6 < 2*height(btlsum_tbl)) - height(btlsum_tbl);

out_NLMR2 = sortrows([bad_casts2(Winkler_outliers6) btl_check2(Winkler_outliers6) Winklers_to_use2(Winkler_outliers6)/44.661/1000.*pdens2(Winkler_outliers6)],[1 2])
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
plot(btlsum_tbl.t2, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.t2, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg2, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg2, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('AR84-02: SOC_k CTD Sensor 2')
%
figure
%Plot residuals versus temperature 
plot(btlsum_tbl.Winkler1_umolkg2./btlsum_tbl.O2sol_umolkg2*100, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg2./btlsum_tbl.O2sol_umolkg2*100, mdlcal_k.Residuals.raw(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Percent Saturation')
grid on

mdlcal_k2 = mdlcal_k; % because two sets of sensors 
%% Decided on SOC calibration 
SOC_type = 1;
SOC_type = 1; 
cal.cal1 = cal1;
cal.cal2 = cal2;
%%

% Combine files and calculate sea water properties for CTD sensor number 
for j = 1:height(Winkcasts) % Number of bottle summary files 
    btlsum_tbl1 = calibrate_CTD_oxygen1(btlsum_tbl,cal,SOC_type);
    btlsum_tbl2 = calibrate_CTD_oxygen2(btlsum_tbl,cal,SOC_type);
end
%%
btlsum_tbl = combine_after_sensor_cals(btlsum_tbl1,btlsum_tbl2); 
%%
%%
% For output structure
btlsum = []; % Indexes by cast number leah_btl{5} == cast 5; 
% Combine files and calculate sea water properties for CTD sensor number 
for j = 1:height(Winkcasts) % Number of bottle summary files 
    btlsum{Winkcasts(j)} = btlsum_tbl(btlsum_tbl.Cast == Winkcasts(j),:);
end
%%
Wink1 = btlsum_tbl.Winkler1_umolkg(btlsum_tbl.NLMR_Outlier1 == 0) - btlsum_tbl.DOcorr_umolkg(btlsum_tbl.NLMR_Outlier1 == 0);
Wink2 = btlsum_tbl.Winkler2_umolkg(btlsum_tbl.NLMR_Outlier2 == 0) - btlsum_tbl.DOcorr_umolkg(btlsum_tbl.NLMR_Outlier2 == 0);
Wink3 = btlsum_tbl.Winkler3_umolkg(btlsum_tbl.NLMR_Outlier3 == 0) - btlsum_tbl.DOcorr_umolkg(btlsum_tbl.NLMR_Outlier3 == 0);
Wink = [abs(Wink1); abs(Wink2); abs(Wink3)]; % Should this abs? 
nanmean(Wink)
nanstd(Wink)

dt = driftdt-driftdt(1);
SOCdtstart = dt(1)*cal.SOCrate_dt + cal.SOCcalc_dt
SOCdtend = dt(end)*cal.SOCrate_dt + cal.SOCcalc_dt


%%
btlsum_tbl_AR45 = btlsum_tbl; 
btlsum_AR45 = btlsum;
SBE_cal_AR45 = cal; 
btl_num = btlcasts; 
if filesave == 1
    clear btlsum_tbl btlcasts btlfiles btl_dir  
    cd(samp_dir)
    save AR45_DOcal.mat btl* SBE* mdlcal*
end
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
    btl = readtable(my_btl_file,'TextType','string');
    vars = {'Bottle','Date','PrDM','DepSM','Latitude','Longitude','Sbeox0V','Sbeox1V'};
    btl = btl(:,vars);
    btl.Properties.VariableNames = {'Bottle','Date','PrDM','depth','lat','lon','oxy_volts1','oxy_volts2'};
    
    btlsum = join(Wink_btl_file,leah_btl,'Keys','Bottle');
    btlsum = join(btlsum,btl,'Keys','Bottle');

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
    btlsum.Winkler1_umolkg = btlsum.Winkler1_mLL*1000*44.661./btlsum.prho; % uses potential density 
    btlsum.Winkler2_umolkg = btlsum.Winkler2_mLL*1000*44.661./btlsum.prho; % uses potential density 

    btlsum.CT_draw1 = gsw_CT_from_t(btlsum.SA,btlsum.draw_temp1,btlsum.prs);
    btlsum.pt_draw1 = gsw_pt_from_CT(btlsum.SA,btlsum.CT_draw1);
    btlsum.O2sol_umolkg_draw1 = gsw_O2sol(btlsum.SA,btlsum.CT_draw1,0,btlsum.lon,btlsum.lat);
    btlsum.prho_draw1 = gsw_rho_CT_exact(btlsum.SA,btlsum.CT_draw1,0); % potential density with ref == surf

    btlsum.CT_draw2 = gsw_CT_from_t(btlsum.SA,btlsum.draw_temp2,btlsum.prs);
    btlsum.pt_draw2 = gsw_pt_from_CT(btlsum.SA,btlsum.CT_draw2);
    btlsum.O2sol_umolkg_draw2 = gsw_O2sol(btlsum.SA,btlsum.CT_draw2,0,btlsum.lon,btlsum.lat);
    btlsum.prho_draw2 = gsw_rho_CT_exact(btlsum.SA,btlsum.CT_draw2,0); % potential density with ref == surf

    btlsum.Winkler1_umolkg_draw = btlsum.Winkler1_mLL*1000*44.661./btlsum.prho_draw1; % uses potential density 
    btlsum.Winkler2_umolkg_draw = btlsum.Winkler2_mLL*1000*44.661./btlsum.prho_draw2; % uses potential density 
    
    % Reorder variables and remove unnecessary ones
    btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2','oxy_volts1','oxy_volts2',...
        'Discrete_Salinity_psu','CTDcal','CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','Winkler1_mLL','Winkler2_mLL'...
        'Winkler1_umolkg','Winkler2_umolkg','Winkler1_umolkg_draw','Winkler2_umolkg_draw','O2sol_umolkg','O2sol_umolkg_draw1','O2sol_umolkg_draw2'};
    btlsum = btlsum(:,btlvars);
end

function btlsum = combine_btl_files2(Wink_btl_file,leah_btl_file,my_btl_file)


    % Format structure for conversion to table and convert to table 
    leah_btl = readtable(leah_btl_file,'FileType','text',NumHeaderLines=4);
    leah_btl.Properties.VariableNames = {'Bottle','prs','temp1','temp2','th190','th290','sal1','sal2','CTDoxy_mLL1','CTDoxy_mLL2','Meas_SAL','Meas_OXYG','QUAL'};
    leah_btl.Meas_SAL(leah_btl.Meas_SAL == -9) = NaN; % replaces no data flag with NaN
    leah_btl.Discrete_Salinity_psu = leah_btl.Meas_SAL;
    leah_btl.Meas_OXYG(leah_btl.Meas_OXYG == -9) = NaN; % replaces no data flag with NaN
    leah_btl.CTDcal(:) = "True"; 

    % Format structure for conversion to table and convert to table 
    btl = readtable(my_btl_file,'TextType','string');
    vars = {'Bottle','Date','PrDM','DepSM','Latitude','Longitude','Sbeox0V','Sbeox1V'};
    btl = btl(:,vars);
    btl.Properties.VariableNames = {'Bottle','Date','PrDM','depth','lat','lon','oxy_volts1','oxy_volts2'};
    
    btlsum = join(Wink_btl_file,leah_btl,'Keys','Bottle');
    btlsum = join(btlsum,btl,'Keys','Bottle');

    % Process both primary and secondary sensor 
    btlsum.t1 = btlsum.temp1; 
    btlsum.SP1 = btlsum.sal1; 
    btlsum.t2 = btlsum.temp2; 
    btlsum.SP2 = btlsum.sal2; 

    % Primary sensors 
    btlsum.SA1 = gsw_SA_from_SP(btlsum.SP1,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.CT1 = gsw_CT_from_t(btlsum.SA1,btlsum.t1,btlsum.prs);
    btlsum.pt1 = gsw_pt_from_CT(btlsum.SA1,btlsum.CT1);
    btlsum.O2sol_umolkg1 = gsw_O2sol(btlsum.SA1,btlsum.CT1,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.rho1 = gsw_rho_CT_exact(btlsum.SA1,btlsum.CT1,btlsum.prs); % in situ density
    btlsum.prho1 = gsw_rho_CT_exact(btlsum.SA1,btlsum.CT1,0); % potential density with ref == surf
    btlsum.sigma01 = gsw_sigma0_CT_exact(btlsum.SA1,btlsum.CT1); % btlsum.prho - 1000 = btlsum.sigma0
    btlsum.Winkler1_umolkg1 = btlsum.Winkler1_mLL*1000*44.661./btlsum.prho1; % uses potential density 
    btlsum.Winkler2_umolkg1 = btlsum.Winkler2_mLL*1000*44.661./btlsum.prho1; % uses potential density 

    % Secondary sensors
    btlsum.SA2 = gsw_SA_from_SP(btlsum.SP2,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.CT2 = gsw_CT_from_t(btlsum.SA2,btlsum.t2,btlsum.prs);
    btlsum.pt2 = gsw_pt_from_CT(btlsum.SA2,btlsum.CT2);
    btlsum.O2sol_umolkg2 = gsw_O2sol(btlsum.SA2,btlsum.CT2,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.rho2 = gsw_rho_CT_exact(btlsum.SA2,btlsum.CT2,btlsum.prs); % in situ density
    btlsum.prho2 = gsw_rho_CT_exact(btlsum.SA2,btlsum.CT2,0); % potential density with ref == surf
    btlsum.sigma02 = gsw_sigma0_CT_exact(btlsum.SA2,btlsum.CT2); % btlsum.prho - 1000 = btlsum.sigma0
    btlsum.Winkler1_umolkg2 = btlsum.Winkler1_mLL*1000*44.661./btlsum.prho2; % uses potential density 
    btlsum.Winkler2_umolkg2 = btlsum.Winkler2_mLL*1000*44.661./btlsum.prho2; % uses potential density
    
    % Reorder variables and remove unnecessary ones
    btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2','oxy_volts1','oxy_volts2',...
        'Discrete_Salinity_psu','CTDcal','t1','CT1','pt1','SP1','SA1','rho1','prho1','sigma01',...
        't2','CT2','pt2','SP2','SA2','rho2','prho2','sigma02','Winkler1_mLL','Winkler2_mLL'...
        'Winkler1_umolkg1','Winkler2_umolkg1','Winkler1_umolkg2','Winkler2_umolkg2','O2sol_umolkg1','O2sol_umolkg2'};
    btlsum = btlsum(:,btlvars);
end

%% Reads in bottle data and calibrates CTD oxygen 
function btlsum1 = calibrate_CTD_oxygen1(btlsum1,cal,SOC_type)

x1 = [btlsum1.oxy_volts1,btlsum1.O2sol_umolkg1,btlsum1.t1,btlsum1.prs];

    if SOC_type == 0 % Seabird Factory calibration 
    
        % SBE functional form without SOC drift 
        btlsum1.DOcorr_umolkg1 =cal.cal1.SOC*(x1(:,1) + cal.cal1.VOFFSET).*x1(:,2)...
        .*(1 + cal.cal1.A*x1(:,3) +cal.cal1.B*x1(:,3).^2 + cal.cal1.C*x1(:,3).^3)...
        .*exp((cal.cal1.E*x1(:,4))./(x1(:,3) + 273.15));
        cal1_outliers = [];
    end

    if SOC_type == 1 % Constant SOC value
    
        % SBE functional form without SOC drift 
        btlsum1.DOcorr_umolkg1 = cal.cal1.SOCcalc*(x1(:,1) + cal.cal1.VOFFSET).*x1(:,2)...
        .*(1 + cal.cal1.A*x1(:,3) + cal.cal1.B*x1(:,3).^2 + cal.cal1.C*x1(:,3).^3)...
        .*exp((cal.cal1.Ecalc*x1(:,4))./(x1(:,3) + 273.15));
        cal1_outliers1 = cal.cal1.Winkler1_outliers;
        cal1_outliers2 = cal.cal1.Winkler2_outliers;
    end

    if SOC_type == 2 % SOC varies with cruise time
        dtx = datenum(btlsum1.Date) - datenum(btlsum1.Date(1)); 
        x1 = [x1, dtx];
        
        % SBE functional form with SOC as a function of cruise time
        btlsum1.DOcorr_umolkg1 = ((cal.cal1.SOCrate_dt*x1(:,5)) + cal.cal1.SOCcalc_dt*(x1(:,1) + cal.cal1.VOFFSET)).*x1(:,2)...
            .*(1 + cal.cal1.A*x1(:,3) + cal.cal1.B*x1(:,3).^2 + cal.cal1.C*x1(:,3).^3)...
            .*exp((cal.cal1.Ecalc_dt*x1(:,4))./(x1(:,3) + 273.15));
        cal1_outliers1 = cal.cal1.Winkler1_outliers_dt;
        cal1_outliers2 = cal.cal1.Winkler2_outliers_dt;
    end

    if SOC_type == 3 % SOC varies with cast number 

        x1 = [x1,btlsum1.Cast];
        
        % SBE functional form with SOC as a function of cruise time
        btlsum1.DOcorr_umolkg1 = ((cal.cal1.SOCrate_cn*x1(:,5)) + cal.cal1.SOCcalc_cn*(x1(:,1) + cal.cal1.VOFFSET)).*x1(:,2)...
            .*(1 + cal.cal1.A*x1(:,3) + cal.cal1.B*x1(:,3).^2 + cal.cal1.C*x1(:,3).^3)...
            .*exp((cal.cal1.Ecalc_cn*x1(:,4))./(x1(:,3) + 273.15));
        cal1_outliers1 = cal.cal1.Winkler1_outliers_cn;
        cal1_outliers2 = cal.cal1.Winkler2_outliers_cn;
    end

        btlsum1.SOC_type1 = ones(height(btlsum1.prs),1)*SOC_type; 

        btlsum1.cal1_NLMR_Outlier1 = zeros(height(btlsum1.prs),1);
        btlsum1.cal1_NLMR_Outlier1(cal1_outliers1) = 1;
        
        btlsum1.cal1_NLMR_Outlier2 = zeros(height(btlsum1.prs),1);
        btlsum1.cal1_NLMR_Outlier2(cal1_outliers2) = 1;

end

%% Reads in bottle data and calibrates CTD oxygen 
function btlsum2 = calibrate_CTD_oxygen2(btlsum2,cal,SOC_type)

x2 = [btlsum2.oxy_volts2,btlsum2.O2sol_umolkg2,btlsum2.t2,btlsum2.prs];

% Secondary sensor 
    if SOC_type == 0 % Seabird Factory calibration 
    
        % SBE functional form without SOC drift 
        btlsum2.DOcorr_umolkg2 = cal.cal2.SOC*(x2(:,1) + cal.cal2.VOFFSET).*x2(:,2)...
        .*(1 + cal.cal2.A*x2(:,3) + cal.cal2.B*x2(:,3).^2 + cal.cal2.C*x2(:,3).^3)...
        .*exp((cal.cal2.E*x2(:,4))./(x2(:,3) + 273.15));
        cal2_outliers = [];
    end

    if SOC_type == 1 % Constant SOC value
    
        % SBE functional form without SOC drift 
        btlsum2.DOcorr_umolkg2 = cal.cal2.SOCcalc*(x2(:,1) + cal.cal2.VOFFSET).*x2(:,2)...
        .*(1 + cal.cal2.A*x2(:,3) + cal.cal2.B*x2(:,3).^2 + cal.cal2.C*x2(:,3).^3)...
        .*exp((cal.cal2.Ecalc*x2(:,4))./(x2(:,3) + 273.15));
        cal2_outliers1 = cal.cal2.Winkler1_outliers;
        cal2_outliers2 = cal.cal2.Winkler2_outliers;
    end

    if SOC_type == 2 % SOC varies with cruise time
        dtx = datenum(btlsum2.Date) - datenum(btlsum2.Date(1)); 
        x2 = [x2, dtx];
        
        % SBE functional form with SOC as a function of cruise time
        btlsum2.DOcorr_umolkg2 = ((cal.cal2.SOCrate_dt*x2(:,5)) + cal.cal2.SOCcalc_dt*(x2(:,1) + cal.cal2.VOFFSET)).*x2(:,2)...
            .*(1 + cal.cal2.A*x2(:,3) + cal.cal2.B*x2(:,3).^2 + cal.cal2.C*x2(:,3).^3)...
            .*exp((cal.cal2.Ecalc_dt*x2(:,4))./(x2(:,3) + 273.15));
        cal2_outliers1 = cal.cal2.Winkler1_outliers_dt;
        cal2_outliers2 = cal.cal2.Winkler2_outliers_dt;
    end

    if SOC_type == 3 % SOC varies with cast number 

        x2 = [x2,btlsum2.Cast];
        
        % SBE functional form with SOC as a function of cruise time
        btlsum2.DOcorr_umolkg2 = ((cal.cal2.SOCrate_cn*x2(:,5)) + cal.cal2.SOCcalc_cn*(x2(:,1) + cal.cal2.VOFFSET)).*x2(:,2)...
            .*(1 + cal.cal2.A*x2(:,3) + cal.cal2.B*x2(:,3).^2 + cal.cal2.C*x2(:,3).^3)...
            .*exp((cal.cal2.Ecalc_cn*x2(:,4))./(x2(:,3) + 273.15));
        cal2_outliers1 = cal.cal2.Winkler1_outliers_cn;
        cal2_outliers2 = cal.cal2.Winkler2_outliers_cn;
    end
        btlsum2.SOC_type2 = ones(height(btlsum2.prs),1)*SOC_type; 

        btlsum2.cal2_NLMR_Outlier1 = zeros(height(btlsum2.prs),1);
        btlsum2.cal2_NLMR_Outlier1(cal2_outliers1) = 1;
        
        btlsum2.cal2_NLMR_Outlier2 = zeros(height(btlsum2.prs),1);
        btlsum2.cal2_NLMR_Outlier2(cal2_outliers2) = 1;
end

function btlsum = combine_after_sensor_cals(btlsum1,btlsum2)

    btlsum = join(btlsum1,btlsum2,'Keys',{'Cast','Bottle'},'KeepOneCopy',{'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2','oxy_volts1','oxy_volts2',...
        'Discrete_Salinity_psu','CTDcal','t1','CT1','pt1','SP1','SA1','rho1','prho1','sigma01',...
        't2','CT2','pt2','SP2','SA2','rho2','prho2','sigma02','Winkler1_mLL','Winkler2_mLL'...
        'Winkler1_umolkg1','Winkler2_umolkg1','Winkler1_umolkg2','Winkler2_umolkg2','O2sol_umolkg1','O2sol_umolkg2'});
    % Reorder variables and remove unnecessary ones
    btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2','oxy_volts1','oxy_volts2',...
        'Discrete_Salinity_psu','CTDcal','t1','CT1','pt1','SP1','SA1','rho1','prho1','sigma01',...
        't2','CT2','pt2','SP2','SA2','rho2','prho2','sigma02','Winkler1_mLL','Winkler2_mLL'...
        'Winkler1_umolkg1','Winkler2_umolkg1','Winkler1_umolkg2','Winkler2_umolkg2','O2sol_umolkg1','O2sol_umolkg2',...
        'SOC_type1','SOC_type2','cal1_NLMR_Outlier1','cal1_NLMR_Outlier2','cal2_NLMR_Outlier1','cal2_NLMR_Outlier2','DOcorr_umolkg1','DOcorr_umolkg2'};

   btlsum = btlsum(:,btlvars);
end
