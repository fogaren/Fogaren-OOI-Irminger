clearvars; close all
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Jan2024')
load glider_griddall.mat
load wfpmerge_output.mat
wfp_prs = 150:1:2600;
glider_prs = 1:1000;
glider = glidergrid;

cd('G:\Shared drives\NSF_Irminger\Data_Files\From Meg')
load blended_mld_daily.mat blended_mld_daily_all
% rename meg's updated variables for my code 
dt = datenum(blended_mld_daily_all.time);
mld_db = blended_mld_daily_all.mld;
clear blended_mld_daily_all 

addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')

load Dproduction.mat % load start and end of D-production period on each isobar
%%
for j = 1:13
    glider{j}.time_dt = datetime(glider{j}.time,'ConvertFrom','datenum');
    glider{j}.doxy_sm = smoothdata(glider{j}.doxy,2,'loess',days(90),'omitnan','SamplePoints',glider{j}.time_dt);
end
resp.doxy_sm = smoothdata(resp.doxy,2,'loess',days(270),'omitnan','SamplePoints',resp.time_dt);
%% Not so quick and dirty plot of glider and WFP data 
% This should be updated to optimize seams between the different assets 
k = [3 4 6 8 10 13];

[X2,Y2] = meshgrid(resp.time,wfp_prs);

figure(1)
set(gcf,'position',[100,100,1200,300])
f = gca;
scatter(X2(~isnan(resp.doxy)),Y2(~isnan(resp.doxy)),[],resp.doxy(~isnan(resp.doxy)),'filled')
hold on
ylim([0 2000])
clim([275 350])
axis ij
xlim([datenum(2015,01,01) datenum(2022,04,01)])
datetick('x','Keeplimits')
for j = 1:length(k)
    [X1,Y1] = meshgrid(glider{k(j)}.time,glider_prs); 

    figure(1)
    scatter(X1(~isnan(glider{k(j)}.doxy)),Y1(~isnan(glider{k(j)}.doxy)),[],glider{k(j)}.doxy(~isnan(glider{k(j)}.doxy)),'filled')
    shading interp
    hold on
end
ylim([0 2000])
c = colorbar;
c.Label.String = 'DO (\mumol kg ^-^1)';
% cmocean('-dense')
plot(dt,mld_db,'k','Linewidth',1.5)
f.FontSize = 14; 
%%
%% Scatter plot with WFP data

sz = 1;
ymax = 2000;

f = figure;
f.Position = [100 100 1200 400];
C = cmocean('dense'); %set colormap
[X,Y] = meshgrid(wggmerge.time, pres_grid_hypm);
scatter(X(:),Y(:),5,wggmerge.doxy(:),'filled'); hold on;
% scatter(X(:),Y(:),5,prho_wfp(:),'filled'); hold on;
% plot(blended_mld_all.dn,blended_mld_all.mld,'k','Linewidth',1.4)
axis ij; axis tight; 
% xlim([datenum(2015,1,1) datenum(2022,1,1)]);
ylim([0 ymax]);
colormap(C); 
ylabel('Pressure (db)', 'Fontsize', 13); hcb = colorbar; set(hcb,'location','eastoutside')
datetick('x',2,'keeplimits');
clim([270 320])
% clim([1027.6 1027.95])
% title('OOI WFP oxygen concentration', 'Fontsize', 14)
hcb.Label.String = 'DO (\mumol kg^-^1)';
hcb.FontSize = 13;
box on
ax = gca;
set(ax, 'TickDir', 'out')
ax.FontSize = 13;
k = [3 4 6 8 10 13];

for j = 1:length(k)
    [X1,Y1] = meshgrid(glider{k(j)}.time,glider_prs); 

    scatter(X1(~isnan(glider{k(j)}.doxy)),Y1(~isnan(glider{k(j)}.doxy)),5,glider{k(j)}.doxy(~isnan(glider{k(j)}.doxy)),'filled')
    shading interp
    hold on
end

plot(dt,mld_db,'ok','MarkerSize',2,'MarkerFaceColor','k')
xlim([datenum(2015,01,01) datenum(2022,01,01)])
%% Backscatter spikes 


[X2,Y2] = meshgrid(wggmerge_fl.time,wfp_prs);
    figure
    set(gcf,'position',[100,100,1200,300])
f = gca;
% scatter(X2(~isnan(wggmerge_fl.spikes)),Y2(~isnan(wggmerge_fl.spikes)),[],wggmerge_fl.spikes(~isnan(wggmerge_fl.spikes)),'filled')
% % pcolor(X2,Y2,wggmerge_fl.spikes);
% hold on
% shading interp
plot(dt,mld_db,'ok','MarkerSize',3,'MarkerFaceColor','k')
% clim([0 7E-5])
% cmocean('algae')
axis ij
xlim([datenum(2015,01,01) datenum(2021,10,01)])
datetick('x','keeplimits')
% c = colorbar;
ylim([200 2000])
f.FontSize = 13; 
ylabel('Pressure (db)')
% title('Backscatter Spikes (Large Particles)')
legend('mixed layer depth','Location','SE')
%% CHL- Mixed Layer Plot 
run('GeneralSettings.m')
cd('G:\My Drive\Matlab_work\Github\Meg_Irminger_Review')
load chl_clean.mat

% close all 
    figure(2)
    set(gcf,'position',[100,100,1200,200])

f = gca;
for j = 1:4
    for k = 2:8

    figure(2)
    plot(chl_final{j}{k}.time,chl_final{j}{k}.data,'.','Color',forestgreen,'MarkerSize',8)
    hold on
    end
end
grid on
datetick('x','yyyy')
% ylabel({'mixed layer'  'chl-a' '(\mug L^-^1)'},'Fontsize',14)
ylabel({'chl-a' '(\mug L^-^1)'},'Fontsize',12)
f.FontSize = 12;
xlim([datenum(2015,01,01) datenum(2021,10,01)])
xlim([datenum(2015,01,01) datenum(2022,04,01)])
% title('Mixed Layer Chlorophyll-a Concentration')
%% Blank depth schematic
dt_test = datenum(2022,06,01):datenum(2023,06,01);
figure
axes1 = gca;
set(gcf,'position',[100,100,1400,500])
plot(dt_test,1,'o','Color','none')
ylim([0 2200])
axis ij
set(axes1,'YTick',[0 200 400 600 1000 1400 1800 2200],...
    'YTickLabel',...
    {'0','50','100','250','500','1000','1500','2000'});
xlim([dt_test(1) dt_test(end)])
axes1.FontSize = 14;
datetick('x','Keeplimits')
ylabel('Depth (m)')

%% Load workspace 
clearvars; close all
% cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Sept2023')
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Jan2024')
load('wfpmerge_output.mat') % Hilary's wggmerge and wggmerge_fl products 
wfp_prs = 150:1:2600; % Depths of Hilary's product 

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load Dproduction.mat 
load blended_MLD_prelim_final.mat 
cd('G:\My Drive\Matlab_work\BC')
run('GeneralSettings.m')

addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))

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
yr = 2; % Deployment year 

z1 = 250; 
z2 = 500; 
z3 = 750;

z1_ind = find(wfp_prs == z1); % Finds the index of that depth
regress_ind_z1 = regress_resp{z1}.start(yr):regress_resp{z1}.end(yr); 
% dt_days = resp.time(regress_ind_z1) - resp.time(regress_resp{z1}.start(yr));

temp_detrended = detrend(resp.temp(z1_ind,regress_ind_z1),'omitnan');
bad_temp_z1 = isoutlier(temp_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z1));
prho_detrended = detrend(resp.prho(z1_ind,regress_ind_z1),'omitnan');
bad_prho_z1 = isoutlier(prho_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z1));
doxy_detrended = detrend(resp.doxy(z1_ind,regress_ind_z1),'omitnan');
bad_doxy_z1 = isoutlier(doxy_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z1));

mdl_z1 = fitlm(resp.time(regress_ind_z1(bad_prho_z1 == 0 & bad_doxy_z1 == 0)),resp.doxy(z1_ind,regress_ind_z1(bad_prho_z1 == 0 & bad_doxy_z1 == 0)));

z2_ind = find(wfp_prs == z2); % Finds the index of that depth
regress_ind_z2 = regress_resp{z2}.start(yr):regress_resp{z2}.end(yr); 
% dt_days = resp.time(regress_ind_z2) - resp.time(regress_resp{z2}.start(yr));

temp_detrended = detrend(resp.temp(z2_ind,regress_ind_z2),'omitnan');
bad_temp_z2 = isoutlier(temp_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z2));
prho_detrended = detrend(resp.prho(z2_ind,regress_ind_z2),'omitnan');
bad_prho_z2 = isoutlier(prho_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z2));
doxy_detrended = detrend(resp.doxy(z2_ind,regress_ind_z2),'omitnan');
bad_doxy_z2 = isoutlier(doxy_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z2));

mdl_z2 = fitlm(resp.time(regress_ind_z2(bad_prho_z2 == 0 & bad_doxy_z2 == 0)),resp.doxy(z2_ind,regress_ind_z2(bad_prho_z2 == 0 & bad_doxy_z2 == 0)));

z3_ind = find(wfp_prs == z3); % Finds the index of that depth
regress_ind_z3 = regress_resp{z3}.start(yr):regress_resp{z3}.end(yr); 
% dt_days = resp.time(regress_ind_z3) - resp.time(regress_resp{z3}.start(yr));

temp_detrended = detrend(resp.temp(z3_ind,regress_ind_z3),'omitnan');
bad_temp_z3 = isoutlier(temp_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z3));
prho_detrended = detrend(resp.prho(z3_ind,regress_ind_z3),'omitnan');
bad_prho_z3 = isoutlier(prho_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z3));
doxy_detrended = detrend(resp.doxy(z3_ind,regress_ind_z3),'omitnan');
bad_doxy_z3 = isoutlier(doxy_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z3));

mdl_z3 = fitlm(resp.time(regress_ind_z3(bad_prho_z3 == 0 & bad_doxy_z3 == 0)),resp.doxy(z3_ind,regress_ind_z3(bad_prho_z3 == 0 & bad_doxy_z3 == 0)));

figure
set(gcf,'position',[100,100,800,800])
days_pad = 100; 
ax1 = subplot(3,1,1);
plot(resp.time(regress_resp{z1}.start(yr)-days_pad:regress_resp{z1}.end(yr)+days_pad),...
    resp.doxy(z1_ind,regress_resp{z1}.start(yr)-days_pad:regress_resp{z1}.end(yr)+days_pad),'o','Color','none','MarkerFaceColor',grey)
hold on
plot(resp.time(regress_ind_z1),...
    resp.doxy(z1_ind,regress_ind_z1),'o','Color','none','MarkerFaceColor',blue)
plot(resp.time(regress_ind_z1(bad_prho_z1 == 1| bad_doxy_z1 == 1)),...
    resp.doxy(z1_ind,regress_ind_z1(bad_prho_z1 == 1 | bad_doxy_z1 == 1)),'o','Color','none','MarkerFaceColor',red)
% plot(resp.time(regress_ind_z1(bad_prho_z1 == 0| bad_doxy_z1 == 0)),...
%     resp.doxy(z1_ind,regress_ind_z1(bad_prho_z1 == 0| bad_doxy_z1 == 0)),'o','Color','none','MarkerFaceColor',blue)
plot([resp.time(regress_ind_z1(1)) resp.time(regress_ind_z1(end))],[(resp.time(regress_ind_z1(1))*mdl_z1.Coefficients.Estimate(2) + mdl_z1.Coefficients.Estimate(1)) (resp.time(regress_ind_z1(end))*mdl_z1.Coefficients.Estimate(2) + mdl_z1.Coefficients.Estimate(1))],'k','Linewidth',2)
grid on
ylabel('\mumol kg^-^1')
ax1.FontSize = 14;
datetick
title(['Oxygen at ' num2str(z1) ' db'])

days_pad = 50; 
ax2 = subplot(3,1,2);
plot(resp.time(regress_resp{z2}.start(yr)-days_pad:regress_resp{z2}.end(yr)+days_pad),...
    resp.doxy(z2_ind,regress_resp{z2}.start(yr)-days_pad:regress_resp{z2}.end(yr)+days_pad),'o','Color','none','MarkerFaceColor',grey)
hold on
plot(resp.time(regress_ind_z2),...
    resp.doxy(z2_ind,regress_ind_z2),'o','Color','none','MarkerFaceColor',blue)
plot(resp.time(regress_ind_z2(bad_prho_z2 == 1| bad_doxy_z2 == 1)),...
    resp.doxy(z2_ind,regress_ind_z2(bad_prho_z2 == 1 | bad_doxy_z2 == 1)),'o','Color','none','MarkerFaceColor',red)
plot([resp.time(regress_ind_z2(1)) resp.time(regress_ind_z2(end))],[(resp.time(regress_ind_z2(1))*mdl_z2.Coefficients.Estimate(2) + mdl_z2.Coefficients.Estimate(1)) (resp.time(regress_ind_z2(end))*mdl_z2.Coefficients.Estimate(2) + mdl_z2.Coefficients.Estimate(1))],'k','Linewidth',2)
grid on
ylabel('\mumol kg^-^1')
datetick
ax2.FontSize = 14;
title(['Oxygen at ' num2str(z2) ' db'])


days_pad = 30; 
ax3 = subplot(3,1,3);
plot(resp.time(regress_resp{z3}.start(yr)-days_pad:regress_resp{z3}.end(yr)+days_pad),...
    resp.doxy(z3_ind,regress_resp{z3}.start(yr)-days_pad:regress_resp{z3}.end(yr)+days_pad),'o','Color','none','MarkerFaceColor',grey)
hold on
plot(resp.time(regress_ind_z3),...
    resp.doxy(z3_ind,regress_ind_z3),'o','Color','none','MarkerFaceColor',blue)
plot(resp.time(regress_ind_z3(bad_prho_z3 == 1| bad_doxy_z3 == 1)),...
    resp.doxy(z3_ind,regress_ind_z3(bad_prho_z3 == 1 | bad_doxy_z3 == 1)),'o','Color','none','MarkerFaceColor',red)
plot([resp.time(regress_ind_z3(1)) resp.time(regress_ind_z3(end))],[(resp.time(regress_ind_z3(1))*mdl_z3.Coefficients.Estimate(2) + mdl_z3.Coefficients.Estimate(1)) (resp.time(regress_ind_z3(end))*mdl_z3.Coefficients.Estimate(2) + mdl_z3.Coefficients.Estimate(1))],'k','Linewidth',2)
grid on
ylabel('\mumol kg^-^1')
datetick
title(['Oxygen at ' num2str(z3) ' db'])
ax3.FontSize = 14;
linkaxes([ax3 ax2 ax1],'xy')
legend('in the mixed layer','below the mixed layer','density outlier','Location','southoutside','Orientation','horizontal')
xlim([resp.time(regress_resp{z3}.start(yr))-days_pad resp.time(regress_resp{z3}.end(yr))+days_pad])
%%
clearvars; close all
cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\Oxygen_Science_Code')
run('Glider_WFP_Resp_working_ver2.m')
%%
close all
for yr = 1:7 % Science year 
    glid_top = 50; wfp_bottom = 1500;
    figure(1)
    subplot(1,7,yr)
    set(gcf,'position',[50,50,1400,600])
    ax = gca;
    % plot(DOresp_rate_umolkg_day{yr}(glid_top:wfp_bottom),(glid_top:wfp_bottom),'k')
    % hold on
    if yr ~= 3
        boundedline(DOresp_rate_umolkg_day{yr}(glid_top:wfp_bottom),(glid_top:wfp_bottom),...
            DOresp_rate_umolkg_day_95CI_high{yr}(glid_top:wfp_bottom) -DOresp_rate_umolkg_day{yr}(glid_top:wfp_bottom),'orientation','horiz','alpha')
    end
    if yr == 3
        boundedline(DOresp_rate_umolkg_day{yr}(200:wfp_bottom),(200:wfp_bottom),...
            DOresp_rate_umolkg_day_95CI_high{yr}(200:wfp_bottom) -DOresp_rate_umolkg_day{yr}(200:wfp_bottom),'orientation','horiz','alpha')   
    end
    if yr == 1
            ylabel('Pressure (db)')
    end
    axis ij

    xlim([-0.6 0])
    grid on
    ax.XAxisLocation = 'top';
    title([num2str(2014+yr) ' - ' num2str(2015+yr)])
    ylim([0 1200])
    ax.FontSize = 13;
    box on
end
    sgtitle('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
mycolors = [maroon; red; yellow; green; navy; purple; brightpurple];
for yr = 1:7
    glid_top = 50; wfp_bottom = 1500;
    figure(2)
    set(gcf,'position',[50,50,1400,600])
    ax = gca;
    % plot(DOresp_rate_umolkg_day{yr}(glid_top:wfp_bottom),(glid_top:wfp_bottom),'k')
    % hold on
    if yr ~= 3
    b =  boundedline(DOresp_rate_umolkg_day{yr}(glid_top:wfp_bottom),(glid_top:wfp_bottom),...
            DOresp_rate_umolkg_day_95CI_high{yr}(glid_top:wfp_bottom) -DOresp_rate_umolkg_day{yr}(glid_top:wfp_bottom),'orientation','horiz','alpha');
    b.Color = mycolors(yr,:);
    end
    if yr == 3
        boundedline(DOresp_rate_umolkg_day{yr}(200:wfp_bottom),(200:wfp_bottom),...
            DOresp_rate_umolkg_day_95CI_high{yr}(200:wfp_bottom) -DOresp_rate_umolkg_day{yr}(200:wfp_bottom),'orientation','horiz','alpha')   
    end
    if yr == 1
            ylabel('Pressure (db)')
    end
    axis ij

    xlim([-0.6 0])
    grid on
    ax.XAxisLocation = 'top';
    title([num2str(2014+yr) ' - ' num2str(2015+yr)])
    ylim([0 1200])
    ax.FontSize = 13;
    box on
end
%% Respiration Rate versus depth for Year 1: Method Example 
close all
yr = 1; % Science year 
glid_top = 50; wfp_bottom = remin0_depth{yr};
figure
set(gcf,'position',[50,50,450,600])
ax = gca;
boundedline(DOresp_rate_umolkg_day{yr}(glid_top:wfp_bottom)*-0.69,(glid_top:wfp_bottom),...
        DOresp_rate_umolkg_day_95CI_high{yr}(glid_top:wfp_bottom)*-0.69 -DOresp_rate_umolkg_day{yr}(glid_top:wfp_bottom)*-0.69,'orientation','horiz','alpha')   
axis ij
ylabel('Pressure (db)')
xlim([0 0.5])
grid on
ax.XAxisLocation = 'top';
title({'Respiration Rate' ...
'(\mumol C kg^-^1 d^-^1)'})
legend('95% confidence intervals','Location','SE','Box','off')
ax.FontSize = 15;
ylim([0 1500])
box on
%%  
figure
set(gcf,'position',[50,50,450,600])
plot(regress_length_days{yr}(1:2000),1:2000,'Color',blue,'Linewidth',2)
axis ij
ylabel('Pressure (db)')
grid on
title({'Time below mixed layer'...
    '(days)'})
ax = gca;
ax.FontSize = 15;
ax.XAxisLocation = 'top';
xlim([0 500])
ylim([0 1500])
%%
figure
set(gcf,'position',[50,50,450,600])
    boundedline(DOresp_season_umolkg{yr}(glid_top:wfp_bottom)*-0.69,(glid_top:wfp_bottom),...
        DOresp_season_umolkg_95CI_high{yr}(glid_top:wfp_bottom)*-0.69 - DOresp_season_umolkg{yr}(glid_top:wfp_bottom)*-0.69,'orientation','horiz','alpha')  
axis ij
ylabel('Pressure (db)')
legend('95% confidence intervals','Location','SE','Box','off')
xlim([0 40]);
grid on
    title({'Carbon Respired' ...
    '(\mumol C kg^-^1 yr^-^1)'})
box on
ax =gca;
ax.XAxisLocation = 'top';
ax.FontSize = 15;
ylim([0 1500])

%% Respiration Rate versus depth for all Years 
close all
figure
    for yr = 1:7 % Science year 
    glid_top = 50; wfp_bottom = 1200;
        if yr == 3 
            glid_top = 200; 
        end
        set(gcf,'position',[50,50,1200,600])
        subplot(1,7,yr)
        ax = gca;
        boundedline(DOresp_rate_umolkg_day{yr}(glid_top:wfp_bottom)*-0.69,(glid_top:wfp_bottom),...
                DOresp_rate_umolkg_day_95CI_high{yr}(glid_top:wfp_bottom)*-0.69 -DOresp_rate_umolkg_day{yr}(glid_top:wfp_bottom)*-0.69,'orientation','horiz','alpha')   
        axis ij
        ylabel('Pressure (db)')
        xlim([0 0.5])
        ylim([0 1200])
        grid on
        ax.XAxisLocation = 'top';
        sgtitle({'Respiration Rate (\mumol C kg^-^1 d^-^1)'})
        title([num2str(2014+yr) ' - ' num2str(2015+yr)])
        % legend('95% confidence intervals','Location','SE','Box','off')
        ax.FontSize = 15;
        box on
    end
%%
close all
figure
        set(gcf,'position',[50,50,450,600])
        ax = gca;
for yr = 1:7
        glid_top = 50; wfp_bottom = remin0_depth{yr};
        if yr == 3 
            glid_top = 200; 
        end
        if yr == 5 
            wfp_bottom = 425; 
        end
        plot(DOresp_rate_umolkg_day{yr}(glid_top:wfp_bottom)*-0.69,(glid_top:wfp_bottom),'Linewidth',2)
        hold on
                axis ij
        ylabel('Pressure (db)')
        xlim([0 0.5])
        ylim([0 1500])
        grid on
        ax.XAxisLocation = 'top';
        title({'Respiration Rate'...
            '(\mumol C kg^-^1 d^-^1)'})
        ax.FontSize = 15;
        box on
end

%%  

figure
set(gcf,'position',[50,50,450,600])
wfp_bottom = 1500;
for yr = 1:7
    plot(regress_length_days{yr}(1:wfp_bottom),1:wfp_bottom,'Linewidth',2)
    axis ij
    ylabel('Pressure (db)')
    grid on
    title({'Time below mixed layer'...
        '(days)'})
    ax = gca;
    ax.FontSize = 15;
    ax.XAxisLocation = 'top';
    hold on
    ylim([0 1500])
end
%%
figure
set(gcf,'position',[50,50,450,600])
for yr = 1:7
        glid_top = 50; wfp_bottom = remin0_depth{yr};
        if yr == 3 
            glid_top = 200; 
        end
    plot(DOresp_season_umolkg{yr}(glid_top:wfp_bottom)*-0.69,(glid_top:wfp_bottom),'Linewidth',2)  
    axis ij
    ylabel('Pressure (db)')
    xlim([0 40]);
    grid on
    title({'Carbon Respired' ...
    '(\mumol C kg^-^1 yr^-^1)'})
    box on
    ax =gca;
    ax.XAxisLocation = 'top';
    ax.FontSize = 15;
    hold on
end
legend('2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022','Location','SE')
%%
wfp_bottom = 1500;
close all
for yr = 1:7
    figure
    set(gcf,'position',[50,50,300,500])
    ax = gca;
    if yr ~= 3
        if yr ~=5
        boundedline(DOresp_season_umolkg{yr}(glid_top:wfp_bottom),(glid_top:wfp_bottom),...
            DOresp_season_umolkg_95CI_high{yr}(glid_top:wfp_bottom) - DOresp_season_umolkg{yr}(glid_top:wfp_bottom),'orientation','horiz','alpha')
    
        end
    end
    if yr == 3
        boundedline(DOresp_season_umolkg{yr}(200:1000),(200:1000),...
            DOresp_season_umolkg_95CI_high{yr}(200:1000) - DOresp_season_umolkg{yr}(200:1000),'orientation','horiz','alpha')
    end 
    if yr == 5
        boundedline(DOresp_season_umolkg{yr}(glid_top:450),(glid_top:450),...
            DOresp_season_umolkg_95CI_high{yr}(glid_top:450) - DOresp_season_umolkg{yr}(glid_top:450),'orientation','horiz','alpha')
    end
    axis ij
    ylabel('Pressure (db)')
    xlim([-50 0]); ylim([0 1500]); grid on
    xlabel({'Oxygen Respired' ...
    '(mol DO m^3)'})
    ax.XAxisLocation = 'top';
    ax.FontSize = 14;
    box on
    title([num2str(2014+yr) ' - ' num2str(2015+yr)])

end
%%
cd('G:\Shared drives\NSF_Irminger\Data_Files\From Meg')
load blended_mld_daily.mat blended_mld_daily_all
% rename meg's updated variables for my code 
dt = datenum(blended_mld_daily_all.time);
mld_db = blended_mld_daily_all.mld;
clear blended_mld_daily_all 

%%
figure
set(gcf,'position',[50,50,1800,300])
ax = gca;
plot(dt,movmean(mld_db,7),'.k')
ylim([0 2000])
axis ij
grid on
ax.FontSize = 13;
datetick
xlim([datenum(2015,01,01) datenum(2022,06,01)])
ylabel('Pressure (db)')
title('Mixed Layer Depths')



