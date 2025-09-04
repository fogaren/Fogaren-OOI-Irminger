% Set up workspace 
clearvars; close all
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
addpath('G:\My Drive\Matlab_work\BC')
addpath(genpath('G:\My Drive\Matlab_work\Github\GSW-Matlab'))
run('GeneralSettings.m') % For colors

% Read in salinity calibrated bottle files, Winkler sample values and oxygen files
% processed with SBE default hysteresis correction and no tau correction 
btl_dir = 'C:\Users\fogaren\Desktop\Irminger12\ctd\btl'; % my processed bottle product 
samp_dir = 'C:\Users\fogaren\Desktop\Irminger12\ctd\cnv'; % processed SBE cnvs
Winkler_dir = 'C:\Users\fogaren\Desktop\Irminger12\ctd';
Winkler_file = 'RR2505_Winklers_KF.xlsx';

filesave = 0; % filesave == 1, save calibration output as mat file

% Use Bottle samples to calculate new SOC (gain) and E terms for CTD data
% Determined during CTD salinity calibration 
CTD_sen = 1; % Use primary or secondary CTD temp and sal

%% Create bottle summary indexed by cast number and table with all data 
cd(btl_dir)
mybtlfiles = ls('*.btl'); % List of my processed bottle files 
btlcasts = str2num(mybtlfiles(:,8:10)); % Pulls out cast numbers that have bottle files 

SBEbtlfiles = []; % Read in all SBE bottle files 
for j = 1:length(btlcasts)
    SBEbtlfiles{btlcasts(j)} = readSBSbtl(mybtlfiles(j,:));
    SBEbtlfiles{btlcasts(j)}.Cast(:) = btlcasts(j);
end

SBEbtlsum_tbl = []; % Combine all SBE bottle files into one table 
for j = 1:length(btlcasts)
    SBEbtlsum_tbl = [SBEbtlsum_tbl; SBEbtlfiles{btlcasts(j)}];
end
% %%
% BTL = read_btl_time(filename)
%% Read in Winkler values, SBE bottle files and combine them
cd(Winkler_dir)
Winklers = readtable(Winkler_file,'TextType','string');
Winklers.Winkler1_mLL = double(Winklers.Winkler1_mLL);
Winklers.Winkler2_mLL = double(Winklers.Winkler2_mLL);
Wink_casts = unique(Winklers.Cast); % Casts with Winklers
CTDcal = 0; 

btlsum_tbl = combine_btl_files(Winklers,SBEbtlsum_tbl,CTD_sen,CTDcal);

%% *** same sensor for all casts ***
% From SBE factory calibration 
% Serial number 3521, 13-Feb-25
cal.SOC = 5.26680e-001;
cal.VOFFSET = -4.81700e-001;
cal.A = -2.87230e-003;
cal.B = 1.28360e-004; 
cal.C = -2.27210e-006;
cal.E = 3.60000e-002;
cal.Tau20 = 1.38000e+000;
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '3521';
cal.OCALDATE = '13-Feb-25';

H = [-0.033, 5000, 1450]; % Default 

%% Look at Winklers versus CTD-DO from factory calibration 

% Calculate oxygen concentration with SBE factory calibration 
x = [[btlsum_tbl.oxy_volts; btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg; btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t; btlsum_tbl.t],...
    [btlsum_tbl.prs; btlsum_tbl.prs]];
DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
  .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
  .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));

f = figure;
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, btlsum_tbl.Winkler1_umolkg - DOuncorr_umolkg(1:height(btlsum_tbl)),'.k','Markersize',20); hold on;
plot(btlsum_tbl.prs, btlsum_tbl.Winkler2_umolkg - DOuncorr_umolkg(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
ylim([5 25])
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, btlsum_tbl.Winkler1_umolkg - DOuncorr_umolkg(1:height(btlsum_tbl)),'.k','Markersize',20); hold on;
plot(btlsum_tbl.Cast, btlsum_tbl.Winkler2_umolkg - DOuncorr_umolkg(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
ylim([5 25])
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, btlsum_tbl.Winkler1_umolkg - DOuncorr_umolkg(1:height(btlsum_tbl)),'.k','Markersize',20); hold on;
plot(btlsum_tbl.t, btlsum_tbl.Winkler2_umolkg - DOuncorr_umolkg(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
ylim([5 25])
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg, btlsum_tbl.Winkler1_umolkg - DOuncorr_umolkg(1:height(btlsum_tbl)),'.k','Markersize',20); hold on;
plot(btlsum_tbl.Winkler2_umolkg, btlsum_tbl.Winkler2_umolkg - DOuncorr_umolkg(height(btlsum_tbl)+1:(height(btlsum_tbl)*2)),'.k','Markersize',20)
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
ylim([5 25])
grid on
sgtitle('RR2505: Factory Calibrated CTD-DO vs Winklers')

%% non linear multiple regression using SBE functional form 

% Oxygen solubility calculated using GSW Toolbox 
% Treats Winkler replicates as individual points (no averaging of Winklers)
% OOI Cruise no replicates 
 
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

beta0 = [cal.SOC 0]; % Starting values for coefficient iterations 

% Non linear multiple regression to get b1 (SOC) and b2 (E term) from SBE
% functional form using all Winklers_umolkg (from calibrated T/S data) 
% Run non linear model fit with all Winkler/CTD oxygen (volts) values
% Repeat until all outliers are removed 

% Find outliers based on median filter it = 1 
mdl1 = fitnlm(X,Winklers_to_use,modelfun,beta0);

figure
histfit(mdl1.Residuals.Raw)
title('SOC_k Residuals with Outliers Removed, it = 1')
ylabel('Frequency')
xlabel('DO Residuals, Winklers - NLMR output (\mumol/kg)')

% Find outliers based on median filter it = 2 
Winkler_outliers1 = find(isoutlier(mdl1.Residuals.Raw,'median') == 1);
% Exclude outliers from NLMR model 
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
mdl7 = fitnlm(X,Winklers_to_use,modelfun,beta0,'Exclude',Winkler_outliers6);

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


% cal.casts = 1:214; % *** CHANGE THIS *** 
cal.mdl = mdl7;
% To identify outliers 
cal.out_NLMR = sortrows([bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)/44.661/1000.*pdens(Winkler_outliers6)],[1 2])
cal_all = cal;
clear cal; 
%% Plot of residuals with updates Calibration Coefficients
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
sgtitle('RR2505: SOC_k fit, whole cruise as one Group')
%
%%
SOC_type = 1;
btlsum_tbl = calibrate_CTD_oxygen(btlsum_tbl,cal_all,SOC_type)

%%
function btlsum = combine_btl_files(Winkler_file,my_btl_file,CTD_sen,CTDcal)

    btlsum = join(Winkler_file,my_btl_file,'Keys',{'Cast','Bottle'});

    % btlsum_tbl.Properties.VariableNames = {'Cruise','Cast','Bottle','Winkler_mLL','Bottle2','Date','Scan','TimeS','PrDM','depth','T090C','T190C','C0mS_cm','C1mS_cm','oxy_volts','pH','lat','lon','oxy_volts','Cast2'};
 
    % Decide if using primary or secondary CTD sensor for temp and sal
    if CTD_sen == 1 % primary sensor (use unless something wrong with data)
        btlsum.t = btlsum.T090C; 
        btlsum.cond = btlsum.C0mS_cm; % Only one calibrated salinity value 
    end
    
    if CTD_sen == 2 % secondary sensor (use if primary sensor bad)
        btlsum.t = btlsum.T190C; 
        btlsum.cond = btlsum.C1mS_cm; % Only one calibrated salinity value
    end    

    btlsum.oxy_volts = btlsum.Sbeox0V;
    btlsum.prs = btlsum.PrDM;
    btlsum.CTD_sen = ones(length(btlsum.prs),1)*CTD_sen; 
    btlsum.SP = gsw_SP_from_C(btlsum.cond,btlsum.t,btlsum.prs);
    btlsum.SA = gsw_SA_from_SP(btlsum.SP,btlsum.prs,btlsum.Longitude,btlsum.Latitude);
    btlsum.CT = gsw_CT_from_t(btlsum.SA,btlsum.t,btlsum.prs);
    btlsum.pt = gsw_pt_from_CT(btlsum.SA,btlsum.CT);
    btlsum.O2sol_umolkg = gsw_O2sol(btlsum.SA,btlsum.CT,btlsum.prs,btlsum.Longitude,btlsum.Latitude);
    btlsum.rho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,btlsum.prs); % in situ density
    btlsum.prho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,0); % potential density with ref == surf
    btlsum.sigma0 = gsw_sigma0_CT_exact(btlsum.SA,btlsum.CT); % btlsum.prho - 1000 = btlsum.sigma0
    btlsum.Winkler1_umolkg = btlsum.Winkler1_mLL*1000*44.661./btlsum.prho; % Winkler conc, uses pot. density 
    btlsum.Winkler2_umolkg = btlsum.Winkler2_mLL*1000*44.661./btlsum.prho; % Winkler conc, uses pot. density
    btlsum.CTDcal(:) = CTDcal; % 1 for calibrated, 0 for uncalibrated 

    btlvars = {'Cruise','Date','Cast','Bottle','prs','Latitude','Longitude','CTDcal','CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','O2sol_umolkg',...
        'Winkler1_mLL','Winkler2_mLL','Winkler1_umolkg','Winkler2_umolkg'};
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
        btlsum.NLMR_Outlier1(isnan(btlsum.Winkler1_umolkg)) = 9; % QC flag for missing data 

        btlsum.NLMR_Outlier2 = ones(size(btlsum.prs))*2; % Sets all Winklers to 2 (acceptable)
        btlsum.NLMR_Outlier2(cal.Winkler2_outliers) = 3; % Questionable from NLMR
        btlsum.NLMR_Outlier2(isnan(btlsum.Winkler2_umolkg)) = 9; % QC flag for missing data 

        btlvars = {'Cruise','Date','Cast','Bottle','prs','Latitude','Longitude','CTDcal','CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','O2sol_umolkg','Winkler1_mLL','Winkler2_mLL',...
            'Winkler1_umolkg','Winkler2_umolkg','SOC_type','NLMR_Outlier1','NLMR_Outlier2','DOcorr_umolkg'};
        btlsum = btlsum(:,btlvars);
end