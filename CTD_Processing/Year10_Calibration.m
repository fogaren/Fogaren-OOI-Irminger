% Set up workspace 
clearvars; close all; clc
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
addpath(genpath('G:\My Drive\Matlab_work\Github\GSW-Matlab'))
%%
% Read in calibrated bottle files, Winkler sample values and oxygen files
% processed with default hysteresis correction and user-determined time lag
% correction 

btl_dir = 'C:\Users\fogaren\Desktop\AR76-03\ctd\raw'; %  
dir = btl_dir; % Casts to match bottle files 
dc_dir = strcat(btl_dir,'\downcasts');
uc_dir = strcat(btl_dir,'\upcasts');

samp_dir = 'C:\Users\fogaren\Desktop\AR76-03'; % Winkler file location 
Winkler_file = 'Irminger_Sea-10_AR76-03_Discrete_Summary_KF.xlsx'; % Winkler file name 
filesave = 0; % filesave == 1, save calibration output as mat file

% Use Bottle samples to calculate new SOC (gain) and E terms for CTD data 
CTD_sen = 1; % Use primary or secondary CTD temp and sal

ns = 10; % Start of cast numbers in file name
ne = 12; % End of cast numbers in file name 

savefile = 0; % savefile == 1 for saving; savefile == 0, don't save 

%%
% cd('C:\Users\fogaren\Desktop\AR76-03\ctd')
% load DefaultH.mat
% 
% downcastsH = downcasts;
% upcastsH = upcasts;
% 
% clear btlsum btlsum_tbl cal downcasts upcasts

%% Create bottle summary indexed by cast number and table with all data 
cd(btl_dir)
mybtlfiles = ls('*.btl'); % List of my processed bottle files 
btlcasts = str2num(mybtlfiles(:,9:11)); % Pulls out cast numbers that have bottle files 

SBEbtlfiles = []; % Read in all SBE bottle files 
for j = 1:length(btlcasts)
    SBEbtlfiles{btlcasts(j)} = readin_SBE_btl(mybtlfiles(j,:));
    SBEbtlfiles{btlcasts(j)}.Cast(:) = btlcasts(j);
end

SBEbtlsum_tbl = []; % Combine all SBE bottle files into one table 
for j = 1:length(btlcasts)
    SBEbtlsum_tbl = [SBEbtlsum_tbl; SBEbtlfiles{btlcasts(j)}];
end

%% Read in Winkler file 
cd(samp_dir)
Winklers = readtable(Winkler_file,'TextType','string');
Winklers.Cast = double(Winklers.Cast);
Winklers.Bottle = double(Winklers.Bottle);
Winklers.Winkler_mLL = double(Winklers.Winkler_mLL);

%% Calibration without final calibrated salinity data 

btlsum = []; % Indexes by cast number leah_btl{5} == cast 5; 
% Combine files and calculate sea water properties for CTD sensor number 
for j = 1:height(btlcasts) % Number of bottle summary files 
    btlsum{btlcasts(j)} = combine_btl_files(SBEbtlfiles{j},Winklers(Winklers.Cast == btlcasts(j),:),CTD_sen) ;
end
%%
% Pull all bottle files and create one large table 
btlsum_tbl = [];
for j = 1:length(btlsum)
    btlsum_tbl = [btlsum_tbl; btlsum{j}];
end
btl_num = unique(btlsum_tbl.Cast);
% %%
%%
% Same Oxygen Sensor for whole cruise 
% Calibration standards from SBE xmlcon file 

cal.SOC = double(4.5906e-001);
cal.VOFFSET = double(-0.5026);
cal.A = double(-4.8449e-003);
cal.B = double(2.6126e-004);
cal.C = double(-3.8500e-006);
cal.E = double(3.60000e-002);
cal.Tau20 = double(1.5600);
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '1960';
cal.OCALDATE = '30-Apr-22'; 

H = [-0.033, 5000, 1450]; % Default 

%% non linear multiple regression 
% Oxygen solubility calculated using GSW Toolbox 
% Model variables 
% Treats Winklers as individual points 
X = [[btlsum_tbl.oxy_volts],...
    [btlsum_tbl.O2sol_umolkg],...
    [btlsum_tbl.t],...
    [btlsum_tbl.prs]];
bad_casts = [btlsum_tbl.Cast];
btl_check = [btlsum_tbl.Bottle];


Winklers_to_use = btlsum_tbl.Winkler_umolkg;
Winklers_to_use(btlsum_tbl.prs < 500) = NaN;
pdens = [btlsum_tbl.prho];

% SBE functional form 
modelfun = @(b,x)(b(1)*(x(:,1) + cal.VOFFSET)).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((b(2)*x(:,4))./(x(:,3) + 273.15));

% SBE DO with factory calibration  
btlsum_tbl.CTDuncal_umolkg = (cal.SOC*(X(:,1) + cal.VOFFSET)).*X(:,2)...
    .*(1 + cal.A*X(:,3) + cal.B*X(:,3).^2 + cal.C*X(:,3).^3)...
    .*exp((cal.E*X(:,4))./(X(:,3) + 273.15));

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
cal.Winkler_outliers = Winkler_outliers6(Winkler_outliers6 < height(btlsum_tbl));

out_NLMR = sortrows([bad_casts(Winkler_outliers6) btl_check(Winkler_outliers6) Winklers_to_use(Winkler_outliers6)/44.661/1000.*pdens(Winkler_outliers6)],[1 2])
%%
f = figure;
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler_umolkg, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.k','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('Year 10 AR76-03: SOC_k')

%% Decided on SOC calibration 
SOC_type = 1;
btlsum_tbl = calibrate_CTD_oxygen(btlsum_tbl,cal,SOC_type);

%%
% For output structure
btlsum = []; % Indexes by cast number leah_btl{5} == cast 5; 
% Combine files and calculate sea water properties for CTD sensor number 
for i = 1:height(btlcasts) % Number of bottle summary files 
    btlsum{btlcasts(i)} = btlsum_tbl(btlsum_tbl.Cast == btlcasts(i),:);
end


%% Read in my processed casts 

% Downcasts 
cd(dc_dir)
files = ls('*.cnv');
cast_num = str2num(files(:,ns:ne)); % Pulls out cast numbers 

mydowncast = []; % Read all my processed SBE cast into matlab 
for i = 1:length(cast_num)
    dcnv_in = readSBScnv(files(i,:));
    mydowncast{cast_num(i)} = my_cast(dcnv_in); %change so that i references cast number not file length number 
    mydowncast{cast_num(i)}.Station(:) = cast_num(i);
end

% Upcasts 
cd(uc_dir)
files = ls('*.cnv');

myupcast = []; % Read all my processed SBE cast into matlab 
for i = 1:length(cast_num)
    ucnv_in = readSBScnv(files(i,:));
    myupcast{cast_num(i)} = my_cast(ucnv_in);
    myupcast{cast_num(i)}.Station(:) = cast_num(i);
end

%% Combine and calibrate DO for Casts Read in bottle data and making DO calibration choice 

CTD_sen = btlsum_tbl.CTD_sen(1); % Sensor package to use for calibration; same as bottle processing 
SOC_type = 1; % 1 = constant, % 2 = changes as a function of cruise time % 3 = changes as a function of station number 

% btlsum_tbl = calibrate_CTD_oxygen(btlsum_tbl,cal,SOC_type);

CruiseStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 
%% 
btlsum = []; 
downcasts = []; upcasts = []; 
for i = 1:length(cast_num)
        btlsum{cast_num(i)} = btlsum_tbl(btlsum_tbl.Cast == cast_num(i),:); 
        downcasts{cast_num(i)} = process_cast(mydowncast{cast_num(i)}, CTD_sen, cal, SOC_type, CruiseStartTime);
        upcasts{cast_num(i)} = process_cast(myupcast{cast_num(i)}, CTD_sen, cal, SOC_type, CruiseStartTime);
end

%% Plot final data
close all
for i = 1:length(cast_num)
    plot_calibrated_DO(downcasts{cast_num(i)},upcasts{cast_num(i)},btlsum{cast_num(i)})
end

%%

for j = 1:length(cast_num)
    figure(j)
    subplot(1,2,2)
    hold on
    plot(downcastsH{j}.DOcorr_umolkg,downcastsH{j}.prs,'Linewidth',1.2)
    plot(upcastsH{j}.DOcorr_umolkg,upcastsH{j}.prs,'Linewidth',1.2,'Color','k')
end
%%
castDOdiff = [];
for j = 1:length(cast_num)
    for k = 100:2:3000
        try
        castDOdiff(j,k) = downcasts{cast_num(j)}.DOcorr_umolkg(downcasts{cast_num(j)}.prs == k) - upcasts{cast_num(j)}.DOcorr_umolkg(upcasts{cast_num(j)}.prs == k);
        end
    end
end
figure

%%
bad_casts = [NaN; % bad downcasts  
    NaN]'; % bad upcasts 
plot_calibrated_pTemp(downcasts,upcasts,cast_num,btlsum_tbl,cal,bad_casts,'Year 9: AR69-01')

%% Change flags to Best Practices Flags
btlsum_tbl.NLMR_Outlier1(btlsum_tbl.NLMR_Outlier1 == 1) = 3;
btlsum_tbl.NLMR_Outlier1(btlsum_tbl.NLMR_Outlier1 == 0) = 2;
btlsum_tbl.NLMR_Outlier1(isnan(btlsum_tbl.Winkler1_umolkg)) = 9;

btlsum_tbl.NLMR_Outlier2(btlsum_tbl.NLMR_Outlier2 == 1) = 3;
btlsum_tbl.NLMR_Outlier2(btlsum_tbl.NLMR_Outlier2 == 0) = 2;
btlsum_tbl.NLMR_Outlier2(isnan(btlsum_tbl.Winkler2_umolkg)) = 9;

btlsum_tbl.NLMR_Outlier3(btlsum_tbl.NLMR_Outlier3 == 1) = 3;
btlsum_tbl.NLMR_Outlier3(btlsum_tbl.NLMR_Outlier3 == 0) = 2;
btlsum_tbl.NLMR_Outlier3(isnan(btlsum_tbl.Winkler3_umolkg)) = 9;

btlsum = [];
for i = 1:length(cast_num)
        btlsum{cast_num(i)} = btlsum_tbl(btlsum_tbl.Cast == cast_num(i),:); 
end

%% Save processed data 
if savefile == 1

    btlsum_yr9 = btlsum;
    btlsum_tbl_yr9 = btlsum_tbl; 
    upcasts_yr9 = upcasts;
    downcasts_yr9 = downcasts;
    btl_num_yr9 = btl_num;
    cast_num_yr9 = cast_num;
    cal_yr9 = cal; 
    dt_Processed_yr9 = datetime('now');
    clear btlsum_tbl
    cd(dir)
    cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Processed')
    save Year9_Processed_KF.mat upcasts_* downcasts_* btl_num_* cast_num_* cal_* btlsum_* dt_Processed_*
end

%%
function btlsum = combine_btl_files(my_btl_file,Winkler_table,CTD_sen)
    btlsum = Winkler_table; % Winklers for just the cast 
    btlsum.Properties.VariableNames = {'Cruise','Cast','Bottle','Winkler_mLL'};
    
    % Format structure for conversion to table and convert to table 
    % btl = readtable(my_btl_file,'TextType','string');
    btl = my_btl_file;
    vars = {'Bottle','Date','PrDM','DepSM','Latitude','Longitude','T090C','T190C','C0mScm','C1mScm','Sbeox0V'};
    btl = btl(:,vars);
    btl.Properties.VariableNames = {'Bottle','Date','PrDM','depth','lat','lon','temp1','temp2','cond1','cond2','oxy_volts'};
    btl.CTDcal(:) = {'True'};
    btl.CTDcal = string(btl.CTDcal);
    
    % Combine tables by Bottle variable 
    btlsum = join(btlsum,btl,'Keys','Bottle');
 
    % Decide if using primary or secondary CTD sensor for temp and sal
    if CTD_sen == 1 % primary sensor (use unless something wrong with data)
        btlsum.t = btlsum.temp1; 
        btlsum.cond = btlsum.cond1; 
     end
    
    if CTD_sen == 2 % secondary sensor (use if primary sensor bad)
        btlsum.t = btlsum.temp2; 
        btlsum.cond = btlsum.cond2; 
    end    
    
    btlsum.prs = btlsum.PrDM;
    btlsum.CTD_sen = ones(length(btlsum.prs),1)*CTD_sen; 
    btlsum.SP = gsw_SP_from_C(btlsum.cond,btlsum.t,btlsum.prs);
    btlsum.SA = gsw_SA_from_SP(btlsum.SP,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.CT = gsw_CT_from_t(btlsum.SA,btlsum.t,btlsum.prs);
    btlsum.pt = gsw_pt_from_CT(btlsum.SA,btlsum.CT);
    btlsum.O2sol_umolkg = gsw_O2sol(btlsum.SA,btlsum.CT,btlsum.prs,btlsum.lon,btlsum.lat);
    btlsum.rho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,btlsum.prs); % in situ density
    btlsum.prho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,0); % potential density with ref == surf
    btlsum.sigma0 = gsw_sigma0_CT_exact(btlsum.SA,btlsum.CT); % btlsum.prho - 1000 = btlsum.sigma0
    btlsum.Winkler_umolkg = btlsum.Winkler_mLL*1000*44.661./btlsum.prho; % Winklers 1 
   
     % Reorder variables and remove unnecessary ones
    btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','cond1','cond2','CTDcal',...
    'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','Winkler_mLL','Winkler_umolkg','O2sol_umolkg'};
    btlsum = btlsum(:,btlvars);
end

% %% Reads in bottle data and calibrates CTD oxygen 
% function btlsum = calibrate_CTD_oxygen(btlsum,cal,SOC_type)
% 
% x = [btlsum.oxy_volts,btlsum.O2sol_umolkg,btlsum.t,btlsum.prs];
% 
%     if SOC_type == 0 % Seabird Factory calibration 
% 
%         % SBE functional form without SOC drift 
%         btlsum.DOcorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
%         .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%         .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));
%         outliers = [];
%     end
% 
%     if SOC_type == 1 % Constant SOC value
% 
%         % SBE functional form without SOC drift 
%         btlsum.DOcorr_umolkg = cal.SOCcalc*(x(:,1) + cal.VOFFSET).*x(:,2)...
%         .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%         .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));
%         outliers = cal.Winkler_outliers;
% 
%     end
% 
%     if SOC_type == 2 % SOC varies with cruise time
%         dtx = datenum(btlsum.Date) - datenum(btlsum.Date(1)); 
%         x = [x, dtx];
% 
%         % SBE functional form with SOC as a function of cruise time
%         btlsum.DOcorr_umolkg = ((cal.SOCrate_dt*x(:,5)) + cal.SOCcalc_dt*(x(:,1) + cal.VOFFSET)).*x(:,2)...
%             .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%             .*exp((cal.Ecalc_dt*x(:,4))./(x(:,3) + 273.15));
%         outliers = cal.Winkler_outliers_dt;
% 
%     end
% 
%     if SOC_type == 3 % SOC varies with cast number 
% 
%         x = [x,btlsum.Cast];
% 
%         % SBE functional form with SOC as a function of cruise time
%         btlsum.DOcorr_umolkg = ((cal.SOCrate_cn*x(:,5)) + cal.SOCcalc_cn*(x(:,1) + cal.VOFFSET)).*x(:,2)...
%             .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%             .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15));
%         outliers = cal.Winkler_outliers_cn;
% 
%     end
% 
%         btlsum.SOC_type = ones(length(btlsum.prs),1)*SOC_type; 
% 
%         btlsum.NLMR_Outlier = zeros(length(btlsum.prs),1);
%         btlsum.NLMR_Outlier(outliers) = 1;
% 
% 
%             % Reorder variables and remove unnecessary ones
%         btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','cond1','cond2',...
%             'CTDcal','CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','O2sol_umolkg','Winkler_mLL',...
%             'Winkler_umolkg','SOC_type','NLMR_Outlier','DOcorr_umolkg'};
%         btlsum = btlsum(:,btlvars);
% end
%%
function btlsum = readin_SBE_btl(filename)

    % Read and combine (avg) and (sdev) rows from a Sea-Bird .btl file
    % Author: ChatGPT (GPT-5)
    % Date: 2025-11-11
    raw = readlines(filename);
    
    % --- 1. Find where data starts ---
    headerIdx = find(contains(raw, 'Bottle'), 1);
    if isempty(headerIdx)
        error('No "Bottle" header line found in file.');
    end
    
    % Extract header line and clean it up
    headerLine = strtrim(raw(headerIdx));
    headers = strsplit(regexprep(headerLine, '\s+', ' '));
    
    % --- 2. Identify avg and sdev rows ---
    dataLines = raw(headerIdx+1:end);
    isAvg = contains(dataLines, '(avg)');
    isSdev = contains(dataLines, '(sdev)');
    
    avgLines0 = strtrim(dataLines(isAvg));
    avgLines = erase(avgLines0,'(avg)');
    sdevLines0 = strtrim(dataLines(isSdev));
    sdevLines = erase(sdevLines0,'(sdev)');

    splitData = cellfun(@(x) strsplit(strtrim(x)), cellstr(avgLines), 'UniformOutput', false);
    C = vertcat(splitData{:});
    dateStrings = string(strcat((C(:,2)), {' '}, (C(:,3)), {' '}, (C(:,4))));
    [~,m] = size(C);
    T_avg = table;
    for j = 1:m
        T_avg(:,j) = table(double(string(C(:,j))));
    end
    T_avg = removevars(T_avg,{'Var2','Var3','Var4'});
    Date = datetime(dateStrings, 'InputFormat', 'MMM dd yyyy');
    T_avg.Date = Date;
    T_avg = movevars(T_avg, 'Date', 'Before', 'Var5');
    headers = erase(headers,'/'); 
    T_avg.Properties.VariableNames = headers;

    splitDatasdev = cellfun(@(x) strsplit(strtrim(x)), cellstr(sdevLines), 'UniformOutput', false);
    C = vertcat(splitDatasdev{:});
    DateTime = datetime(strcat(dateStrings,' ', string(C(:,1))),'InputFormat','MMM dd yyyyHH:mm:ss');

    T_avg.Date = DateTime; 
    btlsum = T_avg;

end

%% Reads in bottle data and calibrates CTD oxygen 
function btlsum = calibrate_CTD_oxygen(btlsum,cal,SOC_type)

x = [btlsum.oxy_volts,btlsum.O2sol_umolkg,btlsum.t,btlsum.prs];

    if SOC_type == 1 % Constant SOC value
    
        % SBE functional form without SOC drift 
        btlsum.DOcorr_umolkg = cal.SOCcalc*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));
        outliers = cal.Winkler_outliers;
    end

    if SOC_type == 2 % SOC varies with cruise time
        dtx = datenum(btlsum.Date) - datenum(btlsum.Date(1)); 
        x = [x, dtx];
        
        % SBE functional form with SOC as a function of cruise time
        btlsum.DOcorr_umolkg = ((cal.SOCrate_dt*x(:,5)) + cal.SOCcalc_dt*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_dt*x(:,4))./(x(:,3) + 273.15));
        outliers = cal.Winkler_outliers_dt;
    end

    if SOC_type == 3 % SOC varies with cast number 

        x = [x,btlsum.Cast];
        
        % SBE functional form with SOC as a function of cruise time
        btlsum.DOcorr_umolkg = ((cal.SOCrate_cn*x(:,5)) + cal.SOCcalc_cn*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15));
        outliers = cal.Winkler_outliers_cn;
    end

        btlsum.SOC_type = ones(length(btlsum.prs),1)*SOC_type; 

        btlsum.NLMR_Outlier = zeros(length(btlsum.prs),1);
        btlsum.NLMR_Outlier(outliers) = 1;

            % Reorder variables and remove unnecessary ones
        btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','cond1','cond2',...
            'CTDcal','CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','Winkler_mLL',...
            'Winkler_umolkg','O2sol_umolkg','SOC_type','DOcorr_umolkg','NLMR_Outlier'};
        btlsum = btlsum(:,btlvars);
end


%% Reads in my processed casts 
function cast = my_cast(cast)
    cast0 = cast;
    fields = {'source','DataFileType','instrumentheaders','userheaders','vars','longname','units','span','mvars','mvars_format'...
        'scan','nbin','flag','SeasaveVersion','softwareheaders'};
    cast = rmfield(cast,fields);
    cast = struct2table(cast);
    cast.Properties.VariableNames = {'CastTimeS','prs','depth','temp1','temp2','cond1','cond2','oxy_volts','lat','lon'};
    cast.oxy_volts(cast.oxy_volts == -9.9900e-29) = NaN; % replaces no data flag with NaN
    cast.StartTimeUTC = ones(length(cast.CastTimeS),1)*datenum(cast0.instrumentheaders.SystemUTC); 
    cast.StartTimeUTC = datetime(cast.StartTimeUTC,'ConvertFrom','datenum');
    cast.CastTimeUTC = cast.StartTimeUTC + cast.CastTimeS/3600/24;
    cast.CTDcal(:) = {'False'};
    cast.CTDcal = string(cast.CTDcal);
end


%% Combines Files and calibrate oxygen data

function cast = process_cast(mycast,CTD_sen,cal,SOC_type,CruiseStartTime)
%     
%     % Combine tables by prs variable 
%     if height(mycast) <= height(leah_cast)
%         cast = join(mycast,leah_cast,'Keys','prs');
%     else 
%         cast = join(leah_cast,mycast,'Keys','prs');
%     end
    cast = mycast; 

    % Decide if using primary or secondary CTD sensor for temp and sal
    if CTD_sen == 1 % primary sensor (use unless something wrong with data)
        cast.t = cast.temp1; 
        cast.cond = cast.cond1;
     end
    
    if CTD_sen == 2 % secondary sensor (use if primary sensor bad)
        cast.t = cast.temp2; 
        cast.cond = cond2; 
    end   

    % Calculate other parameters of interest for downcast 
    cast.SP = gsw_SP_from_C(cast.cond,cast.t,cast.prs);
    cast.SA = gsw_SA_from_SP(cast.SP,cast.prs,cast.lon,cast.lat);
    cast.CT = gsw_CT_from_t(cast.SA,cast.t,cast.prs);
    cast.pt = gsw_pt_from_CT(cast.SA,cast.CT);  
    cast.O2sol_umolkg = gsw_O2sol(cast.SA,cast.CT,cast.prs,cast.lon,cast.lat);
    cast.rho = gsw_rho_CT_exact(cast.SA,cast.CT,cast.prs); % in situ density
    cast.prho = gsw_rho_CT_exact(cast.SA,cast.CT,0); % potential density with ref == surf
    cast.sigma0 = gsw_sigma0_CT_exact(cast.SA,cast.CT); % cast.prho - 1000 = cast.sigma0 
    cast.CTD_sen = ones(length(cast.prs),1)*CTD_sen; 
    cast.cruise_d = datenum(cast.StartTimeUTC) - datenum(CruiseStartTime); % Cruise time in days 
    
    if SOC_type == 0 % Seabird factory calibration
        
        x = [cast.oxy_volts,cast.O2sol_umolkg,cast.t,cast.prs];
    
        % SBE functional form without SOC drift 
        cast.DOcorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));
    end   

    if SOC_type == 1 % Constant SOC value

        x = [cast.oxy_volts,cast.O2sol_umolkg,cast.t,cast.prs];
    
        % SBE functional form without constant SOC
        cast.DOcorr_umolkg = cal.SOCcalc*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));
    end

    if SOC_type == 2 % SOC varies with cruise time

        x = [cast.oxy_volts,cast.O2sol_umolkg,cast.t,cast.prs,cast.cruise_d];
        
        % SBE functional form with SOC as a function of cruise time
        cast.DOcorr_umolkg = ((cal.SOCrate_dt*x(:,5)) + cal.SOCcalc_dt*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_dt*x(:,4))./(x(:,3) + 273.15));
    end

    if SOC_type == 3 % SOC varies with cast number 

        x = [cast.oxy_volts,cast.O2sol_umolkg,cast.t,cast.prs,cast.Station];
        
        % SBE functional form with SOC as a function of cruise time
        cast.DOcorr_umolkg = ((cal.SOCrate_cn*x(:,5)) + cal.SOCcalc_cn*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15));
    end

    cast.SOC_type = ones(length(cast.prs),1)*SOC_type; 

    % Reorder variables and remove unnecessary ones
    vars = {'Station','prs','depth','lat','lon','temp1','temp2','cond1','cond2','CastTimeS','CastTimeUTC','StartTimeUTC','cruise_d','CTDcal'...
        'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','DOcorr_umolkg','O2sol_umolkg','SOC_type'};
    cast = cast(:,vars); 
    
end

function plot_calibrated_DO(downcasts,upcasts,btlsum)

    if height(btlsum) == 1 
         
        figure
        subplot(1,2,1)
        plot(downcasts.pt,downcasts.prs,'Linewidth',1.2)
        hold on
        plot(upcasts.pt,upcasts.prs,'Linewidth',1.2)
        axis ij
        ylabel('Pressure (db)')
        xlabel('pot. temp (\circC)')
        ax = gca;
        ax.XAxisLocation = 'top';
        legend('Downcast','Upcast','Location','SW')

        subplot(1,2,2)
        plot(downcasts.DOcorr_umolkg,downcasts.prs,'Linewidth',1.2)
        hold on
        plot(upcasts.DOcorr_umolkg,upcasts.prs,'Linewidth',1.2)
        axis ij
        ylabel('Pressure (db)')
        xlabel('Oxygen (\mumol kg^-^1)')
        ax = gca;
        ax.XAxisLocation = 'top';
        sgtitle(['Cast ' num2str(downcasts.Station(1))])
    end
    
            
    if height(btlsum) ~= 1 
        
        figure
        subplot(1,2,1)
        plot(downcasts.pt,downcasts.prs,'Linewidth',1.2)
        hold on
        plot(upcasts.pt,upcasts.prs,'Linewidth',1.2)
        axis ij
        ylabel('Pressure (db)')
        xlabel('pot. temp (\circC)')
        ax = gca;
        ax.XAxisLocation = 'top';
        legend('Downcast','Upcast','Location','SW')

        subplot(1,2,2)
        plot(downcasts.DOcorr_umolkg,downcasts.prs,'Linewidth',1.2)
        hold on
        plot(upcasts.DOcorr_umolkg,upcasts.prs,'Linewidth',1.2)
        plot(btlsum.Winkler_umolkg(btlsum.NLMR_Outlier == 0),btlsum.prs(btlsum.NLMR_Outlier == 0),'ok','MarkerFaceColor','k')
        axis ij
        ylabel('Pressure (db)')
        xlabel('Oxygen (\mumol kg^-^1)')
        ax = gca;
        ax.XAxisLocation = 'top';
        sgtitle(['Cast ' num2str(downcasts.Station(1))])
    end

end

function plot_calibrated_pTemp(downcasts,upcasts,cast_num,btlsum,cal,bad_casts,TitleString)
% For plotting purposes 
ooi_latlon = [59.9341, -39.4673
    59.8177, -39.8412
    59.7155, -39.3148];
grey = [0.5     0.5     0.5];
blue = [0     0.44706     0.74118];
red = [0.85098     0.32549    0.098039];

f = figure;
f.Position = [100 100 840 500];
subplot(1,3,1)
for i = 1:length(cast_num)
    if max(cast_num(i) == nanmean(bad_casts,2)) ~=1
        plot(downcasts{cast_num(i)}.lon(1),downcasts{cast_num(i)}.lat(1),'.','Markersize',20)
        hold on
    end
end
plot(ooi_latlon(:,2),ooi_latlon(:,1),'^','markersize',8,'MarkerFaceColor','k',...
    'MarkerEdgeColor','k')
xlabel('Longitude (\circ)')
ylabel('Latitude (\circ)')
grid on
daspect([1 1 1])
title(TitleString)

subplot(1,3,2)
for i = 1:length(cast_num)
    if max(cast_num(i) == nanmean(bad_casts,2)) ~=1
        plot(downcasts{cast_num(i)}.DOcorr_umolkg,downcasts{cast_num(i)}.pt,'Linewidth',1.2)
        hold on
    end
end
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Downcasts')
grid on

subplot(1,3,3)
for i = 1:length(cast_num)
    if max(cast_num(i) == nanmean(bad_casts,2)) ~=1
        plot(upcasts{cast_num(i)}.DOcorr_umolkg,upcasts{cast_num(i)}.pt,'Linewidth',1.2)
        hold on
    end
end

plot(btlsum.Winkler_umolkg(btlsum.NLMR_Outlier==0),btlsum.pt(btlsum.NLMR_Outlier==0),'.k','markersize',20)


ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on

f = figure;
f.Position = [100 100 840 500];
subplot(1,2,1)
for i = 1:length(cast_num)

    x = [downcasts{cast_num(i)}.oxy_volts downcasts{cast_num(i)}.O2sol_umolkg ...
        downcasts{cast_num(i)}.t downcasts{cast_num(i)}.prs];
    DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));
    plot(DOuncorr_umolkg,downcasts{cast_num(i)}.pt,'Linewidth',1,'Color',grey)
    hold on
end

for i = 1:length(cast_num)    
    if max(cast_num(i) == bad_casts(:,1)) ~=1
        plot(downcasts{cast_num(i)}.DOcorr_umolkg,downcasts{cast_num(i)}.pt,'Linewidth',1,'Color',blue)
    end
end
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Downcasts')
grid on

yellow = [0.92941     0.69412     0.12549];

subplot(1,2,2)
plot(NaN,NaN,'Color',grey)
hold on
plot(NaN,NaN,'Color',blue)
plot(NaN,NaN,'.','Markersize',20,'Color',yellow)
plot(NaN,NaN,'.','markersize',20,'Color',red)
plot(NaN,NaN,'.k','markersize',20)

for i = 1:length(cast_num)

    x = [upcasts{cast_num(i)}.oxy_volts upcasts{cast_num(i)}.O2sol_umolkg ...
        upcasts{cast_num(i)}.t upcasts{cast_num(i)}.prs];
    DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));
    plot(DOuncorr_umolkg,upcasts{cast_num(i)}.pt,'Linewidth',1,'Color',grey)
end

for i = 1:length(cast_num)
    if max(cast_num(i) == bad_casts(:,2)) ~= 1
        plot(upcasts{cast_num(i)}.DOcorr_umolkg,upcasts{cast_num(i)}.pt,'Linewidth',1,'Color',blue)
    end
end

plot(btlsum.Winkler_umolkg(btlsum.NLMR_Outlier==1),btlsum.pt(btlsum.NLMR_Outlier==1),'.','markersize',20,'Color',red)
plot(btlsum.Winkler_umolkg(btlsum.NLMR_Outlier==0),btlsum.pt(btlsum.NLMR_Outlier==0),'.k','markersize',20)
% plot(btlsum.Winkler1_umolkg(btlsum.Cast==10),btlsum.pt(btlsum.Cast==10),'.','markersize',20,'Color',yellow)
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on
sgtitle(TitleString)
legend('Uncalibrated','Calibrated','Not Evaluated Winklers','Questionable Winklers','Acceptable Winklers','Location','NW')
end