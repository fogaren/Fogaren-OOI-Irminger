%% Output numbers of interst 

display(['Remin0 = ' num2str(Remin0)])
display(['MLDmax = ' num2str(MLD_winter_max')])
display(['Dremin max = ' num2str(Dremin_max_length_days)])
display(['Export mean w/ projected Yr 3 = ' num2str(mean([export_Cinventory_molm2(1:2) Cinventory_Yr3_projected export_Cinventory_molm2(4:7)])) ' +- ' num2str(std([export_Cinventory_molm2(1:2) Cinventory_Yr3_projected export_Cinventory_molm2(4:7)]))])
display(['Export mean 1 to 3 proj = ' num2str(mean([export_Cinventory_molm2(1:2) Cinventory_Yr3_projected])) ' +- ' num2str(std([export_Cinventory_molm2(1:2) Cinventory_Yr3_projected]))])
display(['Export mean 4 to 7 = ' num2str(mean(export_Cinventory_molm2(4:7))) ' +- ' num2str(std(export_Cinventory_molm2(4:7)))])
display(['Reventilated mean proj  = ' num2str(mean([revent_Cinventory_molm2(1:2) Cinventory_Yr3_projected revent_Cinventory_molm2(4:7)])) ' +- ' num2str(std([revent_Cinventory_molm2(1:2) Cinventory_Yr3_projected revent_Cinventory_molm2(4:7)]))])
sequest_Cinventory_molm2(isnan(sequest_Cinventory_molm2)) = 0; % overwrite years with no Csequest with 0 for calc mean 
display(['Sequestered mean = ' num2str(mean(sequest_Cinventory_molm2)) ' +- ' num2str(std(sequest_Cinventory_molm2))])
display(['Export range = ' num2str(min(export_Cinventory_molm2)) ' - ' num2str(max(export_Cinventory_molm2))])
display(['Vent range = ' num2str(min(revent_Cinventory_molm2)) ' - ' num2str(max(revent_Cinventory_molm2))])
display(['Sequest range = ' num2str(min(sequest_Cinventory_molm2)) ' - ' num2str(max(sequest_Cinventory_molm2))])
display(['Revent % range = ' num2str(min(revent_Cinventory_molm2./export_Cinventory_molm2)*100) ' - ' num2str(max(revent_Cinventory_molm2./export_Cinventory_molm2)*100)])
%%
% Add necessary toolboxes
addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))
run('GeneralSettings.m') %for plotting 
% %% Figure 2
blended_mld_daily_all.dn = datenum(blended_mld_daily_all.time);
figure
% plot(blended_mld_daily_all.dn,blended_mld_daily_all.mld,'ok','MarkerSize',2,'MarkerFaceColor','k')
plot(blended_mld_daily_all.dn,blended_mld_daily_all.mld,'-.','Color',blue)
hold on
% plot([blended_mld_daily_all.dn(1) blended_mld_daily_all.dn(end)],[200 200],'k--')
axis ij
ylim([100 400])
grid on
%
%% Oxygen timeseries with mixed layer depths 
prs_grid = 1:2600;
[X2,Y2] = meshgrid(daily.time,prs_grid);

figure
set(gcf,'position',[100,100,900,300])
scatter(X2(~isnan(daily.doxy)),Y2(~isnan(daily.doxy)),5,daily.doxy(~isnan(daily.doxy)),'filled')
hold on; axis ij; box on
plot(blended_mld_daily_all.dn,blended_mld_daily_all.mld,'ok','MarkerSize',2,'MarkerFaceColor','k')
for j = 1:length(mld_max_ind)-1
%     plot(dt(mld_max_ind(j):mld_max_ind(j+1)),ones(1,length(mld_max_ind(j):mld_max_ind(j+1)))*1800,'k')
    dt_text = round((mld_max_ind(j+1) - mld_max_ind(j))/2) + mld_max_ind(j);
    text(blended_mld_daily_all.dn(dt_text)-108,1900,['Year ' num2str(j)],'Fontsize',12,'FontWeight','bold')
end
for j = 1:length(mld_max_ind)
    plot(blended_mld_daily_all.dn(mld_max_ind(j))*ones(201,1),1800:2000,'k','Linewidth',2)
end
ylim([0 2000])
clim([260 320])
datetick('x','yyyy');
xlim([datenum(2015,01,01) datenum(2022,04,01)])
cmocean('dense')
ylabel('Pressure (dbar)', 'Fontsize', 12); hcb = colorbar; set(hcb,'location','eastoutside')
hcb.Label.String = 'DO (\mumol kg^-^1)';
hcb.FontSize = 12;
ax = gca;
set(ax, 'TickDir', 'out')
ax.FontSize = 12;

%% Backscatter timeseries with mixed layer depths 
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('wfpmerge_output_fixedPc1600db.mat','wggmerge_fl');

wfp_prs = 150:1:2600; % Depths of Hilary's product

[X2,Y2] = meshgrid(wggmerge_fl.time,wfp_prs);
spikes = wggmerge_fl.spikes;

figure
set(gcf,'position',[100,100,900,300])
% scatter(X2(~isnan(wggmerge_fl.spikes)),Y2(~isnan(wggmerge_fl.spikes)),5,wggmerge_fl.spikes(~isnan(wggmerge_fl.spikes)),'filled')
scatter(X2(~isnan(spikes)),Y2(~isnan(spikes)),2,wggmerge_fl.spikes(~isnan(spikes)),'filled')
hold on; axis ij; box on
plot(blended_mld_daily_all.dn,blended_mld_daily_all.mld,'ok','MarkerSize',2,'MarkerFaceColor','k')
% for j = 1:length(mld_max_ind)-1
% %     plot(dt(mld_max_ind(j):mld_max_ind(j+1)),ones(1,length(mld_max_ind(j):mld_max_ind(j+1)))*1800,'k')
%     dt_text = round((mld_max_ind(j+1) - mld_max_ind(j))/2) + mld_max_ind(j);
%     text(blended_mld_daily_all.dn(dt_text)-108,2100,['Year ' num2str(j)],'Fontsize',12,'FontWeight','bold')
% end
% for j = 1:length(mld_max_ind)
%     plot(blended_mld_daily_all.dn(mld_max_ind(j))*ones(201,1),2000:2200,'k','Linewidth',2)
% end
ylim([0 2000])
clim([0 7E-5])
datetick('x','yyyy');
xlim([datenum(2015,01,01) datenum(2022,04,01)])
cmocean('algae')
ylabel('Pressure (dbar)', 'Fontsize', 12); hcb = colorbar; set(hcb,'location','eastoutside')
hcb.Label.String = 'DO (\mumol kg^-^1)';
hcb.FontSize = 12;
ax = gca;
set(ax, 'TickDir', 'out')
ax.FontSize = 12;

% clear wggmerge_fl
%% Remin0 versus previous year maximum ML depth
colorblind = [0 0.61961 0.45098; 0 0.44706 0.69804; 0.33725 0.70588 0.91373; 0.94118 0.89412 0.25882;...
    0.90196 0.62353 0; 0.83529 0.36863 0; 0.8 0.47451 0.6549];

close all
figure

for yr = 1:7
    plot(day_mld(mld_max_ind(yr)),Remin0(yr),'.','Color',colorblind(yr,:),'MarkerSize',30)
    hold on
end
plot(day_mld(mld_max_ind(1:6)),Remin0(1:6),'Color','none')
l = legend('2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022','Location','southeast');
% l.Title.String = 'Remineralization Year';
daspect([1 1 1])
axis([400 1500 400 1500])
grid on
ylabel('Z_r_e_m_i_n_0 (dbar)')
xlabel('Max MLD of previous winter (dbar)')

%% Remineralization Rates and Dremin for each year
Cresp_rate_umolkg_day_mean = mean(DOresp_rate_umolkg_day_all*-0.69,2,'omitnan');
Cresp_rate_umolkg_day_std = std(DOresp_rate_umolkg_day_all*-0.69,0,2,'omitnan');

figure
set(gcf,'position',[100,100,800,500])
subplot(1,2,1)
for yr = 1:7
    if yr == 3
        l = plot(movmean(DOresp_rate_umolkg_day{yr}(208:Remin0(yr))*-0.69,25),208:Remin0(yr),'Linewidth',2.25);
    end
    if yr ~=3
        l = plot(movmean(DOresp_rate_umolkg_day{yr}(50:Remin0(yr))*-0.69,25),50:Remin0(yr),'Linewidth',2.25);
    end
    hold on
    l.Color = colorblind(yr,:);
end
axis ij
grid on
plot(movmean(Cresp_rate_umolkg_day_mean(50:1161),25),50:1161,'-.','Color',[0 0 0 1],'Linewidth',2.25);
hold on
% plot(movmean(Cresp_rate_umolkg_day_mean(50:1161)-Cresp_rate_umolkg_day_std(50:1161),50),50:1161,'g')
% plot(movmean(Cresp_rate_umolkg_day_mean(50:1161)+Cresp_rate_umolkg_day_std(50:1161),50),50:1161,'g')
[l,p] = boundedline(movmean(Cresp_rate_umolkg_day_mean(50:1161),25),50:1161,...
    movmean(Cresp_rate_umolkg_day_std(50:1161),25),'color',rgb('gray'),'orientation','horiz','alpha');
l.Color = 'none';
xlim([0 0.31]); box on
ylabel('Pressure (dbar)')
ax = gca;
ax.FontSize = 12;
ax.XAxisLocation = 'top';
xlabel('\itR\rm (\mumol C kg^-^1 d^-^1)')
text(-0.07,-150,'a.','FontWeight','bold','FontSize',14)


subplot(1,2,2)
for yr = 1:7
    subplot(1,2,2)
    hold on
    plot(movmean(Dremin_length_days{yr}(1:2000),25),1:2000,'Color',colorblind(yr,:),'LineWidth',2.25)
    xlim([0 425])
    ylim([0 1400])
    xlabel('D_r_e_m_i_n length (d)')
    grid on; box on; axis ij
end
ax = gca;
ax.FontSize = 12;
ax.XAxisLocation = 'top';
plot(movmean(Dremin_length_mean,25),1:2000,'-.k','Linewidth',2.25)
plot(Dremin_length_days{1}(Remin0(1)),Remin0(1),'.','Color',rgb('gray'),'MarkerSize',30)
for yr = 1:7
plot(Dremin_length_days{yr}(Remin0(yr)),Remin0(yr),'.','Color',colorblind(yr,:),'MarkerSize',30)
end
plot(movmean(Dremin_length_mean,25),1:2000,'-.k','Linewidth',2.25)
text(-80,-150,'b.','FontWeight','bold','FontSize',14)
legend('2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022','Mean','Z_r_e_m_i_n_0','Location','SW')
%% Figure *** Martin like Curves
    C_Martin_mean = cumsum(DOresp_season_molm3_mean(50:2000)*-0.69,'reverse');
figure
set(gcf,'position',[100,100,1100,300])
for j = 1:7

    if j == 3
        top_cutoff = 200;
    else 
        top_cutoff = 50;
    end

    subplot(1,7,j)
    ax = gca; 
    plot(0:1:10,ones(11,1)*MLD_winter_max(j),'--k','Linewidth',1.2)
        hold on
%     plot(0:1:10,ones(11,1)*Remin0(j),':k','Linewidth',1.5)
    b = barh(top_cutoff:Remin0(j),C_Martin{j});
    hold on
    b.FaceColor = colorblind(j,:);
    b.EdgeColor = colorblind(j,:);
    plot(C_Martin_mean,50:2000,'Color','k','Linewidth',1.6)
    axis ij
    ylim([50 1500])
    xlim([0 10])
    hold on
    if j == 1
        ylabel('Pressure (dbar)')
    end
    if j == 3
        plot(2.5,120,'k*','MarkerSize',7)
%         plot(1,120,'k*','MarkerSize',6) % if want text to say no data
%         text(1.8,120,'No Data')
    end
    if j == 4
        xlabel('Total remineralized export (mol C m^-^2 yr^-^1)','Fontsize',12)
    end
    plot(0:1:10,ones(11,1)*MLD_winter_max(j),'--k','Linewidth',1.2)
% %     plot(0:1:10,ones(11,1)*Remin0(j),':k','Linewidth',1.5)

    ax.FontSize = 12;
    grid on
    ax.XAxisLocation = 'top';
    t = title([num2str(j+2014) ' - ' num2str(j+2015)],'Fontsize',12,'Fontweight','normal','Position',[5 1700 0]);

end
% legend('winter MLD_m_a_x','Orientation','horizontal','Location','southoutside','box','off')

%% Figure *** Inventories bar graph 
% Create figure with scaled errorbars 
figure
ax = gca;
set(gcf,'position',[100,100,800,500])
x1 = 1:4:28;
x2 = 2:4:28;
x3 = 3:4:28;

b = bar(x1,export_Cinventory_molm2);
b.FaceColor = green;
b.BarWidth = 0.2;
hold on
b = bar(x2,revent_Cinventory_molm2);
b.FaceColor = purple;
b.BarWidth = 0.2;
b = bar(x3,sequest_Cinventory_molm2);
b.FaceColor = rgb('medium gray');
b.BarWidth = 0.2;

% to add project inventories for year three
b1 = bar(9,Cinventory_Yr3_projected);
b1.FaceColor = rgb('light gray');
b1.EdgeColor = rgb('light gray');
% b1.LineStyle = ':';
hold on

b1 = bar(10,Cinventory_Yr3_projected);
b1.FaceColor = rgb('light gray');
b1.EdgeColor = rgb('light gray');
% b1.LineStyle = 'none';
plot(10,Cinventory_Yr3_projected+1,'*k')

% b2 = bar(-3,nanmean(export_Cinventory_molm2));
b2 = bar(-3,nanmean([export_Cinventory_molm2(1:2) Cinventory_Yr3_projected export_Cinventory_molm2(4:7)]))
b2.FaceColor = green;

% b2 = bar(-2,nanmean(revent_Cinventory_molm2));
b2 = bar(-2,nanmean([revent_Cinventory_molm2(1:2) Cinventory_Yr3_projected revent_Cinventory_molm2(4:7)]))
b2.FaceColor = purple;

b3 = bar(-1,nanmean(sequest_Cinventory_molm2(~isnan(sequest_Cinventory_molm2)))); % Need to remove the nans and add zeros for average. 
b3.FaceColor = rgb('medium gray');

b = bar(x1,export_Cinventory_molm2);
b.FaceColor = green;
b.BarWidth = 0.2;
b = bar(x2,revent_Cinventory_molm2);
b.FaceColor = purple;
b.BarWidth = 0.2;
b = bar(x3,sequest_Cinventory_molm2);
b.FaceColor = rgb('medium gray');
b.BarWidth = 0.2;
er = errorbar(x1,export_Cinventory_molm2,export_Cinventory_molm2-export_Cinventory_molm2_low_scaled,export_Cinventory_molm2_high_scaled -export_Cinventory_molm2);
er.Color = [ 0 0 0];
er.LineStyle = 'none';
er = errorbar(x2,revent_Cinventory_molm2,revent_Cinventory_molm2-revent_Cinventory_molm2_low_scaled,revent_Cinventory_molm2_high_scaled -revent_Cinventory_molm2);
er.Color = [ 0 0 0];
er.LineStyle = 'none';
er = errorbar(x3,sequest_Cinventory_molm2,sequest_Cinventory_molm2-sequest_Cinventory_molm2_low_scaled,sequest_Cinventory_molm2_high_scaled - sequest_Cinventory_molm2);
er.Color = [ 0 0 0];
er.LineStyle = 'none';


ylabel('mol C m^-^2 yr^-^1')
set(ax,'XTick',[-2 x2],...
    'XTickLabel',...
    {'Mean','2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022'});
xlim([-4.5 28.5]); grid on

% legend('seasonal export','re-enters mixed layer','sequestered annually','Location','southoutside','orientation','horizontal');
legend('exported','re-entrained','sequestrated > winter MLD_m_a_x','Location','NW');
ax.FontSize = 12;


%% CHL- Mixed Layer Plot 
% Nothing added by adding gliders
% Look into flanking moorings 
% Sat chl doesn't add anything really 
run('GeneralSettings.m')
cd('G:\My Drive\Matlab_work\Github\Meg_Irminger_Review')
load chl_clean.mat
t = [      736090
      736450
      736833
      737192
      737558
      737912
      738281
      738641];
figure
set(gcf,'position',[100,100,800,150])
f = gca;
for j = 1:length(t)
    plot([t(j) t(j)],[0 10],'Color',grey,'LineStyle',':','Linewidth',1.5)
    hold on
end
for j = 1:4
    for k = 2:8
    plot(chl_final{j}{k}.time,chl_final{j}{k}.data,'.','Color',forestgreen,'MarkerSize',8)
    hold on
    end
end
datetick('x','yyyy')

% ylabel({'mixed layer'  'chl-a' '(\mug L^-^1)'},'Fontsize',14)
ylabel({'chl-a' '(\mug L^-^1)'},'Fontsize',12)
f.FontSize = 12;
xlim([datenum(2015,01,01) datenum(2022,04,01)])
%% Mixed Layer Dissolved Oxygen 
% Nothing added by adding gliders
% Look into flanking moorings 
cd('G:\Shared drives\NSF_Irminger\OOI_DO_fixed_depth\Data\mixed_layer')
load mixed_layer_calibrated_oxygen.mat
figure
set(gcf,'position',[100,100,800,150])
xlim([datenum(2015,01,01) datenum(2022,04,01)])
f = gca;
for j = 1:length(t)
    plot([t(j) t(j)],[250 400],'Color',grey,'LineStyle',':','Linewidth',1.5)
    hold on
end
xlim([datenum(2015,01,01) datenum(2022,04,01)])
ML_DO.O2sol_umolkg(36955) = NaN;
plot(ML_DO.DOdn,ML_DO.O2sol_umolkg,'k')
plot(ML_DO.DOdn,ML_DO.DO_umolkg_final,'.','Color',blue)
ylabel({'DO' '(\mumol kg^-^1)'},'Fontsize',12)
f.FontSize = 12;

ylim([250 400])
datetick('x','yyyy','Keepticks')
xlim([datenum(2015,01,01) datenum(2022,04,01)])
%% 


