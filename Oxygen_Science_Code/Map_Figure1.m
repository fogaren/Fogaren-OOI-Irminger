clearvars; close all

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('glider_griddall_fixedPc1600db.mat')
glider = glidergrid; clear glidergrid;
glider_prs = 1:1000;

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('wfpmerge_output_fixedPc1600db.mat')
wfp_prs = 150:1:2600; % Depths of Hilary's product

cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
load OOI_BCO_DMO_latlons.mat
SUMOlat = 59.933;    SUMOlon = -39.465;

%%

colorblind = [0 0.61961 0.45098; 0 0.44706 0.69804; 0.33725 0.70588 0.91373; 0.94118 0.89412 0.25882;...
    0.90196 0.62353 0; 0.83529 0.36863 0; 0.8 0.47451 0.6549];
close all

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

subplot(1,5,[1 3.75])
plot(1,1,'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(5,:))
hold on
plot(1,1,'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(6,:))
plot(1,1,'Linewidth',2,'Color',colorblind(3,:))
plot(1,1,'Linewidth',2,'Color',colorblind(2,:))
plot(1,1,'ok','Linewidth',1.2,'MarkerSize',6,'MarkerFaceColor',colorblind(1,:))
axes1 = gca;
for j = 1:13
    plot(movmean(glider{j}.lon(1:end),1),movmean(glider{j}.lat(1:end),1),'Color',colorblind(3,:),'LineWidth',1.25)
    hold on
end
plot(movmean(glider{3}.lon(1:end),1),movmean(glider{3}.lat(1:end),1),'Color',colorblind(2,:),'LineWidth',1.25)
plot(movmean(glider{10}.lon(1:end),1),movmean(glider{10}.lat(1:end),1),'Color',colorblind(2,:),'LineWidth',1.25)
plot(movmean(glider{13}.lon(1:end),1),movmean(glider{13}.lat(1:end),1),'Color',colorblind(2,:),'LineWidth',1.25)

axes1.FontSize = 14;
ylim([59.5 60.1])
xlim([-40.1 -38.9])
grid on
plot(cast_lat_lon.Lon,cast_lat_lon.Lat,'ok','Linewidth',1.2,'MarkerSize',6,'MarkerFaceColor',colorblind(1,:))
plot(SUMOlon,SUMOlat,'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(5,:))
% plot(Yr5wfp.lon_flord(1),Yr5wfp.lat_flord(1),'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(6,:))
plot(wggmerge.lon(1),wggmerge.lat(1),'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(6,:))
legend('SUMO','WFP','Glider-1000 m','Glider-200 m','Turn-around CTD Cast','Location','SW','Box','on')

%%
addpath(genpath('G:\My Drive\Matlab_work\Functions\m_map1.4\m_map'))

close all
lon_min = -40.1; lon_max = -38.9;
lat_min = 59.5; lat_max = 60.1;
ind = find(cast_lat_lon.Lon > lon_min & cast_lat_lon.Lon < -39 & cast_lat_lon.Lat > lat_min & cast_lat_lon.Lat < lat_max);

figure
% subplot(1,5,5)
axes1 = gca;
set(gcf,'position',[100,100,200,400])
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
%%
figure
subplot(1,5,[1 4])
axes1 = gca;
set(gcf,'position',[100,100,1000,600])
m_proj('lambert','long',[lon_min lon_max],'lat',[lat_min lat_max]);
h1 = m_plot(SUMOlon,SUMOlat,'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(5,:));
hold on
% h2 = m_plot(Yr5wfp.lon_flord(1),Yr5wfp.lat_flord(1),'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(6,:));
h2 = m_plot(wggmerge.lon(1),wggmerge.lat(1),'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(6,:));
h3 = m_line(glider{1}.lon,glider{1}.lat,'Linewidth',1.3,'Color',colorblind(3,:));
h4 = m_line(glider{3}.lon,glider{3}.lat,'Linewidth',1.3,'Color',colorblind(2,:));
h5 = m_plot(cast_lat_lon.Lon(ind),cast_lat_lon.Lat(ind),'ok','Linewidth',1.2,'MarkerSize',6,'MarkerFaceColor',colorblind(1,:));
for j  = 1:13
    m_line(glider{j}.lon,glider{j}.lat,'Linewidth',1.3,'Color',colorblind(3,:))
end
m_line(glider{3}.lon,glider{3}.lat,'Linewidth',1.3,'Color',colorblind(2,:))
m_line(glider{10}.lon,glider{10}.lat,'Linewidth',1.3,'Color',colorblind(2,:))
m_line(glider{13}.lon,glider{13}.lat,'Linewidth',1.3,'Color',colorblind(2,:))
m_ruler([.7 .95],.15,'tickdir','out','ticklen',[.007 .007]);


m_plot(cast_lat_lon.Lon(ind),cast_lat_lon.Lat(ind),'ok','Linewidth',1.2,'MarkerSize',6,'MarkerFaceColor',colorblind(1,:))
m_plot(SUMOlon,SUMOlat,'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(5,:))
% m_plot(Yr5wfp.lon_flord(1),Yr5wfp.lat_flord(1),'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(6,:))
m_plot(wggmerge.lon(1),wggmerge.lat(1),'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(6,:))
% title('Mean Sea Surface Height 2015-2022')
m_grid('box','fancy','tickdir','in','FontSize',14);
set(gca, 'fontsize', 14)
legend([h1 h2 h3 h4 h5],'SUMO','WFP','Glider-1000m','Glider-200m','CTD-Cast','Location','SW')
%%
figure
subplot(2,5,[4.5 4.7 ])
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

subplot(2,5,[9 10])
newmap
geoplot(land,FaceColor = colorblind(3,:))
mx1 = gca;
mx1.ProjectedCRS = p;
geolimits([20 75],[0 -90])
hold on
geoscatter(SUMOlat,SUMOlon,'filled')%,'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(5,:))

subplot(2,5,[1 6])
m_proj('lambert','long',[lon_min lon_max],'lat',[lat_min lat_max]);
h1 = m_plot(SUMOlon,SUMOlat,'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(5,:));
hold on
% h2 = m_plot(Yr5wfp.lon_flord(1),Yr5wfp.lat_flord(1),'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(6,:));
h2 = m_plot(wggmerge.lon(1),wggmerge.lat(1),'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(6,:));
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
% m_plot(Yr5wfp.lon_flord(1),Yr5wfp.lat_flord(1),'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(6,:))
m_plot(wggmerge.lon(1),wggmerge.lat(1),'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(6,:))
% title('Mean Sea Surface Height 2015-2022')
m_grid('box','fancy','tickdir','in','FontSize',14);
set(gca, 'fontsize', 14)
legend([h1 h2 h3 h4 h5],'SUMO','WFP','Glider-1000m','Glider-200m','CTD-Cast','Location','SW')
%%
% sea surface height 
figure; clf 
m_proj('Albers Equal-Area Conic','long',[lon_min lon_max],'lat',[lat_min lat_max])
geoscatter(wggmerge.lat(1),wggmerge.lon(1),'filled')
% geoscatter(Yr5wfp.lat_flord(1),Yr5wfp.lon_flord(1),'filled')%,'ok','Linewidth',1.2,'MarkerSize',130,'MarkerFaceColor',colorblind(6,:))
% geoscatter(SUMOlat,SUMOlon,'filled')%,'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(5,:))
% geoscatter(cast_lat_lon.Lat,cast_lat_lon.Lon,'filled')%,'ok','Linewidth',1.2,'MarkerSize',6,'MarkerFaceColor',colorblind(1,:))
%%
figure
newmap
geoplot(land,FaceColor = colorblind(3,:))
mx1 = gca;
mx1.ProjectedCRS = p;
geolimits([20 75],[0 -90])

hold on
% geolimits([59.5 60.1],[-40.1 -38.9])
% for j = 1:13
%     geoplot(glider{j}.lat,glider{j}.lon)
%     hold on
% end
% geoscatter(Yr5wfp.lat_flord(1),Yr5wfp.lon_flord(1),'filled')%,'ok','Linewidth',1.2,'MarkerSize',130,'MarkerFaceColor',colorblind(6,:))
geoscatter(SUMOlat,SUMOlon,'filled')%,'ok','Linewidth',1.2,'MarkerSize',13,'MarkerFaceColor',colorblind(5,:))
% geoscatter(cast_lat_lon.Lat,cast_lat_lon.Lon,'filled')%,'ok','Linewidth',1.2,'MarkerSize',6,'MarkerFaceColor',colorblind(1,:))