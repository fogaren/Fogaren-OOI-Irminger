
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
addpath(genpath('G:\My Drive\Matlab_work\Github\GSW-Matlab'))
addpath(genpath('G:\My Drive\Matlab_work\Github\cmocean'))

dc_dir = 'C:\Users\fogaren\Desktop\Irminger_2024\AR84_02\CTDdata\raw\downcasts';
uc_dir = 'C:\Users\fogaren\Desktop\Irminger_2024\AR84_02\CTDdata\raw\upcasts';
leah_dir = 'C:\Users\fogaren\Desktop\Irminger_2024\AR84_02\CTDdata\final_salinity_cal_2db';
% bco_dmo = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\BCO-DMO Submission\AR84-02';
savefile = 0; % savefile == 1 for saving; savefile == 0, don't save 
%% Read in my processed casts 

% Downcasts 
cd(dc_dir)
files = ls('*.cnv');
cast_num = str2num(files(:,10:12)); % Pulls out cast numbers 

mydowncast = []; % Read all my processed SBE cast into matlab 
for j = 1:length(cast_num)
    dcnv_in = readSBScnv(files(j,:));
    mydowncast{cast_num(j)} = my_cast(dcnv_in); %change so that j references cast number not file length number 
end

% Upcasts 
cd(uc_dir)
files = ls('*.cnv');

myupcast = []; % Read all my processed SBE cast into matlab 
for j = 1:length(cast_num)
    ucnv_in = readSBScnv(files(j,:));
    myupcast{cast_num(j)} = my_cast(ucnv_in);
end
%% Make sure Leah's cast numbers match my cast numbers

cd(leah_dir)
downfiles = ls('*.dcc'); % List of Leah's calibrated cast files 
downcasts = str2num(downfiles(:,9:11)); % Pulls out cast numbers  

upfiles = ls('*.ucc');
upcasts = str2num(upfiles(:,9:11));

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
downfiles = ls('*.dcc'); % List of Leah's calibrated cast files 
upfiles = ls('*.ucc');

dcc = []; % Read Leah's calibrated SBE casts into matlab 
for j = 1:length(cast_num)
    dcc_in = import_dcc(downfiles(j,:));
    dcc{cast_num(j)} = leah_cast(dcc_in); 
end

ucc = [];
for j = 1:length(cast_num)
    ucc_in = import_dcc(upfiles(j,:));
    ucc{cast_num(j)} = leah_cast(ucc_in);
end

%% Combine and calibrate DO for Casts Read in bottle data and making DO calibration choice 
btlsum_tbl = btlsum_AR69_01;
CTD_sen = btlsum_tbl.CTD_sen(1); % Sensor package to use for calibration; same as bottle processing 
% 1 = constant, % 2 = changes as a function of cruise time % 3 = changes as a function of station number 

% btlsum_tbl = calibrate_CTD_oxygen(btlsum_tbl,cal,SOC_type);

CruiseStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 
%% 
% btlsum = []; 
SOC_type = 1; 
downcasts = []; upcasts = []; 
for j = 1:length(cast_num)
        % btlsum{cast_num(j)} = btlsum_tbl(btlsum_tbl.Cast == cast_num(j),:); 
        downcasts{cast_num(j)} = process_cast(dcc{cast_num(j)}, mydowncast{cast_num(j)}, cal, SOC_type, CruiseStartTime);
        upcasts{cast_num(j)} = process_cast(ucc{cast_num(j)}, myupcast{cast_num(j)},  cal, SOC_type, CruiseStartTime);
end
%%
cd('G:\My Drive\Matlab_work\BC\')
run('GeneralSettings.m')
for j = 1:length(cast_num)
    figure(1)
    clf
    plot(downcasts{cast_num(j)}.DOcorr_umolkg1,downcasts{cast_num(j)}.prs,'Linewidth',1.3,'Color',blue)
    hold on
    plot(downcasts{cast_num(j)}.DOcorr_umolkg2,downcasts{cast_num(j)}.prs,'Linewidth',1.3,'Color',navy)
    plot(upcasts{cast_num(j)}.DOcorr_umolkg1,upcasts{cast_num(j)}.prs,'Linewidth',1.3,'Color',red)
    plot(upcasts{cast_num(j)}.DOcorr_umolkg2,upcasts{cast_num(j)}.prs,'Linewidth',1.3,'Color',maroon)
    if ~isempty(btlsum{cast_num(j)})
        plot(btlsum{cast_num(j)}.Winkler1_umolkg1,btlsum{cast_num(j)}.prs,'.k','MarkerSize',30)
        plot(btlsum{cast_num(j)}.Winkler2_umolkg1,btlsum{cast_num(j)}.prs,'.k','MarkerSize',30)
    end
    axis ij; grid on
    pause
    
end


%% Plot final data
for j = 1:length(cast_num)
    plot_calibrated_DO(downcasts{cast_num(j)},upcasts{cast_num(j)},btlsum{cast_num(j)})
end
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
for j = 1:length(cast_num)
        btlsum{cast_num(j)} = btlsum_tbl(btlsum_tbl.Cast == cast_num(j),:); 
end
%% Save processed data 
if savefile == 1

    btlsum_AR69_01 = btlsum;
    btlsum_AR69_01_tbl = btlsum_tbl; 
    upcasts_AR69_01 = upcasts;
    downcasts_AR69_01 = downcasts;
    btl_num_AR69_01 = btl_num;
    cast_num_AR69_01 = cast_num;
    SBE_cal_AR69_01 = cal; 
    dt_KF_Processed_AR69_01 = datetime('now');
    clear btlsum_tbl
    cd(dir)
    save AR69-01_DO_Processed_KF.mat upcasts_* downcasts_* btl_num_* cast_num_* SBE_cal_* btlsum_* dt_KF_Processed_*
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
% %Change folder to BCO-DMO location 
% 
% cd(bco_dmo)
% for i = 1:length(cast_num)
%     dwn_out = downcasts{cast_num(i)};
%     
%     temp_flag = ones(size(dwn_out.t))*2;
%     sal_flag = ones(size(dwn_out.t))*2;
%     oxycur_flag = ones(size(dwn_out.t))*2;
%     ctdoxy_flag = ones(size(dwn_out.t))*2;
% 
%     fheader = ['AR69-01    Calibrated Oxygen Downcast   Station: ' num2str(cast_num(i)) newline...
%     'Latitude: ' sprintf('%.4f',dwn_out.lat(1)) '   Longitude: ' sprintf('%.4f',dwn_out.lon(1))...
%     '   ' datestr(dwn_out.StartTimeUTC(1)) newline...
%     sprintf('CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
%     sprintf('dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 
% 
%     fileIDd = fopen(['AR69-01_' sprintf('%03d',cast_num(i)) 'd.csv'],'w');
%     fprintf(fileIDd,fheader);
%     for ii = 1:length(dwn_out.prs)
%         fprintf(fileIDd,'%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n', dwn_out.prs(ii),dwn_out.t(ii),temp_flag(ii),dwn_out.SP(ii),sal_flag(ii),dwn_out.oxy_volts(ii),oxycur_flag(ii),dwn_out.DOcorr_umolkg(ii),ctdoxy_flag(ii));
%     end
%     fclose(fileIDd);
% end
% 
% for i = 1:length(cast_num)
%     up_out = upcasts{cast_num(i)};
% 
%     temp_flag = ones(size(up_out.t))*2;
%     sal_flag = ones(size(up_out.t))*2;
%     oxycur_flag = ones(size(up_out.t))*2;
%     ctdoxy_flag = ones(size(up_out.t))*2;
% 
%     fheader = ['AR69-01    Calibrated Oxygen Upcast   Station: ' num2str(cast_num(i)) newline...
%     'Latitude: ' sprintf('%.4f',up_out.lat(1)) '   Longitude: ' sprintf('%.4f',up_out.lon(1))...
%     '   ' datestr(up_out.StartTimeUTC(1)) newline...
%     sprintf('CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
%     sprintf('dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 
% 
%     fileIDu = fopen(['AR69-01_' sprintf('%03d',cast_num(i)) 'u.csv'],'w');
%     fprintf(fileIDu,fheader);
%     for ii = 1:length(up_out.prs)
%         fprintf(fileIDd,'%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n', up_out.prs(ii),up_out.t(ii),temp_flag(ii),up_out.SP(ii),sal_flag(ii),up_out.oxy_volts(ii),oxycur_flag(ii),up_out.DOcorr_umolkg(ii),ctdoxy_flag(ii));
%     end
%     fclose(fileIDu);
% end
% 
% %%
% for i = 1:length(btl_num)
%     btl_out = btlsum{btl_num(i)};
%     index1 = max(~(isnan(btl_out.Winkler1_umolkg(:))));
%     index2 = max(~(isnan(btl_out.Winkler1_umolkg(:)) | isnan(btl_out.Winkler2_umolkg(1))));
%     index3 = max(~(isnan(btl_out.Winkler1_umolkg(1)) | isnan(btl_out.Winkler2_umolkg(1)) | isnan(btl_out.Winkler3_umolkg(1))));
%     
%     btl_out.NLMR_Outlier1(isnan(btl_out.Winkler1_umolkg)) = 9;
%     btl_out.NLMR_Outlier1(btl_out.NLMR_Outlier1 == 1) = 3; % Or should this be 4?
%     btl_out.NLMR_Outlier1(btl_out.NLMR_Outlier1 == 0) = 2;
%     btl_out.Winkler1_umolkg(isnan(btl_out.Winkler1_umolkg)) = -999;
%     
%     btl_out.NLMR_Outlier2(isnan(btl_out.Winkler2_umolkg)) = 9;
%     btl_out.NLMR_Outlier2(btl_out.NLMR_Outlier2 == 1) = 3; % Or should this be 4?
%     btl_out.NLMR_Outlier2(btl_out.NLMR_Outlier2 == 0) = 2;
%     btl_out.Winkler2_umolkg(isnan(btl_out.Winkler2_umolkg)) = -999;
% 
%     btl_out.NLMR_Outlier3(isnan(btl_out.Winkler3_umolkg)) = 9;
%     btl_out.NLMR_Outlier3(btl_out.NLMR_Outlier3 == 1) = 3; % Or should this be 4?
%     btl_out.NLMR_Outlier3(btl_out.NLMR_Outlier3 == 0) = 2;
%     btl_out.Winkler3_umolkg(isnan(btl_out.Winkler3_umolkg)) = -999;
% 
%     temp_flag = ones(size(btl_out.t))*2;
%     sal_flag = ones(size(btl_out.t))*2;
%     oxycur_flag = ones(size(btl_out.t))*2;
%     ctdoxy_flag = ones(size(btl_out.t))*2;
% 
%     data =  [btl_out.Bottle,btl_out.prs,btl_out.t,temp_flag,btl_out.SP,sal_flag,btl_out.oxy_volts,oxycur_flag,btl_out.DOcorr_umolkg,ctdoxy_flag,...
%         btl_out.Winkler1_umolkg,btl_out.NLMR_Outlier1,btl_out.Winkler2_umolkg,btl_out.NLMR_Outlier2,btl_out.Winkler3_umolkg,btl_out.NLMR_Outlier3];
% 
%     if index1 + index2 + index3 == 3
%         fheader = ['AR69-01    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
%         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag, Oxygen1, Oxygen1_flag, Oxygen2, Oxygen2_flag, Oxygen3, Oxygen3_flag') newline...
%         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a., umol/kg, n.a., umol/kg, n.a., umol/kg, n.a.') newline];
%         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d,%.1f,%d,%.1f,%d,%.1f,%d\n';
%         data_format = data;
%     elseif index1 + index2 + index3 == 2
%         fheader = ['AR69-01    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
%         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag, Oxygen1, Oxygen1_flag, Oxygen2, Oxygen2_flag') newline...
%         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a., umol/kg, n.a., umol/kg, n.a.') newline];   
%         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d,%.1f,%d,%.1f,%d\n';
%         data_format = data(:,1:end-2);
%     elseif index1 + index2 + index3 == 1
%         fheader = ['AR69-01    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
%         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag, Oxygen1, Oxygen1_flag') newline...
%         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a., umol/kg, n.a.') newline];
%         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d,%.1f,%d\n';
%         data_format = data(:,1:end-4);
%     else
%         fheader = ['AR69-01    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
%         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
%         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 
%         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n';
%         data_format = data(:,1:end-6);
%     end
% 
%     fileID = fopen(['AR69-01_' sprintf('%03d',btl_num(i)) 'btl.csv'],'w');
%     fprintf(fileID,fheader);
%         for ii = 1:length(btl_out.Bottle)
%             fprintf(fileID,string_format, data_format(ii,:));
%         end
%     fclose(fileID);
% end

%% Reads in my processed casts 
function cast = my_cast(cast)
    cast0 = cast;
    fields = {'source','DataFileType','instrumentheaders','userheaders','vars','longname','units','span','mvars','mvars_format'...
        'scan','lat','lon','nbin','flag','SeasaveVersion','softwareheaders','t090C','t190C','c0mScm','c1mScm'};
    cast = rmfield(cast,fields);
    cast = struct2table(cast);
    cast.Properties.VariableNames = {'CastTimeS','prs','depth','oxy_volts1','oxy_volts2'};
    cast.oxy_volts1(cast.oxy_volts1 == -9.9900e-29) = NaN; % replaces no data flag with NaN
    cast.oxy_volts2(cast.oxy_volts2 == -9.9900e-29) = NaN; % replaces no data flag with NaN
    cast.StartTimeUTC = ones(length(cast.CastTimeS),1)*datenum(cast0.instrumentheaders.SystemUTC); 
    cast.StartTimeUTC = datetime(cast.StartTimeUTC,'ConvertFrom','datenum');
    cast.CastTimeUTC = cast.StartTimeUTC + cast.CastTimeS/3600/24;
    cast.CTDcal(:) = "True";
end

%% Read in Leah's calibrated casts 
function leah_cast = leah_cast(leah_cast)

    fields = {'woce','date','time','ox','oxumkg','ox2','oxumkg','ox2umkg','tran','flu','alt'};
    leah_cast = rmfield(leah_cast,fields);
    leah_cast.station = leah_cast.station.*ones(length(leah_cast.prs),1);
    leah_cast.lat = leah_cast.lat.*ones(length(leah_cast.prs),1);
    leah_cast.lon = leah_cast.lon.*ones(length(leah_cast.prs),1);
    leah_cast = struct2table(leah_cast);
    leah_cast.Properties.VariableNames = {'Station','lat','lon','prs','temp1','temp2','sal1','sal2','oxcr1','oxcr2'};    
end

%% Combines Files and calibrate oxygen data

function cast = process_cast(leah_cast,mycast,cal,SOC_type,CruiseStartTime)
%     
%     % Combine tables by prs variable 
%     if height(mycast) <= height(leah_cast)
%         cast = join(mycast,leah_cast,'Keys','prs');
%     else 
%         cast = join(leah_cast,mycast,'Keys','prs');
%     end
    cast = innerjoin(mycast,leah_cast); 
  
    cast.t1 = cast.temp1; 
    cast.SP1 = cast.sal1; 
    cast.t2 = cast.temp2; 
    cast.SP2 = cast.sal2; 

    % Calculate other parameters of interest for downcast 
    cast.SA1 = gsw_SA_from_SP(cast.SP1,cast.prs,cast.lon,cast.lat);
    cast.CT1 = gsw_CT_from_t(cast.SA1,cast.t1,cast.prs);
    cast.pt1 = gsw_pt_from_CT(cast.SA1,cast.CT1);  
    cast.O2sol_umolkg1 = gsw_O2sol(cast.SA1,cast.CT1,cast.prs,cast.lon,cast.lat);
    cast.rho1 = gsw_rho_CT_exact(cast.SA1,cast.CT1,cast.prs); % in situ density
    cast.prho1 = gsw_rho_CT_exact(cast.SA1,cast.CT1,0); % potential density with ref == surf
    cast.sigma01 = gsw_sigma0_CT_exact(cast.SA1,cast.CT1); % cast.prho - 1000 = cast.sigma0 

    cast.SA2 = gsw_SA_from_SP(cast.SP2,cast.prs,cast.lon,cast.lat);
    cast.CT2 = gsw_CT_from_t(cast.SA2,cast.t2,cast.prs);
    cast.pt2 = gsw_pt_from_CT(cast.SA2,cast.CT2);  
    cast.O2sol_umolkg2 = gsw_O2sol(cast.SA2,cast.CT2,cast.prs,cast.lon,cast.lat);
    cast.rho2 = gsw_rho_CT_exact(cast.SA2,cast.CT2,cast.prs); % in situ density
    cast.prho2 = gsw_rho_CT_exact(cast.SA2,cast.CT2,0); % potential density with ref == surf
    cast.sigma02 = gsw_sigma0_CT_exact(cast.SA2,cast.CT2); % cast.prho - 1000 = cast.sigma0 

    % cast.CTD_sen = ones(length(cast.prs),1)*CTD_sen; 
    cast.cruise_d = datenum(cast.StartTimeUTC) - datenum(CruiseStartTime); % Cruise time in days 
% Primary Sensor     
    if SOC_type == 0 % Seabird factory calibration
        
        x1 = [cast.oxcr1,cast.O2sol_umolkg1,cast.t1,cast.prs];
    
        % SBE functional form without SOC drift 
        cast.DOcorr_umolkg1 = cal.cal1.SOC*(x1(:,1) + cal.cal1.VOFFSET).*x1(:,2)...
        .*(1 + cal.cal1.A*x1(:,3) + cal.cal1.B*x1(:,3).^2 + cal.cal1.C*x1(:,3).^3)...
        .*exp((cal.cal1.E*x1(:,4))./(x1(:,3) + 273.15));
    end   

    if SOC_type == 1 % Constant SOC value

        x1 = [cast.oxcr1,cast.O2sol_umolkg1,cast.t1,cast.prs];
    
        % SBE functional form without constant SOC
        cast.DOcorr_umolkg1 = cal.cal1.SOCcalc*(x1(:,1) + cal.cal1.VOFFSET).*x1(:,2)...
        .*(1 + cal.cal1.A*x1(:,3) + cal.cal1.B*x1(:,3).^2 + cal.cal1.C*x1(:,3).^3)...
        .*exp((cal.cal1.Ecalc*x1(:,4))./(x1(:,3) + 273.15));
    end

    if SOC_type == 2 % SOC varies with cruise time

        x1 = [cast.oxcr1,cast.O2sol_umolkg1,cast.t1,cast.prs,cast.cruise_d];
        
        % SBE functional form with SOC as a function of cruise time
        cast.DOcorr_umolkg1 = ((cal.cal1.SOCrate_dt*x1(:,5)) + cal.cal1.SOCcalc_dt*(x1(:,1) + cal.cal1.VOFFSET)).*x1(:,2)...
            .*(1 + cal.cal1.A*x1(:,3) + cal.cal1.B*x1(:,3).^2 + cal.cal1.C*x1(:,3).^3)...
            .*exp((cal.cal1.Ecalc_dt*x1(:,4))./(x1(:,3) + 273.15));
    end

    if SOC_type == 3 % SOC varies with cast number 

        x1 = [cast.oxcr1,cast.O2sol_umolkg1,cast.t1,cast.prs,cast.Station];
        
        % SBE functional form with SOC as a function of cruise time
        cast.DOcorr_umolkg1 = ((cal.cal1.SOCrate_cn*x1(:,5)) + cal.cal1.SOCcalc_cn*(x1(:,1) + cal.cal1.VOFFSET)).*x1(:,2)...
            .*(1 + cal.cal1.A*x1(:,3) + cal.cal1.B*x1(:,3).^2 + cal.cal1.C*x1(:,3).^3)...
            .*exp((cal.cal1.Ecalc_cn*x1(:,4))./(x1(:,3) + 273.15));
    end
% Secondary sensor 
    if SOC_type == 0 % Seabird factory calibration
        
        x2 = [cast.oxcr2,cast.O2sol_umolkg2,cast.t2,cast.prs];
    
        % SBE functional form without SOC drift 
        cast.DOcorr_umolkg2 = cal.cal2.SOC*(x2(:,1) + cal.cal2.VOFFSET).*x2(:,2)...
        .*(1 + cal.cal2.A*x2(:,3) + cal.cal2.B*x2(:,3).^2 + cal.cal2.C*x2(:,3).^3)...
        .*exp((cal.cal2.E*x2(:,4))./(x2(:,3) + 273.15));
    end   

    if SOC_type == 1 % Constant SOC value

        x2 = [cast.oxcr2,cast.O2sol_umolkg2,cast.t2,cast.prs];
    
        % SBE functional form without constant SOC
        cast.DOcorr_umolkg2 = cal.cal2.SOCcalc*(x2(:,1) + cal.cal2.VOFFSET).*x2(:,2)...
        .*(1 + cal.cal2.A*x2(:,3) + cal.cal2.B*x2(:,3).^2 + cal.cal2.C*x2(:,3).^3)...
        .*exp((cal.cal2.Ecalc*x2(:,4))./(x2(:,3) + 273.15));
    end

    if SOC_type == 2 % SOC varies with cruise time

        x2 = [cast.oxcr2,cast.O2sol_umolkg2,cast.t2,cast.prs,cast.cruise_d];
        
        % SBE functional form with SOC as a function of cruise time
        cast.DOcorr_umolkg2 = ((cal.cal2.SOCrate_dt*x2(:,5)) + cal.cal2.SOCcalc_dt*(x2(:,1) + cal.cal2.VOFFSET)).*x2(:,2)...
            .*(1 + cal.cal2.A*x2(:,3) + cal.cal2.B*x2(:,3).^2 + cal.cal2.C*x2(:,3).^3)...
            .*exp((cal.cal2.Ecalc_dt*x2(:,4))./(x2(:,3) + 273.15));
    end

    if SOC_type == 3 % SOC varies with cast number 

        x2 = [cast.oxcr2,cast.O2sol_umolkg2,cast.t2,cast.prs,cast.Station];
        
        % SBE functional form with SOC as a function of cruise time
        cast.DOcorr_umolkg2 = ((cal.cal2.SOCrate_cn*x2(:,5)) + cal.cal2.SOCcalc_cn*(x2(:,1) + cal.cal2.VOFFSET)).*x2(:,2)...
            .*(1 + cal.cal2.A*x2(:,3) + cal.cal2.B*x2(:,3).^2 + cal.cal2.C*x2(:,3).^3)...
            .*exp((cal.cal2.Ecalc_cn*x2(:,4))./(x2(:,3) + 273.15));
    end

    cast.SOC_type1 = ones(length(cast.prs),1)*SOC_type;
    cast.SOC_type2 = ones(length(cast.prs),1)*SOC_type; 

    % Reorder variables and remove unnecessary ones
    vars = {'Station','prs','depth','lat','lon','temp1','temp2','sal1','sal2','oxcr1','oxcr2','CastTimeS','CastTimeUTC','StartTimeUTC','cruise_d',...
        't1','CT1','pt1','SP1','SA1','rho1','prho1','sigma01',...
        't2','CT2','pt2','SP2','SA2','rho2','prho2','sigma02',...
        'O2sol_umolkg1','O2sol_umolkg2','SOC_type1','SOC_type2','DOcorr_umolkg1','DOcorr_umolkg2'};
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
        plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1 == 0),btlsum.prs(btlsum.NLMR_Outlier1 == 0),'ok','MarkerFaceColor','k')
        plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2 == 0),btlsum.prs(btlsum.NLMR_Outlier2 == 0),'ok','MarkerFaceColor','k')
        plot(btlsum.Winkler3_umolkg(btlsum.NLMR_Outlier3 == 0),btlsum.prs(btlsum.NLMR_Outlier3 == 0),'ok','MarkerFaceColor','k')
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

plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1==0),btlsum.pt(btlsum.NLMR_Outlier1==0),'.k','markersize',20)
plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2==0),btlsum.pt(btlsum.NLMR_Outlier2==0),'.k','markersize',20)
plot(btlsum.Winkler3_umolkg(btlsum.NLMR_Outlier3==0),btlsum.pt(btlsum.NLMR_Outlier3==0),'.k','markersize',20)

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

plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1==1),btlsum.pt(btlsum.NLMR_Outlier1==1),'.','markersize',20,'Color',red)
plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1==0),btlsum.pt(btlsum.NLMR_Outlier1==0),'.k','markersize',20)
plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2==1),btlsum.pt(btlsum.NLMR_Outlier2==1),'.','markersize',20,'Color',red)
plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2==0),btlsum.pt(btlsum.NLMR_Outlier2==0),'.k','markersize',20)
plot(btlsum.Winkler3_umolkg(btlsum.NLMR_Outlier3==1),btlsum.pt(btlsum.NLMR_Outlier3==1),'.','markersize',20,'Color',red)
plot(btlsum.Winkler3_umolkg(btlsum.NLMR_Outlier3==0),btlsum.pt(btlsum.NLMR_Outlier3==0),'.k','markersize',20)
% plot(btlsum.Winkler1_umolkg(btlsum.Cast==10),btlsum.pt(btlsum.Cast==10),'.','markersize',20,'Color',yellow)
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on
sgtitle(TitleString)
legend('Uncalibrated','Calibrated','Not Evaluated Winklers','Questionable Winklers','Acceptable Winklers','Location','NW')
end