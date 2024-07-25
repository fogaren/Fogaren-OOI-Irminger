%% Load workspace 
clearvars; close all
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Sept2023')
load('wfpmerge_output.mat') % Hilary's wggmerge and wggmerge_fl products 
wfp_prs = 150:1:2600; % Depths of Hilary's product 

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
% load Su_resp_0.1_loess.mat % retimed and smoothed
    % data has be reindexed to be in ascending time order
    % data has been filtered according to method in title
        % This code is run in Respiration_Su_et_al and output is saved
            % Takes ~30 min to run
load Su_resp_0.07_loess.mat 
% load Su_resp_0.0315_loess.mat

load Dproduction.mat % load start and end of D-production period on each isobar
    % Dproduction defined here is first and last data point below mixed
        % layer
    % Dprod_start/Dprod_end is indexed by isobar Dprod_start{200} = 200 m isobar 
        % Dprod_start/Dprod_end has value for each year
        % If value == NaN, the isobar do not reenter the mixed layer that
        % year 
    % Dprod_ind is the index of the maximum mixing each year
    % This file was created using WFP_Data_in_or_out_ML.m


load reindexed_resp.mat % load wgg data with mixed layer flags
    % includes data_in_mld variable indicating if oxygen data is in or
        % below the mixed layer
% noout = [];
% for j = 1:length(wfp_prs)
    noout = smoothdata(resp.doxy,2,'movmedian',days(3),'omitnan','SamplePoints',resp.time_dt);
% end
% Add toolboxes and Colors 
run('GeneralSettings.m')
addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))
%% Everything on retimed(index)
retimed.time_dt = datetime(retimed.time,'ConvertFrom','datenum');
% out_test = filloutliers(resp.doxy,'nearest','movmedian',days(3),2,'SamplePoints',resp.time_dt);
% temp_test = isoutlier(resp.temp,'movmedian',days(60),2,'SamplePoints',resp.time_dt);
% %     resp.doxy_sm = smoothdata(out_test,2,'loess',days(90),'omitnan','SamplePoints',resp.time_dt);
% 
% figure
% plot(resp.time(temp_test(800,:) == 0),resp.doxy(800,temp_test(800,:) == 0),'.')
% hold on
% yy1 = smoothdata(resp.doxy(800,temp_test(800,:)==0),'loess','omitnan','SamplePoints',resp.time(temp_test(800,:) ==0));
% plot(resp.time(temp_test(800,:) == 0),yy1,'k','Linewidth',1.5)
% %%

% Rename and reindex for different timeseries 
MLmax_ind = Dprod_ind(1:9); % ML max, resp(index) for respiration timeseries
MLmax_ind_retimed = []; % ML max, retimed(index) 
for j = 1:length(MLmax_ind)
    [~,MLmax_ind_retimed(j)] = min(abs(retimed.time - resp.time(MLmax_ind(j))));
end

Dprod_start_retimed = []; Dprod_end_retimed = []; 
for z = 200:2000
    % Find Dprod_start/end retimed(index) on resp(index)
    ind_start = Dprod_start{z};
    ind_end = Dprod_end{z};

    for j = 1:length(ind_start)
        if ~isnan(ind_start(j))
            [~,Dprod_start_retimed{z}(j)] = min(abs(retimed.time - resp.time(ind_start(j))));
        else
            Dprod_start_retimed{z}(j) = NaN; 
        end
        if ~isnan(ind_end(j))
            [~,Dprod_end_retimed{z}(j)] = min(abs(retimed.time - resp.time(ind_end(j)))); 
        else
            Dprod_end_retimed{z}(j) = NaN;
        end
    end
end

%% Figure showing data in or out of ML, smoothed data, Dprod start and end and MLmax 
% This figure is a good visual for how start and end point of linear
% regression of respiration signal is determined each year on 4 different
% isobars

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
% plot(resp.time(Dprod_start{z1}(~isnan(Dprod_start{z1}))),resp.doxy(z1_ind,Dprod_start{z1}(~isnan(Dprod_start{z1}))),'cs','MarkerSize',10,'Linewidth',1.5)
% plot(resp.time(Dprod_end{z1}(~isnan(Dprod_end{z1}))),resp.doxy(z1_ind,Dprod_end{z1}(~isnan(Dprod_end{z1}))),'m^','MarkerSize',10,'Linewidth',1.5)
plot(retimed.time(Dprod_start_retimed{z1}(~isnan(Dprod_start_retimed{z1}))),retimed.doxy_sm(z1_ind,Dprod_start_retimed{z1}(~isnan(Dprod_start_retimed{z1}))),'cs','MarkerSize',10,'Linewidth',1.5)
plot(retimed.time(Dprod_end_retimed{z1}(~isnan(Dprod_end_retimed{z1}))),retimed.doxy_sm(z1_ind,Dprod_end_retimed{z1}(~isnan(Dprod_end_retimed{z1}))),'m^','MarkerSize',10,'Linewidth',1.5)

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
plot(retimed.time(Dprod_start_retimed{z2}(~isnan(Dprod_start_retimed{z2}))),retimed.doxy_sm(z2_ind,Dprod_start_retimed{z2}(~isnan(Dprod_start_retimed{z2}))),'cs','MarkerSize',10,'Linewidth',1.5)
plot(retimed.time(Dprod_end_retimed{z2}(~isnan(Dprod_end_retimed{z2}))),retimed.doxy_sm(z2_ind,Dprod_end_retimed{z2}(~isnan(Dprod_end_retimed{z2}))),'m^','MarkerSize',10,'Linewidth',1.5)
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
plot(retimed.time(Dprod_start_retimed{z3}(~isnan(Dprod_start_retimed{z3}))),retimed.doxy_sm(z3_ind,Dprod_start_retimed{z3}(~isnan(Dprod_start_retimed{z3}))),'cs','MarkerSize',10,'Linewidth',1.5)
plot(retimed.time(Dprod_end_retimed{z3}(~isnan(Dprod_end_retimed{z3}))),retimed.doxy_sm(z3_ind,Dprod_end_retimed{z3}(~isnan(Dprod_end_retimed{z3}))),'m^','MarkerSize',10,'Linewidth',1.5)
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
plot(retimed.time(Dprod_start_retimed{z4}(~isnan(Dprod_start_retimed{z4}))),retimed.doxy_sm(z4_ind,Dprod_start_retimed{z4}(~isnan(Dprod_start_retimed{z4}))),'cs','MarkerSize',10,'Linewidth',1.5)
plot(retimed.time(Dprod_end_retimed{z4}(~isnan(Dprod_end_retimed{z4}))),retimed.doxy_sm(z4_ind,Dprod_end_retimed{z4}(~isnan(Dprod_end_retimed{z4}))),'m^','MarkerSize',10,'Linewidth',1.5)
plot(retimed.time(MLmax_ind_retimed),retimed.doxy_sm(z4_ind,MLmax_ind_retimed),'*','Color',rgb('orange'),'MarkerSize',15,'Linewidth',1.5)
datetick; grid on
ylabel('Oxygen (\mumol kg^-^1)')
ylim([260 320])
title(['Depth = ' num2str(z4)])

%% 


for z = 200:2000% Depth to start at 
    % This is first done using everything on the retimed(index) 

    z_ind = find(wfp_prs == z); % Finds the index of that depth
    localmax = islocalmax(retimed.doxy_sm(z_ind,:)); % Maxs for whole time series
    localmin = islocalmin(retimed.doxy_sm(z_ind,:)); % Mins for whole time series

    localmax_dt = retimed.time(localmax); % Finds retimed time of all maxes 
    localmin_dt = retimed.time(localmin); % Finds retimed time of all mins

    localmax_ind = find(localmax == 1);
    localmin_ind = find(localmin == 1);
    
    regress_start_retimed = [];
    regress_end_retimed = []; 
    dt_days_retimed = [];

    for yr = 1:7 % Deployment year 
        % Find retimed time for each year 

            if ~isnan(Dprod_start{z}(yr))
                regress_start_retimed(yr) = Dprod_start_retimed{z}(yr);
            elseif isnan(Dprod_start{z}(yr))
                regress_start_retimed(yr) = MLmax_ind_retimed(yr);
            end

%             if ~isnan(Dprod_end_retimed{z}(yr))             
%                 yr_end = find(localmin_ind <= Dprod_end_retimed{z}(yr),1,'last');
%                 if isempty(yr_end)
%                     regress_end_retimed(yr) = Dprod_end_retimed{z}(yr);
%                 elseif ~isempty(yr_end)
%                     regress_end_retimed(yr) = localmin_ind(yr_end);
%                 end
%             elseif isnan(Dprod_end_retimed{z}(yr))
%                 regress_end_retimed(yr) = MLmax_ind_retimed(yr+1); 
%             end
            if ~isnan(Dprod_end_retimed{z}(yr))   % To go from Dprod_start to end or max to max           
                regress_end_retimed(yr) = Dprod_end_retimed{z}(yr);
            elseif isnan(Dprod_end_retimed{z}(yr))
                regress_end_retimed(yr) = MLmax_ind_retimed(yr+1); 
            end
%                     Convert from datetime to number of days of D-prod
            Dprod_days_retimed(yr) = max(retimed.time(regress_start_retimed(yr):regress_end_retimed(yr)) - retimed.time(regress_start_retimed(yr)));
            
            % Find all these retimed times in the original timeseries for regression with original data only        
            [~,regress_start_resp(yr)] = min(abs(resp.time - retimed.time(regress_start_retimed(yr))));
            [~,regress_end_resp(yr)] = min(abs(resp.time - retimed.time(regress_end_retimed(yr))));
            Dprod_days = resp.time(regress_start_resp(yr):regress_end_resp(yr)) - resp.time(regress_start_resp(yr));
    end
    regress_retimed{z}.start = regress_start_retimed;
    regress_retimed{z}.end = regress_end_retimed;
    regress_retimed{z}.Dprod_days = Dprod_days_retimed;

    regress_resp{z}.start = regress_start_resp;
    regress_resp{z}.end = regress_end_resp;
    regress_resp{z}.Dprod_days = Dprod_days; 
    
end

%%
% Create empty output variables 
DOresp_rate_umolkg_day = [];
DOresp_rate_umolkg_day_95CI_high = [];
DOresp_rate_umolkg_day_95CI_low = []; 
b_umolkg = [];
p_value = [];
R2 = [];
Dprod_days = []; 
DOresp_season_umolkg = []; % rate (slope) *resp_days 
DOresp_season_umolkg_95CI_high = []; % rate (slope) *resp_days 
DOresp_season_umolkg_95CI_low = []; % rate (slope) *resp_days 
Dprod_prho = [];
DOresp_season_molm3 = []; 
DOresp_season_molm3_95CI_high = [];
DOresp_season_molm3_95CI_low = [];
%%
figs =0;
for yr = 1:7

    for z = 200:2000
        z_ind = find(wfp_prs == z); % Finds the index of that depth
        regress_ind = regress_resp{z}.start(yr):regress_resp{z}.end(yr); 
        dt_days = resp.time(regress_ind) - resp.time(regress_resp{z}.start(yr));

        temp_detrended = detrend(resp.temp(z_ind,regress_ind),'omitnan');
        bad_temp = isoutlier(temp_detrended,'quartiles','SamplePoints',resp.time(regress_ind));
        doxy_detrended = detrend(resp.doxy(z_ind,regress_ind),'omitnan');
        bad_doxy = isoutlier(doxy_detrended,'quartiles','SamplePoints',resp.time(regress_ind));
        if yr == 7
            mdl = fitlm(dt_days(bad_temp == 0),resp.doxy(z_ind,regress_ind(bad_temp == 0)));
        elseif yr ~=7
            mdl = fitlm(dt_days(bad_temp == 0 & bad_doxy == 0),resp.doxy(z_ind,regress_ind(bad_temp == 0 & bad_doxy == 0)));
        end

%             figure(1)
%             plot(dt_days,resp.doxy(z_ind,(regress_resp{z}.start(yr)):regress_resp{z}.end(yr)),'ok','MarkerFaceColor','k')
%             grid on
%             title(['Depth = ' num2str(z) ' Year = ' num2str(yr)])
        if figs == 1
            figure(2)
            clf
            subplot(2,1,1)
            plot(resp.time(regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),...
                resp.doxy(z_ind,regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),'ok','MarkerFaceColor','k')
            hold on
            plot(resp.time(regress_resp{z}.start(yr):regress_resp{z}.end(yr)),...
                resp.doxy(z_ind,regress_resp{z}.start(yr):regress_resp{z}.end(yr)),'ok','MarkerFaceColor','b')
            grid on
            datetick
            
            subplot(2,1,2)
            plot(wggmerge.time(regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),...
                wggmerge.temp(z_ind,regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),'ok','MarkerFaceColor','k')
            hold on
            plot(wggmerge.time(regress_resp{z}.start(yr):regress_resp{z}.end(yr)),...
                wggmerge.temp(z_ind,regress_resp{z}.start(yr):regress_resp{z}.end(yr)),'ok','MarkerFaceColor','b')
            grid on
            datetick
            sgtitle(['Depth = ' num2str(z) ' Year = ' num2str(yr)])
    
            pause 
        end

        CI = mdl.coefCI;

        % Stores them by actual depth 
        DOresp_rate_umolkg_day{yr}(z) = mdl.Coefficients.Estimate(2);
        DOresp_rate_umolkg_day_95CI_high{yr}(z) = CI(2,1);
        DOresp_rate_umolkg_day_95CI_low{yr}(z) = CI(2,2); 
        b_umolkg{yr}(z) = mdl.Coefficients.Estimate(1);
        p_value{yr}(z) = mdl.Coefficients.pValue(2);
        R2{yr}(z) = mdl.Rsquared.Ordinary;
        Dprod_days{yr}(z) = max(dt_days); 
        DOresp_season_umolkg{yr}(z) = mdl.Coefficients.Estimate(2)*max(dt_days); % rate (slope) *resp_days
        DOresp_season_umolkg_95CI_high{yr}(z) = CI(2,1)*max(dt_days); % rate (slope) *resp_days
        DOresp_season_umolkg_95CI_low{yr}(z) = CI(2,2)*max(dt_days); % rate (slope) *resp_days
        Dprod_prho{yr}(z) = nanmean(resp.prho(z_ind,regress_resp{z}.start(yr):regress_resp{z}.end(yr)));
        DOresp_season_molm3{yr}(z) = (DOresp_season_umolkg{yr}(z).*Dprod_prho{yr}(z))/(1000*1000);
        DOresp_season_molm3_95CI_high{yr}(z) = (DOresp_season_umolkg_95CI_high{yr}(z).*Dprod_prho{yr}(z))/(1000*1000);
        DOresp_season_molm3_95CI_low{yr}(z) = (DOresp_season_umolkg_95CI_low{yr}(z).*Dprod_prho{yr}(z))/(1000*1000);
    end
end

%%
mycolors = [maroon; red; yellow; green; forestgreen; blue; purple; brightpurple];
for yr = 2:7
    figure(yr)
    set(gcf,'position',[100,100,850,400])
    subplot(1,3,1)
    plot(DOresp_rate_umolkg_day{yr},1:max(z),'.','Color',mycolors(yr,:))
    hold on
    plot(DOresp_rate_umolkg_day_95CI_low{yr},1:max(z),'.','Color',mycolors(yr-1,:)) 
    plot(DOresp_rate_umolkg_day_95CI_high{yr},1:max(z),'.','Color',mycolors(yr+1,:)) 
%     p = find(p_value{yr} >= 0.05);
%     plot(DOresp_rate_umolkg_day{yr}(p),p,'.')
    axis ij
    ylabel('Pressure (db)')
    title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
    grid on
    
    subplot(1,3,2)
    plot(Dprod_days{yr},1:max(z),'.','Color',mycolors(yr,:))
    hold on
%     plot(Dprod_retimed_days{yr},1:max(z))
    axis ij
    ylabel('Pressure (db)')
    title('Length of D_p_r_o_d (days)')
    grid on

    subplot(1,3,3)
    plot(DOresp_season_molm3{yr}*-0.69,1:max(z),'.','Color',mycolors(yr,:))
    hold on
    plot(DOresp_season_molm3_95CI_low{yr}*-0.69,1:max(z),'.','Color',mycolors(yr-1,:))
    plot(DOresp_season_molm3_95CI_high{yr}*-0.69,1:max(z),'.','Color',mycolors(yr+1,:))
    axis ij
    ylabel('Pressure (db)')
    grid on
    title('Total Respired (mol C m^-^3)')
    sgtitle(['Dproduction Year ' num2str(yr)])
end
%%
for yr = 2:7
    figure(8)
    set(gcf,'position',[100,100,1200,400])
    subplot(1,6,yr-1)
    plot(DOresp_rate_umolkg_day{yr},1:max(z),'.','Color',mycolors(yr,:))
    hold on
    p = find(p_value{yr} >= 0.05);
    plot(DOresp_rate_umolkg_day{yr}(p),p,'.k')
    axis ij
    ylabel('Pressure (db)')
    xlabel(['Year: ' num2str(yr)])
    sgtitle('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
    grid on
end

for yr = 2:7
    figure(9)
    set(gcf,'position',[100,100,1200,400])
    subplot(1,6,yr-1)
    plot(Dprod_days{yr},1:max(z),'.','Color',mycolors(yr,:))
    hold on
%     plot(Dprod_retimed_days{yr},1:max(z))
    axis ij
    ylabel('Pressure (db)')
        xlabel(['Year: ' num2str(yr)])
    sgtitle('Length of D_p_r_o_d (days)')
    grid on
end

for yr = 2:7
    figure(10)
    set(gcf,'position',[100,100,1200,400])
    subplot(1,6,yr-1)
    p = find(p_value{yr} < 0.05 & DOresp_rate_umolkg_day{yr} <0);
    plot(DOresp_season_molm3{yr}*-0.69,1:max(z),'.k')
    hold on
    plot(DOresp_season_molm3{yr}(p)*-0.69,p,'.','Color',mycolors(yr,:))
    axis ij
    ylabel('Pressure (db)')
        xlabel(['Year: ' num2str(yr)])
    grid on
    sgtitle('Total Respired (mol C m^-^3)')
end
%% Integration 
DOinventory_molm2 = [];
DOinventory_molm2_95CI_high = [];
DOinventory_molm2_95CI_low = [];
for yr = 2:7

    p = find(p_value{yr} < 0.05 & DOresp_rate_umolkg_day{yr} <0);
    p_95CI_high = find(p_value{yr} < 0.05 & DOresp_rate_umolkg_day_95CI_high{yr} < 0); 
    p_95CI_low = find(p_value{yr} < 0.05 & DOresp_rate_umolkg_day_95CI_low{yr} < 0);

    DOinventory_molm2(yr) = min(cumsum(DOresp_season_molm3{yr}(p)));
    DOinventory_molm2_95CI_high(yr) = min(cumsum(DOresp_season_molm3_95CI_high{yr}(p)));
    DOinventory_molm2_95CI_low(yr) = min(cumsum(DOresp_season_molm3_95CI_low{yr}(p)));

    figure(11)
    set(gcf,'position',[100,100,500,400])
    subplot(1,6,yr-1)
    plot(cumsum(DOresp_season_molm3{yr}(p)),p)
    hold on
    plot(cumsum(DOresp_season_molm3_95CI_low{yr}(p)),p)
    plot(cumsum(DOresp_season_molm3_95CI_high{yr}(p)),p)
    axis ij
    ylabel('Pressure (db)')
    xlabel('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
%     xlim([-0.1 0.05])
    grid on
    title(['Dproduction Year ' num2str(yr)])
end
%%
% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');
Cinventory_molm2 = DOinventory_molm2(2:7)*-0.69;
Cinventory_molm2_95CI_low = DOinventory_molm2_95CI_low(2:7)*-0.69;
Cinventory_molm2_95CI_high = DOinventory_molm2_95CI_high(2:7)*-0.69;

bar(2015:2020,Cinventory_molm2)
hold on
errorbar(2015:2020,Cinventory_molm2,Cinventory_molm2_95CI_low - Cinventory_molm2,Cinventory_molm2_95CI_high - Cinventory_molm2,'ok')
% errorbar(2015:2020,Cinventory_molm2,Cinventory_molm2 - Cinventory_molm2_95CI_low,Cinventory_molm2 - Cinventory_molm2_95CI_high,'ok')

bar(2014,nanmean(Cinventory_molm2))
ylabel('ANCP mol C m^-^2 yr^-^1')
box(axes1,'on');
hold(axes1,'off');
set(axes1,'XTick',[2014 2015 2016 2017 2018 2019 2020],...
    'XTickLabel',...
    {'Average','2015','2016','2017','2018','2019','2020'});
title('ANCP using Approach 3')

%% To look at profiles 
ind = find(wggmerge.time > datenum(2019,10,01) & wggmerge.time < datenum(2019,12,01));
for j = 1:length(ind)
    figure(1)
    plot(wggmerge.pracsal(:,ind(j)),wfp_prs,'.')
    axis ij
    grid on
    title(datestr(wggmerge.time(ind(j))))
    hold on
    pause
end
%%
yr = 2;

for z = 1000
    z_ind = find(wfp_prs == z);
    regress_ind = regress_resp{z}.start(yr):regress_resp{z}.end(yr); 
    temp_detrended = detrend(resp.temp(z_ind,regress_ind),'omitnan');
    oxy_detrended = detrend(resp.doxy(z_ind,regress_ind),'omitnan');
    bad = isoutlier(temp_detrended,'quartiles','SamplePoints',resp.time(regress_ind));
    bad2 = isoutlier(oxy_detrended,'quartiles','SamplePoints',resp.time(regress_ind)); 
    
    dt_days = resp.time(regress_ind) - resp.time(regress_ind(1));
    mdl = fitlm(dt_days(bad == 0),resp.doxy(z_ind,regress_ind(bad ==0)));
    
    figure(3)
            clf
            subplot(2,1,1)
            plot(resp.time(regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),...
                resp.doxy(z_ind,regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),'ok','MarkerFaceColor','k')
            hold on
            plot(resp.time(regress_resp{z}.start(yr):regress_resp{z}.end(yr)),...
                resp.doxy(z_ind,regress_resp{z}.start(yr):regress_resp{z}.end(yr)),'ok','MarkerFaceColor','b')
            plot(resp.time(regress_ind(bad2)),...
                resp.doxy(z_ind,regress_ind(bad2)),'ok','MarkerFaceColor','r')
            plot(resp.time(regress_ind(bad == 0 & bad2 ==0)),test,'Linewidth',2)
            grid on
            ylabel('DO (\mumol/kg)')
            datetick
            
            subplot(2,1,2)
            plot(resp.time(regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),...
                resp.temp(z_ind,regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),'ok','MarkerFaceColor','k')
            hold on
            plot(resp.time(regress_resp{z}.start(yr):regress_resp{z}.end(yr)),...
                resp.temp(z_ind,regress_resp{z}.start(yr):regress_resp{z}.end(yr)),'ok','MarkerFaceColor','b')
            plot(wggmerge.time(regress_ind(bad == 1)),...
                resp.temp(z_ind,regress_ind(bad == 1)),'ok','MarkerFaceColor','r')
            grid on
            datetick
            ylabel('Temp (\circC)')
            sgtitle(['Depth = ' num2str(z) ' Year = ' num2str(yr)])
%             pause
end

%%

figure
plot(mdl)

