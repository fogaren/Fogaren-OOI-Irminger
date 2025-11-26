
addpath(genpath('G:\My Drive\Matlab_work\Github\Irminger_Jose_Backscatter'))
addpath(genpath('G:\My Drive\Matlab_work\Github\GSW-Matlab'))
addpath(genpath('G:\My Drive\Matlab_work\Github\cmocean'))
addpath(genpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\Oxygen_Science_Code'))
cd('G:\Shared drives\NSF_Irminger\Data_Files\HYPM\downloaded_Jan_2025')

% Load OOI Global Irminger Sea profiler fluorometer data for all eight?
% years
wfpfilenames = ls('*.nc');

% Had to update this function to include the right variable names in the
% netCDF. Need to confirm that these are the files I'm supposed to be using
% 
Yr1wfp = load_HYPM_flord_funKF (wfpfilenames (1,:));
% Yr2wfp = load_HYPM_flord_funKF (wfpfilenames (2,:));
% Yr3wfp = load_HYPM_flord_funKF (wfpfilenames (3,:));
% Yr4wfp = load_HYPM_flord_funKF (wfpfilenames (4,:));
% Yr5wfp = load_HYPM_flord_funKF (wfpfilenames (5,:));
% Yr6wfp = load_HYPM_flord_funKF (wfpfilenames (6,:));
% Yr7wfp = load_HYPM_flord_funKF (wfpfilenames (7,:));
% Yr8wfp = load_HYPM_flord_funKF (wfpfilenames (8,:));

%% Remove outliers
tailvarset = 0.005; tailvarset2 = 0.00062; 
% tailvarset = 0.1; tailvarset2 = 0.1;
[Yr1wfp] = OutlierFilterFunKF (tailvarset, tailvarset2, Yr1wfp);
% [Yr2wfp] = OutlierFilterFunKF (tailvarset, tailvarset2, Yr2wfp);
% [Yr3wfp] = OutlierFilterFunKF (tailvarset, tailvarset2, Yr3wfp);
% [Yr4wfp] = OutlierFilterFunKF (tailvarset, tailvarset2, Yr4wfp);
% [Yr5wfp] = OutlierFilterFunKF (tailvarset, tailvarset2, Yr5wfp);
% [Yr6wfp] = OutlierFilterFunKF (tailvarset, tailvarset2, Yr6wfp);
% [Yr7wfp] = OutlierFilterFunKF (tailvarset, tailvarset2, Yr7wfp);
% [Yr8wfp] = OutlierFilterFunKF (tailvarset, tailvarset2, Yr8wfp);

%% Looking into instrument background for each deployment
Yr1wfp.temp = Yr1wfp.temperature_flord; 
Yr1wfp.SP = Yr1wfp.pracsal_flord;
Yr1wfp.time = Yr1wfp.time_flord;
Yr1wfp.depth = Yr1wfp.depth_flord;

for j = 1:length(Yr1wfp.temp)
    [Yr1wfp.betasw(j),beta90sw(j),Yr1wfp.bsw(j)]= betasw_ZHH2009(700,Yr1wfp.temp(j),142,Yr1wfp.SP(j),0.039);
end
Yr1wfp.betasw = Yr1wfp.betasw';
Yr1wfp.bsw = Yr1wfp.bsw';
Yr1wfp.betap = Yr1wfp.total_vol_backscatter - Yr1wfp.betasw;
Yr1wfp.b_bp = 2*pi*1.097*(Yr1wfp.betap);
% wfpmerge.b_bp = 2*pi*1.077*(wfpmerge.betap); % Briggs 2020

%This function subtracts the (small particle and refractory particle signal) for each 20hr backscatter profile
%from its respective signal.

for u = 1:Yr1wfp.profile_index(end)
   [profileindexindex] = find (Yr1wfp.profile_index == u);
   depthres = 11; % Briggs 2011 uses 7-points, Briggs 2020 using 11-points for each 
   % 20 ~ approximately 50 m moving filer 
   minmaxfilter = movmax (movmin (Yr1wfp.b_bp(profileindexindex),...
       depthres), depthres);
   % minmaxfilter_OOI = movmax (movmin (Yr1wfp.b_bp_OOI(profileindexindex),...
   %     depthres), depthres);
   minmaxchlfilter = movmax(movmin (Yr1wfp.chla(profileindexindex),...
       depthres), depthres); 
   Yr1wfp.minmaxfilter (profileindexindex) = minmaxfilter;
   % Yr1wfp.minmaxfilter_OOI (profileindexindex) = minmaxfilter_OOI;
   Yr1wfp.filteredspikes (profileindexindex) = Yr1wfp.b_bp(profileindexindex) - minmaxfilter;
   % Yr1wfp.filteredspikes_OOI (profileindexindex) = Yr1wfp.b_bp_OOI(profileindexindex) - minmaxfilter_OOI;
   Yr1wfp.minmaxchlfilter(profileindexindex) = minmaxchlfilter;
  Yr1wfp.filteredchlspikes(profileindexindex) = Yr1wfp.chla(profileindexindex) - minmaxchlfilter;
end

Yr1wfp.filteredspikes = Yr1wfp.filteredspikes';
% Yr1wfp.filteredspikes_OOI = Yr1wfp.filteredspikes_OOI';
Yr1wfp.minmaxfilter = Yr1wfp.minmaxfilter';
% Yr1wfp.minmaxfilter_OOI = Yr1wfp.minmaxfilter_OOI';
Yr1wfp.filteredchlspikes = Yr1wfp.filteredchlspikes';
Yr1wfp.minmaxchlfilter = Yr1wfp.minmaxchlfilter';
%%
mindepth = 200;
middepth = 1000;
maxdepth = 2000;
depthint = 50;
deeperdepthint = 100; 
Yr1wfp.depthbins = [mindepth: depthint: maxdepth];
% wfpmerge.depthbins = [mindepth: depthint: middepth, middepth+deeperdepthint: deeperdepthint: maxdepth];
depthint = diff(Yr1wfp.depthbins);%[ones(16,1)*50; ones(10,1)*100]; % if bins are not equal size
centerofbin = Yr1wfp.depthbins(1:end-1) + depthint/2;

for i = 1:max(Yr1wfp.profile_index)
    indt = find(Yr1wfp.profile_index == i);
    Yr1wfp.profile_start(i) = Yr1wfp.time(indt(1));
    for j = 1:(length(Yr1wfp.depthbins) - 1)
        ind = intersect(find(Yr1wfp.profile_index == i),...
            find(Yr1wfp.depth >= Yr1wfp.depthbins(j) & Yr1wfp.depth < Yr1wfp.depthbins(j) + depthint(j)));  
        Yr1wfp.binned_filteredspikes(i,j,1) = sum(~isnan(Yr1wfp.filteredspikes(ind)));

        if sum(~isnan(Yr1wfp.filteredspikes(ind))) > 0
            Yr1wfp.binned_filteredspikes(i,j,2) = nanmean(Yr1wfp.filteredspikes(ind));
            Yr1wfp.binned_filteredspikes(i,j,3) = nanstd(Yr1wfp.filteredspikes(ind));
            Yr1wfp.binned_filteredspikes(i,j,4) = nanmax(Yr1wfp.filteredspikes(ind));
            Yr1wfp.binned_filteredspikes(i,j,5) = nanmedian(Yr1wfp.filteredspikes(ind));
            Yr1wfp.binned_filteredspikes(i,j,6) = prctile(Yr1wfp.filteredspikes(ind),95);
        end
    end
end
%%
ind500 = find(centerofbin > 500);
ind1000 = find(centerofbin > 1000);

%% Plot wfp data
% Merges all seven years of the time series into one continuous data structure

wfpmerge.time = [Yr1wfp.time_flord_mat; Yr2wfp.time_flord_mat; Yr3wfp.time_flord_mat; Yr4wfp.time_flord_mat; Yr5wfp.time_flord_mat; Yr6wfp.time_flord_mat; Yr7wfp.time_flord_mat; Yr8wfp.time_flord_mat];
wfpmerge.depth = [Yr1wfp.depth_flord; Yr2wfp.depth_flord; Yr3wfp.depth_flord; Yr4wfp.depth_flord; Yr5wfp.depth_flord; Yr6wfp.depth_flord; Yr7wfp.depth_flord; Yr8wfp.depth_flord];
wfpmerge.SP = [Yr1wfp.pracsal_flord; Yr2wfp.pracsal_flord; Yr3wfp.pracsal_flord; Yr4wfp.pracsal_flord; Yr5wfp.pracsal_flord; Yr6wfp.pracsal_flord; Yr7wfp.pracsal_flord; Yr8wfp.pracsal_flord];
wfpmerge.temp = [Yr1wfp.temperature_flord; Yr2wfp.temperature_flord; Yr3wfp.temperature_flord; Yr4wfp.temperature_flord; Yr5wfp.temperature_flord; Yr6wfp.temperature_flord; Yr7wfp.temperature_flord; Yr8wfp.temperature_flord];
wfpmerge.pdens = [Yr1wfp.pdens; Yr2wfp.pdens; Yr3wfp.pdens; Yr4wfp.pdens; Yr5wfp.pdens; Yr6wfp.pdens; Yr7wfp.pdens; Yr8wfp.pdens];
wfpmerge.backscatter = [Yr1wfp.backscatter; Yr2wfp.backscatter; Yr3wfp.backscatter; Yr4wfp.backscatter; Yr5wfp.backscatter; Yr6wfp.backscatter; Yr7wfp.backscatter; Yr8wfp.backscatter];
wfpmerge.backscatteroriginal = [Yr1wfp.backscatteroriginal; Yr2wfp.backscatteroriginal; Yr3wfp.backscatteroriginal; Yr4wfp.backscatteroriginal; Yr5wfp.backscatteroriginal; Yr6wfp.backscatteroriginal; Yr7wfp.backscatteroriginal; Yr8wfp.backscatteroriginal];
wfpmerge.sw_scat_coef = [Yr1wfp.sw_scat_coef; Yr2wfp.sw_scat_coef; Yr3wfp.sw_scat_coef; Yr4wfp.sw_scat_coef; Yr5wfp.sw_scat_coef; Yr6wfp.sw_scat_coef; Yr7wfp.sw_scat_coef; Yr8wfp.sw_scat_coef];
wfpmerge.total_vol_backscatter_original = [Yr1wfp.total_vol_backscatter_original; Yr2wfp.total_vol_backscatter_original; Yr3wfp.total_vol_backscatter_original; Yr4wfp.total_vol_backscatter_original; Yr5wfp.total_vol_backscatter_original; Yr6wfp.total_vol_backscatter_original; Yr7wfp.total_vol_backscatter_original; Yr8wfp.total_vol_backscatter_original];
wfpmerge.total_vol_backscatter = [Yr1wfp.total_vol_backscatter; Yr2wfp.total_vol_backscatter; Yr3wfp.total_vol_backscatter; Yr4wfp.total_vol_backscatter; Yr5wfp.total_vol_backscatter; Yr6wfp.total_vol_backscatter; Yr7wfp.total_vol_backscatter; Yr8wfp.total_vol_backscatter];
wfpmerge.b_bp_OOI = wfpmerge.backscatter - wfpmerge.sw_scat_coef/2; % 
wfpmerge.chla = [Yr1wfp.chla; Yr2wfp.chla; Yr3wfp.chla; Yr4wfp.chla; Yr5wfp.chla; Yr6wfp.chla; Yr7wfp.chla; Yr8wfp.chla];
wfpmerge.profile_index = [Yr1wfp.profile_index; Yr1wfp.profile_index(end)+Yr2wfp.profile_index; Yr1wfp.profile_index(end)+Yr2wfp.profile_index(end)+Yr3wfp.profile_index;...
    Yr1wfp.profile_index(end)+Yr2wfp.profile_index(end)+Yr3wfp.profile_index(end)+Yr4wfp.profile_index; Yr1wfp.profile_index(end)+Yr2wfp.profile_index(end)+Yr3wfp.profile_index(end)+Yr4wfp.profile_index(end)+Yr5wfp.profile_index;...
    Yr1wfp.profile_index(end)+Yr2wfp.profile_index(end)+Yr3wfp.profile_index(end)+Yr4wfp.profile_index(end)+Yr5wfp.profile_index(end)+Yr6wfp.profile_index;...
    Yr1wfp.profile_index(end)+Yr2wfp.profile_index(end)+Yr3wfp.profile_index(end)+Yr4wfp.profile_index(end)+Yr5wfp.profile_index(end)+Yr6wfp.profile_index(end)+Yr7wfp.profile_index;...
    Yr1wfp.profile_index(end)+Yr2wfp.profile_index(end)+Yr3wfp.profile_index(end)+Yr4wfp.profile_index(end)+Yr5wfp.profile_index(end)+Yr6wfp.profile_index(end)+Yr7wfp.profile_index(end)+Yr8wfp.profile_index];
wfpmerge.updown_index = [Yr1wfp.updown_index; Yr2wfp.updown_index; Yr3wfp.updown_index; Yr4wfp.updown_index; Yr5wfp.updown_index; Yr6wfp.updown_index; Yr7wfp.updown_index; Yr8wfp.updown_index];
wfpmerge.depth_grid = [150:50:2600];
wfpmerge.profile_index2 = [1:wfpmerge.profile_index(end)];

% Beta_Sw not provided by OOI, so calculated according to Zhang et al 2009
% and the reported chi and theta in Seabird Application 114 for the FLORD
for j = 1:length(wfpmerge.temp)
    [wfpmerge.betasw(j),beta90sw(j),wfpmerge.bsw(j)]= betasw_ZHH2009(700,wfpmerge.temp(j),142,wfpmerge.SP(j),0.039);
    % [wfpmerge.betasw(j),beta90sw(j),wfpmerge.bsw(j)]= betasw_ZHH2009(700,wfpmerge.temp(j),124,wfpmerge.SP(j),0.039); % Briggs 2020
end
wfpmerge.betasw = wfpmerge.betasw';
wfpmerge.bsw = wfpmerge.bsw';
wfpmerge.betap = wfpmerge.total_vol_backscatter - wfpmerge.betasw;
wfpmerge.b_bp = 2*pi*1.097*(wfpmerge.betap);
% wfpmerge.b_bp = 2*pi*1.077*(wfpmerge.betap); % Briggs 2020

%This function subtracts the (small particle and refractory particle signal) for each 20hr backscatter profile
%from its respective signal.

for u = 1:wfpmerge.profile_index(end)
   [profileindexindex] = find (wfpmerge.profile_index == u);
   depthres = 11; % Briggs 2011 uses 7-points, Briggs 2020 using 11-points for each 
   % 20 ~ approximately 50 m moving filer 
   minmaxfilter = movmax (movmin (wfpmerge.b_bp(profileindexindex),...
       depthres), depthres);
   minmaxfilter_OOI = movmax (movmin (wfpmerge.b_bp_OOI(profileindexindex),...
       depthres), depthres);
   minmaxchlfilter = movmax(movmin (wfpmerge.chla(profileindexindex),...
       depthres), depthres); 
   wfpmerge.minmaxfilter (profileindexindex) = minmaxfilter;
   wfpmerge.minmaxfilter_OOI (profileindexindex) = minmaxfilter_OOI;
   wfpmerge.filteredspikes (profileindexindex) = wfpmerge.b_bp(profileindexindex) - minmaxfilter;
   wfpmerge.filteredspikes_OOI (profileindexindex) = wfpmerge.b_bp_OOI(profileindexindex) - minmaxfilter_OOI;
   wfpmerge.minmaxchlfilter(profileindexindex) = minmaxchlfilter;
   wfpmerge.filteredchlspikes(profileindexindex) = wfpmerge.chla(profileindexindex) - minmaxchlfilter;
end

wfpmerge.filteredspikes = wfpmerge.filteredspikes';
wfpmerge.filteredspikes_OOI = wfpmerge.filteredspikes_OOI';
wfpmerge.minmaxfilter = wfpmerge.minmaxfilter';
wfpmerge.minmaxfilter_OOI = wfpmerge.minmaxfilter_OOI';
wfpmerge.filteredchlspikes = wfpmerge.filteredchlspikes';
wfpmerge.minmaxchlfilter = wfpmerge.minmaxchlfilter';



% %%
% [B,I] = sort(wfpmerge.binned_filteredspikes_filt_wtgaps); 
% 
% figure
% scatter(wfpmerge.time(I),wfpmerge.depth(I),[],B,'filled')
% axis ij
% axis([wfpmerge.time(1) wfpmerge.time(end) 0 2000])
% colorbar
% caxis([0.05 6])

%%

% [B2,I2] = sort(wfpmerge.filteredspikes); 
% [B2,I2] = sort(wfpmerge.total_vol_backscatter); 
[B2,I2] = sort(wfpmerge.minmaxfilter); 

figure
scatter(wfpmerge.time(I2),wfpmerge.depth(I2),5,B2,'filled')
axis ij
axis([wfpmerge.time(1) wfpmerge.time(end) 0 2000])
colorbar
% clim([0 .001])
cmocean('amp')
% colormap(sky)
datetick('keeplimits')
box on
%%
test = wfpmerge.filteredspikes;
test(wfpmerge.minmaxfilter > 0.0010) = NaN;
[B2,I2] = sort(test); 

figure
scatter(wfpmerge.time(I2),wfpmerge.depth(I2),5,B2,'filled')
axis ij
axis([wfpmerge.time(1) wfpmerge.time(end) 0 2000])
colorbar

colormap(sky)
datetick('keeplimits')
box on
%% To look at different calculated components of the optical signal 

ind = find(floor(wfpmerge.time) == datenum(2015,07,07),1); % Jose's Figure 4
prof_ind = wfpmerge.profile_index(ind);
for j = 1:length(wfpmerge.profile_index)
    figure(2)
    clf
    subplot(1,3,1)
    % plot(wfpmerge.backscatter(wfpmerge.profile_index == j),wfpmerge.depth(wfpmerge.profile_index == j),'.')
    plot(wfpmerge.total_vol_backscatter(wfpmerge.profile_index == j)*1000,wfpmerge.depth(wfpmerge.profile_index == j),'.')
    hold on
    plot(wfpmerge.betasw(wfpmerge.profile_index == j)*1000, wfpmerge.depth(wfpmerge.profile_index == j ),'.')
    % plot(wfpmerge.sw_scat_coef(wfpmerge.profile_index == j),wfpmerge.depth(wfpmerge.profile_index == j),'.')
    % plot(wfpmerge.bsw(wfpmerge.profile_index ==j),wfpmerge.depth(wfpmerge.profile_index == j),'.')
    axis ij
    grid on
    title('Total Optical Backscatter'); ylabel('depth (m)')
    legend('\beta (x 10^3 m^-^1 sr^-^1)','\beta_s_w (x 10^3 m^-^1 sr^-^1)','location','south')

    subplot(1,3,2)
    plot(wfpmerge.b_bp(wfpmerge.profile_index == j)*1000,wfpmerge.depth(wfpmerge.profile_index == j),'.')
    hold on
    plot(wfpmerge.minmaxfilter(wfpmerge.profile_index == j)*1000,wfpmerge.depth(wfpmerge.profile_index == j),'k','Linewidth',1.6)
    % plot(wfpmerge.b_bp0(wfpmerge.profile_index == j)*1000,wfpmerge.depth(wfpmerge.profile_index == j),'.')
    % hold on
    % plot(wfpmerge.minmaxfilter0(wfpmerge.profile_index == j)*1000,wfpmerge.depth(wfpmerge.profile_index == j),'k','Linewidth',1.6)
    axis ij
    grid on
    title('Particulate Backscatter')
    legend('b_b_p (x 10^3 m^-^1)','b_b_s + b_b_r (x 10^3 m^-^1)','location','south')

    subplot(1,3,3)
    plot(wfpmerge.filteredspikes(wfpmerge.profile_index == j)*1000,wfpmerge.depth(wfpmerge.profile_index == j))
    hold on
    % plot(wfpmerge.filteredspikes0(wfpmerge.profile_index == j)*1000,wfpmerge.depth(wfpmerge.profile_index == j))
    axis ij
    grid on
    legend('b_b_l (x 10^3 m^-^1)','location','south')
    title('Large Particles')
    titletime = wfpmerge.time(wfpmerge.profile_index == j);
    sgtitle(datestr(titletime(1)))
    pause
    
end
%% To look at different calculated components of the chl signal 
for j = 1:length(wfpmerge.profile_index)
    figure(1)
    clf
    subplot(1,2,1)
    plot(wfpmerge.chla(wfpmerge.profile_index == j),wfpmerge.depth(wfpmerge.profile_index == j),'.')
    hold on
    plot(wfpmerge.minmaxchlfilter(wfpmerge.profile_index == j),wfpmerge.depth(wfpmerge.profile_index == j))
    axis ij
    grid on
    legend('total chl','chl_s_r','location','south')

    subplot(1,2,2)
    plot(wfpmerge.filteredchlspikes(wfpmerge.profile_index == j),wfpmerge.depth(wfpmerge.profile_index == j))
    axis ij
    grid on
    legend('chl_l','location','south')
    titletime = wfpmerge.time(wfpmerge.profile_index == j);
    sgtitle(datestr(titletime(1)))
    pause
    
end

%% Calculate number of outliers
totbackscatterout = find (wfpmerge.backscatteroriginal >= tailvarset);
numberspikesremoved = length (totbackscatterout);
outlierremoveprct = length (totbackscatterout) / length (wfpmerge.backscatteroriginal);
totalpointsremoved = sum(~isnan(wfpmerge.backscatteroriginal)) - sum(~isnan(wfpmerge.backscatter)); %%CHECK THIS

%% Binning backscatter spikes
[wfpmerge] = ProfileTimeSeriesFun (datestr(Yr1wfp.time_flord_mat(1)),datestr(Yr7wfp.time_flord_mat(end)),20/24,0,2000,5,wfpmerge);

%% Parameterize Sinking Rates and Flux Attenuation
% SinkingPulseVertHP % Takes a long time to run can load file and then run
%% Script overview - H. Palevsky implementation of sinking pulse analysis (SinkingPulseVert.m from J. Cuevas)
% 1. Extract all backscatter spikes (background removed) within depth bins
% 2. Calculate the moving mean, std, median, max, and 95th percentile - do
% this for each profile rather than 24 hours, since profiles are every 20 hrs
% 3. Clean up by removing profiles that don't have sufficient data in each
% bin to calculate stats, and identify/flag large time gaps in usable record
        %Note that this is conservative choice, could modify to aim to keep more
% 4. Calculate the moving mean over every X profiles with usable data (using 6 for now, ~120 hours)
% 5. Identify center of backscatter pulse in each depth interval during
% each spring-fall season (calculated here as max of 6-profile moving mean
% of the 95th percentile value from each depth interval for each profile)
% 6. Plot resulting time series data for example depths

%% Set binning depth min, max, and step interval
mindepth = 200;
middepth = 1000;
maxdepth = 2000;
depthint = 50;
deeperdepthint = 100; 
wfpmerge.depthbins = [mindepth: depthint: maxdepth];
% wfpmerge.depthbins = [mindepth: depthint: middepth, middepth+deeperdepthint: deeperdepthint: maxdepth];
depthint = diff(wfpmerge.depthbins);%[ones(16,1)*50; ones(10,1)*100]; % if bins are not equal size
centerofbin = wfpmerge.depthbins(1:end-1) + depthint/2;
%% Initialize variable to hold binned output
wfpmerge.binned_backscatter = NaN(max(wfpmerge.profile_index), length(wfpmerge.depthbins) - 1, 6);
wfpmerge.binned_b_bp = NaN(max(wfpmerge.profile_index), length(wfpmerge.depthbins) - 1, 6);
wfpmerge.binned_filteredspikes = NaN(max(wfpmerge.profile_index), length(wfpmerge.depthbins) - 1, 6);

%% Loop over each profile, extracting all data points within given depth bin
%Calculate and save: #points, mean, stdev, max, median, 95th percentile
%note that this section took a long time to run, so saved the updated
%wfpmerge: Joseoutput_HIPupdate28Feb.mat --> could skip running section and load instead
tic
for i = 1:max(wfpmerge.profile_index)
    indt = find(wfpmerge.profile_index == i);
    wfpmerge.profile_start(i) = wfpmerge.time(indt(1));
    for j = 1:(length(wfpmerge.depthbins) - 1)
        ind = intersect(find(wfpmerge.profile_index == i),...
            find(wfpmerge.depth >= wfpmerge.depthbins(j) & wfpmerge.depth < wfpmerge.depthbins(j) + depthint(j)));  
        wfpmerge.binned_backscatter(i,j,1) = sum(~isnan(wfpmerge.backscatter(ind)));
        wfpmerge.binned_b_bp(i,j,1) = sum(~isnan(wfpmerge.b_bp(ind)));
        wfpmerge.binned_filteredspikes(i,j,1) = sum(~isnan(wfpmerge.filteredspikes(ind)));

        if sum(~isnan(wfpmerge.backscatter(ind))) > 0
            wfpmerge.binned_backscatter(i,j,2) = nanmean(wfpmerge.backscatter(ind));
            wfpmerge.binned_backscatter(i,j,3) = nanstd(wfpmerge.backscatter(ind));
            wfpmerge.binned_backscatter(i,j,4) = nanmax(wfpmerge.backscatter(ind));
            wfpmerge.binned_backscatter(i,j,5) = nanmedian(wfpmerge.backscatter(ind));
            wfpmerge.binned_backscatter(i,j,6) = prctile(wfpmerge.backscatter(ind),95);
        end
        if sum(~isnan(wfpmerge.b_bp(ind))) > 0
            wfpmerge.binned_b_bp(i,j,2) = nanmean(wfpmerge.b_bp(ind));
            wfpmerge.binned_b_bp(i,j,3) = nanstd(wfpmerge.b_bp(ind));
            wfpmerge.binned_b_bp(i,j,4) = nanmax(wfpmerge.b_bp(ind));
            wfpmerge.binned_b_bp(i,j,5) = nanmedian(wfpmerge.b_bp(ind));
            wfpmerge.binned_b_bp(i,j,6) = prctile(wfpmerge.b_bp(ind),95);
        end
        if sum(~isnan(wfpmerge.filteredspikes(ind))) > 0
            wfpmerge.binned_filteredspikes(i,j,2) = nanmean(wfpmerge.filteredspikes(ind));
            wfpmerge.binned_filteredspikes(i,j,3) = nanstd(wfpmerge.filteredspikes(ind));
            wfpmerge.binned_filteredspikes(i,j,4) = nanmax(wfpmerge.filteredspikes(ind));
            wfpmerge.binned_filteredspikes(i,j,5) = nanmedian(wfpmerge.filteredspikes(ind));
            wfpmerge.binned_filteredspikes(i,j,6) = prctile(wfpmerge.filteredspikes(ind),95);
        end
    end
end
toc
% save Joseoutput_KFupdate30Jan2025_50m.mat
%%
cd('G:\Shared drives\NSF_Irminger\Data_Files\HYPM\downloaded_Jan_2025')
% load Joseoutput_KFupdate8Jan2025.mat
load Joseoutput_KFupdate30Jan2025_50m.mat
addpath(genpath('G:\My Drive\Matlab_work\Github\cmocean'))
%% Assess to remove profiles/data points without sufficient data points per bin
%Plot histogram of number of points per depth bin over full dataset
figure(1); clf
    subplot(311)
numpts = squeeze(wfpmerge.binned_backscatter(:,:,1));
histogram(numpts(:),[0:2:60])
    subplot(312)
numpts_bp = squeeze(wfpmerge.binned_b_bp(:,:,1));
histogram(numpts_bp(:),[0:2:60])
    subplot(313)
numpts_bbl = squeeze(wfpmerge.binned_filteredspikes(:,:,1));
histogram(numpts_bbl(:),[0:2:60])

% Identify profile numbers of bins with fewer data points than chosen tolerance
tol = 10; %was 14
tol_check = sum(numpts' > tol);

%Only keep profiles that include at least "tol" points per bin for all
%depth bins - note that this is a conservative choice and more data could
%be included by filtering each individual depth bin to check # usable data points
% tol_bins = 36; % for 50 m bins
tol_bins = length(wfpmerge.depthbins)-1; % should work for any depth 
ind_profkeep = find(tol_check >= tol_bins);

%Statistics on number of points in remaining depth bins
numpts_filt = squeeze(wfpmerge.binned_backscatter(ind_profkeep,:,1));

[X2,Y2] = meshgrid(wfpmerge.profile_start,wfpmerge.sinkingpulsedepths);
C = squeeze(wfpmerge.binned_filteredspikes(:,:,1));
figure
pcolor(X2,Y2,C','linestyle','none')
axis ij
clim([0 10])
colorbar


%% Create filtered dataset with only usable depth profiles
% wfpmerge.binned_backscatter_filt = wfpmerge.binned_backscatter(ind_profkeep,:,:);
% wfpmerge.binned_b_bp_filt = wfpmerge.binned_b_bp(ind_profkeep,:,:);
% wfpmerge.binned_filteredspikes_filt = wfpmerge.binned_filteredspikes(ind_profkeep,:,:);
% wfpmerge.profile_start_filt = wfpmerge.profile_start(ind_profkeep);

wfpmerge.binned_backscatter_filt = wfpmerge.binned_backscatter;
wfpmerge.binned_b_bp_filt = wfpmerge.binned_b_bp;
wfpmerge.binned_filteredspikes_filt = wfpmerge.binned_filteredspikes;
wfpmerge.profile_start_filt = wfpmerge.profile_start;
%% Identify large temporal gaps in usable profiles
tgaps = diff(wfpmerge.profile_start_filt);
tol_tgap = prctile(tgaps, 99);
ind_biggap = find(tgaps > tol_tgap);

%% Insert NaN profiles marking each time gap larger than "tol_tgap"
%A bit of a kludge, goal is to make gaps easier to identify

wfpmerge.profile_start_filt_wtgaps = wfpmerge.profile_start_filt;
wfpmerge.binned_backscatter_filt_wtgaps = wfpmerge.binned_backscatter_filt;
wfpmerge.binned_b_bp_filt_wtgaps = wfpmerge.binned_b_bp_filt;
wfpmerge.binned_filteredspikes_filt_wtgaps = wfpmerge.binned_filteredspikes_filt;
for i = 1:length(ind_biggap)
    wfpmerge.profile_start_filt_wtgaps = [wfpmerge.profile_start_filt_wtgaps(1:ind_biggap(i) + (i-2)) NaN NaN NaN wfpmerge.profile_start_filt_wtgaps(ind_biggap(i)+i+1:end)];
    wfpmerge.binned_backscatter_filt_wtgaps = cat(1, wfpmerge.binned_backscatter_filt_wtgaps(1:ind_biggap(i) + (i-1),:,:), NaN(1,length(wfpmerge.depthbins)-1,6), wfpmerge.binned_backscatter_filt_wtgaps(ind_biggap(i)+i:end,:,:));
    wfpmerge.binned_b_bp_filt_wtgaps = cat(1, wfpmerge.binned_b_bp_filt_wtgaps(1:ind_biggap(i) + (i-1),:,:), NaN(1,length(wfpmerge.depthbins)-1,6), wfpmerge.binned_b_bp_filt_wtgaps(ind_biggap(i)+i:end,:,:));
    wfpmerge.binned_filteredspikes_filt_wtgaps = cat(1, wfpmerge.binned_filteredspikes_filt_wtgaps(1:ind_biggap(i) + (i-1),:,:), NaN(1,length(wfpmerge.depthbins)-1,6), wfpmerge.binned_filteredspikes_filt_wtgaps(ind_biggap(i)+i:end,:,:));
end

%% Calculate moving mean over binned data
%Calculate moving mean over every "smoothnum" profiles, with NaNs omitted
smoothnum = 6; % was 6 %median time between profiles is 20 hours, so this is 120 hours for median
wfpmerge.binned_backscatter_smoothed = movmean(wfpmerge.binned_backscatter_filt_wtgaps, smoothnum, 1, 'includenan','endpoints','fill');
wfpmerge.binned_b_bp_smoothed = movmean(wfpmerge.binned_b_bp_filt_wtgaps, smoothnum, 1, 'includenan','endpoints','fill');
wfpmerge.binned_filteredspikes_smoothed = movmean(wfpmerge.binned_filteredspikes_filt_wtgaps, smoothnum, 1, 'includenan','endpoints','fill');
%% Time for some figures, July 7 2015
% Calculate and save: #points, mean, stdev, max, median, 95th percentile
wfpmerge.sinkingpulsedepths = centerofbin'; % 50 m bins then 100 m bins 
% wfpmerge.sinkingpulsedepths = [225:50:1975]'; % for 50 m bins throughout

ind = find(floor(wfpmerge.profile_start) == datenum(2015,07,07));
figure
plot(wfpmerge.filteredspikes(wfpmerge.profile_index == ind),wfpmerge.depth(wfpmerge.profile_index == ind))
hold on
axis ij
plot(squeeze(wfpmerge.binned_filteredspikes(ind,:,2)),wfpmerge.sinkingpulsedepths,'ok') % mean
plot(squeeze(wfpmerge.binned_filteredspikes(ind,:,6)),wfpmerge.sinkingpulsedepths,'*') % 95%
plot(squeeze(wfpmerge.binned_filteredspikes_smoothed(ind,:,2)),wfpmerge.sinkingpulsedepths,'or') % mean
plot(squeeze(wfpmerge.binned_filteredspikes_smoothed(ind,:,6)),wfpmerge.sinkingpulsedepths,'*') % 95%
clear ind


%% For my edits Calculate maximum of sinking pulse in each year for each depth bin % HIP Code 
%calculate year and julian day for each profile
wfpmerge.profile_start_filt_wtgaps_yr = str2num(datestr(wfpmerge.profile_start_filt_wtgaps,'yyyy'));
wfpmerge.profile_start_filt_wtgaps_JD = wfpmerge.profile_start_filt_wtgaps' - datenum(wfpmerge.profile_start_filt_wtgaps_yr,0,0);
wfpmerge.profile_start_yr = str2num(datestr(wfpmerge.profile_start_filt,'yyyy'));
wfpmerge.profile_start_JD = wfpmerge.profile_start_filt' - datenum(wfpmerge.profile_start_yr,0,0);

yrstr = [2015 2016 2016.5 2017 2018 2019 2020 2021]; %set of complete years with summers, though some (i.e. 2019 and 2020, maybe 2017, may have gaps too big to use)
% yrstr = [2015 2016 2016 2017 2018 2019 2020]; %set of complete years with summers, though some (i.e. 2019 and 2020, maybe 2017, may have gaps too big to use)

% yrstr = [2015 2016 2016.5 2017 2018 2018.5 2019 2020]; %set of complete years with summers, though some (i.e. 2019 and 2020, maybe 2017, may have gaps too big to use)
jdmin = 121; jdmax = 274; %specify min and maximum julian days for bloom sinking pulse, here we use 1 May to 31 Oct
jdmid = 212; %august 1 cutoff for the 1st vs 2nd bloom in 2016

%Initialize array to hold output
%depth bin x year x [max val, max id, max date]
sinkingpulse_max_movmean_includenan = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
sinkingpulse_max_movmean_omitnan = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
sinkingpulse_max_gaussfilter_includenan = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
sinkingpulse_max_gaussfilter_omitnan = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
sinkingpulse_gauss1 = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
sinkingpulse_gauss2 = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));

% sinkingpulse_Btot = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
% sinkingpulse_b_bp = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
% sinkingpulse_Btot_filt_wtgaps = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
% sinkingpulse_b_bp_filt_wtgaps = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
% sinkingpulse_max_movmean_includenan = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
% 
% sinkingpulse_Btot_smoothed = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
% sinkingpulse_b_bp_smoothed = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
% sinkingpulse_filt_smoothed = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
% 
% sinkingpulse_Btot_gauss = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
% sinkingpulse_b_bp_gauss = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
% sinkingpulse_filt_gauss = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
% 
% sinkingpulse_Btot_gauss_smoothdata = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
% sinkingpulse_b_bp_gauss_smoothdata = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
% sinkingpulse_filt_gauss_smoothdata = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));

% Plots of each pulse 
for i = 1:length(yrstr)
    if floor(yrstr(i)) == 2015
        jdmin = day(datetime(datenum('2015,06,01'),'ConvertFrom','datenum'),'dayofyear'); % 6/1
        jdmax = day(datetime(datenum('2015,08,10'),'ConvertFrom','datenum'),'dayofyear'); %8/10

        ind{i} = find(wfpmerge.profile_start_yr == 2015 &...
                wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmax);
        ind_filt_wtgaps{i} = find(wfpmerge.profile_start_filt_wtgaps_yr == 2015 &...
                wfpmerge.profile_start_filt_wtgaps_JD > jdmin & wfpmerge.profile_start_filt_wtgaps_JD < jdmax);

    elseif floor(yrstr(i)) == 2016
        jdmin = 140; jdmax = 264; %specify min and maximum julian days for bloom sinking pulse, here we use 1 May to 31 Oct
        jdmid = 220; %august 1 cutoff for the 1st vs 2nd bloom in 2016

        if yrstr(i) == 2016 %first pulse in 2016
            ind{i} = find(wfpmerge.profile_start_yr == 2016 &...
                wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmid);
        else %second pulse in 2016
            ind{i} = find(wfpmerge.profile_start_yr == 2016 &...
                wfpmerge.profile_start_JD > jdmid & wfpmerge.profile_start_JD < jdmax);
        end
        if yrstr(i) == 2016 %first pulse in 2016
            ind_filt_wtgaps{i} = find(wfpmerge.profile_start_filt_wtgaps_yr == 2016 &...
                wfpmerge.profile_start_filt_wtgaps_JD > jdmin & wfpmerge.profile_start_filt_wtgaps_JD < jdmid);
        else %second pulse in 2016
            ind_filt_wtgaps{i} = find(wfpmerge.profile_start_filt_wtgaps_yr == 2016 &...
                wfpmerge.profile_start_filt_wtgaps_JD > jdmid & wfpmerge.profile_start_filt_wtgaps_JD < jdmax);
        end

    elseif floor(yrstr(i)) == 2017
        jdmin = day(datetime(datenum('2017,06,01'),'ConvertFrom','datenum'),'dayofyear');
        jdmax = day(datetime(datenum('2017,07,12'),'ConvertFrom','datenum'),'dayofyear');

        ind{i} = find(wfpmerge.profile_start_yr == 2017 &...
                wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmax);
        ind_filt_wtgaps{i} = find(wfpmerge.profile_start_filt_wtgaps_yr == 2017 &...
                wfpmerge.profile_start_filt_wtgaps_JD > jdmin & wfpmerge.profile_start_filt_wtgaps_JD < jdmax);

    elseif floor(yrstr(i)) == 2018 % multiple pulses?
        jdmin = day(datetime(datenum('2018,06,01'),'ConvertFrom','datenum'),'dayofyear');
        jdmid = day(datetime(datenum('2018,06,26'),'ConvertFrom','datenum'),'dayofyear');
        jdmax = day(datetime(datenum('2018,08,05'),'ConvertFrom','datenum'),'dayofyear');

        ind{i} = find(wfpmerge.profile_start_yr == 2018 &...
                wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmax);
        ind_filt_wtgaps{i} = find(wfpmerge.profile_start_filt_wtgaps_yr == 2018 &...
                wfpmerge.profile_start_filt_wtgaps_JD > jdmin & wfpmerge.profile_start_filt_wtgaps_JD < jdmax);

        % if yrstr(i) == 2018 %first pulse in 2018
        %     ind = find(wfpmerge.profile_start_yr == 2018 &...
        %         wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmid);
        % else %second pulse in 2018
        %     ind = find(wfpmerge.profile_start_yr == 2018 &...
        %         wfpmerge.profile_start_JD > jdmid & wfpmerge.profile_start_JD < jdmax);
        % end
        % if yrstr(i) == 2018 %first pulse in 2018
        %     ind_filt_wtgaps = find(wfpmerge.profile_start_filt_wtgaps_yr == 2018 &...
        %         wfpmerge.profile_start_filt_wtgaps_JD > jdmin & wfpmerge.profile_start_filt_wtgaps_JD < jdmid);
        % else %second pulse in 2018
        %     ind_filt_wtgaps = find(wfpmerge.profile_start_filt_wtgaps_yr == 2018 &...
        %         wfpmerge.profile_start_filt_wtgaps_JD > jdmid & wfpmerge.profile_start_filt_wtgaps_JD < jdmax);
        % end

    elseif floor(yrstr(i)) == 2019 % Too much of a data gap 
        jdmin = 121; jdmax = 304; %specify min and maximum julian days for bloom sinking pulse, here we use 1 May to 31 Oct       
        ind{i} = find(wfpmerge.profile_start_yr == 2019 &...
                wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmax);
        ind_filt_wtgaps{i} = find(wfpmerge.profile_start_filt_wtgaps_yr == 2019 &...
                wfpmerge.profile_start_filt_wtgaps_JD > jdmin & wfpmerge.profile_start_filt_wtgaps_JD < jdmax);
    elseif floor(yrstr(i)) == 2020
        jdmin = 121; jdmax = 274; %specify min and maximum julian days for bloom sinking pulse, here we use 1 May to 31 Oct
        ind{i} = find(wfpmerge.profile_start_yr == yrstr(i) &...
                wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmax);
        ind_filt_wtgaps{i} = find(wfpmerge.profile_start_filt_wtgaps_yr == yrstr(i) &...
                wfpmerge.profile_start_filt_wtgaps_JD > jdmin & wfpmerge.profile_start_filt_wtgaps_JD < jdmax);
    elseif floor(yrstr(i)) == 2021
        jdmin = 121; jdmax = 274; %specify min and maximum julian days for bloom sinking pulse, here we use 1 May to 31 Oct
        ind{i} = find(wfpmerge.profile_start_yr == yrstr(i) &...
                wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmax);
        ind_filt_wtgaps{i} = find(wfpmerge.profile_start_filt_wtgaps_yr == yrstr(i) &...
                wfpmerge.profile_start_filt_wtgaps_JD > jdmin & wfpmerge.profile_start_filt_wtgaps_JD < jdmax);
    elseif floor(yrstr(i)) == 2022
        jdmin = 121; jdmax = 274; %specify min and maximum julian days for bloom sinking pulse, here we use 1 May to 31 Oct
        ind{i} = find(wfpmerge.profile_start_yr == yrstr(i) &...
                wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmax);
        ind_filt_wtgaps{i} = find(wfpmerge.profile_start_filt_wtgaps_yr == yrstr(i) &...
                wfpmerge.profile_start_filt_wtgaps_JD > jdmin & wfpmerge.profile_start_filt_wtgaps_JD < jdmax);
    end
    
    % Gaussian fit to all data surrounding pulse

    for j = 1:length(wfpmerge.sinkingpulsedepths)
        [exclude1] = isnan(wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{i},j,6));

        [gaussfit1{i}{j}, gofgauss1{i}{j}] = fit(ind_filt_wtgaps{i},wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{i},j,6),'gauss1','Normalize','off','Exclude', exclude1);
        gaussfit1_plot{i}(:,j) = gaussfit1{i}{j}(ind_filt_wtgaps{i}');

        [gaussfit2{i}{j}, gofgauss2{i}{j}] = fit(ind_filt_wtgaps{i},wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{i},j,6),'gauss2','Normalize','off','Exclude', exclude1);
        gaussfit2_plot{i}(:,j) = gaussfit2{i}{j}(ind_filt_wtgaps{i}');
        
        [sinkingpulse_gauss1(j,1,i), I] = max(gaussfit1{i}{j}(ind_filt_wtgaps{i})); %max value of gaussian fit to the 95th percentile
        sinkingpulse_gauss1(j,2,i) = ind_filt_wtgaps{i}(I); %index of max
        sinkingpulse_gauss1(j,3,i) = wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{i}(I)); %time of max value

        [sinkingpulse_gauss2(j,1,i), I] = max(gaussfit2{i}{j}(ind_filt_wtgaps{i})); %max value of gaussian fit to the 95th percentile
        sinkingpulse_gauss2(j,2,i) = ind_filt_wtgaps{i}(I); %index of max
        sinkingpulse_gauss2(j,3,i) = wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{i}(I)); %time of max value
    end


    % Maximum of the 6 profile moving mean (including nan data == time
    % gaps) max_smooth

    % [sinkingpulse_Btot_filt_wtgaps(:,1,i), I] = max(wfpmerge.binned_backscatter_smoothed(ind_filt_wtgaps{i},:,6),[],1); %max value of smoothed 95th percentile
    % sinkingpulse_Btot_filt_wtgaps(:,2,i) = ind_filt_wtgaps{i}(I); %index of max
    % sinkingpulse_Btot_filt_wtgaps(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{i}(I)); %time of max value
    % [sinkingpulse_b_bp_filt_wtgaps(:,1,i), I] = max(wfpmerge.binned_b_bp_smoothed(ind_filt_wtgaps{i},:,6),[],1); %max value of smoothed 95th percentile
    % sinkingpulse_b_bp_filt_wtgaps(:,2,i) = ind_filt_wtgaps{i}(I); %index of max
    % sinkingpulse_b_bp_filt_wtgaps(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{i}(I)); %time of max value
    [sinkingpulse_max_movmean_includenan(:,1,i), I] = max(wfpmerge.binned_filteredspikes_smoothed(ind_filt_wtgaps{i},:,6),[],1); %max value of smoothed 95th percentile
    sinkingpulse_max_movmean_includenan(:,2,i) = ind_filt_wtgaps{i}(I); %index of max
    sinkingpulse_max_movmean_includenan(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{i}(I)); %time of max value

    [sinkingpulse_max_movmean_omitnan(:,1,i), I] = max(smoothdata(wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{i},:,6),"movmean",6,'omitnan'));
    sinkingpulse_max_movmean_omitnan(:,2,i) = ind_filt_wtgaps{i}(I); %index of max
    sinkingpulse_max_movmean_omitnan(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{i}(I)); %time of max value

    % % maximum of 
    % % [sinkingpulse_Btot_smoothed(:,1,i), I] = max(wfpmerge.binned_backscatter_smoothed(ind_filt_wtgaps{i},:,6),[],1); %max value of smoothed 95th percentile
    % % sinkingpulse_Btot_smoothed(:,2,i) = ind_filt_wtgaps{i}(I); %index of max
    % % sinkingpulse_Btot_smoothed(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{i}(I)); %time of max value
    % % [sinkingpulse_b_bp_smoothed(:,1,i), I] = max(wfpmerge.binned_b_bp_smoothed(ind_filt_wtgaps{i},:,6),[],1); %max value of smoothed 95th percentile
    % % sinkingpulse_b_bp_smoothed(:,2,i) = ind_filt_wtgaps{i}(I); %index of max
    % % sinkingpulse_b_bp_smoothed(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{i}(I)); %time of max value
    % [sinkingpulse_smoothed(:,1,i), I] = max(wfpmerge.binned_filteredspikes_smoothed(ind_filt_wtgaps{i},:,6),[],1); %max value of smoothed 95th percentile
    % sinkingpulse_smoothed(:,2,i) = ind_filt_wtgaps{i}(I); %index of max
    % sinkingpulse_smoothed(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{i}(I)); %time of max value

    % maxmum of smoothed data using gaussian filter and omitting nans 
    % [sinkingpulse_Btot_gauss_smoothdata(:,1,i), I] = max(smoothdata(wfpmerge.binned_backscatter_filt_wtgaps(ind_filt_wtgaps{i},:,6),"gaussian",8,'omitnan'));
    % sinkingpulse_Btot_gauss_smoothdata(:,2,i) = ind_filt_wtgaps{i}(I); %index of max
    % sinkingpulse_Btot_gauss_smoothdata(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{i}(I)); %time of max value
    % [sinkingpulse_b_bp_gauss_smoothdata(:,1,i), I] = max(smoothdata(wfpmerge.binned_b_bp_filt_wtgaps(ind_filt_wtgaps{i},:,6),"gaussian",8,'omitnan'));
    % sinkingpulse_b_bp_gauss_smoothdata(:,2,i) = ind_filt_wtgaps{i}(I); %index of max
    % sinkingpulse_b_bp_gauss_smoothdata(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{i}(I)); %time of max value
    [sinkingpulse_max_gaussfilter_omitnan(:,1,i), I] = max(smoothdata(wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{i},:,6),"gaussian",6,'omitnan'));
    sinkingpulse_max_gaussfilter_omitnan(:,2,i) = ind_filt_wtgaps{i}(I); %index of max
    sinkingpulse_max_gaussfilter_omitnan(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{i}(I)); %time of max value

    [sinkingpulse_max_gaussfilter_includenan(:,1,i), I] = max(smoothdata(wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{i},:,6),"gaussian",6,'includenan'));
    sinkingpulse_max_gaussfilter_includenan(:,2,i) = ind_filt_wtgaps{i}(I); %index of max
    sinkingpulse_max_gaussfilter_includenan(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{i}(I)); %time of max value

    figure(100)
    [X2_filt_wtgaps,Y2_filt_wtgaps] = meshgrid(day(datetime(wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{i}),'ConvertFrom','datenum'),'dayofyear'),wfpmerge.sinkingpulsedepths);
    subplot(2,4,i)
    % C = squeeze(wfpmerge.binned_filteredspikes_smoothed(ind_filt_wtgaps{i},:,6));
    
    C = squeeze(wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{i},:,6));
    pcolor(X2_filt_wtgaps,Y2_filt_wtgaps,C','linestyle','none')
    axis ij
    cmocean('amp')
    clim([0 0.0011])
    ylabel('Depth (m)')
    xlabel('Day of Year')
    if yrstr(i) == max(yrstr)
        colorbar
    end
    title([string(yrstr(i))])
    sgtitle('95th percentile')

    figure(101)
    subplot(2,4,i)
    C = squeeze(wfpmerge.binned_filteredspikes_smoothed(ind_filt_wtgaps{i},:,6));
    pcolor(X2_filt_wtgaps,Y2_filt_wtgaps,C','linestyle','none')
    axis ij
    % datetick('x','Keeplimits')
    cmocean('amp')
    % clim([0 0.0011])
    ylabel('Depth (m)')
    xlabel('Day of Year')
    if yrstr(i) == max(yrstr)
        colorbar
    end
    title([string(yrstr(i))])
    sgtitle('6-profile moving mean of the 95th percentile')

    figure(102)
    subplot(2,4,i)
    C = squeeze(smoothdata(wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{i},:,6),"gaussian",6,'omitnan'));
    pcolor(X2_filt_wtgaps,Y2_filt_wtgaps,C','linestyle','none')
    axis ij
    % datetick('x','Keeplimits')
    cmocean('amp')
    % clim([0 0.0011])
    ylabel('Depth (m)')
    xlabel('Day of Year')
    if yrstr(i) == max(yrstr)
        colorbar
    end
    title([string(yrstr(i))])
    sgtitle('6-profile gaussian smoothing')


    figure(103)
    subplot(2,4,i)
    C = gaussfit1_plot{i};
    pcolor(X2_filt_wtgaps,Y2_filt_wtgaps,C','linestyle','none')
    axis ij
    % datetick('x','Keeplimits')
    cmocean('amp')
    % clim([0 0.0011])
    ylabel('Depth (m)')
    xlabel('Day of Year')
    if yrstr(i) == max(yrstr)
        colorbar
    end
    title([string(yrstr(i))])
    sgtitle('1st-power gaussian fit')

    figure(104)
    subplot(2,4,i)
    C = gaussfit2_plot{i};
    pcolor(X2_filt_wtgaps,Y2_filt_wtgaps,C','linestyle','none')
    axis ij
    % datetick('x','Keeplimits')
    cmocean('amp')
    % clim([0 0.0011])
    ylabel('Depth (m)')
    xlabel('Day of Year')
    if yrstr(i) == max(yrstr)
        colorbar
    end
    title([string(yrstr(i))])
    sgtitle('2nd-power gaussian fit')
end
%%

for yr = 1:length(yrstr)
    figure(yr)
    for j = 1:length(wfpmerge.sinkingpulsedepths)
        plot(gofgauss{yr}{j}.rsquare,wfpmerge.sinkingpulsedepths(j),'.k','MarkerSize',20)
        hold on
        axis ij
    end
end
%%
addpath(genpath('G:\My Drive\Matlab_work\Github\cdt'))
    z = [1:5:20];
    z = z+0;

for yr = 1:length(yrstr)
   
    figure
    for j = 1:length(z)
                [exclude1] = isnan(wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{yr},z(j),6));
                [gaussfit_z] = fit(ind_filt_wtgaps{yr},wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{yr},z(j),6),'gauss2','Normalize','off','Exclude', exclude1);
    
        [m1,n1] = max(wfpmerge.binned_filteredspikes_smoothed(ind_filt_wtgaps{yr},z(j),6));
        [m2,n2] = max(smoothdata(wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{yr},z(j),6),"movmean",6,'includenan'));
        [m3,n3] = max(smoothdata(wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{yr},z(j),6),"gaussian",6,'omitnan'));
        [m4,n4] = max(gaussfit_z(ind_filt_wtgaps{yr}));
    
        subplot(length(z),1,j)
        plot(ind_filt_wtgaps{yr}(n1),m1,'o','Color',rgb('dull orange'),'Linewidth',6)
        hold on
        plot(ind_filt_wtgaps{yr}(n2),m2,'o','Color',rgb('medium blue'),'Linewidth',6)
        plot(ind_filt_wtgaps{yr}(n3),m3,'o','Color',rgb('forest green'),'Linewidth',6)
        plot(ind_filt_wtgaps{yr}(n4),m4,'o','Color',rgb('purple'),'Linewidth',6)
        plot(ind_filt_wtgaps{yr},wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{yr},z(j),6),'k.','MarkerSize',20)
        plot(ind_filt_wtgaps{yr},wfpmerge.binned_filteredspikes_smoothed(ind_filt_wtgaps{yr},z(j),6),'Color',rgb('dull orange'),'Linewidth',2)
        plot(ind_filt_wtgaps{yr},smoothdata(wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{yr},z(j),6),"movmean",5,'includenan'),'--','Color',rgb('medium blue'),'Linewidth',1.5)
        plot(ind_filt_wtgaps{yr},smoothdata(wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{yr},z(j),6),"gaussian",5,'omitnan'),'-.','Color',rgb('forest green'),'Linewidth',1.3)
        plot(ind_filt_wtgaps{yr},gaussfit_z(ind_filt_wtgaps{yr}),'-','Color',rgb('purple'),'Linewidth',1.3)
        plot(ind_filt_wtgaps{yr},wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{yr},z(j),6),'k.','MarkerSize',20)
        ylabel([num2str(wfpmerge.sinkingpulsedepths(z(j))) ' m'])
        if z(j) == min(z)
            legend('movmean','movmean w/ nan','gauss smooth','gauss fit','Orientation','horizontal','Location','northoutside')
        end
        if z(j) == max(z)
            xlabel('Profile Number')
        end
        sgtitle(['Particle Pulse ' num2str(yr)])
    end
end


% %% Plot for selected depths
% figure(1); clf
% bins_to_plot = [2, 7, 14]; %can alter to switch depths to look at
% L = 2; M = 4;
% for i = 1:3
%         subplot(3,1,i)
%     plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_backscatter_filt_wtgaps(:, bins_to_plot(i), 4)), '.','markersize',M,'color',nicecolor('rmw')); hold on;
%     plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_backscatter_filt_wtgaps(:, bins_to_plot(i), 6)), '.', 'markersize',M,'color',nicecolor('bcw')); hold on;
%     plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_backscatter_smoothed(:, bins_to_plot(i), 4)), '-','linewidth',L-1,'color',nicecolor('rmk')); hold on;
%     plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_backscatter_smoothed(:, bins_to_plot(i), 6)), '-','linewidth',L,'color',nicecolor('bcbck')); hold on;
%     plot(squeeze(sinkingpulse_Btot(bins_to_plot(i),3,:)), squeeze(sinkingpulse_Btot(bins_to_plot(i),1,:)), 'ko','markersize',M*2,'markerfacecolor','y'); hold on;
%     xlim([min(wfpmerge.profile_start_filt_wtgaps) - 10, max(wfpmerge.profile_start_filt_wtgaps) + 10])
%     datetick('x','keeplimits')
%     ylabel('Backscatter, m^{-1}')
%     title(['OOI Irminger WFP, binned & filtered total optical backscatter: Depth interval from ' num2str(wfpmerge.depthbins(bins_to_plot(i))) ' to ' num2str(wfpmerge.depthbins(bins_to_plot(i)+1)) 'm']);
%     legend('Profile max','Profile 95th percentile','6-profile profile max movmean',...
%         '6-prof 95th percentile movmean','Annual max of 6-profile movmean of 95th percentile',...
%         'Orientation','horizontal')
% end
% 
% figure(2); clf
% for i = 1:3
%         subplot(3,1,i)
%     plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_b_bp_filt_wtgaps(:, bins_to_plot(i), 4)), '.','markersize',M,'color',nicecolor('rmw')); hold on;
%     plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_b_bp_filt_wtgaps(:, bins_to_plot(i), 6)), '.', 'markersize',M,'color',nicecolor('bcw')); hold on;
%     plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_b_bp_smoothed(:, bins_to_plot(i), 4)), '-','linewidth',L-1,'color',nicecolor('rmk')); hold on;
%     plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_b_bp_smoothed(:, bins_to_plot(i), 6)), '-','linewidth',L,'color',nicecolor('bcbck')); hold on;
%     plot(squeeze(sinkingpulse_b_bp(bins_to_plot(i),3,:)), squeeze(sinkingpulse_b_bp(bins_to_plot(i),1,:)), 'ko','markersize',M*2,'markerfacecolor','y'); hold on;
%     xlim([min(wfpmerge.profile_start_filt_wtgaps) - 10, max(wfpmerge.profile_start_filt_wtgaps) + 10])
%     datetick('x','keeplimits')
%     ylabel('Backscatter, m^{-1}')
%     title(['OOI Irminger WFP, binned & filtered particle scatter : Depth interval from ' num2str(wfpmerge.depthbins(bins_to_plot(i))) ' to ' num2str(wfpmerge.depthbins(bins_to_plot(i)+1)) 'm']);
%     legend('Profile max','Profile 95th percentile','6-profile profile max movmean',...
%         '6-prof 95th percentile movmean','Annual max of 6-profile movmean of 95th percentile',...
%         'Orientation','horizontal')
% end
% %%
% 
% figure(3); clf
% bins_to_plot = [2, 7, 14]; %can alter to switch depths to look at
% L = 2; M = 4;
% for i = 1:3
%         subplot(3,1,i)
%     %plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_filteredspikes_filt_wtgaps(:, bins_to_plot(i), 4)), '.','markersize',M,'color',nicecolor('rmw')); hold on;
%     plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_filteredspikes_filt_wtgaps(:, bins_to_plot(i), 6)), '.', 'markersize',M,'color',nicecolor('bcw')); hold on;
%     for j = 1:length(yrstr)
%         plot(wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{j}), gaussfit{j}{bins_to_plot(i)}(ind_filt_wtgaps{j}),'k:','Linewidth',1.5)
%     end
%     %plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_filteredspikes_smoothed(:, bins_to_plot(i), 4)), '-','linewidth',L-1,'color',nicecolor('rmk')); hold on;
%     plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_filteredspikes_smoothed(:, bins_to_plot(i), 6)), '-','linewidth',L,'color',nicecolor('bcbck')); hold on;
%     plot(squeeze(sinkingpulse_gauss(bins_to_plot(i),3,:)), squeeze(sinkingpulse_gauss(bins_to_plot(i),1,:)), 'ko','markersize',M*2,'markerfacecolor','y'); hold on;
%     xlim([min(wfpmerge.profile_start_filt_wtgaps) - 10, max(wfpmerge.profile_start_filt_wtgaps) + 10])
%     datetick('x','keeplimits')
%     ylabel('Backscatter, m^{-1}')
%     title(['OOI Irminger WFP, binned & filtered large particle spikes: Depth interval from ' num2str(wfpmerge.depthbins(bins_to_plot(i))) ' to ' num2str(wfpmerge.depthbins(bins_to_plot(i)+1)) 'm']);
%     legend('Profile 95th percentile',...
%         '6-prof 95th percentile movmean','Annual max of 6-profile movmean of 95th percentile',...
%         'Orientation','horizontal')
% end

% 
% %% SinkingPulseAndMartinCurveCalculationsBinnedHP 
% 
% MartinFit = fittype ('c*x.^-b');
% ymin = 200;
% ymax = 2000;
% M = 20;
% 
% figure(1); clf;
% for i = [1,2,5]
%     if i == 3
%         LinearFit{i} = fitlm(sinkingpulse(1:15,3,i), wfpmerge.sinkingpulsedepths(1:15));
%         MartinCurve{i} = fit (sinkingpulse(1:15,1,i), wfpmerge.sinkingpulsedepths(1:15), MartinFit);
%     else
%         LinearFit{i} = fitlm(sinkingpulse(:,3,i), wfpmerge.sinkingpulsedepths);
%         MartinCurve{i} = fit (sinkingpulse(:,1,i), wfpmerge.sinkingpulsedepths, MartinFit);
%     end
% 
% 
% %Set up indices for plotting
% if i < 3
%     ind = i;
% elseif i == 5
%     ind = 3;
% end
% 
% subplot(3,2,2*ind-1)
% plot(LinearFit{i}); hold on;
% plot(squeeze(sinkingpulse(:,3,i)), wfpmerge.sinkingpulsedepths, 'k.','markersize', M);
% % plot(squeeze(sinkingpulse_b_bp(:,3,i)), wfpmerge.sinkingpulsedepths, 'k.','markersize', M);
% % plot(squeeze(sinkingpulse_Btot(:,3,i)), wfpmerge.sinkingpulsedepths, 'k.','markersize', M);
% legend off
% set (gca,'YDir','reverse')
% datetick ('x','mmm-yyyy','keeplimits')
% ylim ([ymin ymax])
% ylabel ('Depth (m)')
% xlabel('Date')
% title(['Sinking rate = ' num2str(table2array(LinearFit{i}.Coefficients(2,1)),3) ' ' char(177) ' ' num2str(table2array(LinearFit{i}.Coefficients(2,2)),2) ' m/d'])
% 
% subplot(3,2,2*ind)
% plot(sinkingpulse(:,1,i), wfpmerge.sinkingpulsedepths, 'k.','markersize', M); hold on;
% % plot(sinkingpulse_b_bp(:,1,i), wfpmerge.sinkingpulsedepths, 'k.','markersize', M); hold on;
% % plot(sinkingpulse_Btot(:,1,i), wfpmerge.sinkingpulsedepths, 'k.','markersize', M); hold on;
% plot (MartinCurve{i});
% legend off
% set (gca,'YDir','reverse')
% ylim ([ymin ymax])
% ylabel ('Depth (m)')
% xlabel ('Maximum spike size (m^-^1)')
% title(['Flux attenuation (b = ' num2str(MartinCurve{i}.b,3) ')'])
% 
% end
% My edits 
%SinkingPulseAndMartinCurveCalculationsBinnedHP 

% MartinFit seems to vary since not a great fit. Message on some of the
% fits is "Success, but fitting stopped because cause in residuals less
% than tolerance." 


%%
addpath(genpath('G:\My Drive\Matlab_work\Github\cdt'))
colorblind = [0 0.61961 0.45098; 0 0.44706 0.69804; 0.33725 0.70588 0.91373; 0.94118 0.89412 0.25882;...
    0.90196 0.62353 0; 0.83529 0.36863 0; 0.8 0.47451 0.6549];
M = 20;

% Calculate sinking velocities for all pulses 
for i = 1:8
    LinearFit_movmean_includenan{i} = fitlm(wfpmerge.sinkingpulsedepths,day(datetime(sinkingpulse_max_movmean_includenan(:,3,i),'ConvertFrom','datenum'),'dayofyear'));
    LinearFit_movmean_omitnan{i} = fitlm(wfpmerge.sinkingpulsedepths,day(datetime(sinkingpulse_max_movmean_omitnan(:,3,i),'ConvertFrom','datenum'),'dayofyear'));
    LinearFit_gaussfilter_includenan{i} = fitlm(wfpmerge.sinkingpulsedepths,day(datetime(sinkingpulse_max_gaussfilter_includenan(:,3,i),'ConvertFrom','datenum'),'dayofyear'));
    LinearFit_gaussfilter_omitnan{i} = fitlm(wfpmerge.sinkingpulsedepths,day(datetime(sinkingpulse_max_gaussfilter_omitnan(:,3,i),'ConvertFrom','datenum'),'dayofyear'));
    LinearFit_gauss1{i} = fitlm(wfpmerge.sinkingpulsedepths,day(datetime(sinkingpulse_gauss1(:,3,i),'ConvertFrom','datenum'),'dayofyear'));
    LinearFit_gauss2{i} = fitlm(wfpmerge.sinkingpulsedepths,day(datetime(sinkingpulse_gauss2(:,3,i),'ConvertFrom','datenum'),'dayofyear'));

end

vel_pulses_good = [1:3 5];
vel_pulses_good = [1:8];

f = figure; f.Position = [50 50 550 700];
for j = 1:length(vel_pulses_good)
    subplot(2,4,j)
    plot(LinearFit_movmean_includenan{vel_pulses_good(j)},'Linewidth',1.5); hold on;
    plot(wfpmerge.sinkingpulsedepths,day(datetime(sinkingpulse_max_movmean_includenan(:,3,vel_pulses_good(j)),'ConvertFrom','datenum'),'dayofyear'), '.k','markersize', M);
    legend off
    xlabel ('Depth (m)')
    ylabel('day of year')
    SR = 1/table2array(LinearFit_movmean_includenan{vel_pulses_good(j)}.Coefficients(2,1)); 
    SR_high = 1/(table2array(LinearFit_movmean_includenan{vel_pulses_good(j)}.Coefficients(2,1) - table2array(LinearFit_movmean_includenan{vel_pulses_good(j)}.Coefficients(2,2))));
    SR_low = 1/(table2array(LinearFit_movmean_includenan{vel_pulses_good(j)}.Coefficients(2,1) + table2array(LinearFit_movmean_includenan{vel_pulses_good(j)}.Coefficients(2,2))));
    if yrstr(vel_pulses_good(j)) == 2016
        title(['First pulse 2016, R2 = ' num2str(LinearFit_movmean_includenan{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d']);
    elseif yrstr(vel_pulses_good(j)) == 2016.5
        title(['Second pulse 2016, R2 = ' num2str(LinearFit_movmean_includenan{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d'])
    else
        title(['Pulse ' num2str(yrstr(vel_pulses_good(j))) ' , R2 = ' num2str(LinearFit_movmean_includenan{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d'])
    end
    sgtitle('Maximum of 6-profile movmean include nans')
end

f = figure; f.Position = [50 50 550 700];
for j = 1:length(vel_pulses_good)
    subplot(2,4,j)
    plot(LinearFit_movmean_omitnan{vel_pulses_good(j)},'Linewidth',1.5); hold on;
    plot(wfpmerge.sinkingpulsedepths,day(datetime(sinkingpulse_max_movmean_omitnan(:,3,vel_pulses_good(j)),'ConvertFrom','datenum'),'dayofyear'), '.k','markersize', M);
    legend off
    xlabel ('Depth (m)')
    ylabel('day of year')
    SR = 1/table2array(LinearFit_movmean_omitnan{vel_pulses_good(j)}.Coefficients(2,1)); 
    SR_high = 1/(table2array(LinearFit_movmean_omitnan{vel_pulses_good(j)}.Coefficients(2,1) - table2array(LinearFit_movmean_omitnan{vel_pulses_good(j)}.Coefficients(2,2))));
    SR_low = 1/(table2array(LinearFit_movmean_omitnan{vel_pulses_good(j)}.Coefficients(2,1) + table2array(LinearFit_movmean_omitnan{vel_pulses_good(j)}.Coefficients(2,2))));
    if yrstr(vel_pulses_good(j)) == 2016
        title(['First pulse 2016, R2 = ' num2str(LinearFit_movmean_omitnan{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d'])
    elseif yrstr(vel_pulses_good(j)) == 2016.5
        title(['Second pulse 2016, R2 = ' num2str(LinearFit_movmean_omitnan{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d'])
    else
        title(['Pulse ' num2str(yrstr(vel_pulses_good(j))) ' , R2 = ' num2str(LinearFit_movmean_omitnan{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d'])
    end
    sgtitle('Maximum of 6-profile movmean omit nans')
end

f = figure; f.Position = [50 50 550 700];
for j = 1:length(vel_pulses_good)
    subplot(2,4,j)
    plot(LinearFit_gaussfilter_includenan{vel_pulses_good(j)},'Linewidth',1.5); hold on;
    plot(wfpmerge.sinkingpulsedepths,day(datetime(sinkingpulse_max_gaussfilter_includenan(:,3,vel_pulses_good(j)),'ConvertFrom','datenum'),'dayofyear'), '.k','markersize', M);
    legend off
    xlabel ('Depth (m)')
    ylabel('day of year')
    SR = 1/table2array(LinearFit_gaussfilter_includenan{vel_pulses_good(j)}.Coefficients(2,1)); 
    SR_high = 1/(table2array(LinearFit_gaussfilter_includenan{vel_pulses_good(j)}.Coefficients(2,1) - table2array(LinearFit_gaussfilter_includenan{vel_pulses_good(j)}.Coefficients(2,2))));
    SR_low = 1/(table2array(LinearFit_gaussfilter_includenan{vel_pulses_good(j)}.Coefficients(2,1) + table2array(LinearFit_gaussfilter_includenan{vel_pulses_good(j)}.Coefficients(2,2))));
    if yrstr(vel_pulses_good(j)) == 2016
        title(['First pulse 2016, R2 = ' num2str(LinearFit_gaussfilter_includenan{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d'])
    elseif yrstr(vel_pulses_good(j)) == 2016.5
        title(['Second pulse 2016, R2 = ' num2str(LinearFit_gaussfilter_includenan{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d'])
    else
        title(['Pulse ' num2str(yrstr(vel_pulses_good(j))) ' , R2 = ' num2str(LinearFit_gaussfilter_includenan{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d'])
    end
    sgtitle('Maximum of 6-profile Gaussian smoothing include nans')
end

f = figure; f.Position = [50 50 550 700];
for j = 1:length(vel_pulses_good)
    subplot(2,4,j)
    plot(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)},'Linewidth',1.5); hold on;
    plot(wfpmerge.sinkingpulsedepths,day(datetime(sinkingpulse_max_gaussfilter_omitnan(:,3,vel_pulses_good(j)),'ConvertFrom','datenum'),'dayofyear'), '.k','markersize', M);
    legend off
    xlabel ('Depth (m)')
    ylabel('day of year')
    SR = 1/table2array(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Coefficients(2,1)); 
    SR_high = 1/(table2array(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Coefficients(2,1) - table2array(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Coefficients(2,2))));
    SR_low = 1/(table2array(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Coefficients(2,1) + table2array(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Coefficients(2,2))));
    if yrstr(vel_pulses_good(j)) == 2016
        title(['First pulse 2016, R2 = ' num2str(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d'])
    elseif yrstr(vel_pulses_good(j)) == 2016.5
        title(['Second pulse 2016, R2 = ' num2str(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d'])
    else
        title(['Pulse ' num2str(yrstr(vel_pulses_good(j))) ' , R2 = ' num2str(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d'])
    end
    sgtitle('Maximum of 6-profile Gaussian smoothing omit nans')
end

f = figure; f.Position = [50 50 550 700];
for j = 1:length(vel_pulses_good)
    subplot(2,4,j)
    plot(LinearFit_gauss1{vel_pulses_good(j)},'Linewidth',1.5); hold on;
    plot(wfpmerge.sinkingpulsedepths,day(datetime(sinkingpulse_gauss1(:,3,vel_pulses_good(j)),'ConvertFrom','datenum'),'dayofyear'), '.k','markersize', M);
    legend off
    xlabel ('Depth (m)')
    ylabel('day of year')
    SR = 1/table2array(LinearFit_gauss1{vel_pulses_good(j)}.Coefficients(2,1)); 
    SR_high = 1/(table2array(LinearFit_gauss1{vel_pulses_good(j)}.Coefficients(2,1) - table2array(LinearFit_gauss1{vel_pulses_good(j)}.Coefficients(2,2))));
    SR_low = 1/(table2array(LinearFit_gauss1{vel_pulses_good(j)}.Coefficients(2,1) + table2array(LinearFit_gauss1{vel_pulses_good(j)}.Coefficients(2,2))));
    if yrstr(vel_pulses_good(j)) == 2016
        title(['First pulse 2016, R2 = ' num2str(LinearFit_gauss1{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d'])
    elseif yrstr(vel_pulses_good(j)) == 2016.5
        title(['Second pulse 2016, R2 = ' num2str(LinearFit_gauss1{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d'])
    else
        title(['Pulse ' num2str(yrstr(vel_pulses_good(j))) ' , R2 = ' num2str(LinearFit_gauss1{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d'])
    end
    sgtitle('Maximum of 1st-order Gaussian Fit')
end

f = figure; f.Position = [50 50 550 700];
for j = 1:length(vel_pulses_good)
    subplot(2,4,j)
    plot(LinearFit_gauss2{vel_pulses_good(j)},'Linewidth',1.5); hold on;
    plot(wfpmerge.sinkingpulsedepths,day(datetime(sinkingpulse_gauss2(:,3,vel_pulses_good(j)),'ConvertFrom','datenum'),'dayofyear'), '.k','markersize', M);
    legend off
    xlabel ('Depth (m)')
    ylabel('day of year')
    SR = 1/table2array(LinearFit_gauss2{vel_pulses_good(j)}.Coefficients(2,1)); 
    SR_high = 1/(table2array(LinearFit_gauss2{vel_pulses_good(j)}.Coefficients(2,1) - table2array(LinearFit_gauss2{vel_pulses_good(j)}.Coefficients(2,2))));
    SR_low = 1/(table2array(LinearFit_gauss2{vel_pulses_good(j)}.Coefficients(2,1) + table2array(LinearFit_gauss2{vel_pulses_good(j)}.Coefficients(2,2))));
    if yrstr(vel_pulses_good(j)) == 2016
        title(['First pulse 2016, R2 = ' num2str(LinearFit_gauss2{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d'])
    elseif yrstr(vel_pulses_good(j)) == 2016.5
        title(['Second pulse 2016, R2 = ' num2str(LinearFit_gauss2{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d'])
    else
        title(['Pulse ' num2str(yrstr(vel_pulses_good(j))) ' , R2 = ' num2str(LinearFit_gauss2{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m/d'])
    end
    sgtitle('Maximum of 2nd-order Gaussian Fit')
end

%%
%pulses to include in mean attenuation calculations 
 
for i = [1:6,8]
        [curve_exp_movmean_includenan{i},gof_exp_movmean_includenan{i},output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_movmean_includenan(:,1,i),'exp1');  
        [curve_power_movmean_includenan{i},gof_power_movmean_includenan{i},output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_movmean_includenan(:,1,i),'power1');

        [curve_exp_movmean_omitnan{i},gof_exp_movmean_omitnan{i},output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_movmean_omitnan(:,1,i),'exp1');  
        [curve_power_movmean_omitnan{i},gof_power_movmean_omitnan{i},output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_movmean_omitnan(:,1,i),'power1');

        [curve_exp_gaussfilter_includenan{i},gof_exp_gaussfilter_includenan{i},output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_includenan(:,1,i),'exp1');  
        [curve_power_gaussfilter_includenan{i},gof_power_gaussfilter_includenan{i},output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_includenan(:,1,i),'power1');

        [curve_exp_gaussfilter_omitnan{i},gof_exp_gaussfilter_omitnan{i},output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan(:,1,i),'exp1');  
        [curve_power_gaussfilter_omitnan{i},gof_power_gaussfilter_omitnan{i},output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan(:,1,i),'power1');

        [curve_exp_gauss1{i},gof_exp_gauss1{i},output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_gauss1(:,1,i),'exp1');  
        [curve_power_gauss1{i},gof_power_gauss1{i},output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_gauss1(:,1,i),'power1');

        [curve_exp_gauss2{i},gof_exp_gauss2{i},output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_gauss2(:,1,i),'exp1');  
        [curve_power_gauss2{i},gof_power_gauss2{i},output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_gauss2(:,1,i),'power1');
end


atten_pulses_good = [1:3 5];
atten_pulses_good = [1:6 8];

sinkingpulse_max_movmean_includenan_mean = nanmean(squeeze(sinkingpulse_max_movmean_includenan(:,1,atten_pulses_good)),2); 
sinkingpulse_max_movmean_includenan_std = nanstd(squeeze(sinkingpulse_max_movmean_includenan(:,1,atten_pulses_good)),0,2); 

sinkingpulse_max_movmean_omitnan_mean = nanmean(squeeze(sinkingpulse_max_movmean_omitnan(:,1,atten_pulses_good)),2); 
sinkingpulse_max_movmean_omitnan_std = nanstd(squeeze(sinkingpulse_max_movmean_omitnan(:,1,atten_pulses_good)),0,2); 

sinkingpulse_max_gaussfilter_includenan_mean = nanmean(squeeze(sinkingpulse_max_gaussfilter_includenan(:,1,atten_pulses_good)),2); 
sinkingpulse_max_gaussfilter_includenan_std = nanstd(squeeze(sinkingpulse_max_gaussfilter_includenan(:,1,atten_pulses_good)),0,2); 

sinkingpulse_max_gaussfilter_omitnan_mean = nanmean(squeeze(sinkingpulse_max_gaussfilter_omitnan(:,1,atten_pulses_good)),2); 
sinkingpulse_max_gaussfilter_omitnan_std = nanstd(squeeze(sinkingpulse_max_gaussfilter_omitnan(:,1,atten_pulses_good)),0,2); 

sinkingpulse_max_gauss1_mean = nanmean(squeeze(sinkingpulse_gauss1(:,1,atten_pulses_good)),2); 
sinkingpulse_max_gauss1_std = nanstd(squeeze(sinkingpulse_gauss1(:,1,atten_pulses_good)),0,2); 

sinkingpulse_max_gauss2_mean = nanmean(squeeze(sinkingpulse_gauss2(:,1,atten_pulses_good)),2); 
sinkingpulse_max_gauss2_std = nanstd(squeeze(sinkingpulse_gauss2(:,1,atten_pulses_good)),0,2); 


[curve_exp_movmean_includenan_mean,gof_exp_movmean_includenan_mean,output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_movmean_includenan_mean,'exp1');  
[curve_power_movmean_includenan_mean,gof_power_movmean_includenan_mean,output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_movmean_includenan_mean,'power1');

[curve_exp_movmean_omitnan_mean,gof_exp_movmean_omitnan_mean,output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_movmean_omitnan_mean,'exp1');  
[curve_power_movmean_omitnan_mean,gof_power_movmean_omitnan_mean,output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_movmean_omitnan_mean,'power1');

[curve_exp_gaussfilter_includenan_mean,gof_exp_gaussfilter_includenan_mean,output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_includenan_mean,'exp1');  
[curve_power_gaussfilter_includenan_mean,gof_power_gaussfilter_includenan_mean,output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_includenan_mean,'power1');

[curve_exp_gaussfilter_omitnan_mean,gof_exp_gaussfilter_omitnan_mean,output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan_mean,'exp1');  
[curve_power_gaussfilter_omitnan_mean,gof_power_gaussfilter_omitnan_mean,output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan_mean,'power1');

[curve_exp_gauss1_mean,gof_exp_gauss1_mean,output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gauss1_mean,'exp1');  
[curve_power_gauss1_mean,gof_power_gauss1_mean,output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gauss1_mean,'power1');

[curve_exp_gauss2_mean,gof_exp_gauss2_mean,output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gauss2_mean,'exp1');  
[curve_power_gauss2_mean,gof_power_gauss2_mean,output] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gauss2_mean,'power1');

figure
for j = 1:length(atten_pulses_good)
    subplot(2,4,j)
    plot(sinkingpulse_max_movmean_includenan(:,1,atten_pulses_good(j)),wfpmerge.sinkingpulsedepths,'.','markersize', M)
    hold on
    plot(curve_exp_movmean_includenan{atten_pulses_good(j)}.a*exp(curve_exp_movmean_includenan{atten_pulses_good(j)}.b*(200:2000)),200:2000,'k','Linewidth',2)
    plot(curve_power_movmean_includenan{atten_pulses_good(j)}.a*(200:2000).^curve_power_movmean_includenan{atten_pulses_good(j)}.b,200:2000,'k--','Linewidth',2)
    plot(curve_exp_movmean_includenan{atten_pulses_good(j)}.a*exp(curve_exp_movmean_includenan{atten_pulses_good(j)}.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
    plot(curve_power_movmean_includenan{atten_pulses_good(j)}.a*(50:200).^curve_power_movmean_includenan{atten_pulses_good(j)}.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
    legend off
    axis ij
    ylabel ('Depth (m)')
    xlabel('max b_b_l (m^-^1)')
    if yrstr(atten_pulses_good(j)) == 2016
        title('First pulse 2016')
    elseif yrstr(atten_pulses_good(j)) == 2016.5
        title('Second pulse 2016')
    else
        title(string(yrstr(atten_pulses_good(j))))
    end
    sgtitle('Maximum of 6-profile movmean include nans')
end

subplot(2,4,8)
errorbar(sinkingpulse_max_movmean_includenan_mean,wfpmerge.sinkingpulsedepths,sinkingpulse_max_movmean_includenan_std,'horizontal','.','MarkerSize',20,'CapSize',0)
hold on
axis ij
plot(curve_exp_movmean_includenan_mean.a*exp(curve_exp_movmean_includenan_mean.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
plot(curve_power_movmean_includenan_mean.a*(50:200).^curve_power_movmean_includenan_mean.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
plot(curve_exp_movmean_includenan_mean.a*exp(curve_exp_movmean_includenan_mean.b*(200:2000)),200:2000,'k','Linewidth',2)
plot(curve_power_movmean_includenan_mean.a*(200:2000).^curve_power_movmean_includenan_mean.b,200:2000,'k--','Linewidth',2)
ylabel('depth (m)')
axis ij
ylabel ('Depth (m)')
xlabel('max b_b_l (m^-^1)')
title('All pulses 2015-2019')

figure
for j = 1:7
    subplot(2,4,j)
    plot(sinkingpulse_max_movmean_omitnan(:,1,atten_pulses_good(j)),wfpmerge.sinkingpulsedepths,'.','markersize', M)
    hold on
    plot(curve_exp_movmean_omitnan{atten_pulses_good(j)}.a*exp(curve_exp_movmean_omitnan{atten_pulses_good(j)}.b*(200:2000)),200:2000,'k','Linewidth',2)
    plot(curve_power_movmean_omitnan{atten_pulses_good(j)}.a*(200:2000).^curve_power_movmean_omitnan{atten_pulses_good(j)}.b,200:2000,'k--','Linewidth',2)
    plot(curve_exp_movmean_omitnan{atten_pulses_good(j)}.a*exp(curve_exp_movmean_omitnan{atten_pulses_good(j)}.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
    plot(curve_power_movmean_omitnan{atten_pulses_good(j)}.a*(50:200).^curve_power_movmean_omitnan{atten_pulses_good(j)}.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
    legend off
    axis ij
    ylabel ('Depth (m)')
    xlabel('max b_b_l (m^-^1)')
    if yrstr(atten_pulses_good(j)) == 2016
        title('First pulse 2016')
    elseif yrstr(atten_pulses_good(j)) == 2016.5
        title('Second pulse 2016')
    else
        title(string(yrstr(atten_pulses_good(j))))
    end
    sgtitle('Maximum of 6-profile movmean omit nans')
end

subplot(2,4,8)
errorbar(sinkingpulse_max_movmean_omitnan_mean,wfpmerge.sinkingpulsedepths,sinkingpulse_max_movmean_omitnan_std,'horizontal','.','MarkerSize',20,'CapSize',0)
hold on
axis ij
plot(curve_exp_movmean_omitnan_mean.a*exp(curve_exp_movmean_omitnan_mean.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
plot(curve_power_movmean_omitnan_mean.a*(50:200).^curve_power_movmean_omitnan_mean.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
plot(curve_exp_movmean_omitnan_mean.a*exp(curve_exp_movmean_omitnan_mean.b*(200:2000)),200:2000,'k','Linewidth',2)
plot(curve_power_movmean_omitnan_mean.a*(200:2000).^curve_power_movmean_omitnan_mean.b,200:2000,'k--','Linewidth',2)
ylabel('depth (m)')
axis ij
ylabel ('Depth (m)')
xlabel('max b_b_l (m^-^1)')
title('All pulses 2015-2019')

figure
for j = 1:7
    subplot(2,4,j)
    plot(sinkingpulse_max_gaussfilter_includenan(:,1,atten_pulses_good(j)),wfpmerge.sinkingpulsedepths,'.','markersize', M)
    hold on
    plot(curve_exp_gaussfilter_includenan{atten_pulses_good(j)}.a*exp(curve_exp_gaussfilter_includenan{atten_pulses_good(j)}.b*(200:2000)),200:2000,'k','Linewidth',2)
    plot(curve_power_gaussfilter_includenan{atten_pulses_good(j)}.a*(200:2000).^curve_power_gaussfilter_includenan{atten_pulses_good(j)}.b,200:2000,'k--','Linewidth',2)
    plot(curve_exp_gaussfilter_includenan{atten_pulses_good(j)}.a*exp(curve_exp_gaussfilter_includenan{atten_pulses_good(j)}.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
    plot(curve_power_gaussfilter_includenan{atten_pulses_good(j)}.a*(50:200).^curve_power_gaussfilter_includenan{atten_pulses_good(j)}.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
    legend off
    axis ij
    ylabel ('Depth (m)')
    xlabel('max b_b_l (m^-^1)')
    if yrstr(atten_pulses_good(j)) == 2016
        title('First pulse 2016')
    elseif yrstr(atten_pulses_good(j)) == 2016.5
        title('Second pulse 2016')
    else
        title(string(yrstr(atten_pulses_good(j))))
    end
    sgtitle('Maximum of 6-profile Gaussian filter include nans')
end

subplot(2,4,8)
errorbar(sinkingpulse_max_gaussfilter_includenan_mean,wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_includenan_std,'horizontal','.','MarkerSize',20,'CapSize',0)
hold on
axis ij
plot(curve_exp_gaussfilter_includenan_mean.a*exp(curve_exp_gaussfilter_includenan_mean.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
plot(curve_power_gaussfilter_includenan_mean.a*(50:200).^curve_power_gaussfilter_includenan_mean.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
plot(curve_exp_gaussfilter_includenan_mean.a*exp(curve_exp_gaussfilter_includenan_mean.b*(200:2000)),200:2000,'k','Linewidth',2)
plot(curve_power_gaussfilter_includenan_mean.a*(200:2000).^curve_power_gaussfilter_includenan_mean.b,200:2000,'k--','Linewidth',2)
ylabel('depth (m)')
axis ij
ylabel ('Depth (m)')
xlabel('max b_b_l (m^-^1)')
title('All pulses 2015-2019')

figure
for j = 1:7
    subplot(2,4,j)
    plot(sinkingpulse_max_gaussfilter_omitnan(:,1,atten_pulses_good(j)),wfpmerge.sinkingpulsedepths,'.','markersize', M)
    hold on
    plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.b*(200:2000)),200:2000,'k','Linewidth',2)
    plot(curve_power_gaussfilter_omitnan{atten_pulses_good(j)}.a*(200:2000).^curve_power_gaussfilter_omitnan{atten_pulses_good(j)}.b,200:2000,'k--','Linewidth',2)
    plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
    plot(curve_power_gaussfilter_omitnan{atten_pulses_good(j)}.a*(50:200).^curve_power_gaussfilter_omitnan{atten_pulses_good(j)}.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
    legend off
    axis ij
    ylabel ('Depth (m)')
    xlabel('max b_b_l (m^-^1)')
    if yrstr(atten_pulses_good(j)) == 2016
        title('First pulse 2016')
    elseif yrstr(atten_pulses_good(j)) == 2016.5
        title('Second pulse 2016')
    else
        title(string(yrstr(atten_pulses_good(j))))
    end
    sgtitle('Maximum of 6-profile Gaussian filter omit nans')
end

subplot(2,4,8)
errorbar(sinkingpulse_max_gaussfilter_omitnan_mean,wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan_std,'horizontal','.','MarkerSize',20,'CapSize',0)
hold on
axis ij
plot(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
plot(curve_power_gaussfilter_omitnan_mean.a*(50:200).^curve_power_gaussfilter_omitnan_mean.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
plot(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(200:2000)),200:2000,'k','Linewidth',2)
plot(curve_power_gaussfilter_omitnan_mean.a*(200:2000).^curve_power_gaussfilter_omitnan_mean.b,200:2000,'k--','Linewidth',2)
ylabel('depth (m)')
axis ij
ylabel ('Depth (m)')
xlabel('max b_b_l (m^-^1)')
title('All pulses 2015-2019')

figure
for j = 1:7
    subplot(2,4,j)
    plot(sinkingpulse_gauss1(:,1,atten_pulses_good(j)),wfpmerge.sinkingpulsedepths,'.','markersize', M)
    hold on
    plot(curve_exp_gauss1{atten_pulses_good(j)}.a*exp(curve_exp_gauss1{atten_pulses_good(j)}.b*(200:2000)),200:2000,'k','Linewidth',2)
    plot(curve_power_gauss1{atten_pulses_good(j)}.a*(200:2000).^curve_power_gauss1{atten_pulses_good(j)}.b,200:2000,'k--','Linewidth',2)
    plot(curve_exp_gauss1{atten_pulses_good(j)}.a*exp(curve_exp_gauss1{atten_pulses_good(j)}.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
    plot(curve_power_gauss1{atten_pulses_good(j)}.a*(50:200).^curve_power_gauss1{atten_pulses_good(j)}.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
    legend off
    axis ij
    ylabel ('Depth (m)')
    xlabel('max b_b_l (m^-^1)')
    if yrstr(atten_pulses_good(j)) == 2016
        title('First pulse 2016')
    elseif yrstr(atten_pulses_good(j)) == 2016.5
        title('Second pulse 2016')
    else
        title(string(yrstr(atten_pulses_good(j))))
    end
    sgtitle('1st-order Gaussian Fit')
end

subplot(2,4,8)
errorbar(sinkingpulse_max_gauss1_mean,wfpmerge.sinkingpulsedepths,sinkingpulse_max_gauss1_std,'horizontal','.','MarkerSize',20,'CapSize',0)
hold on
axis ij
plot(curve_exp_gauss1_mean.a*exp(curve_exp_gauss1_mean.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
plot(curve_power_gauss1_mean.a*(50:200).^curve_power_gauss1_mean.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
plot(curve_exp_gauss1_mean.a*exp(curve_exp_gauss1_mean.b*(200:2000)),200:2000,'k','Linewidth',2)
plot(curve_power_gauss1_mean.a*(200:2000).^curve_power_gauss1_mean.b,200:2000,'k--','Linewidth',2)
ylabel('depth (m)')
axis ij
ylabel ('Depth (m)')
xlabel('max b_b_l (m^-^1)')
title('All pulses 2015-2019')

figure
for j = 1:7
    subplot(2,4,j)
    plot(sinkingpulse_gauss2(:,1,atten_pulses_good(j)),wfpmerge.sinkingpulsedepths,'.','markersize', M)
    hold on
    plot(curve_exp_gauss2{atten_pulses_good(j)}.a*exp(curve_exp_gauss2{atten_pulses_good(j)}.b*(200:2000)),200:2000,'k','Linewidth',2)
    plot(curve_power_gauss2{atten_pulses_good(j)}.a*(200:2000).^curve_power_gauss2{atten_pulses_good(j)}.b,200:2000,'k--','Linewidth',2)
    plot(curve_exp_gauss2{atten_pulses_good(j)}.a*exp(curve_exp_gauss2{atten_pulses_good(j)}.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
    plot(curve_power_gauss2{atten_pulses_good(j)}.a*(50:200).^curve_power_gauss2{atten_pulses_good(j)}.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
    legend off
    axis ij
    ylabel ('Depth (m)')
    xlabel('max b_b_l (m^-^1)')
    if yrstr(atten_pulses_good(j)) == 2016
        title('First pulse 2016')
    elseif yrstr(atten_pulses_good(j)) == 2016.5
        title('Second pulse 2016')
    else
        title(string(yrstr(atten_pulses_good(j))))
    end
    sgtitle('2nd-order Gaussian Fit')
end

subplot(2,4,8)
errorbar(sinkingpulse_max_gauss2_mean,wfpmerge.sinkingpulsedepths,sinkingpulse_max_gauss2_std,'horizontal','.','MarkerSize',20,'CapSize',0)
hold on
axis ij
plot(curve_exp_gauss2_mean.a*exp(curve_exp_gauss2_mean.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
plot(curve_power_gauss2_mean.a*(50:200).^curve_power_gauss2_mean.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
plot(curve_exp_gauss2_mean.a*exp(curve_exp_gauss2_mean.b*(200:2000)),200:2000,'k','Linewidth',2)
plot(curve_power_gauss2_mean.a*(200:2000).^curve_power_gauss2_mean.b,200:2000,'k--','Linewidth',2)
ylabel('depth (m)')
axis ij
ylabel ('Depth (m)')
xlabel('max b_b_l (m^-^1)')
title('All pulses 2015-2019')
%%
figure
subplot(2,3,1)
errorbar(sinkingpulse_max_movmean_includenan_mean,wfpmerge.sinkingpulsedepths,sinkingpulse_max_movmean_includenan_std,'horizontal','.','MarkerSize',20,'CapSize',0)
hold on
axis ij
plot(curve_exp_movmean_includenan_mean.a*exp(curve_exp_movmean_includenan_mean.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
plot(curve_power_movmean_includenan_mean.a*(50:200).^curve_power_movmean_includenan_mean.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
plot(curve_exp_movmean_includenan_mean.a*exp(curve_exp_movmean_includenan_mean.b*(200:2000)),200:2000,'k','Linewidth',2)
plot(curve_power_movmean_includenan_mean.a*(200:2000).^curve_power_movmean_includenan_mean.b,200:2000,'k--','Linewidth',2)
ylabel('depth (m)')
axis ij
ylabel ('Depth (m)')
xlabel('max b_b_l (m^-^1)')
title('movmean include nan')

subplot(2,3,2)
errorbar(sinkingpulse_max_movmean_omitnan_mean,wfpmerge.sinkingpulsedepths,sinkingpulse_max_movmean_omitnan_std,'horizontal','.','MarkerSize',20,'CapSize',0)
hold on
axis ij
plot(curve_exp_movmean_omitnan_mean.a*exp(curve_exp_movmean_omitnan_mean.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
plot(curve_power_movmean_omitnan_mean.a*(50:200).^curve_power_movmean_omitnan_mean.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
plot(curve_exp_movmean_omitnan_mean.a*exp(curve_exp_movmean_omitnan_mean.b*(200:2000)),200:2000,'k','Linewidth',2)
plot(curve_power_movmean_omitnan_mean.a*(200:2000).^curve_power_movmean_omitnan_mean.b,200:2000,'k--','Linewidth',2)
ylabel('depth (m)')
axis ij
ylabel ('Depth (m)')
xlabel('max b_b_l (m^-^1)')
title('movmean omit nan')

subplot(2,3,3)
errorbar(sinkingpulse_max_gaussfilter_includenan_mean,wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_includenan_std,'horizontal','.','MarkerSize',20,'CapSize',0)
hold on
axis ij
plot(curve_exp_gaussfilter_includenan_mean.a*exp(curve_exp_gaussfilter_includenan_mean.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
plot(curve_power_gaussfilter_includenan_mean.a*(50:200).^curve_power_gaussfilter_includenan_mean.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
plot(curve_exp_gaussfilter_includenan_mean.a*exp(curve_exp_gaussfilter_includenan_mean.b*(200:2000)),200:2000,'k','Linewidth',2)
plot(curve_power_gaussfilter_includenan_mean.a*(200:2000).^curve_power_gaussfilter_includenan_mean.b,200:2000,'k--','Linewidth',2)
ylabel('depth (m)')
axis ij
ylabel ('Depth (m)')
xlabel('max b_b_l (m^-^1)')
title('gauss filter include nan')

subplot(2,3,4)
errorbar(sinkingpulse_max_gaussfilter_omitnan_mean,wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan_std,'horizontal','.','MarkerSize',20,'CapSize',0)
hold on
axis ij
plot(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
plot(curve_power_gaussfilter_omitnan_mean.a*(50:200).^curve_power_gaussfilter_omitnan_mean.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
plot(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(200:2000)),200:2000,'k','Linewidth',2)
plot(curve_power_gaussfilter_omitnan_mean.a*(200:2000).^curve_power_gaussfilter_omitnan_mean.b,200:2000,'k--','Linewidth',2)
ylabel('depth (m)')
axis ij
ylabel ('Depth (m)')
xlabel('max b_b_l (m^-^1)')
title('gauss filter omit nan')

subplot(2,3,5)
errorbar(sinkingpulse_max_gauss1_mean,wfpmerge.sinkingpulsedepths,sinkingpulse_max_gauss1_std,'horizontal','.','MarkerSize',20,'CapSize',0)
hold on
axis ij
plot(curve_exp_gauss1_mean.a*exp(curve_exp_gauss1_mean.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
plot(curve_power_gauss1_mean.a*(50:200).^curve_power_gauss1_mean.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
plot(curve_exp_gauss1_mean.a*exp(curve_exp_gauss1_mean.b*(200:2000)),200:2000,'k','Linewidth',2)
plot(curve_power_gauss1_mean.a*(200:2000).^curve_power_gauss1_mean.b,200:2000,'k--','Linewidth',2)
ylabel('depth (m)')
axis ij
ylabel ('Depth (m)')
xlabel('max b_b_l (m^-^1)')
xlim([0 1.5e-3])
title('1st-order gaussian')

subplot(2,3,6)
errorbar(sinkingpulse_max_gauss2_mean,wfpmerge.sinkingpulsedepths,sinkingpulse_max_gauss2_std,'horizontal','.','MarkerSize',20,'CapSize',0)
hold on
axis ij
plot(curve_exp_gauss2_mean.a*exp(curve_exp_gauss2_mean.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
plot(curve_power_gauss2_mean.a*(50:200).^curve_power_gauss2_mean.b,50:200,'--','Color',rgb('gray'),'Linewidth',1.5)
plot(curve_exp_gauss2_mean.a*exp(curve_exp_gauss2_mean.b*(200:2000)),200:2000,'k','Linewidth',2)
plot(curve_power_gauss2_mean.a*(200:2000).^curve_power_gauss2_mean.b,200:2000,'k--','Linewidth',2)
ylabel('depth (m)')
axis ij
ylabel ('Depth (m)')
xlabel('max b_b_l (m^-^1)')
title('2nd-order gaussian')
sgtitle('Mean of all pulses 2015-2019')
 %% Stats table format 
PulseYear = string(yrstr)';
 
for j = 1:length(PulseYear)
    curve_exp_movmean_includenan_a_tbl(j) = curve_exp_movmean_includenan{j}.a;
    curve_exp_movmean_includenan_b_tbl(j) = curve_exp_movmean_includenan{j}.b;
    gof_exp_movmean_includenan_r2_tbl(j) = gof_exp_movmean_includenan{j}.rsquare;
    curve_power_movmean_includenan_a_tbl(j) = curve_power_movmean_includenan{j}.a;
    curve_power_movmean_includenan_b_tbl(j) = curve_power_movmean_includenan{j}.b;
    gof_power_movmean_includenan_r2_tbl(j) = gof_power_movmean_includenan{j}.rsquare;

    curve_exp_movmean_omitnan_a_tbl(j) = curve_exp_movmean_omitnan{j}.a;
    curve_exp_movmean_omitnan_b_tbl(j) = curve_exp_movmean_omitnan{j}.b;
    gof_exp_movmean_omitnan_r2_tbl(j) = gof_exp_movmean_omitnan{j}.rsquare;
    curve_power_movmean_omitnan_a_tbl(j) = curve_power_movmean_omitnan{j}.a;
    curve_power_movmean_omitnan_b_tbl(j) = curve_power_movmean_omitnan{j}.b;
    gof_power_movmean_omitnan_r2_tbl(j) = gof_power_movmean_omitnan{j}.rsquare;

    curve_exp_gaussfilter_includenan_a_tbl(j) = curve_exp_gaussfilter_includenan{j}.a;
    curve_exp_gaussfilter_includenan_b_tbl(j) = curve_exp_gaussfilter_includenan{j}.b;
    gof_exp_gaussfilter_includenan_r2_tbl(j) = gof_exp_gaussfilter_includenan{j}.rsquare;
    curve_power_gaussfilter_includenan_a_tbl(j) = curve_power_gaussfilter_includenan{j}.a;
    curve_power_gaussfilter_includenan_b_tbl(j) = curve_power_gaussfilter_includenan{j}.b;
    gof_power_gaussfilter_includenan_r2_tbl(j) = gof_power_gaussfilter_includenan{j}.rsquare;

    curve_exp_gaussfilter_omitnan_a_tbl(j) = curve_exp_gaussfilter_omitnan{j}.a;
    curve_exp_gaussfilter_omitnan_b_tbl(j) = curve_exp_gaussfilter_omitnan{j}.b;
    gof_exp_gaussfilter_omitnan_r2_tbl(j) = gof_exp_gaussfilter_omitnan{j}.rsquare;
    curve_power_gaussfilter_omitnan_a_tbl(j) = curve_power_gaussfilter_omitnan{j}.a;
    curve_power_gaussfilter_omitnan_b_tbl(j) = curve_power_gaussfilter_omitnan{j}.b;
    gof_power_gaussfilter_omitnan_r2_tbl(j) = gof_power_gaussfilter_omitnan{j}.rsquare;

    curve_exp_gauss1_a_tbl(j) = curve_exp_gauss1{j}.a;
    curve_exp_gauss1_b_tbl(j) = curve_exp_gauss1{j}.b;
    gof_exp_gauss1_r2_tbl(j) = gof_exp_gauss1{j}.rsquare;
    curve_power_gauss1_a_tbl(j) = curve_power_gauss1{j}.a;
    curve_power_gauss1_b_tbl(j) = curve_power_gauss1{j}.b;
    gof_power_gauss1_r2_tbl(j) = gof_power_gauss1{j}.rsquare;

    curve_exp_gauss2_a_tbl(j) = curve_exp_gauss2{j}.a;
    curve_exp_gauss2_b_tbl(j) = curve_exp_gauss2{j}.b;
    gof_exp_gauss2_r2_tbl(j) = gof_exp_gauss2{j}.rsquare;
    curve_power_gauss2_a_tbl(j) = curve_power_gauss2{j}.a;
    curve_power_gauss2_b_tbl(j) = curve_power_gauss2{j}.b;
    gof_power_gauss2_r2_tbl(j) = gof_power_gauss2{j}.rsquare;
end

Part_Atten = table;
Part_Atten.PulseYear = [PulseYear; "2015-2019"];
Part_Atten.curve_exp_movmean_includenan_a = [curve_exp_movmean_includenan_a_tbl'; curve_exp_movmean_includenan_mean.a];
Part_Atten.curve_exp_movmean_includenan_b = [curve_exp_movmean_includenan_b_tbl'; curve_exp_movmean_includenan_mean.b];
Part_Atten.gof_exp_movmean_includenan_r2 = [gof_exp_movmean_includenan_r2_tbl'; gof_exp_movmean_includenan_mean.rsquare];
Part_Atten.curve_power_movmean_includenan_a = [curve_power_movmean_includenan_a_tbl'; curve_power_movmean_includenan_mean.a];
Part_Atten.curve_power_movmean_includenan_b = [curve_power_movmean_includenan_b_tbl'; curve_power_movmean_includenan_mean.b];
Part_Atten.gof_power_movmean_includenan_r2 = [gof_power_movmean_includenan_r2_tbl'; gof_power_movmean_includenan_mean.rsquare];

Part_Atten.curve_exp_movmean_omitnan_a = [curve_exp_movmean_omitnan_a_tbl'; curve_exp_movmean_omitnan_mean.a];
Part_Atten.curve_exp_movmean_omitnan_b = [curve_exp_movmean_omitnan_b_tbl'; curve_exp_movmean_omitnan_mean.b];
Part_Atten.gof_exp_movmean_omitnan_r2 = [gof_exp_movmean_omitnan_r2_tbl'; gof_exp_movmean_omitnan_mean.rsquare];
Part_Atten.curve_power_movmean_omitnan_a = [curve_power_movmean_omitnan_a_tbl'; curve_power_movmean_omitnan_mean.a];
Part_Atten.curve_power_movmean_omitnan_b = [curve_power_movmean_omitnan_b_tbl'; curve_power_movmean_omitnan_mean.b];
Part_Atten.gof_power_movmean_omitnan_r2 = [gof_power_movmean_omitnan_r2_tbl'; gof_power_movmean_omitnan_mean.rsquare];

Part_Atten.curve_exp_gaussfilter_includenan_a = [curve_exp_gaussfilter_includenan_a_tbl'; curve_exp_gaussfilter_includenan_mean.a];
Part_Atten.curve_exp_gaussfilter_includenan_b = [curve_exp_gaussfilter_includenan_b_tbl'; curve_exp_gaussfilter_includenan_mean.b];
Part_Atten.gof_exp_gaussfilter_includenan_r2 = [gof_exp_gaussfilter_includenan_r2_tbl'; gof_exp_gaussfilter_includenan_mean.rsquare];
Part_Atten.curve_power_gaussfilter_includenan_a = [curve_power_gaussfilter_includenan_a_tbl'; curve_power_gaussfilter_includenan_mean.a];
Part_Atten.curve_power_gaussfilter_includenan_b = [curve_power_gaussfilter_includenan_b_tbl'; curve_power_gaussfilter_includenan_mean.b];
Part_Atten.gof_power_gaussfilter_includenan_r2 = [gof_power_gaussfilter_includenan_r2_tbl'; gof_power_gaussfilter_includenan_mean.rsquare];

Part_Atten.curve_exp_gaussfilter_omitnan_a = [curve_exp_gaussfilter_omitnan_a_tbl'; curve_exp_gaussfilter_omitnan_mean.a];
Part_Atten.curve_exp_gaussfilter_omitnan_b = [curve_exp_gaussfilter_omitnan_b_tbl'; curve_exp_gaussfilter_omitnan_mean.b];
Part_Atten.gof_exp_gaussfilter_omitnan_r2 = [gof_exp_gaussfilter_omitnan_r2_tbl'; gof_exp_gaussfilter_omitnan_mean.rsquare];
Part_Atten.curve_power_gaussfilter_omitnan_a = [curve_power_gaussfilter_omitnan_a_tbl'; curve_power_gaussfilter_omitnan_mean.a];
Part_Atten.curve_power_gaussfilter_omitnan_b = [curve_power_gaussfilter_omitnan_b_tbl'; curve_power_gaussfilter_omitnan_mean.b];
Part_Atten.gof_power_gaussfilter_omitnan_r2 = [gof_power_gaussfilter_omitnan_r2_tbl'; gof_power_gaussfilter_omitnan_mean.rsquare];

Part_Atten.curve_exp_gauss1_a = [curve_exp_gauss1_a_tbl'; curve_exp_gauss1_mean.a];
Part_Atten.curve_exp_gauss1_b = [curve_exp_gauss1_b_tbl'; curve_exp_gauss1_mean.b];
Part_Atten.gof_exp_gauss1_r2 = [gof_exp_gauss1_r2_tbl'; gof_exp_gauss1_mean.rsquare];
Part_Atten.curve_power_gauss1_a = [curve_power_gauss1_a_tbl'; curve_power_gauss1_mean.a];
Part_Atten.curve_power_gauss1_b = [curve_power_gauss1_b_tbl'; curve_power_gauss1_mean.b];
Part_Atten.gof_power_gauss1_r2 = [gof_power_gauss1_r2_tbl'; gof_power_gauss1_mean.rsquare];

Part_Atten.curve_exp_gauss1_a = [curve_exp_gauss1_a_tbl'; curve_exp_gauss1_mean.a];
Part_Atten.curve_exp_gauss1_b = [curve_exp_gauss1_b_tbl'; curve_exp_gauss1_mean.b];
Part_Atten.gof_exp_gauss1_r2 = [gof_exp_gauss1_r2_tbl'; gof_exp_gauss1_mean.rsquare];
Part_Atten.curve_power_gauss1_a = [curve_power_gauss1_a_tbl'; curve_power_gauss1_mean.a];
Part_Atten.curve_power_gauss1_b = [curve_power_gauss1_b_tbl'; curve_power_gauss1_mean.b];
Part_Atten.gof_power_gauss1_r2 = [gof_power_gauss1_r2_tbl'; gof_power_gauss1_mean.rsquare];

Part_Atten.curve_exp_gauss2_a = [curve_exp_gauss2_a_tbl'; curve_exp_gauss2_mean.a];
Part_Atten.curve_exp_gauss2_b = [curve_exp_gauss2_b_tbl'; curve_exp_gauss2_mean.b];
Part_Atten.gof_exp_gauss2_r2 = [gof_exp_gauss2_r2_tbl'; gof_exp_gauss2_mean.rsquare];
Part_Atten.curve_power_gauss2_a = [curve_power_gauss2_a_tbl'; curve_power_gauss2_mean.a];
Part_Atten.curve_power_gauss2_b = [curve_power_gauss2_b_tbl'; curve_power_gauss2_mean.b];
Part_Atten.gof_power_gauss2_r2 = [gof_power_gauss2_r2_tbl'; gof_power_gauss2_mean.rsquare];

Part_Atten.curve_exp_gauss2_a = [curve_exp_gauss2_a_tbl'; curve_exp_gauss2_mean.a];
Part_Atten.curve_exp_gauss2_b = [curve_exp_gauss2_b_tbl'; curve_exp_gauss2_mean.b];
Part_Atten.gof_exp_gauss2_r2 = [gof_exp_gauss2_r2_tbl'; gof_exp_gauss2_mean.rsquare];
Part_Atten.curve_power_gauss2_a = [curve_power_gauss2_a_tbl'; curve_power_gauss2_mean.a];
Part_Atten.curve_power_gauss2_b = [curve_power_gauss2_b_tbl'; curve_power_gauss2_mean.b];
Part_Atten.gof_power_gauss2_r2 = [gof_power_gauss2_r2_tbl'; gof_power_gauss2_mean.rsquare];
%%
function [wfp] = load_HYPM_flord_funKF(filename_flord)
%Function to load OOI profiler data (based on load_HYPM_Yr5)
% INPUTS:
%   filename_flord: name of the netcdf file downloaded from OOI Data Portal
%   (make sure this file is in the path prior to calling function)
% OUTPUTS:
%   (all outputs are structures with multiple variables)
%   wfp - extracted data from filename_flord

%Load flord data
   wfp.time_flord = ncread(filename_flord,'time');
   wfp.lon_flord = ncread(filename_flord,'lon');
   wfp.lat_flord = ncread(filename_flord,'lat');
   wfp.temperature_flord = ncread(filename_flord,'sea_water_temperature'); %standard_name = 'sea_water_temperature' units = 'deg_C'
   wfp.pracsal_flord = ncread(filename_flord,'sea_water_practical_salinity'); %standard_name = 'sea_water_practical_salinity'
   wfp.pressure_flord = ncread(filename_flord,'int_ctd_pressure'); %standard_name = 'sea_water_pressure' units = 'dbar'
   %Fluorometer data
   wfp.backscatter = ncread(filename_flord,'optical_backscatter'); %long_name = 'Optical Backscatter' units = 'm-1'
   wfp.sw_scat_coef = ncread(filename_flord,'seawater_scattering_coefficient'); % units m-1
   wfp.total_vol_backscatter = ncread(filename_flord,'total_volume_scattering_coefficient'); % units m-1 Sr-1
   % wfp.total_vol_ = ncread(filename_flord,'seawater_scattering_coefficient'); %long_name = 'Total Scattering Coefficient of Pure Seawater' units = 'm-1'
   wfp.chla = ncread(filename_flord,'fluorometric_chlorophyll_a'); %long_name = 'Chlorophyll-a Concentration' units = 'ug L-1'
   [wfp.SA_flord, in_ocean] = gsw_SA_from_SP(wfp.pracsal_flord, wfp.pressure_flord, wfp.lon_flord, wfp.lat_flord); %absolute salinity from practical salinity - [SA, ~] = gsw_SA_from_SP(SP,p,long,lat)
   wfp.CT_flord = gsw_CT_from_t(wfp.SA_flord, wfp.temperature_flord, wfp.pressure_flord); %Conservative Temperature from in-situ temperature - CT = gsw_CT_from_t(SA,t,p)
   wfp.pdens = gsw_rho(wfp.SA_flord, wfp.CT_flord, 0); %calculate potential density at reference pressure of 0 (surface)
   %Convert to matlab time
   wfp.time_flord_mat = convertTime(wfp.time_flord);
    
 % Assign profile indices prior to gridding
    wfp.depth_flord = -gsw_z_from_p(wfp.pressure_flord,wfp.lat_flord);
    [wfp.profile_index,wfp.updown_index] = profileIndex(wfp.depth_flord);
    wfp.updown_index = wfp.updown_index';
end

function [structure] = OutlierFilterFunKF (tailvar,tailvar2, structure)
    % This function identifies and removes anomalously high backscatter spike
    % measurements by replacing all points within a profile containing an
    % anomalously high value (defined by tailvar) with NaN values.
    % 
    % INPUTS:
    % tailvar - The value which no spike should be greater than or equal to.
    % [structure] - A structure containing vectors named backscatter and
    % profile_index 
    % structure.backscatter - A vector containing unfiltered optical
    % backscatter spike data.
    % structure.profile_index - A vector containing profile index numbers.
    % 
    % OUTPUTS:
    % structure.backscatter - The backscatter vector minus all profiles
    % containing spikes larger than tailvar 
    %
    % Find and index outlier values
    structure.backscatteroriginal = structure.backscatter;
    outindex = find (structure.backscatter >= tailvar);   
    outprofileindex = unique (structure.profile_index(outindex));
    for j = 1:length(outprofileindex)
        outprofileindex2 = find (structure.profile_index == outprofileindex (j));
        structure.backscatter (outprofileindex2) = NaN;
    end

    structure.total_vol_backscatter_original = structure.total_vol_backscatter;
    total_outindex = find(structure.total_vol_backscatter >= tailvar2);
    total_outprofileindex = unique (structure.profile_index(total_outindex));
    for j = 1:length(total_outprofileindex)
        total_outprofileindex2 = find (structure.profile_index == total_outprofileindex (j));
        structure.total_vol_backscatter (total_outprofileindex2) = NaN;
    end

end

function [structure] = ProfileTimeSeriesFun (timestart,timeend,timesize,depthstart,depthend,depthsize,structure)
    % This function searches a provided structure for filtered and unfiltered 
    % backscatter data stored as a single vector and bins them based on
    % provided time and depth constraints
    %
    % INPUTS:
    % timestart - Date string for start of time window
    % timeend - Date string for end of time window
    % timesize - Size of time bins (in days)
    % depthstart - Numerical value for start of depth window
    % depthend - Numerical value for end of depth window
    % depthsize - Size of depth bins (in meters)
    % structure - The structure the backscatter data are stored in (as vectors)
    % 
    % OUTPUTS (within specified structure):
    % structure.unfiltered - a vector containing unfiltered backscatter data
    % binned based on the initial constraints
    % structure.filtered - a vector containing filtered backscatter data binned
    % based on the initial constraints
    % structure.timemesh - mesh grid based on time argument
    % structure.depthmesh - mesh grid based on depth argument
    
    % Create Time and Depth Grids
    structure.highres_time_grid = round(datenum(timestart)):timesize:round(datenum(timeend));
    structure.highres_depth_grid = depthstart:depthsize:depthend;
    structure.highres_depth_grid';
    
    % Create mesh grid
    [structure.timemesh,structure.depthmesh] = meshgrid (structure.highres_time_grid, structure.highres_depth_grid);
    meshsize = size(structure.timemesh);
    unfiltered = NaN(meshsize);
    filtered = NaN(meshsize);
    filtstd = NaN(meshsize);
    num = NaN(meshsize);
    
    % Loop the Loop
    for u = 1:meshsize(2)
        timewindowindex = find (structure.highres_time_grid(u) <= structure.time &...
            structure.time < (structure.highres_time_grid(u)+timesize));
        for v = 1:meshsize(1)
            gridindex = find (structure.highres_depth_grid (v) <=...
            structure.depth(timewindowindex) & structure.depth(timewindowindex) <...
            (structure.highres_depth_grid (v)+depthsize));
            if size (gridindex) == [0,1]
                unfiltered (v,u) = NaN;
                filtered (v,u) = NaN;
                filtstd (v,u) = NaN;
                num (v,u) = 0;
            else
            unfiltered (v,u) = nanmean (structure.backscatter(timewindowindex(gridindex)));
            filtered (v,u) = nanmean (structure.filteredspikes(timewindowindex(gridindex)));
            filtstd (v,u) = nanstd (structure.filteredspikes(timewindowindex(gridindex)));
            num (v,u) = sum (~isnan(structure.filteredspikes(timewindowindex(gridindex))));
            %outindex (v,u) = (structure.outindex(timewindowindex(gridindex)));
            end
        end
    end
    structure.unfiltered = unfiltered;
    structure.filtered = filtered;
    structure.filtstd = filtstd;
    structure.num = num;
    %structure.outliers = outindex;
    
    % Plotting
    C2 = cmocean('Algae');
    C = colormap(jet);
    C3 = colormap(gray); Cmerge = [C3(1:4:end,:); C];
    figure (77); clf;
        % subplot(311)
    h = pcolor(structure.timemesh,structure.depthmesh,structure.filtered); hold on;
    % set(h, 'EdgeColor', 'none');
    axis([round(datenum(timestart)) round(datenum(timeend)) depthstart depthend]);
    colormap(C2);  
    set(gca,'YDir','reverse'); ylabel('Depth (m)'); hcb = colorbar;
    set(hcb,'location','eastoutside')
    datetick('x',2,'keeplimits');
    title('Backscatter spikes', 'Fontsize', 15)
    
    %     subplot(312)
    % h = pcolor(structure.timemesh,structure.depthmesh,structure.filtstd); hold on;
    % set(h, 'EdgeColor', 'none');
    % axis([round(datenum(timestart)) round(datenum(timeend)) depthstart depthend]);
    % colormap(C2); set(gca,'YDir','reverse'); ylabel('Depth (m)'); hcb = colorbar;
    % set(hcb,'location','eastoutside')
    % datetick('x',2,'keeplimits');
    % title('Stdev of backscatter spikes', 'Fontsize', 15)
    % 
    %     subplot(313)
    % h = pcolor(structure.timemesh,structure.depthmesh,structure.num); hold on;
    % set(h, 'EdgeColor', 'none');
    % axis([round(datenum(timestart)) round(datenum(timeend)) depthstart depthend]);
    % colormap(C2); set(gca,'YDir','reverse'); ylabel('Depth (m)'); hcb = colorbar;
    % set(hcb,'location','eastoutside')
    % datetick('x',2,'keeplimits');
    % % caxis([0 800])
    % title('Number of data points per bin', 'Fontsize', 15)
end