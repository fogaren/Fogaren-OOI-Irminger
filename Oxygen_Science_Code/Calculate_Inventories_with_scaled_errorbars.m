% Assigning depths of interest for intergrations 

%Remin0 = [1030 1244 952 1235 418 643 1259]; % from deepest significant P value; w/ glider 12, deep value
Remin0 = [1030 1252 952 1251 418 653 1342]; % from deepest significant P value; w/ glider 12, deep value (446)
% Defined in Dremin_start_end_from_Blended_MLD_product.m

% If Remin0 < MLD_winter, Sequester_top + bottom == 1; 
Sequester_top = MLD_winter_max +1; % One more than max mixed layer depth 
Sequester_bottom = Remin0'; % To where Remin0 == 0 

vent_depth_error = []; % For calculating error bars for ventilation inventory
% Need data coverage for shallower of MLD_winter_max and Remin0 values 
for j = 1:7 
    if Remin0(j) < MLD_winter_max(j)
        Sequester_top(j) = 1;
        Sequester_bottom(j) = 1;
        vent_depth_error(j) = Remin0(j);
    elseif Remin0(j) > MLD_winter_max(j)
        vent_depth_error(j) = MLD_winter_max(j);
    end
end

%% Determine the amount of data coverage for 50 - 2000 m during Dremin each year 
% Then determine amount of data coverage for each Regression and scale
% error bars on R values 
days_wout_DO = []; % days that don't have an DO value
days_w_DO = []; 
days_below_ML = []; % # of days each depth is below ML

for j = 1:7 % for each year 
    for z = 50:2000 % For starting integration year each year *** Does this need to be 2000 m 
        
        [resp_start_z,~] = find(daily.time > resp_start{j}(z),1,'first');
        [resp_end_z,~] = find(daily.time < resp_end{j}(z),1,'last');
        resp_ind = resp_start_z: resp_end_z;

        if j ~= 6
            resp_ind_used = resp_ind;
        elseif j == 6
            [resp_start_z_used,~] = find(daily.time >= datenum(2020,08,00),1,'first');
            [resp_end_z_used,~] = find(daily.time <= resp_end{j}(z),1,'last');
            resp_ind_used = resp_start_z_used:resp_end_z_used; 
        end

        % Calculate days with DO data because of Year 6 starting late
        % Then calculate number of days without DO coverage before outliers
        % are removed 
        days_below_ML{j}(z) = length(daily.doxy(z,resp_ind));
        days_w_DO{j}(z) = sum(~isnan(daily.doxy_w_outliers(z,resp_ind_used)));
        days_wout_DO{j}(z) = days_below_ML{j}(z) - days_w_DO{j}(z);
    end
end

% Calculate scaled error bar for each isobar based on data coverage
% Then calculate error bars for season, revent, sequestered 
for j = 1:7

    data_wout_coverage_by_depth{j} = days_wout_DO{j}./days_below_ML{j};
    error_bar_by_depth{j} = DOresp_rate_umolkg_day_95CI_high{j}-DOresp_rate_umolkg_day{j};
    error_bar_scaled_by_depth{j} = (1+data_wout_coverage_by_depth{j}).*error_bar_by_depth{j};

    DOresp_rate_umolkg_day_high_scaled{j} = DOresp_rate_umolkg_day{j} + error_bar_scaled_by_depth{j};
    DOresp_rate_umolkg_day_low_scaled{j} = DOresp_rate_umolkg_day{j} - error_bar_scaled_by_depth{j}; 
    
    DOresp_season_umolkg_95CI_high_scaled{j} = DOresp_rate_umolkg_day_high_scaled{j}.*Dremin_length_days{j}; % rate (slope) *resp_days
    DOresp_season_umolkg_95CI_low_scaled{j} = DOresp_rate_umolkg_day_low_scaled{j}.*Dremin_length_days{j};% rate (slope) *resp_days
    
    DOresp_season_molm3_95CI_high_scaled{j} = (DOresp_season_umolkg_95CI_high_scaled{j}.*regress_prho{j})/(1000*1000);
    DOresp_season_molm3_95CI_low_scaled{j} = (DOresp_season_umolkg_95CI_low_scaled{j}.*regress_prho{j})/(1000*1000);

end

Dremin_max_length_days = []; % max Dremin length each year 
for j = 1:7 % for each year 
    for z = 2000 % use depth greater than all maximum winter MLDs 

        [resp_start_z,~] = find(daily.time > resp_start{j}(z),1,'first');
        [resp_end_z,~] = find(daily.time < resp_end{j}(z),1,'last');
        resp_ind = resp_start_z:resp_end_z;

        Dremin_max_length_days(j) = length(daily.doxy(z,resp_ind));
    end
end

percent_data_coverage =[sum(days_w_DO{1})/sum(days_below_ML{1})
sum(days_w_DO{2})/sum(days_below_ML{2})
sum(days_w_DO{3})/sum(days_below_ML{3})
sum(days_w_DO{4})/sum(days_below_ML{4})
sum(days_w_DO{5})/sum(days_below_ML{5})
sum(days_w_DO{6})/sum(days_below_ML{6})
sum(days_w_DO{7})/sum(days_below_ML{7})];

%%

% Integration 
export_DOinventory_molm2 = [];
export_DOinventory_molm2_high_scaled = [];
export_DOinventory_molm2_low_scaled = [];

revent_DOinventory_molm2 = [];
revent_DOinventory_molm2_high_scaled = [];
revent_DOinventory_molm2_low_scaled = [];

sequest_DOinventory_molm2 = [];
sequest_DOinventory_molm2_high_scaled = [];
sequest_DOinventory_molm2_low_scaled = [];

for yr = 1:7

    if yr == 3
        top_cutoff = 200;
    else 
        top_cutoff = 50;
    end
%     % Cumulative Sum Martin like curve from DO and convert to C 
    C_total_remin{yr}(top_cutoff:Remin0(yr)) = cumsum(DOresp_season_molm3{yr}(top_cutoff:Remin0(yr))*-0.69,'reverse');

    % 50 to Remin0
    export_DOinventory_molm2(yr) = min(cumsum(DOresp_season_molm3{yr}(top_cutoff:Remin0(yr))));
    export_DOinventory_molm2_high_scaled(yr) = min(cumsum(DOresp_season_molm3_95CI_high_scaled{yr}(top_cutoff:Remin0(yr))));
    export_DOinventory_molm2_low_scaled(yr) = min(cumsum(DOresp_season_molm3_95CI_low_scaled{yr}(top_cutoff:Remin0(yr))));
    % 50 to vent_depth_error (shallower of Remin0 or max winter mixing)
    revent_DOinventory_molm2(yr) = min(cumsum(DOresp_season_molm3{yr}(top_cutoff:vent_depth_error(yr))));
    revent_DOinventory_molm2_high_scaled(yr) = min(cumsum(DOresp_season_molm3_95CI_high_scaled{yr}(top_cutoff:vent_depth_error(yr))));
    revent_DOinventory_molm2_low_scaled(yr) = min(cumsum(DOresp_season_molm3_95CI_low_scaled{yr}(top_cutoff:vent_depth_error(yr))));
    % Sequest top to Sequest bottom 
    sequest_DOinventory_molm2(yr) = min(cumsum(DOresp_season_molm3{yr}(Sequester_top(yr):Sequester_bottom(yr))));
    sequest_DOinventory_molm2_high_scaled(yr) = min(cumsum(DOresp_season_molm3_95CI_high_scaled{yr}(Sequester_top(yr):Sequester_bottom(yr))));
    sequest_DOinventory_molm2_low_scaled(yr) = min(cumsum(DOresp_season_molm3_95CI_low_scaled{yr}(Sequester_top(yr):Sequester_bottom(yr))));
  
end

% Convert DO to C 
export_Cinventory_molm2 = export_DOinventory_molm2*-0.69;
export_Cinventory_molm2_high_scaled = export_DOinventory_molm2_high_scaled*-0.69;
export_Cinventory_molm2_low_scaled = export_DOinventory_molm2_low_scaled*-0.69;

revent_Cinventory_molm2 = revent_DOinventory_molm2*-0.69;
revent_Cinventory_molm2_high_scaled = revent_DOinventory_molm2_high_scaled*-0.69;
revent_Cinventory_molm2_low_scaled = revent_DOinventory_molm2_low_scaled*-0.69;

sequest_Cinventory_molm2 = sequest_DOinventory_molm2*-0.69;
sequest_Cinventory_molm2_high_scaled = sequest_DOinventory_molm2_high_scaled*-0.69;
sequest_Cinventory_molm2_low_scaled = sequest_DOinventory_molm2_low_scaled*-0.69;

%% Calculate year 3 missing inventory (0-200 m)  
% Calculate percentage of inventory from 0 -200 m of data 
DOinventory_less200m_molm2 = []; 
for yr = 1:7
    DOinventory_less200m_molm2(yr) = nanmin(cumsum(DOresp_season_molm3{yr}(50:200)));
end
Cinventory_less200m_molm2 = DOinventory_less200m_molm2*-0.69;
% Calculate projected year 3 
Cinventory_Yr3_projected = export_Cinventory_molm2(3)*(1+nanmean(Cinventory_less200m_molm2./export_Cinventory_molm2));

%% Calculate average for study from each remin year of data 
annual_export = [export_Cinventory_molm2(1:2) Cinventory_Yr3_projected export_Cinventory_molm2(4:7)];
% Create arrays from nested structure indexed by year 
% For taking means/stds 
for j = 1:7
    Dremin_length_all(:,j) = Dremin_length_days{j};
    DOresp_rate_umolkg_day_all(:,j) = DOresp_rate_umolkg_day{j};
    DOresp_rate_mmolm3_day_all(:,j) = DOresp_rate_mmolm3_day{j};
    DOresp_season_molm3_all(:,j) = DOresp_season_molm3{j};
    regress_prho_all(:,j) = regress_prho{j}; 
    regress_temp_all(:,j) = regress_temp{j};
end

% Overwrite data beyond Remin0 with Nan for each year 
for j = 1:7
    DOresp_rate_umolkg_day_all(Remin0(j):end,j) = NaN; 
    DOresp_season_molm3_all(Remin0(j):end,j) = NaN;
    if j == 3 %overwrite bad glider data
        DOresp_rate_umolkg_day_all(1:208,j) = NaN; 
        DOresp_season_molm3_all(1:208,j) = NaN;
    end
end

Dremin_length_mean = mean(Dremin_length_all,2,'omitnan');
Dremin_length_std = std(Dremin_length_all,0,2,'omitnan');
DOresp_rate_umolkg_day_mean = nanmean(DOresp_rate_umolkg_day_all(50:2000,:),2);
DOresp_rate_umolkg_day_std = nanstd(DOresp_rate_umolkg_day_all(50:2000,:),0,2);
DOresp_rate_mmolm3_day_mean = nanmean(DOresp_rate_mmolm3_day_all(50:2000,:),2);
DOresp_rate_mmolm3_day_std = nanstd(DOresp_rate_mmolm3_day_all(50:2000,:),0,2);
regress_prho_mean = mean(regress_prho_all(50:2000,:),2,'omitnan');
regress_temp_mean = mean(regress_temp_all(50:2000,:),2,'omitnan');

% Rates in units of carbon
Cresp_rate_umolkg_day_mean = DOresp_rate_umolkg_day_mean*-0.69; 
Cresp_rate_umolkg_day_std = DOresp_rate_umolkg_day_std*-0.69; 

% Export for season calculated from mean DO resp rate(z) and mean Dremin, 
% not calculated from the mean of all the seasons 
DOresp_season_umolkg_mean = DOresp_rate_umolkg_day_mean.*Dremin_length_mean(50:2000,:); 
DOresp_season_molm3_mean = (DOresp_season_umolkg_mean.*regress_prho_mean)/(1000*1000);

C_total_remin_mean(50:1149) = cumsum(DOresp_season_molm3_mean(50:1149)*-0.69,'reverse');

% Calculate export from the mean DO resp rate and extrapolate to a calendar
% year; for comparisons to other studies 
DOresp_calyr_umolkg_mean = DOresp_rate_umolkg_day_mean.*365.25; 
DOresp_calyr_molm3_mean = (DOresp_calyr_umolkg_mean.*regress_prho_mean)/(1000*1000);

C_total_remin_calyr_mean(50:1149) = cumsum(DOresp_calyr_molm3_mean(50:1149)*-0.69,'reverse');

for j = 1:7
    DOresp_season_molm3_all(Remin0(j):end,j) = NaN;
end

figure
for j = 1:7
    subplot(1,2,1)
    plot(Dremin_length_days{j},1:2000,'Linewidth',1.5)
    hold on
    axis ij
    grid on
    plot(Dremin_length_mean,1:2000,'k--','Linewidth',2)
    xlabel('Remin Period (d)')
    ylim([0 1500])
end

for j = 1:7
    subplot(1,2,2)
    plot(DOresp_rate_umolkg_day{j}(50:2000),50:2000,'Linewidth',1.5)
    hold on
    plot(DOresp_rate_umolkg_day_mean,50:2000,'k--','Linewidth',2)
    axis ij
    xlim([-0.3 0]); ylim([0 1500])
    grid on
    xlabel('Resp Rate (\mumol DO kg^-^1 d^-^1)')
end
sgtitle('Yearly Resp. Rates and Remin. Periods with Means')

figure
for j = 1:7
    plot(regress_prho{j},1:2000)
    hold on
    grid on
    axis ij
    plot(regress_prho_mean,50:2000,'k','Linewidth',2)
    xlabel('Density (kg m^-^3)')
end
ylim([50 2000])
title('Yearly Density with Mean')

figure
for j = 1:7
    plot(regress_temp{j},1:2000)
    hold on
    grid on
    axis ij
    plot(regress_temp_mean,50:2000,'k','Linewidth',2)
    plot(nanmedian(regress_temp_all(20:2000,:),2),20:2000,'k--','Linewidth',2)
    xlabel('temp (\circ C)')
end
ylim([50 2000])
title('Yearly temperature with Mean')

%%
clear j z yr top_cutoff resp_start_z* resp_end_z* resp_ind* hcb