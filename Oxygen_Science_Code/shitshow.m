tic
addpath(genpath('G:\My Drive\Matlab_work\Github\Irminger_Jose_Backscatter'))
addpath(genpath('G:\My Drive\Matlab_work\Github\GSW-Matlab'))
addpath(genpath('G:\My Drive\Matlab_work\Github\cmocean'))
cd('G:\Shared drives\NSF_Irminger\Data_Files\HYPM\downloaded_Jan_2025')

% Load OOI Global Irminger Sea profiler fluorometer data for all seven
% years
load wfpfilenames.mat; load wfpfilenames2.mat;

% Had to update this function to include the right variable names in the
% netCDF. Need to confirm that these are the files I'm supposed to be using
% 
Yr1wfp = load_HYPM_flord_funKF (wfpfilenames2 (1,:));
Yr2wfp = load_HYPM_flord_funKF (wfpfilenames2 (2,:));
Yr3wfp = load_HYPM_flord_funKF (wfpfilenames2 (3,:));
Yr4wfp = load_HYPM_flord_funKF (wfpfilenames2 (4,:));
Yr5wfp = load_HYPM_flord_funKF (wfpfilenames2 (5,:));
Yr6wfp = load_HYPM_flord_funKF (wfpfilenames2 (6,:));
Yr7wfp = load_HYPM_flord_funKF (wfpfilenames2 (7,:));
toc
%% Remove outliers
tailvarset = 0.005; tailvarset2 = 0.00062; 
[Yr1wfp] = OutlierFilterFunKF (tailvarset, tailvarset2, Yr1wfp);
[Yr2wfp] = OutlierFilterFunKF (tailvarset, tailvarset2, Yr2wfp);
[Yr3wfp] = OutlierFilterFunKF (tailvarset, tailvarset2, Yr3wfp);
[Yr4wfp] = OutlierFilterFunKF (tailvarset, tailvarset2, Yr4wfp);
[Yr5wfp] = OutlierFilterFunKF (tailvarset, tailvarset2, Yr5wfp);
[Yr6wfp] = OutlierFilterFunKF (tailvarset, tailvarset2, Yr6wfp);
[Yr7wfp] = OutlierFilterFunKF (tailvarset, tailvarset2, Yr7wfp);
%% Plot wfp data
% Merges all seven years of the time series into one continuous data structure

wfpmerge.time = [Yr1wfp.time_flord_mat; Yr2wfp.time_flord_mat; Yr3wfp.time_flord_mat; Yr4wfp.time_flord_mat; Yr5wfp.time_flord_mat; Yr6wfp.time_flord_mat; Yr7wfp.time_flord_mat];
wfpmerge.depth = [Yr1wfp.depth_flord; Yr2wfp.depth_flord; Yr3wfp.depth_flord; Yr4wfp.depth_flord; Yr5wfp.depth_flord; Yr6wfp.depth_flord; Yr7wfp.depth_flord];
wfpmerge.SP = [Yr1wfp.pracsal_flord; Yr2wfp.pracsal_flord; Yr3wfp.pracsal_flord; Yr4wfp.pracsal_flord; Yr5wfp.pracsal_flord; Yr6wfp.pracsal_flord; Yr7wfp.pracsal_flord];
wfpmerge.temp = [Yr1wfp.temperature_flord; Yr2wfp.temperature_flord; Yr3wfp.temperature_flord; Yr4wfp.temperature_flord; Yr5wfp.temperature_flord; Yr6wfp.temperature_flord; Yr7wfp.temperature_flord];
wfpmerge.pdens = [Yr1wfp.pdens; Yr2wfp.pdens; Yr3wfp.pdens; Yr4wfp.pdens; Yr5wfp.pdens; Yr6wfp.pdens; Yr7wfp.pdens];
wfpmerge.backscatter = [Yr1wfp.backscatter; Yr2wfp.backscatter; Yr3wfp.backscatter; Yr4wfp.backscatter; Yr5wfp.backscatter; Yr6wfp.backscatter; Yr7wfp.backscatter];
wfpmerge.backscatteroriginal = [Yr1wfp.backscatteroriginal; Yr2wfp.backscatteroriginal; Yr3wfp.backscatteroriginal; Yr4wfp.backscatteroriginal; Yr5wfp.backscatteroriginal; Yr6wfp.backscatteroriginal; Yr7wfp.backscatteroriginal];
wfpmerge.sw_scat_coef = [Yr1wfp.sw_scat_coef; Yr2wfp.sw_scat_coef; Yr3wfp.sw_scat_coef; Yr4wfp.sw_scat_coef; Yr5wfp.sw_scat_coef; Yr6wfp.sw_scat_coef; Yr7wfp.sw_scat_coef];
wfpmerge.total_vol_backscatter_original = [Yr1wfp.total_vol_backscatter_original; Yr2wfp.total_vol_backscatter_original; Yr3wfp.total_vol_backscatter_original; Yr4wfp.total_vol_backscatter_original; Yr5wfp.total_vol_backscatter_original; Yr6wfp.total_vol_backscatter_original; Yr7wfp.total_vol_backscatter_original];
wfpmerge.total_vol_backscatter = [Yr1wfp.total_vol_backscatter; Yr2wfp.total_vol_backscatter; Yr3wfp.total_vol_backscatter; Yr4wfp.total_vol_backscatter; Yr5wfp.total_vol_backscatter; Yr6wfp.total_vol_backscatter; Yr7wfp.total_vol_backscatter];
wfpmerge.b_bp_OOI = wfpmerge.backscatter - wfpmerge.sw_scat_coef/2; % 
wfpmerge.chla = [Yr1wfp.chla; Yr2wfp.chla; Yr3wfp.chla; Yr4wfp.chla; Yr5wfp.chla; Yr6wfp.chla; Yr7wfp.chla];
wfpmerge.profile_index = [Yr1wfp.profile_index; Yr1wfp.profile_index(end)+Yr2wfp.profile_index; Yr1wfp.profile_index(end)+Yr2wfp.profile_index(end)+Yr3wfp.profile_index; Yr1wfp.profile_index(end)+Yr2wfp.profile_index(end)+Yr3wfp.profile_index(end)+Yr4wfp.profile_index; Yr1wfp.profile_index(end)+Yr2wfp.profile_index(end)+Yr3wfp.profile_index(end)+Yr4wfp.profile_index(end)+Yr5wfp.profile_index; Yr1wfp.profile_index(end)+Yr2wfp.profile_index(end)+Yr3wfp.profile_index(end)+Yr4wfp.profile_index(end)+Yr5wfp.profile_index(end)+Yr6wfp.profile_index; Yr1wfp.profile_index(end)+Yr2wfp.profile_index(end)+Yr3wfp.profile_index(end)+Yr4wfp.profile_index(end)+Yr5wfp.profile_index(end)+Yr6wfp.profile_index(end)+Yr7wfp.profile_index];
wfpmerge.updown_index = [Yr1wfp.updown_index; Yr2wfp.updown_index; Yr3wfp.updown_index; Yr4wfp.updown_index; Yr5wfp.updown_index; Yr6wfp.updown_index; Yr7wfp.updown_index];
wfpmerge.depth_grid = [150:50:2600];
wfpmerge.profile_index2 = [1:wfpmerge.profile_index(end)];

% Beta_Sw not provided by OOI, so calculated according to Zhang et al 2009
% and the reported chi and theta in Seabird Application 114 for the FLORD
for j = 1:length(wfpmerge.temp)
    [wfpmerge.betasw(j),beta90sw(j),wfpmerge.bsw(j)]= betasw_ZHH2009(700,wfpmerge.temp(j),142,wfpmerge.SP(j),0.039);
end
wfpmerge.betasw = wfpmerge.betasw';
wfpmerge.bsw = wfpmerge.bsw';
wfpmerge.betap = wfpmerge.total_vol_backscatter - wfpmerge.betasw;
wfpmerge.b_bp = 2*pi*1.097*(wfpmerge.betap);

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



%%
[B,I] = sort(wfpmerge.binned_filteredspikes_filt_wtgaps); 

figure
scatter(wfpmerge.time(I),wfpmerge.depth(I),[],B,'filled')
axis ij
axis([wfpmerge.time(1) wfpmerge.time(end) 0 2000])
colorbar
caxis([0.05 6])

%%

[B2,I2] = sort(wfpmerge.filteredspikes); 

figure
scatter(wfpmerge.time(I2),wfpmerge.depth(I2),[],B2,'filled')
axis ij
axis([wfpmerge.time(1) wfpmerge.time(end) 0 2000])
colorbar
% clim([0 .004])
cmocean('amp')
% colormap(sky)
datetick('keeplimits')
box on
%%
[B2,I2] = sort(wfpmerge.filteredspikes); 

figure
scatter(wfpmerge.time(I2),wfpmerge.depth(I2),[],B2,'filled')
axis ij
axis([wfpmerge.time(1) wfpmerge.time(end) 0 2000])
colorbar
% clim([0 .004])
cmocean('amp')
% colormap(sky)
datetick('keeplimits')
box on
%% Too look at different calculated components of the optical signal 

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
[wfpmerge] = ProfileTimeSeriesFun (datestr(Yr1wfp.time_flord_mat(1)),datestr(Yr7wfp.time_flord_mat(end)),1,0,max(Yr1wfp.depth_flord),50,wfpmerge);

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
maxdepth = 2000;
depthint = 50;
wfpmerge.depthbins = [mindepth: depthint: maxdepth];

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
            find(wfpmerge.depth >= wfpmerge.depthbins(j) & wfpmerge.depth < wfpmerge.depthbins(j) + depthint));
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
% save Joseoutput_KFupdate8Jan2025.mat
%%
cd('G:\Shared drives\NSF_Irminger\Data_Files\HYPM\downloaded_Jan_2025')
load Joseoutput_KFupdate8Jan2025.mat
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
tol = 14; %was 14
tol_check = sum(numpts' > tol);

%Only keep profiles that include at least "tol" points per bin for all
%depth bins - note that this is a conservative choice and more data could
%be included by filtering each individual depth bin to check # usable data points
tol_bins = 36;
ind_profkeep = find(tol_check >= tol_bins);

%Statistics on number of points in remaining depth bins
numpts_filt = squeeze(wfpmerge.binned_backscatter(ind_profkeep,:,1));

%% Create filtered dataset with only usable depth profiles
wfpmerge.binned_backscatter_filt = wfpmerge.binned_backscatter(ind_profkeep,:,:);
wfpmerge.binned_b_bp_filt = wfpmerge.binned_b_bp(ind_profkeep,:,:);
wfpmerge.binned_filteredspikes_filt = wfpmerge.binned_filteredspikes(ind_profkeep,:,:);
wfpmerge.profile_start_filt = wfpmerge.profile_start(ind_profkeep);

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
wfpmerge.sinkingpulsedepths = [225:50:1975]';

ind = find(floor(wfpmerge.profile_start) == datenum(2015,07,07));
figure
plot(wfpmerge.filteredspikes(wfpmerge.profile_index == ind),wfpmerge.depth(wfpmerge.profile_index == ind))
hold on
axis ij
plot(squeeze(wfpmerge.binned_filteredspikes(ind,:,2)),wfpmerge.sinkingpulsedepths,'ok') % mean
plot(squeeze(wfpmerge.binned_filteredspikes(ind,:,6)),wfpmerge.sinkingpulsedepths,'*') % 95%
plot(squeeze(wfpmerge.binned_filteredspikes_smoothed(ind,:,2)),wfpmerge.sinkingpulsedepths,'or') % mean
plot(squeeze(wfpmerge.binned_filteredspikes_smoothed(ind,:,6)),wfpmerge.sinkingpulsedepths,'*') % 95%


%% Calculate maximum of sinking pulse in each year for each depth bin % HIP Code 
%calculate year and julian day for each profile
wfpmerge.profile_start_filt_wtgaps_yr = str2num(datestr(wfpmerge.profile_start_filt_wtgaps,'yyyy'));
wfpmerge.profile_start_filt_wtgaps_JD = wfpmerge.profile_start_filt_wtgaps' - datenum(wfpmerge.profile_start_filt_wtgaps_yr,0,0);

yrstr = [2015 2016 2016.5 2017 2018 2019 2020]; %set of complete years with summers, though some (i.e. 2019 and 2020, maybe 2017, may have gaps too big to use)
jdmin = 121; jdmax = 304; %specify min and maximum julian days for bloom sinking pulse, here we use 1 May to 31 Oct
jdmid = 212; %august 1 cutoff for the 1st vs 2nd bloom in 2016

%Initialize array to hold output
%depth bin x year x [max val, max id, max date]
sinkingpulse_Btot = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
sinkingpulse_b_bp = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
sinkingpulse = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
for i = 1:length(yrstr)
    if floor(yrstr(i)) == 2016
        if yrstr(i) == 2016 %first pulse in 2016
            ind = find(wfpmerge.profile_start_filt_wtgaps_yr == 2016 &...
                wfpmerge.profile_start_filt_wtgaps_JD > jdmin & wfpmerge.profile_start_filt_wtgaps_JD < jdmid);
        else %second pulse in 2016
            ind = find(wfpmerge.profile_start_filt_wtgaps_yr == 2016 &...
                wfpmerge.profile_start_filt_wtgaps_JD > jdmid & wfpmerge.profile_start_filt_wtgaps_JD < jdmax);
        end
    else
    %find index for all profiles in year within julian date range
    ind = find(wfpmerge.profile_start_filt_wtgaps_yr == yrstr(i) &...
        wfpmerge.profile_start_filt_wtgaps_JD > jdmin & wfpmerge.profile_start_filt_wtgaps_JD < jdmax);
    end
    %Alternative approach to consider is calculating Gaussian fit, uncertainty stats
    [sinkingpulse_Btot(:,1,i), I] = max(wfpmerge.binned_backscatter_smoothed(ind,:,6),[],1); %max value of smoothed 95th percentile
    sinkingpulse_Btot(:,2,i) = ind(I); %index of max
    sinkingpulse_Btot(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind(I)); %time of max value
    [sinkingpulse_b_bp(:,1,i), I] = max(wfpmerge.binned_b_bp_smoothed(ind,:,6),[],1); %max value of smoothed 95th percentile
    sinkingpulse_b_bp(:,2,i) = ind(I); %index of max
    sinkingpulse_b_bp(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind(I)); %time of max value
    [sinkingpulse(:,1,i), I] = max(wfpmerge.binned_filteredspikes_smoothed(ind,:,6),[],1); %max value of smoothed 95th percentile
    sinkingpulse(:,2,i) = ind(I); %index of max
    sinkingpulse(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind(I)); %time of max value
end
%% For my edits Calculate maximum of sinking pulse in each year for each depth bin % HIP Code 
%calculate year and julian day for each profile
wfpmerge.profile_start_filt_wtgaps_yr = str2num(datestr(wfpmerge.profile_start_filt_wtgaps,'yyyy'));
wfpmerge.profile_start_filt_wtgaps_JD = wfpmerge.profile_start_filt_wtgaps' - datenum(wfpmerge.profile_start_filt_wtgaps_yr,0,0);
wfpmerge.profile_start_yr = year(wfpmerge.profile_start);
wfpmerge.profile_start_JD = day(datetime(wfpmerge.profile_start,'ConvertFrom','datenum'),'dayofyear');


yrstr = [2015 2016 2016.5 2017 2018 2019 2020]; %set of complete years with summers, though some (i.e. 2019 and 2020, maybe 2017, may have gaps too big to use)
jdmin = 121; jdmax = 274; %specify min and maximum julian days for bloom sinking pulse, here we use 1 May to 31 Oct
jdmid = 212; %august 1 cutoff for the 1st vs 2nd bloom in 2016

%% Plots of each pulse 
for i = 1:length(yrstr)
    if floor(yrstr(i)) == 2015
        jdmin = day(datetime(datenum('2015,06,01'),'ConvertFrom','datenum'),'dayofyear');
        jdmax = day(datetime(datenum('2015,08,10'),'ConvertFrom','datenum'),'dayofyear');

        ind = find(wfpmerge.profile_start_yr == 2015 &...
                wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmax);

    % elseif floor(yrstr(i)) == 2016
    %     jdmin = 121; jdmax = 274; %specify min and maximum julian days for bloom sinking pulse, here we use 1 May to 31 Oct
    %     jdmid = 212; %august 1 cutoff for the 1st vs 2nd bloom in 2016
    % 
    %     if yrstr(i) == 2016 %first pulse in 2016
    %         ind = find(wfpmerge.profile_start_yr == 2016 &...
    %             wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmid);
    %     else %second pulse in 2016
    %         ind = find(wfpmerge.profile_start_yr == 2016 &...
    %             wfpmerge.profile_start_JD > jdmid & wfpmerge.profile_start_JD < jdmax);
    %     end

    elseif floor(yrstr(i)) == 2017
        jdmin = day(datetime(datenum('2017,06,01'),'ConvertFrom','datenum'),'dayofyear');
        jdmax = day(datetime(datenum('2017,07,12'),'ConvertFrom','datenum'),'dayofyear');

        ind = find(wfpmerge.profile_start_yr == 2017 &...
                wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmax);
    elseif floor(yrstr(i)) == 2018 % multiple pulses?
        jdmin = day(datetime(datenum('2017,06,01'),'ConvertFrom','datenum'),'dayofyear');
        jdmax = day(datetime(datenum('2017,08,10'),'ConvertFrom','datenum'),'dayofyear');
            
        ind = find(wfpmerge.profile_start_yr == 2018 &...
                wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmax);

    elseif floor(yrstr(i)) == 2019 % Too much of a data gap 
        jdmin = 121; jdmax = 304; %specify min and maximum julian days for bloom sinking pulse, here we use 1 May to 31 Oct       
        ind = find(wfpmerge.profile_start_yr == 2019 &...
                wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmax);

    elseif floor(yrstr(i)) == 2016 % Too much of a data gap 
        jdmin = 121; jdmax = 304; %specify min and maximum julian days for bloom sinking pulse, here we use 1 May to 31 Oct       
        ind = find(wfpmerge.profile_start_yr == 2016 &...
                wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmax);
    else
    %find index for all profiles in year within julian date range
    jdmin = 121; jdmax = 274; %specify min and maximum julian days for bloom sinking pulse, here we use 1 May to 31 Oct
    ind = find(wfpmerge.profile_start_yr == yrstr(i) &...
        wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmax);
    end

    figure(i)
    [X2,Y2] = meshgrid(wfpmerge.profile_start(ind),wfpmerge.sinkingpulsedepths);
    C = squeeze(wfpmerge.binned_filteredspikes(ind,:,6));
    % pcolor(X2(~isnan(C)),Y2(~isnan(C)),C(~isnan(C))')
    pcolor(X2,Y2,C','linestyle','none')
    axis ij
    datetick('x','Keeplimits')
    cmocean('amp')
    title(string(yrstr(i)))
    % 
    % %Alternative approach to consider is calculating Gaussian fit, uncertainty stats
    % [sinkingpulse_Btot(:,1,i), I] = max(wfpmerge.binned_backscatter_smoothed(ind,:,6),[],1); %max value of smoothed 95th percentile
    % sinkingpulse_Btot(:,2,i) = ind(I); %index of max
    % sinkingpulse_Btot(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind(I)); %time of max value
    % [sinkingpulse_b_bp(:,1,i), I] = max(wfpmerge.binned_b_bp_smoothed(ind,:,6),[],1); %max value of smoothed 95th percentile
    % sinkingpulse_b_bp(:,2,i) = ind(I); %index of max
    % sinkingpulse_b_bp(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind(I)); %time of max value
    % [sinkingpulse(:,1,i), I] = max(wfpmerge.binned_filteredspikes_smoothed(ind,:,6),[],1); %max value of smoothed 95th percentile
    % sinkingpulse(:,2,i) = ind(I); %index of max
    % sinkingpulse(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind(I)); %time of max value

end
%%
%Initialize array to hold output
%depth bin x year x [max val, max id, max date]
sinkingpulse_Btot = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
sinkingpulse_b_bp = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
sinkingpulse = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));
for i = 1:length(yrstr)
    if floor(yrstr(i)) == 2016
        if yrstr(i) == 2016 %first pulse in 2016
            ind = find(wfpmerge.profile_start_filt_wtgaps_yr == 2016 &...
                wfpmerge.profile_start_filt_wtgaps_JD > jdmin & wfpmerge.profile_start_filt_wtgaps_JD < jdmid);
        else %second pulse in 2016
            ind = find(wfpmerge.profile_start_filt_wtgaps_yr == 2016 &...
                wfpmerge.profile_start_filt_wtgaps_JD > jdmid & wfpmerge.profile_start_filt_wtgaps_JD < jdmax);
        end
    else
    %find index for all profiles in year within julian date range
    ind = find(wfpmerge.profile_start_filt_wtgaps_yr == yrstr(i) &...
        wfpmerge.profile_start_filt_wtgaps_JD > jdmin & wfpmerge.profile_start_filt_wtgaps_JD < jdmax);
    end
    %Alternative approach to consider is calculating Gaussian fit, uncertainty stats
    [sinkingpulse_Btot(:,1,i), I] = max(wfpmerge.binned_backscatter_smoothed(ind,:,6),[],1); %max value of smoothed 95th percentile
    sinkingpulse_Btot(:,2,i) = ind(I); %index of max
    sinkingpulse_Btot(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind(I)); %time of max value
    [sinkingpulse_b_bp(:,1,i), I] = max(wfpmerge.binned_b_bp_smoothed(ind,:,6),[],1); %max value of smoothed 95th percentile
    sinkingpulse_b_bp(:,2,i) = ind(I); %index of max
    sinkingpulse_b_bp(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind(I)); %time of max value
    [sinkingpulse(:,1,i), I] = max(wfpmerge.binned_filteredspikes_smoothed(ind,:,6),[],1); %max value of smoothed 95th percentile
    sinkingpulse(:,2,i) = ind(I); %index of max
    sinkingpulse(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind(I)); %time of max value
end
%% Plot for selected depths
figure(1); clf
bins_to_plot = [2, 7, 14]; %can alter to switch depths to look at
L = 2; M = 4;
for i = 1:3
        subplot(3,1,i)
    plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_backscatter_filt_wtgaps(:, bins_to_plot(i), 4)), '.','markersize',M,'color',nicecolor('rmw')); hold on;
    plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_backscatter_filt_wtgaps(:, bins_to_plot(i), 6)), '.', 'markersize',M,'color',nicecolor('bcw')); hold on;
    plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_backscatter_smoothed(:, bins_to_plot(i), 4)), '-','linewidth',L-1,'color',nicecolor('rmk')); hold on;
    plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_backscatter_smoothed(:, bins_to_plot(i), 6)), '-','linewidth',L,'color',nicecolor('bcbck')); hold on;
    plot(squeeze(sinkingpulse_Btot(bins_to_plot(i),3,:)), squeeze(sinkingpulse_Btot(bins_to_plot(i),1,:)), 'ko','markersize',M*2,'markerfacecolor','y'); hold on;
    xlim([min(wfpmerge.profile_start_filt_wtgaps) - 10, max(wfpmerge.profile_start_filt_wtgaps) + 10])
    datetick('x','keeplimits')
    ylabel('Backscatter, m^{-1}')
    title(['OOI Irminger WFP, binned & filtered total optical backscatter: Depth interval from ' num2str(wfpmerge.depthbins(bins_to_plot(i))) ' to ' num2str(wfpmerge.depthbins(bins_to_plot(i)+1)) 'm']);
    legend('Profile max','Profile 95th percentile','6-profile profile max movmean',...
        '6-prof 95th percentile movmean','Annual max of 6-profile movmean of 95th percentile',...
        'Orientation','horizontal')
end

figure(2); clf
for i = 1:3
        subplot(3,1,i)
    plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_b_bp_filt_wtgaps(:, bins_to_plot(i), 4)), '.','markersize',M,'color',nicecolor('rmw')); hold on;
    plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_b_bp_filt_wtgaps(:, bins_to_plot(i), 6)), '.', 'markersize',M,'color',nicecolor('bcw')); hold on;
    plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_b_bp_smoothed(:, bins_to_plot(i), 4)), '-','linewidth',L-1,'color',nicecolor('rmk')); hold on;
    plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_b_bp_smoothed(:, bins_to_plot(i), 6)), '-','linewidth',L,'color',nicecolor('bcbck')); hold on;
    plot(squeeze(sinkingpulse_b_bp(bins_to_plot(i),3,:)), squeeze(sinkingpulse_b_bp(bins_to_plot(i),1,:)), 'ko','markersize',M*2,'markerfacecolor','y'); hold on;
    xlim([min(wfpmerge.profile_start_filt_wtgaps) - 10, max(wfpmerge.profile_start_filt_wtgaps) + 10])
    datetick('x','keeplimits')
    ylabel('Backscatter, m^{-1}')
    title(['OOI Irminger WFP, binned & filtered particle scatter : Depth interval from ' num2str(wfpmerge.depthbins(bins_to_plot(i))) ' to ' num2str(wfpmerge.depthbins(bins_to_plot(i)+1)) 'm']);
    legend('Profile max','Profile 95th percentile','6-profile profile max movmean',...
        '6-prof 95th percentile movmean','Annual max of 6-profile movmean of 95th percentile',...
        'Orientation','horizontal')
end


figure(3); clf
for i = 1:3
        subplot(3,1,i)
    %plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_filteredspikes_filt_wtgaps(:, bins_to_plot(i), 4)), '.','markersize',M,'color',nicecolor('rmw')); hold on;
    plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_filteredspikes_filt_wtgaps(:, bins_to_plot(i), 6)), '.', 'markersize',M,'color',nicecolor('bcw')); hold on;
    %plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_filteredspikes_smoothed(:, bins_to_plot(i), 4)), '-','linewidth',L-1,'color',nicecolor('rmk')); hold on;
    plot(wfpmerge.profile_start_filt_wtgaps, squeeze(wfpmerge.binned_filteredspikes_smoothed(:, bins_to_plot(i), 6)), '-','linewidth',L,'color',nicecolor('bcbck')); hold on;
    plot(squeeze(sinkingpulse(bins_to_plot(i),3,:)), squeeze(sinkingpulse(bins_to_plot(i),1,:)), 'ko','markersize',M*2,'markerfacecolor','y'); hold on;
    xlim([min(wfpmerge.profile_start_filt_wtgaps) - 10, max(wfpmerge.profile_start_filt_wtgaps) + 10])
    datetick('x','keeplimits')
    ylabel('Backscatter, m^{-1}')
    title(['OOI Irminger WFP, binned & filtered large particle spikes: Depth interval from ' num2str(wfpmerge.depthbins(bins_to_plot(i))) ' to ' num2str(wfpmerge.depthbins(bins_to_plot(i)+1)) 'm']);
    legend('Profile 95th percentile',...
        '6-prof 95th percentile movmean','Annual max of 6-profile movmean of 95th percentile',...
        'Orientation','horizontal')
end


%%
%SinkingPulseAndMartinCurveCalculationsBinnedHP 

wfpmerge.sinkingpulsedepths = [225:50:1975]';
MartinFit = fittype ('c*x.^-b');
% expFit = fittype ('a*exp(b*x)');
ymin = 200;
ymax = 2000;
M = 20;

figure(1); clf;
for i = [1,2,5]
    if i == 3
        LinearFit{i} = fitlm(sinkingpulse(1:15,3,i), wfpmerge.sinkingpulsedepths(1:15));
        MartinCurve{i} = fit (sinkingpulse(1:15,1,i), wfpmerge.sinkingpulsedepths(1:15), MartinFit);
    else
        LinearFit{i} = fitlm(sinkingpulse(:,3,i), wfpmerge.sinkingpulsedepths);
        MartinCurve{i} = fit (sinkingpulse(:,1,i), wfpmerge.sinkingpulsedepths, MartinFit);
    end


%Set up indices for plotting
if i < 3
    ind = i;
elseif i == 5
    ind = 3;
end

    subplot(3,2,2*ind-1)
plot(LinearFit{i}); hold on;
plot(squeeze(sinkingpulse(:,3,i)), wfpmerge.sinkingpulsedepths, 'k.','markersize', M);
% plot(squeeze(sinkingpulse_b_bp(:,3,i)), wfpmerge.sinkingpulsedepths, 'k.','markersize', M);
% plot(squeeze(sinkingpulse_Btot(:,3,i)), wfpmerge.sinkingpulsedepths, 'k.','markersize', M);
legend off
set (gca,'YDir','reverse')
datetick ('x','mmm-yyyy','keeplimits')
ylim ([ymin ymax])
ylabel ('Depth (m)')
xlabel('Date')
title(['Sinking rate = ' num2str(table2array(LinearFit{i}.Coefficients(2,1)),3) ' ' char(177) ' ' num2str(table2array(LinearFit{i}.Coefficients(2,2)),2) ' m/d'])

    subplot(3,2,2*ind)
plot(sinkingpulse(:,1,i), wfpmerge.sinkingpulsedepths, 'k.','markersize', M); hold on;
% plot(sinkingpulse_b_bp(:,1,i), wfpmerge.sinkingpulsedepths, 'k.','markersize', M); hold on;
% plot(sinkingpulse_Btot(:,1,i), wfpmerge.sinkingpulsedepths, 'k.','markersize', M); hold on;
plot (MartinCurve{i});
legend off
set (gca,'YDir','reverse')
ylim ([ymin ymax])
ylabel ('Depth (m)')
xlabel ('Maximum spike size (m^-^1)')
title(['Flux attenuation (b = ' num2str(MartinCurve{i}.b,3) ')'])

end

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
    %% Find and index outlier values
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
        subplot(311)
    h = pcolor(structure.timemesh,structure.depthmesh,structure.filtered); hold on;
    set(h, 'EdgeColor', 'none');
    axis([round(datenum(timestart)) round(datenum(timeend)) depthstart depthend]);
    colormap(C2); %caxis([0 7E-5]); 
    set(gca,'YDir','reverse'); ylabel('Depth (m)'); hcb = colorbar;
    set(hcb,'location','eastoutside')
    datetick('x',2,'keeplimits');
    title('Backscatter spikes', 'Fontsize', 15)
    
        subplot(312)
    h = pcolor(structure.timemesh,structure.depthmesh,structure.filtstd); hold on;
    set(h, 'EdgeColor', 'none');
    axis([round(datenum(timestart)) round(datenum(timeend)) depthstart depthend]);
    colormap(C2); set(gca,'YDir','reverse'); ylabel('Depth (m)'); hcb = colorbar;
    set(hcb,'location','eastoutside')
    datetick('x',2,'keeplimits');
    title('Stdev of backscatter spikes', 'Fontsize', 15)
    
        subplot(313)
    h = pcolor(structure.timemesh,structure.depthmesh,structure.num); hold on;
    set(h, 'EdgeColor', 'none');
    axis([round(datenum(timestart)) round(datenum(timeend)) depthstart depthend]);
    colormap(C2); set(gca,'YDir','reverse'); ylabel('Depth (m)'); hcb = colorbar;
    set(hcb,'location','eastoutside')
    datetick('x',2,'keeplimits');
    caxis([0 800])
    title('Number of data points per bin', 'Fontsize', 15)
end