% figure
% for j = 1:7
%     subplot(1,2,1)
%     Dremin_length_all(:,j) = Dremin_length_days{j};
%     DOresp_rate_umolkg_day_all(:,j) = DOresp_rate_umolkg_day{j}; 
%     plot(Dremin_length_days{j},1:2000,'Linewidth',1.5)
%     hold on
%     axis ij
%     grid on
%     plot(nanmean(Dremin_length_all,2),1:2000,'k--','Linewidth',2)
%     xlabel('Remin Period (d)')
%      ylim([0 1500])
% end
% 
% for j = 1:7
%     subplot(1,2,2)
%     DOresp_rate_umolkg_day_all(:,j) = DOresp_rate_umolkg_day{j}; 
%     plot(DOresp_rate_umolkg_day{j}(50:2000),50:2000,'Linewidth',1.5)
%     hold on
%     plot(nanmean(DOresp_rate_umolkg_day_all(50:2000,:),2),50:2000,'k--','Linewidth',2)
%     axis ij
%     xlim([-0.3 0]); ylim([0 1500])
%     grid on
%     xlabel('Resp Rate (\mumol DO kg^-^1 d^-^1)')
% end
% sgtitle('Yearly Resp. Rates and Remin. Periods with Means')
% for j = 1:7
%     regress_prho_all(:,j) = regress_prho{j}; 
% %     plot(regress_prho{j},1:2000)
% %     hold on
% %     grid on
% %     axis ij
% %     plot(nanmean(regress_prho_all,2),1:2000,'k','Linewidth',2)
% %     xlabel('Density (kg m^-^3)')
% end
% 
% for j = 1:7
%     DOresp_season_molm3_all(:,j) = DOresp_season_molm3{j};
% end
% DOresp_season_molm3_all(1:208,3) = NaN; % Overwrite bad data year 3
% for j = 1:7
%     DOresp_season_molm3_all(Remin0(j):end,j) = NaN;
% end
% 
% Dremin_length_mean = mean(Dremin_length_all,2,'omitnan');
% Dremin_length_std = std(Dremin_length_all,0,2,'omitnan');
% DOresp_rate_umolkg_day_mean = mean(DOresp_rate_umolkg_day_all,2,'omitnan');
% DOresp_rate_umolkg_day_std = std(DOresp_rate_umolkg_day_all,0,2,'omitnan');
% DOresp_season_molm3_mean = mean(DOresp_season_molm3_all,2,'omitnan');
% DOresp_season_molm3_std = std(DOresp_season_molm3_all,0,2,'omitnan');



%%

depth_iso = 1900; % Average depth of the 3.1 isotherm 
depth = 50:depth_iso;
int_depth = 1150;

figure(10)
clf 
plot(zeros(1,length(50:depth_iso)),50:depth_iso,'k--','Linewidth',1.5)
hold on
hold on; grid on
ylabel('Pressure (dbar)')
title('Missing DO Respired during Season')
xlabel('Missing Respiration (\mumol DO kg^-^1 per season)')

figure(11)
clf
plot(DOresp_rate_umolkg_day_mean(50:depth_iso),50:depth_iso,'k--','Linewidth',1.5)
hold on
grid on
ylabel('Pressure (dbar)')
xlabel('Respiration rate (\mumol DO kg^-^1 d^-^1)')
title('Adjusted Daily Respiration Rates')

% figure(12)
% clf
% plot(DOresp_season_umolkg_mean(50:depth_iso),50:depth_iso,'k--','Linewidth',1.5)
% hold on; grid on
% ylabel('Pressure (dbar)')
% xlabel('Total Respiration (\mumol DO kg^-^1 per season)')
% title('Total Adjusted Respiration during Remineralization Period')

for j = 1:4 %3.4
    % Average density(z) and Dremin(z) from all Stratified seasons 
    regress_prho_mean = nanmean(regress_prho_all,2);
    Dremin_length_days_mean = nanmean(Dremin_length_all,2);
    
    % Rate per day calculated from respiration signal missed over length of
    % season;  
    DO_missing_umolkg_season = -j; 
    DOrate_adj_umolkg_day = DO_missing_umolkg_season./Dremin_length_days_mean(depth_iso);
    DOresp_missed_per_season = DOrate_adj_umolkg_day*Dremin_length_days_mean;

    % Adjust rate and calculate DO respired per season 
    DOresp_rate_umolkg_day_mean = nanmean(DOresp_rate_umolkg_day_all,2);
    DOresp_rate_umolkg_day_adj = DOresp_rate_umolkg_day_mean + DOrate_adj_umolkg_day; 
    
    DOresp_season_umolkg_mean = DOresp_rate_umolkg_day_mean.*Dremin_length_days_mean;
    DOresp_season_umolkg_adj = DOresp_rate_umolkg_day_adj.*Dremin_length_days_mean;
    
    DOresp_season_molm3_mean = DOresp_season_umolkg_mean.*regress_prho_mean/(1000*1000);
    DOresp_season_molm3_adj = DOresp_season_umolkg_adj.*regress_prho_mean/(1000*1000);
    DOresp_season_molm3_adj(DOresp_rate_umolkg_day_adj > 0) = 0; % to Remove any positive values 

    export_DOinventory_molm2_mean = min(cumsum(DOresp_season_molm3_mean(50:depth_iso)));
    export_DOinventory_molm2_adj = min(cumsum(DOresp_season_molm3_adj(50:depth_iso)));
    
    export_Cinventory_molm2_mean = export_DOinventory_molm2_mean*-0.69
    export_Cinventory_molm2_adj = export_DOinventory_molm2_adj*-0.69

    figure(10)
    plot(DOresp_missed_per_season(50:depth_iso),50:depth_iso,'Linewidth',1.5)
    axis ij
    hold on

    figure(11)
    plot(DOresp_rate_umolkg_day_adj(50:depth_iso),50:depth_iso,'Linewidth',1.5)
    hold on
    axis ij

    figure(12)
    plot(DOresp_season_umolkg_adj(50:depth_iso),50:depth_iso,'Linewidth',1.5)
    hold on
    axis ij


end

figure(11)
legend('No Resp at 1900','1 \mumol/kg per yr at 1900','2 \mumol/kg per yr at 1900','3 \mumol/kg per yr at 1900','4 \mumol/kg per yr at 1900','Location','SW')


%%
adj_umol = [0 1 2 3 4];
adj_C = [export_Cinventory_molm2_mean export_Cinventory_molm2_adj];
% for 1:4, didn't feel like changing code above 
adj_C = [export_Cinventory_molm2_mean 6.8115 7.9358 9.0781 10.2203];
figure
bar(adj_umol,adj_C)
ylabel([{'Seasonal Export (mol C m^-^2 yr^-^1)'} {'adjusted for removed respiration signal'}])
xlabel([{'respiration signal (\mumol DO kg^-^1 per season)'} {'removed with deep isotherm correction'}])
grid on