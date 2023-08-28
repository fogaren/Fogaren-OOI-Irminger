clearvars
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
addpath(genpath('G:\My Drive\Matlab_work\Github\optode-response-time-Gordon'))

dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year7'; 
cal_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year7\Final_From_Leah'; % Leah's calibrated bottle product 

AR45dir = ('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\AR45');
cd(AR45dir) % Read in AA calibration info from previous code with DO bottle samples 
load AR45_DO_Processed_KF.mat AA277
ns = 7; % Start of cast numbers in file name
ne = 9; % End of cast numbers in file name

dc_dir = 'C:\Users\fogaren\Documents\SBE\Year7\downcasts';
uc_dir = 'C:\Users\fogaren\Documents\SBE\Year7\upcasts';

savefile = 0; % savefile == 1 for saving; savefile == 0, don't save 
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
cd(cal_dir)
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
cd(cal_dir)

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

% Same Oxygen Sensor for whole cruise 
% Calibration standards from SBE xmlcon file 

cal.SOC = double(5.03070e-001);
cal.VOFFSET = double(-4.89500e-001);
cal.A = double(-4.72970e-003);
cal.B = double(2.09580e-004);
cal.C = double(-3.11120e-006);
cal.E = double(3.60000e-002);
cal.Tau20 = double(1.35000e+000);
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '0794';
cal.OCALDATE = '09-Jul-20';

H = [-0.033, 5000, 1450]; % Default 
%%
CTD_primary = [1:10 18 19]; % Casts that use primary CTD from Leah's Calibration Report 
SOC_type = 0; % Uses SBE calibration coefficients for SBE 43
downcasts = []; upcasts = []; 
% Combine files and calculate sea water properties for CTD sensor number 
for i = 1:length(cast_num) % Number of bottle summary files 
    if max(cast_num(i) == CTD_primary) == 1 
        CTD_sen = 1;
    else 
        CTD_sen = 2;
    end

    downcasts{cast_num(i)} = process_cast_AA(dcc{cast_num(i)}, mydowncast{cast_num(i)}, CTD_sen, cal, SOC_type);
    upcasts{cast_num(i)} = process_cast_AA(ucc{cast_num(i)}, myupcast{cast_num(i)}, CTD_sen, cal, SOC_type);

end
%% This cell takes a while and was already run, thickenss == 26.5 um
% % Aanderaa calibration
% prs_lim = [50 500];
% 
% Gordon2020 = []; 
% for i = 1:length(cast_num)
%     [ Gordon2020{cast_num(i)}] = Aanderaa_timelag_calc(downcasts{cast_num(i)}, upcasts{cast_num(i)},prs_lim);
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
%% Convert AA volts to oxygen concentration
% From Aanderaa calibration file for SN 277 
AA277.foilcoeff = [2.798512E-03	1.179460E-04	2.512907E-06	2.262806E+02	-3.570254E-01	-6.104725E+01	4.558537E+00];
AA277.conccoeff = [0.000000E+00	1.000000E+00];
AA277.salset = 0;  % salinity set at 0  
AA277.D = 0.027; % Default is 0.032
AA277.calc_thickness = 26.5; % um Calculated in cell above 
% mean == 26.2222 and median == 26.5 (with 1 cast removed) 

for i = 1:length(cast_num)
    [ downcasts{cast_num(i)}, upcasts{cast_num(i)}] = ...
        Aanderaa_gain_cast(downcasts{cast_num(i)}, upcasts{cast_num(i)},AA277,cast_num(i)); 
end
%%
% cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\BCO-DMO Submission\AR46')
% for i = 1:length(cast_num)
%     dwn_out = downcasts{cast_num(i)};
% 
%         temp_flag = ones(size(dwn_out.t))*2;
%         sal_flag = ones(size(dwn_out.t))*2;
%         oxycur_flag = ones(size(dwn_out.t))*3;
%         ctdoxy_flag = ones(size(dwn_out.t))*3;
% 
% 
%     fheader = ['AR46    Calibrated Oxygen Downcast   Station: ' num2str(cast_num(i)) newline...
%     'Latitude: ' sprintf('%.4f',dwn_out.lat(1)) '   Longitude: ' sprintf('%.4f',dwn_out.lon(1))...
%     '   ' datestr(dwn_out.StartTimeUTC(1)) newline...
%     sprintf('CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, AAOXYCUR, AAOXYCUR_flag, AAOXY, AAOXY_flag') newline...
%     sprintf('dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 
% 
%     fileIDd = fopen(['AR46_' sprintf('%03d',cast_num(i)) 'd.csv'],'w');
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
%         temp_flag = ones(size(up_out.t))*2;
%         sal_flag = ones(size(up_out.t))*2;
%         oxycur_flag = ones(size(up_out.t))*3;
%         ctdoxy_flag = ones(size(up_out.t))*3;
% 
%     fheader = ['AR46    Calibrated Oxygen Upcast   Station: ' num2str(cast_num(i)) newline...
%     'Latitude: ' sprintf('%.4f',up_out.lat(1)) '   Longitude: ' sprintf('%.4f',up_out.lon(1))...
%     '   ' datestr(up_out.StartTimeUTC(1)) newline...
%     sprintf('CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, AAOXYCUR, AAOXYCUR_flag, AAOXY, AAOXY_flag') newline...
%     sprintf('dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 
% 
%     fileIDu = fopen(['AR46_' sprintf('%03d',cast_num(i)) 'u.csv'],'w');
%     fprintf(fileIDu,fheader);
%     for ii = 1:length(up_out.prs)
%         fprintf(fileIDd,'%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n', up_out.prs(ii),up_out.t(ii),temp_flag(ii),up_out.SP(ii),sal_flag(ii),up_out.Aanderaa_volts(ii),oxycur_flag(ii),up_out.DOcorr_umolkg(ii),ctdoxy_flag(ii));
%     end
%     fclose(fileIDu);
% end
%% Plot finalized AA Oxygen plots 
bad_casts = [NaN 19];
    plot_calibrated_pTemp_AA(downcasts,upcasts,cast_num,bad_casts)

%% Save processed data 
if savefile == 1
    upcasts_yr7 = upcasts;
    downcasts_yr7 = downcasts;
    cast_num_yr7 = cast_num;
    dt_Processed_yr7 = datetime('now');
    
    clear upcasts downcasts  
    cd(dir)
    cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Processed')
    save Year7_Processed_KF.mat upcasts_* downcasts_* cast_num_* AA* dt_Processed_*
end

if savefile == 1
    upcasts_AR46 = upcasts;
    downcasts_AR46 = downcasts;
    cast_num_AR46 = cast_num;
    dt_KF_Processed_AR46 = datetime('now');
    
    cd(dir)
    save AR46_DO_Processed_KF.mat upcasts_* downcasts_* cast_num_* AA* dt_KF_Processed_*
end
%%

function leah_cast = leah_cast(leah_cast)

    fields = {'woce','date','time','oxcr','ox','tran','flu','alt'};
    leah_cast = rmfield(leah_cast,fields);
    leah_cast.station = leah_cast.station.*ones(length(leah_cast.prs),1);
    leah_cast.lat = leah_cast.lat.*ones(length(leah_cast.prs),1);
    leah_cast.lon = leah_cast.lon.*ones(length(leah_cast.prs),1);
    leah_cast = struct2table(leah_cast);
    leah_cast.Properties.VariableNames = {'Station','lat','lon','prs','temp1','temp2','sal1','sal2'};    
end

function cast = my_cast(cast)
    cast0 = cast;
    fields = {'source','DataFileType','instrumentheaders','userheaders','vars','longname','units','span','mvars','mvars_format'...
        'scan','lat','lon','nbin','flag','SeasaveVersion','softwareheaders','t090C','t190C','c0mScm','c1mScm'};
    cast = rmfield(cast,fields);
    cast = struct2table(cast);
    cast.Properties.VariableNames = {'CastTimeS','prs','depth','oxy_volts','Aanderaa_volts'};
    cast.StartTimeUTC = ones(length(cast.CastTimeS),1)*datenum(cast0.instrumentheaders.SystemUTC); 
    cast.StartTimeUTC = datetime(cast.StartTimeUTC,'ConvertFrom','datenum');
    cast.CastTimeUTC = cast.StartTimeUTC + cast.CastTimeS/3600/24;
    cast.CTDcal(:) = {'True'};
    cast.CTDcal = string(cast.CTDcal);
end


function cast = process_cast_AA(leah_cast,mycast,CTD_sen,cal,SOC_type)

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
%     cast.cruise_d = datenum(cast.StartTimeUTC) - datenum(CruiseStartTime); % Cruise time in days 

        x = [cast.oxy_volts,cast.O2sol_umolkg,cast.t,cast.prs];    
    if SOC_type == 0 % Constant SOC value of SBE calibration coefficients 

        % SBE functional form without SOC drift 
        cast.DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
        .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
        .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));
    end

    cast.SOC_type = ones(length(cast.prs),1)*SOC_type; 

    % Reorder variables and remove unnecessary ones
    vars = {'Station','prs','depth','lat','lon','temp1','temp2','sal1','sal2','CastTimeS','CastTimeUTC','StartTimeUTC','CTDcal',...
        'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','DOuncorr_umolkg','O2sol_umolkg','SOC_type','Aanderaa_volts'};
    cast = cast(:,vars); 
    
end

function [ Gordon2020 ] = Aanderaa_timelag_calc(castd,castu,zlim)
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
    CTD_sen = castd.CTD_sen(1); 

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

function [castd, castu] = Aanderaa_gain_cast(castd,castu,AA,cast_num)

    % Call correct_oxygen_profile_wTemp to output Oxygen data [volts] corrected for timelag    
    indd = ~(isnan(datenum(castd.CastTimeUTC)) | isnan(castd.Aanderaa_volts) | isnan(castd.t));
    indu = ~(isnan(datenum(castu.CastTimeUTC)) | isnan(castu.Aanderaa_volts) | isnan(castu.t));
    
    [ castd.Aanderaa_volts_lagcorr ] = correct_oxygen_profile_wTemp(datenum(castd.CastTimeUTC(indd)), castd.Aanderaa_volts(indd), castd.t(indd)', AA.calc_thickness );
    [ castu.Aanderaa_volts_lagcorr ] = correct_oxygen_profile_wTemp(datenum(castu.CastTimeUTC(indu)), castu.Aanderaa_volts(indu), castu.t(indu)', AA.calc_thickness );

     A = 10; B = 12; %note that this should be the same for all optodes
    castd.Aanderaa_volts_lagcorr_sm = smoothdata(castd.Aanderaa_volts_lagcorr,'movmean',19,'omitnan');
%     Calculate uncalibrated oxygen concentration for downcasts 
    castd.Aanderaa_calphase = B.*castd.Aanderaa_volts_lagcorr_sm + A; 
    [optode_uM, ~] = aaoptode_sternvolmer(AA.foilcoeff, castd.Aanderaa_calphase, castd.t, castd.SP, castd.prs);    
     optode_uM = AA.conccoeff(1) + AA.conccoeff(2).*optode_uM;
    castd.Aanderaa_spcorr_umolkg = aaoptode_salpresscorr_Dchoice(optode_uM, castd.t, castd.SP, castd.prs, AA.salset,AA.D);
    
    castu.Aanderaa_volts_lagcorr_sm = smoothdata(castu.Aanderaa_volts_lagcorr,'movmean',19,'omitnan');
%     Calculate uncalibrated oxygen concentration for upcasts 
    castu.Aanderaa_calphase = B.*castu.Aanderaa_volts_lagcorr_sm + A; 
    [optode_uM, ~] = aaoptode_sternvolmer(AA.foilcoeff, castu.Aanderaa_calphase, castu.t, castu.SP, castu.prs);    
     optode_uM = AA.conccoeff(1) + AA.conccoeff(2).*optode_uM;
    castu.Aanderaa_spcorr_umolkg = aaoptode_salpresscorr_Dchoice(optode_uM, castu.t, castu.SP, castu.prs, AA.salset,AA.D);   
     
    % Apply bottle-calculated AA gain 
    castd.DOcorr_umolkg = castd.Aanderaa_spcorr_umolkg *AA.gain;
    castu.DOcorr_umolkg = castu.Aanderaa_spcorr_umolkg *AA.gain;   
% 
%     % Reorder variables and remove unnecessary ones
%     vars = {'Station','prs','depth','lat','lon','temp1','temp2','sal1','sal2','CastTimeS','CastTimeUTC','StartTimeUTC','CTDcal',...
%         'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','DOuncorr_umolkg','O2sol_umolkg','SOC_type',...
%         'AA_volts','AA_volts_lagcorr','AA_volts_lagcorr_sm','AA_calphase','AA_spcorr_umolkg','AA_DOcorr_umolkg'};

    % Reorder variables and remove unnecessary ones
    vars = {'prs','depth','lat','lon','temp1','temp2','sal1','sal2','CastTimeS','CastTimeUTC','StartTimeUTC','CTDcal',...
        'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','Aanderaa_volts','Aanderaa_volts_lagcorr','Aanderaa_volts_lagcorr_sm',...
        'Aanderaa_calphase','Aanderaa_spcorr_umolkg','DOcorr_umolkg'};

    castu = castu(:,vars);
    castd = castd(:,vars); 


navy = [0.078431     0.16863     0.54902];
maroon = [0.63529    0.078431     0.18431];         
        
figure
subplot(1,3,1)
% plot(movmean(castd.DOuncorr_umolkg,20),castd.prs,'Linewidth',1.2)
% hold on
% plot(movmean(castu.DOuncorr_umolkg,20),castu.prs,'Linewidth',1.2)
plot(castd.DOcorr_umolkg,castd.prs,'Linewidth',1.2,'Color',navy)
hold on
plot(castu.DOcorr_umolkg,castu.prs,'Linewidth',1.2,'Color',maroon)
axis ij
ylabel('Pressure (db)')
xlabel('AA Oxygen (\mumol kg^-^1)')
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

function plot_calibrated_pTemp_AA(downcasts,upcasts,cast_num,bad_casts)
% For plotting purposes 
ooi_latlon = [59.9341, -39.4673
    59.8177, -39.8412
    59.7155, -39.3148];
grey = [0.5     0.5     0.5];
blue = [0     0.44706     0.74118];
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
sgtitle('Year 7: AR46 AA Oxygen')

subplot(1,3,2)
for i = 1:length(cast_num)
    if max(cast_num(i) == nanmean(bad_casts,2)) ~=1
        plot(downcasts{cast_num(i)}.DOcorr_umolkg,downcasts{cast_num(i)}.pt,'Linewidth',1.2)
        hold on
    end
end
ylabel('PT (\circC)')
xlabel('AA DO (\mumol kg^-^1)')
title('Downcasts')
grid on

subplot(1,3,3)
for i = 1:length(cast_num)
    if max(cast_num(i) == nanmean(bad_casts,2)) ~=1
        plot(upcasts{cast_num(i)}.DOcorr_umolkg,upcasts{cast_num(i)}.pt,'Linewidth',1.2)
        hold on
    end
end

ylabel('PT (\circC)')
xlabel('AA DO (\mumol kg^-^1)')
title('Upcasts')
grid on

f = figure;
f.Position = [100 100 840 500];
subplot(1,2,1)
for i = 2:length(cast_num)
    if max(cast_num(i) == bad_casts(:,1)) ~=1
        plot(downcasts{cast_num(i)}.Aanderaa_spcorr_umolkg,downcasts{cast_num(i)}.pt,'Linewidth',1,'Color',grey)
        hold on
    end
end

for i = 2:length(cast_num)    
    if max(cast_num(i) == bad_casts(:,1)) ~=1
        plot(downcasts{cast_num(i)}.DOcorr_umolkg,downcasts{cast_num(i)}.pt,'Linewidth',1,'Color',blue)
    end
end
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
ylim([1 12])
title('Downcasts')
grid on

subplot(1,2,2)
plot(NaN,NaN,'Color',grey)
hold on
plot(NaN,NaN,'Color',blue)

for i = 2:length(cast_num)

    if max(cast_num(i) == bad_casts(:,2)) ~= 1
        plot(upcasts{cast_num(i)}.Aanderaa_spcorr_umolkg,upcasts{cast_num(i)}.pt,'Linewidth',1,'Color',grey)
    end
end

for i = 2:length(cast_num)
    if max(cast_num(i) == bad_casts(:,2)) ~= 1
        plot(upcasts{cast_num(i)}.DOcorr_umolkg,upcasts{cast_num(i)}.pt,'Linewidth',1,'Color',blue)
    end
end

ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
ylim([1 12])
title('Upcasts')
grid on
sgtitle('Year 7: AR46')
legend('Uncalibrated','Calibrated','Location','NW')

end
