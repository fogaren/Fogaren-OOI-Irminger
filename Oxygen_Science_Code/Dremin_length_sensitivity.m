%% This is done on the daily average timeseries 
% Create empty output variables 
DOresp_rate_umolkg_day_first100 = [];
DOresp_rate_umolkg_day_95CI_high_first100 = [];
DOresp_rate_umolkg_day_95CI_low_first100 = []; 

DOresp_rate_mmolm3_day_first100 = [];
DOresp_rate_mmolm3_day_95CI_high_first100 = [];
DOresp_rate_mmolm3_day_95CI_low_first100 = [];
b_umolkg_first100 = [];
p_value_first100 = [];
R2_first100 = [];
DFE_first100 = [];
regress_days_first100 = []; 
Dremin_length_days_first100 = [];
DOresp_season_umolkg_first100 = []; % rate (slope) *resp_days 
DOresp_season_umolkg_95CI_high_first100 = []; % rate (slope) *resp_days 
DOresp_season_umolkg_95CI_low_first100 = []; % rate (slope) *resp_days 
regress_prho_first100 = [];
regress_temp_first100 = []; 
DOresp_season_molm3_first100 = []; 
DOresp_season_molm3_95CI_high_first100 = [];
DOresp_season_molm3_95CI_low_first100 = [];

% This is done on the daily average timeseries 
% Create empty output variables 
DOresp_rate_umolkg_day_mid100 = [];
DOresp_rate_umolkg_day_95CI_high_mid100 = [];
DOresp_rate_umolkg_day_95CI_low_mid100 = []; 

DOresp_rate_mmolm3_day_mid100 = [];
DOresp_rate_mmolm3_day_95CI_high_mid100 = [];
DOresp_rate_mmolm3_day_95CI_low_mid100 = [];
b_umolkg_mid100 = [];
p_value_mid100 = [];
R2_mid100 = [];
DFE_mid100 = [];
regress_days_mid100 = []; 
Dremin_length_days_mid100 = [];
DOresp_season_umolkg_mid100 = []; % rate (slope) *resp_days 
DOresp_season_umolkg_95CI_high_mid100 = []; % rate (slope) *resp_days 
DOresp_season_umolkg_95CI_low_mid100 = []; % rate (slope) *resp_days 
regress_prho_mid100 = [];
regress_temp_mid100 = []; 
DOresp_season_molm3_mid100 = []; 
DOresp_season_molm3_95CI_high_mid100 = [];
DOresp_season_molm3_95CI_low_mid100 = [];

% This is done on the daily average timeseries 
% Create empty output variables 
DOresp_rate_umolkg_day_last100 = [];
DOresp_rate_umolkg_day_95CI_high_last100 = [];
DOresp_rate_umolkg_day_95CI_low_last100 = []; 

DOresp_rate_mmolm3_day_last100 = [];
DOresp_rate_mmolm3_day_95CI_high_last100 = [];
DOresp_rate_mmolm3_day_95CI_low_last100 = [];
b_umolkg_last100 = [];
p_value_last100 = [];
R2_last100 = [];
DFE_last100 = [];
regress_days_last100 = []; 
Dremin_length_days_last100 = [];
DOresp_season_umolkg_last100 = []; % rate (slope) *resp_days 
DOresp_season_umolkg_95CI_high_last100 = []; % rate (slope) *resp_days 
DOresp_season_umolkg_95CI_low_last100 = []; % rate (slope) *resp_days 
regress_prho_last100 = [];
regress_temp_last100 = []; 
DOresp_season_molm3_last100 = []; 
DOresp_season_molm3_95CI_high_last100 = [];
DOresp_season_molm3_95CI_low_last100 = [];


%% Split years into 3 thirds

% Length of max remineralization period divided by three

for j = 1:7
    resp_first(j) = resp_start{j}(2000) + (resp_end{j}(2000) - resp_start{j}(2000))/3;
    resp_mid(j) = resp_first(j) + (resp_end{j}(2000) - resp_start{j}(2000))/3;
end

%%
for j = 1:7

    for z = 1:2000
        if resp_first(j) > resp_start{j}(z)
            [resp_start_z,~] = find(daily.time > resp_start{j}(z),1,'first');
            [resp_end_z,~] = find(daily.time < resp_first(j),1,'last');
            resp_ind = resp_start_z:resp_end_z;
            Dremin_days = daily.time(resp_ind) - daily.time(resp_ind(1));
            dt_days = Dremin_days; 
            
            % Oxygen and density outliers have already been removed 
            mdl = fitlm(dt_days,daily.doxy(z,resp_ind));
            CI = mdl.coefCI;
    
            regress_prho_first100{j}(z) = mean(daily.prho(z,resp_ind),'omitnan');
            regress_temp_first100{j}(z) = mean(daily.temp(z,resp_ind),'omitnan');
                    
        else 
            Dremin_days = 0; 
            dt_days = 0; 
            resp_start_z = NaN;
            resp_end_z = NaN; 
            mdl = fitlm(NaN,NaN);
            regress_prho_first100{j}(z) = NaN;
            CI(1:2,1:2) = 0;
            resp_ind = 0;  
        end


        % Stores them by actual depth 
        DOresp_rate_umolkg_day_first100{j}(z) = mdl.Coefficients.Estimate(2);
        DOresp_rate_umolkg_day_95CI_high_first100{j}(z) = CI(2,1);
        DOresp_rate_umolkg_day_95CI_low_first100{j}(z) = CI(2,2); 

        b_umolkg_first100{j}(z) = mdl.Coefficients.Estimate(1);
        p_value_first100{j}(z) = mdl.Coefficients.pValue(2);
        R2_first100{j}(z) = mdl.Rsquared.Ordinary;
        DFE_first100{j}(z) = mdl.DFE;
        regress_days_first100{j}(z) = max(dt_days); 
        Dremin_length_days_first100{j}(z) = max(Dremin_days); 

        DOresp_season_umolkg_first100{j}(z) = mdl.Coefficients.Estimate(2)*Dremin_length_days_first100{j}(z); % rate (slope) *resp_days
        DOresp_season_umolkg_95CI_high_first100{j}(z) = CI(2,1)*Dremin_length_days_first100{j}(z); % rate (slope) *resp_days
        DOresp_season_umolkg_95CI_low_first100{j}(z) = CI(2,2)*Dremin_length_days_first100{j}(z);% rate (slope) *resp_days

        DOresp_rate_mmolm3_day_first100{j}(z) = (mdl.Coefficients.Estimate(2).*regress_prho_first100{j}(z))/(1000*1000); % rate (slope) *resp_days
        DOresp_rate_mmolm3_day_95CI_high_first100{j}(z) = (CI(2,1).*regress_prho_first100{j}(z))/(1000*1000); % rate (slope) *resp_days
        DOresp_rate_mmolm3_day_95CI_low_first100{j}(z) = (CI(2,2).*regress_prho_first100{j}(z))/(1000*1000);% rate (slope) *resp_days

        DOresp_season_molm3_first100{j}(z) = (DOresp_season_umolkg_first100{j}(z).*regress_prho_first100{j}(z))/(1000*1000);
        DOresp_season_molm3_95CI_high_first100{j}(z) = (DOresp_season_umolkg_95CI_high_first100{j}(z).*regress_prho_first100{j}(z))/(1000*1000);
        DOresp_season_molm3_95CI_low_first100{j}(z) = (DOresp_season_umolkg_95CI_low_first100{j}(z).*regress_prho_first100{j}(z))/(1000*1000);
    end
end
%%
for j = 1:7

    for z = 1:2000
        if resp_first(j) > resp_start{j}(z)
            [resp_start_z,~] = find(daily.time > resp_first(j),1,'first');
            [resp_end_z,~] = find(daily.time < resp_mid(j),1,'last');
            resp_ind = resp_start_z:resp_end_z;
            Dremin_days = daily.time(resp_ind) - daily.time(resp_ind(1));
            dt_days = Dremin_days; 
            
            % Oxygen and density outliers have already been removed 
            mdl = fitlm(dt_days,daily.doxy(z,resp_ind));
            CI = mdl.coefCI;
    
            regress_prho_mid100{j}(z) = mean(daily.prho(z,resp_ind),'omitnan');
            regress_temp_mid100{j}(z) = mean(daily.temp(z,resp_ind),'omitnan');
                    
        else 
            Dremin_days = 0; 
            dt_days = 0; 
            resp_start_z = NaN;
            resp_end_z = NaN; 
            mdl = fitlm(NaN,NaN);
            regress_prho_mid100{j}(z) = NaN;
            CI(1:2,1:2) = 0;
            resp_ind = 0;  
        end


        % Stores them by actual depth 
        DOresp_rate_umolkg_day_mid100{j}(z) = mdl.Coefficients.Estimate(2);
        DOresp_rate_umolkg_day_95CI_high_mid100{j}(z) = CI(2,1);
        DOresp_rate_umolkg_day_95CI_low_mid100{j}(z) = CI(2,2); 

        b_umolkg_mid100{j}(z) = mdl.Coefficients.Estimate(1);
        p_value_mid100{j}(z) = mdl.Coefficients.pValue(2);
        R2_mid100{j}(z) = mdl.Rsquared.Ordinary;
        DFE_mid100{j}(z) = mdl.DFE;
        regress_days_mid100{j}(z) = max(dt_days); 
        Dremin_length_days_mid100{j}(z) = max(Dremin_days); 

        DOresp_season_umolkg_mid100{j}(z) = mdl.Coefficients.Estimate(2)*Dremin_length_days_mid100{j}(z); % rate (slope) *resp_days
        DOresp_season_umolkg_95CI_high_mid100{j}(z) = CI(2,1)*Dremin_length_days_mid100{j}(z); % rate (slope) *resp_days
        DOresp_season_umolkg_95CI_low_mid100{j}(z) = CI(2,2)*Dremin_length_days_mid100{j}(z);% rate (slope) *resp_days

        DOresp_rate_mmolm3_day_mid100{j}(z) = (mdl.Coefficients.Estimate(2).*regress_prho_mid100{j}(z))/(1000*1000); % rate (slope) *resp_days
        DOresp_rate_mmolm3_day_95CI_high_mid100{j}(z) = (CI(2,1).*regress_prho_mid100{j}(z))/(1000*1000); % rate (slope) *resp_days
        DOresp_rate_mmolm3_day_95CI_low_mid100{j}(z) = (CI(2,2).*regress_prho_mid100{j}(z))/(1000*1000);% rate (slope) *resp_days

        DOresp_season_molm3_mid100{j}(z) = (DOresp_season_umolkg_mid100{j}(z).*regress_prho_mid100{j}(z))/(1000*1000);
        DOresp_season_molm3_95CI_high_mid100{j}(z) = (DOresp_season_umolkg_95CI_high_mid100{j}(z).*regress_prho_mid100{j}(z))/(1000*1000);
        DOresp_season_molm3_95CI_low_mid100{j}(z) = (DOresp_season_umolkg_95CI_low_mid100{j}(z).*regress_prho_mid100{j}(z))/(1000*1000);
    end
end
%%
for j = 1:7

    for z = 1:2000
        if resp_mid(j) < resp_end{j}(z)
            [resp_start_z,~] = find(daily.time > resp_mid(j),1,'first');
            [resp_end_z,~] = find(daily.time < resp_end{j}(z),1,'last');
            resp_ind = resp_start_z:resp_end_z;
            Dremin_days = daily.time(resp_ind) - daily.time(resp_ind(1));
            dt_days = Dremin_days; 
            
            % Oxygen and density outliers have already been removed 
            mdl = fitlm(dt_days,daily.doxy(z,resp_ind));
            CI = mdl.coefCI;
    
            regress_prho_last100{j}(z) = mean(daily.prho(z,resp_ind),'omitnan');
            regress_temp_last100{j}(z) = mean(daily.temp(z,resp_ind),'omitnan');
                    
        else 
            Dremin_days = 0; 
            dt_days = 0; 
            resp_start_z = NaN;
            resp_end_z = NaN; 
            mdl = fitlm(NaN,NaN);
            regress_prho_last100{j}(z) = NaN;
            CI(1:2,1:2) = 0;
            resp_ind = 0;  
        end


        % Stores them by actual depth 
        DOresp_rate_umolkg_day_last100{j}(z) = mdl.Coefficients.Estimate(2);
        DOresp_rate_umolkg_day_95CI_high_last100{j}(z) = CI(2,1);
        DOresp_rate_umolkg_day_95CI_low_last100{j}(z) = CI(2,2); 

        b_umolkg_last100{j}(z) = mdl.Coefficients.Estimate(1);
        p_value_last100{j}(z) = mdl.Coefficients.pValue(2);
        R2_last100{j}(z) = mdl.Rsquared.Ordinary;
        DFE_last100{j}(z) = mdl.DFE;
        regress_days_last100{j}(z) = max(dt_days); 
        Dremin_length_days_last100{j}(z) = max(Dremin_days); 

        DOresp_season_umolkg_last100{j}(z) = mdl.Coefficients.Estimate(2)*Dremin_length_days_last100{j}(z); % rate (slope) *resp_days
        DOresp_season_umolkg_95CI_high_last100{j}(z) = CI(2,1)*Dremin_length_days_last100{j}(z); % rate (slope) *resp_days
        DOresp_season_umolkg_95CI_low_last100{j}(z) = CI(2,2)*Dremin_length_days_last100{j}(z);% rate (slope) *resp_days

        DOresp_rate_mmolm3_day_last100{j}(z) = (mdl.Coefficients.Estimate(2).*regress_prho_last100{j}(z))/(1000*1000); % rate (slope) *resp_days
        DOresp_rate_mmolm3_day_95CI_high_last100{j}(z) = (CI(2,1).*regress_prho_last100{j}(z))/(1000*1000); % rate (slope) *resp_days
        DOresp_rate_mmolm3_day_95CI_low_last100{j}(z) = (CI(2,2).*regress_prho_last100{j}(z))/(1000*1000);% rate (slope) *resp_days

        DOresp_season_molm3_last100{j}(z) = (DOresp_season_umolkg_last100{j}(z).*regress_prho_last100{j}(z))/(1000*1000);
        DOresp_season_molm3_95CI_high_last100{j}(z) = (DOresp_season_umolkg_95CI_high_last100{j}(z).*regress_prho_last100{j}(z))/(1000*1000);
        DOresp_season_molm3_95CI_low_last100{j}(z) = (DOresp_season_umolkg_95CI_low_last100{j}(z).*regress_prho_last100{j}(z))/(1000*1000);
    end

end
%%
close all

for yr = 1:7
    figure
    if yr == 3
        l = plot(movmean(DOresp_rate_umolkg_day{yr}(208:Remin0(yr))*-0.69,25),208:Remin0(yr),'Linewidth',2.25);
        hold on
        l2 = plot(movmean(DOresp_rate_umolkg_day_first100{yr}(208:Remin0(yr))*-0.69,25),208:Remin0(yr),'Linewidth',2.25);
        l3 = plot(movmean(DOresp_rate_umolkg_day_mid100{yr}(208:Remin0(yr))*-0.69,25),208:Remin0(yr),'Linewidth',2.25);
        l4 = plot(movmean(DOresp_rate_umolkg_day_last100{yr}(208:Remin0(yr))*-0.69,25),208:Remin0(yr),'Linewidth',2.25);
    end
    if yr ~=3
        l = plot(movmean(DOresp_rate_umolkg_day{yr}(50:Remin0(yr))*-0.69,25),50:Remin0(yr),'Linewidth',2.25);
        hold on
        l2 = plot(movmean(DOresp_rate_umolkg_day_first100{yr}(50:Remin0(yr))*-0.69,25),50:Remin0(yr),'Linewidth',2.25);
        l3 = plot(movmean(DOresp_rate_umolkg_day_mid100{yr}(50:Remin0(yr))*-0.69,25),50:Remin0(yr),'Linewidth',2.25);
        l4 = plot(movmean(DOresp_rate_umolkg_day_last100{yr}(50:Remin0(yr))*-0.69,25),50:Remin0(yr),'Linewidth',2.25);
    end
    hold on
    l.Color = 'k';
    axis ij
end
%%

z_plot= (1:2000);
for yr = 1:7
    figure
    set(gcf,'position',[100,100,1100,500])
    subplot(1,4,1)
    l = plot(DOresp_rate_umolkg_day{yr}(p_value{yr} < 0.05)*-0.69,z_plot(p_value{yr} < 0.05),'.k');
    hold on
    l2 = plot(DOresp_rate_umolkg_day_first100{yr}(p_value_first100{yr} < 0.05)*-0.69,z_plot(p_value_first100{yr} < 0.05),'.');
    l3 = plot(DOresp_rate_umolkg_day_mid100{yr}(p_value_mid100{yr} < 0.05)*-0.69,z_plot(p_value_mid100{yr} < 0.05),'.');
    l4 = plot(DOresp_rate_umolkg_day_last100{yr}(p_value_last100{yr} < 0.05)*-0.69,z_plot(p_value_last100{yr} < 0.05),'.');
    
    l.Color = 'k';
    axis ij
    grid on
    title('R (\mumol C kg^-^1 d^-^1, p <0.05)')
    legend('All','First','Mid','Last','Location','SE')

    if yr == 1
        xlim([-0.1 0.35])
    elseif yr == 2
        xlim([-0.1 0.2])
    elseif yr == 3
        xlim([-0.1 0.2])
    elseif yr == 4
        xlim([-0.1 0.4])
    elseif yr == 5
        xlim([-0.05 0.5])
    elseif yr == 6
        xlim([-0.03 0.3])
    elseif yr == 7
        xlim([-0.01 0.5])
    end

    subplot(1,4,2)
    % plot(Dremin_length_days{yr}(p_value{yr} < 0.05),z_plot(p_value{yr} < 0.05),'k.'); 
    % hold on
    % plot(Dremin_length_days_first100{yr}(p_value_first100{yr} < 0.05),z_plot(p_value_first100{yr} < 0.05),'.'); 
    % plot(Dremin_length_days_mid100{yr}(p_value_mid100{yr} < 0.05),z_plot(p_value_mid100{yr} < 0.05),'.'); 
    % plot(Dremin_length_days_last100{yr}(p_value_last100{yr} < 0.05),z_plot(p_value_last100{yr} < 0.05),'.'); 
    % axis ij
    % grid on
    % title('Days in Regression')

    plot(Dremin_length_days{yr}(50:2000),z_plot(50:2000),'k.'); 
    hold on
    plot(Dremin_length_days_first100{yr}(50:2000),z_plot(50:2000),'.'); 
    plot(Dremin_length_days_mid100{yr}(50:2000),z_plot(50:2000),'.'); 
    plot(Dremin_length_days_last100{yr}(50:2000),z_plot(50:2000),'.'); 
    axis ij
    grid on
    title('Days in Regression')

    subplot(1,4,3)
    plot(DFE{yr}(50:2000),z_plot(50:2000),'k.'); 
    hold on
    plot(DFE_first100{yr}(50:2000),z_plot(50:2000),'.'); 
    plot(DFE_mid100{yr}(50:2000),z_plot(50:2000),'.'); 
    plot(DFE_last100{yr}(50:2000),z_plot(50:2000),'.'); 
    axis ij
    grid on
    title('Degrees of Freedom in Regression')

    subplot(1,4,4)
    plot(R2{yr}(p_value{yr} < 0.05),z_plot(p_value{yr} < 0.05),'k.'); 
    hold on
    plot(R2_first100{yr}(p_value_first100{yr} < 0.05),z_plot(p_value_first100{yr} < 0.05),'.'); 
    plot(R2_mid100{yr}(p_value_mid100{yr} < 0.05),z_plot(p_value_mid100{yr} < 0.05),'.'); 
    plot(R2_last100{yr}(p_value_last100{yr} < 0.05),z_plot(p_value_last100{yr} < 0.05),'.'); 
    plot([0 1],[Remin0(yr) Remin0(yr)],'k--','Linewidth',1.6)
    axis ij
    grid on
    title('R2 ( p < 0.05)')
    sgtitle(['Year ' num2str(yr)])


end
