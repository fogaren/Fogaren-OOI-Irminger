%% Load workspace 
% clearvars; close all

% cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Jan2024')
% load('wfpmerge_output.mat') % Hilary's wggmerge and wggmerge_fl products 
wfp_prs = 150:1:2600; % Depths of Hilary's product 

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load Dproduction.mat % load start and end of D-production period on each isobar
    % Dproduction defined here is first and last data point below mixed
        % layer
    % Dprod_start/Dprod_end is indexed by isobar Dprod_start{200} = 200 m isobar 
        % Dprod_start/Dprod_end has value for each year
        % If value == NaN, the isobar do not reenter the mixed layer that
        % year 
    % Dprod_ind is the index of the maximum mixing each year
    % This file was created using WFP_Data_in_or_out_ML.m

% load reindexed_resp.mat % load wgg data with mixed layer flags
    % includes data_in_mld variable indicating if oxygen data is in or
        % below the mixed layer
load blended_MLD_prelim_final.mat 
        % Add toolboxes and Colors 
cd('G:\My Drive\Matlab_work\BC')
run('GeneralSettings.m')

addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))
%%
% tic
% resp.doxy_sm = smoothdata(resp.doxy,2,'loess',days(270),'omitnan','SamplePoints',resp.time_dt);
% toc
% 
% z1_ind = find(wfp_prs == 200);
% z2_ind = find(wfp_prs == 2000);
% [X,Y] = meshgrid(resp.time(1:end-1),200:2000);
% 
% figure
% pcolor(X,Y,diff(resp.doxy_sm(z1_ind:z2_ind,:),1,2))
% axis ij
% shading interp
% clim([-0.2 0.2])
% cmocean('balance')
% c = colorbar;
% datetick; axis tight
% xlim([datenum(2014,08,01) datenum(2022,01,01)])
% % c.title = '\mumol kg^-^1 day^-^1';
% hold on
% plot(wfp_dt,wfp_mld,'k')
% 
% %% Figure showing data in or out of ML, smoothed data, Dprod start and end and MLmax 
% % This figure is a good visual for how start and end point of linear
% % regression of respiration signal is determined each year on 4 different
% % isobars
% MLmax_ind = Dprod_ind;
% z1 = 250; % desired isobar (db)
% z1_ind = find(wfp_prs == z1);
% yy1max = islocalmax(resp.doxy_sm(z1_ind,:));
% yy1min = islocalmin(resp.doxy_sm(z1_ind,:));
% 
% z2 = 500; % desired isobar (db)
% z2_ind = find(wfp_prs == z2);
% yy2max = islocalmax(resp.doxy_sm(z2_ind,:));
% yy2min = islocalmin(resp.doxy_sm(z2_ind,:));
% 
% z3 = 750; % desired isobar (db)
% z3_ind = find(wfp_prs == z3);
% yy3max = islocalmax(resp.doxy_sm(z3_ind,:));
% yy3min = islocalmin(resp.doxy_sm(z3_ind,:));
% 
% z4 = 1000; % desired isobar (db)
% z4_ind = find(wfp_prs == z4);
% yy4max = islocalmax(resp.doxy_sm(z4_ind,:));
% yy4min = islocalmin(resp.doxy_sm(z4_ind,:));
% 
% figure
% subplot(4,1,1)
% plot(resp.time,resp.doxy(z1_ind,:),'.')
% hold on
% plot(resp.time(resp.data_in_mld(z1_ind,:) == 0),resp.doxy(z1_ind,resp.data_in_mld(z1_ind,:) == 0),'.','Color',rgb('gray'))
% plot(resp.time,resp.doxy_sm(z1_ind,:),'k','Linewidth',2)
% plot(resp.time(yy1max),resp.doxy_sm(z1_ind,yy1max),'og','MarkerFaceColor','g')
% plot(resp.time(yy1min),resp.doxy_sm(z1_ind,yy1min),'or','MarkerFaceColor','r')
% % plot(resp.time(Dprod_start{z1}(~isnan(Dprod_start{z1}))),resp.doxy(z1_ind,Dprod_start{z1}(~isnan(Dprod_start{z1}))),'cs','MarkerSize',10,'Linewidth',1.5)
% % plot(resp.time(Dprod_end{z1}(~isnan(Dprod_end{z1}))),resp.doxy(z1_ind,Dprod_end{z1}(~isnan(Dprod_end{z1}))),'m^','MarkerSize',10,'Linewidth',1.5)
% plot(resp.time(Dprod_start{z1}(~isnan(Dprod_start{z1}))),resp.doxy_sm(z1_ind,Dprod_start{z1}(~isnan(Dprod_start{z1}))),'cs','MarkerSize',10,'Linewidth',1.5)
% plot(resp.time(Dprod_end{z1}(~isnan(Dprod_end{z1}))),resp.doxy_sm(z1_ind,Dprod_end{z1}(~isnan(Dprod_end{z1}))),'m^','MarkerSize',10,'Linewidth',1.5)
% 
% plot(resp.time(MLmax_ind),resp.doxy_sm(z1_ind,MLmax_ind),'*','Color',rgb('orange'),'MarkerSize',15,'Linewidth',1.5)
% datetick; grid on
% ylabel('Oxygen (\mumol kg^-^1)')
% ylim([260 320])
% title(['Depth = ' num2str(z1)])
% 
% subplot(4,1,2)
% plot(resp.time,resp.doxy(z2_ind,:),'.')
% hold on
% plot(resp.time(resp.data_in_mld(z2_ind,:) == 0),resp.doxy(z2_ind,resp.data_in_mld(z2_ind,:) == 0),'.','Color',rgb('gray'))
% plot(resp.time,resp.doxy_sm(z2_ind,:),'k','Linewidth',2)
% plot(resp.time(yy2max),resp.doxy_sm(z2_ind,yy2max),'og','MarkerFaceColor','g')
% plot(resp.time(yy2min),resp.doxy_sm(z2_ind,yy2min),'or','MarkerFaceColor','r')
% plot(resp.time(Dprod_start{z2}(~isnan(Dprod_start{z2}))),resp.doxy_sm(z2_ind,Dprod_start{z2}(~isnan(Dprod_start{z2}))),'cs','MarkerSize',10,'Linewidth',1.5)
% plot(resp.time(Dprod_end{z2}(~isnan(Dprod_end{z2}))),resp.doxy_sm(z2_ind,Dprod_end{z2}(~isnan(Dprod_end{z2}))),'m^','MarkerSize',10,'Linewidth',1.5)
% plot(resp.time(MLmax_ind),resp.doxy_sm(z2_ind,MLmax_ind),'*','Color',rgb('orange'),'MarkerSize',15,'Linewidth',1.5)
% datetick; grid on
% ylabel('Oxygen (\mumol kg^-^1)')
% ylim([260 320])
% title(['Depth = ' num2str(z2)])
% 
% subplot(4,1,3)
% plot(resp.time,resp.doxy(z3_ind,:),'.')
% hold on
% plot(resp.time(resp.data_in_mld(z3_ind,:) == 0),resp.doxy(z3_ind,resp.data_in_mld(z3_ind,:) == 0),'.','Color',rgb('gray'))
% plot(resp.time,resp.doxy_sm(z3_ind,:),'k','Linewidth',2)
% plot(resp.time(yy3max),resp.doxy_sm(z3_ind,yy3max),'og','MarkerFaceColor','g')
% plot(resp.time(yy3min),resp.doxy_sm(z3_ind,yy3min),'or','MarkerFaceColor','r')
% plot(resp.time(Dprod_start{z3}(~isnan(Dprod_start{z3}))),resp.doxy_sm(z3_ind,Dprod_start{z3}(~isnan(Dprod_start{z3}))),'cs','MarkerSize',10,'Linewidth',1.5)
% plot(resp.time(Dprod_end{z3}(~isnan(Dprod_end{z3}))),resp.doxy_sm(z3_ind,Dprod_end{z3}(~isnan(Dprod_end{z3}))),'m^','MarkerSize',10,'Linewidth',1.5)
% plot(resp.time(MLmax_ind),resp.doxy_sm(z3_ind,MLmax_ind),'*','Color',rgb('orange'),'MarkerSize',15,'Linewidth',1.5)
% datetick; grid on
% ylabel('Oxygen (\mumol kg^-^1)')
% ylim([260 320])
% title(['Depth = ' num2str(z3)])
% 
% subplot(4,1,4)
% plot(resp.time,resp.doxy(z4_ind,:),'.')
% hold on
% plot(resp.time(resp.data_in_mld(z4_ind,:) == 0),resp.doxy(z4_ind,resp.data_in_mld(z4_ind,:) == 0),'.','Color',rgb('gray'))
% plot(resp.time,resp.doxy_sm(z4_ind,:),'k','Linewidth',2)
% plot(resp.time(yy4max),resp.doxy_sm(z4_ind,yy4max),'og','MarkerFaceColor','g')
% plot(resp.time(yy4min),resp.doxy_sm(z4_ind,yy4min),'or','MarkerFaceColor','r')
% plot(resp.time(Dprod_start{z4}(~isnan(Dprod_start{z4}))),resp.doxy_sm(z4_ind,Dprod_start{z4}(~isnan(Dprod_start{z4}))),'cs','MarkerSize',10,'Linewidth',1.5)
% plot(resp.time(Dprod_end{z4}(~isnan(Dprod_end{z4}))),resp.doxy_sm(z4_ind,Dprod_end{z4}(~isnan(Dprod_end{z4}))),'m^','MarkerSize',10,'Linewidth',1.5)
% plot(resp.time(MLmax_ind),resp.doxy_sm(z4_ind,MLmax_ind),'*','Color',rgb('orange'),'MarkerSize',15,'Linewidth',1.5)
% datetick; grid on
% ylabel('Oxygen (\mumol kg^-^1)')
% ylim([260 320])
% title(['Depth = ' num2str(z4)])

%% 

MLmax_ind = Dprod_ind;
for z = 175:2000% Depth to start at 
    % This is first done using everything on the retimed(index) 

    z_ind = find(wfp_prs == z); % Finds the index of that depth
%     localmax = islocalmax(resp.doxy_sm(z_ind,:)); % Maxs for whole time series
%     localmin = islocalmin(resp.doxy_sm(z_ind,:)); % Mins for whole time series
% 
%     localmax_dt = resp.time(localmax); % Finds retimed time of all maxes 
%     localmin_dt = resp.time(localmin); % Finds retimed time of all mins
% 
%     localmax_ind = find(localmax == 1);
%     localmin_ind = find(localmin == 1);
    
    regress_start = [];
    regress_end = []; 
    dt_days = [];

    for yr = 1:8 % Deployment year 
        % Find retimed time for each year 

            if ~isnan(Dprod_start{z}(yr))
                regress_start(yr) = Dprod_start{z}(yr);
            elseif isnan(Dprod_start{z}(yr))
                regress_start(yr) = MLmax_ind(yr);
            end

%             if ~isnan(Dprod_end{z}(yr))             
%                 yr_end = find(localmin_ind <= Dprod_end{z}(yr),1,'last');
%                 if isempty(yr_end)
%                     regress_end(yr) = Dprod_end{z}(yr);
%                 elseif ~isempty(yr_end)
%                     regress_end(yr) = localmin_ind(yr_end);
%                 end
%             elseif isnan(Dprod_end_retimed{z}(yr))
%                 regress_end(yr) = MLmax_ind(yr+1); 
%             end
            if ~isnan(Dprod_end{z}(yr))   % To go from Dprod_start to end or max to max           
                regress_end(yr) = Dprod_end{z}(yr);
            elseif isnan(Dprod_end{z}(yr))
                regress_end(yr) = MLmax_ind(yr+1); 
            end
%                 
            Dprod_days = resp.time(regress_start(yr):regress_end(yr)) - resp.time(regress_start(yr));
    end

    regress_resp{z}.start = regress_start;
    regress_resp{z}.end = regress_end;
    regress_resp{z}.Dprod_days = Dprod_days; 
    
end

%%
% Create empty output variables 
wfP_DOresp_rate_umolkg_day = [];
wfp_DOresp_rate_umolkg_day_95CI_high = [];
wfp_DOresp_rate_umolkg_day_95CI_low = []; 
wfp_b_umolkg = [];
wfp_p_value = [];
wfp_R2 = [];
wfp_regress_days = []; 
wfp_DOresp_season_umolkg = []; % rate (slope) *resp_days 
wfp_DOresp_season_umolkg_95CI_high = []; % rate (slope) *resp_days 
wfp_DOresp_season_umolkg_95CI_low = []; % rate (slope) *resp_days 
wfp_Dprod_prho = [];
wfp_DOresp_season_molm3 = []; 
wfp_DOresp_season_molm3_95CI_high = [];
wfp_DOresp_season_molm3_95CI_low = [];
%%
figs = 0;
for yr = 2:8 % Deployment Year 

    for z = 175:2000
        z_ind = find(wfp_prs == z); % Finds the index of that depth
        if yr == 7 % Need to start regression after large chunk of missing data 
            regress_ind = find(resp.time > datenum(2020,08,00),1,'first'):regress_resp{z}.end(yr);
        else
            regress_ind = regress_resp{z}.start(yr):regress_resp{z}.end(yr); 
        end
        dt_days = resp.time(regress_ind) - resp.time(regress_resp{z}.start(yr));

        temp_detrended = detrend(resp.temp(z_ind,regress_ind),'omitnan');
        bad_temp = isoutlier(temp_detrended,'quartiles','SamplePoints',resp.time(regress_ind));
        prho_detrended = detrend(resp.prho(z_ind,regress_ind),'omitnan');
        bad_prho = isoutlier(prho_detrended,'quartiles','SamplePoints',resp.time(regress_ind));
        doxy_detrended = detrend(resp.doxy(z_ind,regress_ind),'omitnan');
        bad_doxy = isoutlier(doxy_detrended,'quartiles','SamplePoints',resp.time(regress_ind));

%             mdl = fitlm(dt_days(bad_prho == 0),resp.doxy(z_ind,regress_ind(bad_prho == 0)));
%             mdl = fitlm(dt_days,resp.doxy(z_ind,regress_ind));
%             mdl = fitlm(dt_days,resp.doxy(z_ind,regress_ind));
%         else
%             mdl = fitlm(dt_days(bad_temp == 0 & bad_doxy == 0),resp.doxy(z_ind,regress_ind(bad_temp == 0 & bad_doxy == 0)));
            mdl = fitlm(dt_days(bad_prho == 0 & bad_doxy == 0),resp.doxy(z_ind,regress_ind(bad_prho == 0 & bad_doxy == 0)));
%                         mdl = fitlm(dt_days,resp.doxy(z_ind,regress_ind));
%         end

%             figure(1)
%             plot(dt_days,resp.doxy(z_ind,(regress_resp{z}.start(yr)):regress_resp{z}.end(yr)),'ok','MarkerFaceColor','k')
%             grid on
%             title(['Depth = ' num2str(z) ' Year = ' num2str(yr)])
        if figs == 1
            figure %(2)
            clf
            subplot(2,1,1)
            plot(resp.time(regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),...
                resp.doxy(z_ind,regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),'ok','MarkerFaceColor','k')
            hold on
            plot(resp.time(regress_resp{z}.start(yr):regress_resp{z}.end(yr)),...
                resp.doxy(z_ind,regress_resp{z}.start(yr):regress_resp{z}.end(yr)),'ok','MarkerFaceColor','b')
            plot(resp.time(regress_ind(bad_doxy == 1)),...
                resp.doxy(z_ind,regress_ind(bad_doxy ==1)),'ok','MarkerFaceColor','y')
            plot(resp.time(regress_ind(bad_prho == 1)),...
                resp.doxy(z_ind,regress_ind(bad_prho ==1)),'or','Linewidth',1.2)
            grid on
            ylabel('Oxygen')
            legend('All data','Data below ML','Oxygen Outlier','Density Outlier','Orientation','horizontal','Location','northeast')
            datetick
            
            subplot(2,1,2)
            plot(resp.time(regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),...
                resp.prho(z_ind,regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),'ok','MarkerFaceColor','k')
            hold on
            plot(resp.time(regress_resp{z}.start(yr):regress_resp{z}.end(yr)),...
                resp.prho(z_ind,regress_resp{z}.start(yr):regress_resp{z}.end(yr)),'ok','MarkerFaceColor','b')
            plot(resp.time(regress_ind(bad_prho== 1)),...
                resp.prho(z_ind,regress_ind(bad_prho ==1)),'ok','MarkerFaceColor','r')
            grid on
            datetick
            legend('All data','Data below ML','Density Outlier','Orientation','horizontal','Location','northeast')
            ylabel('prho')
            
            sgtitle(['Depth = ' num2str(z) ' Year = ' num2str(yr)])
    
            pause 
        end

        CI = mdl.coefCI;

        % Stores them by actual depth and by Year for analysis 
        wfp_DOresp_rate_umolkg_day{yr-1}(z) = mdl.Coefficients.Estimate(2);
        wfp_DOresp_rate_umolkg_day_95CI_high{yr-1}(z) = CI(2,1);
        wfp_DOresp_rate_umolkg_day_95CI_low{yr-1}(z) = CI(2,2); 
        wfp_b_umolkg{yr-1}(z) = mdl.Coefficients.Estimate(1);
        wfp_p_value{yr-1}(z) = mdl.Coefficients.pValue(2);
        wfp_R2{yr-1}(z) = mdl.Rsquared.Ordinary;
        wfp_regress_days{yr-1}(z) = max(dt_days); 
        wfp_DOresp_season_umolkg{yr-1}(z) = mdl.Coefficients.Estimate(2)*max(dt_days); % rate (slope) *resp_days
        wfp_DOresp_season_umolkg_95CI_high{yr-1}(z) = CI(2,1)*max(dt_days); % rate (slope) *resp_days
        wfp_DOresp_season_umolkg_95CI_low{yr-1}(z) = CI(2,2)*max(dt_days); % rate (slope) *resp_days
        wfp_Dprod_prho{yr-1}(z) = nanmean(resp.prho(z_ind,regress_resp{z}.start(yr):regress_resp{z}.end(yr)));
        wfp_DOresp_season_molm3{yr-1}(z) = (wfp_DOresp_season_umolkg{yr-1}(z).*wfp_Dprod_prho{yr-1}(z))/(1000*1000);
        wfp_DOresp_season_molm3_95CI_high{yr-1}(z) = (wfp_DOresp_season_umolkg_95CI_high{yr-1}(z).*wfp_Dprod_prho{yr-1}(z))/(1000*1000);
        wfp_DOresp_season_molm3_95CI_low{yr-1}(z) = (wfp_DOresp_season_umolkg_95CI_low{yr-1}(z).*wfp_Dprod_prho{yr-1}(z))/(1000*1000);
    end
end
%%
depth = 175:2000;
mycolors = [maroon; red; yellow; green; forestgreen; blue; purple; brightpurple];
for yr = 1:7 % science analysis year 
    figure
    set(gcf,'position',[100,100,850,400])
    subplot(1,3,1)
    plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.')
    hold on
    plot(wfp_DOresp_rate_umolkg_day_95CI_low{yr}(depth),depth,'.') 
    plot(wfp_DOresp_rate_umolkg_day_95CI_high{yr}(depth),depth,'.') 
    p = find(wfp_p_value{yr} >= 0.05);
    plot(wfp_DOresp_rate_umolkg_day{yr}(p),p,'.k')
    axis ij
    ylabel('Pressure (db)')
    title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
    grid on
    
    subplot(1,3,2)
    plot(wfp_regress_days{yr}(depth),depth,'.')
    hold on
    axis ij
    ylabel('Pressure (db)')
    title('Length of Regression (days)')
    grid on

    subplot(1,3,3)
    plot(wfp_DOresp_season_molm3{yr}(depth)*-0.69,depth,'.')
    hold on
    plot(wfp_DOresp_season_molm3_95CI_low{yr}(depth)*-0.69,depth,'.')
    plot(wfp_DOresp_season_molm3_95CI_high{yr}(depth)*-0.69,depth,'.')
    axis ij
    ylabel('Pressure (db)')
    grid on
    title('Total Respired (mol C m^-^3)')
    sgtitle(['Year ' num2str(yr)])
end
%% For comparing Dprod 1 and Dprod 2

% wfp_DOresp_rate_umolkg_day1 = wfp_DOresp_rate_umolkg_day;
% wfp_regress_days1 = wfp_regress_days;
% wfp_DOresp_rate_umolkg_day2 = wfp_DOresp_rate_umolkg_day;
% wfp_regress_days2 = wfp_regress_days;
fig_run = 1;
if fig_run == 1

yr = 3; % Science Year, not deployment year at this point 

for z = 200:10:1500
    z_ind = find(wfp_prs == z);
        if yr == 6 % Need to start regression after large chunk of missing data 
            regress_ind = find(resp.time > datenum(2020,08,00),1,'first'):regress_resp{z}.end(yr);
        else
            regress_ind = regress_resp{z}.start(yr):regress_resp{z}.end(yr); 
        end
%     prho_detrended = detrend(resp.prho(z_ind,regress_ind),'omitnan');
%     oxy_detrended = detrend(resp.doxy(z_ind,regress_ind),'omitnan');
%     bad = isoutlier(prho_detrended,'quartiles','SamplePoints',resp.time(regress_ind));
%     bad2 = isoutlier(oxy_detrended,'quartiles','SamplePoints',resp.time(regress_ind)); 
    
    dt_days = resp.time(regress_ind) - resp.time(regress_ind(1));
%     mdl = fitlm(dt_days(bad == 0),resp.doxy(z_ind,regress_ind(bad ==0)));
    
    figure(3) 
            clf
            subplot(2,1,1)
            plot(resp.time(regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),...
                resp1.doxy(z_ind,regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),'ok','MarkerFaceColor','k')
            hold on
            plot(resp.time(regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),...
                resp2.doxy(z_ind,regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),'ok','MarkerFaceColor',rgb('gray'))

            plot(resp.time(regress_resp{z}.start(yr):regress_resp{z}.end(yr)),...
                resp1.doxy(z_ind,regress_resp{z}.start(yr):regress_resp{z}.end(yr)),'ok','MarkerFaceColor','b')
            plot(resp.time(regress_resp{z}.start(yr):regress_resp{z}.end(yr)),...
                resp2.doxy(z_ind,regress_resp{z}.start(yr):regress_resp{z}.end(yr)),'ok','MarkerFaceColor',rgb('light blue'))
            grid on
            ylabel('DO (\mumol/kg)')
            datetick
            
            subplot(2,1,2)
            plot(resp.time(regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),...
                resp1.prho(z_ind,regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),'ok','MarkerFaceColor','k')
            hold on
            plot(resp.time(regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),...
                resp2.prho(z_ind,regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),'ok','MarkerFaceColor',rgb('gray'))

            plot(resp.time(regress_resp{z}.start(yr):regress_resp{z}.end(yr)),...
                resp1.prho(z_ind,regress_resp{z}.start(yr):regress_resp{z}.end(yr)),'ok','MarkerFaceColor','b')
            plot(resp.time(regress_resp{z}.start(yr):regress_resp{z}.end(yr)),...
                resp2.prho(z_ind,regress_resp{z}.start(yr):regress_resp{z}.end(yr)),'ok','MarkerFaceColor',rgb('light blue'))
            grid on
            datetick
            ylabel('prho (kg/m^3)')
            sgtitle(['Depth = ' num2str(z) ' Year = ' num2str(yr)])
            pause
end
end

%%
z = depth;
for yr = 1:7
    figure(8)
    set(gcf,'position',[100,100,1200,400])
    subplot(1,7,yr)
%     plot(wfp_DOresp_rate_umolkg_day{yr},1:max(z),'.')
        plot(wfp_DOresp_rate_umolkg_day1{yr},1:max(z),'.')
        hold on
            plot(wfp_DOresp_rate_umolkg_day2{yr},1:max(z),'.')
    hold on
%     p = find(wfp_p_value{yr} >= 0.05);
%     plot(wfp_DOresp_rate_umolkg_day{yr}(p),p,'.k')
    axis ij
    ylabel('Pressure (db)')
    xlabel(['Year: ' num2str(yr)])
    sgtitle('Respiration Rate (\mumol DO kg^-^1 d^-^1): Outliers removed')
    xlim([-0.1 0.04])
    grid on
end

for yr = 1:7
    figure(9)
    set(gcf,'position',[100,100,1200,400])
    subplot(1,7,yr)
%     plot(wfp_regress_days{yr},1:max(z),'.')]
    plot(wfp_regress_days1{yr},1:max(z),'.')
    hold on
        plot(wfp_regress_days2{yr},1:max(z),'.')
    axis ij
    ylabel('Pressure (db)')
        xlabel(['Year: ' num2str(yr)])
                xlim([0 500])
    sgtitle('Length of Regression Window (days)')
    grid on
end
%%
for yr = 1:7
    figure(10)
    set(gcf,'position',[100,100,1200,400])
    subplot(1,7,yr)
    p = find(wfp_p_value{yr} < 0.05 & wfp_DOresp_rate_umolkg_day{yr} <0);
    plot(wfp_DOresp_season_molm3{yr}*-0.69,1:max(z),'.k')
    hold on
    plot(wfp_DOresp_season_molm3{yr}(p)*-0.69,p,'.')
    axis ij
    ylabel('Pressure (db)')
        xlim([0 0.015])
    xlabel(['Year: ' num2str(yr)])
    grid on
    sgtitle('Total Respired (mol C m^-^3): Outliers removed')
end
%% Integration 
DOinventory_molm2 = [];
DOinventory_molm2_95CI_high = [];
DOinventory_molm2_95CI_low = [];
for yr = 1:7

    p = find(wfp_p_value{yr} < 0.05 & wfp_DOresp_rate_umolkg_day{yr} <0);
    p_95CI_high = find(wfp_p_value{yr} < 0.05 & wfp_DOresp_rate_umolkg_day_95CI_high{yr} < 0); 
    p_95CI_low = find(wfp_p_value{yr} < 0.05 & wfp_DOresp_rate_umolkg_day_95CI_low{yr} < 0);

    DOinventory_molm2(yr) = min(cumsum(wfp_DOresp_season_molm3{yr}(p)));
    DOinventory_molm2_95CI_high(yr) = min(cumsum(wfp_DOresp_season_molm3_95CI_high{yr}(p)));
    DOinventory_molm2_95CI_low(yr) = min(cumsum(wfp_DOresp_season_molm3_95CI_low{yr}(p)));

    figure(11)
    set(gcf,'position',[100,100,500,400])
    subplot(1,7,yr)
    plot(cumsum(wfp_DOresp_season_molm3{yr}(p)),p)
    hold on
    plot(cumsum(wfp_DOresp_season_molm3_95CI_low{yr}(p)),p)
    plot(cumsum(wfp_DOresp_season_molm3_95CI_high{yr}(p)),p)
    axis ij
    ylabel('Pressure (db)')
    xlabel('Respiration Rate (\mumol DO kg^-^1 d^-^1)')

    grid on
    title(['Dproduction Year ' num2str(yr)])
end
%%
% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');
Cinventory_molm2 = DOinventory_molm2*-0.69;
Cinventory_molm2_95CI_low = DOinventory_molm2_95CI_low*-0.69;
Cinventory_molm2_95CI_high = DOinventory_molm2_95CI_high*-0.69;

bar(2:8,Cinventory_molm2)
hold on
errorbar(2:8,Cinventory_molm2,Cinventory_molm2_95CI_low - Cinventory_molm2,Cinventory_molm2_95CI_high - Cinventory_molm2,'ok')
% errorbar(2015:2020,Cinventory_molm2,Cinventory_molm2 - Cinventory_molm2_95CI_low,Cinventory_molm2 - Cinventory_molm2_95CI_high,'ok')

bar(1,nanmean(Cinventory_molm2))
ylabel('NCP mol C m^-^2 yr^-^1')
box(axes1,'on');
hold(axes1,'off');
set(axes1,'XTick',[1:8],...
    'XTickLabel',...
    {'Mean','2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022','Average'});
title('NCP through 200 m: Outliers Removed')
grid on
%%
fig_run = 1;
if fig_run == 1

yr = 3; % Science Year, not deployment year at this point 

for z = 200:10:1500
    z_ind = find(wfp_prs == z);
        if yr == 6 % Need to start regression after large chunk of missing data 
            regress_ind = find(resp.time > datenum(2020,08,00),1,'first'):regress_resp{z}.end(yr);
        else
            regress_ind = regress_resp{z}.start(yr):regress_resp{z}.end(yr); 
        end
    prho_detrended = detrend(resp.prho(z_ind,regress_ind),'omitnan');
    oxy_detrended = detrend(resp.doxy(z_ind,regress_ind),'omitnan');
    bad = isoutlier(prho_detrended,'quartiles','SamplePoints',resp.time(regress_ind));
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
            grid on
            ylabel('DO (\mumol/kg)')
            datetick
            
            subplot(2,1,2)
            plot(resp.time(regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),...
                resp.prho(z_ind,regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),'ok','MarkerFaceColor','k')
            hold on
            plot(resp.time(regress_resp{z}.start(yr):regress_resp{z}.end(yr)),...
                resp.prho(z_ind,regress_resp{z}.start(yr):regress_resp{z}.end(yr)),'ok','MarkerFaceColor','b')
            plot(resp.time(regress_ind(bad == 1)),...
                resp.prho(z_ind,regress_ind(bad == 1)),'ok','MarkerFaceColor','r')
            grid on
            datetick
            ylabel('prho (kg/m^3)')
            sgtitle(['Depth = ' num2str(z) ' Year = ' num2str(yr)])
            pause
end
end
% load('chirp')
% sound(y)
%%
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
save wfp_respiration.mat wfp* resp