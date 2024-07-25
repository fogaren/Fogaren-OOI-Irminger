% Assigning depths of interest for intergrations 

Remin0 = [1030 1244 952 1235 418 643 1259]; % from deepest significant P value; w/ glider 12, deep value
% MLD_winter_max = [1414 1223 1343 503 774 463 598]; % Already calculated 
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
% Then determine amount of data coverage for each inventory of interest 
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

Dremin_max_length_days = []; % max Dremin length each year 
for j = 1:7 % for each year 
    for z = 2000 % use depth greater than all maximum winter MLDs 

        [resp_start_z,~] = find(daily.time > resp_start{j}(z),1,'first');
        [resp_end_z,~] = find(daily.time < resp_end{j}(z),1,'last');
        resp_ind = resp_start_z:resp_end_z;

        Dremin_max_length_days(j) = length(daily.doxy(z,resp_ind));
    end
end

export_data_wout_coverage =[]; % From 50: Remin0 each year 
revent_data_wout_coverage = []; % From 50 to shallower of Remin0 or MLD
sequest_data_wout_coverage = []; % From Winter Max to Remin0 for Remin0 > MLD winter max 

for j = 1:7 
    export_data_wout_coverage(j) = (sum(days_wout_DO{j}(50:Remin0(j)))/sum(days_below_ML{j}(50:Remin0(j))));
    revent_data_wout_coverage(j) = (sum(days_wout_DO{j}(50:vent_depth_error(j))/sum(days_below_ML{j}(50:vent_depth_error(j)))));
    sequest_data_wout_coverage(j) = (sum(days_wout_DO{j}(Sequester_top(j):Sequester_bottom(j))/sum(days_below_ML{j}(Sequester_top(j):Sequester_bottom(j)))));
end


%%
C_Martin = [];
% Integration 
export_DOinventory_molm2 = [];
export_DOinventory_molm2_95CI_high = [];
export_DOinventory_molm2_95CI_low = [];

revent_DOinventory_molm2 = [];
revent_DOinventory_molm2_95CI_high = [];
revent_DOinventory_molm2_95CI_low = [];

sequest_DOinventory_molm2 = [];
sequest_DOinventory_molm2_95CI_high = [];
sequest_DOinventory_molm2_95CI_low = [];

for yr = 1:7

    if yr == 3
        top_cutoff = 200;
    else 
        top_cutoff = 50;
    end
    % Cumulative Sum Martin like curve 
    C_Martin{yr} = cumsum(DOresp_season_molm3{yr}(top_cutoff:Remin0(yr))*-0.69,'reverse');
    C_Martin_high{yr} = cumsum(DOresp_season_molm3_95CI_high{yr}(top_cutoff:Remin0(yr))*-0.69,'reverse');

    % 50 to Remin0
    export_DOinventory_molm2(yr) = min(cumsum(DOresp_season_molm3{yr}(top_cutoff:Remin0(yr))));
    export_DOinventory_molm2_95CI_high(yr) = min(cumsum(DOresp_season_molm3_95CI_high{yr}(top_cutoff:Remin0(yr))));
    export_DOinventory_molm2_95CI_low(yr) = min(cumsum(DOresp_season_molm3_95CI_low{yr}(top_cutoff:Remin0(yr))));
    % 50 to vent_depth_error (shallower of Remin0 or max winter mixing)
    revent_DOinventory_molm2(yr) = min(cumsum(DOresp_season_molm3{yr}(top_cutoff:vent_depth_error(yr))));
    revent_DOinventory_molm2_95CI_high(yr) = min(cumsum(DOresp_season_molm3_95CI_high{yr}(top_cutoff:vent_depth_error(yr))));
    revent_DOinventory_molm2_95CI_low(yr) = min(cumsum(DOresp_season_molm3_95CI_low{yr}(top_cutoff:vent_depth_error(yr))));
    % Sequest top to Sequest bottom 
    sequest_DOinventory_molm2(yr) = min(cumsum(DOresp_season_molm3{yr}(Sequester_top(yr):Sequester_bottom(yr))));
    sequest_DOinventory_molm2_95CI_high(yr) = min(cumsum(DOresp_season_molm3_95CI_high{yr}(Sequester_top(yr):Sequester_bottom(yr))));
    sequest_DOinventory_molm2_95CI_low(yr) = min(cumsum(DOresp_season_molm3_95CI_low{yr}(Sequester_top(yr):Sequester_bottom(yr))));
  
end

% Convert DO to C 
export_Cinventory_molm2 = export_DOinventory_molm2*-0.69;
export_Cinventory_molm2_95CI_high = export_DOinventory_molm2_95CI_high*-0.69;
export_Cinventory_molm2_95CI_low = export_DOinventory_molm2_95CI_low*-0.69;

revent_Cinventory_molm2 = revent_DOinventory_molm2*-0.69;
revent_Cinventory_molm2_95CI_high = revent_DOinventory_molm2_95CI_high*-0.69;
revent_Cinventory_molm2_95CI_low = revent_DOinventory_molm2_95CI_low*-0.69;

sequest_Cinventory_molm2 = sequest_DOinventory_molm2*-0.69;
sequest_Cinventory_molm2_95CI_high = sequest_DOinventory_molm2_95CI_high*-0.69;
sequest_Cinventory_molm2_95CI_low = sequest_DOinventory_molm2_95CI_low*-0.69;
%% Calculate scaled errorbars 
% Scaled to percent of data coverage 
exp_rev_seq_cov = [export_data_wout_coverage' revent_data_wout_coverage' sequest_data_wout_coverage']; % Scaling 

export_Cinventory_molm2_95CI_scaled = (export_Cinventory_molm2 - export_Cinventory_molm2_95CI_low).*(1+export_data_wout_coverage);
revent_Cinventory_molm2_95CI_scaled = (revent_Cinventory_molm2 - revent_Cinventory_molm2_95CI_low).*(1+revent_data_wout_coverage);
sequest_Cinventory_molm2_95CI_scaled = (sequest_Cinventory_molm2 - sequest_Cinventory_molm2_95CI_low).*(1+sequest_data_wout_coverage);

%% Calculate percentage of inventory from 0 -200 m of data 
DOinventory_less200m_molm2 = []; 
for yr = 1:7
    DOinventory_less200m_molm2(yr) = nanmin(cumsum(DOresp_season_molm3{yr}(50:200)));
end
Cinventory_less200m_molm2 = DOinventory_less200m_molm2*-0.69;
% Calculate projected year 3 
Cinventory_Yr3_projected = export_Cinventory_molm2(3)*(1+nanmean(Cinventory_less200m_molm2./export_Cinventory_molm2));

%%
clear z yr top_cutoff resp_start_z* resp_end_z* resp_ind* hcb