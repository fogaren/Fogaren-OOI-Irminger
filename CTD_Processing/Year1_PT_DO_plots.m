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
% plotm(cast04u.lat(1),cast04u.lon(1),'.','markersize',30,'Color',purple)
plotm(cast05u.lat(1),cast05u.lon(1),'.','markersize',30,'Color',navy)
plotm(cast06u.lat(1),cast06u.lon(1),'.','markersize',30,'Color',cyan)
plotm(cast07u.lat(1),cast07u.lon(1),'.','markersize',30,'Color',blue)
% plotm(cast08u.lat(1),cast08u.lon(1),'.','markersize',30,'Color',purple)
plotm(cast09u.lat(1),cast09u.lon(1),'.','markersize',30,'Color',red)
% plotm(cast10u.lat(1),cast10u.lon(1),'.','markersize',30,'Color',cyan)
% plotm(cast11u.lat(1),cast11u.lon(1),'.','markersize',30,'Color',red)
% plotm(cast12u.lat(1),cast12u.lon(1),'.','markersize',30,'Color',green)
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

title('Irminger 1: CTD Casts')
legend('','OOI Asset','Cast 5','Cast 6','Cast 7',...
    'Cast 9','Location','southoutside')

subplot(1,3,2)
% plot(cast04d.DOcorr_umolkg,cast04d.pt,'Linewidth',1.2,'Color',purple)
% hold on
plot(cast05d.DOcorr_umolkg,cast05d.pt,'Linewidth',1.2,'Color',navy)
hold on
plot(cast06d.DOcorr_umolkg,cast06d.pt,'Linewidth',1.2,'Color',cyan)
plot(cast07d.DOcorr_umolkg,cast07d.pt,'Linewidth',1.2,'Color',blue)
% plot(cast08d.DOcorr_umolkg,cast08d.pt,'Linewidth',1.2,'Color',purple)
plot(cast09d.DOcorr_umolkg,cast09d.pt,'Linewidth',1.2,'Color',red)
% plot(cast10d.DOcorr_umolkg,cast10d.pt,'Linewidth',1.2,'Color',cyan)
% plot(cast10d.DOcorr_umolkg,cast10d.pt,'Linewidth',1.2,'Color',cyan)
% plot(cast12d.DOcorr_umolkg,cast12d.pt,'Linewidth',1.2,'Color',green)
% plot(cast14d.DOcorr_umolkg,cast14d.pt,'Linewidth',1.2,'Color',yellow)
% plot(cast15d.DOcorr_umolkg,cast15d.pt,'Linewidth',1.2,'Color',brightpurple)
% plot(cast21d.DOcorr_umolkg,cast21d.pt,'Linewidth',1.2,'Color',navy)
grid on
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Downcasts')

subplot(1,3,3)
plot(btlsum05.Winkler_umolkg,btlsum05.pt,'.k','markersize',20)
hold on
% plot(cast04u.DOcorr_umolkg,cast04u.pt,'Linewidth',1.2,'Color',purple)
% hold on
plot(cast05u.DOcorr_umolkg,cast05u.pt,'Linewidth',1.2,'Color',navy)
plot(cast06u.DOcorr_umolkg,cast06u.pt,'Linewidth',1.2,'Color',cyan)
plot(cast07u.DOcorr_umolkg,cast07u.pt,'Linewidth',1.2,'Color',blue)
% plot(cast08u.DOcorr_umolkg,cast08u.pt,'Linewidth',1.2,'Color',purple)
plot(cast09u.DOcorr_umolkg,cast09u.pt,'Linewidth',1.2,'Color',red)
% plot(cast12u.DOcorr_umolkg,cast12u.pt,'Linewidth',1.2,'Color',green)
% plot(cast13u.DOcorr_umolkg,cast13u.pt,'Linewidth',1.2,'Color',maroon)
% plot(cast14u.DOcorr_umolkg,cast14u.pt,'Linewidth',1.2,'Color',yellow)
% plot(cast15u.DOcorr_umolkg,cast15u.pt,'Linewidth',1.2,'Color',brightpurple)
% plot(cast21u.DOcorr_umolkg,cast21u.pt,'Linewidth',1.2,'Color',navy)
% plot(btlsum_yr8.Discrete_Salinity_psu,btlsum_yr8.pt,'.k','markersize',20)
plot(btlsum05.Winkler_umolkg,btlsum05.pt,'.k','markersize',20)
plot(btlsum06.Winkler_umolkg,btlsum06.pt,'.k','markersize',20)
plot(btlsum07.Winkler_umolkg,btlsum07.pt,'.k','markersize',20)
plot(btlsum09.Winkler_umolkg,btlsum09.pt,'.k','markersize',20)
legend('Winklers','Location','SW')
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on
sgtitle('Year 1')

