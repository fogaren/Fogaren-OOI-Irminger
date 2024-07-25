%% Playing with WFP data and buoyancy frequency determined MLD 

clearvars
close all
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Sept2023')
load('wfpmerge_output.mat')
wfp_prs = 150:1:2600;

% This method seems to work well when there is a strong seasonal signal in the DO record
% Aka the upper water column
% Should use the MLD product to determine the deeper layer and then use the
% whole unmixed time period to calculate rate and p value 
% Can use this seasonal signal to calculate MLDs from Oxygen and compare to
% ones calculated from WFP chla
%% Sort time to be in ascending order 

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load reindexed_resp.mat 
%% Create evenly spaced timeseries for filtered determination of D-prod
retimed.time = resp.time(1):(20/24):resp.time(end);
retimed.year = year(retimed.time);

%% To look at reinterpolation and test different smoothing for particular isobar 
z = 250; % desired isobar (db)
z_ind = find(wfp_prs == z);

data_ind = ~isnan(resp.doxy(z_ind,:)); % only find data at that isobar 
retimed_doxy = interp1(resp.time(data_ind),resp.doxy(z_ind,data_ind),retimed.time,'linear');
% yy1 = smooth(retimed.time,retimed_doxy,0.1,'loess');
yy1 = smoothdata(resp.doxy(z_ind,:),'loess','SamplePoints',resp.time);
max_ind = islocalmax(yy1);
min_ind = islocalmin(yy1);
yr = 2;
    ind_yr_retimed = find(retimed.year == yr + 2014);
    nxt_yr_retimed = find(retimed.year == yr + 2015); 

    localmax = islocalmax(yy1(ind_yr_retimed));
    [~,max_max] = max(yy1(ind_yr_retimed(localmax)));% Finds index of highest max
    max_dt = retimed.time(ind_yr_retimed(localmax));
    dt_yr_max_retimed_ind = find(retimed.time == max_dt(max_max));

    nxt_localmax = islocalmax(yy1(nxt_yr_retimed));
    [~,nxt_max_max] = max(yy1(nxt_yr_retimed(nxt_localmax)));% Finds index of highest max 
    nxt_max_dt = retimed.time(nxt_yr_retimed(nxt_localmax)); 
%         dt_nxt_max_retimed_ind = find(retimed.time == nxt_max_dt(1));
    dt_nxt_max_retimed_ind = find(retimed.time == nxt_max_dt(nxt_max_max));

    ind_bt_retimed = dt_yr_max_retimed_ind:dt_nxt_max_retimed_ind; % ind between this and next year maximums  

    localmin = islocalmin(yy1(ind_bt_retimed));     
    [~,min_min] = min(yy1(ind_bt_retimed(localmin))); % Finds lowest min 
    min_dt = retimed.time(ind_bt_retimed(localmin));
%     dt_yr_min_retimed_ind = find(retimed.time == min_dt(min_min));
    dt_yr_min_retimed_ind = find(retimed.time == min_dt(end));

    figure(2)
    clf
% subplot(2,1,1)
plot(resp.time,resp.doxy(z_ind,:),'.')
hold on
plot(retimed.time,retimed_doxy,'.')
% plot(retimed.time,yy1,'k','Linewidth',2)
plot(resp.time,yy1,'k','Linewidth',2)
plot(retimed.time(max_ind),yy1(max_ind),'og','MarkerFaceColor','g')
plot(retimed.time(min_ind),yy1(min_ind),'or','MarkerFaceColor','r')
plot(retimed.time(dt_yr_max_retimed_ind),yy1(dt_yr_max_retimed_ind),'oc','MarkerFaceColor','c')
plot(retimed.time(dt_yr_min_retimed_ind),yy1(dt_yr_min_retimed_ind),'oy','MarkerFaceColor','y')
datetick; grid on
ylabel('Oxygen (\mumol kg^-^1)')
title(['Depth = ' num2str(z)])
%%
figure
plot(resp.time,resp.doxy(z_ind,:),'.')
hold on
plot(resp.time(resp.data_in_mld(z_ind,:) == 0),resp.doxy(z_ind,resp.data_in_mld(z_ind,:) == 0),'.','Color',rgb('gray'))
plot(resp.time,yy1,'k','Linewidth',2)
datetick; grid on
ylabel('Oxygen (\mumol kg^-^1)')
title(['Depth = ' num2str(z)])
%% Interpolate each isobar onto retimed time series 
tic
retimed.doxy = [];
retimed.doxy_sm = []; % Smoothed 
for j = 1:length(wfp_prs)
    data_ind = ~isnan(resp.doxy(j,:)); % only find data at that isobar 
    retimed.doxy(j,:) = interp1(resp.time(data_ind),resp.doxy(j,data_ind),retimed.time,'linear');
    retimed.doxy_sm(j,:) = smooth(retimed.time,retimed.doxy(j,:),0.07,'loess');
end

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
save Su_resp_0.07_loess.mat retimed 
toc
load gong.mat
sound(y)
%%
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Sept2023')
load('wfpmerge_output.mat')

% if run above already 
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
% load Su_resp_0.1_loess.mat
load Su_resp_0.07_loess.mat
% load Su_resp_0.0315_loess.mat
load reindexed_resp.mat
load Dproduction.mat
% Dprod_start = Dprod_start(2:8);
% Dprod_end = Dprod_end(2:8);
MLmax_ind = Dprod_ind(1:9); % ML max index for respiration timeseries
MLmax_ind_retimed = []; % ML max index for retimed timeseries 
for j = 1:length(MLmax_ind)
    [~,MLmax_ind_retimed(j)] = min(abs(retimed.time - resp.time(MLmax_ind(j))));
%     [~,Dprod_start_retimed(j)] = min(abs(retimed.time -resp.time(Dprod_start(j))));
%     [~,Dprod_end_retimed(j)] = min(abs(retimed.time -resp.time(Dprod_end(j))));
end
wfp_prs = 150:1:2600;
addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))
%% Figure showing data in or out of ML and filtered data 

z1 = 250; % desired isobar (db)
z1_ind = find(wfp_prs == z1);
yy1max = islocalmax(retimed.doxy_sm(z1_ind,:));
yy1min = islocalmin(retimed.doxy_sm(z1_ind,:));

z2 = 500; % desired isobar (db)
z2_ind = find(wfp_prs == z2);
yy2max = islocalmax(retimed.doxy_sm(z2_ind,:));
yy2min = islocalmin(retimed.doxy_sm(z2_ind,:));

z3 = 750; % desired isobar (db)
z3_ind = find(wfp_prs == z3);
yy3max = islocalmax(retimed.doxy_sm(z3_ind,:));
yy3min = islocalmin(retimed.doxy_sm(z3_ind,:));

z4 = 1000; % desired isobar (db)
z4_ind = find(wfp_prs == z4);
yy4max = islocalmax(retimed.doxy_sm(z4_ind,:));
yy4min = islocalmin(retimed.doxy_sm(z4_ind,:));

figure
subplot(4,1,1)
plot(resp.time,resp.doxy(z1_ind,:),'.')
hold on
plot(resp.time(resp.data_in_mld(z1_ind,:) == 0),resp.doxy(z1_ind,resp.data_in_mld(z1_ind,:) == 0),'.','Color',rgb('gray'))
plot(retimed.time,retimed.doxy_sm(z1_ind,:),'k','Linewidth',2)
plot(retimed.time(yy1max),retimed.doxy_sm(z1_ind,yy1max),'og','MarkerFaceColor','g')
plot(retimed.time(yy1min),retimed.doxy_sm(z1_ind,yy1min),'or','MarkerFaceColor','r')
plot(resp.time(Dprod_start{z1}(~isnan(Dprod_start{z1}))),resp.doxy(z1_ind,Dprod_start{z1}(~isnan(Dprod_start{z1}))),'cs','MarkerSize',10,'Linewidth',1.5)
plot(resp.time(Dprod_end{z1}(~isnan(Dprod_end{z1}))),resp.doxy(z1_ind,Dprod_end{z1}(~isnan(Dprod_end{z1}))),'m^','MarkerSize',10,'Linewidth',1.5)
plot(retimed.time(MLmax_ind_retimed),retimed.doxy_sm(z1_ind,MLmax_ind_retimed),'*','Color',rgb('orange'),'MarkerSize',15,'Linewidth',1.5)
datetick; grid on
ylabel('Oxygen (\mumol kg^-^1)')
ylim([260 320])
title(['Depth = ' num2str(z1)])

subplot(4,1,2)
plot(resp.time,resp.doxy(z2_ind,:),'.')
hold on
plot(resp.time(resp.data_in_mld(z2_ind,:) == 0),resp.doxy(z2_ind,resp.data_in_mld(z2_ind,:) == 0),'.','Color',rgb('gray'))
plot(retimed.time,retimed.doxy_sm(z2_ind,:),'k','Linewidth',2)
plot(retimed.time(yy2max),retimed.doxy_sm(z2_ind,yy2max),'og','MarkerFaceColor','g')
plot(retimed.time(yy2min),retimed.doxy_sm(z2_ind,yy2min),'or','MarkerFaceColor','r')
plot(resp.time(Dprod_start{z2}(~isnan(Dprod_start{z2}))),resp.doxy(z2_ind,Dprod_start{z2}(~isnan(Dprod_start{z2}))),'cs','MarkerSize',10,'Linewidth',1.5)
plot(resp.time(Dprod_end{z2}(~isnan(Dprod_end{z2}))),resp.doxy(z2_ind,Dprod_end{z2}(~isnan(Dprod_end{z2}))),'m^','MarkerSize',10,'Linewidth',1.5)
plot(retimed.time(MLmax_ind_retimed),retimed.doxy_sm(z2_ind,MLmax_ind_retimed),'*','Color',rgb('orange'),'MarkerSize',15,'Linewidth',1.5)
datetick; grid on
ylabel('Oxygen (\mumol kg^-^1)')
ylim([260 320])
title(['Depth = ' num2str(z2)])

subplot(4,1,3)
plot(resp.time,resp.doxy(z3_ind,:),'.')
hold on
plot(resp.time(resp.data_in_mld(z3_ind,:) == 0),resp.doxy(z3_ind,resp.data_in_mld(z3_ind,:) == 0),'.','Color',rgb('gray'))
plot(retimed.time,retimed.doxy_sm(z3_ind,:),'k','Linewidth',2)
plot(retimed.time(yy3max),retimed.doxy_sm(z3_ind,yy3max),'og','MarkerFaceColor','g')
plot(retimed.time(yy3min),retimed.doxy_sm(z3_ind,yy3min),'or','MarkerFaceColor','r')
plot(resp.time(Dprod_start{z3}(~isnan(Dprod_start{z3}))),resp.doxy(z3_ind,Dprod_start{z3}(~isnan(Dprod_start{z3}))),'cs','MarkerSize',10,'Linewidth',1.5)
plot(resp.time(Dprod_end{z3}(~isnan(Dprod_end{z3}))),resp.doxy(z3_ind,Dprod_end{z3}(~isnan(Dprod_end{z3}))),'m^','MarkerSize',10,'Linewidth',1.5)
plot(retimed.time(MLmax_ind_retimed),retimed.doxy_sm(z3_ind,MLmax_ind_retimed),'*','Color',rgb('orange'),'MarkerSize',15,'Linewidth',1.5)
datetick; grid on
ylabel('Oxygen (\mumol kg^-^1)')
ylim([260 320])
title(['Depth = ' num2str(z3)])

subplot(4,1,4)
plot(resp.time,resp.doxy(z4_ind,:),'.')
hold on
plot(resp.time(resp.data_in_mld(z4_ind,:) == 0),resp.doxy(z4_ind,resp.data_in_mld(z4_ind,:) == 0),'.','Color',rgb('gray'))
plot(retimed.time,retimed.doxy_sm(z4_ind,:),'k','Linewidth',2)
plot(retimed.time(yy4max),retimed.doxy_sm(z4_ind,yy4max),'og','MarkerFaceColor','g')
plot(retimed.time(yy4min),retimed.doxy_sm(z4_ind,yy4min),'or','MarkerFaceColor','r')
plot(resp.time(Dprod_start{z4}(~isnan(Dprod_start{z4}))),resp.doxy(z4_ind,Dprod_start{z4}(~isnan(Dprod_start{z4}))),'cs','MarkerSize',10,'Linewidth',1.5)
plot(resp.time(Dprod_end{z4}(~isnan(Dprod_end{z4}))),resp.doxy(z4_ind,Dprod_end{z4}(~isnan(Dprod_end{z4}))),'m^','MarkerSize',10,'Linewidth',1.5)
plot(retimed.time(MLmax_ind_retimed),retimed.doxy_sm(z4_ind,MLmax_ind_retimed),'*','Color',rgb('orange'),'MarkerSize',15,'Linewidth',1.5)
datetick; grid on
ylabel('Oxygen (\mumol kg^-^1)')
ylim([260 320])
title(['Depth = ' num2str(z4)])
%%
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load blended_MLD_prelim_final.mat 

z1_ind = find(wfp_prs == 200);
z2_ind = find(wfp_prs == 2000);
[X,Y] = meshgrid(retimed.time(1:end-1),200:2000);
[X0,Y0] = meshgrid(retimed.time,200:2000);
[X1,Y1] = meshgrid(wggmerge_fl.time,200:2000);

fl_ind = zeros(size(wggmerge_fl.spikes(z1_ind:z2_ind,:)));
for j = 1:width(fl_ind)
    jj = find(wggmerge_fl.spikes(z1_ind:z2_ind,j) > 5e-04);
    if ~isempty(jj)
        fl_ind(jj,j) = 1;
    end
end
figure
% ax1 = subplot(2,1,1);
pcolor(X,Y,diff(retimed.doxy_sm(z1_ind:z2_ind,:),1,2))
axis ij
shading interp
hold on
scatter(X1(fl_ind == 1),Y1(fl_ind == 1),2,rgb('forest green'))
plot(wfp_dt,wfp_mld,'k')

clim([-0.2 0.2])
cmocean('balance')
c = colorbar;
datetick; axis tight
xlim([datenum(2014,08,01) datenum(2022,01,01)])
% c.title = '\mumol kg^-^1 day^-^1';

figure

pcolor(X1,Y1,wggmerge_fl.spikes(z1_ind:z2_ind,:))
axis ij
shading interp
cmocean('algae')
datetick
colorbar
%%
for yr = 2014:2021
    ind_yr = find(retimed.time>=datenum(yr,02,01) & retimed.time <= datenum(yr+1,02,01));
    ind_yr_fl = find(wggmerge_fl.time>=datenum(yr,02,01) & wggmerge_fl.time <= datenum(yr+1,02,01));
    figure(1)
%     figure(yr-2013)
    subplot(2,4,yr-2013)
    pcolor(X(:,ind_yr),Y(:,ind_yr),diff(retimed.doxy_sm(z1_ind:z2_ind,ind_yr(1):ind_yr(end)+1),1,2))
    axis ij
    shading interp
    hold on
    plot(wfp_dt,wfp_mld,'.k')
%     scatter(X1(fl_ind == 1),Y1(fl_ind == 1),2,rgb('forest green'))
    ylim([200 2000])
    xlim([datenum(yr,02,01) datenum(yr+1,02,01)])
    box on
    
    clim([-0.4 0.4])
    cmocean('balance')
    c = colorbar;
    datetick('x','m','keeplimits')
    ylabel('Depth (m)')
    title([num2str(yr) ' - ' num2str(yr+1)]);
end 
%%
for yr = 2014:2021
    figure(1)
%     figure(yr-2013)
    subplot(2,4,yr-2013)
    pcolor(X0,Y0,retimed.doxy(z1_ind:z2_ind,:))
    axis ij
    shading interp
    hold on
    plot(wfp_dt,wfp_mld,'.k')
    ylim([200 2000])
    xlim([datenum(yr,02,01) datenum(yr+1,02,01)])
    box on

    clim([250 310])
    cmocean('deep')
    c = colorbar;
    datetick('x','Keeplimits')
    % c.title = '\mumol kg^-^1 day^-^1';
end 

%% To look identifying Dproduction start and end for each year on different isobars  
z = 250; % desired isobar (db)
z_ind = find(wfp_prs == z);

data_ind = ~isnan(resp.doxy(z_ind,:)); % only find data at that isobar 
retimed_doxy = interp1(resp.time(data_ind),resp.doxy(z_ind,data_ind),retimed.time,'linear');
    yy1 = smooth(retimed.time,retimed_doxy,0.1,'loess');
max_ind = islocalmax(yy1);
min_ind = islocalmin(yy1);
% MLmax_ind_retimed = retimed(ind) of maximum winter mixing
% Dprod_start = resp(ind) of first time isobar is below the mixed layer 
% Dprod_end = resp(ind) of last time isobar is below the mixed layer 
    %Dprod_start/Dprod_end have time for each year
        % if value == NaN then isobar stays below mixed layer for more than
        % one year

% Regression start: first maximum after Dprod_end
% if Dprod_end == NaN , regression start == 

yr = 3;
    MLmax_yr_ind = MLmax_ind_retimed(yr);
    MLmax_nxt_ind = MLmax_ind_retimed(yr+1);
    ind_yr_retimed = find(retimed.year == yr + 2014);
    nxt_yr_retimed = find(retimed.year == yr + 2015); 

    localmax = islocalmax(yy1); % finds maxs for timeseries 
    localmax_dt = retimed.time(localmax);

    localmin = islocalmin(yy1); % Finds mins for timeseries
    localmin_dt = retimed.time(localmin); 

    [a,b] = min(abs(localmax_dt - retimed.time(MLmax_ind_retimed(yr))));

%     [~,max_max] = max(yy1(ind_yr_retimed(localmax)));% Finds index of highest max
%     max_dt = retimed.time(ind_yr_retimed(localmax));
%     dt_yr_max_retimed_ind = find(retimed.time == max_dt(max_max));
% 
%     nxt_localmax = islocalmax(yy1(nxt_yr_retimed));
%     [~,nxt_max_max] = max(yy1(nxt_yr_retimed(nxt_localmax)));% Finds index of highest max 
%     nxt_max_dt = retimed.time(nxt_yr_retimed(nxt_localmax)); 
% %         dt_nxt_max_retimed_ind = find(retimed.time == nxt_max_dt(1));
%     dt_nxt_max_retimed_ind = find(retimed.time == nxt_max_dt(nxt_max_max));
% 
%     ind_bt_retimed = dt_yr_max_retimed_ind:dt_nxt_max_retimed_ind; % ind between this and next year maximums  
% 
%     localmin = islocalmin(yy1(ind_bt_retimed));     
%     [~,min_min] = min(yy1(ind_bt_retimed(localmin))); % Finds lowest min 
%       min_dt = retimed.time(ind_bt_retimed(localmin));
%        % Finds min closest to deepest MLD that year  
%   
% %     dt_yr_min_retimed_ind = find(retimed.time == min_dt(min_min));
%     dt_yr_min_retimed_ind = find(retimed.time == min_dt(end)); % last 


    figure(2)
    clf
% subplot(2,1,1)
plot(resp.time,resp.doxy(z_ind,:),'.')
hold on
% plot(retimed.time,retimed_doxy,'.')
plot(retimed.time,yy1,'k','Linewidth',2)
plot(retimed.time(max_ind),yy1(max_ind),'og','MarkerFaceColor','g')
plot(retimed.time(min_ind),yy1(min_ind),'or','MarkerFaceColor','r')
plot(resp.time(Dprod_start{z}(~isnan(Dprod_start{z}))),resp.doxy(z,Dprod_start{z}(~isnan(Dprod_start{z}))),'cs','MarkerSize',15,'Linewidth',1.5)
plot(resp.time(Dprod_end{z}(~isnan(Dprod_end{z}))),resp.doxy(z,Dprod_end{z}(~isnan(Dprod_end{z}))),'k^','MarkerSize',15,'Linewidth',1.5)
% plot(retimed.time(dt_yr_max_retimed_ind),yy1(dt_yr_max_retimed_ind),'oc','MarkerFaceColor','c')
% plot(retimed.time(dt_yr_min_retimed_ind),yy1(dt_yr_min_retimed_ind),'oy','MarkerFaceColor','y')
plot(retimed.time(MLmax_ind_retimed),retimed.doxy_sm(z_ind,MLmax_ind_retimed),'om','MarkerSize',15,'Linewidth',1.5)
datetick; grid on
ylabel('Oxygen (\mumol kg^-^1)')
title(['Depth = ' num2str(z)])
%%

% Create empty output variables 
DOresp_rate_umolkg_day =[];
b_umolkg = [];
p_value = [];
R2 = [];
Dprod_days = []; 
Dprod_retimed_days= [];
DOresp_season_umolkg = []; % rate (slope) *resp_days 
DOresp_season_retimed_umolkg = []; % Using length of smoothed timeseries
Dprod_start =[]; % index of regression start with retimed time series 
Dprod_end = []; 
        
%% This seems to work well for Years 1 - 5
tic
figs = 0; 
for yr = 1:9 % Deployment year 
    % Find D-production season in retimed data 
    ind_yr_retimed = find(retimed.year == yr + 2014); 
    if yr == 7
        nxt_yr_retimed = ind_yr_retimed;
    else
        nxt_yr_retimed = find(retimed.year == yr + 2015); 
    end

    for z = 200:1200% Depth to start at 

        z_ind = find(wfp_prs == z); % Finds the index of that depth

            localmax = islocalmax(retimed.doxy_sm(z_ind,ind_yr_retimed));
            [~,max_max] = max(retimed.doxy_sm(z_ind,ind_yr_retimed(localmax)));% Finds index of highest max
            max_dt = retimed.time(ind_yr_retimed(localmax));
%             dt_yr_max_retimed_ind = find(retimed.time == max_dt(max_max));
            dt_yr_max_retimed_ind = find(retimed.time == max_dt(1));
        
            nxt_localmax = islocalmax(retimed.doxy_sm(z_ind,nxt_yr_retimed));
            [~,nxt_max_max] = max(retimed.doxy_sm(z_ind,nxt_yr_retimed(nxt_localmax)));% Finds index of highest max 
            nxt_max_dt = retimed.time(nxt_yr_retimed(nxt_localmax)); 
        %         dt_nxt_max_retimed_ind = find(retimed.time == nxt_max_dt(1));
            dt_nxt_max_retimed_ind = find(retimed.time == nxt_max_dt(nxt_max_max));
        
            ind_bt_retimed = dt_yr_max_retimed_ind:dt_nxt_max_retimed_ind; % ind between this and next year maximums  
        
            localmin = islocalmin(retimed.doxy_sm(z_ind,ind_bt_retimed));     
%             [~,min_min] = min(retimed.doxy_sm(z_ind,ind_bt_retimed(localmin))); % Finds lowest min 
            min_dt = retimed.time(ind_bt_retimed(localmin));
%             dt_yr_min_retimed_ind = find(retimed.time == min_dt(min_min));
            dt_yr_min_retimed_ind = find(retimed.time == min_dt(end)); % Finds last min before highest max 

%                 % For retimed data, find find max of current year and next year 
%         
%         localmax = islocalmax(retimed.doxy_sm(z_ind,:));
%         nxt_localmax = islocalmax(retimed.doxy_sm(z_ind,:));
%         ind_bt_retimed = ind_yr_retimed(1):nxt_yr_retimed(1); % ind between this and next year maximums 
% 
%         localmin = islocalmin(retimed.doxy_sm(z_ind,ind_bt_retimed)); 
% 
%         max_dt = retimed.time(ind_yr_retimed(localmax));
%         nxt_max_dt = retimed.time(nxt_yr_retimed(nxt_localmax)); 
%         min_dt = retimed.time(ind_bt_retimed(localmin));
% 
%         dt_yr_max_retimed_ind = find(retimed.time == max_dt(1));
%         dt_yr_min_retimed_ind = find(retimed.time == min_dt(end));

        % For retimed data, find find max of current year and next year 
        
% % %         localmax = islocalmax(retimed.doxy_sm(z_ind,ind_yr_retimed));
% % %         max_max = find(max(retimed.doxy_sm(ind_yr_retimed(localmax))));% Finds index of highest max
% % %         max_dt = retimed.time(ind_yr_retimed(localmax));
% % %         dt_yr_max_retimed_ind = find(retimed.time == max_dt(1));
% % % 
% % %         nxt_localmax = islocalmax(retimed.doxy_sm(z_ind,nxt_yr_retimed));
% % %         nxt_max_max = find(max(retimed.doxy_sm(nxt_yr_retimed(nxt_localmax))));% Finds index of highest max 
% % %         nxt_max_dt = retimed.time(nxt_yr_retimed(nxt_localmax)); 
% % % %         dt_nxt_max_retimed_ind = find(retimed.time == nxt_max_dt(1));
% % %         dt_nxt_max_retimed_ind = find(retimed.time == nxt_max_dt(nxt_max_max));
% % %         
% % %         if yr == 7 
% % %             ind_bt_retimed = dt_yr_max_retimed_ind:length(retimed.time);
% % %             dt_yr_min_retimed_ind = length(retimed.time);
% % %         else
% % %             ind_bt_retimed = dt_yr_max_retimed_ind:dt_nxt_max_retimed_ind; % ind between this and next year maximums  
% % %             localmin = islocalmin(retimed.doxy_sm(z_ind,ind_bt_retimed)); 
% % %             min_dt = retimed.time(ind_bt_retimed(localmin));
% % %             dt_yr_min_retimed_ind = find(retimed.time == min_dt(end));
% % %         end


%         % For retimed data, find find max of current year and next year 
%         [~,yr_max] = max(retimed.doxy_sm(z_ind,ind_yr_retimed));
%         dt_yr_max_retimed = retimed.time(ind_yr_retimed(yr_max));
%         dt_yr_max_retimed_ind = find(retimed.time == dt_yr_max_retimed);
% 
%         [~,nxt_yr_max] = max(retimed.doxy_sm(z_ind,nxt_yr_retimed));
%         
%         % For retimed data, find min between max of current year and next
%         % year 
%         [~,yr_min] = min(retimed.doxy_sm(z_ind,ind_yr_retimed(yr_max):nxt_yr_retimed(nxt_yr_max)));
%         dt_dum = retimed.time(ind_yr_retimed(yr_max):nxt_yr_retimed(nxt_yr_max));
%         dt_yr_min_retimed = dt_dum(yr_min);
%         dt_yr_min_retimed_ind = find(retimed.time == dt_yr_min_retimed);
        
        % Convert from datetime to number of days of D-prod
        dt_days_retimed = retimed.time(dt_yr_max_retimed_ind:dt_yr_min_retimed_ind) - retimed.time(dt_yr_max_retimed_ind);


        % Find all these retimed times in the original timeseries for regression with original data only        
        [~,dt_yr_max_ind] = min(abs(wggmerge.time - retimed.time(dt_yr_max_retimed_ind)));
        [~,dt_yr_min_ind] = min(abs(wggmerge.time - retimed.time(dt_yr_min_retimed_ind)));
        dt_days = wggmerge.time(dt_yr_max_ind:dt_yr_min_ind) - wggmerge.time(dt_yr_max_ind);
    
        mdl = fitlm(dt_days,wggmerge.doxy(z_ind,dt_yr_max_ind:dt_yr_min_ind));
        
        % Stores them by actual depth 
        DOresp_rate_umolkg_day{yr}(z) = mdl.Coefficients.Estimate(2);
        b_umolkg{yr}(z) = mdl.Coefficients.Estimate(1);
        p_value{yr}(z) = mdl.Coefficients.pValue(2);
        R2{yr}(z) = mdl.Rsquared.Ordinary;
        Dprod_days{yr}(z) = max(dt_days); 
        Dprod_retimed_days{yr}(z) = max(dt_days_retimed);
        DOresp_season_umolkg{yr}(z) = mdl.Coefficients.Estimate(2)*max(dt_days); % rate (slope) *resp_days 
        DOresp_season_retimed_umolkg{yr}(z) = mdl.Coefficients.Estimate(2)*max(dt_days_retimed); % Using length of smoothed timeseries
        Dprod_start{yr}(z) = dt_yr_max_retimed_ind; % index for retimed series 
        Dprod_end{yr}(z) = dt_yr_min_retimed_ind; 
        if figs == 1

            figure(10)
            clf
            plot(wggmerge.time,wggmerge.doxy(z_ind,:),'.')
            hold on
            plot(retimed.time,retimed.doxy_sm(z_ind,:),'k','Linewidth',1.5)
            plot(retimed.time(dt_yr_max_retimed_ind),retimed.doxy_sm(z_ind,dt_yr_max_retimed_ind),'go','MarkerFaceColor','g')
            plot(retimed.time(dt_yr_min_retimed_ind),retimed.doxy_sm(z_ind,dt_yr_min_retimed_ind),'ro','MarkerFaceColor','r')
            plot(wggmerge.time(dt_yr_max_ind),wggmerge.doxy(z_ind,dt_yr_max_ind),'co','MarkerFaceColor','c')
            plot(wggmerge.time(dt_yr_min_ind),wggmerge.doxy(z_ind,dt_yr_min_ind),'mo','MarkerFaceColor','m')            
            datetick
            grid on
            title(num2str(z))
        
            figure(20)
            clf
            plot(dt_days,wggmerge.doxy(z_ind,dt_yr_max_ind:dt_yr_min_ind),'ok')
            title(['R2 = ' num2str(R2{yr}(z)) ' ' 'pvalue = ' num2str(p_value{yr}(z))])
            pause
        end

    end 
end
toc    

%%
z = 1200;
close all
z1 = 250; z1_ind = find(wfp_prs == z1);% Desired isobars in depth 
z2 = 500; z2_ind = find(wfp_prs == z2);
z3 = 750; z3_ind = find(wfp_prs == z3);
z4 = 1000; z4_ind = find(wfp_prs == z4); 
for yr = 1:5
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
    if yr == 1
        plot(wggmerge.time,wggmerge.doxy(z1_ind,:),'.')
        hold on
        plot(wggmerge.time,DO_not_inML(z1_ind,:),'.','Color',yellow)
        plot(retimed.time,retimed.doxy_sm(z1_ind,:),'k','Linewidth',1.5)
        plot(retimed.time(Dprod_start{yr}(z1)),retimed.doxy_sm(z1_ind,Dprod_start{yr}(z1)),'go','MarkerFaceColor','g')
        plot(retimed.time(Dprod_end{yr}(z1)),retimed.doxy_sm(z1_ind,Dprod_end{yr}(z1)),'ro','MarkerFaceColor','r')
        datetick
        ylabel('DO (umol kg^-^1)')

    else
        plot(retimed.time(Dprod_start{yr}(z1)),retimed.doxy_sm(z1_ind,Dprod_start{yr}(z1)),'go','MarkerFaceColor','g')
        plot(retimed.time(Dprod_end{yr}(z1)),retimed.doxy_sm(z1_ind,Dprod_end{yr}(z1)),'ro','MarkerFaceColor','r')
        datetick
        legend(['Depth = ' num2str(z1)],'Location','SW')
    end

    subplot(4,4,[6 8])
    if yr == 1
        plot(wggmerge.time,wggmerge.doxy(z2_ind,:),'.')
        hold on
        plot(wggmerge.time,DO_not_inML(z2_ind,:),'.','Color',yellow)
        plot(retimed.time,retimed.doxy_sm(z2_ind,:),'k','Linewidth',1.5)
        plot(retimed.time(Dprod_start{yr}(z2)),retimed.doxy_sm(z2_ind,Dprod_start{yr}(z2)),'go','MarkerFaceColor','g')
        plot(retimed.time(Dprod_end{yr}(z2)),retimed.doxy_sm(z2_ind,Dprod_end{yr}(z2)),'ro','MarkerFaceColor','r')
        datetick
        ylabel('DO (umol kg^-^1)')

    else
        plot(retimed.time(Dprod_start{yr}(z2)),retimed.doxy_sm(z2_ind,Dprod_start{yr}(z2)),'go','MarkerFaceColor','g')
        plot(retimed.time(Dprod_end{yr}(z2)),retimed.doxy_sm(z2_ind,Dprod_end{yr}(z2)),'ro','MarkerFaceColor','r')
        datetick
        legend(['Depth = ' num2str(z2)],'Location','SW')
    end

    subplot(4,4,[10 12])
    if yr == 1
        plot(wggmerge.time,wggmerge.doxy(z3_ind,:),'.')
        hold on
        plot(wggmerge.time,DO_not_inML(z3_ind,:),'.','Color',yellow)
        plot(retimed.time,retimed.doxy_sm(z3_ind,:),'k','Linewidth',1.5)
        plot(retimed.time(Dprod_start{yr}(z3)),retimed.doxy_sm(z3_ind,Dprod_start{yr}(z3)),'go','MarkerFaceColor','g')
        plot(retimed.time(Dprod_end{yr}(z3)),retimed.doxy_sm(z3_ind,Dprod_end{yr}(z3)),'ro','MarkerFaceColor','r')
        datetick
        ylabel('DO (umol kg^-^1)')
    else
        plot(retimed.time(Dprod_start{yr}(z3)),retimed.doxy_sm(z3_ind,Dprod_start{yr}(z3)),'go','MarkerFaceColor','g')
        plot(retimed.time(Dprod_end{yr}(z3)),retimed.doxy_sm(z3_ind,Dprod_end{yr}(z3)),'ro','MarkerFaceColor','r')
        datetick
        legend(['Depth = ' num2str(z3)],'Location','SW')
    end

    subplot(4,4,[14 16])
    if yr == 1
        plot(wggmerge.time,wggmerge.doxy(z4_ind,:),'.')
        hold on
        plot(wggmerge.time,DO_not_inML(z4_ind,:),'.','Color',yellow)
        plot(retimed.time,retimed.doxy_sm(z4_ind,:),'k','Linewidth',1.5)
        plot(retimed.time(Dprod_start{yr}(z4)),retimed.doxy_sm(z4_ind,Dprod_start{yr}(z4)),'go','MarkerFaceColor','g')
        plot(retimed.time(Dprod_end{yr}(z4)),retimed.doxy_sm(z4_ind,Dprod_end{yr}(z4)),'ro','MarkerFaceColor','r')
        datetick
        ylabel('DO (umol kg^-^1)')
    else
        plot(retimed.time(Dprod_start{yr}(z4)),retimed.doxy_sm(z4_ind,Dprod_start{yr}(z4)),'go','MarkerFaceColor','g')
        plot(retimed.time(Dprod_end{yr}(z4)),retimed.doxy_sm(z4_ind,Dprod_end{yr}(z4)),'ro','MarkerFaceColor','r')
        datetick
        legend(['Depth = ' num2str(z4)],'Location','SW')
    end

end
sgtitle('rloess 0.08')
%%
close all
for yr = 1:7
    figure(1)
    subplot(1,2,1)
    plot(DOresp_rate_umolkg_day{yr},1:max(z),'.')
    hold on
%     p = find(p_value{yr} >= 0.05);
%     plot(DOresp_rate_umolkg_day{yr}(p),p,'.')
    axis ij
    ylabel('Pressure (db)')
    title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
    
    subplot(1,2,2)
    plot(Dprod_days{yr},1:max(z),'Linewidth',1.5)
    hold on
%     plot(Dprod_retimed_days{yr},1:max(z))
    axis ij
    ylabel('Pressure (db)')
    title('Length of D_p_r_o_d (days)')
%     sgtitle(['Year = ' num2str(yr)])
end
%%
% Create empty output variables 
out.DOresp_rate_umolkg_day = DOresp_rate_umolkg_day;
out.b_umolkg = b_umolkg;
out.p_value = p_value;
out.R2 = R2;
out.Dprod_days = Dprod_days; 
out.Dprod_retimed_days = Dprod_retimed_days;
out.DOresp_season_umolkg = DOresp_season_umolkg; % rate (slope) *resp_days 
out.DOresp_season_retimed_umolkg = DOresp_season_retimed_umolkg; % Using length of smoothed timeseries
out.retimed.time = retimed.time;
out.retimed.doxy_sm = retimed.doxy_sm;
out.Dprod_start = Dprod_start;
out.Dprod_end = Dprod_end; 
out.filter_type = 'loess';
out.filter_span = 0.08;
