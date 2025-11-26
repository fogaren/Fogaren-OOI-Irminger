% Pull in all processed oxygen data and compare Years 1-9 to each other
clearvars
cd('G:\My Drive\Matlab_work\BC')
run('GeneralSettings.m')

cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Processed')
load Year1_Processed_KF.mat
load Year2_Processed_KF.mat
load Year3_Processed_KF.mat
load Year4_Processed_KF.mat
load Year5_Processed_KF.mat
load Year6_Processed_KF.mat
load Year7_Processed_KF.mat
load Year8_Processed_KF.mat
load Year9_Processed_KF.mat

load AllYears_Processed_KF.mat 
%% OOI radius
% meg is using 40 km 
% hilary is using 20 km (10 km in cruise_oxygen code)
% Will redo with final number before publication 

% GIlatlon = [];
addpath(genpath('G:\My Drive\Matlab_work\Github\OOI_Irminger_students'))
load OOImooringLocations
OOIradius = 10;

% Need to update with Mooring location for each year
% Right now using mooring location from Year 5. 
% ex: if distlatlon(OOImoorings.HYPM5(1), nanmean(downcasts{yr}{ii}.lat), OOImoorings.HYPM5(2), nanmean(downcasts{yr}{ii}.lon)) <= OOIradius 

ind1 = NaN(height(btlsum_tbl_yr1),1);
for i = 1:height(btlsum_tbl_yr1)
    d = distlatlon(OOImoorings.HYPM5(1),nanmean(btlsum_tbl_yr1.lat(i)),OOImoorings.HYPM5(2), nanmean(btlsum_tbl_yr1.lon(i)));
    if d < OOIradius
        ind1(i) = 1;
    else ind1(i) = 0;
    end
end

ind2 = NaN(height(btlsum_tbl_yr2),1);
for i = 1:height(btlsum_tbl_yr2)
    d = distlatlon(OOImoorings.HYPM5(1),nanmean(btlsum_tbl_yr2.lat(i)),OOImoorings.HYPM5(2), nanmean(btlsum_tbl_yr2.lon(i)));
    if d < OOIradius
        ind2(i) = 1;
    else ind2(i) = 0;
    end
end

ind3 = NaN(height(btlsum_tbl_yr3),1); 
for i = 1:height(btlsum_tbl_yr3)
    d = distlatlon(OOImoorings.HYPM5(1),nanmean(btlsum_tbl_yr3.lat(i)),OOImoorings.HYPM5(2), nanmean(btlsum_tbl_yr3.lon(i)));
    if d < OOIradius
        ind3(i) = 1;
    else ind3(i) = 0;
    end
end

ind4 = NaN(height(btlsum_tbl_yr4),1);
for i = 1:height(btlsum_tbl_yr4)
    d = distlatlon(OOImoorings.HYPM5(1),nanmean(btlsum_tbl_yr4.lat(i)),OOImoorings.HYPM5(2), nanmean(btlsum_tbl_yr4.lon(i)));
    if d < OOIradius
        ind4(i) = 1;
    else ind4(i) = 0;
    end
end

ind5 = NaN(height(btlsum_tbl_yr5),1); 
for i = 1:height(btlsum_tbl_yr5)
    d = distlatlon(OOImoorings.HYPM5(1),nanmean(btlsum_tbl_yr5.lat(i)),OOImoorings.HYPM5(2), nanmean(btlsum_tbl_yr5.lon(i)));
    if d < OOIradius
        ind5(i) = 1;
    else ind5(i) = 0;
    end
end

ind6 = NaN(height(btlsum_tbl_yr6),1); 
for i = 1:height(btlsum_tbl_yr6)
    d = distlatlon(OOImoorings.HYPM5(1),nanmean(btlsum_tbl_yr6.lat(i)),OOImoorings.HYPM5(2), nanmean(btlsum_tbl_yr6.lon(i)));
    if d < OOIradius
        ind6(i) = 1;
    else ind6(i) = 0;
    end
end

ind8 = NaN(height(btlsum_tbl_yr8),1); 
for i = 1:height(btlsum_tbl_yr8)
    d = distlatlon(OOImoorings.HYPM5(1),nanmean(btlsum_tbl_yr8.lat(i)),OOImoorings.HYPM5(2), nanmean(btlsum_tbl_yr8.lon(i)));
    if d < OOIradius
        ind8(i) = 1;
    else ind8(i) = 0;
    end
end

ind9 = NaN(height(btlsum_tbl_yr9),1); 
for i = 1:height(btlsum_tbl_yr9)
    d = distlatlon(OOImoorings.HYPM5(1),nanmean(btlsum_tbl_yr9.lat(i)),OOImoorings.HYPM5(2), nanmean(btlsum_tbl_yr9.lon(i)));
    if d < OOIradius
        ind9(i) = 1;
    else ind9(i) = 0;
    end
end
%%
figure
plot(NaN,NaN,'.','MarkerSize',20,'Color',maroon); hold on
plot(NaN,NaN,'.','MarkerSize',20,'Color',red)
plot(NaN,NaN,'.','MarkerSize',20,'Color',yellow)
plot(NaN,NaN,'.','MarkerSize',20,'Color',green)
plot(NaN,NaN,'.','MarkerSize',20,'Color',forestgreen)
plot(NaN,NaN,'.','MarkerSize',20,'Color',blue)
plot(NaN,NaN,'.','MarkerSize',20,'Color',navy)
plot(NaN,NaN,'.','MarkerSize',20,'Color',purple)
plot(NaN,NaN,'.','MarkerSize',20,'Color',brightpurple)
plot(btlsum_tbl_yr1.Winkler1_umolkg(ind1 == 1),btlsum_tbl_yr1.pt(ind1 == 1),'.','MarkerSize',20','Color',maroon)
plot(btlsum_tbl_yr1.Winkler2_umolkg(ind1 == 1),btlsum_tbl_yr1.pt(ind1 == 1),'.','MarkerSize',20','Color',maroon)
plot(btlsum_tbl_yr2.Winkler_umolkg(btlsum_tbl_yr2.NLMR_Outlier == 2 & ind2 == 1),...
    btlsum_tbl_yr2.pt(btlsum_tbl_yr2.NLMR_Outlier == 2 & ind2 == 1),'.','MarkerSize',20','Color',red)
plot(btlsum_tbl_yr3.Winkler_umolkg(btlsum_tbl_yr3.NLMR_Outlier ==2 & ind3 == 1),...
    btlsum_tbl_yr3.pt(btlsum_tbl_yr3.NLMR_Outlier == 2 & ind3 == 1),'.','MarkerSize',20','Color',yellow)
plot(btlsum_tbl_yr4.Winkler_umolkg(btlsum_tbl_yr4.NLMR_Outlier ==2 & ind4 == 1),...
    btlsum_tbl_yr4.pt(btlsum_tbl_yr4.NLMR_Outlier == 2 & ind4 == 1),'.','MarkerSize',20','Color',green)
plot(btlsum_tbl_yr5.Winkler_OOI_umolkg(btlsum_tbl_yr5.NLMR_OOI_Outlier == 2 & ind5 == 1),...
    btlsum_tbl_yr5.pt(btlsum_tbl_yr5.NLMR_OOI_Outlier == 2 & ind5 == 1),'.','MarkerSize',20','Color',forestgreen)
plot(btlsum_tbl_yr5.Winkler1_HIP_umolkg(btlsum_tbl_yr5.NLMR_HIP1_Outlier == 2 & ind5 == 1),...
    btlsum_tbl_yr5.pt(btlsum_tbl_yr5.NLMR_HIP1_Outlier == 2 & ind5 == 1),'.','MarkerSize',20','Color',forestgreen)
plot(btlsum_tbl_yr5.Winkler2_HIP_umolkg(btlsum_tbl_yr5.NLMR_HIP2_Outlier == 2 & ind5 == 1),...
    btlsum_tbl_yr5.pt(btlsum_tbl_yr5.NLMR_HIP2_Outlier == 2 & ind5 == 1),'.','MarkerSize',20','Color',forestgreen)
plot(btlsum_tbl_yr6.Winkler1_umolkg(ind6 == 1),...
    btlsum_tbl_yr6.pt(ind6 == 1),'.','MarkerSize',20','Color',blue)
plot(btlsum_tbl_yr6.Winkler2_umolkg(ind6 == 1),...
    btlsum_tbl_yr6.pt(ind6 == 1),'.','MarkerSize',20','Color',blue)
plot(btlsum_tbl_yr6.Winkler3_umolkg(ind6 == 1),...
    btlsum_tbl_yr6.pt(ind6 == 1),'.','MarkerSize',20','Color',blue)
plot(btlsum_tbl_yr6.Winkler4_umolkg(ind6 == 1),...
    btlsum_tbl_yr6.pt(ind6 == 1),'.','MarkerSize',20','Color',blue)
plot(btlsum_tbl_yr8.Winkler_umolkg(btlsum_tbl_yr8.NLMR_Outlier ==2  & ind8 == 1),...
    btlsum_tbl_yr8.pt(btlsum_tbl_yr8.NLMR_Outlier == 2  & ind8 == 1),'.','MarkerSize',20','Color',purple)
plot(btlsum_tbl_yr9.Winkler1_umolkg(btlsum_tbl_yr9.NLMR_Outlier1 ==2 & ind9 == 1),...
    btlsum_tbl_yr9.pt(btlsum_tbl_yr9.NLMR_Outlier1 == 2 & ind9 == 1),'.','MarkerSize',20','Color',brightpurple)
plot(btlsum_tbl_yr9.Winkler2_umolkg(btlsum_tbl_yr9.NLMR_Outlier2 ==2 & ind9 == 1),...
    btlsum_tbl_yr9.pt(btlsum_tbl_yr9.NLMR_Outlier2 == 2 & ind9 == 1),'.','MarkerSize',20','Color',brightpurple)
plot(btlsum_tbl_yr9.Winkler3_umolkg(btlsum_tbl_yr9.NLMR_Outlier3 ==2 & ind9 == 1),...
    btlsum_tbl_yr9.pt(btlsum_tbl_yr9.NLMR_Outlier3 == 2 & ind9 == 1),'.','MarkerSize',20','Color',brightpurple)
axis([270 310 1 5])
grid on
ylabel('PT (\circ C)'); xlabel('Winkler Dissolved Oxygen (\mumol kg^-^1)')
lgd = legend('2014','2015','2016','2017','2018','2019','2020','2021','2022',...
    'Location','northeastoutside');
lgd.Title.String = 'Cruise Year';
title(['Winklers within ' num2str(OOIradius) ' km of OOI HYPM'])

%%

figure
plot(NaN,NaN,'.','MarkerSize',20,'Color',maroon); hold on
plot(NaN,NaN,'.','MarkerSize',20,'Color',red)
plot(NaN,NaN,'.','MarkerSize',20,'Color',yellow)
plot(NaN,NaN,'.','MarkerSize',20,'Color',green)
plot(NaN,NaN,'.','MarkerSize',20,'Color',forestgreen)
plot(NaN,NaN,'.','MarkerSize',20,'Color',blue)
plot(NaN,NaN,'.','MarkerSize',20,'Color',navy)
plot(NaN,NaN,'.','MarkerSize',20,'Color',purple)
plot(NaN,NaN,'.','MarkerSize',20,'Color',brightpurple)

plot(btlsum_tbl_yr1.Winkler1_umolkg,btlsum_tbl_yr1.prho,'.','MarkerSize',20','Color',maroon)
plot(btlsum_tbl_yr1.Winkler2_umolkg,btlsum_tbl_yr1.prho,'.','MarkerSize',20','Color',maroon)
plot(btlsum_tbl_yr2.Winkler_umolkg(btlsum_tbl_yr2.NLMR_Outlier == 2),...
    btlsum_tbl_yr2.prho(btlsum_tbl_yr2.NLMR_Outlier == 2),'.','MarkerSize',20','Color',red)
plot(btlsum_tbl_yr3.Winkler_umolkg(btlsum_tbl_yr3.NLMR_Outlier ==2),...
    btlsum_tbl_yr3.prho(btlsum_tbl_yr3.NLMR_Outlier == 2),'.','MarkerSize',20','Color',yellow)
plot(btlsum_tbl_yr4.Winkler_umolkg(btlsum_tbl_yr4.NLMR_Outlier ==2),...
    btlsum_tbl_yr4.prho(btlsum_tbl_yr4.NLMR_Outlier == 2),'.','MarkerSize',20','Color',green)
plot(btlsum_tbl_yr5.Winkler_OOI_umolkg(btlsum_tbl_yr5.NLMR_OOI_Outlier == 2),...
    btlsum_tbl_yr5.prho(btlsum_tbl_yr5.NLMR_OOI_Outlier == 2),'.','MarkerSize',20','Color',forestgreen)
plot(btlsum_tbl_yr5.Winkler1_HIP_umolkg(btlsum_tbl_yr5.NLMR_HIP1_Outlier == 2),...
    btlsum_tbl_yr5.prho(btlsum_tbl_yr5.NLMR_HIP1_Outlier == 2),'.','MarkerSize',20','Color',forestgreen)
plot(btlsum_tbl_yr5.Winkler2_HIP_umolkg(btlsum_tbl_yr5.NLMR_HIP2_Outlier == 2),...
    btlsum_tbl_yr5.prho(btlsum_tbl_yr5.NLMR_HIP2_Outlier == 2),'.','MarkerSize',20','Color',forestgreen)
plot(btlsum_tbl_yr6.Winkler1_umolkg,...
    btlsum_tbl_yr6.prho,'.','MarkerSize',20','Color',blue)
plot(btlsum_tbl_yr6.Winkler2_umolkg,...
    btlsum_tbl_yr6.prho,'.','MarkerSize',20','Color',blue)
plot(btlsum_tbl_yr6.Winkler3_umolkg,...
    btlsum_tbl_yr6.prho,'.','MarkerSize',20','Color',blue)
plot(btlsum_tbl_yr6.Winkler4_umolkg,...
    btlsum_tbl_yr6.prho,'.','MarkerSize',20','Color',blue)
plot(btlsum_tbl_yr8.Winkler_umolkg(btlsum_tbl_yr8.NLMR_Outlier ==2),...
    btlsum_tbl_yr8.prho(btlsum_tbl_yr8.NLMR_Outlier == 2),'.','MarkerSize',20','Color',purple)
plot(btlsum_tbl_yr9.Winkler1_umolkg(btlsum_tbl_yr9.NLMR_Outlier1 ==2),...
    btlsum_tbl_yr9.prho(btlsum_tbl_yr9.NLMR_Outlier1 == 2),'.','MarkerSize',20','Color',brightpurple)
plot(btlsum_tbl_yr9.Winkler2_umolkg(btlsum_tbl_yr9.NLMR_Outlier2 ==2),...
    btlsum_tbl_yr9.prho(btlsum_tbl_yr9.NLMR_Outlier2 == 2),'.','MarkerSize',20','Color',brightpurple)
plot(btlsum_tbl_yr9.Winkler3_umolkg(btlsum_tbl_yr9.NLMR_Outlier3 ==2),...
     btlsum_tbl_yr9.prho(btlsum_tbl_yr9.NLMR_Outlier3 == 2),'.','MarkerSize',20','Color',brightpurple)
axis([270 310 1027.75 1028])
grid on
axis ij
ylabel('potential density (kg m^-^3)'); xlabel('Winkler Dissolved Oxygen (\mumol kg^-^1)')
lgd = legend('2014','2015','2016','2017','2018','2019','2020','2021','2022',...
    'Location','northeastoutside');
lgd.Title.String = 'Cruise Year';




%%


colors = [maroon; red; yellow; green; forestgreen; blue; navy; purple; brightpurple];
figure
for i = 1:9
    subplot(3,3,i)
        for yr = 1:9
            for ii = 1:length(cast_num{yr})
                try 
                    if distlatlon(OOImoorings.HYPM5(1), nanmean(downcasts{yr}{ii}.lat), OOImoorings.HYPM5(2), nanmean(downcasts{yr}{ii}.lon)) <= OOIradius  
                        plot(downcasts{yr}{ii}.DOcorr_umolkg,downcasts{yr}{ii}.pt,'Linewidth',1,'Color',grey); hold on                         
                    end
                end
                try
                    if distlatlon(OOImoorings.HYPM5(1), nanmean(downcasts{i}{ii}.lat), OOImoorings.HYPM5(2), nanmean(downcasts{i}{ii}.lon)) <= OOIradius
                        plot(downcasts{i}{ii}.DOcorr_umolkg,downcasts{i}{ii}.pt,'Linewidth',1.5,'Color',colors(i,:))
                        plot(upcasts{i}{ii}.DOcorr_umolkg,upcasts{i}{ii}.pt,'Linewidth',1.5,'Color',colors(i,:))
                    end
                end
            end
        end
    ylabel('pot. temp (\circC)'); xlabel('CTD DO (\mumol kg ^-^1)')
    title(['Year: ' num2str(2013 + i)])

    axis([260 320 0 12]); 
    grid on
end
sgtitle(['Calibrated CTD-DO within ' num2str(OOIradius) ' km'])

figure
for i = 1:9
    subplot(3,3,i)
        for yr = 1:9
            for ii = 1:length(cast_num{yr})
                try
                    if distlatlon(OOImoorings.HYPM5(1), nanmean(downcasts{i}{ii}.lat), OOImoorings.HYPM5(2), nanmean(downcasts{i}{ii}.lon)) <= OOIradius
                        plot(downcasts{i}{ii}.DOcorr_umolkg,downcasts{i}{ii}.pt,'Linewidth',1.5,'Color',colors(i,:)); hold on
                        plot(upcasts{i}{ii}.DOcorr_umolkg,upcasts{i}{ii}.pt,'Linewidth',1.5,'Color',colors(i,:))
                    end
                end
            end
        end
    ylabel('pot. temp (\circC)'); xlabel('CTD DO (\mumol kg ^-^1)')
    title(['Year: ' num2str(2013 + i)])

    axis([260 320 1 4]); 
    grid on
end
sgtitle(['Calibrated CTD-DO within ' num2str(OOIradius) ' km of OOI GI HYPM'])

figure
for i = 1:9
    plot(NaN,NaN,'.','MarkerSize',20,'Color',colors(i,:)); hold on
end
for i = 1:9
        for yr = 1:9
            for ii = 1:length(cast_num{yr})
                try
                    if distlatlon(OOImoorings.HYPM5(1), nanmean(downcasts{i}{ii}.lat), OOImoorings.HYPM5(2), nanmean(downcasts{i}{ii}.lon)) <= OOIradius
                        plot(downcasts{i}{ii}.DOcorr_umolkg,downcasts{i}{ii}.pt,'Linewidth',1.5,'Color',colors(i,:)); hold on
                        plot(upcasts{i}{ii}.DOcorr_umolkg,upcasts{i}{ii}.pt,'Linewidth',1.5,'Color',colors(i,:))
                    end
                end
            end
        end
    ylabel('pot. temp (\circC)'); xlabel('CTD DO (\mumol kg ^-^1)')
    axis([260 320 1 4]); 
    grid on
end
legend('2014','2015','2016','2017','2018','2019','2020','2021','2022','Location','northeastoutside')
title(['Calibrated CTD-DO within ' num2str(OOIradius) ' km'])

