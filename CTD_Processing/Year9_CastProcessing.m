clearvars; clc; close all
addpath('G:\My Drive\Matlab_work\BC\Irminger\colab-workspace\CTD_Processing')
addpath('G:\My Drive\Matlab_work\BC\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Sea-Bird-Toolbox')
addpath(genpath('G:\My Drive\Matlab_work\Functions\GSW'))

dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year9';
cd(dir)
load Year9_DOcal.mat
ns = 10;
ne = 12;

dc_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year9\cnv\downcasts';
uc_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year9\cnv\upcasts';
leah_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year9\From_Leah';

savefile = 1; % savefile == 1 for saving; savefile == 0, don't save 
%% Read in my processed casts 

% Downcasts 
cd(dc_dir)
files = ls('*.cnv');
cast_num = str2num(files(:,ns:ne)); % Pulls out cast numbers 

mydowncast = []; % Read all my processed SBE cast into matlab 
for i = 1:length(cast_num)
    dcnv_in = readSBScnv(files(i,:));
    mydowncast{cast_num(i)} = my_cast(dcnv_in); %change so that i references cast number not file length number 
end

% Upcasts 
cd(uc_dir)
files = ls('*.cnv');

myupcast = []; % Read all my processed SBE cast into matlab 
for i = 1:length(cast_num)
    ucnv_in = readSBScnv(files(i,:));
    myupcast{cast_num(i)} = my_cast(ucnv_in);
end
%% Make sure Leah's cast numbers match my cast numbers

cd(leah_dir)
downfiles = ls('*.dcc'); % List of Leah's calibrated cast files 
downcasts = str2num(downfiles(:,ns:ne)); % Pulls out cast numbers  

upfiles = ls('*.ucc');
upcasts = str2num(upfiles(:,ns:ne));

% Make sure that there is a Leah cast file for each of my cast files 
if cast_num == downcasts 
    disp('Downcast numbers Line Up')
    clear downcasts % To use variable namelater 
else
    disp('Caution: Issue with Matching Downcast Numbers!')
end

if cast_num == upcasts
    disp('Upcast numbers Line Up')
    clear upcasts % To use variable name later 
else 
    disp('Caution: Issue with Matching Upcast Numbers!')
end

%% Read in Leah's calibrated casts
cd(leah_dir)

dcc = []; % Read Leah's calibrated SBE casts into matlab 
for i = 1:length(cast_num)
    dcc_in =import_dcc(downfiles(i,:));
    dcc{cast_num(i)} = leah_cast(dcc_in);
end

ucc = [];
for i = 1:length(cast_num)
    ucc_in = import_dcc(upfiles(i,:));
    ucc{cast_num(i)} = leah_cast(ucc_in);
end

%% Combine and calibrate DO for Casts Read in bottle data and making DO calibration choice 
btlsum = btlsum_yr9;
CTD_sen = btlsum.CTD_sen(1); % Sensor package to use for calibration; same as bottle processing 
SOC_type = 3; % 1 = constant, % 2 = changes as a function of cruise time % 3 = changes as a function of station number 

btlsum = calibrate_CTD_oxygen(btlsum,cal,SOC_type);
CruiseStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 
 
downcasts = []; upcasts = []; 
for i = 1:length(cast_num)
    if cast_num(i) ~= 10||21 % Skips cast numbers 
        downcasts{cast_num(i)} = process_cast(dcc{cast_num(i)}, mydowncast{cast_num(i)}, CTD_sen, cal, SOC_type, CruiseStartTime);
        upcasts{cast_num(i)} = process_cast(ucc{cast_num(i)}, myupcast{cast_num(i)}, CTD_sen, cal, SOC_type, CruiseStartTime);
    end
end

%% Plot final data
for i = 1:length(cast_num)
%     if cast_num(i) ~= 10||21 % Skips cast numbers
        plot_calibrated_DO(downcasts{cast_num(i)},upcasts{cast_num(i)},btlsum(find(btlsum.Cast == cast_num(i)),:))
%     end
end
%%
bad_casts = [NaN; % bad downcasts  
    NaN]'; % bad upcasts 
plot_calibrated_pTemp(downcasts,upcasts,cast_num,btlsum,cal,bad_casts,'Irminger Year 9')

%% Save processed data 
if savefile == 1

    btlsum_yr9 = btlsum;
    upcasts_yr9 = upcasts;
    downcasts_yr9 = downcasts;
    btl_num_yr9 = btl_num;
    cast_num_yr9 = cast_num;
    cal_yr9 = cal; 
    dt_Processed = datetime('now');
    
    cd(dir)
    save Year9_Processed_NLMR_KF.mat upcasts_yr* downcasts_yr* btl_num_yr* cast_num_yr* cal_yr* btlsum_yr* bad_casts dt_Processed
end
%% Reads in bottle data and calibrates CTD oxygen 
function btlsum = calibrate_CTD_oxygen(btlsum,cal,SOC_type)

    if SOC_type == 1 % Constant SOC value

        x = [btlsum.oxy_volts,btlsum.SBE_oxsol_umolkg,btlsum.t,btlsum.prs];
    
        % SBE functional form without SOC drift 
        btlsum.DOcorr_umolkg = cal.SOCcalc*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));
    end

    if SOC_type == 2 % SOC varies with cruise time
        dtx = datenum(btlsum.Date) - datenum(btlsum.Date(1)); 
        x = [btlsum.oxy_volts,btlsum.SBE_oxsol_umolkg,btlsum.t,btlsum.prs,dtx];
        
        % SBE functional form with SOC as a function of cruise time
        btlsum.DOcorr_umolkg = ((cal.SOCrate_dt*x(:,5)) + cal.SOCcalc_dt*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_dt*x(:,4))./(x(:,3) + 273.15));
    end

    if SOC_type == 3 % SOC varies with cast number 

        x = [btlsum.oxy_volts,btlsum.SBE_oxsol_umolkg,btlsum.t,btlsum.prs,btlsum.Cast];
        
        % SBE functional form with SOC as a function of cruise time
        btlsum.DOcorr_umolkg = ((cal.SOCrate_cn*x(:,5)) + cal.SOCcalc_cn*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15));
    end

        btlsum.SOC_type = ones(length(btlsum.prs),1)*SOC_type; 

            % Reorder variables and remove unnecessary ones
        btlvars = {'Bottle','Date','prs','depth','lat','lon','temp1','temp2','sal1','sal2','Discrete_Salinity_psu','Cruise','Asset','Cast','CTDcal',...
        'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','Winkler_mLL','Winkler_umolkg','GSW_oxsol_umolkg','SBE_oxsol_umolkg',...
        'SOC_type','DOcorr_umolkg'};
        btlsum = btlsum(:,btlvars);
end


%% Reads in my processed casts 
function cast = my_cast(cast)
    cast0 = cast;
    fields = {'source','DataFileType','instrumentheaders','userheaders','vars','longname','units','span','mvars','mvars_format'...
        'scan','lat','lon','nbin','flag','SeasaveVersion','softwareheaders','t090C','t190C','c0mScm','c1mScm'};
    cast = rmfield(cast,fields);
    cast = struct2table(cast);
    cast.Properties.VariableNames = {'CastTimeS','prs','depth','oxy_volts'};
    cast.oxy_volts(cast.oxy_volts == -9.9900e-29) = NaN; % replaces no data flag with NaN
    cast.StartTimeUTC = ones(length(cast.CastTimeS),1)*datenum(cast0.instrumentheaders.SystemUTC); 
    cast.StartTimeUTC = datetime(cast.StartTimeUTC,'ConvertFrom','datenum');
    cast.CastTimeUTC = cast.StartTimeUTC + cast.CastTimeS/3600/24;
    cast.CTDcal(:) = {'True'};
    cast.CTDcal = string(cast.CTDcal);
end

%% Read in Leah's calibrated casts 
function leah_cast = leah_cast(leah_cast)

    fields = {'woce','date','time','oxcr','ox','tran','flu','alt'};
    leah_cast = rmfield(leah_cast,fields);
    leah_cast.station = leah_cast.station.*ones(length(leah_cast.prs),1);
    leah_cast.lat = leah_cast.lat.*ones(length(leah_cast.prs),1);
    leah_cast.lon = leah_cast.lon.*ones(length(leah_cast.prs),1);
    leah_cast = struct2table(leah_cast);
    leah_cast.Properties.VariableNames = {'Station','lat','lon','prs','temp1','temp2','sal1','sal2'};    
end

%% Combines Files and calibrate oxygen data

function cast = process_cast(leah_cast,mycast,CTD_sen,cal,SOC_type,CruiseStartTime)
%     
%     % Combine tables by prs variable 
%     if height(mycast) <= height(leah_cast)
%         cast = join(mycast,leah_cast,'Keys','prs');
%     else 
%         cast = join(leah_cast,mycast,'Keys','prs');
%     end
    cast = innerjoin(mycast,leah_cast); 

    % Decide if using primary or secondary CTD sensor for temp and sal
    if CTD_sen == 1 % primary sensor (use unless something wrong with data)
        cast.t = cast.temp1; 
        cast.SP = cast.sal1; 
     end
    
    if CTD_sen == 2 % secondary sensor (use if primary sensor bad)
        cast.t = cast.temp2; 
        cast.SP = cast.sal2; 
    end   

    % Calculate other parameters of interest for downcast 
    cast.SA = gsw_SA_from_SP(cast.SP,cast.prs,cast.lon,cast.lat);
    cast.CT = gsw_CT_from_t(cast.SA,cast.t,cast.prs);
    cast.pt = gsw_pt_from_CT(cast.SA,cast.CT);  
    cast.GSW_oxsol_umolkg = gsw_O2sol(cast.SA,cast.CT,cast.prs,cast.lon,cast.lat);
    cast.rho = gsw_rho_CT_exact(cast.SA,cast.CT,cast.prs); % in situ density
    cast.prho = gsw_rho_CT_exact(cast.SA,cast.CT,0); % potential density with ref == surf
    cast.sigma0 = gsw_sigma0_CT_exact(cast.SA,cast.CT); % cast.prho - 1000 = cast.sigma0 
    cast.CTD_sen = ones(length(cast.prs),1)*CTD_sen; 
    cast.cruise_d = datenum(cast.StartTimeUTC) - datenum(CruiseStartTime); % Cruise time in days 

    % Calculate oxygen concentration from Winkler calibrated SBE equation 
    [~, oxsol_uM] = sbsoxygensol(cast.t, cast.SP, 'sbs');
    cast.SBE_oxsol_umolkg = oxsol_uM*1000./cast.prho; % Convert to umol/kg
    
    if SOC_type == 1 % Constant SOC value

        x = [cast.oxy_volts,cast.SBE_oxsol_umolkg,cast.t,cast.prs];
    
        % SBE functional form without SOC drift 
        cast.DOcorr_umolkg = cal.SOCcalc*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));
    end

    if SOC_type == 2 % SOC varies with cruise time

        x = [cast.oxy_volts,cast.SBE_oxsol_umolkg,cast.t,cast.prs,cast.cruise_d];
        
        % SBE functional form with SOC as a function of cruise time
        cast.DOcorr_umolkg = ((cal.SOCrate_dt*x(:,5)) + cal.SOCcalc_dt*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_dt*x(:,4))./(x(:,3) + 273.15));
    end

    if SOC_type == 3 % SOC varies with cast number 

        x = [cast.oxy_volts,cast.SBE_oxsol_umolkg,cast.t,cast.prs,cast.Station];
        
        % SBE functional form with SOC as a function of cruise time
        cast.DOcorr_umolkg = ((cal.SOCrate_cn*x(:,5)) + cal.SOCcalc_cn*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15));
    end

    cast.SOC_type = ones(length(cast.prs),1)*SOC_type; 

    % Reorder variables and remove unnecessary ones
    vars = {'Station','prs','depth','lat','lon','temp1','temp2','sal1','sal2','CastTimeS','CastTimeUTC','StartTimeUTC','cruise_d','CTDcal',...
        'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','DOcorr_umolkg','GSW_oxsol_umolkg','SBE_oxsol_umolkg','SOC_type'};
    cast = cast(:,vars); 
    
end

function plot_calibrated_DO(downcasts,upcasts,btlsum)

    if height(btlsum) == 0 
         
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
    
            
    if height(btlsum) ~= 0 
        
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
        plot(btlsum.Winkler_umolkg,btlsum.prs,'ok','MarkerFaceColor','k')
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

figure
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

if btlsum.SOC_type == 1
    outliers = cal.Winkler_outliers;
elseif btlsum.SOC_type == 2
    outliers = cal.Winkler_outliers_dt;
elseif btlsum.SOC_type == 3 
    outliers = cal.Winkler_outliers_cn;
end
Winklers_in = btlsum.Winkler_umolkg;
Winklers_in(outliers) = NaN;

plot(Winklers_in,btlsum.pt,'.k','markersize',20)
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on

figure
subplot(1,2,1)
for i = 1:length(cast_num)

    x = [downcasts{cast_num(i)}.oxy_volts downcasts{cast_num(i)}.SBE_oxsol_umolkg ...
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

subplot(1,2,2)
for i = 1:length(cast_num)

    x = [upcasts{cast_num(i)}.oxy_volts upcasts{cast_num(i)}.SBE_oxsol_umolkg ...
        upcasts{cast_num(i)}.t upcasts{cast_num(i)}.prs];
    DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));
    plot(DOuncorr_umolkg,upcasts{cast_num(i)}.pt,'Linewidth',1,'Color',grey)
    hold on
end

for i = 1:length(cast_num)
    if max(cast_num(i) == bad_casts(:,2)) ~= 1
        plot(upcasts{cast_num(i)}.DOcorr_umolkg,upcasts{cast_num(i)}.pt,'Linewidth',1,'Color',blue)
    end
end

if btlsum.SOC_type == 1
    outliers = cal.Winkler_outliers;
elseif btlsum.SOC_type == 2
    outliers = cal.Winkler_outliers_dt;
elseif btlsum.SOC_type == 3 
    outliers = cal.Winkler_outliers_cn;
end
Winklers_in = btlsum.Winkler_umolkg;
Winklers_in(outliers) = NaN;
plot(btlsum.Winkler_umolkg,btlsum.pt,'.','markersize',20,'Color',red)
plot(Winklers_in,btlsum.pt,'.k','markersize',20)
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on
sgtitle(TitleString)

end