% clearvars; clc; 
% addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
% addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
% addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')

ns = 9; % Start of cast numbers in file name
ne = 11; % End of cast numbers in file name 

dc_dir = 'C:\Users\fogaren\Desktop\Irminger12\ctd\cnv\downcasts';
uc_dir = 'C:\Users\fogaren\Desktop\Irminger12\ctd\cnv\upcasts';

savefile = 0; % savefile == 1 for saving; savefile == 0, don't save
%% Read in my processed casts 

% Downcasts 
cd(dc_dir)
files = ls('*.cnv');
cast_num = unique(str2num(files(:,ns:ne))); % Pulls out cast numbers 

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
CTD_sen = btlsum_tbl.CTD_sen(1); % Sensor package to use for calibration; same as bottle processing 
SOC_type = btlsum_tbl.SOC_type(1); % 1 = constant, % 2 = changes as a function of cruise time % 3 = changes as a function of station number 

CruiseStartTime = mydowncast{cast_num(1)}.StartTimeUTC(1); % Needed for variable SOC 

btlsum = []; 
downcasts = []; upcasts = []; 
for i = 1:length(cast_num)
        btlsum{cast_num(i)} = btlsum_tbl(btlsum_tbl.Cast == cast_num(i),:); 
        downcasts{cast_num(i)} = process_cast_noCTDcal(mydowncast{cast_num(i)}, CTD_sen, cal_all, SOC_type, CruiseStartTime,cast_num(i));
        upcasts{cast_num(i)} = process_cast_noCTDcal( myupcast{cast_num(i)}, CTD_sen, cal_all, SOC_type, CruiseStartTime,cast_num(i));
end

%% Plot final data
for i = 1:length(cast_num)
    plot_calibrated_DO(downcasts{cast_num(i)},upcasts{cast_num(i)},btlsum{cast_num(i)})
end

%%
plot_calibrated_pTemp(downcasts,upcasts,cast_num,btlsum,cal_all,'RR2505')
%% Look at pH data
pH_casts = [3 6 7 10 14 15 19];
for j = 1:length(pH_casts)
    plot_pH(downcasts{pH_casts(j)},upcasts{pH_casts(j)})
end

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
sgtitle('RR2505 Downcasts')

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
sgtitle('RR2505 Upcasts')
%% Pulling variables for cruise report

addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')

cnv_dir = 'C:\Users\fogaren\Desktop\Irminger12\ctd\cnv';

ns = 8; % Start of cast numbers in file name
ne = 10; % End of cast numbers in file name 

cd(cnv_dir)
files = ls('*.cnv');
file_num = str2num(files(:,ns:ne)); % Pulls out cast numbers 

atmax_lat = []; atmax_lon = [];
ctd_date = []; max_depth = [];
for j = 1:length(file_num)
    cnv_in = readSBScnv(files(j,:));
    atmax_lat(j) = cnv_in.lat(find(cnv_in.pm == max(cnv_in.pm)));
    atmax_lon(j) = cnv_in.lon(find(cnv_in.pm == max(cnv_in.pm)));
    ctd_start(j) = datenum(cnv_in.instrumentheaders.SystemUTC);
    max_depth(j) = int64(max(cnv_in.depSM));
end
N = 'N';
atmax_latlon = [atmax_lat'  atmax_lon'*-1];
atmax_latlon = atmax_latlon(2:end,:);
max_depth = max_depth'; ctd_dn = ctd_start';
ctd_dn = ctd_dn(2:end,:);
ctd_date = datestr(ctd_dn);

btlsum_out = [];
for j = 1:length(btlcasts)
    btlsum_out = [btlsum_out; btlsum{j}];
end

%% Reads in my processed casts 
function cast = my_cast(cast)
    cast0 = cast;
    fields = {'source','DataFileType','instrumentheaders','userheaders','vars','longname','units','span','mvars','mvars_format'...
        'scan','nbin','flag','SeasaveVersion','softwareheaders'};
    cast = rmfield(cast,fields);
    cast = struct2table(cast);
    cast.Properties.VariableNames = {'CastTimeS','prs','depth','temp1','temp2','cond1','cond2','oxy_volts','pH','lat','lon'};
    cast.oxy_volts(cast.oxy_volts == -9.9900e-29) = NaN; % replaces no data flag with NaN
    cast.StartTimeUTC = ones(length(cast.CastTimeS),1)*datenum(cast0.instrumentheaders.SystemUTC); 
    cast.StartTimeUTC = datetime(cast.StartTimeUTC,'ConvertFrom','datenum');
    cast.CastTimeUTC = cast.StartTimeUTC + cast.CastTimeS/3600/24;
    cast.CTDcal(:) = {'False'};
    cast.CTDcal = string(cast.CTDcal);
    cast.sal1 = gsw_SP_from_C(cast.cond1,cast.temp1,cast.prs);
    cast.sal2 = gsw_SP_from_C(cast.cond2,cast.temp2,cast.prs);
end
%% Map from Monica
cd('G:\My Drive\Matlab_work\BC')
run('GeneralSettings.m')
addpath(genpath('G:\My Drive\Matlab_work\Functions\m_map1.4'))
addpath(genpath('G:\My Drive\Matlab_work\Github\cmocean'))
% osnap2022_watersampling_MN.m

% Plots section of where water samples have been taken along AR07-W line
% Monica Nelson, 6 Sept 2022
% 
% cd C:\Users\monic\Documents\MATLAB\Research\OSNAP\OSNAP2022

% Code uses m_map package for making the maps. 
% Download the package if you don't have it and add it to your filepath.
% https://www.eoas.ubc.ca/~rich/map.html

% plot map
% update filepath to where you have bathymetry data saved....
cd('C:\Users\fogaren\Desktop\Irminger12')
bathy = load('NAbathy.mat'); 
    % this bathymetry isn't as high resolution as the bedmachine bathymetry
    % ("cfbathy") but is decent and faster
   
% OOI FLB lat and lon for reference
    % load C:\Users\monic\Documents\MATLAB\Research\IrmTStransport\OOI_lat_lon_rough
lat_ooi = 59.7182; lon_ooi = -39.3536;

ooi_2024 = NaN;
OSNAP = [(59 + 54.204/60) (41 + 06.594/60) % Pulled from AR84-01 Crusie Report 
    (59 + 51.534/60) (40 + 41.626/60)
    (59 + 48.912/60) (40 + 16.746/60)
    (59 + 38.777/60) (38 + 33.893/60)];

SUMO = [(59 + 56.497/60), (39 + 34.583/60)]; 
HYPM = [(59 + 58.288/60), (39 + 31.811/60)];
FLMA = [(59 + 46.048/60), (39 + 50.606/60)];
FLMB = [(59 + 42.913/60), (39 + 18.909/60)];

lon_min = -41.5; lon_max = -38;
ilon = bathy.bathylon >= lon_min & bathy.bathylon <= lon_max;
lat_min = 59.25; lat_max = 60.25;
ilat = bathy.bathylat >= lat_min & bathy.bathylat <= lat_max;
[BLON,BLAT] = meshgrid(bathy.bathylon(ilon),bathy.bathylat(ilat));

figure
m_proj('mercator','long',[lon_min lon_max],'lat',[lat_min lat_max])
    % add bathymetry
m_contourf(BLON,BLAT,bathy.bathy(ilat,ilon),[-4500:100:0],'color','none');%[.5 .5 .5]) %,'linewidth',2)
hold on
caxis([-3500 0]); cmocean('topo','pivot',0)
m_contour(BLON,BLAT,bathy.bathy(ilat,ilon),[-5000:1000:0],'color','k') % 'linewidth',2)
  
m_contour(BLON,BLAT,bathy.bathy(ilat,ilon),[0 0],'k', 'linewidth',2)
    % all CTD stations

p3 = m_scatter(-SUMO(2), SUMO(1),75,'^k','MarkerFaceColor','y');
p4 = m_scatter(-HYPM(2), HYPM(1),75,'^k','MarkerFaceColor','y');
p2 = m_scatter(-OSNAP(:,2),OSNAP(:,1),75,'vk','MarkerFaceColor','m');
p1 = m_scatter(-atmax_latlon(2:end,2),atmax_latlon(2:end,1),30,'r*'); 
m_scatter(-FLMA(2), FLMA(1),75,'^k','MarkerFaceColor','y');
m_scatter(-FLMB(2), FLMB(1),75,'^k','MarkerFaceColor','y');

p5 = m_scatter(-atmax_latlon(pH_casts,2),atmax_latlon(pH_casts,1),30,'*c');

p4 = m_line([-39.3 -38.942 -38.942 -38.942 -39.3 -38.942 -39.3 -39.3],[59.927 59.927 59.927 59.792 59.792 59.792 59.792 59.927],'linewi',1.5,'color','g');

m_text(-(41 + 06.594/60+0.05),(59 + 54.204/60)+0.05,'M1','Fontsize',12)
m_text(-(40 + 41.626/60+0.05),(59 + 51.534/60)+0.05,'M2','Fontsize',12)
m_text(-(40 + 16.746/60+0.05),(59 + 48.912/60)+0.05,'M3','Fontsize',12)
m_text(-(38 + 33.893/60+0.05),(59 + 38.777/60)+0.05,'M4','Fontsize',12)
m_text(-(39 + 34.583/60+0.06),(59 + 56.497/60)+0.07,'SUMO','Fontsize',12); 
m_text(-(39 + 31.811/60+0.34),(59 + 58.288/60-0.05),'HYPM','Fontsize',12);
m_text(-(39 + 50.606/60+0.24), (59 + 46.048/60-0.05),'FLMA','Fontsize',12);
m_text(-(39 + 18.909/60+0.02), (59 + 42.913/60-0.05),'FLMB','Fontsize',12);

title('Irminger 12: CTD Stations')
m_grid('tickdir','out','box','fancy','fontsize',12)
set(gcf,'position',[100 100 1000 500])
legend([p1 p5 p3 p2 p4],[{'CTD'},{'CTD-pH'},{'OOI'},{'OSNAP'},{'Glider Box'}],'location','southeast')
shg

gtext('2000')
gtext('2000')
gtext('3000')
gtext('3000')


%% estimate of total number of water samples
    % under estimate bc not counting triplicates of DO nor duplicates of other variables
    
Nsalt = sum(salt_flg,'omitnan');
Ndo = sum(do_flg,'omitnan')*2; % samples typically taken in duplicate, although sometimes triplicates were taken
Ndic = sum(dic_flg,'omitnan');
Nnut = sum(nut_flg,'omitnan');
Nd18o = sum(d18o_flg,'omitnan');

Nall = Nsalt + Ndo + Ndic + Nnut + Nd18o;

disp(' ')
disp(['estimate of total number of water samples collected: ' num2str(Nall)])

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
        'CTD_sen','t','CT','pt','SP','SA','rho','prho','sigma0','oxy_volts','pH','DOcorr_umolkg','O2sol_umolkg','SOC_type'};
    cast = cast(:,vars); 
    
end

function plot_calibrated_DO(downcasts,upcasts,btlsum)
red = [0.85098     0.32549    0.098039];
grey = [0.5     0.5     0.5];

% *** same sensor for all casts ***
% From SBE factory calibration 
% Serial number 3521, 13-Feb-25
cal.SOC = 5.26680e-001;
cal.VOFFSET = -4.81700e-001;
cal.A = -2.87230e-003;
cal.B = 1.28360e-004; 
cal.C = -2.27210e-006;
cal.E = 3.60000e-002;
cal.Tau20 = 1.38000e+000;
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '3521';
cal.OCALDATE = '13-Feb-25';

H = [-0.033, 5000, 1450]; % Default 

% Look at Winklers versus CTD-DO from factory calibration 

% Calculate oxygen concentration with SBE factory calibration 
x = [[upcasts.oxy_volts],...
    [upcasts.O2sol_umolkg],...
    [upcasts.t],...
    [upcasts.prs]];
DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
  .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
  .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));

    if height(btlsum) == 1 
         
        figure
        subplot(1,2,1)
        plot(downcasts.pt,downcasts.prs,'Linewidth',1.2)
        hold on
        plot(upcasts.pt,upcasts.prs,'Linewidth',1.2)
        axis ij
        ylabel('Pressure (db)')
        xlabel('pot. temp (\circC)')
        ax = gca; grid on
        ax.XAxisLocation = 'top';
        legend('Downcast','Upcast','Location','SW')

        subplot(1,2,2)
        plot(downcasts.DOcorr_umolkg,downcasts.prs,'Linewidth',1.2)
        hold on
        plot(upcasts.DOcorr_umolkg,upcasts.prs,'Linewidth',1.2)
        axis ij
        ylabel('Pressure (db)')
        xlabel('Oxygen (\mumol kg^-^1)')
        ax = gca; grid on
        ax.XAxisLocation = 'top';
        sgtitle(['Cast ' num2str(downcasts.Station(1))])
    end
    
            
    if height(btlsum) ~= 1 
        
        f = figure;
        f.Position = [100 100 400 500];
        % subplot(1,2,1)
        % plot(downcasts.pt,downcasts.prs,'Linewidth',1.2)
        % hold on
        % plot(upcasts.pt,upcasts.prs,'Linewidth',1.2)
        % axis ij
        % ylabel('Pressure (db)')
        % xlabel('pot. temp (\circC)')
        % ax = gca; grid on
        % ax.XAxisLocation = 'top';
        % legend('Downcast','Upcast','Location','SW')
        % 
        % subplot(1,2,2)
        % plot(downcasts.DOcorr_umolkg,downcasts.prs,'Linewidth',1.2)
        % hold on
        plot(upcasts.DOcorr_umolkg,upcasts.prs,'Linewidth',1.2)
        hold on
        plot(DOuncorr_umolkg,upcasts.prs,'Linewidth',1.2,'Color',grey)
        plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1 == 2),btlsum.prs(btlsum.NLMR_Outlier1 == 2),'ok','MarkerFaceColor','k')
        plot(btlsum.Winkler1_umolkg(btlsum.NLMR_Outlier1 == 3),btlsum.prs(btlsum.NLMR_Outlier1 == 3),'ok','MarkerFaceColor',red)
        plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2 == 2),btlsum.prs(btlsum.NLMR_Outlier2 == 2),'ok','MarkerFaceColor','k') 
        plot(btlsum.Winkler2_umolkg(btlsum.NLMR_Outlier2 == 3),btlsum.prs(btlsum.NLMR_Outlier2 == 3),'ok','MarkerFaceColor',red) 
        axis ij
        ylabel('Pressure (db)')
        xlabel('Oxygen (\mumol kg^-^1)')
        ax = gca; grid on
        ax.XAxisLocation = 'top';
        % sgtitle(['Cast ' num2str(downcasts.Station(1))])
        legend('Calibrated','Uncalibrated','Winkler','Outlier','Location','best')
        title(['Cast ' num2str(downcasts.Station(1))])
    end

end

function plot_pH(downcasts,upcasts)

    figure
    subplot(1,2,1)
    plot(downcasts.pt,downcasts.prs,'Linewidth',1.2)
    hold on
    plot(upcasts.pt,upcasts.prs,'Linewidth',1.2)
    axis ij
    ylabel('Pressure (db)')
    xlabel('pot. temp (\circC)')
    ax = gca; grid on
    ax.XAxisLocation = 'top';
    legend('Downcast','Upcast','Location','SW')

    subplot(1,2,2)
    plot(downcasts.pH,downcasts.prs,'Linewidth',1.2)
    hold on
    plot(upcasts.pH,upcasts.prs,'Linewidth',1.2)
    axis ij
    ylabel('Pressure (db)')
    xlabel('Oxygen (\mumol kg^-^1)')
    ax = gca; grid on
    ax.XAxisLocation = 'top';
    sgtitle(['Cast ' num2str(downcasts.Station(1))])

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
        plot(btlsum{cast_num(i)}.Winkler1_umolkg(btlsum{cast_num(i)}.NLMR_Outlier1 == 2),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier1 == 2),'.k','markersize',20); hold on
        plot(btlsum{cast_num(i)}.Winkler2_umolkg(btlsum{cast_num(i)}.NLMR_Outlier2 == 2),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier2 == 2),'.k','markersize',20)
        % plot(btlsum{cast_num(i)}.Winkler3_umolkg(btlsum{cast_num(i)}.NLMR_Outlier3 == 2),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier3 == 2),'.k','markersize',20)
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
    plot(downcasts{cast_num(i)}.DOcorr_umolkg,downcasts{cast_num(i)}.pt,'Linewidth',1,'Color',blue)
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
        plot(upcasts{cast_num(i)}.DOcorr_umolkg,upcasts{cast_num(i)}.pt,'Linewidth',1,'Color',blue)
end

for i = 1:length(cast_num)
        try
            % plot(btlsum{cast_num(i)}.Winkler1_umolkg(btlsum{cast_num(i)}.NLMR_Outlier1 == 1),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier1 == 1),'.','markersize',20,'Color',yellow)
            plot(btlsum{cast_num(i)}.Winkler1_umolkg(btlsum{cast_num(i)}.NLMR_Outlier1 == 3),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier1 == 3),'.','markersize',20,'Color',red)
            plot(btlsum{cast_num(i)}.Winkler1_umolkg(btlsum{cast_num(i)}.NLMR_Outlier1 == 2),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier1 == 2),'.k','markersize',20)
            
            % plot(btlsum{cast_num(i)}.Winkler2_umolkg(btlsum{cast_num(i)}.NLMR_Outlier2 == 1),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier2 == 1),'.','markersize',20,'Color',yellow)
            plot(btlsum{cast_num(i)}.Winkler2_umolkg(btlsum{cast_num(i)}.NLMR_Outlier2 == 3),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier2 == 3),'.','markersize',20,'Color',red)
            plot(btlsum{cast_num(i)}.Winkler2_umolkg(btlsum{cast_num(i)}.NLMR_Outlier2 == 2),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier2 == 2),'.k','markersize',20)
            
            % plot(btlsum{cast_num(i)}.Winkler3_umolkg(btlsum{cast_num(i)}.NLMR_Outlier3 == 1),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier3 == 1),'.','markersize',20,'Color',yellow)
            % plot(btlsum{cast_num(i)}.Winkler3_umolkg(btlsum{cast_num(i)}.NLMR_Outlier3 == 3),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier3 == 3),'.','markersize',20,'Color',red)
            % plot(btlsum{cast_num(i)}.Winkler3_umolkg(btlsum{cast_num(i)}.NLMR_Outlier3 == 2),btlsum{cast_num(i)}.pt(btlsum{cast_num(i)}.NLMR_Outlier3 == 2),'.k','markersize',20)
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