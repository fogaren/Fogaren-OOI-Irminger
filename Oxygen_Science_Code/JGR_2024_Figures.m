%% Output numbers of interst 

display(['Remin0 = ' num2str(Remin0)])
display(['MLDmax = ' num2str(MLD_winter_max')])
display(['Dremin max = ' num2str(Dremin_max_length_days)])
display(['Export mean w/ projected Yr 3 = ' num2str(mean([export_Cinventory_molm2(1:2) Cinventory_Yr3_projected export_Cinventory_molm2(4:7)])) ' +- ' num2str(std([export_Cinventory_molm2(1:2) Cinventory_Yr3_projected export_Cinventory_molm2(4:7)]))])
display(['Export mean w/ projected Yr 3 (exp. fit) = ' num2str(mean([export_Cinventory_molm2(1:2) Cinventory_Yr3_projected_from_expfit export_Cinventory_molm2(4:7)])) ' +- ' num2str(std([export_Cinventory_molm2(1:2) Cinventory_Yr3_projected_from_expfit export_Cinventory_molm2(4:7)]))])
display(['Export mean 1 to 3 proj = ' num2str(mean([export_Cinventory_molm2(1:2) Cinventory_Yr3_projected])) ' +- ' num2str(std([export_Cinventory_molm2(1:2) Cinventory_Yr3_projected]))])
display(['Export mean 1 to 3 proj (exp. fit) = ' num2str(mean([export_Cinventory_molm2(1:2) Cinventory_Yr3_projected_from_expfit])) ' +- ' num2str(std([export_Cinventory_molm2(1:2) Cinventory_Yr3_projected_from_expfit]))])
display(['Export mean 4 to 7 = ' num2str(mean(export_Cinventory_molm2(4:7))) ' +- ' num2str(std(export_Cinventory_molm2(4:7)))])
display(['Reventilated mean proj  = ' num2str(mean([revent_Cinventory_molm2(1:2) Cinventory_Yr3_projected revent_Cinventory_molm2(4:7)])) ' +- ' num2str(std([revent_Cinventory_molm2(1:2) Cinventory_Yr3_projected revent_Cinventory_molm2(4:7)]))])
display(['Reventilated mean Yr 3 proj (exp. fit) = ' num2str(mean([revent_Cinventory_molm2(1:2) Cinventory_Yr3_projected_from_expfit revent_Cinventory_molm2(4:7)])) ' +- ' num2str(std([revent_Cinventory_molm2(1:2) Cinventory_Yr3_projected_from_expfit revent_Cinventory_molm2(4:7)]))])
sequest_Cinventory_molm2(isnan(sequest_Cinventory_molm2)) = 0; % overwrite years with no Csequest with 0 for calc mean 
display(['Sequestered mean = ' num2str(mean(sequest_Cinventory_molm2)) ' +- ' num2str(std(sequest_Cinventory_molm2))])
display(['Export range = ' num2str(min(export_Cinventory_molm2)) ' - ' num2str(max(export_Cinventory_molm2))])
display(['Vent range = ' num2str(min(revent_Cinventory_molm2)) ' - ' num2str(max(revent_Cinventory_molm2))])
display(['Sequest range = ' num2str(min(sequest_Cinventory_molm2)) ' - ' num2str(max(sequest_Cinventory_molm2))])
display(['Revent % range = ' num2str(min(revent_Cinventory_molm2./export_Cinventory_molm2)*100) ' - ' num2str(max(revent_Cinventory_molm2./export_Cinventory_molm2)*100)])
%%
% Add necessary toolboxes and color palettes
addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))
addpath(genpath('G:\My Drive\Matlab_work\Github\cmocean'))
cd('G:\My Drive\Matlab_work\BC')
run('GeneralSettings.m') %for plotting 

colorblind = [0 0.61961 0.45098; 0 0.44706 0.69804; 0.33725 0.70588 0.91373; 0.94118 0.89412 0.25882;...
    0.90196 0.62353 0; 0.83529 0.36863 0; 0.8 0.47451 0.6549];
%% Figure 1: Map 
addpath(genpath('G:\My Drive\Matlab_work\Functions\m_map1.4\m_map'))

lon_min = -40.1; lon_max = -38.9;
lat_min = 59.5; lat_max = 60.1;
ind = find(cast_lat_lon.Lon > lon_min & cast_lat_lon.Lon < -39 & cast_lat_lon.Lat > lat_min & cast_lat_lon.Lat < lat_max);

figure
subplot(1,5,5)
axes1 = gca;
set(gcf,'position',[100,100,1000,600])
plot(1,1,'.','MarkerSize',30,'Color',colorblind(5,:)) % 1 m 
hold on
plot(1,100,'.','MarkerSize',30,'Color',colorblind(5,:)) % 12 m NSIF
plot([1.5 1.5],[0 500],'Color',colorblind(2,:),'Linewidth',3) % shallow prof
plot([2 2],[0 1000],'Color',colorblind(3,:),'Linewidth',3) % deep prof
plot([1 1],[400 1700],'Color',colorblind(6,:),'Linewidth',3) % wfp
plot([2.5 2.5],[0 3000],'Color',colorblind(1,:),'Linewidth',3) % deep prof
axis ij
xlim([0 3])
ylim([0 2000])
axis ij
set(axes1,'YTick',[0 100 300 500 1000 1500 2000],...
    'YTickLabel',...
                {'0','12','150','200','1000','2000','3000'});
set(axes1,'XTickLabel','','XTick','');
axes1.FontSize = 14;
ylabel('pressure (dbar)')

subplot(1,5,[1 4])
m_proj('lambert','long',[lon_min lon_max],'lat',[lat_min lat_max]);
h1 = m_plot(SUMOlon,SUMOlat,'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(5,:));
hold on
h2 = m_plot(Yr5wfp.lon_flord(1),Yr5wfp.lat_flord(1),'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(6,:));
h3 = m_line(glider{1}.lon,glider{1}.lat,'Linewidth',1.3,'Color',colorblind(3,:));
h4 = m_line(glider{3}.lon,glider{3}.lat,'Linewidth',1.3,'Color',colorblind(2,:));
h5 = m_plot(cast_lat_lon.Lon(ind),cast_lat_lon.Lat(ind),'ok','Linewidth',1.2,'MarkerSize',6,'MarkerFaceColor',colorblind(1,:));
for j  = 1:13
    m_line(glider{j}.lon,glider{j}.lat,'Linewidth',1.3,'Color',colorblind(3,:))
end
m_line(glider{3}.lon,glider{3}.lat,'Linewidth',1.3,'Color',colorblind(2,:))
m_line(glider{10}.lon,glider{10}.lat,'Linewidth',1.3,'Color',colorblind(2,:))
m_line(glider{13}.lon,glider{13}.lat,'Linewidth',1.3,'Color',colorblind(2,:))

m_plot(cast_lat_lon.Lon(ind),cast_lat_lon.Lat(ind),'ok','Linewidth',1.2,'MarkerSize',6,'MarkerFaceColor',colorblind(1,:))
m_plot(SUMOlon,SUMOlat,'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(5,:))
m_plot(Yr5wfp.lon_flord(1),Yr5wfp.lat_flord(1),'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(6,:))
% title('Mean Sea Surface Height 2015-2022')
m_grid('box','fancy','tickdir','in','FontSize',14);
set(gca, 'fontsize', 14)
legend([h1 h2 h3 h4 h5],'SUMO','WFP','Glider-1000m','Glider-200m','CTD-Cast','Location','SW')

%% Figure 2: Oxygen timeseries with mixed layer depths 
cd('G:\Shared drives\NSF_Irminger\OOI_DO_fixed_depth\Data\mixed_layer')
load mixed_layer_calibrated_oxygen.mat
ML_DOday = retime(ML_DO,'daily','mean'); % Daily average of ML product

prs_grid = 1:2600;
[X2,Y2] = meshgrid(daily.time,prs_grid);

figure
set(gcf,'position',[100,100,900,300])
scatter(X2(~isnan(daily.doxy)),Y2(~isnan(daily.doxy)),5,daily.doxy(~isnan(daily.doxy)),'filled')
hold on; axis ij; box on
scatter(ML_DOday.DOdn,ones(size(ML_DOday.DOdn))*nanmedian(ML_DOday.prs),5,ML_DOday.DO_umolkg_final,"filled")
plot(blended_mld_daily_all.dn,blended_mld_daily_all.mld,'ok','MarkerSize',2,'MarkerFaceColor','k')
for j = 1:length(mld_max_ind)-1
%     plot(dt(mld_max_ind(j):mld_max_ind(j+1)),ones(1,length(mld_max_ind(j):mld_max_ind(j+1)))*1800,'k')
    dt_text = round((mld_max_ind(j+1) - mld_max_ind(j))/2) + mld_max_ind(j);
    text(blended_mld_daily_all.dn(dt_text)-88,1820,['Remin.'],'Fontsize',11,'FontWeight','bold')
    text(blended_mld_daily_all.dn(dt_text)-78,1920,['Year ' num2str(j)],'Fontsize',11,'FontWeight','bold')
end
for j = 1:length(mld_max_ind)
    plot(blended_mld_daily_all.dn(mld_max_ind(j))*ones(201,1),1800:2000,'k','Linewidth',2)
end
ylim([0 2000])
clim([260 320])
datetick('x','yyyy');
xlim([datenum(2015,01,01) datenum(2022,04,01)])
cmocean('dense')
ylabel('pressure (dbar)', 'Fontsize', 12); hcb = colorbar; set(hcb,'location','eastoutside')
hcb.Label.String = 'DO (\mumol kg^-^1)';
hcb.FontSize = 12;
ax = gca;
set(ax, 'TickDir', 'out')
ax.FontSize = 12;

%% Figure 2: Oxygen with two panels
z_plot = 8;
SA_plot1 = gsw_SA_from_SP(glider{1}.sal_prho_out_removed(z_plot,:),z_plot,glider{1}.lon,glider{1}.lat);
pt_plot1 = gsw_pt0_from_t(SA_plot1,glider{1}.temp_prho_out_removed(z_plot,:),z_plot);
DOsol_plot1 = gsw_O2sol_SP_pt(glider{1}.sal_prho_out_removed(z_plot,:),pt_plot1);

SA_plot3 = gsw_SA_from_SP(glider{3}.sal_prho_out_removed(z_plot,:),z_plot,glider{3}.lon,glider{3}.lat);
pt_plot3 = gsw_pt0_from_t(SA_plot3,glider{3}.temp_prho_out_removed(z_plot,:),z_plot);
DOsol_plot3 = gsw_O2sol_SP_pt(glider{3}.sal_prho_out_removed(z_plot,:),pt_plot3);

SA_plot4 = gsw_SA_from_SP(glider{4}.sal_prho_out_removed(z_plot,:),z_plot,glider{4}.lon,glider{4}.lat);
pt_plot4 = gsw_pt0_from_t(SA_plot4,glider{4}.temp_prho_out_removed(z_plot,:),z_plot);
DOsol_plot4 = gsw_O2sol_SP_pt(glider{4}.sal_prho_out_removed(z_plot,:),pt_plot4);

SA_plot13 = gsw_SA_from_SP(glider{13}.sal_prho_out_removed(z_plot,:),z_plot,glider{13}.lon,glider{13}.lat);
pt_plot13 = gsw_pt0_from_t(SA_plot13,glider{13}.temp_prho_out_removed(z_plot,:),z_plot);
DOsol_plot13 = gsw_O2sol_SP_pt(glider{13}.sal_prho_out_removed(z_plot,:),pt_plot13);

xt = [datenum(2015,01,01)
datenum(2016,01,01)
datenum(2017,01,01)
datenum(2018,01,01)
datenum(2019,01,01)
datenum(2020,01,01)
datenum(2021,01,01)
datenum(2022,01,01)];

figure
set(gcf,'position',[100,100,900,500])
ax1 = subplot(3,1,1);
ML_DO.O2sol_umolkg(36955) = NaN; % bad data point 
glider{3}.doxy(z_plot,384) = NaN; % remove data point
glider{3}.doxy(z_plot,457) = NaN; % remove data point
glider{3}.doxy(z_plot,475) = NaN; % remove data point
glider{3}.doxy(z_plot,456) = NaN; % remove data point
glider{3}.doxy(z_plot,734) = NaN; % remove data point
glider{3}.doxy(z_plot,394) = NaN; % remove data point
plot(ML_DO.DOdn,ML_DO.DO_umolkg_final./ML_DO.O2sol_umolkg*100,'k','Linewidth',1.5)
hold on
plot(glider{4}.time,glider{4}.doxy(z_plot,:)./DOsol_plot4*100,'k','Linewidth',1.5) % To look at daily glider data at same depth 
plot(glider{3}.time,glider{3}.doxy(z_plot,:)./DOsol_plot3*100,'k','Linewidth',1.5) % To look at daily glider data at same depth 
plot(glider{13}.time(330:464),glider{13}.doxy(z_plot,330:464)./DOsol_plot13(330:464)*100,'k','Linewidth',1.5) % To look at daily glider data at same depth 
% plot(daily.time,daily.doxy(2,:),'.') % To look at daily glider data at same depth 
% plot(daily.time,daily.doxy(10,:),'.') % To look at daily glider data at same depth 
% plot(ML_DO.DOdn,ML_DO.DO_umolkg_final,'k','Linewidth',1.5)
ylabel({'DO (% sat.)'},'Fontsize',12)
f = gca; f.FontSize = 12;
% ylim([250 400])
grid on
xlim([datenum(2015,01,01) datenum(2022,04,01)])
xticks(xt)
datetick('x','yyyy','keeplimits','keepticks');
plot([datenum(2015,01,01) datenum(2022,04,01)],[100 100],'k--','LineWidth',1.2)

text(datenum(2014,06,01),130,'a.','FontWeight','bold','FontSize',14)

ax2 = subplot(3,1,[2 3]);
scatter(X2(~isnan(daily.doxy)),Y2(~isnan(daily.doxy)),5,daily.doxy(~isnan(daily.doxy)),'filled')
hold on; axis ij; box on
scatter(ML_DOday.DOdn,ones(size(ML_DOday.DOdn))*nanmedian(ML_DOday.prs),5,ML_DOday.DO_umolkg_final,"filled")
plot(blended_mld_daily_all.dn,blended_mld_daily_all.mld,'ok','MarkerSize',2,'MarkerFaceColor','k')
for j = 1:length(mld_max_ind)-1
%     plot(dt(mld_max_ind(j):mld_max_ind(j+1)),ones(1,length(mld_max_ind(j):mld_max_ind(j+1)))*1800,'k')
    dt_text = round((mld_max_ind(j+1) - mld_max_ind(j))/2) + mld_max_ind(j);
    text(blended_mld_daily_all.dn(dt_text)-88,1820,['Remin.'],'Fontsize',11,'FontWeight','bold')
    text(blended_mld_daily_all.dn(dt_text)-78,1920,['Year ' num2str(j)],'Fontsize',11,'FontWeight','bold')
end
for j = 1:length(mld_max_ind)
    plot(blended_mld_daily_all.dn(mld_max_ind(j))*ones(201,1),1800:2000,'k','Linewidth',2)
end
ylim([0 2000])
clim([260 320])
datetick('x','yyyy');
xlim([datenum(2015,01,01) datenum(2022,04,01)])
cmocean('dense')
ylabel('pressure (dbar)', 'Fontsize', 12); hcb = colorbar; set(hcb,'location','eastoutside')
hcb.Label.String = 'DO (\mumol kg^-^1)';
hcb.FontSize = 12;
ax = gca;
set(ax, 'TickDir', 'out')
linkaxes([ax2 ax1],'x')
ax.FontSize = 12;
text(datenum(2014,06,01),0,'b.','FontWeight','bold','FontSize',14)
%% Figure 3: CHL- Mixed Layer Plot 
% Nothing added by adding gliders
% Look into flanking moorings 
% Sat chl doesn't add anything really 
cd('G:\My Drive\Matlab_work\Github\Meg_Irminger_Review\FINAL')
load chl_clean.mat
addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))

t = [      736090
      736450
      736833
      737192
      737558
      737912
      738281
      738641];

figure
set(gcf,'position',[100,100,900,500])
subplot(3,1,1)
% set(gcf,'position',[100,100,800,150])
yyaxis left
ax1 = gca;
% for j = 1:length(t)
%     plot([t(j) t(j)],[0 10],'Color',rgb('gray'),'LineStyle',':','Linewidth',1.5)
%     hold on
% end
for j = 1:4
    for k = 2:8
    % plot(chl_final{j}{k}.time,chl_final{j}{k}.data,'.','MarkerSize',8,'Color',rgb('dark gray'))
    plot(chl_final{j}{k}.time,chl_final{j}{k}.data,'.','MarkerSize',8,'Color','k')
    hold on
    end
end
ax1.YColor = rgb('dark gray');
datetick('x','yyyy')
grid on
ylabel({'chl-a' '(\mug L^-^1)'},'Fontsize',12)
ax1.FontSize = 12;
xlim([datenum(2015,01,01) datenum(2022,04,01)])
text(datenum(2014,06,01),10,'a.','FontWeight','bold','FontSize',14)

yyaxis right
ax2 = gca;
bin_ind = find(wfpmerge.sinkingpulsedepths == 1025);
plot(wfpmerge.profile_start,smooth(wfpmerge.binned_filteredspikes(:,bin_ind,2),0.007),'.') %mean ~20 day filter; 
ylim([0.0000 .0001])
ylabel('$\overline{b_{bl}}$ (m$^{{-}1}$)','interpreter','latex','Fontsize',14,'FontName','Arial','FontWeight','bold')
ax2.FontSize = 12;
xlim([datenum(2015,01,01) datenum(2022,04,01)])

% Used this to figure out ~smoothing of filter since profiles are not
% evenly spaced in time 
% dt_new = wfpmerge.profile_start(1):1:wfpmerge.profile_start(end);
% test_new = interp1(wfpmerge.profile_start,wfpmerge.binned_filteredspikes(:,bin_ind,2),dt_new,'linear');
% plot(dt_new,smooth(test_new,0.007),'c.')

% Backscatter timeseries with mixed layer depths 
cd('G:\Shared drives\NSF_Irminger\Data_Files\HYPM\downloaded_Jan_2025')
load wfpmerge_plotting.mat 

[B2,I2] = sort(wfpmerge.filteredspikes); 

subplot(3,1,[2 3])
ax2 = gca; 
scatter(wfpmerge.time(I2),wfpmerge.pressure(I2),6,B2,'filled')
hold on; axis ij; box on
% plot(blended_mld_daily_all.dn,blended_mld_daily_all.mld,'.k','MarkerSize',8)
% plot(blended_mld_daily_all.dn,movmean(blended_mld_daily_all.mld,5),'Color',rgb('dark gray'),'Linewidth',1.9)
plot(blended_mld_daily_all.dn,movmean(blended_mld_daily_all.mld,5),'Color','k','Linewidth',1.9)
ylim([0 2000])
ax2.FontSize = 12;
datetick('x','yyyy');
xlim([datenum(2015,01,01) datenum(2022,04,01)])
ylabel('pressure (dbar)', 'Fontsize', 12); 
hcb = colorbar; set(hcb,'location','eastoutside')
clim([0 .003])
cmocean('amp')
hcb.Label.String = 'b_b_l (m^-^1)';
hcb.FontSize = 12;
set(ax2, 'TickDir', 'out')
linkaxes([ax1 ax2],'x')
text(datenum(2014,06,01),0,'b.','FontWeight','bold','FontSize',14)

%% Figure 4: Remineralization Rates and Dremin for each year

figure
set(gcf,'position',[100,100,750,450])
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
plot(movmean(Cresp_rate_umolkg_day_mean(1:1161-49),25),50:1161,'-.','Color',[0 0 0 1],'Linewidth',2.25);
hold on
% Uncomment this to add shaded errorbars around the mean for Cresp_rate 
% [l,p] = boundedline(movmean(Cresp_rate_umolkg_day_mean(50:1161),25),50:1161,...
%     movmean(Cresp_rate_umolkg_day_std(50:1161),25),'color',rgb('gray'),'orientation','horiz','alpha');
% l.Color = 'none';
xlim([0 0.31]); box on
ylabel('pressure (dbar)')
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
% l = legend('2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022','Mean','Z_r_e_m_i_n_0','Location','SW');
% l.FontSize = 10;
l = legend('1: 2015-2016','2: 2016-2017','3: 2017-2018','4: 2018-2019','5: 2019-2020','6: 2020-2021','7: 2021-2022','Mean','Z_r_e_m_i_n_0','Location','SW');
l.FontSize = 10;
title(l,'Remin. Year')
%% Figure 5: Total Remineralized Carbon figure 
% Option 1 
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
    b = barh(top_cutoff:Remin0(j),C_total_remin{j}(top_cutoff:Remin0(j)));
    hold on
    b.FaceColor = colorblind(j,:);
    b.EdgeColor = colorblind(j,:);
    plot(C_total_remin_mean(50:1149),50:1149,'Color','k','Linewidth',1.6)
    axis ij
    ylim([0 1500])
    xlim([0 10])
    hold on
    if j == 1
        ylabel('pressure (dbar)')
    end
    if j == 3
        plot(2.5,120,'k*','MarkerSize',7)
%         plot(1,120,'k*','MarkerSize',6) % if want text to say no data
%         text(1.8,120,'No Data')
    end
    if j == 4
        xlabel('Total remineralized export (mol C m^-^2 remin. yr^-^1)','Fontsize',12)
    end
    plot(0:1:10,ones(11,1)*MLD_winter_max(j),'--k','Linewidth',1.2)
% %     plot(0:1:10,ones(11,1)*Remin0(j),':k','Linewidth',1.5)

    ax.FontSize = 12;
    grid on
    ax.XAxisLocation = 'top';
    t = title([num2str(j+2014) ' - ' num2str(j+2015)],'Fontsize',12,'Fontweight','normal','Position',[5 1700 0]);

end
% legend('winter MLD_m_a_x','Orientation','horizontal','Location','southoutside','box','off')
%%
% Option 2
figure
set(gcf,'position',[100,100,1100,300])
for yr = 1:7
    subplot(1,7,yr)
    ax = gca;
    if yr == 3
        top_cutoff = 200;
    else 
        top_cutoff = 50;
    end
    depth_to_use = top_cutoff:Remin0(yr);
    b = barh(depth_to_use,C_total_remin{yr}(depth_to_use));
    b.FaceColor = colorblind(yr,:);
    b.EdgeColor = colorblind(yr,:);
    hold on
    % Exp fit (martin-like fit)
    % plot(C_total_remin_zstarfit{yr}.a*exp(C_total_remin_zstarfit{yr}.b*(50:2000)),50:2000,'k-','Linewidth',1.5)
    plot(C_total_remin_zstarfit{yr}.a.*exp(-((50:1500)-top_cutoff)./C_total_remin_zstarfit{yr}.b),50:1500,'k-','Linewidth',1.5)
    if yr == 1
        ylabel('pressure (dbar)')
    end
    ylim([0 1500])

    if yr == 3
        plot(3,100,'k*','MarkerSize',7)
%         plot(1,120,'k*','MarkerSize',6) % if want text to say no data
%         text(1.8,120,'No Data')
    end

    if yr == 4
        xlabel('Total remineralized export (mol C m^-^2 remin. yr^-^1)','Fontsize',12)
    end
    plot(0:1:10,ones(11,1)*MLD_winter_max(yr),'--','Color',rgb('medium gray'),'Linewidth',1.5)

    axis ij 
    grid on
    ax.FontSize = 12;
    ax.XAxisLocation = 'top';
    t = title([num2str(yr+2014) ' - ' num2str(yr+2015)],'Fontsize',12,'Fontweight','normal','Position',[5 1700 0]);
end


%% Normalized expontial fits, fits calculated in attenuation_calculations.m
top_cutoff = 50;
lw = 2;

figure
set(gcf,'position',[100,100,850,400])
subplot(1,2,1)
ax = gca;
norm_z = gsw_z_from_p(-50,60); % convert from pressure to depth 
z_to_use = gsw_z_from_p(-1*(50:2500),60);
for j = 1:7
    plot(C_total_remin_zstarfit{j}(z_to_use)/C_total_remin_zstarfit{j}(norm_z),z_to_use,'Linewidth',lw,'Color',colorblind(j,:));
    hold on
end
plot(C_total_remin_mean_zstarfit(z_to_use)/C_total_remin_mean_zstarfit(norm_z),z_to_use,'--k','Linewidth',2)
% plot(C_total_remin_zstarfit{1}(MLD_winter_max(1))/C_total_remin_zstarfit{1}(norm_z),MLD_winter_max(1),'.','Color',rgb('gray'),'MarkerSize',30)
plot([0.37 0.37],[0 2500],'--','Color',rgb('medium gray'),'Linewidth',1.2)
for j = 1:7
    plot(C_total_remin_zstarfit{j}(z_to_use)/C_total_remin_zstarfit{j}(norm_z),z_to_use,'Linewidth',lw,'Color',colorblind(j,:));
    hold on
end
plot(C_total_remin_mean_zstarfit(z_to_use)/C_total_remin_mean_zstarfit(norm_z),z_to_use,'--k','Linewidth',2)
axis ij
grid on
% for j = 1:7
%     plot(C_total_remin_zstarfit{j}(MLD_winter_max(j))/C_total_remin_zstarfit{j}(top_cutoff),MLD_winter_max(j),'.','MarkerSize',30,'Color',colorblind(j,:));
%     hold on
% end
l = legend('1: 2015-2016','2: 2016-2017','3: 2017-2018','4: 2018-2019','5: 2019-2020','6: 2020-2021','7: 2021-2022','Mean','Location','SE');
l.FontSize = 10;
ylim([0 2000])
title(l,'Remin. Year')
ylabel('depth (m)')
xlabel('fraction of total remin. C')
ax.FontSize = 12;
text(-0.2,-150,'a.','FontWeight','bold','FontSize',14)


% Fraction of export bbl
subplot(1,2,2)
ax = gca;  
norm_z = 50; % keep in depth space 
pres_to_use = 50:2500;
plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(1)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(1)}.b*(pres_to_use))./(curve_exp_gaussfilter_omitnan{atten_pulses_good(1)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(1)}.b*(norm_z))),pres_to_use,'Color',colorblind(1,:),'Linewidth',lw)
hold on
plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(2)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(2)}.b*(pres_to_use))./(curve_exp_gaussfilter_omitnan{atten_pulses_good(2)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(2)}.b*(norm_z))),pres_to_use,'-.','Color',colorblind(2,:),'Linewidth',lw)
plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(3)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(3)}.b*(pres_to_use))./(curve_exp_gaussfilter_omitnan{atten_pulses_good(3)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(3)}.b*(norm_z))),pres_to_use,'Color',colorblind(2,:),'Linewidth',lw)
plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(4)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(4)}.b*(pres_to_use))./(curve_exp_gaussfilter_omitnan{atten_pulses_good(4)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(4)}.b*(norm_z))),pres_to_use,'Color',colorblind(3,:),'Linewidth',lw)
plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(5)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(5)}.b*(pres_to_use))./(curve_exp_gaussfilter_omitnan{atten_pulses_good(5)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(5)}.b*(norm_z))),pres_to_use,'Color',colorblind(4,:),'Linewidth',lw)
plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(6)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(6)}.b*(pres_to_use))./(curve_exp_gaussfilter_omitnan{atten_pulses_good(6)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(6)}.b*(norm_z))),pres_to_use,'Color',colorblind(7,:),'Linewidth',lw)
% plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(7)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(7)}.b*(50:2000))./(curve_exp_gaussfilter_omitnan{atten_pulses_good(7)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(7)}.b*(norm_z))),50:2000,'Color',colorblind(7,:),'Linewidth',lw)
plot(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(50:2000))./(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(norm_z))),50:2000,'k--','Linewidth',2)
plot([0.37 0.37],[0 2000],'--','Color',rgb('medium gray'),'Linewidth',1.2)
% hold on
% plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(1)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(1)}.b*(50:2000))./(curve_exp_gaussfilter_omitnan{atten_pulses_good(1)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(1)}.b*(norm_z))),50:2000,'Color',colorblind(1,:),'Linewidth',lw)
% plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(2)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(2)}.b*(50:2000))./(curve_exp_gaussfilter_omitnan{atten_pulses_good(2)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(2)}.b*(norm_z))),50:2000,'--','Color',colorblind(2,:),'Linewidth',lw)
% plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(3)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(3)}.b*(50:2000))./(curve_exp_gaussfilter_omitnan{atten_pulses_good(3)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(3)}.b*(norm_z))),50:2000,'Color',colorblind(2,:),'Linewidth',lw)
% plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(4)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(4)}.b*(50:2000))./(curve_exp_gaussfilter_omitnan{atten_pulses_good(4)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(4)}.b*(norm_z))),50:2000,'Color',colorblind(3,:),'Linewidth',lw)
% plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(5)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(5)}.b*(50:2000))./(curve_exp_gaussfilter_omitnan{atten_pulses_good(5)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(5)}.b*(norm_z))),50:2000,'Color',colorblind(4,:),'Linewidth',lw)
% plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(6)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(6)}.b*(50:2000))./(curve_exp_gaussfilter_omitnan{atten_pulses_good(6)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(6)}.b*(norm_z))),50:2000,'Color',colorblind(7,:),'Linewidth',lw)
% % plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(7)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(7)}.b*(50:2000))./(curve_exp_gaussfilter_omitnan{atten_pulses_good(7)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(7)}.b*(norm_z))),50:2000,'Color',colorblind(7,:),'Linewidth',lw)
% plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(2)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(2)}.b*(50:2000))./(curve_exp_gaussfilter_omitnan{atten_pulses_good(2)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(2)}.b*(norm_z))),50:2000,'-.','Color',colorblind(2,:),'Linewidth',lw)
% plot(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(50:2000))./(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(norm_z))),50:2000,'k--','Linewidth',2)
axis ij
% sgtitle('Export Normalized to 50 dbar')
grid on
xlim([0 1])
ylim([0 2000])
xlabel('fraction of')
text(0.68,2250,'$\overline{b_{bl}}$','interpreter','latex','Fontsize',15,'FontWeight','bold')
ax.FontSize = 12;
text(-0.2,-150,'b.','FontWeight','bold','FontSize',14)
l = legend('2015','2016','2016','2017','2018','2021','Mean','Location','NW');
l.FontSize = 10;
title(l,'Pulse')
%%
figure
plot(C_total_remin_mean_zstarfit(50:2000)/C_total_remin_mean_zstarfit(50),50:2000,'k','Linewidth',2)
hold on
% plot(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(50:2000))./(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(norm_z))),50:2000,'m:','Linewidth',2)
plot(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(pres_to_use))./(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(norm_z))),pres_to_use,'k--','Linewidth',2) % z to pressure; same line
axis ij
xlabel('Export Normalized to 50 dbar')
grid on
xlim([0 1])
ylim([0 2000])
legend('C_r_e_m_i_n','B_b_l','location','NW')

%% Particle transfer efficiency 
bottom_depth = 500;
top_depth = 150; 
Teff_bbl = [];
for j = 1:8
    Teff_bbl(j) = curve_exp_gaussfilter_omitnan{(j)}.a*exp(curve_exp_gaussfilter_omitnan{(j)}.b*(bottom_depth))./(curve_exp_gaussfilter_omitnan{(j)}.a*exp(curve_exp_gaussfilter_omitnan{(j)}.b*(top_depth))); 
end
Teff_bbl_mean = curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(bottom_depth))./(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(top_depth)));
%% Calculate some stats for the Attenuation fits using Cremin and bbl
% Attenuation of export normalized to 50 dbar  
C_total_remin_zstarfit_table
C_total_remin_gof_table
bbl_expfit_gof_table % No zstar exponential fits for the data, zstar = inf



%% Option 1: zstar versus max MLD from winter before 

fit_zstar_maxMLD = fitlm(day_mld(mld_max_ind(1:6)),zstar(1:6));

figure
set(gcf,'position',[100,100,450,400])
ax = gca;
for yr = 1:7
    plot(day_mld(mld_max_ind(yr)),zstar(yr),'.','Color',colorblind(yr,:),'MarkerSize',30)
    hold on
end
plot([400:1600],fit_zstar_maxMLD.Coefficients.Estimate(2)*(400:1600) + fit_zstar_maxMLD.Coefficients.Estimate(1),'k--','Linewidth',1.2)

for yr = 1:7
    plot(day_mld(mld_max_ind(yr)),zstar(yr),'.','Color',colorblind(yr,:),'MarkerSize',30)
    hold on
end
plot(day_mld(mld_max_ind(7)),zstar(7),'kx','MarkerSize',8,'Linewidth',1.5)
l = legend('1: 2015-2016','2: 2016-2017','3: 2017-2018','4: 2018-2019','5: 2019-2020','6: 2020-2021','7: 2021-2022','Location','SE');
l.FontSize = 10;
grid on
title(l,'Remin. Year')
ax.FontSize = 12;
text(450,425,['R^2 = ' num2str(fit_zstar_maxMLD.Rsquared.Ordinary,2)])
% text(450,425,'R^2 = 0.90') % For 2 decimal places
ylabel('z^* for C_r_e_m_i_n (m)')
xlabel('Max MLD of previous winter (dbar)')


%% Option 2: zstar verus max MLD and annual export  
fit_zstar_maxMLD = fitlm(day_mld(mld_max_ind(1:6)),zstar(1:6));

figure
set(gcf,'position',[100,100,850,400])
subplot(1,2,1)
ax = gca;
for yr = 1:7
    plot(day_mld(mld_max_ind(yr)),zstar(yr),'.','Color',colorblind(yr,:),'MarkerSize',30)
    hold on
end
plot([400:1600],fit_zstar_maxMLD.Coefficients.Estimate(2)*(400:1600) + fit_zstar_maxMLD.Coefficients.Estimate(1),'k--','Linewidth',1.2)

for yr = 1:7
    plot(day_mld(mld_max_ind(yr)),zstar(yr),'.','Color',colorblind(yr,:),'MarkerSize',30)
    hold on
end
plot(day_mld(mld_max_ind(7)),zstar(7),'kx','MarkerSize',8,'Linewidth',1.5)
% l = legend('2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022','Location','SE');
% l.FontSize = 10;
ylim([100 450])
grid on
ax.FontSize = 12;
% text(450,425,['R^2 = ' num2str(fit_zstar_maxMLD.Rsquared.Ordinary,2)])
text(450,425,'R^2 = 0.90 (p = 0.004)') % For 2 decimal places
ylabel('z^* for C_r_e_m_i_n (m)')
xlabel('Max MLD of previous winter (dbar)')
text(175,475,'a.','FontWeight','bold','FontSize',14)

exportinv_zstar_fit = fitlm(annual_export,zstar);

subplot(1,2,2)
ax = gca;
for j = 1:7
    plot(annual_export(j),zstar(j),'.','Color',colorblind(j,:),'MarkerSize',30)
    hold on
end
er = errorbar(export_Cinventory_molm2([1:2 4:7]),zstar([1:2 4:7]),export_Cinventory_molm2([1:2 4:7])-export_Cinventory_molm2_low_scaled([1:2 4:7]),'horizontal','ok','MarkerSize',5,'Linewidth',1,'CapSize',3);
hold on
er.Color = [ 0 0 0];
er = errorbar(annual_export(3),zstar(3),annual_export(3) - (annual_export(3)*export_Cinventory_molm2_low_scaled(3)/export_Cinventory_molm2(3)),'horizontal','ok','MarkerSize',5,'Linewidth',1,'CapSize',3);
for j = 1:7
    plot(annual_export(j),zstar(j),'.','Color',colorblind(j,:),'MarkerSize',30)
    hold on
end
plot([0:14],exportinv_zstar_fit.Coefficients.Estimate(2)*(0:14) + exportinv_zstar_fit.Coefficients.Estimate(1),'k--','Linewidth',1.2)
xlabel('Annual export (mol C m^-^2 remin. yr^-^1)')
ylabel('z^* for C_r_e_m_i_n (m)')
ax.FontSize = 12;
grid on
ylim([100 450])
xlim([0.5 14])
% text(2.25,425,['R^2 = ' num2str(exportinv_zstar_fit.Rsquared.Ordinary,2)])
l = legend('1: 2015-2016','2: 2016-2017','3: 2017-2018','4: 2018-2019','5: 2019-2020','6: 2020-2021','7: 2021-2022','Location','SE');
l.FontSize = 10;
title(l,'Remin. Year')
text(1,425,['R^2 = ' num2str(exportinv_zstar_fit.Rsquared.Ordinary,2) ' (p = 0.105)'])
text(-2.5,475,'b.','FontWeight','bold','FontSize',14)
%% Remin0 versus previous year maximum ML depth

fit_remin0_maxMLD = fitlm(day_mld(mld_max_ind(1:6)),Remin0(1:6));

figure
set(gcf,'position',[100,100,450,400])
ax = gca;
for yr = 1:7
    plot(day_mld(mld_max_ind(yr)),Remin0(yr),'.','Color',colorblind(yr,:),'MarkerSize',30)
    hold on
end

plot([400:1600],fit_remin0_maxMLD.Coefficients.Estimate(2)*(400:1600) + fit_remin0_maxMLD.Coefficients.Estimate(1),'k--','Linewidth',1.2)

for yr = 1:7
    plot(day_mld(mld_max_ind(yr)),Remin0(yr),'.','Color',colorblind(yr,:),'MarkerSize',30)
    hold on
end
plot(day_mld(mld_max_ind(7)),Remin0(7),'kx','MarkerSize',8,'Linewidth',1.5)
l = legend('1: 2015-2016','2: 2016-2017','3: 2017-2018','4: 2018-2019','5: 2019-2020','6: 2020-2021','7: 2021-2022','Location','SE');
l.FontSize = 10;
title(l,'Remin. Year')
axis([400 1600 400 1450])
grid on
ax.FontSize = 12;
text(425,1400,['R^2 = ' num2str(fit_remin0_maxMLD.Rsquared.Ordinary,2)])
ylabel('Z_r_e_m_i_n_0 (dbar)')
xlabel('Max MLD of previous winter (dbar)')

%% export versus previous year maximum ML depth
figure
set(gcf,'position',[100,100,450,400])
ax = gca;
% % er = errorbar(export_Cinventory_molm2([1:2 4:7]),zstar([1:2 4:7]),export_Cinventory_molm2([1:2 4:7])-export_Cinventory_molm2_low_scaled([1:2 4:7]),'horizontal','ok','MarkerSize',5,'Linewidth',1,'CapSize',3);
% hold on
% er.Color = [ 0 0 0];
% er = errorbar(day_mld(mld_max_ind(yr)),annual_export(3),annual_export(3) - (annual_export(3)*export_Cinventory_molm2_low_scaled(3)/export_Cinventory_molm2(3)),'horizontal','ok','MarkerSize',5,'Linewidth',1,'CapSize',3);
% % er = errorbar(day_mld(mld_max_ind(yr)), export_Cinventory_molm2([1:2 4:7]),zstar([1:2 4:7]),zstar_errorbar([1:2 4:7]),'horizontal','ok','MarkerSize',5,'Linewidth',1,'CapSize',3);
% % for j = 1:7
% %     plot(annual_export(j),zstar(j),'.','Color',colorblind(j,:),'MarkerSize',30)
% %     hold on
% % end

fit_export_maxMLD = fitlm(day_mld(mld_max_ind(1:7)),annual_export);


ax = gca;
for yr = 1:7
    plot(day_mld(mld_max_ind(yr)),annual_export(yr),'.','Color',colorblind(yr,:),'MarkerSize',30)
    hold on
end
l = legend('2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022','Location','SE');
l.FontSize = 10;
grid on
ax.FontSize = 12;
ylabel('C_e_x_p_o_r_t (mol C m^-^2 remin. yr^-^1)')
xlabel('Max MLD of previous winter (dbar)')

%% Option  
fit_zstar_maxMLD = fitlm(day_mld(mld_max_ind(1:6)),zstar(1:6));

% a: mld vs zstar 
figure
set(gcf,'position',[100,100,825,750])
subplot(2,2,4)
ax = gca;
for yr = 1:7
    plot(day_mld(mld_max_ind(yr)),zstar(yr),'.','Color',colorblind(yr,:),'MarkerSize',30)
    hold on
end
plot([400:1600],fit_zstar_maxMLD.Coefficients.Estimate(2)*(400:1600) + fit_zstar_maxMLD.Coefficients.Estimate(1),'k--','Linewidth',1.2)

for yr = 1:7
    plot(day_mld(mld_max_ind(yr)),zstar(yr),'.','Color',colorblind(yr,:),'MarkerSize',30)
    hold on
end
plot(day_mld(mld_max_ind(7)),zstar(7),'kx','MarkerSize',8,'Linewidth',1.5)
ylim([100 450])
grid on
ax.FontSize = 12;
% text(450,375,['R^2 = ' num2str(fit_zstar_maxMLD.Rsquared.Ordinary,2)])
text(450,425,'R^2 = 0.90 (p = 0.004)') % For 2 decimal places
ylabel('z^* for C_e_x_p_o_r_t (m)')
xlabel('MLD_m_a_x of previous winter (dbar)')
text(165,475,'d.','FontWeight','bold','FontSize',14)

% b, annual export versus zstar
exportinv_zstar_fit = fitlm(annual_export,zstar);

subplot(2,2,3)
ax = gca;
er = errorbar(export_Cinventory_molm2([1:2 4:7]),zstar([1:2 4:7]),export_Cinventory_molm2([1:2 4:7])-export_Cinventory_molm2_low_scaled([1:2 4:7]),'horizontal','ok','MarkerSize',5,'Linewidth',1,'CapSize',3);
hold on
er.Color = [ 0 0 0];
er = errorbar(annual_export(3),zstar(3),annual_export(3) - (annual_export(3)*export_Cinventory_molm2_low_scaled(3)/export_Cinventory_molm2(3)),'horizontal','ok','MarkerSize',5,'Linewidth',1,'CapSize',3);
er = errorbar(export_Cinventory_molm2([1:2 4:7]),zstar([1:2 4:7]),zstar_errorbar([1:2 4:7]),'vertical','ok','MarkerSize',5,'Linewidth',1,'CapSize',3);
for j = 1:7
    plot(annual_export(j),zstar(j),'.','Color',colorblind(j,:),'MarkerSize',30)
    hold on
end
% plot([2:10],exportinv_zstar_fit.Coefficients.Estimate(2)*(2:10) + exportinv_zstar_fit.Coefficients.Estimate(1),'k--','Linewidth',1.2)
xlabel('C_e_x_p_o_r_t (mol C m^-^2 remin. yr^-^1)')
ylabel('z^* for C_e_x_p_o_r_t (m)')
ax.FontSize = 12;
grid on
xlim([0 14])
ylim([100 450])
text(-2.75,475,'c.','FontWeight','bold','FontSize',14)

for j = 1:7
    remin_rate_200to400mean(j) = nanmean(DOresp_rate_umolkg_day_all(200:400,j)*-0.69);
    remin_rate_200to400std(j) = nanstd(DOresp_rate_umolkg_day_all(200:400,j)*-0.69);
end

for j = 1:7
    remin_rate_Cmmolm3_200to400mean(j) = nanmean(DOresp_rate_mmolm3_day_all(200:400,j)*-0.69);
    remin_rate_Cmmolm3_200to400std(j) = nanstd(DOresp_rate_mmolm3_day_all(200:400,j)*-0.69);
end

% c: Mean R versus zstar 
fit_remin_rate_zstar = fitlm(remin_rate_200to400mean,zstar);

subplot(2,2,2)
ax = gca;
ind = 1:7;
for j = 1:length(ind)
    plot(remin_rate_200to400mean(j),zstar(j),'.','Color',colorblind(j,:),'MarkerSize',30)
    hold on
end
h = errorbar(remin_rate_200to400mean,zstar,remin_rate_200to400std,'horizontal','ok','MarkerSize',5,'Linewidth',1,'CapSize',3);
ind = 1:7;
for j = 1:length(ind)
    plot(remin_rate_200to400mean(j),zstar(j),'.','Color',colorblind(j,:),'MarkerSize',30)
end
% plot([0.015:0.01:0.09],fit_remin_rate_zstar.Coefficients.Estimate(2)*(0.015:0.01:0.09) + fit_remin_rate_zstar.Coefficients.Estimate(1),'k--','Linewidth',1.2)
% text(0.022,375,'R^2 = 0.16 (p = 0.382)') 
grid on
xlabel('Mean \itR\rm 200-400 dbar (\mumol C kg^-^1 d^-^1)')
ylabel('z^* for C_e_x_p_o_r_t (m)')
ylim([100 450])
xlim([0.01 0.1])
ax.FontSize = 12;
text(-.008,475,'b.','FontWeight','bold','FontSize',14)
l = legend('1: 2015-2016','2: 2016-2017','3: 2017-2018','4: 2018-2019','5: 2019-2020','6: 2020-2021','7: 2021-2022','Location','SE');
l.FontSize = 10;
title(l,'Remin. Year')

% d: Mean temp versus zstar 
for j = 1:length(ind)
    temp_mean_ind(j) = nanmedian(regress_temp{ind(j)}(200:400));
    temp_mean_std(j) = nanstd(regress_temp{ind(j)}(200:400));
end
fit_zstar_temp = fitlm(temp_mean_ind,zstar(ind));
subplot(2,2,1)
ax = gca;
h = errorbar(temp_mean_ind,zstar,temp_mean_std,'horizontal','ok','MarkerSize',5,'Linewidth',1,'CapSize',3);
hold on
for j = 1:length(ind)
    plot(nanmedian(regress_temp{ind(j)}(200:400)),zstar(ind(j)),'.','Color',colorblind(ind(j),:),'MarkerSize',30)
    hold on
end
grid on
% plot([3.95:0.01:4.2],fit_zstar_temp.Coefficients.Estimate(2)*(3.95:0.01:4.2) + fit_zstar_temp.Coefficients.Estimate(1),'k--','Linewidth',1.2)
xlabel('Mean temp. 200-400 dbar (\circC)')
ylabel('z^* for C_e_x_p_o_r_t (m)')
ylim([100 450])
ax.FontSize = 12;
text(3.675,475,'a.','FontWeight','bold','FontSize',14)
% text(3.96,375,'R^2 = 0.22 (p = 0.285)') 

%% Option  
figure
set(gcf,'position',[100,100,1100,300])
% a, annual export versus zstar exportinv_zstar_fit
subplot(1,3,1)
ax = gca;
er = errorbar(export_Cinventory_molm2([1:2 4:7]),zstar([1:2 4:7]),export_Cinventory_molm2([1:2 4:7])-export_Cinventory_molm2_low_scaled([1:2 4:7]),'horizontal','ok','MarkerSize',5,'Linewidth',1,'CapSize',3);
hold on
er.Color = [ 0 0 0];
er = errorbar(annual_export(3),zstar(3),annual_export(3) - (annual_export(3)*export_Cinventory_molm2_low_scaled(3)/export_Cinventory_molm2(3)),'horizontal','ok','MarkerSize',5,'Linewidth',1,'CapSize',3);
% zstar errorbar 
er = errorbar(export_Cinventory_molm2([1:2 4:7]),zstar([1:2 4:7]),zstar_errorbar([1:2 4:7]),'vertical','ok','MarkerSize',5,'Linewidth',1,'CapSize',3);
for j = 1:7
    plot(annual_export(j),zstar(j),'.','Color',colorblind(j,:),'MarkerSize',30)
    hold on
end
% plot([2:10],exportinv_zstar_fit.Coefficients.Estimate(2)*(2:10) + exportinv_zstar_fit.Coefficients.Estimate(1),'k--','Linewidth',1.2)
xlabel('Annual export (mol C m^-^2 remin. yr^-^1)')
ylabel('z^* for C_e_x_p_o_r_t (m)')
ax.FontSize = 12;
grid on
xlim([0 14])
ylim([100 450])
text(1,425,['R^2 = ' num2str(exportinv_zstar_fit.Rsquared.Ordinary,2) ' (p = 0.105)'])
text(-2.75,475,'a.','FontWeight','bold','FontSize',14)

for j = 1:7
    remin_rate_200to400mean(j) = nanmean(DOresp_rate_umolkg_day_all(200:400,j))*-0.69;
    remin_rate_200to400std(j) = nanstd(DOresp_rate_umolkg_day_all(200:400,j))*-0.69;
end

% b: Mean temp versus zstar 
subplot(1,3,2) % from fit_zstar_temp
ax = gca;
h = errorbar(temp_mean_ind,zstar,temp_mean_std,'horizontal','ok','MarkerSize',5,'Linewidth',1,'CapSize',3);
hold on
for j = 1:length(ind)
    plot(nanmedian(regress_temp{ind(j)}(200:400)),zstar(ind(j)),'.','Color',colorblind(ind(j),:),'MarkerSize',30)
    hold on
end
grid on
% plot([3.95:0.01:4.2],fit_zstar_temp.Coefficients.Estimate(2)*(3.95:0.01:4.2) + fit_zstar_temp.Coefficients.Estimate(1),'k--','Linewidth',1.2)
xlabel('Mean temp. 200-400 dbar (\circC)')
text(3.84,425,['R^2 = 0.22 (p = 0.287)']) % from fit_zstar_temp
% ylabel('z^*(m), total remin. C')
ylim([100 450])
ax.FontSize = 12;
text(3.675,475,'b.','FontWeight','bold','FontSize',14)

% c: Mean R versus zstar 
subplot(1,3,3) % fit_remin_rate_zstar
ax = gca;
for j = 1:length(ind)
    plot(remin_rate_200to400mean(j),zstar(j),'.','Color',colorblind(j,:),'MarkerSize',30)
    hold on
end
h = errorbar(remin_rate_200to400mean,zstar,remin_rate_200to400std,'horizontal','ok','MarkerSize',5,'Linewidth',1,'CapSize',3);
ind = 1:7;
for j = 1:length(ind)
    plot(remin_rate_200to400mean(j),zstar(j),'.','Color',colorblind(j,:),'MarkerSize',30)
end
% plot([0.015:0.01:0.09],fit_remin_rate_zstar.Coefficients.Estimate(2)*(0.015:0.01:0.09) + fit_remin_rate_zstar.Coefficients.Estimate(1),'k--','Linewidth',1.2)
% text(0.022,375,'R^2 = 0.16 (p = 0.382)') 
grid on
xlabel('Mean \itR\rm 200-400 dbar (\mumol C kg^-^1 d^-^1)')
% ylabel('z^*(m), total remin. C')
ylim([100 450])
xlim([0.01 0.1])
ax.FontSize = 12;
text(0.015,425,['R^2 = 0.15 (p = 0.384)'])
text(-.008,475,'c.','FontWeight','bold','FontSize',14)
l = legend('1: 2015-2016','2: 2016-2017','3: 2017-2018','4: 2018-2019','5: 2019-2020','6: 2020-2021','7: 2021-2022','Location','SE');
l.FontSize = 10;
title(l,'Remin. Year')



%%
% colorblind = [0 0.61961 0.45098; 0 0.44706 0.69804; 0.33725 0.70588 0.91373; 0.94118 0.89412 0.25882;...
%     0.90196 0.62353 0; 0.83529 0.36863 0; 0.8 0.47451 0.6549];
pulsecolors = [0 0.61961 0.45098; 0 0.44706 0.69804; 0 0.44706 0.69804; 0.33725 0.70588 0.91373; 0.94118 0.89412 0.25882; 0.8 0.47451 0.6549];
pulse_num = [1 2 2 3 4 8];
figure
set(gcf,'position',[100,100,775,550])
for j = 1:length(atten_pulses_good)

    subplot(2,3,j)
    ax = gca;
    plot(sinkingpulse_max_gaussfilter_omitnan(:,1,atten_pulses_good(j)),wfpmerge.sinkingpulsedepths,'ok','MarkerFaceColor',pulsecolors(j,:),'markersize', 5)
    hold on
    plot((curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.b*(200:2000))),200:2000,'k','Linewidth',2)
    plot((curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.b*(50:200))),50:200,'Color',rgb('gray'),'Linewidth',2)
    legend off
    axis ij; grid on
    % xlabel('b_b_l x 10^-^3 (m^-^1)','Fontsize',11)
    if j == 1
        ylabel('depth (m)') 
    end
    if j == 4
        ylabel('depth (m)')
    end
    ax.FontSize = 12; 
    % ax.XAxisLocation = 'top';
    xlim([0 0.00025])
    if yrstr(atten_pulses_good(j)) == 2016
        title('2016: Pulse 1')
    elseif yrstr(atten_pulses_good(j)) == 2016.5
        title('2016: Pulse 2')
    else
        title(string(yrstr(atten_pulses_good(j))))
    end
    xlabel('$\overline{b_{bl}}$ (m$^{{-}1}$)','interpreter','latex','Fontsize',14,'FontName','Arial','FontWeight','bold')
end
%%
pulsecolors = [0 0.61961 0.45098; 0 0.44706 0.69804; 0 0.44706 0.69804; 0.33725 0.70588 0.91373; 0.94118 0.89412 0.25882; 0.8 0.47451 0.6549];
pulse_num = [1 2 2 3 4 8];
figure
set(gcf,'position',[100,100,1100,300])
for j = 1:length(atten_pulses_good)

    subplot(1,6,j) % x 10000 
    ax = gca;
    plot(sinkingpulse_max_gaussfilter_omitnan(:,1,atten_pulses_good(j))*10000,wfpmerge.sinkingpulsedepths,'ok','MarkerFaceColor',pulsecolors(j,:),'markersize', 5)
    hold on
    plot((curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.b*(200:2000)))*10000,200:2000,'k','Linewidth',2)
    plot((curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.b*(50:200)))*10000,50:200,'Color',rgb('gray'),'Linewidth',2)
    legend off
    axis ij; grid on
    % xlabel('b_b_l x 10^-^3 (m^-^1)','Fontsize',11)
    if j == 1
        ylabel('depth (m)') 
    end
    if j == 4
        text(-2.15,-445,'$\overline{b_{bl}}$','interpreter','latex','Fontsize',14,'FontName','Arial','FontWeight','bold')
        text(-1.6,-455,'x10^-^4 (m^-^1)','Fontsize',12)
    end
    ax.FontSize = 12; 
    ax.XAxisLocation = 'top';
    xlim([0 2.5])
    if yrstr(atten_pulses_good(j)) == 2016
        text(0.1,2150,'2016: Pulse 1')
    elseif yrstr(atten_pulses_good(j)) == 2016.5
        text(0.1,2150,'2016: Pulse 2')
    else
        text(0.9,2150,string(yrstr(atten_pulses_good(j))))
    end
  % sgtitle('$\overline{b_{bl}}$','interpreter','latex','Fontsize',14,'FontName','Arial','FontWeight','bold')
    sgtitle('test','Color','none')
end
%%
figure
set(gcf,'position',[100,100,300,350])
ax = gca;
l = errorbar(sinkingpulse_max_gaussfilter_omitnan_mean,wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan_std,'horizontal','ok','MarkerSize',5,'CapSize',0);
l.MarkerFaceColor = rgb('medium gray');
hold on
axis ij
plot(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
plot(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(200:2000)),200:2000,'k','Linewidth',2)
grid on
ax.FontSize = 12; 
xlim([0 0.00025])
xlabel('$\overline{b_{bl}}$ (m$^{{-}1}$)','interpreter','latex','Fontsize',14,'FontName','helvetica')
ylabel('depth (m)')
title('All pulses 2015-2018, 2021')

%%
figure
set(gcf,'position',[100,100,700,350])
subplot(1,2,1)
ax = gca;
l = errorbar(sinkingpulse_max_gaussfilter_omitnan_mean,wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan_std,'horizontal','ok','MarkerSize',6,'CapSize',0);
l.MarkerFaceColor = rgb('medium gray');
hold on
axis ij
plot(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
plot(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(200:2000)),200:2000,'k','Linewidth',2)
grid on
ax.FontSize = 12; 
xlim([0 0.00025])
% xlabel('max. b_b_l (m^-^1)')
xlabel('$\overline{b_{bl}}$ (m$^{{-}1}$)','interpreter','latex','Fontsize',14,'FontName','helvetica')
ylabel('depth (m)')


% subplot(1,2,2)
% % plot(wfpmerge.sinkingpulsedepths,nanmean(p2,2),'ok','MarkerSize',6,'MarkerFaceColor',rgb('medium gray'))
% ax = gca;
% l = errorbar(wfpmerge.sinkingpulsedepths,nanmean(p2,2),nanstd(p2,0,2),'vertical','ok','MarkerSize',6,'CapSize',0);
% l.MarkerFaceColor = rgb('medium gray');
% grid on
% ax.FontSize = 12;
% title(['w_b_b_l = ' num2str(SR_allpulses_mean,3) ' ' '(' num2str(SR_allpulses_mean_low,3) '-' num2str(SR_allpulses_mean_high,3) ') m d^-^1'])
% ylabel('Time of max pulse (d)')
% xlabel('Depth (m)')

subplot(1,2,2)
lm = fitlm(wfpmerge.sinkingpulsedepths,nanmean(p2,2));
ax = gca;
l = errorbar(wfpmerge.sinkingpulsedepths,nanmean(p2,2),nanstd(p2,0,2),'vertical','ok','MarkerSize',6,'CapSize',0);
hold on
l.MarkerFaceColor = rgb('medium gray');
plot((200:2000),(200:2000)*lm.Coefficients.Estimate(2) + lm.Coefficients.Estimate(1),'-k','Linewidth',2)
grid on
ax.FontSize = 12;
% text(-14,100,'$\overline{w}_{bbl}$','interpreter','latex','Fontsize',13)
% text(-2,90,['= ' num2str(SR_allpulses_mean,3) ' ' '(' num2str(SR_allpulses_mean_low,3) '-' num2str(SR_allpulses_mean_high,3) ') m d^-^1'],'Fontsize',12)
ylabel('days since pulse at 200 m')
xlabel('depth (m)')

%%
figure
set(gcf,'position',[100,100,700,350])
subplot(1,2,1)
ax = gca;
l = errorbar(sinkingpulse_max_gaussfilter_omitnan_mean,wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan_std,'horizontal','ok','MarkerSize',6,'CapSize',0);
l.MarkerFaceColor = rgb('medium gray');
hold on
axis ij
plot(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
plot(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(200:2000)),200:2000,'k','Linewidth',2)
grid on
ax.FontSize = 12; 
xlim([0 0.00025])
% xlabel('max. b_b_l (m^-^1)')
xlabel('$\overline{b_{bl}}$ (m$^{{-}1}$)','interpreter','latex','Fontsize',14,'FontName','helvetica')
ylabel('depth (m)')

subplot(1,2,2)
lm = fitlm(nanmean(p2,2),wfpmerge.sinkingpulsedepths);
ax = gca;
l = errorbar(nanmean(p2,2),wfpmerge.sinkingpulsedepths,nanstd(p2,0,2),'horizontal','ok','MarkerSize',6,'CapSize',0);
hold on
l.MarkerFaceColor = rgb('medium gray');
plot((0:40),(0:40)*lm.Coefficients.Estimate(2) + lm.Coefficients.Estimate(1),'-k','Linewidth',2)
grid on
ax.FontSize = 12;
axis ij
text(-14,100,'$\overline{w}_{bbl}$','interpreter','latex','Fontsize',13)
text(-2,90,['= ' num2str(SR_allpulses_mean,3) ' ' '(' num2str(SR_allpulses_mean_low,3) '-' num2str(SR_allpulses_mean_high,3) ') m d^-^1'],'Fontsize',12)
xlabel('days since pulse at 200 m')
ylabel('depth (m)')
ylim([0 2000])
%%
pulsecolors = [0 0.61961 0.45098; 0 0.44706 0.69804; 0 0.44706 0.69804; 0.33725 0.70588 0.91373; 0.94118 0.89412 0.25882; 0.8 0.47451 0.6549];
pulse_num = [1 2 2 3 4 8];
atten_pulses_good = [1:5 8];

bblsize = [];
bblsize_std = [];
for j = 1:length(atten_pulses_good)
   bblsize(j) = sinkingpulse_max_gaussfilter_omitnan(1,1,atten_pulses_good(j));
   % bblsize_std(j) =  wfpmerge.binned_filteredspikes(sinkingpulse_max_gaussfilter_omitnan(:,2,j),3,j);
   % bblsize_mean(j) = wfpmerge.binned_filteredspikes(sinkingpulse_max_gaussfilter_omitnan(:,2,j),2,j);
end

bblsize_zstar_bbl_fit = fitlm(bblsize,zstar_bbl(atten_pulses_good));

figure
set(gcf,'position',[100,100,750,700])
subplot(2,2,1) % fit_remin_rate_zstar
ax = gca;
for j = 1:length(atten_pulses_good)
    if j == 2
        plot(sinkingpulse_max_gaussfilter_omitnan(1,1,atten_pulses_good(j)),zstar_bbl(atten_pulses_good(j)),'o','Color',pulsecolors(j,:),'MarkerSize',7,'Linewidth',2)
    else
        plot(sinkingpulse_max_gaussfilter_omitnan(1,1,atten_pulses_good(j)),zstar_bbl(atten_pulses_good(j)),'.','Color',pulsecolors(j,:),'MarkerSize',30)
        hold on
    end
end
ylabel('z$^{*}$ from $\overline{b_{bl}}$ (m$^{{-}1}$)','interpreter','latex','Fontsize',14,'FontName','helvetica')
xlabel('$\overline{b_{bl}}$ at 225 m (m$^{{-}1}$)','interpreter','latex','Fontsize',14,'FontName','helvetica')
ylim([1250 3500])
xlim([0.000075 0.00035])
grid on
ax.FontSize = 12; 
l = legend('2015','2016','2016','2017','2018','2021','Location','NE');
title(l,'Pulse');

subplot(2,2,2) % fit_remin_rate_zstar
Temp_bbl = [];
pulses = [1 2 2 3 4 7];
for j = 1:length(pulses)
    Temp_bbl(j) = nanmedian(regress_temp{pulses(j)}(200:400));
    Temp_bbl_std(j) = nanstd(regress_temp{pulses(j)}(200:400));
end
temp_zstar_bbl_fit = fitlm(Temp_bbl,zstar_bbl(atten_pulses_good));
ax = gca;
for j = 1:length(pulses)
    h = errorbar(Temp_bbl(j),zstar_bbl(atten_pulses_good(j)),Temp_bbl_std(j),'horizontal','k','MarkerSize',1,'Linewidth',1,'CapSize',3);
    hold on
end
for j = 1:length(atten_pulses_good)
    if j ==2
        plot(Temp_bbl(j),zstar_bbl(atten_pulses_good(j)),'o','Color',pulsecolors(j,:),'MarkerSize',7,'Linewidth',2)
    else
        plot(Temp_bbl(j),zstar_bbl(atten_pulses_good(j)),'.','Color',pulsecolors(j,:),'MarkerSize',30)
    end
    hold on
end
ylabel('z$^{*}$ from $\overline{b_{bl}}$ (m$^{{-}1}$)','interpreter','latex','Fontsize',14,'FontName','helvetica')
ylim([1250 3500])
% xlim([3.95 4.2])
xlabel('Mean temp. 200-400 dbar (\circC)')
grid on
ax.FontSize = 12; 

vel_pulses_good = [1:3 5];
subplot(2,2,4) 
for j = 1:length(vel_pulses_good)
    SR(j) = 1/table2array(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Coefficients(2,1));
end

sinkingspeed_zstar_bbl_fit = fitlm(SR,zstar_bbl(vel_pulses_good));

ax = gca;
for j = 1:length(vel_pulses_good)
    if j == 2
        plot(1/table2array(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Coefficients(2,1)),zstar_bbl(j),'o','Color',pulsecolors(j,:),'MarkerSize',7,'Linewidth',2)
    else 
        plot(1/table2array(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Coefficients(2,1)),zstar_bbl(j),'.','Color',pulsecolors(j,:),'MarkerSize',30)
    end
    hold on
end
ylabel('z$^{*}$ from $\overline{b_{bl}}$ (m$^{{-}1}$)','interpreter','latex','Fontsize',14,'FontName','helvetica')
ylim([1250 3500])
xlabel('sinking speed (m d^-^1)')
xlim([30 85])
grid on
ax.FontSize = 12; 

subplot(2,2,3)
bblsize_vel = [];
for j = 1:length(vel_pulses_good)
   bblsize_vel(j) = sinkingpulse_max_gaussfilter_omitnan(1,1,vel_pulses_good(j));
end
sinkingspeed_bblsize_vel_fit = fitlm(bblsize_vel,SR);

ax = gca;
for j = 1:length(vel_pulses_good)
    if j == 2
        plot(sinkingpulse_max_gaussfilter_omitnan(1,1,vel_pulses_good(j)),1/table2array(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Coefficients(2,1)),'o','Color',pulsecolors(j,:),'MarkerSize',7,'Linewidth',2)
    else 
        plot(sinkingpulse_max_gaussfilter_omitnan(1,1,vel_pulses_good(j)),1/table2array(LinearFit_gaussfilter_omitnan{vel_pulses_good(j)}.Coefficients(2,1)),'.','Color',pulsecolors(j,:),'MarkerSize',30)
    end
    hold on
end
ylabel('sinking speed (m d^-^1)')
xlabel('$\overline{b_{bl}}$ at 225 m (m$^{{-}1}$)','interpreter','latex','Fontsize',14,'FontName','helvetica')
xlim([0.000075 0.00035])
ylim([30 85])
grid on
ax.FontSize = 12; 
%%
figure
temp_zstar_bbl_fit = fitlm(Temp_bbl,zstar_bbl(atten_pulses_good));
ax = gca;
for j = 1:length(atten_pulses_good)
    if j ==2
        plot(Temp_bbl(j),bblsize(j),'o','Color',pulsecolors(j,:),'MarkerSize',7,'Linewidth',2)
    else
        plot(Temp_bbl(j),bblsize(j),'.','Color',pulsecolors(j,:),'MarkerSize',30)
    end
    hold on
end
ylabel('z* for large particles (m)')
xlabel('Mean temp. 200-400 dbar (\circC)')
% ylim([1500 3000])
grid on
ax.FontSize = 12; 
%% Figure *** Inventories bar graph
% Create figure with scaled errorbars 
figure
ax = gca;
set(gcf,'position',[100,100,800,400])
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
% b1 = bar(9,Cinventory_Yr3_projected); % From average of other year inventories
b1 = bar(9,Cinventory_Yr3_projected_from_expfit); % From exp fit projection 
b1.FaceColor = green; b1.FaceAlpha = 0.45;
b1.EdgeColor = rgb('light gray');
% b1.LineStyle = ':';
hold on

% b1 = bar(10,Cinventory_Yr3_projected); % From average of other year inventories
b1 = bar(10,Cinventory_Yr3_projected_from_expfit); % From exp fit projection 
b1.FaceColor = purple; b1.FaceAlpha = 0.45;
b1.EdgeColor = rgb('light gray');
% b1.LineStyle = 'none';
% plot(10,Cinventory_Yr3_projected+1,'*k')
plot(10,Cinventory_Yr3_projected_from_expfit+1,'*k','Markersize',6,'Linewidth',1)

% b2 = bar(-3,nanmean(export_Cinventory_molm2));
% b2 = bar(-3,nanmean([export_Cinventory_molm2(1:2) Cinventory_Yr3_projected export_Cinventory_molm2(4:7)]));
b2 = bar(-3,nanmean([export_Cinventory_molm2(1:2) Cinventory_Yr3_projected_from_expfit export_Cinventory_molm2(4:7)]));
b2.FaceColor = green;

% b2 = bar(-2,nanmean(revent_Cinventory_molm2));
% b2 = bar(-2,nanmean([revent_Cinventory_molm2(1:2)
% Cinventory_Yr3_projected revent_Cinventory_molm2(4:7)]));
b2 = bar(-2,nanmean([revent_Cinventory_molm2(1:2) Cinventory_Yr3_projected_from_expfit revent_Cinventory_molm2(4:7)]));
b2.FaceColor = purple;

b3 = bar(-1,nanmean(sequest_Cinventory_molm2(~isnan(sequest_Cinventory_molm2))));  
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


ylabel('mol C m^-^2 remin. yr^-^1')
set(ax,'XTick',[-2 x2],...
    'XTickLabel',...
    {'Mean','2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022'});
xlim([-4.5 28.5]); grid on
title('','Fontsize',40)
% legend('seasonal export','re-enters mixed layer','sequestered annually','Location','southoutside','orientation','horizontal');
l = legend('seasonally exported','seasonally re-entrained','annually sequestrated > MLD_m_a_x','Location','NW');
title(l,'Remineralized Carbon')
ax.FontSize = 12;

ax2 = axes('Position',get(ax,'Position'),'Color','none');
set(ax2, 'XAxisLocation','top','YAxisLocation','Right')
set(ax2,'Ytick',[])
set(ax2,'XAxisLocation','top')
set(ax2,'XLim',[-4.5 28.5],'XTick',[-2 x2],'XTickLabel',{'Mean',sprintf('Remin.\\newlineYear 1'),sprintf('Remin.\\newlineYear 2'),...
    sprintf('Remin.\\newlineYear 3'),sprintf('Remin.\\newlineYear 4'),sprintf('Remin.\\newlineYear 5'),sprintf('Remin.\\newlineYear 6'),sprintf('Remin.\\newlineYear 7')},'Fontsize',12)
xtickangle(ax2,35)
% for j = 1:7
%     text(x1(j)-0.5,15.5,['Remin.'],'Fontsize',12)%,'FontWeight','bold')
%     text(x1(j)-1,14.5,['Year ' num2str(j)],'Fontsize',12)%,'FontWeight','bold')
% end
% text(-3,15,'Mean','Fontsize',12)
 % text(blended_mld_daily_all.dn(dt_text)-88,1820,['Remin.'],'Fontsize',11,'FontWeight','bold')
 %    text(blended_mld_daily_all.dn(dt_text)-78,1920,['Year ' num2str(j)],'Fontsize',11,'FontWeight','bold')
%% Mixed Layer Dissolved Oxygen, supplemental figure 
% Very little is added by including glider data at same depth (~7 m)

figure
set(gcf,'position',[100,150,800,200])
ML_DO.O2sol_umolkg(36955) = NaN; % bad data point 
plot(ML_DO.DOdn,ML_DO.O2sol_umolkg,'k','Linewidth',1.5)
hold on
plot(ML_DO.DOdn,ML_DO.DO_umolkg_final,'.','Color',blue)
% plot(daily.time,daily.doxy(7,:),'.') % To look at daily glider data at same depth 
ylabel({'DO' '(\mumol kg^-^1)'},'Fontsize',12)
f = gca; f.FontSize = 12;
ylim([250 400])
grid on
xlim([datenum(2018,01,01) datenum(2022,01,01)])
datetick('x','yyyy')
%% 


