depth_iso = 1900; % Average depth of the 3.1 isotherm 
depth = 50:depth_iso;
int_depth = 1150;

figure(100)
clf 
plot(zeros(1,length(50:depth_iso)),50:depth_iso,'k--','Linewidth',1.5)
hold on
hold on; grid on
ylabel('Pressure (dbar)')
title('Missing DO Respired during Season')
xlabel('Missing Respiration (\mumol DO kg^-^1 per season)')

figure(200)
clf
plot(DOresp_rate_umolkg_day_mean(50:depth_iso),50:depth_iso,'k--','Linewidth',1.5)
hold on
grid on
ylabel('Pressure (dbar)')
xlabel('Respiration rate (\mumol DO kg^-^1 d^-^1)')
title('Adjusted Daily Respiration Rates')


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
    
    export_Cinventory_molm2_mean = export_DOinventory_molm2_mean*-0.69;
    export_Cinventory_molm2_adj = export_DOinventory_molm2_adj*-0.69;
    export_Cinventory_molm2_adj_plot(j) = export_DOinventory_molm2_adj*-0.69;

    figure(100)
    plot(DOresp_missed_per_season(50:depth_iso),50:depth_iso,'Linewidth',1.5)
    axis ij
    hold on

    figure(200)
    plot(DOresp_rate_umolkg_day_adj(50:depth_iso),50:depth_iso,'Linewidth',1.5)
    hold on
    axis ij

end

figure(200)
legend('No Resp at 1900','1 \mumol/kg per yr at 1900','2 \mumol/kg per yr at 1900','3 \mumol/kg per yr at 1900','4 \mumol/kg per yr at 1900','Location','SW')


%%
adj_umol = [0 1 2 3 4];
adj_C = [export_Cinventory_molm2_mean export_Cinventory_molm2_adj_plot];

figure
bar(adj_umol,adj_C)
ylabel([{'Mean Seasonal Export (mol C m^-^2 yr^-^1)'} {'adjusted for removed respiration signal'}])
xlabel([{'respiration signal (\mumol DO kg^-^1 per season)'} {'removed with deep isotherm correction'}])
grid on