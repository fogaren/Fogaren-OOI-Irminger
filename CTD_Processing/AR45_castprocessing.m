clearvars
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
addpath(genpath('G:\My Drive\Matlab_work\Github\optode-response-time-Gordon'))

dir = ('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\AR45');
cd(dir)
load AR45_DOcal.mat
ns = 7; % Start of cast numbers in file name
ne = 9; % End of cast numbers in file name

dc_dir = 'C:\Users\fogaren\Documents\SBE\AR45\ctd_data\downcasts';
uc_dir = 'C:\Users\fogaren\Documents\SBE\AR45\ctd_data\upcasts';
leah_dir = 'C:\Users\fogaren\Documents\SBE\AR45\ctd_data\Final_From_Leah';

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
%%
cd(leah_dir)
downfiles = ls('*.dcc'); % List of Leah's calibrated bottle files 
downcasts = str2num(downfiles(:,ns-1:ne-1)); % Pulls out cast numbers that have bottle files 

% Make sure that there is a Leah cast file for each of my cast files 
if cast_num == downcasts 
    disp('Downcast numbers Line Up')
    
else
    disp('Caution: Issue with Matching Downcast Numbers!')
end

upfiles = ls('*.ucc'); % List of Leah's calibrated bottle files 
upcasts = str2num(upfiles(:,ns-1:ne-1)); % Pulls out cast numbers that have bottle files 

% Make sure that there is a Leah cast file for each of my cast files 
if cast_num == upcasts 
    disp('Upcast numbers Line Up')
    
else
    disp('Caution: Issue with Matching Upcast Numbers!')
end

%% Read in Leah's calibrated casts
cd(leah_dir)

dcc = []; % Read Leah's calibrated SBE casts into matlab 
for i = 1:length(cast_num)
    dcc_in =import_dcc(downfiles(i,:));
    dcc_in.temp_flag1 = str2num(dcc_in.woce.t901);
    dcc_in.temp_flag2 = str2num(dcc_in.woce.t902);
    dcc_in.sal_flag1 = str2num(dcc_in.woce.sal1);
    dcc_in.sal_flag2 = str2num(dcc_in.woce.sal2); 
    dcc{cast_num(i)} = leah_cast(dcc_in);
end

ucc = [];
for i = 1:length(cast_num)
    ucc_in = import_dcc(upfiles(i,:));
    ucc_in.temp_flag1 = str2num(ucc_in.woce.t901);
    ucc_in.temp_flag2 = str2num(ucc_in.woce.t902);
    ucc_in.sal_flag1 = str2num(ucc_in.woce.sal1);
    ucc_in.sal_flag2 = str2num(ucc_in.woce.sal2); 
    ucc{cast_num(i)} = leah_cast(ucc_in);
end

%% Combine and calibrate DO for Casts Read in bottle data and making DO calibration choice 
btlsum_tbl = btlsum_tbl_AR45;
cal = SBE_cal_AR45;
CTD_sen = btlsum_tbl.CTD_sen(1); % Sensor package to use for calibration; same as bottle processing 
SOC_type = 1; %*** 1 = constant, % 2 = changes as a function of cruise time % 3 = changes as a function of station number 

% btlsum_tbl = calibrate_CTD_oxygen(btlsum_tbl,cal,SOC_type);
CruiseStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 
%%
btlsum = []; % Indexes by cast number leah_btl{5} == cast 5; 
downcasts = []; upcasts = []; 
% Combine files and calculate sea water properties for CTD sensor number 
for i = 1:length(cast_num) % Number of bottle summary files 
    btlsum{cast_num(i)} = btlsum_tbl(btlsum_tbl.Cast == cast_num(i),:); 
    downcasts{cast_num(i)} = process_cast(dcc{cast_num(i)}, mydowncast{cast_num(i)}, CTD_sen, cal, SOC_type, CruiseStartTime);
    upcasts{cast_num(i)} = process_cast(ucc{cast_num(i)}, myupcast{cast_num(i)}, CTD_sen, cal, SOC_type, CruiseStartTime);
end
%% This cell takes a while and was already run, thickenss == 20 um
    
% %% Aanderaa calibration
prs_lim = [50 500];

Gordon2020 = []; 
for i = 1:length(cast_num)
    [ Gordon2020{cast_num(i)}] = Aanderaa_timelag_calc(downcasts{cast_num(i)}, upcasts{cast_num(i)},prs_lim,CTD_sen);
end

thickness = [];
tau_Tref = [];
for i = 1:length(cast_num)
    figure(100)
    plot(Gordon2020{cast_num(i)}.thickness_constants,Gordon2020{cast_num(i)}.rmsd)
    hold on
    grid on
    ylabel('RMSD')
    xlabel('thickness (\mum)')
    thickness = [thickness; Gordon2020{cast_num(i)}.thickness];
    tau_Tref = [tau_Tref; Gordon2020{cast_num(i)}.tau_Tref];
end

mean(thickness)
median(thickness)
%% Convert to oxygen concentration and calculate Aanderaa gain 
% From Aanderaa calibration file for SN 277 
AA277.foilcoeff = [2.798512E-03	1.179460E-04	2.512907E-06	2.262806E+02	-3.570254E-01	-6.104725E+01	4.558537E+00];
AA277.conccoeff = [0.000000E+00	1.000000E+00];
AA277.salset = 0;  % salinity set at 0  
AA277.D = 0.027; % Default is 0.032
AA277.calc_thickness = 20; % um Calculated in cell above 

for i = 1:length(cast_num)
    [ downcasts{cast_num(i)}, upcasts{cast_num(i)},btlsum{cast_num(i)}] = ...
        Aanderaa_gain_calc(downcasts{cast_num(i)}, upcasts{cast_num(i)},...
        btlsum{cast_num(i)},AA277); 
end
%%
% Pull all bottle files and create one large table 
btlsum_tbl = [];
for i = 1:length(btl_num)
        btlsum_tbl = [btlsum_tbl; btlsum{btl_num(i)}];
end
% Calculate AA gain
AA277.gain = mean(nanmean([btlsum_tbl.AA_gain1(btlsum_tbl.prs > 500) btlsum_tbl.AA_gain2(btlsum_tbl.prs > 500) btlsum_tbl.AA_gain3(btlsum_tbl.prs > 500)]))
AA277.gainstd = std(nanstd([btlsum_tbl.AA_gain1(btlsum_tbl.prs > 500) btlsum_tbl.AA_gain2(btlsum_tbl.prs > 500) btlsum_tbl.AA_gain3(btlsum_tbl.prs > 500)]))

%% 

for i = 1:length(cast_num)
    [ downcasts{cast_num(i)}, upcasts{cast_num(i)}, btlsum{cast_num(i)}] = ...
        Aanderaa_gain_cast(downcasts{cast_num(i)}, upcasts{cast_num(i)},...
        btlsum{cast_num(i)},AA277.gain,cast_num(i)); 
end

btlsum_tbl = [];
for i = 1:length(btl_num)
        btlsum_tbl = [btlsum_tbl; btlsum{btl_num(i)}];
end

%%
for i = 1:length(btl_num)
f = figure(300);
f.Position = [100 100 840 500];
    subplot(2,2,1)
    plot(btlsum{btl_num(i)}.prs,btlsum{btl_num(i)}.Winkler1_umolkg - btlsum{btl_num(i)}.AA_DOcorr_umolkg,'.k','Markersize',20); hold on; grid on
    plot(btlsum{btl_num(i)}.prs,btlsum{btl_num(i)}.Winkler2_umolkg - btlsum{btl_num(i)}.AA_DOcorr_umolkg,'.k','Markersize',20)
    plot(btlsum{btl_num(i)}.prs,btlsum{btl_num(i)}.Winkler3_umolkg - btlsum{btl_num(i)}.AA_DOcorr_umolkg,'.k','Markersize',20)
 
ylabel({'Residual, Winkler - Aanderaa','(\mumol/kg)'}); xlabel('Pressure (db)')

    subplot(2,2,2)
    plot(btlsum{btl_num(i)}.Cast,btlsum{btl_num(i)}.Winkler1_umolkg - btlsum{btl_num(i)}.AA_DOcorr_umolkg,'.k','Markersize',20); hold on; grid on
    plot(btlsum{btl_num(i)}.Cast,btlsum{btl_num(i)}.Winkler2_umolkg - btlsum{btl_num(i)}.AA_DOcorr_umolkg,'.k','Markersize',20)
    plot(btlsum{btl_num(i)}.Cast,btlsum{btl_num(i)}.Winkler3_umolkg - btlsum{btl_num(i)}.AA_DOcorr_umolkg,'.k','Markersize',20)
 
ylabel({'Residual, Winkler - Aanderaa','(\mumol/kg)'}); xlabel('Station Number')

    subplot(2,2,3)
    plot(btlsum{btl_num(i)}.t,btlsum{btl_num(i)}.Winkler1_umolkg - btlsum{btl_num(i)}.AA_DOcorr_umolkg,'.k','Markersize',20); hold on; grid on
    plot(btlsum{btl_num(i)}.t,btlsum{btl_num(i)}.Winkler2_umolkg - btlsum{btl_num(i)}.AA_DOcorr_umolkg,'.k','Markersize',20)
    plot(btlsum{btl_num(i)}.t,btlsum{btl_num(i)}.Winkler3_umolkg - btlsum{btl_num(i)}.AA_DOcorr_umolkg,'.k','Markersize',20)
 
ylabel({'Residual, Winkler - Aanderaa','(\mumol/kg)'}); xlabel('Temperature (\circC)')

    subplot(2,2,4)
    plot(btlsum{btl_num(i)}.Winkler1_umolkg,btlsum{btl_num(i)}.Winkler1_umolkg - btlsum{btl_num(i)}.AA_DOcorr_umolkg,'.k','Markersize',20); hold on; grid on
    plot(btlsum{btl_num(i)}.Winkler2_umolkg,btlsum{btl_num(i)}.Winkler2_umolkg - btlsum{btl_num(i)}.AA_DOcorr_umolkg,'.k','Markersize',20)
    plot(btlsum{btl_num(i)}.Winkler3_umolkg,btlsum{btl_num(i)}.Winkler3_umolkg - btlsum{btl_num(i)}.AA_DOcorr_umolkg,'.k','Markersize',20)
 ylabel({'Residual, Winkler - Aanderaa','(\mumol/kg)'}); xlabel('Winkler DO (\mumol/kg)')
sgtitle('AR45: Aanderaa Residuals')
end
%% Plot final data
for i = 1:length(cast_num)
    plot_calibrated_DO(downcasts{cast_num(i)},upcasts{cast_num(i)},btlsum{cast_num(i)})
end


%% Plot just casts with Winklers 
navy = [0.078431     0.16863     0.54902];
maroon = [0.63529    0.078431     0.18431];
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
    plot(btlsum{btl_num(i)}.Winkler1_umolkg(btlsum{btl_num(i)}.NLMR_Outlier1 == 1),btlsum{btl_num(i)}.prs(btlsum{btl_num(i)}.NLMR_Outlier1 == 1),'.r','MarkerSize',20)
    plot(btlsum{btl_num(i)}.Winkler2_umolkg(btlsum{btl_num(i)}.NLMR_Outlier2 == 1),btlsum{btl_num(i)}.prs(btlsum{btl_num(i)}.NLMR_Outlier2 == 1),'.r','MarkerSize',20)
    plot(btlsum{btl_num(i)}.Winkler3_umolkg(btlsum{btl_num(i)}.NLMR_Outlier3 == 1),btlsum{btl_num(i)}.prs(btlsum{btl_num(i)}.NLMR_Outlier3 == 1),'.r','MarkerSize',20)

    ax = gca;
    ax.XAxisLocation = 'top';
    ylabel('pressure (db)')
    xlabel('DO (\mumol/kg)')
    title(['Cast: ' num2str(btl_num(i))])
end



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
%%
for i = 1:length(cast_num)
    figure(1)
    subplot(2,2,1)
    plot(upcasts{cast_num(i)}.temp_flag,'.')
    hold on
    title('Upcast: Temp Flag')
    xlabel('Bin #')
    ylabel('WOCE Flag')

    subplot(2,2,2)
    plot(upcasts{cast_num(i)}.sal_flag,'.')
    hold on
    title('Upcast: Sal Flag')
    ylabel('WOCE Flag')
    
    subplot(2,2,3)
    plot(downcasts{cast_num(i)}.temp_flag,'.')
    hold on
    title('Downcast: Temp Flag')
    xlabel('Bin #')
    ylabel('WOCE Flag')

    subplot(2,2,4)
    plot(downcasts{cast_num(i)}.sal_flag,'.')
    hold on
    title('Downcast: Sal Flag')
    xlabel('Bin #')
    ylabel('WOCE Flag')
end
sgtitle('WHOI Calibrated CTD Flags')
%%
%Change folder to BCO-DMO location 
cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\BCO-DMO Submission\GOHSNAP\AR45')

%Create metadata file 
    fheader = [sprintf('Filename,Cruise,Station,Down_Up,Lat,Lon,Date (UTC)') newline];
    metadata_file = fopen('metadata_oxygenprofiles.csv','w');
    fprintf(metadata_file,fheader);
    fclose(metadata_file); 

for i = 1:length(cast_num)
    dwn_out = downcasts{cast_num(i)};

    metadata_file = fopen('metadata_oxygenprofiles.csv','a');
    castname_d = ['AR45_' sprintf('%03d',cast_num(i)) 'd.csv']; castname_u = ['AR45_' sprintf('%03d',cast_num(i)) 'u.csv'];
    cruise = 'AR45'; cast = cast_num(i); d = 'd'; u = 'u';
    lat = dwn_out.lat(1); lon = dwn_out.lon(1);
    dt = datestr(dwn_out.StartTimeUTC(1)); 

    fprintf(metadata_file,'%s,%s,%d,%s,%.4f,%.4f,%s\n', castname_d,cruise,cast,d,lat,lon,dt);
    fprintf(metadata_file,'%s,%s,%d,%s,%.4f,%.4f,%s\n', castname_u,cruise,cast,u,lat,lon,dt);
    fclose(metadata_file);
end

%%
cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\BCO-DMO Submission\GOHSNAP\AR45')
% For adding questionable qa flags. 
% upcast10 = 40;
% upcast87 = 74;
% downcast117 = 34;
% Mark these depths as questionable for downcasts 1-70 (before pump change)
questionable = [20 26 56 40 30 22 20 40 20 40 24 32 26 26 28 26 28 26 22 22 46 60 20 28 22 24 32 22 26 28 26 28 30 28 22 26 26 20 28 26 26 26 ...
    22 34 20 24 78 28 24 26 22 22 24 74 26 24 26 26 22 20 20 20 20 24 46 44 34 52 30 68];

for i = 1:length(cast_num)
    dwn_out = downcasts{cast_num(i)};
    
%     temp_flag = ones(size(dwn_out.t))*2; % Incorporated Leah's WOCE flags
%     sal_flag = ones(size(dwn_out.t))*2;
    oxycur_flag = ones(size(dwn_out.t))*2;
    ctdoxy_flag = ones(size(dwn_out.t))*2;
        if cast_num(i) < 71
            indbad = find(dwn_out.prs == questionable(i));
               oxycur_flag(1:indbad) = 3;
               ctdoxy_flag(1:indbad) = 3; 
        end
        if cast_num(i) == 117
            indbad = find(dwn_out.prs == 34);
               oxycur_flag(1:indbad) = 3;
               ctdoxy_flag(1:indbad) = 3; 
        end
    dwn_out.oxycur_flag = oxycur_flag;
    dwn_out.ctdoxy_flag = ctdoxy_flag;
    downcasts{cast_num(i)} = dwn_out; 

    fheader = ['AR45    Calibrated Oxygen Downcast   Station: ' num2str(cast_num(i)) newline...
    'Latitude: ' sprintf('%.4f',dwn_out.lat(1)) '   Longitude: ' sprintf('%.4f',dwn_out.lon(1))...
    '   ' datestr(dwn_out.StartTimeUTC(1)) newline...
    sprintf('CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
    sprintf('dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 

    fileIDd = fopen(['AR45_' sprintf('%03d',cast_num(i)) 'd.csv'],'w');
    fprintf(fileIDd,fheader);
    for ii = 1:length(dwn_out.prs)
        fprintf(fileIDd,'%.1f,%.3f,%d,%.3f,%d,%.4f,%d,%.1f,%d\n', dwn_out.prs(ii),dwn_out.t(ii),dwn_out.temp_flag(ii),dwn_out.SP(ii),dwn_out.sal_flag(ii),dwn_out.oxy_volts(ii),oxycur_flag(ii),dwn_out.DOcorr_umolkg(ii),ctdoxy_flag(ii));
    end
    fclose(fileIDd);
end

for i = 1:length(cast_num)
    up_out = upcasts{cast_num(i)};

%     temp_flag = ones(size(up_out.t))*2; % Incorporated Leah's WOCE flags
%     sal_flag = ones(size(up_out.t))*2;
    oxycur_flag = ones(size(up_out.t))*2;
    ctdoxy_flag = ones(size(up_out.t))*2;

        if cast_num(i) == 10
            indbad = find(dwn_out.prs == 40);
               oxycur_flag(1:indbad) = 3;
               ctdoxy_flag(1:indbad) = 3; 
        end
        if cast_num(i) == 87
            indbad = find(dwn_out.prs == 74);
               oxycur_flag(1:indbad) = 3;
               ctdoxy_flag(1:indbad) = 3; 
        end
    
    up_out.oxycur_flag = oxycur_flag;
    up_out.ctdoxy_flag = ctdoxy_flag;
    upcasts{cast_num(i)} = up_out; 

    fheader = ['AR45    Calibrated Oxygen Upcast   Station: ' num2str(cast_num(i)) newline...
    'Latitude: ' sprintf('%.4f',up_out.lat(1)) '   Longitude: ' sprintf('%.4f',up_out.lon(1))...
    '   ' datestr(up_out.StartTimeUTC(1)) newline...
    sprintf('CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
    sprintf('dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 

    fileIDu = fopen(['AR45_' sprintf('%03d',cast_num(i)) 'u.csv'],'w');
    fprintf(fileIDu,fheader);
    for ii = 1:length(up_out.prs)
        fprintf(fileIDd,'%.1f,%.3f,%d,%.3f,%d,%.4f,%d,%.1f,%d\n', up_out.prs(ii),up_out.t(ii),up_out.temp_flag(ii),up_out.SP(ii),up_out.sal_flag(ii),up_out.oxy_volts(ii),oxycur_flag(ii),up_out.DOcorr_umolkg(ii),ctdoxy_flag(ii));
    end
    fclose(fileIDu);
end
%%
grey = [0.5     0.5     0.5];
blue = [0     0.44706     0.74118];
red = [0.85098     0.32549    0.098039]; 

figure(1000)
subplot(1,2,1)
    plot(NaN,NaN,'Linewidth',1','Color',grey)
    hold on
    plot(NaN,NaN,'Linewidth',1','Color',blue)
    plot(NaN,NaN,'.','MarkerSize',20,'Color',red)
    plot(NaN,NaN,'.k','MarkerSize',20)
for i = 1:length(btl_num)

    subplot(1,2,1)
    x = [downcasts{btl_num(i)}.oxy_volts downcasts{btl_num(i)}.O2sol_umolkg ...
        downcasts{btl_num(i)}.t downcasts{btl_num(i)}.prs];
    DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));
%     plot(DOuncorr_umolkg(downcasts{btl_num(i)}.ctdoxy_flag ==2),downcasts{btl_num(i)}.pt(downcasts{btl_num(i)}.ctdoxy_flag ==2),'Linewidth',1,'Color',grey)
    plot(DOuncorr_umolkg,downcasts{btl_num(i)}.pt,'Linewidth',1,'Color',grey)
    hold on
end

for i = 1:length(btl_num)

    plot(downcasts{btl_num(i)}.DOcorr_umolkg(downcasts{btl_num(i)}.ctdoxy_flag ==2)   ,downcasts{btl_num(i)}.pt(downcasts{btl_num(i)}.ctdoxy_flag ==2),'Linewidth',1,'Color',blue)
end 
ylim([0 10])
grid on
ylabel('PT (\circC)'); xlabel('DO (\mumol kg^-^1)')
title('Downcasts')

subplot(1,2,2)
    plot(NaN,NaN,'Linewidth',1','Color',grey)
hold on
plot(NaN,NaN,'Linewidth',1','Color',blue)
plot(NaN,NaN,'.','MarkerSize',20,'Color',red)
plot(NaN,NaN,'.k','MarkerSize',20)

for i = 1:length(btl_num)

    x = [upcasts{btl_num(i)}.oxy_volts upcasts{btl_num(i)}.O2sol_umolkg ...
        upcasts{btl_num(i)}.t upcasts{btl_num(i)}.prs];
    DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));
    plot(DOuncorr_umolkg,upcasts{btl_num(i)}.pt,'Linewidth',1,'Color',grey)
    hold on
end

for i = 1:length(btl_num)

    plot(upcasts{btl_num(i)}.DOcorr_umolkg,upcasts{btl_num(i)}.pt,'Linewidth',1,'Color',blue)
end 

for i = 1:length(btl_num)
    plot(btlsum{btl_num(i)}.Winkler1_umolkg,btlsum{btl_num(i)}.pt,'.k','MarkerSize',20)
    plot(btlsum{btl_num(i)}.Winkler2_umolkg,btlsum{btl_num(i)}.pt,'.k','MarkerSize',20)
    plot(btlsum{btl_num(i)}.Winkler3_umolkg,btlsum{btl_num(i)}.pt,'.k','MarkerSize',20)
    plot(btlsum{btl_num(i)}.Winkler1_umolkg(btlsum{btl_num(i)}.NLMR_Outlier1 == 3),btlsum{btl_num(i)}.pt(btlsum{btl_num(i)}.NLMR_Outlier1 == 3),'.','MarkerSize',20,'Color',red)
    plot(btlsum{btl_num(i)}.Winkler2_umolkg(btlsum{btl_num(i)}.NLMR_Outlier2 == 3),btlsum{btl_num(i)}.pt(btlsum{btl_num(i)}.NLMR_Outlier2 == 3),'.','MarkerSize',20,'Color',red)
    plot(btlsum{btl_num(i)}.Winkler3_umolkg(btlsum{btl_num(i)}.NLMR_Outlier3 == 3),btlsum{btl_num(i)}.pt(btlsum{btl_num(i)}.NLMR_Outlier3 == 3),'.','MarkerSize',20,'Color',red)
end

ylim([0 10])
grid on
ylabel('PT (\circC)'); xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
legend('Uncalibrated','Calibrated','Questionable Winklers','Acceptable Winklers','Location','NW')
sgtitle('AR45')

%%
figure(1001)

plot(NaN,NaN,'Linewidth',1','Color',grey)
hold on
plot(NaN,NaN,'Linewidth',1','Color',blue)
plot(NaN,NaN,'.','MarkerSize',20,'Color',red)
plot(NaN,NaN,'.k','MarkerSize',20)

for i = 1:length(btl_num)

    x = [upcasts{btl_num(i)}.oxy_volts upcasts{btl_num(i)}.O2sol_umolkg ...
        upcasts{btl_num(i)}.t upcasts{btl_num(i)}.prs];
    DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));
    plot(DOuncorr_umolkg,upcasts{btl_num(i)}.pt,'Linewidth',1,'Color',grey)
    hold on
end

for i = 1:length(btl_num)

    plot(upcasts{btl_num(i)}.DOcorr_umolkg,upcasts{btl_num(i)}.pt,'Linewidth',1,'Color',blue)
end 

for i = 1:length(btl_num)
    plot(btlsum{btl_num(i)}.Winkler1_umolkg,btlsum{btl_num(i)}.pt,'.k','MarkerSize',20)
    plot(btlsum{btl_num(i)}.Winkler2_umolkg,btlsum{btl_num(i)}.pt,'.k','MarkerSize',20)
    plot(btlsum{btl_num(i)}.Winkler3_umolkg,btlsum{btl_num(i)}.pt,'.k','MarkerSize',20)
    plot(btlsum{btl_num(i)}.Winkler1_umolkg(btlsum{btl_num(i)}.NLMR_Outlier1 == 3),btlsum{btl_num(i)}.pt(btlsum{btl_num(i)}.NLMR_Outlier1 == 3),'.','MarkerSize',20,'Color',red)
    plot(btlsum{btl_num(i)}.Winkler2_umolkg(btlsum{btl_num(i)}.NLMR_Outlier2 == 3),btlsum{btl_num(i)}.pt(btlsum{btl_num(i)}.NLMR_Outlier2 == 3),'.','MarkerSize',20,'Color',red)
    plot(btlsum{btl_num(i)}.Winkler3_umolkg(btlsum{btl_num(i)}.NLMR_Outlier3 == 3),btlsum{btl_num(i)}.pt(btlsum{btl_num(i)}.NLMR_Outlier3 == 3),'.','MarkerSize',20,'Color',red)
end

ylim([0 10])
grid on
ylabel('PT (\circC)'); xlabel('DO (\mumol kg^-^1)')
legend('Uncalibrated','Calibrated','Questionable Winklers','Acceptable Winklers','Location','NW')
title('AR45: Upcasts')

%% Save processed data 
if savefile == 1

    btlsum_AR45 = btlsum;
    btlsum_AR45_tbl = btlsum_tbl;
    upcasts_AR45 = upcasts;
    downcasts_AR45 = downcasts;
    btl_num_AR45 = btl_num;
    cast_num_AR45 = cast_num;
    SBE_cal_AR45 = cal; 
%     Gordon2020_AR45;
    dt_KF_Processed_AR45 = datetime('now');

    
    cd(dir)
    save AR45_DO_Processed_KF.mat upcasts_* downcasts_* btl_num_* cast_num_* SBE_cal_* AA* btlsum_* dt_KF_Processed_*
end

%%
% bad_casts = [163 163];
bad_casts = [NaN NaN];
    plot_calibrated_pTemp_AA(downcasts,upcasts,cast_num,btlsum_tbl,cal,bad_casts,'AR45')

% % 
% %%
% bad_casts = [NaN; % bad downcasts  
%     NaN]'; % bad upcasts 
% plot_calibrated_pTemp(downcasts,upcasts,cast_num,btlsum_tbl,cal,bad_casts,'AR45 GOHSNAP 2020')
%%
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
%         fheader = ['AR45    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
%         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag, Oxygen1, Oxygen1_flag, Oxygen2, Oxygen2_flag, Oxygen3, Oxygen3_flag') newline...
%         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a., umol/kg, n.a., umol/kg, n.a., umol/kg, n.a.') newline];
%         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d,%.1f,%d,%.1f,%d,%.1f,%d\n';
%         data_format = data;
%     elseif index1 + index2 + index3 == 2
%         fheader = ['AR45    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
%         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag, Oxygen1, Oxygen1_flag, Oxygen2, Oxygen2_flag') newline...
%         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a., umol/kg, n.a., umol/kg, n.a.') newline];   
%         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d,%.1f,%d,%.1f,%d\n';
%         data_format = data(:,1:end-2);
%     elseif index1 + index2 + index3 == 1
%         fheader = ['AR45    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
%         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag, Oxygen1, Oxygen1_flag') newline...
%         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a., umol/kg, n.a.') newline];
%         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d,%.1f,%d\n';
%         data_format = data(:,1:end-4);
%     else
%         fheader = ['AR45    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
%         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
%         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 
%         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n';
%         data_format = data(:,1:end-6);
%     end
% 
%     fileID = fopen(['AR45_' sprintf('%03d',btl_num(i)) 'btl.csv'],'w');
%     fprintf(fileID,fheader);
%         for ii = 1:length(btl_out.Bottle)
%             fprintf(fileID,string_format, data_format(ii,:));
%         end
%     fclose(fileID);
% end
%%

function leah_cast = leah_cast(leah_cast)

    fields = {'woce','date','time','oxcr','ox','tran','flu','alt'};
    leah_cast = rmfield(leah_cast,fields);
    leah_cast.station = leah_cast.station.*ones(length(leah_cast.prs),1);
    leah_cast.lat = leah_cast.lat.*ones(length(leah_cast.prs),1);
    leah_cast.lon = leah_cast.lon.*ones(length(leah_cast.prs),1);
    leah_cast = struct2table(leah_cast);
    leah_cast.Properties.VariableNames = {'Station','lat','lon','prs','temp1','temp2','sal1','sal2','temp_flag1','temp_flag2','sal_flag1','sal_flag2'};   
 
end

function cast = my_cast(cast)
    cast0 = cast;
%     fields = {'source','DataFileType','instrumentheaders','userheaders','vars','longname','units','span','mvars','mvars_format'...
%         'scan','lat','lon','nbin','flag','SeasaveVersion','softwareheaders','t090C','t190C','c0mScm','c1mScm'};
    fields = {'source','DataFileType','instrumentheaders','userheaders','vars','longname','units','span','mvars','mvars_format'...
        'scan','lat','lon','nbin','flag','SeasaveVersion','softwareheaders','c0mScm','c1mScm','t090C','t190C'};
    cast = rmfield(cast,fields);
    cast = struct2table(cast);
    cast.Properties.VariableNames = {'CastTimeS','prs','depth','oxy_volts','AA_volts'};
    cast.StartTimeUTC = ones(length(cast.CastTimeS),1)*datenum(cast0.instrumentheaders.SystemUTC); 
    cast.StartTimeUTC = datetime(cast.StartTimeUTC,'ConvertFrom','datenum');
    cast.CastTimeUTC = cast.StartTimeUTC + cast.CastTimeS/3600/24;
    cast.CTDcal(:) = {'True'};
    cast.CTDcal = string(cast.CTDcal);
end

%% Reads in bottle data and calibrates CTD oxygen 
function btlsum = calibrate_CTD_oxygen(btlsum,cal,SOC_type)
        x = [btlsum.oxy_volts,btlsum.O2sol_umolkg,btlsum.t,btlsum.prs];

    if SOC_type == 1 % Constant SOC value
    
        % SBE functional form without SOC drift 
        btlsum.DOcorr_umolkg = cal.SOCcalc*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));
    end

    if SOC_type == 2 % SOC varies with cruise time
        dtx = datenum(btlsum.Date) - datenum(btlsum.Date(1)); 
        x = [x,dtx];
        
        % SBE functional form with SOC as a function of cruise time
        btlsum.DOcorr_umolkg = ((cal.SOCrate_dt*x(:,5)) + cal.SOCcalc_dt*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_dt*x(:,4))./(x(:,3) + 273.15));
    end

    if SOC_type == 3 % SOC varies with cast number 

        x = [x,btlsum.Cast];
        
        % SBE functional form with SOC as a function of cruise time
        btlsum.DOcorr_umolkg = ((cal.SOCrate_cn*x(:,5)) + cal.SOCcalc_cn*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15));
    end

        btlsum.SOC_type = ones(length(btlsum.prs),1)*SOC_type; 

        btlsum.NLMR_Outlier = btlsum.Winkler_umolkg_wout_outliers;
        btlsum.NLMR_Outlier(find(btlsum.NLMR_Outlier >=0)) = 0;
        btlsum.NLMR_Outlier(isnan(btlsum.NLMR_Outlier)) = 1; 

            % Reorder variables and remove unnecessary one        
        btlvars = {'Cast','Cruise','Bottle','Date','prs','depth','lat','lon','temp1','temp2','sal1','sal2','Discrete_Salinity_psu',...
            'CTDcal','CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','Winkler_mLL','Winkler_umolkg','O2sol_umolkg',...
            'SOC_type','DOcorr_umolkg','NLMR_Outlier','AA_volts'};
        btlsum = btlsum(:,btlvars);

end


function cast = process_cast(leah_cast,mycast,CTD_sen,cal,SOC_type,CruiseStartTime)

    cast = innerjoin(mycast,leah_cast); 

    % Decide if using primary or secondary CTD sensor for temp and sal
    if CTD_sen == 1 % primary sensor (use unless something wrong with data)
        cast.t = cast.temp1; 
        cast.SP = cast.sal1;
        cast.temp_flag = cast.temp_flag1;
        cast.sal_flag = cast.sal_flag1;
     end
    
    if CTD_sen == 2 % secondary sensor (use if primary sensor bad)
        cast.t = cast.temp2; 
        cast.SP = cast.sal2; 
        cast.temp_flag = cast.temp_flag2;
        cast.sal_flag = cast.sal_flag2;
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

        x = [cast.oxy_volts,cast.O2sol_umolkg,cast.t,cast.prs];    
    if SOC_type == 1 % Constant SOC value

        % SBE functional form without SOC drift 
        cast.DOcorr_umolkg = cal.SOCcalc*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));
    end

    if SOC_type == 2 % SOC varies with cruise time

        x = [x, cast.cruise_d];
        
        % SBE functional form with SOC as a function of cruise time
        cast.DOcorr_umolkg = ((cal.SOCrate_dt*x(:,5)) + cal.SOCcalc_dt*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_dt*x(:,4))./(x(:,3) + 273.15));
    end

    if SOC_type == 3 % SOC varies with cast number 

        x = [x, cast.Station];
        
        % SBE functional form with SOC as a function of cruise time
        cast.DOcorr_umolkg = ((cal.SOCrate_cn*x(:,5)) + cal.SOCcalc_cn*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15));
    end

    cast.SOC_type = ones(length(cast.prs),1)*SOC_type; 

    % Reorder variables and remove unnecessary ones
    vars = {'Station','prs','depth','lat','lon','temp1','temp2','sal1','sal2','CastTimeS','CastTimeUTC','StartTimeUTC','cruise_d','CTDcal',...
        'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','DOcorr_umolkg','O2sol_umolkg','SOC_type','AA_volts','temp_flag','sal_flag'};
    cast = cast(:,vars); 
    
end

function plot_calibrated_DO(downcasts,upcasts,btlsum)

maroon = [0.63529    0.078431     0.18431];
navy = [0.078431     0.16863     0.54902];

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
%         plot(downcasts.AA_DOcorr_umolkg,downcasts.prs,'Linewidth',1.2,'Color',navy)
%         plot(upcasts.AA_DOcorr_umolkg,upcasts.prs,'Linewidth',1.2,'Color',maroon)
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
%         plot(downcasts.AA_DOcorr_umolkg,downcasts.prs,'Linewidth',1.2,'Color',navy)
%         plot(upcasts.AA_DOcorr_umolkg,upcasts.prs,'Linewidth',1.2,'Color',maroon)
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
    
    DO(1,1:length(castd.CastTimeS)) = castd.AA_volts; 
    DO(2,1:length(castu.CastTimeS)) = castu.AA_volts; 

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

function [ castd, castu, btlsum ] = Aanderaa_gain_calc(castd,castu,btlsum,AA)

    % Call correct_oxygen_profile_wTemp to output Oxygen data [volts] corrected for timelag    
    indd = ~(isnan(datenum(castd.CastTimeUTC)) | isnan(castd.AA_volts) | isnan(castd.t));
    indu = ~(isnan(datenum(castu.CastTimeUTC)) | isnan(castu.AA_volts) | isnan(castu.t));
    
    [ castd.AA_volts_lagcorr ] = correct_oxygen_profile_wTemp(datenum(castd.CastTimeUTC(indd)), castd.AA_volts(indd), castd.t(indd)', AA.calc_thickness );
    [ castu.AA_volts_lagcorr ] = correct_oxygen_profile_wTemp(datenum(castu.CastTimeUTC(indu)), castu.AA_volts(indu), castu.t(indu)', AA.calc_thickness );

     A = 10; B = 12; %note that this should be the same for all optodes
    castd.AA_volts_lagcorr_sm = smoothdata(castd.AA_volts_lagcorr,'movmean',9,'omitnan');
%     Calculate uncalibrated oxygen concentration for downcasts 
    castd.AA_calphase = B.*castd.AA_volts_lagcorr_sm + A; 
    [optode_uM, ~] = aaoptode_sternvolmer(AA.foilcoeff, castd.AA_calphase, castd.t, castd.SP, castd.prs);    
     optode_uM = AA.conccoeff(1) + AA.conccoeff(2).*optode_uM;
    castd.AA_spcorr_umolkg = aaoptode_salpresscorr_Dchoice(optode_uM, castd.t, castd.SP, castd.prs, AA.salset,AA.D);
    
    castu.AA_volts_lagcorr_sm = smoothdata(castu.AA_volts_lagcorr,'movmean',9,'omitnan');
%     Calculate uncalibrated oxygen concentration for upcasts 
    castu.AA_calphase = B.*castu.AA_volts_lagcorr_sm + A; 
    [optode_uM, ~] = aaoptode_sternvolmer(AA.foilcoeff, castu.AA_calphase, castu.t, castu.SP, castu.prs);    
     optode_uM = AA.conccoeff(1) + AA.conccoeff(2).*optode_uM;
    castu.AA_spcorr_umolkg = aaoptode_salpresscorr_Dchoice(optode_uM, castu.t, castu.SP, castu.prs, AA.salset,AA.D);   

    % Reorder variables and remove unnecessary ones
    vars = {'Station','prs','depth','lat','lon','temp1','temp2','sal1','sal2','CastTimeS','CastTimeUTC','StartTimeUTC','CTDcal',...
        'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','DOcorr_umolkg','O2sol_umolkg','SOC_type',...
        'AA_volts','AA_volts_lagcorr','AA_volts_lagcorr_sm','AA_calphase','AA_spcorr_umolkg','temp_flag','sal_flag'};

    castu = castu(:,vars);
    castd = castd(:,vars); 

        if height(btlsum) ~= 0
            
      % Find bottle value at specific depth using lag corrected upcast 
            bin_1dbu = min(castu.prs):1:max(castu.prs); 
            bin_1dbd = min(castd.prs):1:max(castd.prs); 
            AAu_interp = interp1(castu.prs,castu.AA_spcorr_umolkg,bin_1dbu);
            AAd_interp = interp1(castd.prs,castd.AA_spcorr_umolkg,bin_1dbd);

            AA_spcorr_umolkg = [];
            for i = 1:length(btlsum.prs)
                try 
                    [ind,~] = find(floor(btlsum.prs(i)) == bin_1dbu');
                    AA_spcorr_umolkg(i) = AAu_interp(ind);
                catch
                    [ind,~] = find(floor(btlsum.prs(i)) == bin_1dbd');
                    AA_spcorr_umolkg(i) = AAd_interp(ind);
                    warning(['Cast ' num2str(btlsum.Cast(1)) ' Btl ' num2str(btlsum.Bottle(i)) ' = downcast value'])
                end
            end

            btlsum.AA_spcorr_umolkg = AA_spcorr_umolkg';
      % Calculate gain from Winkler over Aanderaa lag/sal/press corrected values
            btlsum.AA_gain1 = btlsum.Winkler1_umolkg./btlsum.AA_spcorr_umolkg;
            btlsum.AA_gain2 = btlsum.Winkler2_umolkg./btlsum.AA_spcorr_umolkg;
            btlsum.AA_gain3 = btlsum.Winkler3_umolkg./btlsum.AA_spcorr_umolkg;

                 % Reorder variables and remove unnecessary one        
        btlvars = {'Cruise','Date','Cast','Bottle','prs','depth','lat','lon','temp1','temp2','sal1','sal2','Discrete_Salinity_psu',...
            'CTDcal','CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','O2sol_umolkg','Winkler1_mLL','Winkler2_mLL','Winkler3_mLL',...
            'Winkler1_umolkg','Winkler2_umolkg','Winkler3_umolkg','SOC_type','NLMR_Outlier1','NLMR_Outlier2','NLMR_Outlier3','DOcorr_umolkg','AA_volts','AA_spcorr_umolkg','AA_gain1','AA_gain2','AA_gain3'};
        btlsum = btlsum(:,btlvars);
        end
    
        if height(btlsum) == 0
            btlsum = 'No Discrete Samples';
        end
end

function [castd, castu, btlsum] = Aanderaa_gain_cast(castd,castu,btlsum,gain,cast_num)
temp_sal_plots = 0;
navy = [0.078431     0.16863     0.54902];
maroon = [0.63529    0.078431     0.18431];

castd.AA_DOcorr_umolkg = castd.AA_spcorr_umolkg*gain;
castu.AA_DOcorr_umolkg = castu.AA_spcorr_umolkg*gain;

% Bottle gain correction
if height(btlsum ) ~= 1
    btlsum.AA_DOcorr_umolkg = btlsum.AA_spcorr_umolkg.*gain; 
end


if temp_sal_plots == 1

    if height(btlsum) == 1 && temp_sal_plots == 0
         
        figure
        plot(castd.DOcorr_umolkg,castd.prs,'Linewidth',1.2)
        hold on
        plot(castu.DOcorr_umolkg,castu.prs,'Linewidth',1.2)
        plot(castd.AA_DOcorr_umolkg,castd.prs,'Linewidth',1.2,'Color',navy)
        plot(castu.AA_DOcorr_umolkg,castu.prs,'Linewidth',1.2,'Color',maroon)
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
        plot(castd.AA_DOcorr_umolkg,castd.prs,'Linewidth',1.2,'Color',navy)
        plot(castu.AA_DOcorr_umolkg,castu.prs,'Linewidth',1.2,'Color',maroon)
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
        plot(btlsum.Winkler_umolkg,btlsum.prs,'ok','MarkerFaceColor','k')
        plot(castd.AA_DOcorr_umolkg,castd.prs,'Linewidth',1.2,'Color',navy)
        plot(castu.AA_DOcorr_umolkg,castu.prs,'Linewidth',1.2,'Color',maroon)
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
        plot(btlsum.Winkler_umolkg,btlsum.prs,'ok','MarkerFaceColor','k')
        plot(castd.AA_DOcorr_umolkg,castd.prs,'Linewidth',1.2,'Color',navy)
        plot(castu.AA_DOcorr_umolkg,castu.prs,'Linewidth',1.2,'Color',maroon)
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
end

function plot_calibrated_pTemp_AA(downcasts,upcasts,cast_num,btlsum,cal,bad_casts,TitleString)
% For plotting purposes 
ooi_latlon = [59.9341, -39.4673
    59.8177, -39.8412
    59.7155, -39.3148];
grey = [0.5     0.5     0.5];
blue = [0     0.44706     0.74118];
red = [0.85098     0.32549    0.098039];
maroon = [0.63529    0.078431     0.18431];

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
sgtitle(TitleString)

subplot(1,3,2)
for i = 1:length(cast_num)
    if max(cast_num(i) == nanmean(bad_casts,2)) ~=1
        plot(downcasts{cast_num(i)}.DOcorr_umolkg(13:end),downcasts{cast_num(i)}.pt(13:end),'Linewidth',1.2)
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

figure
subplot(1,2,1)
for i = 1:length(cast_num)

    x = [downcasts{cast_num(i)}.oxy_volts downcasts{cast_num(i)}.O2sol_umolkg ...
        downcasts{cast_num(i)}.t downcasts{cast_num(i)}.prs];
    DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));
    if max(cast_num(i) == bad_casts(:,1)) ~=1
        plot(DOuncorr_umolkg,downcasts{cast_num(i)}.pt,'Linewidth',1,'Color',grey)
        hold on
    end
end

for i = 1:length(cast_num)    
    if max(cast_num(i) == bad_casts(:,1)) ~=1
        plot(downcasts{cast_num(i)}.DOcorr_umolkg(downcasts{cast_num(i)}.ctdoxy_flag == 2),downcasts{cast_num(i)}.pt(downcasts{cast_num(i)}.ctdoxy_flag == 2),'Linewidth',1,'Color',blue)
    end
end
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Downcasts')
grid on
ylim([0 10])
xlim([225 425])

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
    if max(cast_num(i) == bad_casts(:,2)) ~= 1
        plot(DOuncorr_umolkg,upcasts{cast_num(i)}.pt,'Linewidth',1,'Color',grey)
    end
end

for i = 1:length(cast_num)
    if max(cast_num(i) == bad_casts(:,2)) ~= 1
        plot(upcasts{cast_num(i)}.DOcorr_umolkg(upcasts{cast_num(i)}.ctdoxy_flag == 2),upcasts{cast_num(i)}.pt(upcasts{cast_num(i)}.ctdoxy_flag == 2),'Linewidth',1,'Color',blue)
    end
end

plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1==3),btlsum.pt(btlsum.NLMR_Outlier1==3),'.','markersize',20,'Color',red)
plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1==2),btlsum.pt(btlsum.NLMR_Outlier1==2),'.k','markersize',20)
plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2==3),btlsum.pt(btlsum.NLMR_Outlier2==3),'.','markersize',20,'Color',red)
plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2==2),btlsum.pt(btlsum.NLMR_Outlier2==2),'.k','markersize',20)
plot(btlsum.Winkler3_umolkg(btlsum.NLMR_Outlier3==3),btlsum.pt(btlsum.NLMR_Outlier3==3),'.','markersize',20,'Color',red)
plot(btlsum.Winkler3_umolkg(btlsum.NLMR_Outlier3==2),btlsum.pt(btlsum.NLMR_Outlier3==2),'.k','markersize',20)

ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on
ylim([0 10])
xlim([225 425])
sgtitle([TitleString])
legend('Uncalibrated','Calibrated','Questionable Winklers','Acceptable Winklers','Location','NW')

figure
subplot(1,2,1)
for i = 1:length(cast_num)
    if max(cast_num(i) == bad_casts(:,1)) ~=1
        plot(downcasts{cast_num(i)}.AA_spcorr_umolkg(1:end),downcasts{cast_num(i)}.pt(1:end),'Linewidth',1,'Color',grey)
    end
    hold on
end

for i = 1:length(cast_num)    
    if max(cast_num(i) == bad_casts(:,1)) ~=1
        plot(downcasts{cast_num(i)}.AA_DOcorr_umolkg(1:end),downcasts{cast_num(i)}.pt(1:end),'Linewidth',1,'Color',maroon)
    end
end
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Downcasts')
grid on

subplot(1,2,2)
plot(NaN,NaN,'Color',grey)
hold on
plot(NaN,NaN,'Color',maroon)
plot(NaN,NaN,'.','markersize',20,'Color',red)
plot(NaN,NaN,'.k','markersize',20)

for i = 1:length(cast_num)
    if max(cast_num(i) == bad_casts(:,1)) ~=1
        plot(upcasts{cast_num(i)}.AA_spcorr_umolkg(1:end),upcasts{cast_num(i)}.pt(1:end),'Linewidth',1,'Color',grey)
    end
    hold on
end

for i = 1:length(cast_num)
    if max(cast_num(i) == bad_casts(:,2)) ~= 1
        plot(upcasts{cast_num(i)}.AA_DOcorr_umolkg,upcasts{cast_num(i)}.pt,'Linewidth',1,'Color',maroon)
    end
end

plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1==1),btlsum.pt(btlsum.NLMR_Outlier1==1),'.','markersize',20,'Color',red)
plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1==0),btlsum.pt(btlsum.NLMR_Outlier1==0),'.k','markersize',20)
plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2==1),btlsum.pt(btlsum.NLMR_Outlier2==1),'.','markersize',20,'Color',red)
plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2==0),btlsum.pt(btlsum.NLMR_Outlier2==0),'.k','markersize',20)
plot(btlsum.Winkler3_umolkg(btlsum.NLMR_Outlier3==1),btlsum.pt(btlsum.NLMR_Outlier3==1),'.','markersize',20,'Color',red)
plot(btlsum.Winkler3_umolkg(btlsum.NLMR_Outlier3==0),btlsum.pt(btlsum.NLMR_Outlier3==0),'.k','markersize',20)
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on
sgtitle([TitleString 'Aanderaa Oxygen'])
legend('Uncalibrated','Calibrated','Winklers Removed','Winklers Used','Location','NW')

figure
subplot(1,2,1)
for i = 1:length(cast_num)
    if max(cast_num(i) == bad_casts(:,1)) ~=1
        plot(downcasts{cast_num(i)}.DOcorr_umolkg(13:end),downcasts{cast_num(i)}.pt(13:end),'Linewidth',1,'Color',blue)
    end
    hold on
end

for i = 1:length(cast_num)    
    if max(cast_num(i) == bad_casts(:,1)) ~=1
        plot(downcasts{cast_num(i)}.AA_DOcorr_umolkg(1:end),downcasts{cast_num(i)}.pt(1:end),'Linewidth',1,'Color',maroon)
    end
end
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Downcasts')
grid on

subplot(1,2,2)
plot(NaN,NaN,'Color',blue)
hold on
plot(NaN,NaN,'Color',maroon)
plot(NaN,NaN,'.k','markersize',20)

for i = 1:length(cast_num)
    if max(cast_num(i) == bad_casts(:,1)) ~=1
        plot(upcasts{cast_num(i)}.DOcorr_umolkg,upcasts{cast_num(i)}.pt,'Linewidth',1,'Color',blue)
    end
    hold on
end

for i = 1:length(cast_num)
    if max(cast_num(i) == bad_casts(:,2)) ~= 1
        plot(upcasts{cast_num(i)}.AA_DOcorr_umolkg(1:end-13),upcasts{cast_num(i)}.pt(1:end-13),'Linewidth',1,'Color',maroon)
    end
end

plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1==1),btlsum.pt(btlsum.NLMR_Outlier1==1),'.','markersize',20,'Color',red)
plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1==0),btlsum.pt(btlsum.NLMR_Outlier1==0),'.k','markersize',20)
plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2==1),btlsum.pt(btlsum.NLMR_Outlier2==1),'.','markersize',20,'Color',red)
plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2==0),btlsum.pt(btlsum.NLMR_Outlier2==0),'.k','markersize',20)
plot(btlsum.Winkler3_umolkg(btlsum.NLMR_Outlier3==1),btlsum.pt(btlsum.NLMR_Outlier3==1),'.','markersize',20,'Color',red)
plot(btlsum.Winkler3_umolkg(btlsum.NLMR_Outlier3==0),btlsum.pt(btlsum.NLMR_Outlier3==0),'.k','markersize',20)
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on
sgtitle(TitleString)
legend('SBE43','Aanderaa','Winklers','Location','NW')

end
