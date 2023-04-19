clearvars
addpath('G:\My Drive\Matlab_work\BC\Irminger\colab-workspace\CTD_Processing')
addpath('G:\My Drive\Matlab_work\BC\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\Functions\GSW')
%%
cd('C:\Users\fogaren\Documents\SBE\AR45\ctd_data\raw\downcasts'); % processed SBE cnvs

files = ls('*.cnv');
mydowncasts = str2num(files(:,7:9)); % Pulls out cast numbers that have bottle files 

downcast = []; % Read all my processed SBE cast into matlab 
for i = 1:length(files)
    cnv_in = readSBScnv(files(i,:));
    downcast{i} = my_cast(cnv_in);
end

%%
cd('G:\My Drive\Matlab_work\BC\Irminger\colab-workspace\CTD_Processing')
load AR45_CalCalculation.mat

cd('C:\Users\fogaren\Documents\SBE\AR45\ctd_data\final_processed\final_data\AR45_final_data\final_data')
downfiles = ls('*.dcc'); % List of Leah's calibrated bottle files 
downcasts = str2num(downfiles(:,6:8)); % Pulls out cast numbers that have bottle files 

% Make sure that there is a Leah cast file for each of my cast files 
if mydowncasts == downcasts 
    disp('Cast numbers Line Up')
    
else
    disp('Caution: Issue with Matching Cast Numbers!')
end
%%

dcc = []; % Read Leah's calibrated SBE casts into matlab 
for i = 1:length(downcasts)
    dcc_in =import_dcc(downfiles(i,:));
    dcc{i} = leah_cast(dcc_in);
end
%% combine files and calculate oxygen and hydrodynamic properties 
CTD_sen = 1; 
cast = [];
for i = 1:length(downcasts)
    table_down = join(dcc{i},downcast{i},'Keys','prs');
    cast{i} = process_cast(table_down,cal,CTD_sen);
end
%%
for i = 1:length(cast)
%     figure(1)
%     plot(cast{i}.lon(1),cast{i}.lat(1),'.','MarkerSize',20)
%     hold on

%     figure(2)
%     plot(cast{i}.DOcorr_umolkg,cast{i}.prs)
%     hold on
%     axis ij
%     ylabel('prs (db)')
%     xlabel('DO (\mumol/kg)')

    figure(3)
    plot(cast{i}.DOcorr_umolkg,cast{i}.pt)
    hold on
    ylabel('pt')
    xlabel('DO (\mumol/kg)')
    grid on
end
%%
for i = 1:length(btlcasts)
    cn = btlcasts(i);
    figure
    plot(cast{cn}.DOcorr_umolkg,cast{cn}.pt)
    axis ij
    hold on
    plot(btlsum_all.Winkler_umolkg(btlsum_all.Cast == cn),...
        btlsum_all.pt(btlsum_all.Cast == cn),'.k','MarkerSize',20)
    ax = gca;
    ax.XAxisLocation = 'top';
    ylabel('pt (db)')
    xlabel('DO (\mumol/kg)')
    title(['Cast: ' num2str(cn)])
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
        'scan','lat','lon','nbin','flag','SeasaveVersion','softwareheaders','t090C','t190C','c0mScm','c1mScm','sbeox0mL_L1',...
        'sbeox0mL_L2'};
    cast = rmfield(cast,fields);
    cast = struct2table(cast);
    cast.Properties.VariableNames = {'CastTimeS','prs','depth','oxy_volts','v7'};
    cast.StartTimeUTC = ones(length(cast.CastTimeS),1)*datenum(cast0.instrumentheaders.SystemUTC); 
    cast.StartTimeUTC = datetime(cast.StartTimeUTC,'ConvertFrom','datenum');
    cast.CastTimeUTC = cast.StartTimeUTC + cast.CastTimeS/3600/24;
    cast.CTDcal(:) = {'True'};
    cast.CTDcal = string(cast.CTDcal);
end

function cast = process_cast(cast,cal,CTD_sen)

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

    % Calculate oxygen concentration from Winkler calibrated SBE equation 
    [~, oxsol_uM] = sbsoxygensol(cast.t, cast.SP, 'sbs');
    cast.oxsol_umolkg = oxsol_uM*1000./cast.prho; % Convert to umol/kg

    x = [cast.oxy_volts,cast.oxsol_umolkg,cast.t,cast.prs];

    % SBE functional form without SOC drift 
    cast.DOcorr_umolkg = cal.SOCcalc*(x(:,1) + cal.Voffset).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.Ecalc*x(:,4))./(x(:,3) + 273.15));

    % Reorder variables and remove unnecessary ones
    vars = {'prs','depth','lat','lon','temp1','temp2','sal1','sal2','CastTimeS','CastTimeUTC','StartTimeUTC','CTDcal',...
        'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','DOcorr_umolkg','O2sol_umolkg'};
    cast = cast(:,vars); 
end
