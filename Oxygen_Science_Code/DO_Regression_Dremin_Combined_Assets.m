%% This is done on the daily average timeseries 
% Create empty output variables 
DOresp_rate_umolkg_day = [];
DOresp_rate_umolkg_day_95CI_high = [];
DOresp_rate_umolkg_day_95CI_low = []; 
b_umolkg = [];
p_value = [];
R2 = [];
regress_days = []; 
Dremin_length_days = [];
DOresp_season_umolkg = []; % rate (slope) *resp_days 
DOresp_season_umolkg_95CI_high = []; % rate (slope) *resp_days 
DOresp_season_umolkg_95CI_low = []; % rate (slope) *resp_days 
regress_prho = [];
DOresp_season_molm3 = []; 
DOresp_season_molm3_95CI_high = [];
DOresp_season_molm3_95CI_low = [];

%%
for j = 1:7

    for z =  1:2000
        if j == 6
            if resp_end{j}(z) > datenum(2020,08,00,13,42,57) & resp_start{j}(z) ~= resp_end{j}(z)
                [resp_start_z,~] = find(daily.time >= datenum(2020,08,00),1,'first');
                [resp_start_z0,~] = find(daily.time >= resp_start{j}(z),1,'first');
                [resp_end_z,~] = find(daily.time <= resp_end{j}(z),1,'last');
                if resp_start_z < resp_end_z
                    resp_ind = resp_start_z:resp_end_z;
                    resp_ind0 = resp_start_z0:resp_end_z;
                    dt_days = daily.time(resp_ind) - daily.time(resp_ind(1));
                    Dremin_days = daily.time(resp_ind0)- daily.time(resp_ind0(1));
                % Density and oxygen outliers have already been removed 
        
                mdl = fitlm(dt_days,daily.doxy(z,resp_ind));
                CI = mdl.coefCI;
        
                regress_prho{j}(z) = mean(daily.prho(z,resp_ind),'omitnan');
                        
                else 
                    resp_start_z = NaN;
                    resp_end_z = NaN;
                    dt_days = 0;
                    mdl = fitlm(NaN,NaN);
                    regress_prho{j}(z) = NaN;
                    CI(1:2,1:2) = 0;
                    resp_ind = 0; 
                    Dremin_days = 0; 
                end
            else 
                resp_start_z = NaN;
                resp_end_z = NaN;
                dt_days = 0;
                mdl = fitlm(NaN,NaN);
                regress_prho{j}(z) = NaN;
                CI(1:2,1:2) = 0;
                resp_ind = 0; 
                Dremin_days = 0; 
            end
        elseif j ~=6
            if resp_end{j}(z) > resp_start{j}(z)
                [resp_start_z,~] = find(daily.time > resp_start{j}(z),1,'first');
                [resp_end_z,~] = find(daily.time < resp_end{j}(z),1,'last');
                resp_ind = resp_start_z:resp_end_z;
                Dremin_days = daily.time(resp_ind) - daily.time(resp_ind(1));
                dt_days = Dremin_days; 
                
                % Oxygen and density outliers have already been removed 
                mdl = fitlm(dt_days,daily.doxy(z,resp_ind));
                CI = mdl.coefCI;
        
                regress_prho{j}(z) = mean(daily.prho(z,resp_ind),'omitnan');
                        
            else 
                Dremin_days = 0; 
                dt_days = 0; 
                resp_start_z = NaN;
                resp_end_z = NaN; 
                mdl = fitlm(NaN,NaN);
                regress_prho{j}(z) = NaN;
                CI(1:2,1:2) = 0;
                resp_ind = 0;  
            end
        end

        % Stores them by actual depth 
        DOresp_rate_umolkg_day{j}(z) = mdl.Coefficients.Estimate(2);
        DOresp_rate_umolkg_day_95CI_high{j}(z) = CI(2,1);
        DOresp_rate_umolkg_day_95CI_low{j}(z) = CI(2,2); 

        b_umolkg{j}(z) = mdl.Coefficients.Estimate(1);
        p_value{j}(z) = mdl.Coefficients.pValue(2);
        R2{j}(z) = mdl.Rsquared.Ordinary;
        regress_days{j}(z) = max(dt_days); 
        Dremin_length_days{j}(z) = max(Dremin_days); 

        DOresp_season_umolkg{j}(z) = mdl.Coefficients.Estimate(2)*Dremin_length_days{j}(z); % rate (slope) *resp_days
        DOresp_season_umolkg_95CI_high{j}(z) = CI(2,1)*Dremin_length_days{j}(z); % rate (slope) *resp_days
        DOresp_season_umolkg_95CI_low{j}(z) = CI(2,2)*Dremin_length_days{j}(z);% rate (slope) *resp_days

        DOresp_season_molm3{j}(z) = (DOresp_season_umolkg{j}(z).*regress_prho{j}(z))/(1000*1000);
        DOresp_season_molm3_95CI_high{j}(z) = (DOresp_season_umolkg_95CI_high{j}(z).*regress_prho{j}(z))/(1000*1000);
        DOresp_season_molm3_95CI_low{j}(z) = (DOresp_season_umolkg_95CI_low{j}(z).*regress_prho{j}(z))/(1000*1000);
    end
end
%%
clear CI b_umolkg bad_doxy doxy_detrended dt_days j mdl resp_end_z resp_ind*...
    resp_start_z* z Dremin_days