clearvars
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
addpath(genpath('G:\My Drive\Matlab_work\Github\optode-response-time-Gordon'))

dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year7'; 
leah_dir = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year7\Final_From_Leah'; % Leah's calibrated bottle product 

AR45dir = ('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\AR45');
cd(AR45dir) % Read in AA calibration info from previous code with DO bottle samples 
load AR45_DO_Processed_KF.mat AA277
ns = 7; % Start of cast numbers in file name
ne = 9; % End of cast numbers in file name

dc_dir = 'C:\Users\fogaren\Documents\SBE\Year7\downcasts';
uc_dir = 'C:\Users\fogaren\Documents\SBE\Year7\upcasts';

savefile = 0; % savefile == 1 for saving; savefile == 0, don't save 
%%
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
downcasts = str2num(downfiles(:,ns-1:ne-1)); % Pulls out cast numbers  

upfiles = ls('*.ucc');
upcasts = str2num(upfiles(:,ns-1:ne-1));

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

%%
CTD_sen = 1; 
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
        Aanderaa_gain_cast(downcasts{cast_num(i)}, upcasts{cast_num(i)},AA277); 
end
%%

btlgain = [];
for i = 1:length(btl_num)
    gain = btlsum{btl_num(i)}.Aanderaa_gain;
    btlgain = [btlgain; gain];
end

gain_mean = nanmean(btlgain)
gain_std = nanstd(btlgain)

gain502 = gain_mean;

for i = 1:length(cast_num)
    [ downcasts{cast_num(i)}, upcasts{cast_num(i)}, btlsum{cast_num(i)}] = ...
        Aanderaa_gain_cast(downcasts{cast_num(i)}, upcasts{cast_num(i)},...
        btlsum{cast_num(i)},mean(gain502),cast_num(i)); 
end

for i = 1:length(btl_num)
    figure(300)
    subplot(2,2,1)
    plot(btlsum{btl_num(i)}.t,btlsum{btl_num(i)}.Winkler_umolkg - btlsum{btl_num(i)}.DOcorr_umolkg,'.k','Markersize',10)
    hold on; grid on
    ylabel({'Residual, Winkler - Aanderaa','(\mumol/kg)'}); xlabel('temp')

    subplot(2,2,2)
    plot(btlsum{btl_num(i)}.prs,btlsum{btl_num(i)}.Winkler_umolkg - btlsum{btl_num(i)}.DOcorr_umolkg,'.k','Markersize',10)
    hold on; grid on
    ylabel({'Residual, Winkler - Aanderaa','(\mumol/kg)'}); xlabel('prs (db)')

    subplot(2,2,3)
    plot(btlsum{btl_num(i)}.Winkler_umolkg,btlsum{btl_num(i)}.Winkler_umolkg - btlsum{btl_num(i)}.DOcorr_umolkg,'.k','Markersize',10)
    hold on; grid on
    ylabel({'Residual, Winkler - Aanderaa','(\mumol/kg)'}); xlabel('sal/prs corr. DO (\mumol/kg)')

    subplot(2,2,4)
    plot(btlsum{btl_num(i)}.Cast,btlsum{btl_num(i)}.Winkler_umolkg - btlsum{btl_num(i)}.DOcorr_umolkg,'.k','Markersize',10)
    hold on; grid on
    ylabel({'Residual, Winkler - Aanderaa','(\mumol/kg)'}); xlabel('Station')
    sgtitle(btlsum{cast_num(end)}.Cruise(1))
end
%%
plot_calibrated_pTemp(downcasts,upcasts,btlsum,cast_num)

%%
% cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year6')
% clear btlsum0 gain_mean gain_std 
% dt_Processed = datetime;
% save Year6_Processed_KF cast* btl* Gordon* gain* dt_Processed
%%
function [cast,cast0] = combine_CTD_files_Aanderaa(leah_cast,cast)

    % Format structure for conversion to table and convert to table 
    fields = {'woce','date','time','oxcr','ox','tran','flu','alt'};
    leah_cast = rmfield(leah_cast,fields);
    leah_cast.station = leah_cast.station.*ones(length(leah_cast.prs),1);
    leah_cast.lat = leah_cast.lat.*ones(length(leah_cast.prs),1);
    leah_cast.lon = leah_cast.lon.*ones(length(leah_cast.prs),1);
    leah_cast = struct2table(leah_cast);
    leah_cast.Properties.VariableNames = {'station','lat','lon','prs','temp1','temp2','sal1','sal2'};
    
    % Format structure for conversion to table and convert to table 
    cast0 = cast;
    fields = {'source','DataFileType','instrumentheaders','userheaders','vars','longname','units','span','mvars','mvars_format'...
        'scan','sbeox0V','lat','lon','flag','SeasaveVersion','softwareheaders'};
    cast = rmfield(cast,fields);
    try 
        cast = rmfield(cast,'nbin'); % cast 24 down is missing nbin variable? 
    end
    cast = struct2table(cast);
    cast.Properties.VariableNames = {'CastTimeS','prs','depth','t1','t2','cond1','cond2','Aanderaa_volts'};
    cast.StartTimeUTC = ones(length(cast.CastTimeS),1)*datenum(cast0.instrumentheaders.SystemUTC); 
    cast.StartTimeUTC = datetime(cast.StartTimeUTC,'ConvertFrom','datenum');
    cast.CastTimeUTC = cast.StartTimeUTC + cast.CastTimeS/3600/24;
    cast.CTDcal(:) = {'True'};
    cast.CTDcal = string(cast.CTDcal);
    cast = cast(:,{'prs','depth','Aanderaa_volts','CastTimeS','CastTimeUTC','StartTimeUTC','CTDcal'});  

    % Combine tables by prs variable 
%     
    if height(cast) > height(leah_cast)
        cast = join(leah_cast,cast,'Keys','prs'); 
    else
        cast = join(cast,leah_cast,'Keys','prs'); 
    end
end

% function [btlsum] = combine_btl_files_Aanderaa(leah_btl_file,btl_file,btlsum)
% 
%     % Format structure for conversion to table and convert to table 
%     leah_btl = readtable(leah_btl_file,'FileType','text');
%         if width(leah_btl) == 15
%             leah_btl.Properties.VariableNames = {'Bottle','prs','temp1','temp2','th168','th268','sal1','sal2','CTDoxy_mLL_nohyst','CTDoxy_umolkg_nohyst','flur_mgm3','tran','Meas_SAL','Meas_DO_mLL','QUAL'};
%             leah_btl = leah_btl(:,{'Bottle','prs','temp1','temp2','sal1','sal2','Meas_SAL','Meas_DO_mLL'});
%         end
%     leah_btl.Meas_SAL(leah_btl.Meas_SAL == -9) = NaN; % replaces no data flag with NaN
%     leah_btl.Meas_DO_mLL(leah_btl.Meas_DO_mLL == -9) = NaN; % replaces no data flag with NaN
%     
%     % Format structure for conversion to table and convert to table 
%     btl = readtable(btl_file,'TextType','string');
%     btl = btl(:,{'Bottle','Date','PrDM','DepSM','Latitude','Longitude','Sbeox0V','V6'});
%     btl.Properties.VariableNames = {'Bottle','Date','PrDM','depth','lat','lon','oxy_volts','Aanderaa_volts'};
%     btl.CTDcal(:) = {'True'};
%     btl.CTDcal = string(btl.CTDcal);
%     
%     % Combine tables by Bottle variable 
%     btlsum0 = join(leah_btl,btl,'Keys','Bottle');
%     btlsum = join(btlsum0,btlsum,'Keys','Bottle');
%     
% end

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
            btlsum.Winkler_umolkg = btlsum.Winkler_mLL*1000*44.661./btlsum.prho; % uses potential density 
            
      % Find bottle value at specific depth using lag corrected upcast 
            ind = [];
            for i = 1:length(btlsum.prs)
                [ind(i),~] = find(round(btlsum.prs(i)) == castu.prs);
            end

            btlsum.Aanderaa_spcorr_umolkg = castu.Aanderaa_spcorr_umolkg(ind);
      % Calculate gain from Winkler over Aanderaa lag/sal/press corrected values
            btlsum.Aanderaa_gain = btlsum.Winkler_umolkg./btlsum.Aanderaa_spcorr_umolkg;

            % Reorder variables and remove unnecessary ones
            btlvars = {'Bottle','Date','prs','depth','lat','lon','temp1','temp2','sal1','sal2','Discrete_Salinity_psu','Cruise','Asset','Cast','CTDcal',...
                'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','Winkler_mLL','Winkler_umolkg','Aanderaa_volts','Aanderaa_spcorr_umolkg','Aanderaa_gain'};
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
        plot(btlsum.Winkler_umolkg,btlsum.prs,'ok','MarkerFaceColor','k')
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
        plot(btlsum{cast_num(i)}.Winklers_umolkg,btlsum{cast_num(i)}.pt,'.k','markersize',20)
    end
end

ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on
sgtitle(btlsum{cast_num(end)}.Cruise(1))

figure
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
for i = 1:length(cast_num)
    plot(upcasts{cast_num(i)}.Aanderaa_spcorr_umolkg,upcasts{cast_num(i)}.pt,'Linewidth',1,'Color',grey)
    hold on
    plot(upcasts{cast_num(i)}.DOcorr_umolkg,upcasts{cast_num(i)}.pt,'Linewidth',1,'Color',blue)
end

for i = 1:length(cast_num)
    try
        plot(btlsum{cast_num(i)}.Winklers,btlsum{cast_num(i)}.pt,'.k','markersize',20)
    end
end

ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on
sgtitle(btlsum{cast_num(end)}.Cruise(1))

end