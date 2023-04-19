% OOI asset locations 
ooi_latlon = [59.9341, -39.4673
    59.8177, -39.8412
    59.7155, -39.3148];
    
% Setup the Map Axes
figure
subplot(1,3,1)
axesm('MapProjection','mercator'); 
minlat=min(ooi_latlon(:,1)); maxlat=max(ooi_latlon(:,1)); 
minlon=min(ooi_latlon(:,2)); maxlon=max(ooi_latlon(:,1)); 

% New Lat/Lon Limits
ll = [-40 59.5; -39 60.05];

setm(gca, 'MapLatLimit',[ll(1,2) ll(2,2)],...
          'MapLonLimit',[ll(1,1) ll(2,1)]);
setm(gca,'MLineLocation',1,'MLabelLocation',1,...
    'MeridianLabel','on','MLabelParallel','south'); 
setm(gca,'PLineLocation',1,'PLabelLocation',1,...
    'ParallelLabel','on','PLabelMeridian','west');
tightmap;
setm(gca,'FontWeight','normal','FontSize',10,'FontName','Tahoma','LabelUnits','dm'); 

% Add lat/lon tickmarks for every degree if the map spans 
% greater than 1.5 degrees longitude, or every quarter degree if less.
if abs(maxlon-minlon)>1.5
  setm(gca,'MLineLocation',1,'MLabelLocation',1,'MeridianLabel','on','MLabelParallel','south'); 
  setm(gca,'PLineLocation',1,'PLabelLocation',1,'ParallelLabel','on','PLabelMeridian','west');
else
  setm(gca,'MLineLocation',0.25,'MLabelLocation',0.25,'MeridianLabel','on','MLabelParallel','south'); 
  setm(gca,'PLineLocation',0.25,'PLabelLocation',0.25,'ParallelLabel','on','PLabelMeridian','west');
end

% Plot Casts/OOI Assets
plotm(ooi_latlon(:,1),ooi_latlon(:,2),'^','markersize',8,'MarkerFaceColor','k',...
    'MarkerEdgeColor','k')
hold on
plotm(cast04u.lat(1),cast04u.lon(1),'.','markersize',30,'Color',purple)
plotm(cast05u.lat(1),cast05u.lon(1),'.','markersize',30,'Color',maroon)
plotm(cast06u.lat(1),cast06u.lon(1),'.','markersize',30,'Color',red)
plotm(cast07u.lat(1),cast07u.lon(1),'.','markersize',30,'Color',blue)
% plotm(cast08u.lat(1),cast08u.lon(1),'.','markersize',30,'Color',purple)
% plotm(cast09u.lat(1),cast09u.lon(1),'.','markersize',30,'Color',blue)
% plotm(cast10u.lat(1),cast10u.lon(1),'.','markersize',30,'Color',cyan)
% plotm(cast11u.lat(1),cast11u.lon(1),'.','markersize',30,'Color',red)
plotm(cast12u.lat(1),cast12u.lon(1),'.','markersize',30,'Color',green)
% plotm(cast13u.lat(1),cast13u.lon(1),'.','markersize',30,'Color',maroon)
% plotm(cast14u.lat(1),cast14u.lon(1),'.','markersize',30,'Color',yellow)
% plotm(cast15u.lat(1),cast15u.lon(1),'.','markersize',30,'Color',brightpurple)
% plotm(cast16u.lat(1),cast16u.lon(1),'.','markersize',30,'Color',brightpurple)
% plotm(cast17u.lat(1),cast17u.lon(1),'.','markersize',30,'Color',yellow)
% plotm(cast18u.lat(1),cast18u.lon(1),'.','markersize',30,'Color',yellow)
% plotm(cast19u.lat(1),cast19u.lon(1),'.','markersize',30,'Color',yellow)
% plotm(cast30u.lat(1),cast30u.lon(1),'.','markersize',30,'Color',brightpurple)
% plotm(cast21u.lat(1),cast21u.lon(1),'.','markersize',30,'Color',navy)
% plotm(cast22u.lat(1),cast22u.lon(1),'.','markersize',30,'Color',brightpurple)
% plotm(cast23u.lat(1),cast23u.lon(1),'.','markersize',30,'Color',yellow)

title('Irminger 8: CTD Casts')
legend('','OOI Asset','Cast 4','Cast 5','Cast 6','Cast 7',...
    'Cast 12','Location','southoutside')

subplot(1,3,2)
plot(cast04d.DOcorr_umolkg,cast04d.pt,'Linewidth',1.2,'Color',purple)
hold on
plot(cast05d.DOcorr_umolkg,cast05d.pt,'Linewidth',1.2,'Color',maroon)
plot(cast06d.DOcorr_umolkg,cast06d.pt,'Linewidth',1.2,'Color',red)
plot(cast07d.DOcorr_umolkg,cast07d.pt,'Linewidth',1.2,'Color',blue)
% plot(cast08d.DOcorr_umolkg,cast08d.pt,'Linewidth',1.2,'Color',purple)
% plot(cast09d.DOcorr_umolkg,cast09d.pt,'Linewidth',1.2,'Color',blue)
% plot(cast10d.DOcorr_umolkg,cast10d.pt,'Linewidth',1.2,'Color',cyan)
% plot(cast10d.DOcorr_umolkg,cast10d.pt,'Linewidth',1.2,'Color',cyan)
plot(cast12d.DOcorr_umolkg,cast12d.pt,'Linewidth',1.2,'Color',green)
% plot(cast14d.DOcorr_umolkg,cast14d.pt,'Linewidth',1.2,'Color',yellow)
% plot(cast15d.DOcorr_umolkg,cast15d.pt,'Linewidth',1.2,'Color',brightpurple)
% plot(cast21d.DOcorr_umolkg,cast21d.pt,'Linewidth',1.2,'Color',navy)
grid on
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Downcasts')

subplot(1,3,3)
plot(btlsum04.Winkler_umolkg,btlsum04.pt,'.k','markersize',20)
hold on
plot(cast04u.DOcorr_umolkg,cast04u.pt,'Linewidth',1.2,'Color',purple)
% hold on
plot(cast05u.DOcorr_umolkg,cast05u.pt,'Linewidth',1.2,'Color',maroon)
plot(cast06u.DOcorr_umolkg,cast06u.pt,'Linewidth',1.2,'Color',red)
plot(cast07u.DOcorr_umolkg,cast07u.pt,'Linewidth',1.2,'Color',blue)
% plot(cast08u.DOcorr_umolkg,cast08u.pt,'Linewidth',1.2,'Color',purple)
% plot(cast09u.DOcorr_umolkg,cast09u.pt,'Linewidth',1.2,'Color',blue)
plot(cast12u.DOcorr_umolkg,cast12u.pt,'Linewidth',1.2,'Color',green)
% plot(cast13u.DOcorr_umolkg,cast13u.pt,'Linewidth',1.2,'Color',maroon)
% plot(cast14u.DOcorr_umolkg,cast14u.pt,'Linewidth',1.2,'Color',yellow)
% plot(cast15u.DOcorr_umolkg,cast15u.pt,'Linewidth',1.2,'Color',brightpurple)
% plot(cast21u.DOcorr_umolkg,cast21u.pt,'Linewidth',1.2,'Color',navy)
% plot(btlsum_yr8.Winkler_umolkg,btlsum_yr8.pt,'.k','markersize',20)
plot(btlsum04.Winkler_umolkg,btlsum04.pt,'.k','markersize',20)
plot(btlsum05.Winkler_umolkg,btlsum05.pt,'.k','markersize',20)
plot(btlsum06.Winkler_umolkg,btlsum06.pt,'.k','markersize',20)
plot(btlsum07.Winkler_umolkg,btlsum07.pt,'.k','markersize',20)
plot(btlsum12.Winkler_umolkg,btlsum12.pt,'.k','markersize',20)
legend('Winklers','Location','SW')
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
ylim([0 10])
grid on
sgtitle('Year 8')
%% to show all data including removed bad winklers 
cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year8')

btl = readtable('Irminger_Sea-08_AR60-01_Summary_KF.xlsx','TextType','string');
btl.Cast = double(btl.Cast); btl.Bottle = double(btl.Bottle);
btl.Winkler_mLL = double(btl.Winkler_mLL);
btl.Discrete_Salinity_psu = double(btl.Discrete_Salinity_psu);

btlsum01all = btl(btl.Cast == 1,:);
btlsum02all = btl(btl.Cast == 2,:);
btlsum04all = btl(btl.Cast == 4,:);
btlsum05all = btl(btl.Cast == 5,:);
btlsum06all = btl(btl.Cast == 6,:);
btlsum07all = btl(btl.Cast == 7,:);
btlsum09all = btl(btl.Cast == 9,:);
btlsum10all = btl(btl.Cast == 10,:);
btlsum11all = btl(btl.Cast == 11,:);
btlsum12all = btl(btl.Cast == 12,:);

% Had to change bottle numbers in csv files to be sequential 
% [btlsum] = combine_btl_files(leah_btl_file,btl_file,btlsum,CTD_sen)
btlsum01all = combine_btl_files('AR60-1_001.cbot_s','ar60-1_001.csv',btlsum01all,CTD_sen);
btlsum02all = combine_btl_files('AR60-1_002.cbot_s','ar60-1_002.csv',btlsum02all,CTD_sen);
btlsum04all = combine_btl_files('AR60-1_004.cbot_s','ar60-1_004.csv',btlsum04all,CTD_sen);
btlsum05all = combine_btl_files('AR60-1_005.cbot_s','ar60-1_005.csv',btlsum05all,CTD_sen);
btlsum06all = combine_btl_files('AR60-1_006.cbot_s','ar60-1_006.csv',btlsum06all,CTD_sen);
btlsum07all = combine_btl_files('AR60-1_007.cbot_s','ar60-1_007.csv',btlsum07all,CTD_sen);
btlsum09all = combine_btl_files('AR60-1_009.cbot_s','ar60-1_009.csv',btlsum09all,CTD_sen);
btlsum10all = combine_btl_files('AR60-1_010.cbot_s','ar60-1_010.csv',btlsum10all,CTD_sen);
btlsum11all = combine_btl_files('AR60-1_011.cbot_s','ar60-1_011.csv',btlsum11all,CTD_sen);
btlsum12all = combine_btl_files('AR60-1_012.cbot_s','ar60-1_012.csv',btlsum12all,CTD_sen);

[~, ~, btlsum01all] = Process_Cast_Gain_E2_v2(cast01u,cast01d,cal,btlsum01all,sal_plots,leah_plot,CTD_sen,'Cast 01');
[~, ~, btlsum02all] = Process_Cast_Gain_E2_v2(cast02u,cast02d,cal,btlsum02all,sal_plots,leah_plot,CTD_sen,'Cast 02');
[~, ~, btlsum03all] = Process_Cast_Gain_E2_v2(cast03u,cast03d,cal,0,sal_plots,leah_plot,CTD_sen,'Cast 03');
[~, ~, btlsum04all] = Process_Cast_Gain_E2_v2(cast04u,cast04d,cal,btlsum04all,sal_plots,leah_plot,CTD_sen,'Cast 04');
[~, ~, btlsum05all] = Process_Cast_Gain_E2_v2(cast05u,cast05d,cal,btlsum05all,sal_plots,leah_plot,CTD_sen,'Cast 05');
[~, ~, btlsum06all] = Process_Cast_Gain_E2_v2(cast06u,cast06d,cal,btlsum06all,sal_plots,leah_plot,CTD_sen,'Cast 06');
[~, ~, btlsum07all] = Process_Cast_Gain_E2_v2(cast07u,cast07d,cal,btlsum07all,sal_plots,leah_plot,CTD_sen,'Cast 07');
[~, ~, btlsum08all] = Process_Cast_Gain_E2_v2(cast08u,cast08d,cal,0,sal_plots,leah_plot,CTD_sen,'Cast 08');
[~, ~, btlsum09all] = Process_Cast_Gain_E2_v2(cast09u,cast09d,cal,btlsum09all,sal_plots,leah_plot,CTD_sen,'Cast 09');
[~, ~, btlsum10all] = Process_Cast_Gain_E2_v2(cast10u,cast10d,cal,btlsum10all,sal_plots,leah_plot,CTD_sen,'Cast 10'); 
[~, ~, btlsum11all] = Process_Cast_Gain_E2_v2(cast11u,cast11d,cal,btlsum11all,sal_plots,leah_plot,CTD_sen,'Cast 11');
[~, ~, btlsum12all] = Process_Cast_Gain_E2_v2(cast12u,cast12d,cal,btlsum12all,sal_plots,leah_plot,CTD_sen,'Cast 12');

btlsumall = [btlsum04all; btlsum05all; btlsum06all; btlsum07all; btlsum12all];

%%
% OOI asset locations 
ooi_latlon = [59.9341, -39.4673
    59.8177, -39.8412
    59.7155, -39.3148];
    
% Setup the Map Axes
figure
subplot(1,3,1)
axesm('MapProjection','mercator'); 
minlat=min(ooi_latlon(:,1)); maxlat=max(ooi_latlon(:,1)); 
minlon=min(ooi_latlon(:,2)); maxlon=max(ooi_latlon(:,1)); 

% New Lat/Lon Limits
ll = [-40 59.5; -39 60.05];

setm(gca, 'MapLatLimit',[ll(1,2) ll(2,2)],...
          'MapLonLimit',[ll(1,1) ll(2,1)]);
setm(gca,'MLineLocation',1,'MLabelLocation',1,...
    'MeridianLabel','on','MLabelParallel','south'); 
setm(gca,'PLineLocation',1,'PLabelLocation',1,...
    'ParallelLabel','on','PLabelMeridian','west');
tightmap;
setm(gca,'FontWeight','normal','FontSize',10,'FontName','Tahoma','LabelUnits','dm'); 

% Add lat/lon tickmarks for every degree if the map spans 
% greater than 1.5 degrees longitude, or every quarter degree if less.
if abs(maxlon-minlon)>1.5
  setm(gca,'MLineLocation',1,'MLabelLocation',1,'MeridianLabel','on','MLabelParallel','south'); 
  setm(gca,'PLineLocation',1,'PLabelLocation',1,'ParallelLabel','on','PLabelMeridian','west');
else
  setm(gca,'MLineLocation',0.25,'MLabelLocation',0.25,'MeridianLabel','on','MLabelParallel','south'); 
  setm(gca,'PLineLocation',0.25,'PLabelLocation',0.25,'ParallelLabel','on','PLabelMeridian','west');
end

% Plot Casts/OOI Assets
plotm(ooi_latlon(:,1),ooi_latlon(:,2),'^','markersize',8,'MarkerFaceColor','k',...
    'MarkerEdgeColor','k')
hold on
plotm(cast04u.lat(1),cast04u.lon(1),'.','markersize',30,'Color',purple)
plotm(cast05u.lat(1),cast05u.lon(1),'.','markersize',30,'Color',maroon)
plotm(cast06u.lat(1),cast06u.lon(1),'.','markersize',30,'Color',red)
plotm(cast07u.lat(1),cast07u.lon(1),'.','markersize',30,'Color',blue)
% plotm(cast08u.lat(1),cast08u.lon(1),'.','markersize',30,'Color',purple)
% plotm(cast09u.lat(1),cast09u.lon(1),'.','markersize',30,'Color',blue)
% plotm(cast10u.lat(1),cast10u.lon(1),'.','markersize',30,'Color',cyan)
% plotm(cast11u.lat(1),cast11u.lon(1),'.','markersize',30,'Color',red)
plotm(cast12u.lat(1),cast12u.lon(1),'.','markersize',30,'Color',green)
% plotm(cast13u.lat(1),cast13u.lon(1),'.','markersize',30,'Color',maroon)
% plotm(cast14u.lat(1),cast14u.lon(1),'.','markersize',30,'Color',yellow)
% plotm(cast15u.lat(1),cast15u.lon(1),'.','markersize',30,'Color',brightpurple)
% plotm(cast16u.lat(1),cast16u.lon(1),'.','markersize',30,'Color',brightpurple)
% plotm(cast17u.lat(1),cast17u.lon(1),'.','markersize',30,'Color',yellow)
% plotm(cast18u.lat(1),cast18u.lon(1),'.','markersize',30,'Color',yellow)
% plotm(cast19u.lat(1),cast19u.lon(1),'.','markersize',30,'Color',yellow)
% plotm(cast30u.lat(1),cast30u.lon(1),'.','markersize',30,'Color',brightpurple)
% plotm(cast21u.lat(1),cast21u.lon(1),'.','markersize',30,'Color',navy)
% plotm(cast22u.lat(1),cast22u.lon(1),'.','markersize',30,'Color',brightpurple)
% plotm(cast23u.lat(1),cast23u.lon(1),'.','markersize',30,'Color',yellow)

title('Irminger 8: CTD Casts')
legend('','OOI Asset','Cast 4','Cast 5','Cast 6','Cast 7',...
    'Cast 12','Location','southoutside')

subplot(1,3,2)
plot(cast04d.DOcorr_umolkg,cast04d.pt,'Linewidth',1.2,'Color',purple)
hold on
plot(cast05d.DOcorr_umolkg,cast05d.pt,'Linewidth',1.2,'Color',maroon)
plot(cast06d.DOcorr_umolkg,cast06d.pt,'Linewidth',1.2,'Color',red)
plot(cast07d.DOcorr_umolkg,cast07d.pt,'Linewidth',1.2,'Color',blue)
% plot(cast08d.DOcorr_umolkg,cast08d.pt,'Linewidth',1.2,'Color',purple)
% plot(cast09d.DOcorr_umolkg,cast09d.pt,'Linewidth',1.2,'Color',blue)
% plot(cast10d.DOcorr_umolkg,cast10d.pt,'Linewidth',1.2,'Color',cyan)
% plot(cast10d.DOcorr_umolkg,cast10d.pt,'Linewidth',1.2,'Color',cyan)
plot(cast12d.DOcorr_umolkg,cast12d.pt,'Linewidth',1.2,'Color',green)
% plot(cast14d.DOcorr_umolkg,cast14d.pt,'Linewidth',1.2,'Color',yellow)
% plot(cast15d.DOcorr_umolkg,cast15d.pt,'Linewidth',1.2,'Color',brightpurple)
% plot(cast21d.DOcorr_umolkg,cast21d.pt,'Linewidth',1.2,'Color',navy)
grid on
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Downcasts')

subplot(1,3,3)
% plot(btlsum04_OOI.Winkler_umolkg,btlsum04.pt,'.k','markersize',20)
hold on
plot(cast04u.DOcorr_umolkg,cast04u.pt,'Linewidth',1.2,'Color',purple)
% hold on
plot(cast05u.DOcorr_umolkg,cast05u.pt,'Linewidth',1.2,'Color',maroon)
plot(cast06u.DOcorr_umolkg,cast06u.pt,'Linewidth',1.2,'Color',red)
plot(cast07u.DOcorr_umolkg,cast07u.pt,'Linewidth',1.2,'Color',blue)
% plot(cast08u.DOcorr_umolkg,cast08u.pt,'Linewidth',1.2,'Color',purple)
% plot(cast09u.DOcorr_umolkg,cast09u.pt,'Linewidth',1.2,'Color',blue)
plot(cast12u.DOcorr_umolkg,cast12u.pt,'Linewidth',1.2,'Color',green)
% plot(cast13u.DOcorr_umolkg,cast13u.pt,'Linewidth',1.2,'Color',maroon)
% plot(cast14u.DOcorr_umolkg,cast14u.pt,'Linewidth',1.2,'Color',yellow)
% plot(cast15u.DOcorr_umolkg,cast15u.pt,'Linewidth',1.2,'Color',brightpurple)
% plot(cast21u.DOcorr_umolkg,cast21u.pt,'Linewidth',1.2,'Color',navy)
% plot(btlsum_yr8.Winkler_umolkg,btlsum_yr8.pt,'.k','markersize',20)
plot(btlsumall.Winkler_umolkg,btlsumall.pt,'.r','markersize',20)
plot(btlsum04.Winkler_umolkg,btlsum04.pt,'.k','markersize',20)
plot(btlsum05.Winkler_umolkg,btlsum05.pt,'.k','markersize',20)
plot(btlsum06.Winkler_umolkg,btlsum06.pt,'.k','markersize',20)
plot(btlsum07.Winkler_umolkg,btlsum07.pt,'.k','markersize',20)
plot(btlsum12.Winkler_umolkg,btlsum12.pt,'.k','markersize',20)
legend('Winklers','Location','SW')
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on
sgtitle('Year 8')


%%

% figure
% subplot(1,2,1)
% plot(cast05d.oxumkg,cast05d.pt,'Linewidth',1.2,'Color',grey)
% hold on
% plot(cast06d.oxumkg,cast06d.pt,'Linewidth',1.2,'Color',grey)
% plot(cast07d.oxumkg,cast07d.pt,'Linewidth',1.2,'Color',grey)
% plot(cast08d.oxumkg,cast08d.pt,'Linewidth',1.2,'Color',grey)
% plot(cast09d.oxumkg,cast09d.pt,'Linewidth',1.2,'Color',grey)
% plot(cast10d.oxumkg,cast10d.pt,'Linewidth',1.2,'Color',grey)
% plot(cast13d.oxumkg,cast13d.pt,'Linewidth',1.2,'Color',grey)
% plot(cast14d.oxumkg,cast14d.pt,'Linewidth',1.2,'Color',grey)
% plot(cast15d.oxumkg,cast15d.pt,'Linewidth',1.2,'Color',grey)
% plot(cast21d.oxumkg,cast21d.pt,'Linewidth',1.2,'Color',grey)
% plot(cast05d.DOcorr_umolkg,cast05d.pt,'Linewidth',1.2,'Color',green)
% plot(cast06d.DOcorr_umolkg,cast06d.pt,'Linewidth',1.2,'Color',forestgreen)
% plot(cast07d.DOcorr_umolkg,cast07d.pt,'Linewidth',1.2,'Color',red)
% plot(cast08d.DOcorr_umolkg,cast08d.pt,'Linewidth',1.2,'Color',purple)
% plot(cast09d.DOcorr_umolkg,cast09d.pt,'Linewidth',1.2,'Color',blue)
% plot(cast10d.DOcorr_umolkg,cast10d.pt,'Linewidth',1.2,'Color',cyan)
% plot(cast13d.DOcorr_umolkg,cast13d.pt,'Linewidth',1.2,'Color',maroon)
% plot(cast14d.DOcorr_umolkg,cast14d.pt,'Linewidth',1.2,'Color',yellow)
% plot(cast15d.DOcorr_umolkg,cast15d.pt,'Linewidth',1.2,'Color',brightpurple)
% plot(cast21d.DOcorr_umolkg,cast21d.pt,'Linewidth',1.2,'Color',navy)
% ylabel('PT (\circC)')
% xlabel('DO (\mumol kg^-^1)')
% title('Downcasts')
% 
% subplot(1,2,2)
% plot(cast05u.oxumkg,cast05u.pt,'Linewidth',1.2,'Color',grey)
% hold on
% plot(cast06u.oxumkg,cast06u.pt,'Linewidth',1.2,'Color',grey)
% plot(cast07u.oxumkg,cast07u.pt,'Linewidth',1.2,'Color',grey)
% plot(cast08u.oxumkg,cast08u.pt,'Linewidth',1.2,'Color',grey)
% plot(cast09u.oxumkg,cast09u.pt,'Linewidth',1.2,'Color',grey)
% plot(cast10u.oxumkg,cast10u.pt,'Linewidth',1.2,'Color',grey)
% plot(cast13u.oxumkg,cast13u.pt,'Linewidth',1.2,'Color',grey)
% plot(cast14u.oxumkg,cast14u.pt,'Linewidth',1.2,'Color',grey)
% plot(cast15u.oxumkg,cast15u.pt,'Linewidth',1.2,'Color',grey)
% plot(cast21u.oxumkg,cast21u.pt,'Linewidth',1.2,'Color',grey)
% plot(cast05u.DOcorr_umolkg,cast05u.pt,'Linewidth',1.2,'Color',green)
% plot(cast06u.DOcorr_umolkg,cast06u.pt,'Linewidth',1.2,'Color',forestgreen)
% plot(cast07u.DOcorr_umolkg,cast07u.pt,'Linewidth',1.2,'Color',red)
% plot(cast08u.DOcorr_umolkg,cast08u.pt,'Linewidth',1.2,'Color',purple)
% plot(cast09u.DOcorr_umolkg,cast09u.pt,'Linewidth',1.2,'Color',blue)
% plot(cast10u.DOcorr_umolkg,cast10u.pt,'Linewidth',1.2,'Color',cyan)
% plot(cast13u.DOcorr_umolkg,cast13u.pt,'Linewidth',1.2,'Color',maroon)
% plot(cast14u.DOcorr_umolkg,cast14u.pt,'Linewidth',1.2,'Color',yellow)
% plot(cast15u.DOcorr_umolkg,cast15u.pt,'Linewidth',1.2,'Color',brightpurple)
% plot(cast21u.DOcorr_umolkg,cast21u.pt,'Linewidth',1.2,'Color',navy)
% 
% %%
% figure
% plot(cast05d.DOcorr_umolkg./cast05d.O2sol_umolkg,cast05d.pt,'Linewidth',1.2,'Color',green)
% hold on
% plot(cast06d.DOcorr_umolkg./cast06d.O2sol_umolkg,cast06d.pt,'Linewidth',1.2,'Color',forestgreen)
% plot(cast07d.DOcorr_umolkg./cast07d.O2sol_umolkg,cast07d.pt,'Linewidth',1.2,'Color',red)
% plot(cast08d.DOcorr_umolkg./cast08d.O2sol_umolkg,cast08d.pt,'Linewidth',1.2,'Color',purple)
% plot(cast09d.DOcorr_umolkg./cast09d.O2sol_umolkg,cast09d.pt,'Linewidth',1.2,'Color',blue)
% plot(cast10d.DOcorr_umolkg./cast10d.O2sol_umolkg,cast10d.pt,'Linewidth',1.2,'Color',cyan)
% plot(cast13d.DOcorr_umolkg./cast13d.O2sol_umolkg,cast13d.pt,'Linewidth',1.2,'Color',maroon)
% plot(cast14d.DOcorr_umolkg./cast14d.O2sol_umolkg,cast14d.pt,'Linewidth',1.2,'Color',yellow)
% plot(cast15d.DOcorr_umolkg./cast15d.O2sol_umolkg,cast15d.pt,'Linewidth',1.2,'Color',brightpurple)
% plot(cast21d.DOcorr_umolkg./cast21d.O2sol_umolkg,cast21d.pt,'Linewidth',1.2,'Color',navy)
% ylabel('PT (\circC)')
% xlabel('DO (% Sat)')
% title('Downcasts')
% 
% figure
% subplot(1,2,1)
% plot(cast05d.oxumkg./cast05d.O2sol_umolkg,cast05d.prs,'Linewidth',1.2,'Color',green)
% hold on
% plot(cast06d.oxumkg./cast06d.O2sol_umolkg,cast06d.prs,'Linewidth',1.2,'Color',forestgreen)
% plot(cast07d.oxumkg./cast07d.O2sol_umolkg,cast07d.prs,'Linewidth',1.2,'Color',red)
% plot(cast08d.oxumkg./cast08d.O2sol_umolkg,cast08d.prs,'Linewidth',1.2,'Color',purple)
% plot(cast09d.oxumkg./cast09d.O2sol_umolkg,cast09d.prs,'Linewidth',1.2,'Color',blue)
% plot(cast10d.oxumkg./cast10d.O2sol_umolkg,cast10d.prs,'Linewidth',1.2,'Color',cyan)
% plot(cast13d.oxumkg./cast13d.O2sol_umolkg,cast13d.prs,'Linewidth',1.2,'Color',maroon)
% plot(cast14d.oxumkg./cast14d.O2sol_umolkg,cast14d.prs,'Linewidth',1.2,'Color',yellow)
% plot(cast15d.oxumkg./cast15d.O2sol_umolkg,cast15d.prs,'Linewidth',1.2,'Color',brightpurple)
% plot(cast21d.oxumkg./cast21d.O2sol_umolkg,cast21d.prs,'Linewidth',1.2,'Color',navy)
% axis ij
% ylabel('Pres. (db)')
% xlabel('DO (% Sat)')
% title('Uncorrected Downcasts')
% 
% subplot(1,2,2)
% plot(cast05d.DOcorr_umolkg./cast05d.O2sol_umolkg,cast05d.prs,'Linewidth',1.2,'Color',green)
% hold on
% plot(cast06d.DOcorr_umolkg./cast06d.O2sol_umolkg,cast06d.prs,'Linewidth',1.2,'Color',forestgreen)
% plot(cast07d.DOcorr_umolkg./cast07d.O2sol_umolkg,cast07d.prs,'Linewidth',1.2,'Color',red)
% plot(cast08d.DOcorr_umolkg./cast08d.O2sol_umolkg,cast08d.prs,'Linewidth',1.2,'Color',purple)
% plot(cast09d.DOcorr_umolkg./cast09d.O2sol_umolkg,cast09d.prs,'Linewidth',1.2,'Color',blue)
% plot(cast10d.DOcorr_umolkg./cast10d.O2sol_umolkg,cast10d.prs,'Linewidth',1.2,'Color',cyan)
% plot(cast13d.DOcorr_umolkg./cast13d.O2sol_umolkg,cast13d.prs,'Linewidth',1.2,'Color',maroon)
% plot(cast14d.DOcorr_umolkg./cast14d.O2sol_umolkg,cast14d.prs,'Linewidth',1.2,'Color',yellow)
% plot(cast15d.DOcorr_umolkg./cast15d.O2sol_umolkg,cast15d.prs,'Linewidth',1.2,'Color',brightpurple)
% plot(cast21d.DOcorr_umolkg./cast21d.O2sol_umolkg,cast21d.prs,'Linewidth',1.2,'Color',navy)
% axis ij
% ylabel('Pres. (db)')
% xlabel('DO (% Sat)')
% title('Corrected Downcasts')