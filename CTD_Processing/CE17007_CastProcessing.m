% Set up workspace 
clearvars; close all
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
addpath(genpath('G:\My Drive\Matlab_work\Github\GSW-Matlab'))
addpath(genpath('G:\My Drive\Matlab_work\Github\cmocean'))

dir = 'G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing';
cd(dir)
load CE17007_DOcal.mat

dc_dir = 'C:\Users\fogaren\Desktop\CE17007\SBE-profile-data\binned_1db\downcasts';
uc_dir = 'C:\Users\fogaren\Desktop\CE17007\SBE-profile-data\binned_1db\upcasts';
leah_dir = 'C:\Users\fogaren\Desktop\CE17007\SBE-profile-data\from_leah';

savefile = 0; % savefile == 1 for saving; savefile == 0, don't save
% bcodmo = 0; % write to csv files if == 1
% bco_dmo = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\BCO-DMO Submission\AR21';
%% Read in my processed casts 

% Downcasts 
cd(dc_dir)
files = ls('*.cnv');
cast_num = str2num(files(:,10:12)); % Pulls out cast numbers 

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

dcc = []; % Read Leah's calibrated SBE casts into matlab 
for j = 1:length(cast_num)
    dcc_in =import_dcc(downfiles(j,:));
    dcc_in.temp_flag1 = str2num(dcc_in.woce.t901);
    dcc_in.temp_flag2 = str2num(dcc_in.woce.t902);
    dcc_in.sal_flag1 = str2num(dcc_in.woce.sal1);
    dcc_in.sal_flag2 = str2num(dcc_in.woce.sal2); 
    dcc{cast_num(j)} = leah_cast(dcc_in);
end

ucc = [];
for j = 1:length(cast_num)
    ucc_in = import_dcc(upfiles(j,:));
    ucc_in.temp_flag1 = str2num(ucc_in.woce.t901);
    ucc_in.temp_flag2 = str2num(ucc_in.woce.t902);
    ucc_in.sal_flag1 = str2num(ucc_in.woce.sal1);
    ucc_in.sal_flag2 = str2num(ucc_in.woce.sal2); 
    ucc{cast_num(j)} = leah_cast(ucc_in);
end

%%
downcasts = []; upcasts = []; 
%
CTD_sen = 1;

cal = cal_cast4; SOC_type = 1; %%% The line to change 
cast_num = cal.casts;
CastStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC
CastNum_Start = min(cast_num); % Neede for variable SOC 
for j = 1:length(cast_num)
        downcasts{cast_num(j)} = process_cast(dcc{cast_num(j)}, mydowncast{cast_num(j)}, CTD_sen, cal, SOC_type, CastStartTime,CastNum_Start);
        upcasts{cast_num(j)} = process_cast(ucc{cast_num(j)}, myupcast{cast_num(j)}, CTD_sen, cal, SOC_type, CastStartTime,CastNum_Start);
end

cal = cal1; SOC_type = 3; %%% The line to change 
cast_num = cal.casts;
CastStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC
CastNum_Start = min(cast_num); % Neede for variable SOC 
for j = 1:length(cast_num)
        downcasts{cast_num(j)} = process_cast(dcc{cast_num(j)}, mydowncast{cast_num(j)}, CTD_sen, cal, SOC_type, CastStartTime,CastNum_Start);
        upcasts{cast_num(j)} = process_cast(ucc{cast_num(j)}, myupcast{cast_num(j)}, CTD_sen, cal, SOC_type, CastStartTime,CastNum_Start);
end

cal = cal2; SOC_type = 3; %%% The line to change 
cast_num = cal.casts;
CastStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 
CastNum_Start = min(cast_num); % Neede for variable SOC 
for j = 1:length(cast_num)
        downcasts{cast_num(j)} = process_cast(dcc{cast_num(j)}, mydowncast{cast_num(j)}, CTD_sen, cal, SOC_type, CastStartTime,CastNum_Start);
        upcasts{cast_num(j)} = process_cast(ucc{cast_num(j)}, myupcast{cast_num(j)}, CTD_sen, cal, SOC_type, CastStartTime,CastNum_Start);
end

cal = cal3; SOC_type = 3; %%% The line to change 
cast_num = [29,31,33,35,37]; % cal.casts;
CastStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 
CastNum_Start = min(cast_num); % Neede for variable SOC 
for j = 1:length(cast_num)
        downcasts{cast_num(j)} = process_cast(dcc{cast_num(j)}, mydowncast{cast_num(j)}, CTD_sen, cal, SOC_type, CastStartTime,CastNum_Start);
        upcasts{cast_num(j)} = process_cast(ucc{cast_num(j)}, myupcast{cast_num(j)}, CTD_sen, cal, SOC_type, CastStartTime,CastNum_Start);
end

cal = cal4; SOC_type = 1; %%% The line to change 
cast_num = cal.casts;
CastStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 
CastNum_Start = min(cast_num); % Neede for variable SOC 
for j = 1:length(cast_num)
        downcasts{cast_num(j)} = process_cast(dcc{cast_num(j)}, mydowncast{cast_num(j)}, CTD_sen, cal, SOC_type, CastStartTime,CastNum_Start);
        upcasts{cast_num(j)} = process_cast(ucc{cast_num(j)}, myupcast{cast_num(j)}, CTD_sen, cal, SOC_type, CastStartTime,CastNum_Start);
end

cal = cal5; SOC_type = 1; %%% The line to change 
cast_num = cal.casts;
CastStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 
CastNum_Start = min(cast_num); % Neede for variable SOC 
for j = 1:length(cast_num)
        downcasts{cast_num(j)} = process_cast(dcc{cast_num(j)}, mydowncast{cast_num(j)}, CTD_sen, cal, SOC_type, CastStartTime,CastNum_Start);
        upcasts{cast_num(j)} = process_cast(ucc{cast_num(j)}, myupcast{cast_num(j)}, CTD_sen, cal, SOC_type, CastStartTime,CastNum_Start);
end

cal = cal6; SOC_type = 3; %%% The line to change 
cast_num = cal.casts;
CastStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 
CastNum_Start = min(cast_num); % Neede for variable SOC 
for j = 1:length(cast_num) 
    if cast_num(j) ~= 146
        downcasts{cast_num(j)} = process_cast(dcc{cast_num(j)}, mydowncast{cast_num(j)}, CTD_sen, cal, SOC_type, CastStartTime,CastNum_Start);
        upcasts{cast_num(j)} = process_cast(ucc{cast_num(j)}, myupcast{cast_num(j)}, CTD_sen, cal, SOC_type, CastStartTime,CastNum_Start);
    end
end

cal = cal7; SOC_type = 1; %%% The line to change 
cast_num = cal.casts;
CastStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 
CastNum_Start = min(cast_num); % Neede for variable SOC 
for j = 1:length(cast_num)
        downcasts{cast_num(j)} = process_cast(dcc{cast_num(j)}, mydowncast{cast_num(j)}, CTD_sen, cal, SOC_type, CastStartTime,CastNum_Start);
        upcasts{cast_num(j)} = process_cast(ucc{cast_num(j)}, myupcast{cast_num(j)}, CTD_sen, cal, SOC_type, CastStartTime,CastNum_Start);
end


%% Plot final data
cal_cast_num = [cal_cast4.casts, cal1.casts, cal2.casts, cal3.casts, cal4.casts, cal5.casts, cal6.casts, cal7.casts];
Winks = unique(btlsum_tbl.Cast);

casts = cal_cast_num; %Winks; 
for j = 1:length(casts)
    plot_calibrated_DO(downcasts{casts(j)},upcasts{casts(j)},btlsum{casts(j)})
end


%% Plot just casts with Winklers 
cd('G:\My Drive\Matlab_work\BC')
run('GeneralSettings.m')
btl_num = unique(btlsum_tbl.Cast);
for j = 1:length(btl_num)
    figure
    plot(downcasts{btl_num(j)}.DOcorr_umolkg,downcasts{btl_num(j)}.prs,'Linewidth',1.4)
    hold on
    plot(upcasts{btl_num(j)}.DOcorr_umolkg,upcasts{btl_num(j)}.prs,'Linewidth',1.4)
    axis ij
    plot(btlsum{btl_num(j)}.Winkler_umolkg,btlsum{btl_num(j)}.prs,'.k','MarkerSize',20)
    plot(btlsum{btl_num(j)}.Winkler_umolkg(btlsum{btl_num(j)}.NLMR_Outlier == 3),btlsum{btl_num(j)}.prs(btlsum{btl_num(j)}.NLMR_Outlier == 3),'.','MarkerSize',20,'Color',red)
    plot(btlsum{btl_num(j)}.Winkler_umolkg(btlsum{btl_num(j)}.NLMR_Outlier == 1),btlsum{btl_num(j)}.prs(btlsum{btl_num(j)}.NLMR_Outlier == 1),'.','MarkerSize',20,'Color',yellow)

    ax = gca;
    ax.XAxisLocation = 'top';
    ylabel('pressure (db)')
    xlabel('DO (\mumol/kg)')
    title(['Cast: ' num2str(btl_num(j))])
end
%%
%Change folder to BCO-DMO location 
cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Calibration_Comparison')

%Create metadata file 
fheader = [sprintf('Filename,Cruise,Station,Down_Up,Lat,Lon,Date (UTC)') newline];
metadata_file = fopen('metadata_oxygenprofiles.csv','w');
fprintf(metadata_file,fheader);
fclose(metadata_file);

cast_num = cal_cast_num; 
for j = 1:length(cast_num)
    dwn_out = downcasts{cast_num(j)};

    metadata_file = fopen('metadata_oxygenprofiles.csv','a');
    castname_d = ['CE17007_' sprintf('%03d',cast_num(j)) 'd.csv']; castname_u = ['CE17007_' sprintf('%03d',cast_num(j)) 'u.csv'];
    cruise = 'CE17007'; cast = cast_num(j); d = 'd'; u = 'u';
    lat = dwn_out.lat(1); lon = dwn_out.lon(1);
    dt = datestr(dwn_out.StartTimeUTC(1)); 

    fprintf(metadata_file,'%s,%s,%d,%s,%.4f,%.4f,%s\n', castname_d,cruise,cast,d,lat,lon,dt);
    fprintf(metadata_file,'%s,%s,%d,%s,%.4f,%.4f,%s\n', castname_u,cruise,cast,u,lat,lon,dt);
    fclose(metadata_file);
end
%%
cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Calibration_Comparison')

% For adding questionable qa flags. 
% upcast10 = 40;
% upcast87 = 74;
% downcast117 = 34;
% Mark these depths as questionable for downcasts 1-70 (before pump change)

for j = 1:length(cast_num)
    dwn_out = downcasts{cast_num(j)};
    
    oxycur_flag = ones(size(dwn_out.t))*2;
    ctdoxy_flag = ones(size(dwn_out.t))*2;
    % No downcast flags 
    dwn_out.oxycur_flag = oxycur_flag;
    dwn_out.ctdoxy_flag = ctdoxy_flag;
    downcasts{cast_num(j)} = dwn_out; 

    fheader = ['CE17-007    Calibrated Oxygen Downcast   Station: ' num2str(cast_num(j)) newline...
    'Latitude: ' sprintf('%.4f',dwn_out.lat(1)) '   Longitude: ' sprintf('%.4f',dwn_out.lon(1))...
    '   ' datestr(dwn_out.StartTimeUTC(1)) newline...
    sprintf('CTDPRES, CTDTEMP1_ITS90, CTDTEMP1_flag, CTDSAL1_PSS78, CTDSAL1_flag, CTDTEMP2_ITS90, CTDTEMP2_flag, CTDSAL2_PSS78, CTDSAL2_flag,CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
    sprintf('dbar, deg_C, n.a., n.a., n.a., deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 

    fileIDd = fopen(['CE17-007_' sprintf('%03d',cast_num(j)) 'd.csv'],'w');
    fprintf(fileIDd,fheader);
    for ii = 1:length(dwn_out.prs)
        fprintf(fileIDd,'%.1f,%.3f,%d,%.3f,%d,%.3f,%d,%.3f,%d,%.4f,%d,%.1f,%d\n', ...
            dwn_out.prs(ii),dwn_out.temp1(ii),dwn_out.temp_flag1(ii),dwn_out.sal1(ii),dwn_out.sal_flag1(ii),dwn_out.temp2(ii),dwn_out.temp_flag2(ii),dwn_out.sal2(ii),dwn_out.sal_flag2(ii),dwn_out.oxy_volts(ii),oxycur_flag(ii),dwn_out.DOcorr_umolkg(ii),ctdoxy_flag(ii));
    end
    fclose(fileIDd);
end

for j = 1:length(cast_num)
    up_out = upcasts{cast_num(j)};

    oxycur_flag = ones(size(up_out.t))*2;
    ctdoxy_flag = ones(size(up_out.t))*2;
        if cast_num(j) == 12
            indbad1 = find(up_out.prs == 90);
            indbad2 = find(up_out.prs == 124);
               oxycur_flag(indbad1:indbad2) = 3;
               ctdoxy_flag(indbad1:indbad2) = 3; 
        end
        if cast_num(j) == 20
            indbad = find(up_out.prs == 26);
               oxycur_flag(1:indbad) = 3;
               ctdoxy_flag(1:indbad) = 3; 
        end
        if cast_num(j) == 63
            indbad = find(up_out.prs == 4);
               oxycur_flag(1:indbad) = 3;
               ctdoxy_flag(1:indbad) = 3; 
        end
        if cast_num(j) == 65
            indbad = find(up_out.prs == 4);
            oxycur_flag(1:indbad) = 3;
            ctdoxy_flag(1:indbad) = 3; 
        end
        if cast_num(j) == 66
            indbad = find(up_out.prs == 4);
            oxycur_flag(1:indbad) = 3;
            ctdoxy_flag(1:indbad) = 3; 
        end
    
    up_out.oxycur_flag = oxycur_flag;
    up_out.ctdoxy_flag = ctdoxy_flag;
    upcasts{cast_num(j)} = up_out; 

    fheader = ['CE17-007    Calibrated Oxygen Upcast   Station: ' num2str(cast_num(j)) newline...
    'Latitude: ' sprintf('%.4f',up_out.lat(1)) '   Longitude: ' sprintf('%.4f',up_out.lon(1))...
    '   ' datestr(up_out.StartTimeUTC(1)) newline...
    sprintf('CTDPRES, CTDTEMP1_ITS90, CTDTEMP1_flag, CTDSAL1_PSS78, CTDSAL1_flag, CTDTEMP2_ITS90, CTDTEMP2_flag, CTDSAL2_PSS78, CTDSAL2_flag,CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
    sprintf('dbar, deg_C, n.a., n.a., n.a., deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 

    fileIDu = fopen(['CE17-007_' sprintf('%03d',cast_num(j)) 'u.csv'],'w');
    fprintf(fileIDu,fheader);
    for ii = 1:length(up_out.prs)
        fprintf(fileIDu,'%.1f,%.3f,%d,%.3f,%d,%.3f,%d,%.3f,%d,%.4f,%d,%.1f,%d\n',...
            up_out.prs(ii),up_out.temp1(ii),up_out.temp_flag1(ii),up_out.sal1(ii),up_out.sal_flag1(ii),up_out.temp2(ii),up_out.temp_flag2(ii),up_out.sal2(ii),up_out.sal_flag2(ii),up_out.oxy_volts(ii),oxycur_flag(ii),up_out.DOcorr_umolkg(ii),ctdoxy_flag(ii));
    end
    fclose(fileIDu);
end
%% plot after flags applied 
close all
plot_calibrated_pTemp(downcasts,upcasts,cal_cast_num,btlsum,cal0,'CE17-007')

%% Save processed data 
if savefile == 1
    cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
    clear cal cal_cast_num
    save CE17007_Processed_KF.mat upcasts_* downcasts_* cal* btlsum_tbl 
end

%% Reads in my processed casts 
function cast = my_cast(cast)
    cast0 = cast;
    castnum = str2num(cast.source(10:12));
    fields = {'source','DataFileType','instrumentheaders','userheaders','vars','longname','units','span','mvars','mvars_format'...
        'scan','nbin','flag','SeasaveVersion','softwareheaders','t090C','t190C','c0mScm','c1mScm','lat','lon'};
    cast = rmfield(cast,fields);
    cast = struct2table(cast);
    cast.Properties.VariableNames = {'CastTimeS','prs','depth','oxy_volts','SBE_oxsol_umolkg'};
    cast.oxy_volts(cast.oxy_volts == -9.9900e-29) = NaN; % replaces no data flag with NaN
    cast.StartTimeUTC = ones(length(cast.CastTimeS),1)*datenum(cast0.instrumentheaders.SystemUTC); 
    cast.StartTimeUTC = datetime(cast.StartTimeUTC,'ConvertFrom','datenum');
    cast.CastTimeUTC = cast.StartTimeUTC + cast.CastTimeS/3600/24;
    cast.CastNum = ones(length(cast.prs),1)*castnum; 
    cast.CTDcal(:) = "True";
end
%% Read in Leah's calibrated casts 
function leah_cast = leah_cast(leah_cast)

    fields = {'woce','date','time','oxcr','ox','oxumkg','tran','alt'};
    leah_cast = rmfield(leah_cast,fields);
    leah_cast.station = leah_cast.station.*ones(length(leah_cast.prs),1);
    leah_cast.lat = leah_cast.lat.*ones(length(leah_cast.prs),1);
    leah_cast.lon = leah_cast.lon.*ones(length(leah_cast.prs),1);
    prs = min(leah_cast.prs):1:max(leah_cast.prs); prs = prs';
    leah_cast.station = double(interp1(leah_cast.prs,leah_cast.station,prs));
    leah_cast.lat = interp1(leah_cast.prs,leah_cast.lat,prs);
    leah_cast.lon = interp1(leah_cast.prs,leah_cast.lon,prs);
    leah_cast.t901 = interp1(leah_cast.prs,leah_cast.t901,prs);
    leah_cast.t902 = interp1(leah_cast.prs,leah_cast.t902,prs);
    leah_cast.sal1 = interp1(leah_cast.prs,leah_cast.sal1,prs);
    leah_cast.sal2 = interp1(leah_cast.prs,leah_cast.sal2,prs);
    leah_cast.temp_flag1 = interp1(leah_cast.prs,leah_cast.temp_flag1,prs);
    leah_cast.temp_flag2 = interp1(leah_cast.prs,leah_cast.temp_flag2,prs);
    leah_cast.sal_flag1 = interp1(leah_cast.prs,leah_cast.sal_flag1,prs);
    leah_cast.sal_flag2 = interp1(leah_cast.prs,leah_cast.sal_flag2,prs);
    leah_cast.prs = prs;

    leah_cast = struct2table(leah_cast);
    leah_cast.Properties.VariableNames = {'Station','lat','lon','prs','temp1','temp2','sal1','sal2','temp_flag1','temp_flag2','sal_flag1','sal_flag2'};    
end


%% Combines Files and calibrate oxygen data

function cast = process_cast(leah_cast,mycast,CTD_sen,cal,SOC_type,CruiseStartTime,CastNum_Start)
%    % Uses optimized cal.A cariable.  
    % Combine tables by prs variable 
    if height(mycast) <= height(leah_cast)
        cast = innerjoin(mycast,leah_cast);%,'Keys','prs');
    else 
        cast = innerjoin(leah_cast,mycast);%,'Keys','prs');
    end
    % cast = innerjoin(mycast,leah_cast); 

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
    cast.fit_del_cn = cast.Station - CastNum_Start; % Station change from beginning of it 
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
        .*(1 + cal.Acalc*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));
    end

    if SOC_type == 2 % SOC varies with cruise time

        x = [cast.oxy_volts,cast.O2sol_umolkg,cast.t,cast.prs,cast.cruise_d];
        
        % SBE functional form with SOC as a function of cruise time
        cast.DOcorr_umolkg = ((cal.SOCrate_dt*x(:,5)) + cal.SOCcalc_dt*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.Acalc_dt*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_dt*x(:,4))./(x(:,3) + 273.15));
    end

    if SOC_type == 3 % SOC varies with cast number 
        % 
        % x = [cast.oxy_volts,cast.O2sol_umolkg,cast.t,cast.prs,cast.Station];
        x = [cast.oxy_volts,cast.O2sol_umolkg,cast.t,cast.prs,cast.fit_del_cn];
        
        % SBE functional form with SOC as a function of cruise time
        cast.DOcorr_umolkg = ((cal.SOCrate_cn*x(:,5)) + cal.SOCcalc_cn*(x(:,1) + cal.VOFFSET)).*x(:,2)...
            .*(1 + cal.Acalc_cn*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
            .*exp((cal.Ecalc_cn*x(:,4))./(x(:,3) + 273.15));
    end

    cast.SOC_type = ones(length(cast.prs),1)*SOC_type; 

    % Reorder variables and remove unnecessary ones
    vars = {'Station','prs','depth','lat','lon','temp1','temp_flag1','temp2','temp_flag2','sal1','sal_flag1','sal2','sal_flag2',...
        'CastTimeS','CastTimeUTC','StartTimeUTC','cruise_d','fit_del_cn','CTDcal',...
        'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','DOcorr_umolkg','O2sol_umolkg','SOC_type'};
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
        plot(btlsum.Winkler_umolkg,btlsum.prs,'ok','MarkerFaceColor','k') 
        axis ij
        ylabel('Pressure (db)')
        xlabel('Oxygen (\mumol kg^-^1)')
        ax = gca;
        ax.XAxisLocation = 'top';
        sgtitle(['Cast ' num2str(downcasts.Station(1))])
    end

end

function plot_calibrated_pTemp(downcasts,upcasts,cast_num,btlsum,cal,TitleString)

grey = [0.5     0.5     0.5];
blue = [0     0.44706     0.74118];
red = [0.85098     0.32549    0.098039];
yellow = [0.92941     0.69412     0.12549];

f = figure;
f.Position = [100 100 840 500];
subplot(1,2,1)
for j = 1:length(cast_num)
    plot(downcasts{cast_num(j)}.DOcorr_umolkg(downcasts{cast_num(j)}.ctdoxy_flag == 2),downcasts{cast_num(j)}.pt(downcasts{cast_num(j)}.ctdoxy_flag == 2),'Linewidth',1.2)
    hold on
end
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Downcasts')
grid on

subplot(1,2,2)
for j = 1:length(cast_num)
    plot(upcasts{cast_num(j)}.DOcorr_umolkg(upcasts{cast_num(j)}.ctdoxy_flag == 2),upcasts{cast_num(j)}.pt(upcasts{cast_num(j)}.ctdoxy_flag == 2),'Linewidth',1.2)
    hold on
end

for j = 1:length(cast_num)
    try
        plot(btlsum{cast_num(j)}.Winkler_umolkg(btlsum{cast_num(j)}.NLMR_Outlier == 2),btlsum{cast_num(j)}.pt(btlsum{cast_num(j)}.NLMR_Outlier == 2),'.k','markersize',20)
    catch
        disp('No Winklers for Cast')
    end
end
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on
sgtitle(TitleString)

f = figure;
f.Position = [100 100 840 500];
subplot(1,2,1)
for j = 1:length(cast_num)

    x = [downcasts{cast_num(j)}.oxy_volts downcasts{cast_num(j)}.O2sol_umolkg ...
        downcasts{cast_num(j)}.t downcasts{cast_num(j)}.prs];
    DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));
    plot(DOuncorr_umolkg,downcasts{cast_num(j)}.pt,'Linewidth',1,'Color',grey)
    hold on
end

for j = 1:length(cast_num)    
    plot(downcasts{cast_num(j)}.DOcorr_umolkg(downcasts{cast_num(j)}.ctdoxy_flag == 2),downcasts{cast_num(j)}.pt(downcasts{cast_num(j)}.ctdoxy_flag == 2),'Linewidth',1,'Color',blue)
end
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Downcasts')
grid on

subplot(1,2,2)
plot(NaN,NaN,'Color',grey)
hold on
plot(NaN,NaN,'Color',blue)
plot(NaN,NaN,'.','MarkerSize',20,'Color',red)
plot(NaN,NaN,'.k','markersize',20)

for j = 1:length(cast_num)

    x = [upcasts{cast_num(j)}.oxy_volts upcasts{cast_num(j)}.O2sol_umolkg ...
        upcasts{cast_num(j)}.t upcasts{cast_num(j)}.prs];
    DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));
    plot(DOuncorr_umolkg,upcasts{cast_num(j)}.pt,'Linewidth',1,'Color',grey)
end

for j = 1:length(cast_num)
        plot(upcasts{cast_num(j)}.DOcorr_umolkg(upcasts{cast_num(j)}.ctdoxy_flag == 2),upcasts{cast_num(j)}.pt(upcasts{cast_num(j)}.ctdoxy_flag == 2),'Linewidth',1,'Color',blue)
end

for j = 1:length(cast_num)
        try
            plot(btlsum{cast_num(j)}.Winkler_umolkg(btlsum{cast_num(j)}.NLMR_Outlier == 1),btlsum{cast_num(j)}.pt(btlsum{cast_num(j)}.NLMR_Outlier == 1),'.','markersize',20,'Color',yellow)
            plot(btlsum{cast_num(j)}.Winkler_umolkg(btlsum{cast_num(j)}.NLMR_Outlier == 3),btlsum{cast_num(j)}.pt(btlsum{cast_num(j)}.NLMR_Outlier == 3),'.','markersize',20,'Color',red)
            plot(btlsum{cast_num(j)}.Winkler_umolkg(btlsum{cast_num(j)}.NLMR_Outlier == 2),btlsum{cast_num(j)}.pt(btlsum{cast_num(j)}.NLMR_Outlier == 2),'.k','markersize',20)
            
        catch 
            disp('No Winklers for Cast')
        end
end

ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on
sgtitle(TitleString)
legend('Uncalibrated','Calibrated','Questionable Winklers','Acceptable Winklers','Location','NW')

end