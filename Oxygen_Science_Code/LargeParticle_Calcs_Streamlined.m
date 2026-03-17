% Streamlined code of particle processing, see LargeParticle_Calculations.m
% for all processing and sensitivity tests. 

addpath(genpath('G:\My Drive\Matlab_work\Github\Irminger_Jose_Backscatter'))
addpath(genpath('G:\My Drive\Matlab_work\Github\GSW-Matlab'))
addpath(genpath('G:\My Drive\Matlab_work\Github\cmocean'))
addpath(genpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\Oxygen_Science_Code'))
cd('G:\Shared drives\NSF_Irminger\Data_Files\HYPM\downloaded_Jan_2025')
load Joseoutput_KFupdate04Feb2025_50m.mat 

%% Combine all deployments 
number_backscatter_profiles = length(Yr1wfp.profile_start) + length(Yr2wfp.profile_start) + length(Yr3wfp.profile_start) + length(Yr4wfp.profile_start) + length(Yr5wfp.profile_start) + length(Yr6wfp.profile_start) + length(Yr7wfp.profile_start);

wfpmerge.time = [Yr1wfp.time; Yr2wfp.time; Yr3wfp.time; Yr4wfp.time; Yr5wfp.time; Yr6wfp.time; Yr7wfp.time; Yr8wfp.time];
wfpmerge.pressure = [Yr1wfp.pressure_flord; Yr2wfp.pressure_flord; Yr3wfp.pressure_flord; Yr4wfp.pressure_flord; Yr5wfp.pressure_flord; Yr6wfp.pressure_flord; Yr7wfp.pressure_flord; Yr8wfp.pressure_flord];
wfpmerge.depth = [Yr1wfp.depth; Yr2wfp.depth; Yr3wfp.depth; Yr4wfp.depth; Yr5wfp.depth; Yr6wfp.depth; Yr7wfp.depth; Yr8wfp.depth];
wfpmerge.backscatter = [Yr1wfp.backscatter; Yr2wfp.backscatter; Yr3wfp.backscatter; Yr4wfp.backscatter; Yr5wfp.backscatter; Yr6wfp.backscatter; Yr7wfp.backscatter; Yr8wfp.backscatter];
wfpmerge.backscatteroriginal = [Yr1wfp.backscatteroriginal; Yr2wfp.backscatteroriginal; Yr3wfp.backscatteroriginal; Yr4wfp.backscatteroriginal; Yr5wfp.backscatteroriginal; Yr6wfp.backscatteroriginal; Yr7wfp.backscatteroriginal; Yr8wfp.backscatteroriginal];
wfpmerge.sw_scat_coef = [Yr1wfp.sw_scat_coef; Yr2wfp.sw_scat_coef; Yr3wfp.sw_scat_coef; Yr4wfp.sw_scat_coef; Yr5wfp.sw_scat_coef; Yr6wfp.sw_scat_coef; Yr7wfp.sw_scat_coef; Yr8wfp.sw_scat_coef];
wfpmerge.total_vol_backscatter_original = [Yr1wfp.total_vol_backscatter_original; Yr2wfp.total_vol_backscatter_original; Yr3wfp.total_vol_backscatter_original; Yr4wfp.total_vol_backscatter_original; Yr5wfp.total_vol_backscatter_original; Yr6wfp.total_vol_backscatter_original; Yr7wfp.total_vol_backscatter_original; Yr8wfp.total_vol_backscatter_original];
wfpmerge.total_vol_backscatter = [Yr1wfp.total_vol_backscatter; Yr2wfp.total_vol_backscatter; Yr3wfp.total_vol_backscatter; Yr4wfp.total_vol_backscatter; Yr5wfp.total_vol_backscatter; Yr6wfp.total_vol_backscatter; Yr7wfp.total_vol_backscatter; Yr8wfp.total_vol_backscatter];
wfpmerge.chla = [Yr1wfp.chla; Yr2wfp.chla; Yr3wfp.chla; Yr4wfp.chla; Yr5wfp.chla; Yr6wfp.chla; Yr7wfp.chla; Yr8wfp.chla];
wfpmerge.profile_index = [Yr1wfp.profile_index; Yr1wfp.profile_index(end)+Yr2wfp.profile_index; Yr1wfp.profile_index(end)+Yr2wfp.profile_index(end)+Yr3wfp.profile_index;...
    Yr1wfp.profile_index(end)+Yr2wfp.profile_index(end)+Yr3wfp.profile_index(end)+Yr4wfp.profile_index; Yr1wfp.profile_index(end)+Yr2wfp.profile_index(end)+Yr3wfp.profile_index(end)+Yr4wfp.profile_index(end)+Yr5wfp.profile_index;...
    Yr1wfp.profile_index(end)+Yr2wfp.profile_index(end)+Yr3wfp.profile_index(end)+Yr4wfp.profile_index(end)+Yr5wfp.profile_index(end)+Yr6wfp.profile_index;...
    Yr1wfp.profile_index(end)+Yr2wfp.profile_index(end)+Yr3wfp.profile_index(end)+Yr4wfp.profile_index(end)+Yr5wfp.profile_index(end)+Yr6wfp.profile_index(end)+Yr7wfp.profile_index;...
    Yr1wfp.profile_index(end)+Yr2wfp.profile_index(end)+Yr3wfp.profile_index(end)+Yr4wfp.profile_index(end)+Yr5wfp.profile_index(end)+Yr6wfp.profile_index(end)+Yr7wfp.profile_index(end)+Yr8wfp.profile_index];
wfpmerge.updown_index = [Yr1wfp.updown_index; Yr2wfp.updown_index; Yr3wfp.updown_index; Yr4wfp.updown_index; Yr5wfp.updown_index; Yr6wfp.updown_index; Yr7wfp.updown_index; Yr8wfp.updown_index];
wfpmerge.depth_grid = 150:50:2600;
wfpmerge.profile_index2 = 1:wfpmerge.profile_index(end);
wfpmerge.filteredspikes = [Yr1wfp.filteredspikes; Yr2wfp.filteredspikes; Yr3wfp.filteredspikes; Yr4wfp.filteredspikes; Yr5wfp.filteredspikes; Yr6wfp.filteredspikes; Yr7wfp.filteredspikes; Yr8wfp.filteredspikes];
wfpmerge.binned_filteredspikes = [Yr1wfp.binned_filteredspikes; Yr2wfp.binned_filteredspikes; Yr3wfp.binned_filteredspikes; Yr4wfp.binned_filteredspikes; Yr5wfp.binned_filteredspikes; Yr6wfp.binned_filteredspikes; Yr7wfp.binned_filteredspikes; Yr8wfp.binned_filteredspikes];
wfpmerge.profile_start = [Yr1wfp.profile_start'; Yr2wfp.profile_start'; Yr3wfp.profile_start'; Yr4wfp.profile_start'; Yr5wfp.profile_start'; Yr6wfp.profile_start'; Yr7wfp.profile_start'; Yr8wfp.profile_start'];
wfpmerge.depthbins = depthbins;
wfpmerge.sinkingpulsedepths = centerofbin';

%% Need to sort the time properly for overlaping deployments

[wfpmerge.profile_start,prof_index] = sort(wfpmerge.profile_start);
wfpmerge.binned_filteredspikes = wfpmerge.binned_filteredspikes(prof_index,:,:);

%% Example of filtering for supplemental section 
pind = find(floor(Yr1wfp.profile_start) == datenum(2015,07,07));

% Yr1wfp; each deployment contains more variables used in bbl calculations
figure
set(gcf,'position',[100,100,750,650])
subplot(1,3,1)
plot(Yr1wfp.b_bp(Yr1wfp.profile_index == pind),Yr1wfp.depth(Yr1wfp.profile_index == pind),'.')
hold on
plot(Yr1wfp.minmaxfilter(Yr1wfp.profile_index == pind),Yr1wfp.depth(Yr1wfp.profile_index == pind),'k','Linewidth',1.5)
axis ij
ax = gca;
ax.FontSize = 12;
grid on
ylabel('depth (m)')
legend('b_b_p (m^-^1)','b_b_s + b_b_r (m^-^1)','Location','South')
text(-.0003,-85,'a.','FontWeight','bold','FontSize',14)

subplot(1,3,2)
plot(Yr1wfp.filteredspikes(Yr1wfp.profile_index == pind),Yr1wfp.depth(Yr1wfp.profile_index == pind),'-')
axis ij
ax = gca;
ax.FontSize = 12;
grid on
legend('b_b_l (m^-^1)','Location','South')
text(-.0003,-85,'b.','FontWeight','bold','FontSize',14)

subplot(1,3,3)
plot(Yr1wfp.binned_filteredspikes(pind,:,2),wfpmerge.sinkingpulsedepths,'s','Linewidth',1.5,'MarkerFaceColor','auto')
axis ij
ax = gca;
ax.FontSize = 12;
grid on
ylim([0 3000])
xlim([0 .00015])
text(-.000035,-85,'c.','FontWeight','bold','FontSize',14)
legend('$\overline{b_{bl}}$ (m$^{{-}1}$)','interpreter','latex','Fontsize',13,'Location','south')

%% Filter profiles by the minimum number of points in each bin
% Profiles are removed if every depth bin does not include this number of
% points
numpts_bbl = squeeze(wfpmerge.binned_filteredspikes(:,:,1));

% Identify profile numbers of bins with fewer data points than chosen tolerance
tol = 10; %was 14
tol_check = sum(numpts_bbl' > tol);

%Only keep profiles that include at least "tol" points per bin for all
%depth bins - note that this is a conservative choice and more data could
%be included by filtering each individual depth bin to check # usable data points
tol_bins = length(wfpmerge.depthbins)-1; % should work for any depth 
ind_profkeep = find(tol_check >= tol_bins);

% Statistics on number of points in remaining depth bins
numpts_filt = squeeze(wfpmerge.binned_filteredspikes(ind_profkeep,:,1));

% Create filtered dataset with only usable depth profiles 
wfpmerge.binned_filteredspikes_filt = wfpmerge.binned_filteredspikes(ind_profkeep,:,:); % without Instrument blank removed 
wfpmerge.profile_start_filt = wfpmerge.profile_start(ind_profkeep)';
%% Hilary's code for identifying time gaps in data

% Identify large temporal gaps in usable profiles
tgaps = diff(wfpmerge.profile_start_filt);
tol_tgap = prctile(tgaps, 99);
ind_biggap = find(tgaps > tol_tgap);

% Insert NaN profiles marking each time gap larger than "tol_tgap"
%A bit of a kludge, goal is to make gaps easier to identify

wfpmerge.profile_start_filt_wtgaps = wfpmerge.profile_start_filt;
wfpmerge.binned_filteredspikes_filt_wtgaps = wfpmerge.binned_filteredspikes_filt;
for i = 1:length(ind_biggap)
    wfpmerge.profile_start_filt_wtgaps = [wfpmerge.profile_start_filt_wtgaps(1:ind_biggap(i) + (i-2)) NaN NaN NaN wfpmerge.profile_start_filt_wtgaps(ind_biggap(i)+i+1:end)];
    wfpmerge.binned_filteredspikes_filt_wtgaps = cat(1, wfpmerge.binned_filteredspikes_filt_wtgaps(1:ind_biggap(i) + (i-1),:,:), NaN(1,length(wfpmerge.depthbins)-1,6), wfpmerge.binned_filteredspikes_filt_wtgaps(ind_biggap(i)+i:end,:,:));
end
%%
% Calculate moving mean over binned data
%Calculate moving mean over every "smoothnum" profiles, with NaNs omitted
smoothnum = 6; % median time between profiles is 20 hours, so this is 120 hours for median
wfpmerge.binned_filteredspikes_smoothed = movmean(wfpmerge.binned_filteredspikes_filt_wtgaps, smoothnum, 1, 'includenan','endpoints','fill');

%% For my edits Calculate maximum of sinking pulse in each year for each depth bin % HIP Code 
%calculate year and julian day for each profile
clear ind
wfpmerge.profile_start_filt_wtgaps_yr = str2num(datestr(wfpmerge.profile_start_filt_wtgaps,'yyyy'));
wfpmerge.profile_start_filt_wtgaps_JD = wfpmerge.profile_start_filt_wtgaps' - datenum(wfpmerge.profile_start_filt_wtgaps_yr,0,0);
wfpmerge.profile_start_yr = str2num(datestr(wfpmerge.profile_start_filt,'yyyy'));
wfpmerge.profile_start_JD = wfpmerge.profile_start_filt' - datenum(wfpmerge.profile_start_yr,0,0);

yrstr = [2015 2016 2016.5 2017 2018 2019 2020 2021]; %set of complete years with summers, though some (i.e. 2019 and 2020, maybe 2017, may have gaps too big to use)

jdmin = 121; jdmax = 274; %specify min and maximum julian days for bloom sinking pulse, here we use 1 May to 31 Oct
jdmid = 212; %august 1 cutoff for the 1st vs 2nd bloom in 2016

%Initialize array to hold output, decided to use gaussfilter_omitnan
% gaussfilter_omitnan == gaussfilter_includenan 
%depth bin x year x [max val, max id, max date]

sinkingpulse_max_gaussfilter_omitnan = NaN(length(wfpmerge.depthbins) - 1, 3, length(yrstr));

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

    elseif floor(yrstr(i)) == 2018 % tried multiple pulses, but decided on one
        jdmin = day(datetime(datenum('2018,06,01'),'ConvertFrom','datenum'),'dayofyear');
        jdmid = day(datetime(datenum('2018,06,26'),'ConvertFrom','datenum'),'dayofyear');
        jdmax = day(datetime(datenum('2018,08,05'),'ConvertFrom','datenum'),'dayofyear');

        ind{i} = find(wfpmerge.profile_start_yr == 2018 &...
                wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmax);
        ind_filt_wtgaps{i} = find(wfpmerge.profile_start_filt_wtgaps_yr == 2018 &...
                wfpmerge.profile_start_filt_wtgaps_JD > jdmin & wfpmerge.profile_start_filt_wtgaps_JD < jdmax);

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
        jdmin = 220; %121; jdmax = 274; %specify min and maximum julian days for bloom sinking pulse, here we use 1 May to 31 Oct
        ind{i} = find(wfpmerge.profile_start_yr == yrstr(i) &...
                wfpmerge.profile_start_JD > jdmin & wfpmerge.profile_start_JD < jdmax);
        ind_filt_wtgaps{i} = find(wfpmerge.profile_start_filt_wtgaps_yr == yrstr(i) &...
                wfpmerge.profile_start_filt_wtgaps_JD > jdmin & wfpmerge.profile_start_filt_wtgaps_JD < jdmax);
    end

    % %Maximum of the 6 profile gaussian filter omit nans 
    size_metric = 2; % 2 = mean; 3 = std; 4 = max; 5 = median; 6 = 95 percentile  
    [sinkingpulse_max_gaussfilter_omitnan(:,1,i), I] = max(smoothdata(wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{i},:,size_metric),"gaussian",6,'omitnan'));
    sinkingpulse_max_gaussfilter_omitnan(:,2,i) = ind_filt_wtgaps{i}(I); %index of max
    sinkingpulse_max_gaussfilter_omitnan(:,3,i) = wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{i}(I)); %time of max value
   
    [X2_filt_wtgaps,Y2_filt_wtgaps] = meshgrid(day(datetime(wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{i}),'ConvertFrom','datenum'),'dayofyear'),wfpmerge.sinkingpulsedepths);

    figure(100)
    subplot(2,4,i)
    C = squeeze(smoothdata(wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{i},:,size_metric),"gaussian",6,'omitnan'));
    pcolor(X2_filt_wtgaps,Y2_filt_wtgaps,C','linestyle','none')
    hold on
    clim([0.00001 0.00015])
    if i == 1
        ylabel('depth (m)')
        rectangle('Position',[180,225,5,1975],'FaceColor','white','LineStyle','none')
    end
    if i == 2 
        rectangle('Position',[178,225,191-178,1975],'FaceColor','white','LineStyle','none')
    end
    if i == 4
        rectangle('Position',[185.5,225,1.5,1975],'FaceColor','white','LineStyle','none')
        colorbar
    end
    if i == 5
        ylabel('depth (m)')
    end
    if i == 6
        rectangle('Position',[181,225,217-181,1975],'FaceColor','white','LineStyle','none')
    end
    if i == 7
        rectangle('Position',[156,225,234-156,1975],'FaceColor','white','LineStyle','none')
    end
    if i == 8
        rectangle('Position',[191,225,223-191,1975],'FaceColor','white','LineStyle','none')
    end
    axis ij
    cmocean('amp')
    % ylabel('Depth (m)')
    xlabel('day of year')
    if yrstr(i) == max(yrstr)
        colorbar
    end
    if i == 2
        title('2016: Pulse 1')
    elseif i == 3
        title('2016: Pulse 2')
    else
        title([string(yrstr(i))])
    end
    ax = gca;
    set(ax, 'TickDir', 'out')
    ax.FontSize = 12;
end
%%
for i = 1:6
   figure(101)
    j = [1:5 8]; 
    subplot(1,6,i)
    [X2_filt_wtgaps,Y2_filt_wtgaps] = meshgrid(day(datetime(wfpmerge.profile_start_filt_wtgaps(ind_filt_wtgaps{j(i)}),'ConvertFrom','datenum'),'dayofyear'),wfpmerge.sinkingpulsedepths);
    C = squeeze(smoothdata(wfpmerge.binned_filteredspikes_filt_wtgaps(ind_filt_wtgaps{j(i)},:,size_metric),"gaussian",6,'omitnan'));
    pcolor(X2_filt_wtgaps,Y2_filt_wtgaps,C','linestyle','none'); %shading interp;
    hold on
    clim([0.00001 0.00015])
    if i == 1
        ylabel('depth (m)')
    end
    if i == 4
        colorbar
    end
    axis ij
    cmocean('amp')
    plot(day(datetime(wfpmerge.profile_start_filt_wtgaps(sinkingpulse_max_gaussfilter_omitnan(:,2,j(i))),'ConvertFrom','datenum'),'dayofyear'),wfpmerge.sinkingpulsedepths,'c.','MarkerSize',10)
    xlabel('day of year')
    if yrstr(i) == max(yrstr)
        colorbar
    end
    if i == 2
        title('2016: Pulse 1')
    elseif i == 3
        title('2016: Pulse 2')
    else
        title([string(yrstr(j(i)))])
    end
    ax = gca;
    set(ax, 'TickDir', 'out')
    ax.FontSize = 12;
    
end
%%
addpath(genpath('G:\My Drive\Matlab_work\Github\cdt'))
colorblind = [0 0.61961 0.45098; 0 0.44706 0.69804; 0.33725 0.70588 0.91373; 0.94118 0.89412 0.25882;...
    0.90196 0.62353 0; 0.83529 0.36863 0; 0.8 0.47451 0.6549];
M = 25;

% Calculate sinking velocities for all pulses 
for i = 1:8
    LinearFit_gaussfilter_omitnan{i} = fitlm(wfpmerge.sinkingpulsedepths,day(datetime(sinkingpulse_max_gaussfilter_omitnan(:,3,i),'ConvertFrom','datenum'),'dayofyear'));
end

vel_pulses_good = [1:3 5];

colorblind_sink = [0 0.61961 0.45098; 0 0.44706 0.69804; 0 0.44706 0.69804; 0.94118 0.89412 0.25882];
f = figure; f.Position = [50 50 750 800];
for j = 1:length(vel_pulses_good)
    subplot(2,2,j)
    ax = gca;
    plot(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)},'Linewidth',2); hold on;
    plot(wfpmerge.sinkingpulsedepths,day(datetime(sinkingpulse_max_gaussfilter_omitnan(:,3,vel_pulses_good(j)),'ConvertFrom','datenum'),'dayofyear'), 'ok','MarkerFaceColor',colorblind_sink(j,:),'markersize', 6);
    legend off
    xlabel ('depth (m)')
    ylabel('day of year')
    SR = 1/table2array(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Coefficients(2,1)); 
    SR_high = 1/(table2array(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Coefficients(2,1) - table2array(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Coefficients(2,2))));
    SR_low = 1/(table2array(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Coefficients(2,1) + table2array(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Coefficients(2,2))));
    if yrstr(vel_pulses_good(j)) == 2016
        title(['First pulse 2016, R^2 = ' num2str(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m d^-^1'],'Interpreter','tex')
    elseif yrstr(vel_pulses_good(j)) == 2016.5
        title(['Second pulse 2016, R^2 = ' num2str(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m d^-^1'],'Interpreter','tex')
    else
        title(['Pulse ' num2str(yrstr(vel_pulses_good(j))) ', R^2 = ' num2str(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Rsquared.Ordinary,3)], ['Sinking rate = ' num2str(SR,3) ' ' '(' num2str(SR_low,3) '-' num2str(SR_high,3) ') m d^-^1'],'Interpreter','tex')
    end
    ax.FontSize = 12;
    grid on
end

%% Mean sinking rate for the four good pulses

for j = 1:length(vel_pulses_good)
    pulse{j} = day(datetime(sinkingpulse_max_gaussfilter_omitnan(:,3,vel_pulses_good(j)),'ConvertFrom','datenum'),'dayofyear') - (day(datetime(sinkingpulse_max_gaussfilter_omitnan(1,3,vel_pulses_good(j)),'ConvertFrom','datenum'),'dayofyear'));
end

pulse{1}(3)= NaN; % Removed data for point that occurs more than 20 days before pulse spike
p2 = [pulse{1} pulse{2} pulse{3} pulse{4}];
p3 = [pulse{1}; pulse{2}; pulse{3}; pulse{4}];
d3 = [wfpmerge.sinkingpulsedepths; wfpmerge.sinkingpulsedepths; wfpmerge.sinkingpulsedepths; wfpmerge.sinkingpulsedepths];

LinearFit_allpulses = fitlm(d3,p3);
LinearFit_allpulses_mean = fitlm(wfpmerge.sinkingpulsedepths,nanmean(p2,2));
LinearFit_allpulses_median = fitlm(wfpmerge.sinkingpulsedepths,nanmedian(p2,2));

SR_allpulses = 1/table2array(LinearFit_allpulses.Coefficients(2,1)); 
SR_allpulses_high = 1/(table2array(LinearFit_allpulses.Coefficients(2,1) - table2array(LinearFit_allpulses.Coefficients(2,2))));
SR_allpulses_low = 1/(table2array(LinearFit_allpulses.Coefficients(2,1) + table2array(LinearFit_allpulses.Coefficients(2,2))));

SR_allpulses_mean = 1/table2array(LinearFit_allpulses_mean.Coefficients(2,1)); 
SR_allpulses_mean_high = 1/(table2array(LinearFit_allpulses_mean.Coefficients(2,1) - table2array(LinearFit_allpulses_mean.Coefficients(2,2))));
SR_allpulses_mean_low = 1/(table2array(LinearFit_allpulses_mean.Coefficients(2,1) + table2array(LinearFit_allpulses_mean.Coefficients(2,2))));

SR_allpulses_median = 1/table2array(LinearFit_allpulses_median.Coefficients(2,1)); 
SR_allpulses_median_high = 1/(table2array(LinearFit_allpulses_median.Coefficients(2,1) - table2array(LinearFit_allpulses_median.Coefficients(2,2))));
SR_allpulses_median_low = 1/(table2array(LinearFit_allpulses_median.Coefficients(2,1) + table2array(LinearFit_allpulses_median.Coefficients(2,2))));

figure
subplot(1,2,1)
plot(wfpmerge.sinkingpulsedepths,nanmean(p2,2),'.k','MarkerSize',M)
legend('Mean of all pulses','Location','NW')
title(['Sinking rate = ' num2str(SR_allpulses_mean,3) ' ' '(' num2str(SR_allpulses_mean_low,3) '-' num2str(SR_allpulses_mean_high,3) ') m/d'])
subplot(1,2,2)
plot(wfpmerge.sinkingpulsedepths,nanmedian(p2,2),'.b','MarkerSize',M)
legend('Median of all pulses','Location','NW')
title(['Sinking rate = ' num2str(SR_allpulses_median,3) ' ' '(' num2str(SR_allpulses_median_low,3) '-' num2str(SR_allpulses_median_high,3) ') m/d'])