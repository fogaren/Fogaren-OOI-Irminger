clearvars; clc; 
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')

dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year2';
cd(dir)
load Year2_DOcal.mat
ns = 7; % Start of cast numbers in file name
ne = 9; % End of cast numbers in file name 

dc_dir = 'C:\Users\fogaren\Documents\SBE\Year2\downcasts';
uc_dir = 'C:\Users\fogaren\Documents\SBE\Year2\upcasts';

savefile = 0; % savefile == 1 for saving; savefile == 0, don't save
bcodmo = 0; % write to csv files if == 1
bco_dmo = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\BCO-DMO Submission\AT30-01';
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


%% Combine and calibrate DO for Casts Read in bottle data and making DO calibration choice 
btlsum_tbl = btlsum_yr2;
CTD_sen = btlsum_tbl.CTD_sen(1); % Sensor package to use for calibration; same as bottle processing 
SOC_type = btlsum_tbl.SOC_type(1); % 1 = constant, % 2 = changes as a function of cruise time % 3 = changes as a function of station number 

CruiseStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 

btlsum = []; 
downcasts = []; upcasts = []; 
for i = 1:length(cast_num)
        btlsum{cast_num(i)} = btlsum_tbl(btlsum_tbl.Cast == cast_num(i),:); 
        downcasts{cast_num(i)} = process_cast_noCTDcal(mydowncast{cast_num(i)}, CTD_sen, cal, SOC_type, CruiseStartTime,cast_num(i));
        upcasts{cast_num(i)} = process_cast_noCTDcal( myupcast{cast_num(i)}, CTD_sen, cal, SOC_type, CruiseStartTime,cast_num(i));
end

%% Plot final data
for i = 1:length(cast_num)
    plot_calibrated_DO(downcasts{cast_num(i)},upcasts{cast_num(i)},btlsum{cast_num(i)})
end
%%
bad_casts = [NaN; % bad downcasts 
    NaN]'; % bad upcasts 
plot_calibrated_pTemp(downcasts,upcasts,cast_num,btlsum_tbl,cal,bad_casts,'AT30-01 OOI Year 2')

%% Plot CTD1 - CTD2 versus pressure by Downcasts and Upcasts

for i = 1:length(cast_num)
    figure(100)
    subplot(1,2,1)
    plot(downcasts{cast_num(i)}.temp1-downcasts{cast_num(i)}.temp2,downcasts{cast_num(i)}.prs)
    hold on

    subplot(1,2,2)
    plot(downcasts{cast_num(i)}.sal1-downcasts{cast_num(i)}.sal2,downcasts{cast_num(i)}.prs)
    hold on
end

figure(100)
subplot(1,2,1)
hold on
plot(ones(length(0:100:3500))*0.001,0:100:3500,'k--')
plot(ones(length(0:100:3500))*-0.001,0:100:3500,'k--')
axis ij
grid on
xlim([-0.015 0.015])
title({'Temperature' 'Sensor Difference'})
ylabel('Pressure (db)')
xlabel({'Primary minus Secondary ' 'Temperature (\circC)'})

figure(100)
subplot(1,2,2)
hold on
plot(ones(length(0:100:3500))*0.005,0:100:3500,'k--')
plot(ones(length(0:100:3500))*-0.005,0:100:3500,'k--')
axis ij
grid on
xlim([-0.03 0.03])
title({'Salinity' 'Sensor Difference'})
ylabel('Pressure (db)')
xlabel({'Primary minus Secondary ' 'derived Salinity (PSU)'})
sgtitle('AT30-01 Downcasts')

for i = 1:length(cast_num)
    figure(101)
    subplot(1,2,1)
    plot(upcasts{cast_num(i)}.temp1-upcasts{cast_num(i)}.temp2,upcasts{cast_num(i)}.prs)
    hold on

    subplot(1,2,2)
    plot(upcasts{cast_num(i)}.sal1-upcasts{cast_num(i)}.sal2,upcasts{cast_num(i)}.prs)
    hold on
end
figure(101)
subplot(1,2,1)
hold on
plot(ones(length(0:100:3500))*0.001,0:100:3500,'k--')
plot(ones(length(0:100:3500))*-0.001,0:100:3500,'k--')
axis ij
grid on
xlim([-0.015 0.015])
title({'Temperature' 'Sensor Difference'})
ylabel('Pressure (db)')
xlabel({'Primary minus Secondary ' 'Temperature (\circC)'})

figure(101)
subplot(1,2,2)
hold on
plot(ones(length(0:100:3500))*0.005,0:100:3500,'k--')
plot(ones(length(0:100:3500))*-0.005,0:100:3500,'k--')
axis ij
grid on
xlim([-0.03 0.03])
title({'Salinity' 'Sensor Difference'})
ylabel('Pressure (db)')
xlabel({'Primary minus Secondary ' 'derived Salinity (PSU)'})
sgtitle('AT30-01 Upcasts')

%% Bottle Salinity vs. Upcast sal1 and Upcast sal 2 by stations
for i = 1:length(cast_num)
    figure
    plot(upcasts{cast_num(i)}.sal1,upcasts{cast_num(i)}.prs)
    hold on
    plot(upcasts{cast_num(i)}.sal2,upcasts{cast_num(i)}.prs)

    if height(btlsum{cast_num(i)}) > 0
        plot(btlsum{cast_num(i)}.Discrete_Salinity_psu,btlsum{cast_num(i)}.prs,'.k','MarkerSize',20)
    end

    axis ij
    grid on
    title(['AT30-01 Cast ' num2str(cast_num(i))])
end
%%

sal1sorted = sort(abs(btlsum_tbl.Discrete_Salinity_psu-btlsum_tbl.sal1));
sal2sorted = sort(abs(btlsum_tbl.Discrete_Salinity_psu-btlsum_tbl.sal2));
nanmean(sal1sorted(1:end-14))
nanstd(sal1sorted(1:end-14))
nanmean(sal2sorted(1:end-14))
nanstd(sal2sorted(1:end-14))

figure
plot(sal1sorted(1:104),'.','MarkerSize',20)
hold on
plot(sal2sorted(1:104),'.','MarkerSize',20)
%% Save processed data 
if savefile == 1

    btlsum_yr2 = btlsum;
    btlsum_tbl_yr2 = btlsum_tbl; 
    upcasts_yr2 = upcasts;
    downcasts_yr2 = downcasts;
    btl_num_yr2 = btl_num;
    cast_num_yr2 = cast_num;
    SBE_cal_yr2 = cal;
    dt_KF_Processed_yr2 = datetime('now');
    clear btlsum_tbl
%     cd(dir)
    cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Processed')
    save Year2_Processed_KF.mat upcasts_* downcasts_* btl_num_* cast_num_* SBE_cal_* btlsum_* dt_KF_Processed_*
end
%%
%Change folder to BCO-DMO location 
if bcodmo == 1
cd(bco_dmo)
for i = 1:length(cast_num)
    dwn_out = downcasts{cast_num(i)};
    
    temp_flag = ones(size(dwn_out.t))*1; % Not evaluated 
    sal_flag = ones(size(dwn_out.t))*1;
    oxycur_flag = ones(size(dwn_out.t))*2; % Acceptable 
    ctdoxy_flag = ones(size(dwn_out.t))*2;

    fheader = ['AT30-01    Calibrated Oxygen Downcast   Station: ' num2str(cast_num(i)) newline...
    'Latitude: ' sprintf('%.4f',dwn_out.lat(1)) '   Longitude: ' sprintf('%.4f',dwn_out.lon(1))...
    '   ' datestr(dwn_out.StartTimeUTC(1)) newline...
    sprintf('CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
    sprintf('dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 

    fileIDd = fopen(['AT30-01_' sprintf('%03d',cast_num(i)) 'd.csv'],'w');
    fprintf(fileIDd,fheader);
    for ii = 1:length(dwn_out.prs)
        fprintf(fileIDd,'%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n', dwn_out.prs(ii),dwn_out.t(ii),temp_flag(ii),dwn_out.SP(ii),sal_flag(ii),dwn_out.oxy_volts(ii),oxycur_flag(ii),dwn_out.DOcorr_umolkg(ii),ctdoxy_flag(ii));
    end
    fclose(fileIDd);
end

for i = 1:length(cast_num)
    up_out = upcasts{cast_num(i)};

    temp_flag = ones(size(up_out.t))*1; % Not Evaluated  
    sal_flag = ones(size(up_out.t))*1;
    oxycur_flag = ones(size(up_out.t))*2; % Acceptable
    ctdoxy_flag = ones(size(up_out.t))*2;

    fheader = ['AT30-01    Calibrated Oxygen Upcast   Station: ' num2str(cast_num(i)) newline...
    'Latitude: ' sprintf('%.4f',up_out.lat(1)) '   Longitude: ' sprintf('%.4f',up_out.lon(1))...
    '   ' datestr(up_out.StartTimeUTC(1)) newline...
    sprintf('CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
    sprintf('dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 

    fileIDu = fopen(['AT30-01_' sprintf('%03d',cast_num(i)) 'u.csv'],'w');
    fprintf(fileIDu,fheader);
    for ii = 1:length(up_out.prs)
        fprintf(fileIDd,'%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n', up_out.prs(ii),up_out.t(ii),temp_flag(ii),up_out.SP(ii),sal_flag(ii),up_out.oxy_volts(ii),oxycur_flag(ii),up_out.DOcorr_umolkg(ii),ctdoxy_flag(ii));
    end
    fclose(fileIDu);
end

%%
for i = 1:length(btl_num)
    btl_out = btlsum{btl_num(i)};

    index1 = max(~(isnan(btl_out.Winkler_umolkg)));
%     btl_out.NLMR_Outlier(isnan(btl_out.Winkler_umolkg)) = 9; % This was
%     already done in DOcal file 
%     btl_out.NLMR_Outlier(btl_out.NLMR_Outlier == 1) = 3; 
%     btl_out.NLMR_Outlier(btl_out.NLMR_Outlier == 0) = 2;
    btl_out.Winkler_umolkg(isnan(btl_out.Winkler_umolkg)) = -999;

    temp_flag = ones(size(btl_out.t))*1; % Not evaluated 
    sal_flag = ones(size(btl_out.t))*1;
    oxycur_flag = ones(size(btl_out.t))*2; % Acceptable 
    ctdoxy_flag = ones(size(btl_out.t))*2;

    data =  [btl_out.Bottle,btl_out.prs,btl_out.t,temp_flag,btl_out.SP,sal_flag,btl_out.oxy_volts,oxycur_flag,btl_out.DOcorr_umolkg,ctdoxy_flag,...
        btl_out.Winkler_umolkg,btl_out.NLMR_Outlier];

    if index1 == 1
        fheader = ['AT30-01    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
        sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag, Oxygen, Oxygen_flag') newline...
        sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a., umol/kg, n.a.') newline];
        string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d,%.1f,%d\n';
        data_format = data(:,1:end);
    else
        fheader = ['AT30-01    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
        sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
        sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 
        string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n';
        data_format = data(:,1:end-2);
    end

    fileID = fopen(['AT30-01_' sprintf('%03d',btl_num(i)) 'btl.csv'],'w');
    fprintf(fileID,fheader);
        for ii = 1:length(btl_out.Bottle)
            fprintf(fileID,string_format, data_format(ii,:));
        end
    fclose(fileID);
end

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
    cast.sal1 = gsw_SP_from_C(cast.cond1,cast.temp1,cast.prs);
    cast.sal2 = gsw_SP_from_C(cast.cond2,cast.temp2,cast.prs);
end

%% Combines Files and calibrate oxygen data

function cast = process_cast_noCTDcal(cast,CTD_sen,cal,SOC_type,CruiseStartTime,cast_number)

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
    cast.O2sol_umolkg = gsw_O2sol(cast.SA,cast.CT,cast.prs,cast.lon,cast.lat);
    cast.rho = gsw_rho_CT_exact(cast.SA,cast.CT,cast.prs); % in situ density
    cast.prho = gsw_rho_CT_exact(cast.SA,cast.CT,0); % potential density with ref == surf
    cast.sigma0 = gsw_sigma0_CT_exact(cast.SA,cast.CT); % cast.prho - 1000 = cast.sigma0 
    cast.CTD_sen = ones(length(cast.prs),1)*CTD_sen; 
    cast.cruise_d = datenum(cast.StartTimeUTC) - datenum(CruiseStartTime); % Cruise time in days 
    cast.Station = cast_number*ones(length(cast.prs),1);
    
    if SOC_type == 0 % Uses SBE factory calibration 

        x = [cast.oxy_volts,cast.O2sol_umolkg,cast.t,cast.prs];
    
        % SBE functional form without SOC drift 
        cast.DOcorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));
    end

    if SOC_type == 1 % Constant SOC value

        x = [cast.oxy_volts,cast.O2sol_umolkg,cast.t,cast.prs];
    
        % SBE functional form without SOC drift 
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
    vars = {'Station','prs','depth','lat','lon','temp1','temp2','sal1','sal2','CastTimeS','CastTimeUTC','StartTimeUTC','cruise_d','CTDcal',...
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
yellow = [0.92941     0.69412     0.12549];

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

if btlsum.SOC_type == 1
    outliers = cal.Winkler_outliers;
elseif btlsum.SOC_type == 2
    outliers = cal.Winkler_outliers_dt;
elseif btlsum.SOC_type == 3 
    outliers = cal.Winkler_outliers_cn;
end
Winklers_in = btlsum.Winkler_umolkg;
Winklers_in(outliers) = NaN;

plot(Winklers_in,btlsum.pt,'.','markersize',20,'Color',red)
plot(btlsum.Winkler_umolkg,btlsum.pt,'.k','markersize',20)
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
axis([220 320 0 10]); grid on

subplot(1,2,2)
plot(NaN,NaN,'Color',grey)
hold on
plot(NaN,NaN,'Color',blue)
plot(NaN,NaN,'.','MarkerSize',20,'Color',yellow)
plot(NaN,NaN,'.','MarkerSize',20,'Color',red)
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

plot(btlsum.Winkler_umolkg,btlsum.pt,'.','markersize',20,'Color',yellow)
plot(btlsum.Winkler_umolkg(btlsum.NLMR_Outlier == 3),btlsum.pt(btlsum.NLMR_Outlier == 3),'.','markersize',20,'Color',red)
plot(btlsum.Winkler_umolkg(btlsum.NLMR_Outlier == 2),btlsum.pt(btlsum.NLMR_Outlier == 2),'.k','markersize',20)

ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
axis([220 320 0 10]); grid on
sgtitle('Year 2: AT30-01')
legend('Uncalibrated','Calibrated','Not Evaluated Winklers','Questionable Winklers','Acceptable Winklers','Location','NW')

end