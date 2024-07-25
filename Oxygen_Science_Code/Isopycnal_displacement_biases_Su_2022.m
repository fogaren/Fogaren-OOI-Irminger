addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Jan2024')
load('wfpmerge_output.mat') % Hilary's wggmerge and wggmerge_fl products 
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load Dproduction
wfp_prs = 150:1:2600; % Depths of Hilary's product 

cd('G:\Shared drives\NSF_Irminger\Data_Files\From Meg')
load blended_mld_daily.mat

%%
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

figure
plot(blended_mld_daily_all.time,day_mld,'.k')
hold on
plot(blended_mld_daily_all.time(mld_max_ind),day_mld(mld_max_ind),'*m','MarkerSize',8)
axis ij
grid on
title('Maximum Annual MLDs')
ylabel('MLDs (db)')
xlim([datetime(2015,01,01) datetime(2022,08,15)])
%%
time = [];
wfp_prs_cell = [];%ones(size(wggmerge.pdens));
resp_prho_sm_cell = [];
prho_cell = []; 
method = 'linear';
prho = fillmissing(resp.prho,method,1);
% resp_prho_sm = smoothdata(resp.prho,1,'loess',1,'omitnan','SamplePoints',wfp_prs);
resp_prho_sm = smoothdata(resp.prho,2,'loess',144,'omitnan','SamplePoints',resp.time); %~37.5 day filter

% resp_doxy_sm = smoothdata(resp.doxy,1,'loess',1,'omitnan','SamplePoints',wfp_prs);
% resp_doxy_sm = smoothdata(resp.doxy,2,'loess',45,'omitnan','SamplePoints',resp.time);

% DO = fillmissing(resp.doxy,'nearest',1);
for j = 1:length(resp.time)
    wfp_prs_cell{j} = wfp_prs';
    prho_cell{j} = prho(:,j);
    resp_prho_sm_cell{j} = resp_prho_sm(:,j)-1000;
%     resp_prho_sm_cell{j} = resp.prho(:,j)-1000; % Unsmoothed data 
%     DO_cell{j} = resp_doxy_sm(:,j); % If want to use smoothing from above
%     
    DO_cell{j} = resp.doxy(:,j);
end
%%
close all
vals = 27.4:0.02:28;
figure
set(gcf,'position',[100,100,2000,1000])

for j  = 1:length(mld_max_ind)-1
    Dremin_ind = find(resp.time >= day_dn(mld_max_ind(j)) & resp.time <= day_dn(mld_max_ind(j+1)));
    
    wfp_prs_cell_yr =[];
    prho_cell_yr = [];
    DO_cell_yr =[];
    DO_nan = []; 
    for k = 1:length(Dremin_ind)
        wfp_prs_cell_yr{k} = wfp_prs_cell{Dremin_ind(k)};
        prho_cell_yr{k} = resp_prho_sm_cell{Dremin_ind(k)};
        DO_cell_yr{k} = DO_cell{Dremin_ind(k)};
%         prho_cell_yr{k} = resp.prho(:,Dremin_ind(k));
%         DO_cell_yr{k} = resp.doxy(:,Dremin_ind(k));
    end
    
    subplot(2,4,j)
    f = gca;
    transect(resp.time(Dremin_ind),wfp_prs_cell_yr,DO_cell_yr,'color','none')
    hold on
    transectc(resp.time(Dremin_ind),wfp_prs_cell_yr,prho_cell_yr,vals,'k','linewidth',1.25,'Showtext','on')
    plot(day_dn(mld_max_ind(j):mld_max_ind(j+1)),movmean(day_mld(mld_max_ind(j):mld_max_ind(j+1)),10),'Color',rgb('red'),'Linewidth',2)
    xlim([day_dn(mld_max_ind(j)) day_dn(mld_max_ind(j+1))])
    datetick('x','m','keeplimits')
    clim([265 315])
    ylim([200 2000])
%     cmocean thermal
    title([num2str(2014+j) ' - ' num2str(2015+j)])
    f.FontSize = 14;
    xtickangle(0)
    ylabel('Pressure (db)'); xlabel('Month')
    if j == 7
        c = colorbar;
        ylabel(c,'Dissolved Oxygen (\mumol kg^-^1)','Fontsize',13)
    end
end
%%
z = 1000;
z_ind = find(wfp_prs == z);
figure
for j = 1:length(mld_max_ind)-1
    Dremin_ind = find(resp.time >= day_dn(mld_max_ind(j)) & resp.time <= day_dn(mld_max_ind(j+1)));

    subplot(2,7,j)
    plot(resp.time(Dremin_ind),resp.doxy(z,Dremin_ind),'ok')
    ylim([280 305]); datetick('x','m','keeplimits')
    ylabel('DO (\mumol/kg)')
    title([num2str(2014+j) ' - ' num2str(2015+j)])
    grid on
    subplot(2,7,j+7)
    plot(resp.time(Dremin_ind),resp.prho(z,Dremin_ind),'ok')
    ylim([1027.75 1027.78]); datetick('x','m','keeplimits')
    grid on
    ylabel('prho (kg/m^3)')
    
end
figs = 1;
mdlDO = [];
mdlprho = [];
for yr = 8 % Deployment Year 
n = 0 
    for z = 1000 % 175:2000
        z_ind = find(wfp_prs == z); % Finds the index of that depth
        regress_ind = regress_resp{z}.start(yr)+n:regress_resp{z}.end(yr); 
        dt_days = resp.time(regress_ind) - resp.time(regress_resp{z}.start(yr));

        temp_detrended = detrend(resp.temp(z_ind,regress_ind),'omitnan');
        bad_temp = isoutlier(temp_detrended,'quartiles','SamplePoints',resp.time(regress_ind));
        prho_detrended = detrend(resp.prho(z_ind,regress_ind),'omitnan');
        bad_prho = isoutlier(prho_detrended,'quartiles','SamplePoints',resp.time(regress_ind));
        doxy_detrended = detrend(resp.doxy(z_ind,regress_ind),'omitnan');
        bad_doxy = isoutlier(doxy_detrended,'quartiles','SamplePoints',resp.time(regress_ind));
        if yr == 9
%             mdl = fitlm(dt_days(bad_prho == 0),resp.doxy(z_ind,regress_ind(bad_prho == 0)));
            mdlDO{yr} = fitlm(dt_days,resp.doxy(z_ind,regress_ind));
            mdlprho{yr} = fitlm(dt_days,resp.prho(z_ind,regress_ind));
%             mdl = fitlm(dt_days,resp.doxy(z_ind,regress_ind));
        else
%             mdl = fitlm(dt_days(bad_temp == 0 & bad_doxy == 0),resp.doxy(z_ind,regress_ind(bad_temp == 0 & bad_doxy == 0)));
            mdlDO{yr} = fitlm(dt_days(bad_prho == 0 & bad_doxy == 0),resp.doxy(z_ind,regress_ind(bad_prho == 0 & bad_doxy == 0)));
            mdlprho{yr} = fitlm(dt_days(bad_prho == 0 & bad_doxy == 0),resp.prho(z_ind,regress_ind(bad_prho == 0 & bad_doxy == 0)));

%                         mdl = fitlm(dt_days,resp.doxy(z_ind,regress_ind));
        end

%             figure(1)
%             plot(dt_days,resp.doxy(z_ind,(regress_resp{z}.start(yr)):regress_resp{z}.end(yr)),'ok','MarkerFaceColor','k')
%             grid on
%             title(['Depth = ' num2str(z) ' Year = ' num2str(yr)])
        if figs == 1
            figure %(2)
            clf
            subplot(2,1,1)
            plot(resp.time(regress_resp{z}.start(yr)-50:regress_resp{z}.end(yr)+0),...
                resp.doxy(z_ind,regress_resp{z}.start(yr)-50:regress_resp{z}.end(yr)+0),'ok','MarkerFaceColor','k')
            hold on
            plot(resp.time(regress_resp{z}.start(yr)+n:regress_resp{z}.end(yr)),...
                resp.doxy(z_ind,regress_resp{z}.start(yr)+n:regress_resp{z}.end(yr)),'ok','MarkerFaceColor','b')
            plot(resp.time(regress_ind(bad_doxy == 1)),...
                resp.doxy(z_ind,regress_ind(bad_doxy ==1)),'ok','MarkerFaceColor','y')
            plot(resp.time(regress_ind(bad_prho == 1)),...
                resp.doxy(z_ind,regress_ind(bad_prho ==1)),'or','Linewidth',1.2)
            grid on
            ylabel('Oxygen')
            legend('All data','Data below ML','Oxygen Outlier','Density Outlier','Orientation','horizontal','Location','northeast')
            datetick
            
            subplot(2,1,2)
            plot(resp.time(regress_resp{z}.start(yr)-50:regress_resp{z}.end(yr)+0),...
                resp.prho(z_ind,regress_resp{z}.start(yr)-50:regress_resp{z}.end(yr)+0),'ok','MarkerFaceColor','k')
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
    end
end