%% NOTES: 

% Leaky Niskins:
%   - Cast 4: Bottle 12
%   - Cast 5: Bottle 13
%   - Cast 6: Bottle 13

%%
% Set up workspace 
clearvars
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
addpath(genpath('G:\My Drive\Matlab_work\Github\GSW-Matlab'))

% Read in calibrated bottle files, Winkler sample values and oxygen files
% processed with default hysteresis correction and user-determined time lag
% correction 
% btl_dir = 'C:\Users\fogaren\Desktop\AR76-03\btl'; % With hysteresis correction 
btl_dir = 'C:\Users\fogaren\Desktop\AR76-03\ctd\raw'; % with custom hysteresis correction 
%cal_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year9\From_Leah';
samp_dir = 'C:\Users\fogaren\Desktop\AR76-03'; % Winkler file location 
Winkler_file = 'Irminger_Sea-10_AR76-03_Discrete_Summary_KF.xlsx'; % Winkler file name 
filesave = 0; % filesave == 1, save calibration output as mat file

% Use Bottle samples to calculate new SOC (gain) and E terms for CTD data 
CTD_sen = 1; % Use primary or secondary CTD temp and sal
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
Winklers_to_use(btlsum_tbl.prs < 100) = NaN;
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
f = figure(8);
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.b','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.b','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.b','Markersize',20); hold on;
ylabel({'Residual, Winkler - Model','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on

%Plot residuals versus oxygen concentration 
subplot(2,2,4)
plot(btlsum_tbl.Winkler_umolkg, mdlcal_k.Residuals.raw(1:height(btlsum_tbl)), '.b','Markersize',20); hold on;
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
            'CTDcal','CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','O2sol_umolkg','Winkler_mLL',...
            'Winkler_umolkg','SOC_type','NLMR_Outlier','DOcorr_umolkg'};
        btlsum = btlsum(:,btlvars);
end
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
