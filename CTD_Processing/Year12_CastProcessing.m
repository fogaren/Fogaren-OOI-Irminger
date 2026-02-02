clearvars; clc; close all
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
run('GeneralSettings.m') % For colors

% dir = 'C:\Users\fogaren\Documents\SBE_Processing\RR2505\btl';
dir = 'C:\Users\fogaren\Documents\SBE_Processing\RR2505\btl\custom_hyst';
cd(dir)
load RR2505_DOcal.mat
ns = 9; % Start of cast numbers in file name
ne = 11; % End of cast numbers in file name 
% cnv_dir = 'C:\Users\fogaren\Documents\SBE_Processing\RR2505\cnv';
% dc_dir = 'C:\Users\fogaren\Documents\SBE_Processing\RR2505\cnv\downcasts';
% uc_dir = 'C:\Users\fogaren\Documents\SBE_Processing\RR2505\cnv\upcasts';
cnv_dir = 'C:\Users\fogaren\Documents\SBE_Processing\RR2505\custom_hyst';
dc_dir = 'C:\Users\fogaren\Documents\SBE_Processing\RR2505\custom_hyst\downcasts';
uc_dir = 'C:\Users\fogaren\Documents\SBE_Processing\RR2505\custom_hyst\upcasts';

leah_dir = 'C:\Users\fogaren\Documents\SBE_Processing\RR2505\from_Leah\final_2db\final_2db';
bco_dmo = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\BCO-DMO Submission\RR2505';
savefile = 0; % savefile == 1 for saving; savefile == 0, don't save 
%% Read in my processed casts 

% Downcasts 
cd(dc_dir)
files = ls('*.cnv');
cast_num = str2num(files(:,ns:ne)); % Pulls out cast numbers 

mydowncast = []; % Read all my processed SBE cast into matlab 
for j = 1:length(cast_num)
    dcnv_in = readSBScnv(files(j,:));
    mydowncast{cast_num(j)} = my_cast(dcnv_in); %change so that i references cast number not file length number 
end

% Upcasts 
cd(uc_dir)
files = ls('*.cnv');

myupcast = []; % Read all my processed SBE cast into matlab 
for j = 1:length(cast_num)
    ucnv_in = readSBScnv(files(j,:));
    myupcast{cast_num(j)} = my_cast(ucnv_in);
end

mycast = [];
cd(cnv_dir)
files = ls('*.cnv');

for j = 1:length(cast_num)
    ucnv_in = readSBScnv(files(j,:));
    mycast{cast_num(j)} = my_cast(ucnv_in);
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
for j = 1:length(cast_num)
    dcc_in =import_dcc(downfiles(j,:));
    dcc{cast_num(j)} = leah_cast(dcc_in);
end

ucc = [];
for j = 1:length(cast_num)
    ucc_in = import_dcc(upfiles(j,:));
    ucc{cast_num(j)} = leah_cast(ucc_in);
end

%% Combine and calibrate DO for Casts Read in bottle data and making DO calibration choice 
btlsum_tbl = btlsum_RR2505;
CTD_sen = btlsum_tbl.CTD_sen(1); % Sensor package to use for calibration; same as bottle processing 
SOC_type = 1; % 1 = constant, % 2 = changes as a function of cruise time % 3 = changes as a function of station number 

CruiseStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 

btlsum = []; 
downcasts = []; upcasts = []; 
for j = 1:length(cast_num)
        btlsum{cast_num(j)} = btlsum_tbl(btlsum_tbl.Cast == cast_num(j),:); 
        downcasts{cast_num(j)} = process_cast(dcc{cast_num(j)}, mydowncast{cast_num(j)}, CTD_sen, cal, SOC_type, CruiseStartTime);
        upcasts{cast_num(j)} = process_cast(ucc{cast_num(j)}, myupcast{cast_num(j)}, CTD_sen, cal, SOC_type, CruiseStartTime);
end
% %% Example of what happens to oxygen sensor data when you don't remove the surface soak
% close all
% j = 15;
% figure
% plot(downcasts{j}.DOcorr_umolkg,downcasts{j}.prs,'Linewidth',2)
% hold on
% plot(downcasts{j}.oxumkg,downcasts{j}.prs,'Linewidth',2)
% plot(upcasts{j}.DOcorr_umolkg,upcasts{j}.prs,'Color',navy,'Linewidth',2)
% plot(upcasts{j}.oxumkg,upcasts{j}.prs,'Color',maroon,'Linewidth',2)
% l = legend('Removed Down (cal)','Not Removed Down (uncal)','Removed Up (cal)','Not Removed Up (uncal)','Location','SW');
% l.Title.String = 'Surface Soak';
% axis ij; axis tight
% ylim([0 500])
% title(['Cast ' num2str(downcasts{j}.Station(1))])
% ylabel('depth (dbar)')
% xlabel('Oxygen (\mumol kg^-^1)')

%% Plot final data

for j = 1:length(cast_num)
    plot_calibrated_DO(downcasts{cast_num(j)},upcasts{cast_num(j)},btlsum{cast_num(j)})
end
%%
bad_casts = [NaN; % bad downcasts  
    NaN]'; % bad upcasts 
plot_calibrated_pTemp(downcasts,upcasts,cast_num,btlsum_tbl,cal,bad_casts,'Year 12: RR2505')
%%
figure
for j = 1:length(cast_num)
    subplot(3,8,j)
    plot(downcasts{j}.DOcorr_umolkg,downcasts{j}.prs,'Color',blue,'Linewidth',2)
    hold on
    plot(upcasts{j}.DOcorr_umolkg,upcasts{j}.prs,'Color',green,'Linewidth',2)
    axis ij
    plot(btlsum_tbl.Winkler1_umolkg(btlsum_tbl.Cast == cast_num(j) & btlsum_tbl.NLMR_Outlier1 == 2),btlsum_tbl.prs(btlsum_tbl.Cast == cast_num(j) & btlsum_tbl.NLMR_Outlier1 == 2),'.k','MarkerSize',20)
    plot(btlsum_tbl.Winkler2_umolkg(btlsum_tbl.Cast == cast_num(j) & btlsum_tbl.NLMR_Outlier2 == 2),btlsum_tbl.prs(btlsum_tbl.Cast == cast_num(j) & btlsum_tbl.NLMR_Outlier2 == 2),'.k','MarkerSize',20)
    plot(btlsum_tbl.Winkler1_umolkg(btlsum_tbl.Cast == cast_num(j) & btlsum_tbl.NLMR_Outlier1 == 3),btlsum_tbl.prs(btlsum_tbl.Cast == cast_num(j) & btlsum_tbl.NLMR_Outlier1 == 3),'.','Color',red,'MarkerSize',20)
    plot(btlsum_tbl.Winkler2_umolkg(btlsum_tbl.Cast == cast_num(j) & btlsum_tbl.NLMR_Outlier2 == 3),btlsum_tbl.prs(btlsum_tbl.Cast == cast_num(j) & btlsum_tbl.NLMR_Outlier2 == 3),'.','Color',red,'MarkerSize',20)
    title(['Cast ' num2str(downcasts{j}.Station(1))])
    if cast_num(j) == 1 
        ylabel('prs (dbar)')
    elseif cast_num(j) == 9
        ylabel('prs (dbar)')
    elseif cast_num(j) == 17
        ylabel('prs (dbar)')
    elseif cast_num(j) == 3
        legend('Downcast','Upcast','Winkler','Winkler Outlier','Location','eastoutside')
    end
end
sgtitle('RR2505: Winkler-calibrated CTD-DO (\mumol kg^-^1)')



%%
figure(101)
output = [];
for j = 1:length(cast_num)
    if height(downcasts{j})*2 > 2000
        for k = 2:2:(height(downcasts{j})*2)
            try 
                plot(downcasts{cast_num(j)}.DOcorr_umolkg(downcasts{cast_num(j)}.prs == k) - ...
                    upcasts{cast_num(j)}.DOcorr_umolkg(upcasts{cast_num(j)}.prs == k), upcasts{cast_num(j)}.prs(upcasts{cast_num(j)}.prs == k),'.k','Markersize',8)
                output = [output; [k downcasts{cast_num(j)}.DOcorr_umolkg(downcasts{cast_num(j)}.prs == k) - upcasts{cast_num(j)}.DOcorr_umolkg(upcasts{cast_num(j)}.prs == k)]];
            catch
                disp('No matching depth cell')
            end
            hold on
        end
    axis ij
    grid on; box on
    plot([-1 -1],[0 height(downcasts{j})*2],'r--','Linewidth',2)
    plot([1 1],[0 height(downcasts{j})*2],'r--','LineWidth',2)
    xlim([-10 10])
    ylim([0 3000])
    end
end
%%
ylabel('Pressure (dbar)')
xlabel('Downcast DO - Upcast DO for each depth bin (\mumol kg^-^1)')
title('RR2505: Custom Hysteresis Correction')
%% Save processed data 
if savefile == 1

    btlsum_RR2505 = btlsum;
    btlsum_RR2505_tbl = btlsum_tbl; 
    upcasts_RR2505 = upcasts;
    downcasts_RR2505 = downcasts;
    btl_num_RR2505 = unique(btlsum_tbl.Cast);
    cast_num_RR2505 = cast_num;
    SBE_cal_RR2505 = cal; 
    dt_KF_Processed_RR2505 = datetime('now');
    cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Processed')
    save RR2505_DO_Processed_KF.mat upcasts_* downcasts_* btl_num_* cast_num_* SBE_cal_* btlsum_RR2505* dt_KF_Processed_*
end

%% Save processed data 
if savefile == 1

    btlsum_yr12 = btlsum;
    btlsum_tbl_yr12 = btlsum_tbl; 
    upcasts_yr12 = upcasts;
    downcasts_yr12 = downcasts;
    btl_num_yr12 = unique(btlsum_tbl.Cast);
    cast_num_yr12 = cast_num;
    cal_yr12 = cal; 
    dt_KF_Processed_yr12 = datetime('now');
    clear btlsum_tbl
    cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Processed')
    save Year12_Processed_KF.mat upcasts_* downcasts_* btl_num_* cast_num_* cal_* btlsum_* dt_KF_Processed_*
end

%%
%Change folder to BCO-DMO location 

cd(bco_dmo)
for j = 1:length(cast_num)
    dwn_out = downcasts{cast_num(j)};

    temp_flag = ones(size(dwn_out.t))*2;
    sal_flag = ones(size(dwn_out.t))*2;
    oxycur_flag = ones(size(dwn_out.t))*2;
    ctdoxy_flag = ones(size(dwn_out.t))*2;

    fheader = ['RR2505    Calibrated Oxygen Downcast   Station: ' num2str(cast_num(j)) newline...
    'Latitude: ' sprintf('%.4f',dwn_out.lat(1)) '   Longitude: ' sprintf('%.4f',dwn_out.lon(1))...
    '   ' datestr(dwn_out.StartTimeUTC(1)) newline...
    sprintf('CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
    sprintf('dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 

    fileIDd = fopen(['RR2505_' sprintf('%03d',cast_num(j)) 'd.csv'],'w');
    fprintf(fileIDd,fheader);
    for jj = 1:length(dwn_out.prs)
        fprintf(fileIDd,'%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n', dwn_out.prs(jj),dwn_out.t(jj),temp_flag(jj),dwn_out.SP(jj),sal_flag(jj),dwn_out.oxy_volts(jj),oxycur_flag(jj),dwn_out.DOcorr_umolkg(jj),ctdoxy_flag(jj));
    end
    fclose(fileIDd);
end

for j = 1:length(cast_num)
    up_out = upcasts{cast_num(j)};

    temp_flag = ones(size(up_out.t))*2;
    sal_flag = ones(size(up_out.t))*2;
    oxycur_flag = ones(size(up_out.t))*2;
    ctdoxy_flag = ones(size(up_out.t))*2;

    fheader = ['RR2505    Calibrated Oxygen Upcast   Station: ' num2str(cast_num(j)) newline...
    'Latitude: ' sprintf('%.4f',up_out.lat(1)) '   Longitude: ' sprintf('%.4f',up_out.lon(1))...
    '   ' datestr(up_out.StartTimeUTC(1)) newline...
    sprintf('CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
    sprintf('dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 

    fileIDu = fopen(['RR2505_' sprintf('%03d',cast_num(j)) 'u.csv'],'w');
    fprintf(fileIDu,fheader);
    for jj = 1:length(up_out.prs)
        fprintf(fileIDu,'%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n', up_out.prs(jj),up_out.t(jj),temp_flag(jj),up_out.SP(jj),sal_flag(jj),up_out.oxy_volts(jj),oxycur_flag(jj),up_out.DOcorr_umolkg(jj),ctdoxy_flag(jj));
    end
    fclose(fileIDu);
end

%%
for j = 1:length(btl_num)
    btl_out = btlsum{btl_num(j)};
    index1 = max(~(isnan(btl_out.Winkler1_umolkg(:))));
    index2 = max(~(isnan(btl_out.Winkler1_umolkg(:)) | isnan(btl_out.Winkler2_umolkg(1))));
    % index3 = max(~(isnan(btl_out.Winkler1_umolkg(1)) | isnan(btl_out.Winkler2_umolkg(1)) | isnan(btl_out.Winkler3_umolkg(1))));

    btl_out.NLMR_Outlier1(isnan(btl_out.Winkler1_umolkg)) = 9;
    btl_out.NLMR_Outlier1(btl_out.NLMR_Outlier1 == 1) = 3; % Or should this be 4?
    btl_out.NLMR_Outlier1(btl_out.NLMR_Outlier1 == 0) = 2;
    btl_out.Winkler1_umolkg(isnan(btl_out.Winkler1_umolkg)) = -999;

    btl_out.NLMR_Outlier2(isnan(btl_out.Winkler2_umolkg)) = 9;
    btl_out.NLMR_Outlier2(btl_out.NLMR_Outlier2 == 1) = 3; % Or should this be 4?
    btl_out.NLMR_Outlier2(btl_out.NLMR_Outlier2 == 0) = 2;
    btl_out.Winkler2_umolkg(isnan(btl_out.Winkler2_umolkg)) = -999;

    % btl_out.NLMR_Outlier3(isnan(btl_out.Winkler3_umolkg)) = 9;
    % btl_out.NLMR_Outlier3(btl_out.NLMR_Outlier3 == 1) = 3; % Or should this be 4?
    % btl_out.NLMR_Outlier3(btl_out.NLMR_Outlier3 == 0) = 2;
    % btl_out.Winkler3_umolkg(isnan(btl_out.Winkler3_umolkg)) = -999;

    temp_flag = ones(size(btl_out.t))*2;
    sal_flag = ones(size(btl_out.t))*2;
    oxycur_flag = ones(size(btl_out.t))*2;
    ctdoxy_flag = ones(size(btl_out.t))*2;

    data =  [btl_out.Bottle,btl_out.prs,btl_out.t,temp_flag,btl_out.SP,sal_flag,btl_out.oxy_volts,oxycur_flag,btl_out.DOcorr_umolkg,ctdoxy_flag,...
        btl_out.Winkler1_umolkg,btl_out.NLMR_Outlier1,btl_out.Winkler2_umolkg,btl_out.NLMR_Outlier2];

    if index1 + index2 == 2
        fheader = ['RR2505    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(j)) newline...
        sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag, Oxygen1, Oxygen1_flag, Oxygen2, Oxygen2_flag') newline...
        sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a., umol/kg, n.a., umol/kg, n.a.') newline];
        string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d,%.1f,%d,%.1f,%d\n';
        data_format = data;
    elseif index1 + index2 == 1
        fheader = ['RR2505    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(j)) newline...
        sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag, Oxygen1, Oxygen1_flag') newline...
        sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a., umol/kg, n.a.') newline];   
        string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d,%.1f,%d\n';
        data_format = data(:,1:end-2);
    else
        fheader = ['RR2505    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(j)) newline...
        sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
        sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 
        string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n';
        data_format = data(:,1:end-6);
    end

    fileID = fopen(['RR2505_' sprintf('%03d',btl_num(j)) 'btl.csv'],'w');
    fprintf(fileID,fheader);
        for jj = 1:length(btl_out.Bottle)
            fprintf(fileID,string_format, data_format(jj,:));
        end
    fclose(fileID);
end

%% Reads in my processed casts 
function cast = my_cast(cast)
    cast0 = cast;
    fields = {'source','DataFileType','instrumentheaders','userheaders','vars','longname','units','span','mvars','mvars_format'...
        'scan','lat','lon','nbin','flag','SeasaveVersion','softwareheaders','t090C','t190C','c0mScm','c1mScm','sbox0Mm_Kg','oxsolMm_Kg','oxsatMm_Kg','ph'};
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

    fields = {'woce','date','time','oxcr','ox','oxumkg','tran','flu','alt'};
    % fields = {'woce','date','time','oxcr','ox','tran','flu','alt'};
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
    vars = {'Station','prs','depth','lat','lon','temp1','temp2','sal1','sal2','CastTimeS','CastTimeUTC','StartTimeUTC','cruise_d','CTDcal',...
        'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','DOcorr_umolkg','O2sol_umolkg','SOC_type'};
    cast = cast(:,vars); 
    
end

function plot_calibrated_DO(downcasts,upcasts,btlsum)
yellow = [0.9294    0.6941    0.1255];
red = [0.8510    0.3255    0.0980];
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
        plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1 == 99),btlsum.prs(btlsum.NLMR_Outlier1 == 99),'ok','MarkerFaceColor',yellow)
        plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2 == 99),btlsum.prs(btlsum.NLMR_Outlier2 == 99),'ok','MarkerFaceColor',yellow)
        plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1 == 3),btlsum.prs(btlsum.NLMR_Outlier1 == 3),'ok','MarkerFaceColor',red)
        plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2 == 3),btlsum.prs(btlsum.NLMR_Outlier2 == 3),'ok','MarkerFaceColor',red)
        plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1 == 2),btlsum.prs(btlsum.NLMR_Outlier1 == 2),'ok','MarkerFaceColor','k')
        plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2 == 2),btlsum.prs(btlsum.NLMR_Outlier2 == 2),'ok','MarkerFaceColor','k')
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

plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1==2),btlsum.pt(btlsum.NLMR_Outlier1==2),'.k','markersize',20)
plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2==2),btlsum.pt(btlsum.NLMR_Outlier2==2),'.k','markersize',20)

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

subplot(1,2,2)
plot(NaN,NaN,'Color',grey)
hold on
plot(NaN,NaN,'Color',blue)
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

plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1==3),btlsum.pt(btlsum.NLMR_Outlier1==3),'.','markersize',20,'Color',red)
plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1==2),btlsum.pt(btlsum.NLMR_Outlier1==2),'.k','markersize',20)
plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2==3),btlsum.pt(btlsum.NLMR_Outlier2==3),'.','markersize',20,'Color',red)
plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2==2),btlsum.pt(btlsum.NLMR_Outlier2==2),'.k','markersize',20)
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on
sgtitle(TitleString)
legend('Uncalibrated','Calibrated','Questionable Winklers','Acceptable Winklers','Location','NW')
end