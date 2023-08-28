% Set up workspace 
clearvars
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
addpath(genpath('G:\My Drive\Matlab_work\Github\optode-response-time-Gordon'))
run('GeneralSettings.m')
%% 
% Combine Leah's processed cast files with my processed cast files 
% Casts binned in 1 db bins 
% Read in processed casts
% Processed with 0 sec DO alignment and SBE default hysteresis, SOC, and E term
% 
ns = 10;
ne = 12;

dc_dir = 'C:\Users\fogaren\Documents\SBE\Year6\downcasts';
uc_dir = 'C:\Users\fogaren\Documents\SBE\Year6\upcasts';
leah_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year6\Final_From_Leah';

savefile = 0; % savefile == 1 for saving; savefile == 0, don't save 
% Casts 
% Aanderaa added to rosette before Cast 3 
% (Removed cnvs and dcc/ucc for 1 and 2)

% Downcasts 
cd(dc_dir)
files = ls('*.cnv');
cast_num = str2num(files(:,ns:ne)); % Pulls out cast numbers 

mydowncast = []; % Read all my processed SBE cast into matlab 
for i = 1:length(cast_num)
    mydowncast{cast_num(i)} = readSBScnv(files(i,:)); %change so that i references cast number not file length number 
end

% Upcasts 
cd(uc_dir)
files = ls('*.cnv');

myupcast = []; % Read all my processed SBE cast into matlab 
for i = 1:length(cast_num)
    myupcast{cast_num(i)} = readSBScnv(files(i,:));
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
    dcc{cast_num(i)} = import_dcc(downfiles(i,:));
end

ucc = [];
for i = 1:length(cast_num)
    ucc{cast_num(i)} = import_dcc(upfiles(i,:));
end

%% Combine my files with Leah's files 
downcasts = []; upcasts =[]; 
for i = 1:length(cast_num)
    downcasts{cast_num(i)} = combine_CTD_files_Aanderaa(dcc{cast_num(i)},mydowncast{cast_num(i)});
    upcasts{cast_num(i)} = combine_CTD_files_Aanderaa(ucc{cast_num(i)},myupcast{cast_num(i)});
end

%% Create bottle summary file with Leah's calibrated bottle file

addpath('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Bottle_Files\Year6');

addpath('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year6\Final_From_Leah');
gpath('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year6')

btl = readtable('Irminger_Sea-06_AR35-05_Discrete_Summary_KF_June2023','TextType','string');
btl.Cast = double(btl.Cast); btl.Bottle = double(btl.Bottle);
btl.Winkler1_mLL = double(btl.Winkler1_mLL);
btl.Winkler2_mLL = double(btl.Winkler2_mLL);
btl.Winkler3_mLL = double(btl.Winkler3_mLL);
btl.Winkler4_mLL = double(btl.Winkler4_mLL);
btl.Discrete_Salinity_psu = double(btl.Discrete_Salinity_psu);

btlsum11 = btl(btl.Cast == 11,:);
btlsum12 = btl(btl.Cast == 12,:);
btlsum13 = btl(btl.Cast == 13,:);

btlsum11 = combine_btl_files_Aanderaa('ar35-05_011.cbot_so','ar35-05011.csv',btlsum11);
btlsum12 = combine_btl_files_Aanderaa('ar35-05_012.cbot_so','ar35-05012.csv',btlsum12);
btlsum13 = combine_btl_files_Aanderaa('ar35-05_013.cbot_so','ar35-05013.csv',btlsum13);

btlsum0 = [btlsum11; btlsum12; btlsum13];
btl_num = unique(btlsum0.Cast); % Find cast numbers with btl samples

btlsum_tbl = btlsum0; 
btlsum = [];
for i = 1:length(btl_num)
    btlsum{btl_num(i)} = btlsum0(btlsum0.Cast == btl_num(i),:);
end
%%
% CTD_sen = 2; 
% prs_lim = [50 500];
% 
% Gordon2020 = []; 
% for i = 1:length(cast_num)
%     [ Gordon2020{cast_num(i)}] = Aanderaa_timelag_calc(downcasts{cast_num(i)}, upcasts{cast_num(i)},prs_lim,CTD_sen);
% end
% 
% thickness = [];
% tau_Tref = [];
% for i = 1:length(cast_num)
%     figure(100)
%     plot(Gordon2020{cast_num(i)}.thickness_constants,Gordon2020{cast_num(i)}.rmsd)
%     hold on
%     grid on
%     ylabel('RMSD')
%     xlabel('thickness (\mum)')
%     thickness = [thickness; Gordon2020{cast_num(i)}.thickness];
%     tau_Tref = [tau_Tref; Gordon2020{cast_num(i)}.tau_Tref];
% end
% 
% mean(thickness)
% median(thickness)
%% Convert to oxygen concentration and calculate Aanderaa gain 
% Checked KF
% From Aanderaa calibration file for SN 502 
CTD_sen = 2; 
AA502.foilcoeff = [2.82567E-3 1.20716E-4 2.4593E-6 2.30757E2 -3.09502E-1 -5.60627E1 4.5615E0];
AA502.conccoeff = [-1.285961 1.039998];
AA502.salset = 0;  % salinity set at 0  
btlsum{13}.prs(1) = floor(btlsum{13}.prs(1)); % Need to round down for deepest bin 
% Above cell takes a long time to run
% round(mean(thickness)) = 20; % if don't want to run above cell 
for i = 1:length(cast_num)
    [ downcasts{cast_num(i)}, upcasts{cast_num(i)}, btlsum{cast_num(i)}] = ...
        Aanderaa_gain_calc(downcasts{cast_num(i)}, upcasts{cast_num(i)},...
        btlsum{cast_num(i)},CTD_sen,20,AA502); 
end

%%

btlgain = [];
prsgain = []; 
for i = 1:length(btl_num)
    gain = [btlsum{btl_num(i)}.Aanderaa_gain1; btlsum{btl_num(i)}.Aanderaa_gain2;...
        btlsum{btl_num(i)}.Aanderaa_gain3; btlsum{btl_num(i)}.Aanderaa_gain4];
    prs = [btlsum{btl_num(i)}.prs; btlsum{btl_num(i)}.prs;...
        btlsum{btl_num(i)}.prs; btlsum{btl_num(i)}.prs];
    btlgain = [btlgain; gain];
    prsgain = [prsgain; prs];
end
%%
gain_mean = nanmean(btlgain(prsgain > 500 & btlgain < 1.04)) % Removed three outliers 
gain_std = nanstd(btlgain(prsgain > 500 & btlgain < 1.04))

gain502 = gain_mean;
%%
for i = 1:length(cast_num)
    [ downcasts{cast_num(i)}, upcasts{cast_num(i)}, btlsum{cast_num(i)}] = ...
        Aanderaa_gain_cast(downcasts{cast_num(i)}, upcasts{cast_num(i)},...
        btlsum{cast_num(i)},mean(gain502),cast_num(i)); 
end
%%
btlsum_tbl = [];
for i = 1:length(btl_num)
    btlsum_tbl = [btlsum_tbl; btlsum{btl_num(i)}];
end
%%
AAresid = [btlsum_tbl.Winkler1_umolkg(btlsum_tbl.prs > 500) - btlsum_tbl.DOcorr_umolkg(btlsum_tbl.prs > 500); btlsum_tbl.Winkler2_umolkg(btlsum_tbl.prs > 500) - btlsum_tbl.DOcorr_umolkg(btlsum_tbl.prs > 500); 
btlsum_tbl.Winkler3_umolkg(btlsum_tbl.prs > 500) - btlsum_tbl.DOcorr_umolkg(btlsum_tbl.prs > 500); btlsum_tbl.Winkler4_umolkg(btlsum_tbl.prs > 500) - btlsum_tbl.DOcorr_umolkg(btlsum_tbl.prs > 500)];

%%
f = figure;
f.Position = [100 100 840 500];
subplot(2,2,1)
plot(btlsum_tbl.prs,btlsum_tbl.Winkler1_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20); hold on
plot(btlsum_tbl.prs,btlsum_tbl.Winkler2_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20)
plot(btlsum_tbl.prs,btlsum_tbl.Winkler3_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20)
plot(btlsum_tbl.prs,btlsum_tbl.Winkler4_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20)
%     plot(btlsum_tbl.prs,btlsum_tbl.Winkler5_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20)
hold on; grid on
ylim([-10 10])
ylabel({'Residual, Winkler - Aanderaa','(\mumol/kg)'}); xlabel('Pressure (db)')

subplot(2,2,2)
plot(btlsum_tbl.Cast,btlsum_tbl.Winkler1_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20); hold on 
plot(btlsum_tbl.Cast,btlsum_tbl.Winkler2_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20)
plot(btlsum_tbl.Cast,btlsum_tbl.Winkler3_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20)
plot(btlsum_tbl.Cast,btlsum_tbl.Winkler4_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20)    
%     plot(btlsum_tbl.Cast,btlsum_tbl.Winkler5_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20)    
hold on; grid on; ylim([-10 10])
ylabel({'Residual, Winkler - Aanderaa','(\mumol/kg)'}); xlabel('Station Number')

subplot(2,2,3)
plot(btlsum_tbl.t,btlsum_tbl.Winkler1_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20); hold on
plot(btlsum_tbl.t,btlsum_tbl.Winkler2_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20)
plot(btlsum_tbl.t,btlsum_tbl.Winkler3_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20)
plot(btlsum_tbl.t,btlsum_tbl.Winkler4_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20)
%     plot(btlsum_tbl.t,btlsum_tbl.Winkler5_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20)
hold on; grid on; ylim([-10 10])
ylabel({'Residual, Winkler - Aanderaa','(\mumol/kg)'}); xlabel('Temperature (\circC)')

subplot(2,2,4)
plot(btlsum_tbl.Winkler1_umolkg,btlsum_tbl.Winkler1_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20); hold on
plot(btlsum_tbl.Winkler2_umolkg,btlsum_tbl.Winkler2_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20)
plot(btlsum_tbl.Winkler3_umolkg,btlsum_tbl.Winkler3_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20)
plot(btlsum_tbl.Winkler4_umolkg,btlsum_tbl.Winkler4_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20)
%     plot(btlsum_tbl.Aanderaa_spcorr_umolkg,btlsum_tbl.Winkler5_umolkg - btlsum_tbl.DOcorr_umolkg,'.k','Markersize',20)
hold on; grid on; ylim([-10 10])
ylabel({'Residual, Winkler - Aanderaa','(\mumol/kg)'}); xlabel('Winkler DO (\mumol/kg)')


sgtitle('Year 6 AR35-05: Aanderaa Residuals')

%%
plot_calibrated_pTemp(downcasts,upcasts,btlsum,cast_num)
%%
cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year6')
clear btlsum0 gain_mean gain_std
btlsum_tbl_yr6 = btlsum_tbl;
btlsum_yr6 = btlsum; 
downcasts_yr6 = downcasts;
upcasts_yr6 = upcasts;
dt_Processed_yr6 = datetime;
btl_num_yr6 = btl_num;
cast_num_yr6 = cast_num;

clear btlsum btlsum_tbl btl_num cast_num upcasts downcasts

save Year6_Processed_KF btlsum_* downcasts* upcasts* cast* btl_num* dt_Processed*
%%
% %% Comment out so that files aren't accidently overwritten.
% %  Certain files have had flags manually changed in excel. 
% cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\BCO-DMO Submission\AR35-05')
% for i = 1:length(cast_num)
%     dwn_out = downcasts{cast_num(i)};
%     
%     if cast_num(i) < 11
%         temp_flag = ones(size(dwn_out.t))*3;
%         sal_flag = ones(size(dwn_out.t))*3;
%         oxycur_flag = ones(size(dwn_out.t))*3;
%         ctdoxy_flag = ones(size(dwn_out.t))*3;
%     end
% 
%     if cast_num(i) >= 11
%         temp_flag = ones(size(dwn_out.t))*2;
%         sal_flag = ones(size(dwn_out.t))*2;
%         oxycur_flag = ones(size(dwn_out.t))*3;
%         ctdoxy_flag = ones(size(dwn_out.t))*3;
%     end
% 
%     fheader = ['AR35-05    Calibrated Oxygen Downcast   Station: ' num2str(cast_num(i)) newline...
%     'Latitude: ' sprintf('%.4f',dwn_out.lat(1)) '   Longitude: ' sprintf('%.4f',dwn_out.lon(1))...
%     '   ' datestr(dwn_out.StartTimeUTC(1)) newline...
%     sprintf('CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, AAOXYCUR, AAOXYCUR_flag, AAOXY, AAOXY_flag') newline...
%     sprintf('dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 
% 
%     fileIDd = fopen(['AR35-05_' sprintf('%03d',cast_num(i)) 'd.csv'],'w');
%     fprintf(fileIDd,fheader);
%     for ii = 1:length(dwn_out.prs)
%         fprintf(fileIDd,'%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n', dwn_out.prs(ii),dwn_out.t(ii),temp_flag(ii),dwn_out.SP(ii),sal_flag(ii),dwn_out.Aanderaa_volts(ii),oxycur_flag(ii),dwn_out.DOcorr_umolkg(ii),ctdoxy_flag(ii));
%     end
%     fclose(fileIDd);
% end
% 
% for i = 1:length(cast_num)
%     up_out = upcasts{cast_num(i)};
% 
%     if cast_num(i) < 11
%         temp_flag = ones(size(up_out.t))*3;
%         sal_flag = ones(size(up_out.t))*3;
%         oxycur_flag = ones(size(up_out.t))*3;
%         ctdoxy_flag = ones(size(up_out.t))*3;
%     end
% 
%     if cast_num(i) >= 11
%         temp_flag = ones(size(up_out.t))*2;
%         sal_flag = ones(size(up_out.t))*2;
%         oxycur_flag = ones(size(up_out.t))*3;
%         ctdoxy_flag = ones(size(up_out.t))*3;
%     end
% 
%     fheader = ['AR35-05    Calibrated Oxygen Upcast   Station: ' num2str(cast_num(i)) newline...
%     'Latitude: ' sprintf('%.4f',up_out.lat(1)) '   Longitude: ' sprintf('%.4f',up_out.lon(1))...
%     '   ' datestr(up_out.StartTimeUTC(1)) newline...
%     sprintf('CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, AAOXYCUR, AAOXYCUR_flag, AAOXY, AAOXY_flag') newline...
%     sprintf('dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 
% 
%     fileIDu = fopen(['AR35-05_' sprintf('%03d',cast_num(i)) 'u.csv'],'w');
%     fprintf(fileIDu,fheader);
%     for ii = 1:length(up_out.prs)
%         fprintf(fileIDd,'%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n', up_out.prs(ii),up_out.t(ii),temp_flag(ii),up_out.SP(ii),sal_flag(ii),up_out.Aanderaa_volts(ii),oxycur_flag(ii),up_out.DOcorr_umolkg(ii),ctdoxy_flag(ii));
%     end
%     fclose(fileIDu);
% end
% %%
% 
% cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\BCO-DMO Submission\AR35-05')
% for i = 1:length(btl_num)
%     btl_out = btlsum{btl_num(i)};
% %     index1 = max(~(isnan(btl_out.Winkler1_umolkg)));
% %     index2 = max(~(isnan(btl_out.Winkler1_umolkg) | isnan(btl_out.Winkler2_umolkg)));
% %     index3 = max(~(isnan(btl_out.Winkler1_umolkg) | isnan(btl_out.Winkler2_umolkg) | isnan(btl_out.Winkler3_umolkg)));
% %     index4 = max(~(isnan(btl_out.Winkler1_umolkg) | isnan(btl_out.Winkler2_umolkg) | isnan(btl_out.Winkler3_umolkg)| isnan(btl_out.Winkler4_umolkg)));
%     
%     btl_out.Aanderaa_gain1(btl_out.Aanderaa_gain1 > 1.04) = 3; 
%     btl_out.Aanderaa_gain1(btl_out.prs < 500) = 1;
%     btl_out.Aanderaa_gain1(btl_out.prs > 500) = 2;
%     btl_out.Aanderaa_gain1(isnan(btl_out.Winkler1_umolkg)) = 9;
%     btl_out.Winkler1_umolkg(isnan(btl_out.Winkler1_umolkg)) = -999;
%     
%     btl_out.Aanderaa_gain2(btl_out.Aanderaa_gain2 > 1.04) = 3; 
%     btl_out.Aanderaa_gain2(btl_out.prs > 500) = 2;
%     btl_out.Aanderaa_gain2(btl_out.prs < 500) = 1;
%     btl_out.Aanderaa_gain2(isnan(btl_out.Winkler2_umolkg)) = 9;
%     btl_out.Winkler2_umolkg(isnan(btl_out.Winkler2_umolkg)) = -999;
% 
%     btl_out.Aanderaa_gain3(btl_out.Aanderaa_gain3 > 1.04) = 3; 
%     btl_out.Aanderaa_gain3(btl_out.prs > 500) = 2;
%     btl_out.Aanderaa_gain3(btl_out.prs < 500) = 1;
%     btl_out.Aanderaa_gain3(isnan(btl_out.Winkler3_umolkg)) = 9;
%     btl_out.Winkler3_umolkg(isnan(btl_out.Winkler3_umolkg)) = -999;
% 
%     btl_out.Aanderaa_gain4(btl_out.Aanderaa_gain4 > 1.04) = 3; 
%     btl_out.Aanderaa_gain4(btl_out.prs > 500) = 2;
%     btl_out.Aanderaa_gain4(btl_out.prs < 500) = 1;
%     btl_out.Aanderaa_gain4(isnan(btl_out.Winkler4_umolkg)) = 9;
%     btl_out.Winkler4_umolkg(isnan(btl_out.Winkler4_umolkg)) = -999;
% % 
%     temp_flag = ones(size(btl_out.t))*2;
%     sal_flag = ones(size(btl_out.t))*2;
%     oxycur_flag = ones(size(btl_out.t))*3;
%     ctdoxy_flag = ones(size(btl_out.t))*3;
% 
%     data =  [btl_out.Bottle,btl_out.prs,btl_out.t,temp_flag,btl_out.SP,sal_flag,btl_out.Aanderaa_volts,oxycur_flag,btl_out.DOcorr_umolkg,ctdoxy_flag,...
%         btl_out.Winkler1_umolkg,btl_out.Aanderaa_gain1,btl_out.Winkler2_umolkg,btl_out.Aanderaa_gain2,btl_out.Winkler3_umolkg,btl_out.Aanderaa_gain3];
% 
% %     if index1 + index2 + index3 + index4 == 4
% %         fheader = ['AR35-05    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
% %         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, AAOXYCUR, AAOXYCUR_flag, AAOXY, AAOXY_flag, Oxygen1, Oxygen1_flag, Oxygen2, Oxygen2_flag, Oxygen3, Oxygen3_flag, Oxygen4, Oxygen4_flag') newline...
% %         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a., umol/kg, n.a., umol/kg, n.a., umol/kg, n.a., umol/kg, n.a.') newline];
% %         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d,%.1f,%d,%.1f,%d,%.1f,%d,%.1f,%d\n';
% %         data_format = data;    
% %     elseif index1 + index2 + index3 == 3
%         fheader = ['AR35-05    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
%         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, AAOXYCUR, AAOXYCUR_flag, AAOXY, AAOXY_flag, Oxygen1, Oxygen1_flag, Oxygen2, Oxygen2_flag, Oxygen3, Oxygen3_flag') newline...
%         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a., umol/kg, n.a., umol/kg, n.a., umol/kg, n.a.') newline];
%         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d,%.1f,%d,%.1f,%d,%.1f,%d\n';
%         data_format = data;
% %     elseif index1 + index2 + index3 == 2
% %         fheader = ['AR35-05    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
% %         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, AAOXYCUR, AAOXYCUR_flag, AAOXY, AAOXY_flag, Oxygen1, Oxygen1_flag, Oxygen2, Oxygen2_flag') newline...
% %         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a., umol/kg, n.a., umol/kg, n.a.') newline];   
% %         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d,%.1f,%d,%.1f,%d\n';
% %         data_format = data(:,1:end-4);
% %     elseif index1 + index2 + index3 == 1
% %         fheader = ['AR35-05    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
% %         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, AAOXYCUR, AAOXYCUR_flag, AAOXY, AAOXY_flag, Oxygen1, Oxygen1_flag') newline...
% %         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a., umol/kg, n.a.') newline];
% %         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d,%.1f,%d\n';
% %         data_format = data(:,1:end-6);
% %     else
% %         fheader = ['AR35-05    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
% %         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, AAOXYCUR, AAOXYCUR_flag, AAOXY, AAOXY_flag, CTDOXY, CTDOXY_flag') newline...
% %         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 
% %         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n';
% %         data_format = data(:,1:end-8);
% %     end
% 
%     fileID = fopen(['AR35-05_' sprintf('%03d',btl_num(i)) 'btl.csv'],'w');
%     fprintf(fileID,fheader);
%         for ii = 1:length(btl_out.Bottle)
%             fprintf(fileID,string_format, data_format(ii,:));
%         end
%     fclose(fileID);
% end

%%
function [cast,cast0] = combine_CTD_files_Aanderaa(leah_cast,cast)

    % Format structure for conversion to table and convert to table 
    fields = {'woce','date','time','oxcr','ox','oxumkg','tran','flu','alt'};
    leah_cast = rmfield(leah_cast,fields);
    leah_cast.station = leah_cast.station.*ones(length(leah_cast.prs),1);
    leah_cast.lat = leah_cast.lat.*ones(length(leah_cast.prs),1);
    leah_cast.lon = leah_cast.lon.*ones(length(leah_cast.prs),1);
    leah_cast = struct2table(leah_cast);
    leah_cast.Properties.VariableNames = {'station','lat','lon','prs','temp1','temp2','sal1','sal2'};
    
    % Format structure for conversion to table and convert to table 
    cast0 = cast;
    fields = {'source','DataFileType','instrumentheaders','userheaders','vars','longname','units','span','mvars','mvars_format'...
        'scan','sbeox0V','lat','lon','nbin','flag','SeasaveVersion','softwareheaders'};
    cast = rmfield(cast,fields);
    cast = struct2table(cast);
    cast.Properties.VariableNames = {'CastTimeS','prs','depth','t1','t2','cond1','cond2','Aanderaa_volts'};
    cast.StartTimeUTC = ones(length(cast.CastTimeS),1)*datenum(cast0.instrumentheaders.SystemUTC); 
    cast.StartTimeUTC = datetime(cast.StartTimeUTC,'ConvertFrom','datenum');
    cast.CastTimeUTC = cast.StartTimeUTC + cast.CastTimeS/3600/24;
    cast.CTDcal(:) = {'True'};
    cast.CTDcal = string(cast.CTDcal);
    cast = cast(:,{'prs','depth','Aanderaa_volts','CastTimeS','CastTimeUTC','StartTimeUTC','CTDcal'});  

    % Combine tables by prs variable 
%     cast = join(leah_cast,cast,'Keys','prs');  
    cast = join(cast,leah_cast,'Keys','prs');
end

function [btlsum] = combine_btl_files_Aanderaa(leah_btl_file,btl_file,btlsum)

    % Format structure for conversion to table and convert to table 
    leah_btl = readtable(leah_btl_file,'FileType','text');
        if width(leah_btl) == 15
            leah_btl.Properties.VariableNames = {'Bottle','prs','temp1','temp2','th168','th268','sal1','sal2','CTDoxy_mLL_nohyst','CTDoxy_umolkg_nohyst','flur_mgm3','tran','Meas_SAL','Meas_DO_mLL','QUAL'};
            leah_btl = leah_btl(:,{'Bottle','prs','temp1','temp2','sal1','sal2','Meas_SAL','Meas_DO_mLL'});
        end
    leah_btl.Meas_SAL(leah_btl.Meas_SAL == -9) = NaN; % replaces no data flag with NaN
    leah_btl.Meas_DO_mLL(leah_btl.Meas_DO_mLL == -9) = NaN; % replaces no data flag with NaN
    
    % Format structure for conversion to table and convert to table 
    btl = readtable(btl_file,'TextType','string');
    btl = btl(:,{'Bottle','Date','PrDM','DepSM','Latitude','Longitude','Sbeox0V','V6'});
    btl.Properties.VariableNames = {'Bottle','Date','PrDM','depth','lat','lon','oxy_volts','Aanderaa_volts'};
    btl.CTDcal(:) = {'True'};
    btl.CTDcal = string(btl.CTDcal);
    
    % Combine tables by Bottle variable 
    btlsum0 = join(leah_btl,btl,'Keys','Bottle');
    btlsum = join(btlsum0,btlsum,'Keys','Bottle');
    
end

function [ Gordon2020 ] = Aanderaa_timelag_calc(castd,castu,zlim,CTD_sen)
                        % Create NaN array that is length of longer cast (upcast vs downcast) 
        if length(castu.CastTimeS) >= length(castd.CastTimeS)
            timeS = NaN(2,length(castu.CastTimeS));
        end
        
        if length(castu.CastTimeS) < length(castd.CastTimeS)
            timeS = NaN(2,length(castd.CastTimeS));
        end     
    
    % Create other same-size arrays 
    DO = timeS;
    z = timeS;
    temp = timeS;

        if CTD_sen == 1
            temp(1,1:length(castd.CastTimeS)) = castd.temp1; % Temp sensor chosen when processing CTD files 
            temp(2,1:length(castu.CastTimeS)) = castu.temp1;
        end 
    
        if CTD_sen == 2
            temp(1,1:length(castd.CastTimeS)) = castd.temp2; % Temp sensor chosen when processing CTD files 
            temp(2,1:length(castu.CastTimeS)) = castu.temp2; 
        end
      
    % Fill in downcast/upcast TIME, DO, TEMP
    timeS(1,1:length(castd.CastTimeS)) = datenum(castd.CastTimeUTC);
    timeS(2,1:length(castu.CastTimeS)) = datenum(castu.CastTimeUTC);
    
    DO(1,1:length(castd.CastTimeS)) = castd.Aanderaa_volts; 
    DO(2,1:length(castu.CastTimeS)) = castu.Aanderaa_volts; 

    % Calculate timelag in pressure space 
    pres = z; 

    pres(1,1:length(castd.CastTimeS)) = castd.prs;
    pres(2,1:length(castu.CastTimeS)) = castu.prs;
    zres = 1;

    [ thickness, tau_Tref , thickness_constants, rmsd] = calculate_tau_wTemp( timeS, pres, DO, temp,'zlim', zlim,'zres',zres,'Tref',4);

    Gordon2020.thickness = thickness;
    Gordon2020.tau_Tref = tau_Tref;
    Gordon2020.thickness_constants = thickness_constants;
    Gordon2020.rmsd = rmsd;

end

function [ castd, castu, btlsum ] = Aanderaa_gain_calc(castd,castu,btlsum,CTD_sen,calc_thickness,AA)

        if CTD_sen == 1
            castd.t = castd.temp1; castu.t = castu.temp1;
            castd.SP = castd.sal1; castu.SP = castu.sal1;
            if height(btlsum) ~= 0
                btlsum.t = btlsum.temp1; 
                btlsum.SP = btlsum.sal1; 
            end
        end 
    
        if CTD_sen == 2
            castd.t = castd.temp2; castu.t = castu.temp2;
            castd.SP = castd.sal2; castu.SP = castu.sal2; 
            if height(btlsum) ~= 0
                btlsum.t = btlsum.temp2; 
                btlsum.SP = btlsum.sal2; 
            end
        end

    % Calculate other parameters of interest for downcast 
    castd.SA = gsw_SA_from_SP(castd.SP,castd.prs,castd.lon,castd.lat);
    castd.CT = gsw_CT_from_t(castd.SA,castd.t,castd.prs);
    castd.pt = gsw_pt_from_CT(castd.SA,castd.CT);  
    castd.rho = gsw_rho_CT_exact(castd.SA,castd.CT,castd.prs); % in situ density
    castd.prho = gsw_rho_CT_exact(castd.SA,castd.CT,0); % potential density with ref == surf
    castd.sigma0 = gsw_sigma0_CT_exact(castd.SA,castd.CT); % cast.prho - 1000 = cast.sigma0
    castd.CTD_sen = ones(length(castd.prs),1)*CTD_sen; 
    castd.CTDcal(:) = {'True'}; 
    castd.CTDcal = string(castd.CTDcal);
      
    % Calculate other parameters of interest for upcast 
    castu.SA = gsw_SA_from_SP(castu.SP,castu.prs,castu.lon,castu.lat);
    castu.CT = gsw_CT_from_t(castu.SA,castu.t,castu.prs);
    castu.pt = gsw_pt_from_CT(castu.SA,castu.CT);  
    castu.rho = gsw_rho_CT_exact(castu.SA,castu.CT,castu.prs); % in situ density
    castu.prho = gsw_rho_CT_exact(castu.SA,castu.CT,0); % potential density with ref == surf
    castu.sigma0 = gsw_sigma0_CT_exact(castu.SA,castu.CT); % cast.prho - 1000 = cast.sigma0
    castu.CTD_sen = ones(length(castu.prs),1)*CTD_sen; 
    castu.CTDcal(:) = {'True'}; 
    castu.CTDcal = string(castu.CTDcal);

    % Call correct_oxygen_profile_wTemp to output Oxygen data [volts] corrected for timelag    
    indd = ~(isnan(datenum(castd.CastTimeUTC)) | isnan(castd.Aanderaa_volts) | isnan(castd.t));
    indu = ~(isnan(datenum(castu.CastTimeUTC)) | isnan(castu.Aanderaa_volts) | isnan(castu.t));
    
    [ castd.Aanderaa_volts_lagcorr ] = correct_oxygen_profile_wTemp(datenum(castd.CastTimeUTC(indd)), castd.Aanderaa_volts(indd), castd.t(indd)', calc_thickness );
    [ castu.Aanderaa_volts_lagcorr ] = correct_oxygen_profile_wTemp(datenum(castu.CastTimeUTC(indu)), castu.Aanderaa_volts(indu), castu.t(indu)', calc_thickness );

     A = 10; B = 12; %note that this should be the same for all optodes
    castd.Aanderaa_volts_lagcorr_sm = smoothdata(castd.Aanderaa_volts_lagcorr,'movmean',9,'omitnan');
%     Calculate uncalibrated oxygen concentration for downcasts 
    castd.Aanderaa_calphase = B.*castd.Aanderaa_volts_lagcorr_sm + A; 
    [optode_uM, ~] = aaoptode_sternvolmer(AA.foilcoeff, castd.Aanderaa_calphase, castd.t, castd.SP, castd.prs);    
    optode_uM = AA.conccoeff(1) + AA.conccoeff(2).*optode_uM;
    castd.Aanderaa_spcorr_umolkg = aaoptode_salpresscorr(optode_uM, castd.t, castd.SP, castd.prs, AA.salset);
    
    castu.Aanderaa_volts_lagcorr_sm = smoothdata(castu.Aanderaa_volts_lagcorr,'movmean',9,'omitnan');
%     Calculate uncalibrated oxygen concentration for upcasts 
    castu.Aanderaa_calphase = B.*castu.Aanderaa_volts_lagcorr_sm + A; 
    [optode_uM, ~] = aaoptode_sternvolmer(AA.foilcoeff, castu.Aanderaa_calphase, castu.t, castu.SP, castu.prs);    
    optode_uM = AA.conccoeff(1) + AA.conccoeff(2).*optode_uM;
    castu.Aanderaa_spcorr_umolkg = aaoptode_salpresscorr(optode_uM, castu.t, castu.SP, castu.prs, AA.salset);   

    % Reorder variables and remove unnecessary ones
    vars = {'prs','depth','lat','lon','temp1','temp2','sal1','sal2','CastTimeS','CastTimeUTC','StartTimeUTC','CTDcal',...
        'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','Aanderaa_volts','Aanderaa_volts_lagcorr','Aanderaa_volts_lagcorr_sm',...
        'Aanderaa_calphase','Aanderaa_spcorr_umolkg'};
    

    castu = castu(:,vars);
    castd = castd(:,vars); 

        if height(btlsum) ~= 0
                
            btlsum.CTD_sen = ones(length(btlsum.prs),1)*CTD_sen; 
            btlsum.SA = gsw_SA_from_SP(btlsum.SP,btlsum.prs,btlsum.lon,btlsum.lat);
            btlsum.CT = gsw_CT_from_t(btlsum.SA,btlsum.t,btlsum.prs);
            btlsum.pt = gsw_pt_from_CT(btlsum.SA,btlsum.CT); 
            btlsum.rho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,btlsum.prs); % in situ density
            btlsum.prho = gsw_rho_CT_exact(btlsum.SA,btlsum.CT,0); % potential density with ref == surf
            btlsum.sigma0 = gsw_sigma0_CT_exact(btlsum.SA,btlsum.CT); % btlsum.prho - 1000 = btlsum.sigma0
            btlsum.Winkler1_umolkg = btlsum.Winkler1_mLL*1000*44.661./btlsum.prho; % uses potential density 
            btlsum.Winkler2_umolkg = btlsum.Winkler2_mLL*1000*44.661./btlsum.prho;
            btlsum.Winkler3_umolkg = btlsum.Winkler3_mLL*1000*44.661./btlsum.prho;
            btlsum.Winkler4_umolkg = btlsum.Winkler4_mLL*1000*44.661./btlsum.prho;

      % Find bottle value at specific depth using lag corrected upcast 
            ind = [];
            for i = 1:length(btlsum.prs)
                [ind(i),~] = find(round(btlsum.prs(i)) == castu.prs);
            end

            btlsum.Aanderaa_spcorr_umolkg = castu.Aanderaa_spcorr_umolkg(ind);
      % Calculate gain from Winkler over Aanderaa lag/sal/press corrected values
            btlsum.Aanderaa_gain1 = btlsum.Winkler1_umolkg./btlsum.Aanderaa_spcorr_umolkg;
            btlsum.Aanderaa_gain2 = btlsum.Winkler2_umolkg./btlsum.Aanderaa_spcorr_umolkg;
            btlsum.Aanderaa_gain3 = btlsum.Winkler3_umolkg./btlsum.Aanderaa_spcorr_umolkg;   
            btlsum.Aanderaa_gain4 = btlsum.Winkler4_umolkg./btlsum.Aanderaa_spcorr_umolkg;
            % Reorder variables and remove unnecessary ones
            btlvars = {'Bottle','Date','prs','depth','lat','lon','temp1','temp2','sal1','sal2','Discrete_Salinity_psu','Cruise','Asset','Cast','CTDcal',...
                'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','Winkler1_mLL','Winkler2_mLL','Winkler3_mLL','Winkler4_mLL',...
                'Winkler1_umolkg','Winkler2_umolkg','Winkler3_umolkg','Winkler4_umolkg','Aanderaa_volts','Aanderaa_spcorr_umolkg',...
                'Aanderaa_gain1','Aanderaa_gain2','Aanderaa_gain3','Aanderaa_gain4'};
            btlsum = btlsum(:,btlvars);
        end
    
        if height(btlsum) == 0
            btlsum = 'No Discrete Samples';
        end
end

function [castd, castu, btlsum] = Aanderaa_gain_cast(castd,castu,btlsum,gain,cast_num)
temp_sal_plots = 1; 

castd.DOcorr_umolkg = castd.Aanderaa_spcorr_umolkg*gain;
castu.DOcorr_umolkg = castu.Aanderaa_spcorr_umolkg*gain;

% Bottle gain correction
if height(btlsum ) ~= 1
    btlsum.DOcorr_umolkg = btlsum.Aanderaa_spcorr_umolkg.*gain; 
end

    if height(btlsum) == 1 && temp_sal_plots == 0
         
        figure
        plot(castd.DOcorr_umolkg,castd.prs,'Linewidth',1.2)
        hold on
        plot(castu.DOcorr_umolkg,castu.prs,'Linewidth',1.2)
        axis ij
        ylabel('Pressure (db)')
        xlabel('Oxygen (\mumol kg^-^1)')
        ax = gca;
        ax.XAxisLocation = 'top';
        legend('Downcast','Upcast','Location','SW')
        title(['Cast ' num2str(cast_num)])
    end
    
    if height(btlsum) == 1 && temp_sal_plots == 1

        figure
        subplot(1,3,1)
        plot(castd.DOcorr_umolkg,castd.prs,'Linewidth',1.2)
        hold on
        plot(castu.DOcorr_umolkg,castu.prs,'Linewidth',1.2)
        axis ij
        ylabel('Pressure (db)')
        xlabel('Oxygen (\mumol kg^-^1)')
        ax = gca;
        ax.XAxisLocation = 'top';
        sgtitle(['Cast ' num2str(cast_num)])

        subplot(1,3,2)
        plot(castd.t,castd.prs,'Linewidth',1.2)
        hold on
        plot(castu.t,castu.prs,'Linewidth',1.2)
        axis ij
        ylabel('Pressure (db)')
        xlabel('Temperature (\circC)')
        ax = gca;
        ax.XAxisLocation = 'top';
        
        subplot(1,3,3)
        plot(castd.SP,castd.prs,'Linewidth',1.2)
        hold on
        plot(castu.SP,castu.prs,'Linewidth',1.2)
        axis ij
        ylabel('Pressure (db)')
        xlabel('Practical Salinity')
        ax = gca;
        ax.XAxisLocation = 'top';
        legend('Downcast','Upcast','Location','SW')
    end
            
    if height(btlsum) ~= 1 && temp_sal_plots == 0 
        
        figure
        plot(castd.DOcorr_umolkg,castd.prs,'Linewidth',1.2)
        hold on
        plot(castu.DOcorr_umolkg,castu.prs,'Linewidth',1.2)
        plot(btlsum.Winkler1_umolkg,btlsum.prs,'.','MarkerSize',20)
        plot(btlsum.Winkler2_umolkg,btlsum.prs,'.','MarkerSize',20)
        plot(btlsum.Winkler3_umolkg,btlsum.prs,'.','MarkerSize',20)
        plot(btlsum.Winkler4_umolkg,btlsum.prs,'.','MarkerSize',20)
        axis ij
        ylabel('Pressure (db)')
        xlabel('Oxygen (\mumol kg^-^1)')
        ax = gca;
        ax.XAxisLocation = 'top';
        legend('Downcast','Upcast','Bottle','Location','SW')
        title(['Cast ' num2str(cast_num)])
    end
        
    if height(btlsum) ~= 1 && temp_sal_plots == 1 
        
        figure
        subplot(1,3,1)
        plot(movmean(castd.DOcorr_umolkg,20),castd.prs,'Linewidth',1.2)
        hold on
        plot(movmean(castu.DOcorr_umolkg,20),castu.prs,'Linewidth',1.2)
        plot(btlsum.Winkler1_umolkg,btlsum.prs,'.','MarkerSize',20)
        plot(btlsum.Winkler2_umolkg,btlsum.prs,'.','MarkerSize',20)
        plot(btlsum.Winkler3_umolkg,btlsum.prs,'.','MarkerSize',20)
        plot(btlsum.Winkler4_umolkg,btlsum.prs,'.','MarkerSize',20)
        axis ij
        ylabel('Pressure (db)')
        xlabel('Oxygen (\mumol kg^-^1)')
        ax = gca;
        ax.XAxisLocation = 'top';
        sgtitle(['Cast ' num2str(cast_num)])

        subplot(1,3,2)
        plot(castd.t,castd.prs,'Linewidth',1.2)
        hold on
        plot(castu.t,castu.prs,'Linewidth',1.2)
        axis ij
        ylabel('Pressure (db)')
        xlabel('Temperature (\circC)')
        ax = gca;
        ax.XAxisLocation = 'top';
        
        subplot(1,3,3)
        plot(castd.SP,castd.prs,'Linewidth',1.2)
        hold on
        plot(castu.SP,castu.prs,'Linewidth',1.2)
        plot(btlsum.Discrete_Salinity_psu,btlsum.prs,'ok','MarkerFaceColor','k')
        axis ij
        ylabel('Pressure (db)')
        xlabel('Practical Salinity')
        ax = gca;
        ax.XAxisLocation = 'top';
        legend('Downcast','Upcast','Bottle','Location','SW')
    end
end


function plot_calibrated_pTemp(downcasts,upcasts,btlsum,cast_num)
% For plotting purposes 
ooi_latlon = [59.9341, -39.4673
    59.8177, -39.8412
    59.7155, -39.3148];
grey = [0.5     0.5     0.5];
blue = [0     0.44706     0.74118];

figure
subplot(1,3,1)
for i = 1:length(cast_num)
    plot(downcasts{cast_num(i)}.lon(1),downcasts{cast_num(i)}.lat(1),'.','Markersize',20)
    hold on
end
plot(ooi_latlon(:,2),ooi_latlon(:,1),'^','markersize',8,'MarkerFaceColor','k',...
    'MarkerEdgeColor','k')
xlabel('Longitude (\circ)')
ylabel('Latitude (\circ)')
daspect([1 1 1]); grid on
try
    sgtitle(num2str(btlsum{cast_num(i)}))
end

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
        plot(btlsum{cast_num(i)}.Winkler1_umolkg,btlsum{cast_num(i)}.pt,'.k','markersize',20)
    end
end

ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on
sgtitle(btlsum{cast_num(end)}.Cruise(1))

f = figure;
f.Position = [100 100 840 500];
subplot(1,2,1)
for i = 1:length(cast_num)
    plot(downcasts{cast_num(i)}.Aanderaa_spcorr_umolkg,downcasts{cast_num(i)}.pt,'Linewidth',1,'Color',grey)
    hold on
    plot(downcasts{cast_num(i)}.DOcorr_umolkg,downcasts{cast_num(i)}.pt,'Linewidth',1,'Color',blue)
end
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Downcasts')
grid on

subplot(1,2,2)
red = [0.85098     0.32549    0.098039];
yellow = [0.92941     0.69412     0.12549];
plot(NaN,NaN,'Color',grey)
hold on
plot(NaN,NaN,'Color',blue)
plot(NaN,NaN,'.','MarkerSize',20,'Color',yellow)
plot(NaN,NaN,'.','MarkerSize',20,'Color',red)
plot(NaN,NaN,'.k','markersize',20)

for i = 1:length(cast_num)
    plot(upcasts{cast_num(i)}.Aanderaa_spcorr_umolkg,upcasts{cast_num(i)}.pt,'Linewidth',1,'Color',grey)
    hold on
    plot(upcasts{cast_num(i)}.DOcorr_umolkg,upcasts{cast_num(i)}.pt,'Linewidth',1,'Color',blue)
end

if cast_num(i) == 11 || 12|| 13
        plot(btlsum{cast_num(i)}.Winkler1_umolkg(btlsum{cast_num(i)}.prs > 500),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.prs > 500),'.k','markersize',20); hold on
        plot(btlsum{cast_num(i)}.Winkler2_umolkg(btlsum{cast_num(i)}.prs > 500),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.prs > 500),'.k','markersize',20)
        plot(btlsum{cast_num(i)}.Winkler3_umolkg(btlsum{cast_num(i)}.prs > 500),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.prs > 500),'.k','markersize',20);
        plot(btlsum{cast_num(i)}.Winkler4_umolkg(btlsum{cast_num(i)}.prs > 500),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.prs > 500),'.k','markersize',20);
        
        plot(btlsum{cast_num(i)}.Winkler1_umolkg(btlsum{cast_num(i)}.prs <= 500),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.prs <= 500),'.','Color',yellow,'markersize',20); hold on
        plot(btlsum{cast_num(i)}.Winkler2_umolkg(btlsum{cast_num(i)}.prs <= 500),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.prs <= 500),'.','Color',yellow,'markersize',20)
        plot(btlsum{cast_num(i)}.Winkler3_umolkg(btlsum{cast_num(i)}.prs <= 500),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.prs <= 500),'.','Color',yellow,'markersize',20);
        plot(btlsum{cast_num(i)}.Winkler4_umolkg(btlsum{cast_num(i)}.prs <= 500),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.prs <= 500),'.','Color',yellow,'markersize',20);
end

if cast_num(i) == 13

        plot(btlsum{cast_num(i)}.Winkler1_umolkg(btlsum{cast_num(i)}.Bottle == 2),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.Bottle == 2),'.','Color',red,'markersize',20); hold on
        plot(btlsum{cast_num(i)}.Winkler2_umolkg(btlsum{cast_num(i)}.Bottle == 2),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.Bottle == 2),'.','Color',red,'markersize',20)
        plot(btlsum{cast_num(i)}.Winkler3_umolkg(btlsum{cast_num(i)}.Bottle == 2),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.Bottle == 2),'.','Color',red,'markersize',20);
        plot(btlsum{cast_num(i)}.Winkler4_umolkg(btlsum{cast_num(i)}.Bottle == 2),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.Bottle == 2),'.','Color',red,'markersize',20);
end

ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on
legend('Uncalibrated','Calibrated','Not Evaluated Winklers','Questionable Winklers','Acceptable Winklers','Location','NE')
sgtitle('Year 6: AR35-05')

end