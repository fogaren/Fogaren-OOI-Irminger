%% Load workspace 
clearvars; close all; clc
addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('wfpmerge_output_fixedPc1600db.mat')
wfp_prs = 150:1:2600; % Depths of Hilary's product

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('glider_griddall_fixedPc1600db.mat')
glider = glidergrid; clear glidergrid;
glider_prs = 1:1000;

cd('G:\Shared drives\NSF_Irminger\Data_Files\From Meg')
load blended_mld_daily.mat blended_mld_daily_all
% rename meg's updated variables for my code 
% Remove nan data and create MLDs for every day
day_mld0 = blended_mld_daily_all.mld;
day_dn0 = datenum(blended_mld_daily_all.time);

day_dn0(isnan(day_mld0)) = [];
day_mld0(isnan(day_mld0)) = [];

day_mld = interp1(day_dn0,day_mld0,datenum(blended_mld_daily_all.time),'linear');
day_mld = round(day_mld);
day_dn = datenum(blended_mld_daily_all.time); 

mld_max = islocalmax(day_mld,'MinSeparation',days(270),'SamplePoints',blended_mld_daily_all.time);
mld_max = find(mld_max); 
mld_max_ind = mld_max(1:8); % Ignore last winter, past my timeseries 

dt = datenum(blended_mld_daily_all.time);
mld_db = blended_mld_daily_all.mld;
clear blended_mld_daily_all day_* mld_max 

% Sort time to be in ascending order
[time,IND] = sort(wggmerge.time);
doxy = wggmerge.doxy(:,IND);
prho = wggmerge.pdens(:,IND);
temp = wggmerge.temp(:,IND);
sal = wggmerge.pracsal(:,IND);
% backscatter = wggmerge.backscatter(:,IND); % need to use wggmerge_fl
% chla = wggmerge.chla(:,IND);

resp.time = time;
resp.doxy = doxy; 
resp.prho = prho; 
resp.temp = temp; 
resp.sal = sal; 
% resp.backscatter = backscatter;
% resp.chla = chla;
clear time doxy prho temp sal backscatter chla IND wggmerge wggmerge_fl


%%
% Figure out number of glider profiles by using time stamp. 
glid_time = []; 
glid_DO_all = [];
glid_prho_all = []; 
glid_temp_all = [];
glid_sal_all = [];
% glid_backscatter_all = []; % Need to 
% glid_chla_all = [];

for j = [1:4 6:13]
    glid_time = [glid_time; glider{j}.time];
    glid_DO_all = [glid_DO_all glider{j}.doxy];
    glid_prho_all = [glid_prho_all glider{j}.pdens];
    glid_temp_all = [glid_temp_all glider{j}.temp];
    glid_sal_all = [glid_sal_all glider{j}.pracsal];
%     glid_backscatter_all = [glid_backscatter_all glider{j}.backscatter];
%     glid_chla_all = [glid_chla_all glider{j}.chla;]
end

% Create emtpy NaN matrix for each profile and fill with glider data 
glid_DO = NaN(max(wfp_prs),length(glid_time));
glid_prho = glid_DO; 
glid_temp = glid_DO;
glid_sal = glid_DO;
% glid_backscatter = glid_DO;
% glid_chla = glid_DO;

for pn = 1:length(glid_time)
    glid_DO(1:1000,pn) = glid_DO_all(:,pn);
    glid_prho(1:1000,pn) = glid_prho_all(:,pn);
    glid_temp(1:1000,pn) = glid_temp_all(:,pn);
    glid_sal(1:1000,pn) = glid_sal_all(:,pn);
%     glid_backscatter(1:1000,pn) = glid_backscatter_all(:,pn);
%     glid_chla(1:1000,pn) = glid_chla_all(:,pn);
end

% Create empty NaN matrix and fill with WFP data 
wfp_DO = NaN(max(wfp_prs),length(resp.time));
wfp_prho = wfp_DO; 
wfp_temp = wfp_DO; 
wfp_sal = wfp_DO;
% wfp_backscatter = wfp_DO; 
% wfp_chla = wfp_DO; 
for pn = 1:length(resp.time)
    wfp_DO(wfp_prs,pn) = resp.doxy(:,pn);
    wfp_prho(wfp_prs,pn) = resp.prho(:,pn);
    wfp_temp(wfp_prs,pn) = resp.temp(:,pn);
    wfp_sal(wfp_prs,pn) = resp.sal(:,pn);
%     wfp_backscatter(wfp_prs,pn) = resp.backscatter(:,pn);
%     wfp_chla(wfp_prs,pn) = resp.chla(:,pn);
end

DO_unsorted = [glid_DO wfp_DO];
prho_unsorted = [glid_prho wfp_prho]; 
temp_unsorted = [glid_temp wfp_temp];
sal_unsorted = [glid_sal wfp_sal];
time_unsorted = [glid_time; resp.time];

[time,IND] = sort(time_unsorted);
doxy = DO_unsorted(:,IND);
prho = prho_unsorted(:,IND);
temp = temp_unsorted(:,IND);
sal = sal_unsorted(:,IND); 
%%
figure
set(gcf,'position',[100,100,900,300])
hold on; axis ij; box on
plot(dt,mld_db,'ok','MarkerSize',2,'MarkerFaceColor','k')
plot(dt(mld_max_ind),mld_db(mld_max_ind),'*m','MarkerSize',8)
for j = 1:length(mld_max_ind)-1
%     plot(dt(mld_max_ind(j):mld_max_ind(j+1)),ones(1,length(mld_max_ind(j):mld_max_ind(j+1)))*1800,'k')
    dt_text = round((mld_max_ind(j+1) - mld_max_ind(j))/2) + mld_max_ind(j);
    text(dt(dt_text)-100,1800,['Year ' num2str(j)],'Fontsize',12)
end
for j = 1:length(mld_max_ind)
    plot(dt(mld_max_ind(j))*ones(201,1),1700:1900,'k','Linewidth',2)
end
datetick
grid on
ylim([0 2000])

%% If want 2D plot
prs_grid = 1:2600;
[X2,Y2] = meshgrid(time,prs_grid);

figure
set(gcf,'position',[100,100,900,300])
scatter(X2(~isnan(doxy)),Y2(~isnan(doxy)),5,doxy(~isnan(doxy)),'filled')
hold on; axis ij; box on
plot(dt,mld_db,'ok','MarkerSize',2,'MarkerFaceColor','k')
ylim([0 2000])
clim([260 320])
datetick('x','yyyy');
xlim([datenum(2015,01,01) datenum(2022,04,01)])
for j = 1:length(mld_max_ind)-1
%     plot(dt(mld_max_ind(j):mld_max_ind(j+1)),ones(1,length(mld_max_ind(j):mld_max_ind(j+1)))*1800,'k')
    dt_text = round((mld_max_ind(j+1) - mld_max_ind(j))/2) + mld_max_ind(j);
    text(dt(dt_text)-100,1800,['Year ' num2str(j)],'Fontsize',12,'FontWeight','bold')
end
for j = 1:length(mld_max_ind)
    plot(dt(mld_max_ind(j))*ones(201,1),1700:1900,'k','Linewidth',2)
end
cmocean('dense')
ylabel('Pressure (dbar)', 'Fontsize', 12); hcb = colorbar; set(hcb,'location','eastoutside')
hcb.Label.String = 'DO (\mumol kg^-^1)';
hcb.FontSize = 12;
ax = gca;
set(ax, 'TickDir', 'out')
ax.FontSize = 12;
%%
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load respiration_length_by_year.mat
%%
% Create empty output variables 
DOresp_rate_umolkg_day = [];
DOresp_rate_umolkg_day_95CI_high = [];
DOresp_rate_umolkg_day_95CI_low = []; 
b_umolkg = [];
p_value = [];
R2 = [];
regress_days = []; 
Dremin_length_days = [];
DOresp_season_umolkg = []; % rate (slope) *resp_days 
DOresp_season_umolkg_95CI_high = []; % rate (slope) *resp_days 
DOresp_season_umolkg_95CI_low = []; % rate (slope) *resp_days 
regress_prho = [];
DOresp_season_molm3 = []; 
DOresp_season_molm3_95CI_high = [];
DOresp_season_molm3_95CI_low = [];
DO_out_removed = doxy;

%%
for j = 1:7

    for z =  1:2000
        if j == 6
            if resp_end{j}(z) > datenum(2020,08,00,13,42,57) & resp_start{j}(z) ~= resp_end{j}(z)
                [resp_start_z,~] = find(time >= datenum(2020,08,00),1,'first');
                [resp_start_z0,~] = find(time >= resp_start{j}(z),1,'first');
                [resp_end_z,~] = find(time <= resp_end{j}(z),1,'last');
                if resp_start_z < resp_end_z
                    resp_ind = resp_start_z:resp_end_z;
                    resp_ind0 = resp_start_z0:resp_end_z;
                    dt_days = time(resp_ind) - time(resp_ind(1));
                    Dremin_days = time(resp_ind0)- time(resp_ind0(1));

                % Remove prho/DO outliers 
                prho_detrend = detrend(prho(z,resp_ind),'omitnan');
                bad_prho = isoutlier(prho_detrend,'quartiles','SamplePoints',time(resp_start_z:resp_end_z));
                doxy_detrended = detrend(doxy(z,resp_ind),'omitnan');
                bad_doxy = isoutlier(doxy_detrended,'quartiles','SamplePoints',time(resp_start_z:resp_end_z));
        
                mdl = fitlm(dt_days(bad_prho == 0 & bad_doxy == 0),doxy(z,resp_ind(bad_prho == 0 & bad_doxy == 0)));
                CI = mdl.coefCI;
        
                regress_prho{j}(z) = nanmean(prho(z,resp_ind(bad_prho == 0 & bad_doxy == 0)));
                        
                DO_out_removed(z,resp_ind(bad_prho == 1)) = NaN;
                DO_out_removed(z,resp_ind(bad_doxy == 1)) = NaN; 
                else 
                    resp_start_z = NaN;
                    resp_end_z = NaN;
                    dt_days = 0;
                    mdl = fitlm(NaN,NaN);
                    regress_prho{j}(z) = NaN;
                    CI(1:2,1:2) = 0;
                    resp_ind = 0; 
                    Dremin_days = 0; 
                end
            else 
                resp_start_z = NaN;
                resp_end_z = NaN;
                dt_days = 0;
                mdl = fitlm(NaN,NaN);
                regress_prho{j}(z) = NaN;
                CI(1:2,1:2) = 0;
                resp_ind = 0; 
                Dremin_days = 0; 
            end
        elseif j ~=6
            if resp_end{j}(z) > resp_start{j}(z)
                [resp_start_z,~] = find(time > resp_start{j}(z),1,'first');
                [resp_end_z,~] = find(time < resp_end{j}(z),1,'last');
                resp_ind = resp_start_z:resp_end_z;
                Dremin_days = time(resp_ind) - time(resp_ind(1));
                dt_days = Dremin_days; 
                
                % Remove prho/DO outliers 
                prho_detrend = detrend(prho(z,resp_ind),'omitnan');
                bad_prho = isoutlier(prho_detrend,'quartiles','SamplePoints',time(resp_start_z:resp_end_z));
                doxy_detrended = detrend(doxy(z,resp_ind),'omitnan');
                bad_doxy = isoutlier(doxy_detrended,'quartiles','SamplePoints',time(resp_start_z:resp_end_z));
        
                mdl = fitlm(dt_days(bad_prho == 0 & bad_doxy == 0),doxy(z,resp_ind(bad_prho == 0 & bad_doxy == 0)));
                CI = mdl.coefCI;
        
                regress_prho{j}(z) = nanmean(prho(z,resp_ind(bad_prho == 0 & bad_doxy == 0)));
                        
                DO_out_removed(z,resp_ind(bad_prho == 1)) = NaN;
                DO_out_removed(z,resp_ind(bad_doxy == 1)) = NaN; 
            else 
                Dremin_days = 0; 
                dt_days = 0; 
                resp_start_z = NaN;
                resp_end_z = NaN; 
                mdl = fitlm(NaN,NaN);
                regress_prho{j}(z) = NaN;
                CI(1:2,1:2) = 0;
                resp_ind = 0;  
            end
        end

        % Stores them by actual depth 
        DOresp_rate_umolkg_day{j}(z) = mdl.Coefficients.Estimate(2);
        DOresp_rate_umolkg_day_95CI_high{j}(z) = CI(2,1);
        DOresp_rate_umolkg_day_95CI_low{j}(z) = CI(2,2); 
        b_umolkg{j}(z) = mdl.Coefficients.Estimate(1);
        p_value{j}(z) = mdl.Coefficients.pValue(2);
        R2{j}(z) = mdl.Rsquared.Ordinary;
        regress_days{j}(z) = max(dt_days); 
        Dremin_length_days{j}(z) = max(Dremin_days); 
        DOresp_season_umolkg{j}(z) = mdl.Coefficients.Estimate(2)*Dremin_length_days{j}(z); % rate (slope) *resp_days
        DOresp_season_umolkg_95CI_high{j}(z) = CI(2,1)*Dremin_length_days{j}(z); % rate (slope) *resp_days
        DOresp_season_umolkg_95CI_low{j}(z) = CI(2,2)*Dremin_length_days{j}(z);% rate (slope) *resp_days

        DOresp_season_molm3{j}(z) = (DOresp_season_umolkg{j}(z).*regress_prho{j}(z))/(1000*1000);
        DOresp_season_molm3_95CI_high{j}(z) = (DOresp_season_umolkg_95CI_high{j}(z).*regress_prho{j}(z))/(1000*1000);
        DOresp_season_molm3_95CI_low{j}(z) = (DOresp_season_umolkg_95CI_low{j}(z).*regress_prho{j}(z))/(1000*1000);
    end
end

%% If want 2D plot with outliers during Dstrat removed 
prs_grid = 1:2600;
[X2,Y2] = meshgrid(time,prs_grid);

figure
set(gcf,'position',[100,100,900,300])
scatter(X2(~isnan(DO_out_removed)),Y2(~isnan(DO_out_removed)),5,doxy(~isnan(DO_out_removed)),'filled')
hold on; axis ij; box on
plot(dt,mld_db,'ok','MarkerSize',2,'MarkerFaceColor','k')
ylim([0 2000])
clim([260 320])
datetick('x','yyyy');
xlim([datenum(2015,01,01) datenum(2022,04,01)])
cmocean('dense')
ylabel('Pressure (db)', 'Fontsize', 12); hcb = colorbar; set(hcb,'location','eastoutside')
hcb.Label.String = 'DO (\mumol kg^-^1)';
hcb.FontSize = 12;
ax = gca;
set(ax, 'TickDir', 'out')
ax.FontSize = 12;

%%
close all
depth = 50:1500; % Depths for plot 
figure
for yr = 1:7
    set(gcf,'position',[100,100,1200,400])
    subplot(1,7,yr)
    plot(DOresp_rate_umolkg_day{yr}(depth),depth,'.')
    hold on
    axis ij
    ylabel('Pressure (db)')
    xlabel(['Year: ' num2str(yr)])
    sgtitle('Respiration Rate (\mumol DO kg^-^1 d^-^1): Combined Assets')
    xlim([-0.6 0.04])
    grid on
end

figure
for yr = 1:7
    set(gcf,'position',[100,100,1200,400])
    subplot(1,7,yr)
    plot(regress_days{yr}(depth),depth,'.')
    hold on
    plot(Dremin_length_days{yr}(depth),depth,'.')
    axis ij
    ylabel('Pressure (db)')
    xlabel(['Year: ' num2str(yr)])
    xlim([0 500])
    sgtitle('Length of Regression Window/Dremin (days)')
    grid on
end

figure
for yr = 1:7
    set(gcf,'position',[100,100,1200,400])
    subplot(1,7,yr)
    plot(DOresp_season_molm3{yr}(depth)*-0.69,depth,'.') % Insignifcant or positive R
    hold on
    axis ij
    ylabel('Pressure (db)')
    xlim([0 0.03])
    ylim([0 1500])
    xlabel(['Year: ' num2str(yr)])
    grid on
    sgtitle('Total Respired (mol C m^-^3): Combined Assets')
end

%% Integration 
DOinventory_molm2 = [];
DOinventory_molm2_95CI_high = [];
DOinventory_molm2_95CI_low = [];
Remin0_1 = [1008 1226 980 1240 402 800 1339];
% Remin0_1 = [1008 1226 980 1240 402 800 439];
% Remin0_1 = [1008 1226 980 1240 1000 675 402];
% Remin0_2 = [1060 1253 981 1278 980 797 1405];
Remin0_3 = [1060 1253 981 1278 1014 797 439];

Remin0 = Remin0_1; % Change to look at different Remin0 horizons 
for yr = 1:7

%     % Intergrate using values < 0 and from the surface to Remin 0 
%     use = find(wfp_DOresp_rate_umolkg_day{yr}((1:Remin0(yr))) <=0);
%     use_95CI_high = find(wfp_DOresp_rate_umolkg_day_95CI_high{yr}((1:Remin0(yr))) <= 0); 
%     use_95CI_low = find(wfp_DOresp_rate_umolkg_day_95CI_low{yr}((1:Remin0(yr))) <= 0);
    if yr == 3
        top_cutoff = 213;
    else 
        top_cutoff = 50;
    end
    DOinventory_molm2(yr) = nanmin(cumsum(DOresp_season_molm3{yr}(top_cutoff:Remin0(yr))));
    DOinventory_molm2_95CI_high(yr) = nanmin(cumsum(DOresp_season_molm3_95CI_high{yr}(top_cutoff:Remin0(yr))));
    DOinventory_molm2_95CI_low(yr) = nanmin(cumsum(DOresp_season_molm3_95CI_low{yr}(top_cutoff:Remin0(yr))));

    figure(11)
    set(gcf,'position',[100,100,500,400])
    subplot(1,7,yr)
    plot(cumsum(DOresp_season_molm3{yr}(top_cutoff:Remin0(yr))),top_cutoff:Remin0(yr))
    hold on
%     plot(cumsum(DOresp_season_molm3_95CI_low{yr}(use)),(use))
%     plot(cumsum(DOresp_season_molm3_95CI_high{yr}(use)),(use))
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
grid on
title('Year 7 to 1340 m')
% %%
% cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
% save wfp_respiration.mat wfp* resp