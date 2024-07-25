clearvars; clc; 
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')

dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\AR69-03';
cd(dir)
load AR6903_DOcal.mat
ns = 10; % Start of cast numbers in file name
ne = 12; % End of cast numbers in file name 

dc_dir = 'C:\Users\fogaren\Documents\SBE\AR69-03\downcasts';
uc_dir = 'C:\Users\fogaren\Documents\SBE\AR69-03\upcasts';
aaron_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\AR69-03\SOI_Processed';

savefile = 0; % savefile == 1 for saving; savefile == 0, don't save
% bcodmo = 0; % write to csv files if == 1
% bco_dmo = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\BCO-DMO Submission\AR21';
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

%% Make sure Aaron's cast numbers match my cast numbers

cd(aaron_dir)
downfiles = ls('*_downcast_2db.nc'); % List of Leah's calibrated cast files 
downcasts = str2num(downfiles(:,1:3)); % Pulls out cast numbers  

upfiles = ls('*_upcast_2db.nc');
upcasts = str2num(upfiles(:,1:3));

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
%% Read in Aarons calibrated casts
cd(aaron_dir)

dcc = []; % Read Leah's calibrated SBE casts into matlab 
for i = 1:length(cast_num)
    dcc_in = import_sio(downfiles(i,:));
    dcc{cast_num(i)} = dcc_in;
end

ucc = [];
for i = 1:length(cast_num)
    ucc_in = import_sio(upfiles(i,:));
    ucc{cast_num(i)} = ucc_in;
end
%%
for i = 1:length(cast_num)
    figure(1)
    subplot(2,2,1)
    plot(ucc{cast_num(i)}.CTDTMP_FLAG,'.')
    hold on
    title('Upcast: Temp Flag')
    xlabel('Bin #')
    ylabel('WOCE Flag')

    subplot(2,2,2)
    plot(ucc{cast_num(i)}.CTDSAL_FLAG,'.')
    hold on
    title('Upcast: Sal Flag')
    ylabel('WOCE Flag')
    
    subplot(2,2,3)
    plot(dcc{cast_num(i)}.CTDTMP_FLAG,'.')
    hold on
    title('Downcast: Temp Flag')
    xlabel('Bin #')
    ylabel('WOCE Flag')

    subplot(2,2,4)
    plot(dcc{cast_num(i)}.CTDSAL_FLAG,'.')
    hold on
    title('Downcast: Sal Flag')
    xlabel('Bin #')
    ylabel('WOCE Flag')
end
sgtitle('SIO Calibrated CTD Flags')

%% Combine and calibrate DO for Casts Read in bottle data and making DO calibration choice 
btlsum_tbl = btlsum_tbl_AR6903;
btlsum = btlsum_AR6903; 
CTD_sen = btlsum_tbl.CTD_sen(1); % Sensor package to use for calibration; same as bottle processing 
% SOC_type = btlsum_tbl.SOC_type(1); % 1 = constant, % 2 = changes as a function of cruise time % 3 = changes as a function of station number 
%%
downcasts = []; upcasts = []; 
%
cal = cal1; SOC_type = 1; %%% The line to change 
cast_num = cal.casts;
CastStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 
for i = 1:length(cast_num)
        downcasts{cast_num(i)} = process_cast(dcc{cast_num(i)}, mydowncast{cast_num(i)}, CTD_sen, cal, SOC_type, CastStartTime);
        upcasts{cast_num(i)} = process_cast(ucc{cast_num(i)}, myupcast{cast_num(i)}, CTD_sen, cal, SOC_type, CastStartTime);
%         downcasts{cast_num(i)} = process_cast_noCTDcal(mydowncast{cast_num(i)}, CTD_sen, cal, SOC_type, CastStartTime,cast_num(i));
%         upcasts{cast_num(i)} = process_cast_noCTDcal( myupcast{cast_num(i)}, CTD_sen, cal, SOC_type, CastStartTime,cast_num(i));
end

cal = cal2; SOC_type = 2; %%% The line to change 
cast_num = cal.casts;
CastStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 
for i = 1:length(cast_num)
        downcasts{cast_num(i)} = process_cast(dcc{cast_num(i)}, mydowncast{cast_num(i)}, CTD_sen, cal, SOC_type, CastStartTime);
        upcasts{cast_num(i)} = process_cast(ucc{cast_num(i)}, myupcast{cast_num(i)}, CTD_sen, cal, SOC_type, CastStartTime);
end

cal = cal3; SOC_type = 1; %%% The line to change 
cast_num = cal.casts;
CastStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 
for i = 1:length(cast_num)
        downcasts{cast_num(i)} = process_cast(dcc{cast_num(i)}, mydowncast{cast_num(i)}, CTD_sen, cal, SOC_type, CastStartTime);
        upcasts{cast_num(i)} = process_cast(ucc{cast_num(i)}, myupcast{cast_num(i)}, CTD_sen, cal, SOC_type, CastStartTime);
end

cal = cal4; SOC_type = 1; %%% The line to change 
cast_num = cal.casts;
CastStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 
for i = 1:length(cast_num)
        downcasts{cast_num(i)} = process_cast(dcc{cast_num(i)}, mydowncast{cast_num(i)}, CTD_sen, cal, SOC_type, CastStartTime);
        upcasts{cast_num(i)} = process_cast(ucc{cast_num(i)}, myupcast{cast_num(i)}, CTD_sen, cal, SOC_type, CastStartTime);
end

cal = cal5; SOC_type = 2; %%% The line to change 
cast_num = cal.casts;
CastStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 
for i = 1:length(cast_num)
        downcasts{cast_num(i)} = process_cast(dcc{cast_num(i)}, mydowncast{cast_num(i)}, CTD_sen, cal, SOC_type, CastStartTime);
        upcasts{cast_num(i)} = process_cast(ucc{cast_num(i)}, myupcast{cast_num(i)}, CTD_sen, cal, SOC_type, CastStartTime);
end

cal = cal6; SOC_type = 1; %%% The line to change 
cast_num = cal.casts;
CastStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 
for i = 1:length(cast_num) 
    if cast_num(i) ~= 146
        downcasts{cast_num(i)} = process_cast(dcc{cast_num(i)}, mydowncast{cast_num(i)}, CTD_sen, cal, SOC_type, CastStartTime);
        upcasts{cast_num(i)} = process_cast(ucc{cast_num(i)}, myupcast{cast_num(i)}, CTD_sen, cal, SOC_type, CastStartTime);
    end
end

cal = cal7; SOC_type = 2; %%% The line to change 
cast_num = cal.casts(1):214;
CastStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 
for i = 1:length(cast_num)
        downcasts{cast_num(i)} = process_cast(dcc{cast_num(i)}, mydowncast{cast_num(i)}, CTD_sen, cal, SOC_type, CastStartTime);
        upcasts{cast_num(i)} = process_cast(ucc{cast_num(i)}, myupcast{cast_num(i)}, CTD_sen, cal, SOC_type, CastStartTime);
end
%%
%% Change flags to Best Practices Flags
btlsum_tbl.NLMR_Outlier1(btlsum_tbl.NLMR_Outlier1 == 1) = 3;
btlsum_tbl.NLMR_Outlier1(btlsum_tbl.NLMR_Outlier1 == 0) = 2;
btlsum_tbl.NLMR_Outlier1(isnan(btlsum_tbl.Winkler1_umolkg)) = 9;
btlsum_tbl.NLMR_Outlier1(btlsum_tbl.Winkler1_umolkg > 316) = 1;

btlsum_tbl.NLMR_Outlier2(btlsum_tbl.NLMR_Outlier2 == 1) = 3;
btlsum_tbl.NLMR_Outlier2(btlsum_tbl.NLMR_Outlier2 == 0) = 2;
btlsum_tbl.NLMR_Outlier2(isnan(btlsum_tbl.Winkler2_umolkg)) = 9;
btlsum_tbl.NLMR_Outlier2(btlsum_tbl.Winkler2_umolkg > 316) = 1;

btlsum_tbl.NLMR_Outlier3(btlsum_tbl.NLMR_Outlier3 == 1) = 3;
btlsum_tbl.NLMR_Outlier3(btlsum_tbl.NLMR_Outlier3 == 0) = 2;
btlsum_tbl.NLMR_Outlier3(isnan(btlsum_tbl.Winkler3_umolkg)) = 9;
btlsum_tbl.NLMR_Outlier3(btlsum_tbl.Winkler3_umolkg > 316) = 1;

cal_all.casts = [1:145 147:214]; % SIO didn't process Cast 146
cast_num = cal_all.casts;
btlsum = [];
for i = 1:length(cast_num)
        btlsum{cast_num(i)} = btlsum_tbl(btlsum_tbl.Cast == cast_num(i),:); 
end

%% Plot final data
group2 = cal2.casts;
deep_casts = cal_deep.casts;
Winks = unique(btlsum_tbl.Cast);
casts = Winks; 
for i = 1:length(casts)
    plot_calibrated_DO(downcasts{casts(i)},upcasts{casts(i)},btlsum{casts(i)})
end

%%
deep = [2:24 38 70:71 78 86:95 106:107 113:126 133 154:155 196:199 207:210];
cast_num = deep;
for i = 1:length(cast_num)
    plot_calibrated_DO(downcasts{cast_num(i)},upcasts{cast_num(i)},btlsum{cast_num(i)})
end
%% Plot of irminger section 
cast_num_IRM = 2:20; % casts in transect
% cast_num = [125 115 114 123 117 126 92 93 94 91 90 88];% 86 85 105 97 99 103];

% calculate transect distance from first cast in transect 
d = [];
DO = []; DOsat = [];
prs = [];
lon = [];
test = [];
for i = 1:length(cast_num_IRM)
    lon(i) = downcasts{cast_num_IRM(i)}.lon(1);
    DO{i} = downcasts{cast_num_IRM(i)}.DOcorr_umolkg;
    DOsat{i} = downcasts{cast_num_IRM(i)}.DOcorr_umolkg./downcasts{cast_num_IRM(i)}.O2sol_umolkg;
    prs{i} = downcasts{cast_num_IRM(i)}.prs;
    test{i} = downcasts{cast_num_IRM(i)}.pt;
end


figure
transect(lon,prs,DOsat)
ylabel('Pressure (db)')
xlabel('Longitude (\circW)')
title('Irminger Section: Casts 2-20')
c = colorbar;
% cmocean('thermal')
% ylabel(c,'Dissolved Oxygen (\mumol kg^-^1)')
ylabel(c,'Dissolved Oxygen (% sat.)')

%% Plot just casts with Winklers 
run('GeneralSettings.m')
btl_num = unique(btlsum_tbl.Cast);
for i = 1:length(btl_num)
    figure
    plot(downcasts{btl_num(i)}.DOcorr_umolkg,downcasts{btl_num(i)}.prs,'Linewidth',1.4)
    hold on
    plot(upcasts{btl_num(i)}.DOcorr_umolkg,upcasts{btl_num(i)}.prs,'Linewidth',1.4)
%     plot(downcasts{btl_num(i)}.AA_DOcorr_umolkg,downcasts{btl_num(i)}.prs,'Linewidth',1.4,'Color',navy)
%     hold on
%     plot(upcasts{btl_num(i)}.AA_DOcorr_umolkg,upcasts{btl_num(i)}.prs,'Linewidth',1.4,'Color',maroon)
    axis ij
    plot(btlsum{btl_num(i)}.Winkler1_umolkg,btlsum{btl_num(i)}.prs,'.k','MarkerSize',20)
    plot(btlsum{btl_num(i)}.Winkler2_umolkg,btlsum{btl_num(i)}.prs,'.k','MarkerSize',20)
    plot(btlsum{btl_num(i)}.Winkler3_umolkg,btlsum{btl_num(i)}.prs,'.k','MarkerSize',20)
    plot(btlsum{btl_num(i)}.Winkler1_umolkg(btlsum{btl_num(i)}.NLMR_Outlier1 == 3),btlsum{btl_num(i)}.prs(btlsum{btl_num(i)}.NLMR_Outlier1 == 3),'.','MarkerSize',20,'Color',red)
    plot(btlsum{btl_num(i)}.Winkler2_umolkg(btlsum{btl_num(i)}.NLMR_Outlier2 == 3),btlsum{btl_num(i)}.prs(btlsum{btl_num(i)}.NLMR_Outlier2 == 3),'.','MarkerSize',20,'Color',red)
    plot(btlsum{btl_num(i)}.Winkler3_umolkg(btlsum{btl_num(i)}.NLMR_Outlier3 == 3),btlsum{btl_num(i)}.prs(btlsum{btl_num(i)}.NLMR_Outlier3 == 3),'.','MarkerSize',20,'Color',red)
    plot(btlsum{btl_num(i)}.Winkler1_umolkg(btlsum{btl_num(i)}.NLMR_Outlier1 == 1),btlsum{btl_num(i)}.prs(btlsum{btl_num(i)}.NLMR_Outlier1 == 1),'.','MarkerSize',20,'Color',yellow)
    plot(btlsum{btl_num(i)}.Winkler2_umolkg(btlsum{btl_num(i)}.NLMR_Outlier2 == 1),btlsum{btl_num(i)}.prs(btlsum{btl_num(i)}.NLMR_Outlier2 == 1),'.','MarkerSize',20,'Color',yellow)
    plot(btlsum{btl_num(i)}.Winkler3_umolkg(btlsum{btl_num(i)}.NLMR_Outlier3 == 1),btlsum{btl_num(i)}.prs(btlsum{btl_num(i)}.NLMR_Outlier3 == 1),'.','MarkerSize',20,'Color',yellow)
    ax = gca;
    ax.XAxisLocation = 'top';
    ylabel('pressure (db)')
    xlabel('DO (\mumol/kg)')
    title(['Cast: ' num2str(btl_num(i))])
end
%%
%Change folder to BCO-DMO location 
cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\BCO-DMO Submission\GOHSNAP\AR69-03')

%Create metadata file 
    fheader = [sprintf('Filename,Cruise,Station,Down_Up,Lat,Lon,Date (UTC)') newline];
    metadata_file = fopen('metadata_oxygenprofiles.csv','w');
    fprintf(metadata_file,fheader);
    fclose(metadata_file); 

    cast_num = cal_all.casts;
for i = 1:length(cast_num)
    dwn_out = downcasts{cast_num(i)};

    metadata_file = fopen('metadata_oxygenprofiles.csv','a');
    castname_d = ['AR69-03_' sprintf('%03d',cast_num(i)) 'd.csv']; castname_u = ['AR69-03_' sprintf('%03d',cast_num(i)) 'u.csv'];
    cruise = 'AR69-03'; cast = cast_num(i); d = 'd'; u = 'u';
    lat = dwn_out.lat(1); lon = dwn_out.lon(1);
    dt = datestr(dwn_out.StartTimeUTC(1)); 

    fprintf(metadata_file,'%s,%s,%d,%s,%.4f,%.4f,%s\n', castname_d,cruise,cast,d,lat,lon,dt);
    fprintf(metadata_file,'%s,%s,%d,%s,%.4f,%.4f,%s\n', castname_u,cruise,cast,u,lat,lon,dt);
    fclose(metadata_file);
end
%%
for i = 1:length(cast_num)
    dwn_out = downcasts{cast_num(i)};
    
    temp_flag = ones(size(dwn_out.t))*1; % Reset all Temp Flags to 1
%     sal_flag = ones(size(dwn_out.t))*2;
    oxycur_flag = ones(size(dwn_out.t))*2;
    ctdoxy_flag = ones(size(dwn_out.t))*2;
        if cast_num(i) == 37
            indbad = find(dwn_out.prs == 72);
               oxycur_flag(1:indbad) = 3;
               ctdoxy_flag(1:indbad) = 3; 
        end
        if cast_num(i) == 46
            indbad = find(dwn_out.prs == 80);
               oxycur_flag(1:indbad) = 3;
               ctdoxy_flag(1:indbad) = 3; 
        end
        if cast_num(i) == 86
            oxycur_flag = ones(size(dwn_out.t))*3;
            ctdoxy_flag = ones(size(dwn_out.t))*3;
        end
        if cast_num(i) == 116
            indbad = find(dwn_out.prs == 136);
               oxycur_flag(1:indbad) = 3;
               ctdoxy_flag(1:indbad) = 3; 
        end
        if cast_num(i) == 117
            indbad = find(dwn_out.prs == 120);
               oxycur_flag(1:indbad) = 3;
               ctdoxy_flag(1:indbad) = 3; 
        end
        if cast_num(i) == 118
            indbad = find(dwn_out.prs == 38);
               oxycur_flag(1:indbad) = 3;
               ctdoxy_flag(1:indbad) = 3; 
        end
        if cast_num(i) == 119
            indbad = find(dwn_out.prs == 76);
               oxycur_flag(1:indbad) = 3;
               ctdoxy_flag(1:indbad) = 3; 
        end
        if cast_num(i) == 120
            indbad = find(dwn_out.prs == 30);
               oxycur_flag(1:indbad) = 3;
               ctdoxy_flag(1:indbad) = 3; 
        end
        if cast_num(i) == 169
            indbad = find(dwn_out.prs == 240);
               oxycur_flag(indbad:end) = 3;
               ctdoxy_flag(indbad:end) = 3; 
        end
        if cast_num(i) == 176
            indbad = find(dwn_out.prs == 560);
               oxycur_flag(indbad:end) = 3;
               ctdoxy_flag(indbad:end) = 3; 
        end
    dwn_out.oxycur_flag = oxycur_flag;
    dwn_out.ctdoxy_flag = ctdoxy_flag;
    downcasts{cast_num(i)} = dwn_out; 

    fheader = ['AR69-03    Calibrated Oxygen Downcast   Station: ' num2str(cast_num(i)) newline...
    'Latitude: ' sprintf('%.4f',dwn_out.lat(1)) '   Longitude: ' sprintf('%.4f',dwn_out.lon(1))...
    '   ' datestr(dwn_out.StartTimeUTC(1)) newline...
    sprintf('CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
    sprintf('dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 

    fileIDd = fopen(['AR69-03_' sprintf('%03d',cast_num(i)) 'd.csv'],'w');
    fprintf(fileIDd,fheader);
    for ii = 1:length(dwn_out.prs)
        fprintf(fileIDd,'%.1f,%.3f,%d,%.3f,%d,%.4f,%d,%.1f,%d\n', dwn_out.prs(ii),dwn_out.t(ii),dwn_out.temp_flag(ii),dwn_out.SP(ii),dwn_out.sal_flag(ii),dwn_out.oxy_volts(ii),oxycur_flag(ii),dwn_out.DOcorr_umolkg(ii),ctdoxy_flag(ii));
    end
    fclose(fileIDd);
end

for i = 1:length(cast_num)
    up_out = upcasts{cast_num(i)};

    temp_flag = ones(size(up_out.t))*1; % Reset all temp flags to 1 
%     sal_flag = ones(size(up_out.t))*2;
    oxycur_flag = ones(size(up_out.t))*2;
    ctdoxy_flag = ones(size(up_out.t))*2;

        if cast_num(i) == 86
            oxycur_flag = ones(size(up_out.t))*3;
            ctdoxy_flag = ones(size(up_out.t))*3;
        end
    
    up_out.oxycur_flag = oxycur_flag;
    up_out.ctdoxy_flag = ctdoxy_flag;
    upcasts{cast_num(i)} = up_out; 

    fheader = ['AR69-03    Calibrated Oxygen Upcast   Station: ' num2str(cast_num(i)) newline...
    'Latitude: ' sprintf('%.4f',up_out.lat(1)) '   Longitude: ' sprintf('%.4f',up_out.lon(1))...
    '   ' datestr(up_out.StartTimeUTC(1)) newline...
    sprintf('CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
    sprintf('dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 

    fileIDu = fopen(['AR69-03_' sprintf('%03d',cast_num(i)) 'u.csv'],'w');
    fprintf(fileIDu,fheader);
    for ii = 1:length(up_out.prs)
        fprintf(fileIDu,'%.1f,%.3f,%d,%.3f,%d,%.4f,%d,%.1f,%d\n', up_out.prs(ii),up_out.t(ii),up_out.temp_flag(ii),up_out.SP(ii),up_out.sal_flag(ii),up_out.oxy_volts(ii),oxycur_flag(ii),up_out.DOcorr_umolkg(ii),ctdoxy_flag(ii));
    end
    fclose(fileIDu);
end

%%
% plot_calibrated_pTemp(downcasts,upcasts,cal2.casts,btlsum,cal0,'AR69-03')
plot_calibrated_pTemp(downcasts,upcasts,2:20,btlsum,cal_all,'AR69-03 Irminger Section')

%%
plot_calibrated_pTemp(downcasts,upcasts,cast_num,btlsum,cal_all,'AR69-03')

%% Save processed data 
if savefile == 1
    cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\AR69-03')
    btl_num_AR6903 = unique(btlsum_tbl.Cast);
    cast_num_AR6903 = cast_num;
    btlsum_AR6903_tbl = btlsum_tbl;
    btlsum_AR6903 = btlsum;
    dt_Processed_AR6903 = datetime('now'); 
    SBE_caldeep_AR6903 = cal_deep;
    SBE_calall_AR6903 = cal_all;
    SBE_cal1_AR6903 = cal1;
    SBE_cal2_AR6903 = cal2;
    SBE_cal3_AR6903 = cal3;
    SBE_cal4_AR6903 = cal4;
    SBE_cal5_AR6903 = cal5;
    SBE_cal6_AR6903 = cal6;
    SBE_cal7_AR6903 = cal7;
    upcasts_AR6903 = upcasts;
    downcasts_AR6903 = downcasts; 
    
    save AR6903_Processed_KF.mat upcasts_* downcasts_* btl_num_* cast_num_* SBE_cal* btlsum_* btlsum_tbl_* dt_Processed_*
end
%%
% for i = 1:length(btl_num)
%     btl_out = btlsum{btl_num(i)};
% 
%     index1 = max(~(isnan(btl_out.Winkler_umolkg)));
% %     btl_out.NLMR_Outlier(isnan(btl_out.Winkler_umolkg)) = 9; % This was
% %     already done in DOcal file 
% %     btl_out.NLMR_Outlier(btl_out.NLMR_Outlier == 1) = 3; 
% %     btl_out.NLMR_Outlier(btl_out.NLMR_Outlier == 0) = 2;
%     btl_out.Winkler_umolkg(isnan(btl_out.Winkler_umolkg)) = -999;
% 
%     temp_flag = ones(size(btl_out.t))*1; % Not evaluated 
%     sal_flag = ones(size(btl_out.t))*1;
%     oxycur_flag = ones(size(btl_out.t))*2; % Acceptable 
%     ctdoxy_flag = ones(size(btl_out.t))*2;
% 
%     data =  [btl_out.Bottle,btl_out.prs,btl_out.t,temp_flag,btl_out.SP,sal_flag,btl_out.oxy_volts,oxycur_flag,btl_out.DOcorr_umolkg,ctdoxy_flag,...
%         btl_out.Winkler_umolkg,btl_out.NLMR_Outlier];
% 
%     if index1 == 1
%         fheader = ['AR21    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
%         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag, Oxygen, Oxygen_flag') newline...
%         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a., umol/kg, n.a.') newline];
%         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d,%.1f,%d\n';
%         data_format = data(:,1:end);
%     else
%         fheader = ['AR21    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
%         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
%         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 
%         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n';
%         data_format = data(:,1:end-2);
%     end
% 
%     fileID = fopen(['AR21_' sprintf('%03d',btl_num(i)) 'btl.csv'],'w');
%     fprintf(fileID,fheader);
%         for ii = 1:length(btl_out.Bottle)
%             fprintf(fileID,string_format, data_format(ii,:));
%         end
%     fclose(fileID);
% end

%% Reads in my processed casts 
function cast = my_cast(cast)
    cast0 = cast;
    castnum = str2num(cast.source(10:12));
    fields = {'source','DataFileType','instrumentheaders','userheaders','vars','longname','units','span','mvars','mvars_format'...
        'scan','nbin','flag','SeasaveVersion','softwareheaders','t090C','t190C','c0mScm','c1mScm'};
    cast = rmfield(cast,fields);
    cast = struct2table(cast);
    cast.Properties.VariableNames = {'CastTimeS','prs','depth','oxy_volts','lat','lon'};
    cast.oxy_volts(cast.oxy_volts == -9.9900e-29) = NaN; % replaces no data flag with NaN
    cast.StartTimeUTC = ones(length(cast.CastTimeS),1)*datenum(cast0.instrumentheaders.SystemUTC); 
    cast.StartTimeUTC = datetime(cast.StartTimeUTC,'ConvertFrom','datenum');
    cast.CastTimeUTC = cast.StartTimeUTC + cast.CastTimeS/3600/24;
    cast.Station = ones(length(cast.prs),1)*castnum; 
    cast.CTDcal(:) = {'True'};
    cast.CTDcal = string(cast.CTDcal);
end
%% Read in SIO Casts 
function CTDSIO = import_sio(nc_fn)
    %%
    GPSLAT = ncread(nc_fn,'GPSLAT');
    GPSLON = ncread(nc_fn,'GPSLON');
    prs = ncread(nc_fn,'CTDPRS');
    CTDTMP1 = ncread(nc_fn,'CTDTMP1');
    CTDTMP2 = ncread(nc_fn,'CTDTMP2');
    CTDTMP_FLAG = ncread(nc_fn,'CTDTMP_FLAG_W');
    CTDSAL = ncread(nc_fn,'CTDSAL');
    CTDSAL_FLAG = ncread(nc_fn,'CTDSAL_FLAG_W');
    CTDOXY_SIO_umolkg = ncread(nc_fn,'CTDOXY_SIO');
    CTDOXY1_mLL = ncread(nc_fn,'CTDOXY1');
    CTDOXYVOLTS = ncread(nc_fn,'CTDOXYVOLTS');
    CTDOXY_FLAG = ncread(nc_fn,'CTDOXY_FLAG_W');
    
    CTDSIO = table(GPSLAT,GPSLON,prs,CTDTMP1,CTDTMP2,CTDTMP_FLAG,CTDSAL,CTDSAL_FLAG,CTDOXY_SIO_umolkg,CTDOXY1_mLL,CTDOXYVOLTS,CTDOXY_FLAG); 
end

%% Combines Files and calibrate oxygen data

function cast = process_cast(sio_cast,mycast,CTD_sen,cal,SOC_type,CruiseStartTime)
%     
%     % Combine tables by prs variable 
%     if height(mycast) <= height(leah_cast)
%         cast = join(mycast,leah_cast,'Keys','prs');
%     else 
%         cast = join(leah_cast,mycast,'Keys','prs');
%     end
    cast = innerjoin(mycast,sio_cast); 

    % Decide if using primary or secondary CTD sensor for temp and sal
    if CTD_sen == 1 % primary sensor (use unless something wrong with data)
        cast.t = cast.CTDTMP1; 
        cast.SP = cast.CTDSAL; 
     end
    
    if CTD_sen == 2 % secondary sensor (use if primary sensor bad)
        cast.t = cast.CTDTMP2; 
        cast.SP = cast.sal; 
    end  

    cast.temp_flag = cast.CTDTMP_FLAG;
    cast.sal_flag = cast.CTDSAL_FLAG;

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
%     vars = {'Station','prs','lat','lon','CastTimeS','CastTimeUTC','StartTimeUTC','cruise_d','CTDcal',...
%         'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','DOcorr_umolkg','O2sol_umolkg','SOC_type',...
%         'CTDOXY_SIO_umolkg','CTDOXY1_mLL','CTDOXYVOLTS','CTDOXY_FLAG'};
    vars = {'Station','prs','lat','lon','CastTimeS','CastTimeUTC','StartTimeUTC','cruise_d','CTDcal',...
        'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','DOcorr_umolkg','O2sol_umolkg','SOC_type',...
        'temp_flag','sal_flag'};
    cast = cast(:,vars); 
    
end


function plot_calibrated_DO(downcasts,upcasts,btlsum)
navy = [0.078431     0.16863     0.54902];
maroon = [0.63529    0.078431     0.18431];
grey = [0.5     0.5     0.5];
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
        plot(btlsum.Winkler1_umolkg,btlsum.prs,'ok','MarkerFaceColor','k') 
        plot(btlsum.Winkler2_umolkg,btlsum.prs,'ok','MarkerFaceColor','k') 
        plot(btlsum.Winkler3_umolkg,btlsum.prs,'ok','MarkerFaceColor','k') 
        axis ij
        ylabel('Pressure (db)')
        xlabel('Oxygen (\mumol kg^-^1)')
        ax = gca;
        ax.XAxisLocation = 'top';
        sgtitle(['Cast ' num2str(downcasts.Station(1))])
    end

end

function plot_calibrated_pTemp(downcasts,upcasts,cast_num,btlsum,cal,TitleString)
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
    plot(downcasts{cast_num(i)}.lon(1),downcasts{cast_num(i)}.lat(1),'.','Markersize',20)
    hold on
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
    plot(downcasts{cast_num(i)}.DOcorr_umolkg,downcasts{cast_num(i)}.pt,'Linewidth',1.2)
    hold on
end
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Downcasts')
grid on

subplot(1,3,3)
for i = 1:length(cast_num)
    plot(upcasts{cast_num(i)}.DOcorr_umolkg,upcasts{cast_num(i)}.pt,'Linewidth',1.2)
    hold on
end

for i = 1:length(cast_num)
    try
        plot(btlsum{cast_num(i)}.Winkler1_umolkg(btlsum{cast_num(i)}.NLMR_Outlier1 == 2),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier1 == 2),'.k','markersize',20)
        plot(btlsum{cast_num(i)}.Winkler2_umolkg(btlsum{cast_num(i)}.NLMR_Outlier2 == 2),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier2 == 2),'.k','markersize',20)
        plot(btlsum{cast_num(i)}.Winkler3_umolkg(btlsum{cast_num(i)}.NLMR_Outlier3 == 2),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier3 == 2),'.k','markersize',20)
    catch
        disp('No Winklers for Cast')
    end
end

% plot(Winklers_in,btlsum.pt,'.','markersize',20,'Color',red)

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
    plot(downcasts{cast_num(i)}.DOcorr_umolkg(downcasts{cast_num(i)}.ctdoxy_flag == 2),downcasts{cast_num(i)}.pt(downcasts{cast_num(i)}.ctdoxy_flag == 2),'Linewidth',1,'Color',blue)
end
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Downcasts')
grid on

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
        plot(upcasts{cast_num(i)}.DOcorr_umolkg(upcasts{cast_num(i)}.ctdoxy_flag == 2),upcasts{cast_num(i)}.pt(upcasts{cast_num(i)}.ctdoxy_flag == 2),'Linewidth',1,'Color',blue)
end

for i = 1:length(cast_num)
        try
            plot(btlsum{cast_num(i)}.Winkler1_umolkg(btlsum{cast_num(i)}.NLMR_Outlier1 == 1),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier1 == 1),'.','markersize',20,'Color',yellow)
            plot(btlsum{cast_num(i)}.Winkler1_umolkg(btlsum{cast_num(i)}.NLMR_Outlier1 == 3),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier1 == 3),'.','markersize',20,'Color',red)
            plot(btlsum{cast_num(i)}.Winkler1_umolkg(btlsum{cast_num(i)}.NLMR_Outlier1 == 2),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier1 == 2),'.k','markersize',20)
            
            plot(btlsum{cast_num(i)}.Winkler2_umolkg(btlsum{cast_num(i)}.NLMR_Outlier2 == 1),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier2 == 1),'.','markersize',20,'Color',yellow)
            plot(btlsum{cast_num(i)}.Winkler2_umolkg(btlsum{cast_num(i)}.NLMR_Outlier2 == 3),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier2 == 3),'.','markersize',20,'Color',red)
            plot(btlsum{cast_num(i)}.Winkler2_umolkg(btlsum{cast_num(i)}.NLMR_Outlier2 == 2),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier2 == 2),'.k','markersize',20)
            
            
            plot(btlsum{cast_num(i)}.Winkler3_umolkg(btlsum{cast_num(i)}.NLMR_Outlier3 == 1),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier3 == 1),'.','markersize',20,'Color',yellow)
            plot(btlsum{cast_num(i)}.Winkler3_umolkg(btlsum{cast_num(i)}.NLMR_Outlier3 == 3),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier3 == 3),'.','markersize',20,'Color',red)
            plot(btlsum{cast_num(i)}.Winkler3_umolkg(btlsum{cast_num(i)}.NLMR_Outlier3 == 2),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier3 == 2),'.k','markersize',20)
        catch 
            disp('No Winklers for Cast')
        end
end



ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on
sgtitle(TitleString)
legend('Uncalibrated','Calibrated','Not Evaluated Winklers','Questionable Winklers','Acceptable Winklers','Location','NW')

end