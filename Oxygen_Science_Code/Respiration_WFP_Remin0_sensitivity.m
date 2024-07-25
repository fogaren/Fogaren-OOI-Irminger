cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('wfpmerge_output_fixedPc1600db.mat')
load('glider_griddall_fixedPc1600db.mat')
wfp_prs = 150:1:2600;
resp = wggmerge;
glider = glidergrid; clear glidergrid;
glider_prs = 1:1000;

cd('G:\Shared drives\NSF_Irminger\Data_Files\From Meg')
load blended_mld_daily.mat blended_mld_daily_all
% rename meg's updated variables for my code 
dt = datenum(blended_mld_daily_all.time);
mld_db = blended_mld_daily_all.mld;
clear blended_mld_daily_all 

addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))

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

%% 

MLmax_ind = Dprod_ind;
for z = 175:2000% Depth to start at 
    % This is first done using everything on the retimed(index) 

    z_ind = find(wfp_prs == z); % Finds the index of that depth
    
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


       mdl = fitlm(dt_days(bad_prho == 0 & bad_doxy == 0),resp.doxy(z_ind,regress_ind(bad_prho == 0 & bad_doxy == 0)));

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
    use = find(wfp_p_value{yr} >= 0.05);
    plot(wfp_DOresp_rate_umolkg_day{yr}(use),use,'.k')
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

%%
z = depth;
for yr = 1:7
    figure(8)
    set(gcf,'position',[100,100,1200,400])
    subplot(1,7,yr)
    plot(wfp_DOresp_rate_umolkg_day{yr},1:max(z),'.')
    hold on
    use = find(wfp_p_value{yr} >= 0.05);
    plot(wfp_DOresp_rate_umolkg_day{yr}(use),use,'.k')
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
    plot(wfp_regress_days{yr},1:max(z),'.')
    axis ij
    ylabel('Pressure (db)')
        xlabel(['Year: ' num2str(yr)])
                xlim([0 500])
    sgtitle('Length of Regression Window (days)')
    grid on
end

Remin0_1 = [1008 1226 980 1240 402 675 1339];
Remin0_2 = [1060 1253 981 1278 980 797 1405];
for yr = 1:7
    figure(10)
    set(gcf,'position',[100,100,1200,400])
    subplot(1,7,yr)
    use = find(wfp_p_value{yr} < 0.05 & wfp_DOresp_rate_umolkg_day{yr} <0);
    plot(wfp_DOresp_season_molm3{yr}*-0.69,1:max(z),'.k')
    hold on
    plot(wfp_DOresp_season_molm3{yr}(use)*-0.69,use,'.')
    plot(0:0.001:0.015,ones(length(0:0.001:0.015),1)*Remin0_1(yr),'k--')
    plot(0:0.001:0.015,ones(length(0:0.001:0.015),1)*Remin0_2(yr),'k:')
    axis ij
    ylabel('Pressure (db)')
    xlim([0 0.015])
    xlabel(['Year: ' num2str(yr)])
    grid on
    sgtitle('Total Respired (mol C m^-^3): Outliers removed')
end


%% Integration 2
DOinventory_molm2 = [];
DOinventory_molm2_95CI_high = [];
DOinventory_molm2_95CI_low = [];
Remin0_1 = [1008 1226 980 1240 402 675 1339];
% Remin0_2 = [1060 1253 981 1278 980 797 1405];
% Remin0_3 = [1060 1253 981 1278 1014 797 1405];

Remin0 = Remin0_2; % Change to look at different Remin0 horizons 
for yr = 1:7

    % Intergrate using values < 0 and from the surface to Remin 0 
    use = find(wfp_DOresp_rate_umolkg_day{yr}((1:Remin0(yr))) <=0);
    use_95CI_high = find(wfp_DOresp_rate_umolkg_day_95CI_high{yr}((1:Remin0(yr))) <= 0); 
    use_95CI_low = find(wfp_DOresp_rate_umolkg_day_95CI_low{yr}((1:Remin0(yr))) <= 0);

    DOinventory_molm2(yr) = min(cumsum(wfp_DOresp_season_molm3{yr}(use)));
    DOinventory_molm2_95CI_high(yr) = min(cumsum(wfp_DOresp_season_molm3_95CI_high{yr}(use)));
    DOinventory_molm2_95CI_low(yr) = min(cumsum(wfp_DOresp_season_molm3_95CI_low{yr}(use)));

    figure(11)
    set(gcf,'position',[100,100,500,400])
    subplot(1,7,yr)
    plot(cumsum(wfp_DOresp_season_molm3{yr}(use)),(use))
    hold on
    plot(cumsum(wfp_DOresp_season_molm3_95CI_low{yr}(use)),(use))
    plot(cumsum(wfp_DOresp_season_molm3_95CI_high{yr}(use)),(use))
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
errorbar(2:8,Cinventory_molm2,Cinventory_molm2 - Cinventory_molm2_95CI_low,Cinventory_molm2 - Cinventory_molm2_95CI_high,'ok')

bar(1,nanmean(Cinventory_molm2))
ylabel('mol C m^-^2 yr^-^1')
box(axes1,'on');
hold(axes1,'off');
set(axes1,'XTick',[1:8],...
    'XTickLabel',...
    {'Mean','2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022','Average'});
title('Remin0 =  Dotted Line')
grid on

% %%
% cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
% save wfp_respiration.mat wfp* resp