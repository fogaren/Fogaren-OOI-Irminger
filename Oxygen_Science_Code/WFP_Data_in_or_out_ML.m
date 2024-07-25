clearvars 
close all
% cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Sept2023')
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Jan2024')
load('wfpmerge_output.mat')
wfp_prs = 150:1:2600;

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load blended_MLD_prelim_final.mat
run('GeneralSettings.m')
%% Sort time to be in ascending order 

[time,IND] = sort(wggmerge.time);
doxy = wggmerge.doxy(:,IND);
prho = wggmerge.pdens(:,IND);
temp = wggmerge.temp(:,IND);

resp.time = time;
resp.doxy = doxy; 
resp.prho = prho; 
resp.temp = temp; 
clear time doxy IND
%% Interpolate known MLDs onto every WFP timestep and find maximum MLD for each year 

% Sort the wggmerge_fl timeseries and Remove the NaN mld
% [dt0,IND] = sort(wggmerge_fl.time);
% wfp_mld0 = wfp_mld(IND);

dt0 = wfp_dt;
wfp_mld0 = wfp_mld;

dt0(isnan(wfp_mld)) = [];
dt0_dt = datetime(dt0,'ConvertFrom','datenum');
wfp_mld0(isnan(wfp_mld)) = [];

% Find large gaps
figure
plot(dt0(1:end-1),diff(dt0))
datetick
title('# of days between chl-a found MLD on WFP')
ylabel('Days')

ind0 = islocalmax(wfp_mld0,'MinSeparation',days(180),'SamplePoints',dt0_dt);
ind = find(ind0 == 1);

% Find max of MLD index in respiration timeseries 
MLmax_ind = []; MLmax_dt = [];
for j = 1:length(ind)
    [MLmax_dt(j),MLmax_ind(j)] = min(abs(resp.time - dt0(ind(j))));
end
Dprod_ind = [1 MLmax_ind length(resp.time)]; 

figure
plot(wfp_dt,wfp_mld,'.')
hold on
plot(dt0,wfp_mld0,'.k')
plot(dt0(ind),wfp_mld0(ind),'m*','MarkerSize',10)
axis ij
datetick; grid on
ylabel('Mixed Layer Depths (db)')
title('Maximum Annual MLDs')
%% Find start and end of wfp mld each year 
wfp_dt_end = find(diff(dt0) > 150); % Find end of MLD on WFP each year 
wfp_dt_start = wfp_dt_end +1; % Find start of MLD for following year 
wfp_dt_start = [1; wfp_dt_start]; % For first point 
wfp_dt_end = [wfp_dt_end; length(dt0)]; % For last point 

% Find closest timestamp for chl and DO data because of time difference in wggmerge and wggmerge_fl for year 8 
for j = 1:length(wfp_dt_end)
    [~,ind_start(j)] = min(abs(resp.time - dt0(wfp_dt_start(j))));
    [~,ind_end(j)] = min(abs(resp.time - dt0(wfp_dt_end(j))));
end


%% Interpolate checked mld outputs onto each profile of wfp timeseries

vq = interp1(dt0,wfp_mld0,resp.time,'linear','extrap');

figure % check interpolation
plot(resp.time,vq,'.')
hold on
plot(dt0,wfp_mld0,'.')
axis ij
datetick; grid on
plot(dt0(wfp_dt_start),wfp_mld0(wfp_dt_start),'ro')
plot(resp.time(ind_start),vq(ind_start),'m*')
plot(dt0(wfp_dt_end),wfp_mld0(wfp_dt_end),'ok')
plot(resp.time(ind_end),vq(ind_end),'c*')

%% Overwrite time periods with no MLD from wfp CHl with NaN

for j = 1:length(ind_end)-1 
    vq(ind_end(j):ind_start(j+1)) = NaN;
end

vq(1:ind_start(1)) = NaN;
vq(ind_end(end):length(vq)) = NaN; 

%% Find the depth of the MLD in the WFP index
vq = round(vq); % interpolation results in non interger MLDs 

data_in_mld = zeros(size(resp.doxy));
% zeros for data not in the mixed layer
% ones for data point that is in the mixed layer 

for j = 1:length(resp.time)
    if ~isnan(vq(j))
        [~,b] = find(wfp_prs == vq(j));
        data_in_mld(1:b,j) = 1; 
        clear b
    end
end

%% Create DO variables with data in and below the ML
resp.DO_in_mld = resp.doxy;
resp.DO_in_mld(data_in_mld == 0) = NaN; % overwrites data not in ML with NaN
resp.DO_out_mld = resp.doxy;
resp.DO_out_mld(data_in_mld == 1) = NaN; % overwrites data in ML with NaN 
resp.data_in_mld = data_in_mld;
resp.year = year(resp.time);
resp.time_dt = datetime(resp.time,'ConvertFrom','datenum');


%% Test method before applying to every isobar 
% The last time depth is in the ML in winter to first time depth is in the
% ML the following winter
z = 200; % User desired depth 
z_ind = find(wfp_prs == z); % Finds the index of that depth

% This function needed the WFP data sorted in ascending time 
ind1 = islocalmax(resp.data_in_mld(z_ind,:),'FlatSelection','all');%,'MinSeparation',days(180),'SamplePoints',resp.time_dt);
ind2 = islocalmax(resp.data_in_mld(z_ind,:),'FlatSelection','first','MinSeparation',days(180),'SamplePoints',resp.time_dt);

ind2 = find(ind2 == 1); %red % Dprod_end (when isobar is first in ML each season)
ind2 = ind2-1; % Time previous to being in Mixed Layer 
% ind2 = [ind2 length(resp.time)];
% Dprod_ind = [1 MLmax_ind length(resp.time)]; 

Dprod_end =[];
Dprod_start = [];
for j = 1:length(Dprod_ind)-1
    ind_max2max = Dprod_ind(j):Dprod_ind(j+1); % Find index for seasonal MLmax to following MLmax
    last_ML = find(ind1(ind_max2max),1,'last'); 
    

    [MLtest,ind] = max(ismember(ind_max2max,ind2)); % See if end of Dprod is between those MLmaxs 
%     [~,ind] = find(ind1(ind_max2max)); % See if end of Dprod is between those MLmaxs
  
    if MLtest == 1 % If Dprod_end is between values, find last time isobar is in ML before Dprod_end 

        [a0,~] = find(resp.time(ind_max2max(ind)) == resp.time);
        ind_range = Dprod_ind(j):a0;
        Dprod_end(j) = a0;

        
        if j == 1
            Dprod_start(j) = 1;
        end
        if j ~= 1
            b = find(ind1(ind_range),1,'last');
            if ~isempty(b)
                [a1,b1] = find(resp.time(ind_range(b)) == resp.time);
                Dprod_start(j) = a1;
            end
            if isempty(b)
                Dprod_start(j) = NaN;
            end
        end
    
    elseif MLtest == 0

        if ~isempty(last_ML)
            b = last_ML;
            [a1,b1] = find(resp.time(ind_max2max(b+1)) == resp.time); 
            Dprod_start(j) = a1;
        end

        if isempty(last_ML)
%             Dprod_start(j) = Dprod_ind(j);
            Dprod_start(j) = NaN;
        end

        Dprod_end(j) = NaN;

    end

    if j == 9
        Dprod_end(j) = length(resp.time);
    end

        clear last_ML ind_max2max MLtest ind ind_range
end

figure
plot(resp.time,resp.data_in_mld(z_ind,:))
datetick
grid on
hold on
plot(resp.time(ind1),resp.data_in_mld(z_ind,ind1),'go','MarkerFaceColor','g')
plot(resp.time(ind2),resp.data_in_mld(z_ind,ind2),'ro','MarkerFaceColor','r')
plot(resp.time(Dprod_ind),resp.data_in_mld(z_ind,Dprod_ind),'ok')
plot(resp.time(Dprod_end(~isnan(Dprod_end))),resp.data_in_mld(z_ind,Dprod_end(~isnan(Dprod_end))),'ys','MarkerSize',10)
plot(resp.time(Dprod_start(~isnan(Dprod_start))),resp.data_in_mld(z_ind,Dprod_start(~isnan(Dprod_start))),'co','MarkerFaceColor','c')
ylim([-2 3])

% Show in or out of MLD on isobar

figure
plot(resp.time,resp.doxy(z_ind,:),'.')
hold on
plot(resp.time,resp.DO_out_mld(z_ind,:),'.','Color',yellow)
yy1 = smooth(resp.time,resp.doxy(z_ind,:),0.1,'loess');
plot(resp.time,yy1,'k','Linewidth',1.5)
plot(resp.time(Dprod_end(~isnan(Dprod_end))),resp.doxy(z_ind,Dprod_end(~isnan(Dprod_end))),'ro')%,'MarkerFaceColor','r')
plot(resp.time(Dprod_start(~isnan(Dprod_start))),resp.doxy(z_ind,Dprod_start(~isnan(Dprod_start))),'go')%,'MarkerFaceColor','g')
datetick
grid on

%%
Dprod_start = [];
Dprod_end = [];
%% Calculate Dprod start and end for each year at each isobar
% The last time depth is in the ML in winter to first time depth is in the
% ML the following winter
for z = 175:2000 % User desired depth 
    z_ind = find(wfp_prs == z); % Finds the index of that depth
    
    % This function needed the WFP data sorted in ascending time 
    ind1 = islocalmax(resp.data_in_mld(z_ind,:),'FlatSelection','all');%,'MinSeparation',days(180),'SamplePoints',resp.time_dt);
    ind2 = islocalmax(resp.data_in_mld(z_ind,:),'FlatSelection','first','MinSeparation',days(180),'SamplePoints',resp.time_dt);
    
    ind2 = find(ind2 == 1); %red % Dprod_end (when isobar is first in ML each season)
    ind2 = ind2-1; % Time previous to being in Mixed Layer 
 
    Dprod_end_temp = []; Dprod_start_temp =[]; 
    for j = 1:length(Dprod_ind)-1
        ind_max2max = Dprod_ind(j):Dprod_ind(j+1); % Find index for seasonal MLmax to following MLmax
        last_ML = find(ind1(ind_max2max),1,'last');         
    
        [MLtest,ind] = max(ismember(ind_max2max,ind2)); % See if end of Dprod is between those MLmaxs 
      
        if MLtest == 1 % If Dprod_end is between values, find last time isobar is in ML before Dprod_end 
    
            [a0,~] = find(resp.time(ind_max2max(ind)) == resp.time);
            ind_range = Dprod_ind(j):a0;
            Dprod_end_temp(j) = a0;
  
            
            if j == 1
                Dprod_start_temp(j) = 1;
            end
            if j ~= 1
                b = find(ind1(ind_range),1,'last');
                if ~isempty(b)
                    [a1,b1] = find(resp.time(ind_range(b)) == resp.time);
                    Dprod_start_temp(j) = a1;
                end
                if isempty(b)
                    Dprod_start_temp(j) = NaN;
                end
            end
        
        elseif MLtest == 0
    
            if ~isempty(last_ML)
                b = last_ML;
                [a1,b1] = find(resp.time(ind_max2max(b+1)) == resp.time); 
                Dprod_start_temp(j) = a1;
            end
    
            if isempty(last_ML)
    %             Dprod_start(j) = Dprod_ind(j);
                Dprod_start_temp(j) = NaN;
            end
    
            Dprod_end_temp(j) = NaN;
    
        end
    
        if j == 9
            Dprod_end_temp(j) = length(resp.time);
        end
            clear last_ML ind_max2max MLtest ind ind_range
    end
    Dprod_end{z} = Dprod_end_temp;
    Dprod_start{z} = Dprod_start_temp; 
end
%%
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
save Dproduction2.mat Dprod_ind Dprod_start Dprod_end resp
    %%
    z = 200;
    z_ind = find(wfp_prs == z);
    
    figure
    plot(resp.time,resp.data_in_mld(z_ind,:))
    datetick
    grid on
    hold on
        plot(resp.time(ind1),resp.data_in_mld(z_ind,ind1),'go','MarkerFaceColor','g')
        plot(resp.time(ind2),resp.data_in_mld(z_ind,ind2),'ro','MarkerFaceColor','r')
        plot(resp.time(ind3),resp.data_in_mld(z_ind,ind3),'co','MarkerFaceColor','c')
%     plot(resp.time(Dprod_end(z)),resp.data_in_mld(z_ind,Dprod_end(z)),'ro','MarkerFaceColor','r')
%     plot(resp.time(Dprod_start(z)),resp.data_in_mld(z_ind,Dprod_start(z)),'go','MarkerFaceColor','g')
    ylim([-2 3])
    clear a1 ind1 ind2

%%

DOresp_rate_umolkg_day =[];
b_umolkg = [];
p_value = [];
R2 = [];
Dprod_days = []; 
DOresp_season_umolkg = []; % rate (slope) *resp_days 

%%
figs =1;
for yr = 2;%1:length(Dprod_ind)-1

    for z = 200:5:1500 % Depth to start at 

        z_ind = find(wfp_prs == z); % Finds the index of that depth
        
        Dprod = Dprod_start{z}(yr):Dprod_end{z}(yr); % Dprod season for isobar

        dt_days = resp.time(Dprod) - resp.time(Dprod(1));
    
        mdl = fitlm(dt_days,resp.doxy(z_ind,Dprod));
        
        if figs == 1

            figure(1)
%             plot(resp.time,resp.doxy(z_ind,:),'.')
%             hold on
            plot(dt_days,resp.doxy(z_ind,Dprod),'ok')
            datetick
            grid on
            pause
        end

        
        % Stores them by actual depth 
        DOresp_rate_umolkg_day{yr}(z) = mdl.Coefficients.Estimate(2);
        b_umolkg{yr}(z) = mdl.Coefficients.Estimate(1);
        p_value{yr}(z) = mdl.Coefficients.pValue(2);
        R2{yr}(z) = mdl.Rsquared.Ordinary;
        Dprod_days{yr}(z) = max(dt_days); 
        DOresp_season_umolkg{yr}(z) = mdl.Coefficients.Estimate(2)*max(dt_days); % rate (slope) *resp_days 
%         Dprod_start{yr}(z) = dt_yr_max_retimed_ind; % index for retimed series 
%         Dprod_end{yr}(z) = dt_yr_min_retimed_ind; 
    end 
end
%%

% Want to find last localmax each year 
% last local max == start of Dprod at t = 1
% first local max == end of Dprod  at t = 2 (because of when timeseries
% started)
figs = 0; 
for yr = 1 % Deployment year 
    ind_yr = find(resp.year == yr + 2014);
    nxt_yr = find(resp.year == yr + 2015);


    for z = 200:1600 % Depth to start at 

        z_ind = find(wfp_prs == z); % Finds the index of that depth
        [~,ind_below_mld] = find(data_in_mld(z_ind,ind_yr)==0);
        [~,nxt_below_mld] = find(data_in_mld(z_ind,nxt_yr)==0);
        Dprod = ind_yr(ind_below_mld(1)):nxt_yr(nxt_below_mld(1));

        if figs == 1

            figure
            plot(resp.time,resp.doxy(z_ind,:),'.')
            hold on
            plot(resp.time(Dprod),resp.doxy(z_ind,Dprod),'.')
            datetick
            grid on
            pause
        end

        
        dt_days = resp.time(Dprod) - resp.time(Dprod(1));
    
        mdl = fitlm(dt_days,resp.doxy(z_ind,Dprod));
        
        
        % Stores them by actual depth 
        DOresp_rate_umolkg_day{yr}(z) = mdl.Coefficients.Estimate(2);
        b_umolkg{yr}(z) = mdl.Coefficients.Estimate(1);
        p_value{yr}(z) = mdl.Coefficients.pValue(2);
        R2{yr}(z) = mdl.Rsquared.Ordinary;
        Dprod_days{yr}(z) = max(dt_days); 
        DOresp_season_umolkg{yr}(z) = mdl.Coefficients.Estimate(2)*max(dt_days); % rate (slope) *resp_days 
%         Dprod_start{yr}(z) = dt_yr_max_retimed_ind; % index for retimed series 
%         Dprod_end{yr}(z) = dt_yr_min_retimed_ind; 
    end 
end

%%
close all
z1 = 250; z1_ind = find(wfp_prs == z1);% Desired isobars in depth 
z2 = 500; z2_ind = find(wfp_prs == z2);
z3 = 750; z3_ind = find(wfp_prs == z3);
z4 = 1000; z4_ind = find(wfp_prs == z4); 
for yr = 2:7
    figure(1)
    subplot(4,4,[1 5])
    plot(-DOresp_rate_umolkg_day{yr},1:max(z),'.')
    hold on
%     p = find(p_value{yr} >= 0.05);
%     plot(DOresp_rate_umolkg_day{yr}(p),p,'.')
    axis ij
    ylabel('Pressure (db)')
    title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
    
    subplot(4,4,[9 13])
    plot(Dprod_days{yr},1:max(z),'Linewidth',1.5)
    hold on
%     plot(Dprod_retimed_days{yr},1:max(z))
    axis ij
    ylabel('Pressure (db)')
    title('Length of D_p_r_o_d (days)')

    subplot(4,4,[2 4])
    plot(resp.time,resp.doxy(z1_ind,:),'.')
    hold on
    plot(resp.time,resp.DO_out_mld(z1_ind,:),'.')
    datetick
    grid on
    ylabel('DO (umol kg^-^1)')

    subplot(4,4,[6 8])
    plot(resp.time,resp.doxy(z2_ind,:),'.')
    hold on
    plot(resp.time,resp.DO_out_mld(z2_ind,:),'.')
    datetick
    grid on
    ylabel('DO (umol kg^-^1)')

    subplot(4,4,[10 12])
    plot(resp.time,resp.doxy(z3_ind,:),'.')
    hold on
    plot(resp.time,resp.DO_out_mld(z3_ind,:),'.')
    datetick
    grid on
    ylabel('DO (umol kg^-^1)')

    subplot(4,4,[14 16])
    plot(resp.time,resp.doxy(z4_ind,:),'.')
    hold on
    plot(resp.time,resp.DO_out_mld(z4_ind,:),'.')
    datetick
    grid on
    ylabel('DO (umol kg^-^1)')

end
