%% Load workspace 
clearvars; close all
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Sept2023')
% Pc = 0.032; Run 1 
% cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Jan2024')
% % Pc = 0.04; Run 2
load('wfpmerge_output.mat') % Hilary's wggmerge and wggmerge_fl products 

% cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
% load('wfpmerge_output_fixedPc1600db.mat') % Run 3
% load('wfpmerge_output_variablePc1600db.mat') % Run 4 

% Sort time to be in ascending order
[time,IND] = sort(wggmerge.time);
doxy = wggmerge.doxy(:,IND);
prho = wggmerge.pdens(:,IND);
temp = wggmerge.temp(:,IND);

resp.time = time;
resp.doxy = doxy; 
resp.prho = prho; 
resp.temp = temp; 
clear time doxy IND wggmerge

wfp_prs = 150:1:2600; % Depths of Hilary's product

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load Dproduction.mat Dprod_ind Dprod_start Dprod_end % load start and end of D-production period on each isobar
         
%   Dprod_start/Dprod_end is the Production period start and end (D
%       remineralization). Defined as index of first/last data point below mixed layer by depth

        % Dproduction defined here is first and last data point below mixed
        % layer
        % Dprod_start/Dprod_end has value for each year
        % If value == NaN, the isobar do not reenter the mixed layer that
        % year
        % e.g., Dprod_start{200}(2) = Start of Dremin period for 200 m isobar during year 2 
% 
% Dprod_ind is the index of the maximum mixing each year
% *** These variables were created using WFP_Data_in_or_out_ML.m ***

load blended_MLD_prelim_final.mat 
% Add file information 
% Add toolboxes and Colors 
cd('G:\My Drive\Matlab_work\BC')
run('GeneralSettings.m')

addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))
%% Create start and end times and calculate length of regression for respiration regressions for each depth

MLmax_ind = Dprod_ind; % resp.time(MLmax_ind) == time(index) of maximum mixing each year 

for z = 175:2000 % Depth index

    z_ind = find(wfp_prs == z); % Finds the index of that depth in wfp record
    
    regress_start = [];
    regress_end = []; 
    dt_days = [];

    for yr = 1:8 % Deployment year 
            % Find start for each year 
            if ~isnan(Dprod_start{z}(yr))
                regress_start(yr) = Dprod_start{z}(yr);
            elseif isnan(Dprod_start{z}(yr)) % If nan start is time of maximum winter mixing
                regress_start(yr) = MLmax_ind(yr);
            end
            
            % Find regression end each year 
            if ~isnan(Dprod_end{z}(yr))             
                regress_end(yr) = Dprod_end{z}(yr);
            elseif isnan(Dprod_end{z}(yr)) % If nan end at timing of next winter mixing
                regress_end(yr) = MLmax_ind(yr+1); 
            end
            
%             % Calculate the length of regression (time below ML) for each
%             % depth each year 
%             Dprod_days = resp.time(regress_start(yr):regress_end(yr)) - resp.time(regress_start(yr));
    end

    regress_resp{z}.start = regress_start;
    regress_resp{z}.end = regress_end;
%     regress_resp{z}.Dprod_days = Dprod_days; 
    
end

% regress_resp start/end are indexed by depth {z} and then by year
% eg. regress_resp{200}.start(2) == start of regression for the 2nd year on 200 db isobar
%% Regression variables 
% Create empty output variables 
wfP_DOresp_rate_umolkg_day = [];
wfp_DOresp_rate_umolkg_day_95CI_high = [];
wfp_DOresp_rate_umolkg_day_95CI_low = []; 
wfp_b_umolkg = [];
wfp_p_value = [];
wfp_R2 = [];
wfp_regress_days = []; 
wfp_DOresp_season_umolkg = []; % rate (slope) *resp_days 
wfp_DOresp_season_umolkg_95CI_high = []; % rate (slope) *resp_days 
wfp_DOresp_season_umolkg_95CI_low = []; % rate (slope) *resp_days 
wfp_Dprod_prho = [];
wfp_DOresp_season_molm3 = []; 
wfp_DOresp_season_molm3_95CI_high = [];
wfp_DOresp_season_molm3_95CI_low = [];
%% Calculates Respiration variables (above) after removing outliers for each isobar for each Remineralization Year 
% Converts from Deployment Year (2:8) to Scientific Analysis Year (1:7)
figs = 0; % Creates figure of oxygen/prho for regression each year and flags outliers  
for yr = 2:8 % Deployment Year 

    for z = 175:2000 % Depth 
        z_ind = find(wfp_prs == z); % Finds the index of that depth

        if yr == 7 % Decided start regression after large chunk of missing data 
            regress_ind = find(resp.time > datenum(2020,08,00),1,'first'):regress_resp{z}.end(yr);
        else
            regress_ind = regress_resp{z}.start(yr):regress_resp{z}.end(yr); 
        end

        % Number of day of regression, different than Dprod_days for year 7
        dt_days = resp.time(regress_ind) - resp.time(regress_resp{z}.start(yr)); 

        % Find outliers before doing regression
        % Detrend because expecting linear decrease due to respiration or
        % isopycnal displacement 
        prho_detrended = detrend(resp.prho(z_ind,regress_ind),'omitnan');
        bad_prho = isoutlier(prho_detrended,'quartiles','SamplePoints',resp.time(regress_ind));
        doxy_detrended = detrend(resp.doxy(z_ind,regress_ind),'omitnan');
        bad_doxy = isoutlier(doxy_detrended,'quartiles','SamplePoints',resp.time(regress_ind));
    
        % Do regression with outliers removed 
        mdl = fitlm(dt_days(bad_prho == 0 & bad_doxy == 0),resp.doxy(z_ind,regress_ind(bad_prho == 0 & bad_doxy == 0)));
        CI = mdl.coefCI; % 95% Confidence Intervals on slope from regression 

        if figs == 1
            figure(100)
            clf
            subplot(2,1,1)
            plot(resp.time(regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),...
                resp.doxy(z_ind,regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),'ok','MarkerFaceColor','k')
            hold on
            plot(resp.time(regress_resp{z}.start(yr):regress_resp{z}.end(yr)),...
                resp.doxy(z_ind,regress_resp{z}.start(yr):regress_resp{z}.end(yr)),'ok','MarkerFaceColor','b')
            plot(resp.time(regress_ind(bad_doxy == 1)),...
                resp.doxy(z_ind,regress_ind(bad_doxy ==1)),'ok','MarkerFaceColor','y')
            plot(resp.time(regress_ind(bad_prho == 1)),...
                resp.doxy(z_ind,regress_ind(bad_prho ==1)),'or','Linewidth',1.2)
            grid on
            ylabel('Oxygen')
            legend('All data','Data below ML','Oxygen Outlier','Density Outlier','Orientation','horizontal','Location','northeast')
            datetick
            
            subplot(2,1,2)
            plot(resp.time(regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),...
                resp.prho(z_ind,regress_resp{z}.start(yr)-100:regress_resp{z}.end(yr)+100),'ok','MarkerFaceColor','k')
            hold on
            plot(resp.time(regress_resp{z}.start(yr):regress_resp{z}.end(yr)),...
                resp.prho(z_ind,regress_resp{z}.start(yr):regress_resp{z}.end(yr)),'ok','MarkerFaceColor','b')
            plot(resp.time(regress_ind(bad_prho== 1)),...
                resp.prho(z_ind,regress_ind(bad_prho ==1)),'ok','MarkerFaceColor','r')
            grid on
            datetick
            legend('All data','Data below ML','Density Outlier','Orientation','horizontal','Location','northeast')
            ylabel('prho')
            
            sgtitle(['Depth = ' num2str(z) ' Year = ' num2str(yr)])
    
            pause 
        end

        % Stores them by actual depth and by Year of scientific analysis 
        wfp_DOresp_rate_umolkg_day{yr-1}(z) = mdl.Coefficients.Estimate(2);
        wfp_DOresp_rate_umolkg_day_95CI_high{yr-1}(z) = CI(2,1);
        wfp_DOresp_rate_umolkg_day_95CI_low{yr-1}(z) = CI(2,2); 
        wfp_b_umolkg{yr-1}(z) = mdl.Coefficients.Estimate(1);
        wfp_p_value{yr-1}(z) = mdl.Coefficients.pValue(2);
        wfp_R2{yr-1}(z) = mdl.Rsquared.Ordinary;
        wfp_regress_days{yr-1}(z) = max(dt_days); 
        wfp_DOresp_season_umolkg{yr-1}(z) = mdl.Coefficients.Estimate(2)*max(dt_days); % rate (slope) *resp_days
        wfp_DOresp_season_umolkg_95CI_high{yr-1}(z) = CI(2,1)*max(dt_days); % rate (slope) *resp_days
        wfp_DOresp_season_umolkg_95CI_low{yr-1}(z) = CI(2,2)*max(dt_days); % rate (slope) *resp_days
        wfp_Dprod_prho{yr-1}(z) = nanmean(resp.prho(z_ind,regress_resp{z}.start(yr):regress_resp{z}.end(yr)));
        wfp_DOresp_season_molm3{yr-1}(z) = (wfp_DOresp_season_umolkg{yr-1}(z).*wfp_Dprod_prho{yr-1}(z))/(1000*1000);
        wfp_DOresp_season_molm3_95CI_high{yr-1}(z) = (wfp_DOresp_season_umolkg_95CI_high{yr-1}(z).*wfp_Dprod_prho{yr-1}(z))/(1000*1000);
        wfp_DOresp_season_molm3_95CI_low{yr-1}(z) = (wfp_DOresp_season_umolkg_95CI_low{yr-1}(z).*wfp_Dprod_prho{yr-1}(z))/(1000*1000);
    end
end
%% Plots of Respiration Rates(z), Remineralization Period(z) and Total Respired Carbon(z) for each Remineralization year 
% uses a 117 mol C:170 mol O2 respiratory conversion (-0.69)

depth = 175:2000; % Depths used in cells above

for yr = 1:7 % science analysis year 
    
    figure
    set(gcf,'position',[100,100,850,400])
    subplot(1,3,1) % Rate(z) with 95% CIs
    plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.') 
    hold on
    plot(wfp_DOresp_rate_umolkg_day_95CI_low{yr}(depth),depth,'.') 
    plot(wfp_DOresp_rate_umolkg_day_95CI_high{yr}(depth),depth,'.') 
    p = find(wfp_p_value{yr} >= 0.05); % finds insignifcant p values and plots them in black
    plot(wfp_DOresp_rate_umolkg_day{yr}(p),p,'.k')
    axis ij
    ylabel('Pressure (db)')
    title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
    grid on
    
    subplot(1,3,2) % Remineralization Period (z)
    plot(wfp_regress_days{yr}(depth),depth,'.')
    hold on
    axis ij
    ylabel('Pressure (db)')
    title('Length of Regression (days)')
    grid on

    subplot(1,3,3) % Respired Carbon(z) with 95% CI
    plot(wfp_DOresp_season_molm3{yr}(depth)*-0.69,depth,'.')
    hold on
    plot(wfp_DOresp_season_molm3_95CI_low{yr}(depth)*-0.69,depth,'.')
    plot(wfp_DOresp_season_molm3_95CI_high{yr}(depth)*-0.69,depth,'.')
    axis ij
    ylabel('Pressure (db)')
    grid on
    title('Total Respired (mol C m^-^3)')
    sgtitle(['Year ' num2str(yr)])
end

% Plots panels of all years 

z = depth;

for yr = 1:7
    figure(8)
    set(gcf,'position',[100,100,1200,400])
    subplot(1,7,yr)
    plot(wfp_DOresp_rate_umolkg_day{yr},1:max(z),'.')
    hold on
    p = find(wfp_p_value{yr} >= 0.05); % finds insignifcant p values and plots them in black
    plot(wfp_DOresp_rate_umolkg_day{yr}(p),p,'.k')
    axis ij
    ylabel('Pressure (db)')
    xlabel(['Year: ' num2str(yr)])
    sgtitle('Run 4: Respiration Rate (\mumol DO kg^-^1 d^-^1): Outliers removed')
    xlim([-0.1 0.04])
    grid on
end

for yr = 1:7
    figure(9)
    set(gcf,'position',[100,100,1200,400])
    subplot(1,7,yr)
    plot(wfp_regress_days{yr},1:max(z),'.')
    hold on
    axis ij
    ylabel('Pressure (db)')
    xlabel(['Year: ' num2str(yr)])
    xlim([0 500])
    sgtitle('Length of Regression Window (days)')
    grid on
end

for yr = 1:7
    figure(10)
    set(gcf,'position',[100,100,1200,400])
    subplot(1,7,yr)
    % finds neg R rates with significant p values and plots them in color
    p = find(wfp_p_value{yr} < 0.05 & wfp_DOresp_rate_umolkg_day{yr} <0);
    plot(wfp_DOresp_season_molm3{yr}*-0.69,1:max(z),'.k') % Insignifcant or positive R
    hold on
    plot(wfp_DOresp_season_molm3{yr}(p)*-0.69,p,'.')
    axis ij
    ylabel('Pressure (db)')
    xlim([0 0.015])
    xlabel(['Year: ' num2str(yr)])
    grid on
    sgtitle('Total Respired (mol C m^-^3): Outliers removed')
end


%%
resp1 = resp;
wfp_DOresp_rate_umolkg_day1 = wfp_DOresp_rate_umolkg_day;
wfp_DOresp_rate_umolkg_day_95CI_high1 = wfp_DOresp_rate_umolkg_day_95CI_high;
wfp_DOresp_rate_umolkg_day_95CI_low1 = wfp_DOresp_rate_umolkg_day_95CI_low; 
wfp_b_umolkg1 = wfp_b_umolkg;
wfp_p_value1 = wfp_p_value;
wfp_R21 = wfp_R2;
wfp_regress_days1 = wfp_regress_days; 
wfp_DOresp_season_umolkg1 = wfp_DOresp_season_umolkg; % rate (slope) *resp_days 
wfp_DOresp_season_umolkg_95CI_high1 = wfp_DOresp_season_umolkg_95CI_high; % rate (slope) *resp_days 
wfp_DOresp_season_umolkg_95CI_low1 = wfp_DOresp_season_umolkg_95CI_low; % rate (slope) *resp_days 
wfp_Dprod_prho1 = wfp_Dprod_prho;
wfp_DOresp_season_molm31 = wfp_DOresp_season_molm3; 
wfp_DOresp_season_molm3_95CI_high1 = wfp_DOresp_season_molm3_95CI_high;
wfp_DOresp_season_molm3_95CI_low1 = wfp_DOresp_season_molm3_95CI_low;

% resp2 = resp;
% wfp_DOresp_rate_umolkg_day2 = wfp_DOresp_rate_umolkg_day;
% wfp_DOresp_rate_umolkg_day_95CI_high2 = wfp_DOresp_rate_umolkg_day_95CI_high;
% wfp_DOresp_rate_umolkg_day_95CI_low2 = wfp_DOresp_rate_umolkg_day_95CI_low; 
% wfp_b_umolkg2 = wfp_b_umolkg;
% wfp_p_value2 = wfp_p_value;
% wfp_R22 = wfp_R2;
% wfp_regress_days2 = wfp_regress_days; 
% wfp_DOresp_season_umolkg2 = wfp_DOresp_season_umolkg; % rate (slope) *resp_days 
% wfp_DOresp_season_umolkg_95CI_high2 = wfp_DOresp_season_umolkg_95CI_high; % rate (slope) *resp_days 
% wfp_DOresp_season_umolkg_95CI_low2 = wfp_DOresp_season_umolkg_95CI_low; % rate (slope) *resp_days 
% wfp_Dprod_prho2 = wfp_Dprod_prho;
% wfp_DOresp_season_molm32 = wfp_DOresp_season_molm3; 
% wfp_DOresp_season_molm3_95CI_high2 = wfp_DOresp_season_molm3_95CI_high;
% wfp_DOresp_season_molm3_95CI_low2 = wfp_DOresp_season_molm3_95CI_low;
% 
% resp3 = resp;
% wfp_DOresp_rate_umolkg_day3 = wfp_DOresp_rate_umolkg_day;
% wfp_DOresp_rate_umolkg_day_95CI_high3 = wfp_DOresp_rate_umolkg_day_95CI_high;
% wfp_DOresp_rate_umolkg_day_95CI_low3 = wfp_DOresp_rate_umolkg_day_95CI_low; 
% wfp_b_umolkg3 = wfp_b_umolkg;
% wfp_p_value3 = wfp_p_value;
% wfp_R23 = wfp_R2;
% wfp_regress_days3 = wfp_regress_days; 
% wfp_DOresp_season_umolkg3 = wfp_DOresp_season_umolkg; % rate (slope) *resp_days 
% wfp_DOresp_season_umolkg_95CI_high3 = wfp_DOresp_season_umolkg_95CI_high; % rate (slope) *resp_days 
% wfp_DOresp_season_umolkg_95CI_low3 = wfp_DOresp_season_umolkg_95CI_low; % rate (slope) *resp_days 
% wfp_Dprod_prho3 = wfp_Dprod_prho;
% wfp_DOresp_season_molm33 = wfp_DOresp_season_molm3; 
% wfp_DOresp_season_molm3_95CI_high3 = wfp_DOresp_season_molm3_95CI_high;
% wfp_DOresp_season_molm3_95CI_low3 = wfp_DOresp_season_molm3_95CI_low;

% resp4 = resp;
% wfp_DOresp_rate_umolkg_day4 = wfp_DOresp_rate_umolkg_day;
% wfp_DOresp_rate_umolkg_day_95CI_high4 = wfp_DOresp_rate_umolkg_day_95CI_high;
% wfp_DOresp_rate_umolkg_day_95CI_low4 = wfp_DOresp_rate_umolkg_day_95CI_low; 
% wfp_b_umolkg4 = wfp_b_umolkg;
% wfp_p_value4 = wfp_p_value;
% wfp_R24 = wfp_R2;
% wfp_regress_days4 = wfp_regress_days; 
% wfp_DOresp_season_umolkg4 = wfp_DOresp_season_umolkg; % rate (slope) *resp_days 
% wfp_DOresp_season_umolkg_95CI_high4 = wfp_DOresp_season_umolkg_95CI_high; % rate (slope) *resp_days 
% wfp_DOresp_season_umolkg_95CI_low4 = wfp_DOresp_season_umolkg_95CI_low; % rate (slope) *resp_days 
% wfp_Dprod_prho4 = wfp_Dprod_prho;
% wfp_DOresp_season_molm34 = wfp_DOresp_season_molm3; 
% wfp_DOresp_season_molm3_95CI_high4 = wfp_DOresp_season_molm3_95CI_high;
% wfp_DOresp_season_molm3_95CI_low4 = wfp_DOresp_season_molm3_95CI_low;
%%
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
save wfp_respiration1.mat wfp* resp*

%% Now for the gliders 
% Pc is the same for the gliders (0.032) 
% but data pinned to wfp w/ Pcs values 

clearvars; close all
% % run 1
% cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Sept2023') 
% load('glider_griddall.mat')

% cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Jan2024') 
% load('glider_griddall.mat') % Hilary's wggmerge and wggmerge_fl products 

% cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
% load('glider_griddall_fixedPc1600db.mat')

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('glider_griddall_variablePc1600db.mat')

% Grid all glider data (not just the single pick per year)
% yrs = [2 2 2 3 4 5 5 6 6 7 7 8 8];
% glidernum = [495 485 528 559 493 363 453 525 560 515 365 469 565];
% i = 0;
% for glgid = [9:11,13:14, 1:8]
%     i = i + 1; %increment the index
%     ind = find(isnan(glgmerge{glgid}.time_start) == 0);
%     glidergrid{i}.glidernum = glidernum(i);
%     glidergrid{i}.time = glgmerge{glgid}.time_start(ind);
%     glidergrid{i}.duration = glgmerge{glgid}.duration(ind);
%     glidergrid{i}.lat = glgmerge{glgid}.lat_profile(ind);
%     glidergrid{i}.lon = glgmerge{glgid}.lon_profile(ind);
%     glidergrid{i}.deploy_yr = yrs(i)*ones(length(ind),1);
%     glidergrid{i}.temp = glgmerge{glgid}.temp_grid(:,ind);
%     glidergrid{i}.pracsal = glgmerge{glgid}.sal_grid(:,ind);
%     glidergrid{i}.SA = glgmerge{glgid}.SA_grid(:,ind);
%     glidergrid{i}.CT = glgmerge{glgid}.CT_grid(:,ind);
%     glidergrid{i}.pdens = glgmerge{glgid}.pdens_grid(:,ind);
%     glidergrid{i}.doxy = glgmerge{glgid}.doxy_lagcorr_grid(:,ind).*glgmerge{glgid}.oxygain_deepisotherm_linear(ind)';
%     glidergrid{i}.chla = glgmerge{glgid}.chl_grid(:,ind);
%     glidergrid{i}.backscatter = glgmerge{glgid}.backscatter_grid(:,ind);
% end
%%
glider_prs = 1:1000; 
glider = glidergrid;
clear pres_grid_glider glidergrid 

cd('G:\Shared drives\NSF_Irminger\Data_Files\From Meg')
load blended_mld_daily.mat blended_mld_daily_all
% rename meg's updated variables for my code 
dt = datenum(blended_mld_daily_all.time);
mld_db = blended_mld_daily_all.mld;
clear blended_mld_daily_all 

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load respiration_length_by_glider.mat
% *** output from 'Respiration_lengths_from_Blended_MLD_product.m'
% Variables glider_resp_length_days{glider_num}
% glider_resp_start{glider_num}
% glider_resp_end{glider_num}

addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))

%%
% Create empty output variables 
glider_DOresp_rate_umolkg_day = [];
glider_DOresp_rate_umolkg_day_95CI_high = [];
glider_DOresp_rate_umolkg_day_95CI_low = []; 
glider_b_umolkg = [];
glider_p_value = [];
glider_R2 = [];
glider_regress_days = []; 
glider_DOresp_season_umolkg = []; % rate (slope) *resp_days 
glider_DOresp_season_umolkg_95CI_high = []; % rate (slope) *resp_days 
glider_DOresp_season_umolkg_95CI_low = []; % rate (slope) *resp_days 
glider_regress_prho = [];
glider_DOresp_season_molm3 = []; 
glider_DOresp_season_molm3_95CI_high = [];
glider_DOresp_season_molm3_95CI_low = [];
%%
figs = 0;
for j = 1:13

    for z =  1:1000
        
        time_test = find(glider{j}.time < glider_resp_end{j}(z));
        if glider_resp_start{j}(z) == glider_resp_end{j}(z)
            dt_days = 0;
            resp_start = NaN;
            resp_end = NaN; 
        elseif isempty(time_test) 
            dt_days = 0; 
        else
            [resp_start,~] = find(glider{j}.time > glider_resp_start{j}(z),1,'first');
            [resp_end,~] = find(glider{j}.time < glider_resp_end{j}(z),1,'last');
            dt_days = glider{j}.time(resp_start:resp_end) - glider{j}.time(resp_start);
        end

        if dt_days < 20 %Number of days for regression
            % If less than that #, output NaN/0 data 
            mdl = fitlm(NaN,NaN);
            glider_regress_prho{j}(z) = NaN;
            CI(1:2,1:2) = 0;
            resp_ind = 0;
        elseif max(dt_days) >= 20
            resp_ind = resp_start:resp_end;

            % Remove prho outliers 
            prho_detrend = detrend(glider{j}.pdens(z,resp_ind),'omitnan');
            bad_prho = isoutlier(prho_detrend,'quartiles','SamplePoints',glider{j}.time(resp_start:resp_end));
            % Oxygen filter doens't filter out any process, not using
%             doxy_detrended = detrend(glider{j}.doxy(z,resp_ind),'omitnan');
%             bad_doxy = isoutlier(doxy_detrended,'quartiles','SamplePoints',glider{j}.time(resp_start:resp_end));

            mdl = fitlm(dt_days(bad_prho == 0),glider{j}.doxy(z,resp_ind(bad_prho == 0)));
            CI = mdl.coefCI;

            glider_regress_prho{j}(z) = nanmean(glider{j}.pdens(z,resp_ind));

        end

            if figs == 1 & resp_ind > 0
                figure
                clf
                subplot(2,1,1)
                plot(glider{j}.time,glider{j}.doxy(z,:),'ok','MarkerFaceColor','k')
                hold on
                plot(glider{j}.time(resp_ind),glider{j}.doxy(z,resp_ind),'o','Color',blue,'MarkerFaceColor',blue)
                plot(glider{j}.time(resp_ind(bad_doxy == 1)),glider{j}.doxy(z,resp_ind(bad_doxy ==1)),'o','Color',rgb('yellow'),'MarkerFaceColor',rgb('yellow'))
                plot(glider{j}.time(resp_ind(bad_prho == 1)),glider{j}.doxy(z,resp_ind(bad_prho ==1)),'o','Color',rgb('red'),'MarkerFaceColor',rgb('red'))
                grid on
                ylabel('DO (\mumol/kg)')
                ylim([260 320])
                datetick
                
                subplot(2,1,2)
                plot(glider{j}.time,glider{j}.pdens(z,:),'ok','MarkerFaceColor','k')
                hold on
                plot(glider{j}.time(resp_ind),glider{j}.pdens(z,resp_ind),'o','Color',blue,'MarkerFaceColor',blue)
                plot(glider{j}.time(resp_ind(bad_prho == 1)),glider{j}.pdens(z,resp_ind(bad_prho ==1)),'o','Color',red,'MarkerFaceColor',red)
                grid on
                datetick
                ylabel('prho')
                sgtitle(['Depth = ' num2str(z) ' Year = ' num2str(j)])
                pause
            end
                
        % Stores them by actual depth 
        glider_DOresp_rate_umolkg_day{j}(z) = mdl.Coefficients.Estimate(2);
        glider_DOresp_rate_umolkg_day_95CI_high{j}(z) = CI(2,1);
        glider_DOresp_rate_umolkg_day_95CI_low{j}(z) = CI(2,2); 
        glider_b_umolkg{j}(z) = mdl.Coefficients.Estimate(1);
        glider_p_value{j}(z) = mdl.Coefficients.pValue(2);
        glider_R2{j}(z) = mdl.Rsquared.Ordinary;
        glider_regress_days{j}(z) = max(dt_days); 

        glider_DOresp_season_umolkg{j}(z) = mdl.Coefficients.Estimate(2)*glider_resp_length_days{j}(z); % rate (slope) *resp_days
        glider_DOresp_season_umolkg_95CI_high{j}(z) = CI(2,1)*glider_resp_length_days{j}(z); % rate (slope) *resp_days
        glider_DOresp_season_umolkg_95CI_low{j}(z) = CI(2,2)*glider_resp_length_days{j}(z);% rate (slope) *resp_days

        glider_DOresp_season_molm3{j}(z) = (glider_DOresp_season_umolkg{j}(z).*glider_regress_prho{j}(z))/(1000*1000);
        glider_DOresp_season_molm3_95CI_high{j}(z) = (glider_DOresp_season_umolkg_95CI_high{j}(z).*glider_regress_prho{j}(z))/(1000*1000);
        glider_DOresp_season_molm3_95CI_low{j}(z) = (glider_DOresp_season_umolkg_95CI_low{j}(z).*glider_regress_prho{j}(z))/(1000*1000);
    end
end
%%
run('GeneralSettings.m')
z = 1:1000;

depth = 1:max(z);
% Year 1 index = 1, 2 and 3
figure
set(gcf,'position',[100,100,1250,400])
subplot(1,7,1)
plot(glider_DOresp_rate_umolkg_day{1},depth,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{2},depth,'.','Color',red)
plot(glider_DOresp_rate_umolkg_day{3},depth,'.','Color',yellow)
legend(num2str(glider{1}.glidernum),num2str(glider{2}.glidernum),num2str(glider{3}.glidernum),'Location','SW');
axis ij
ylabel('Pressure (db)')
title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
xlim([-0.6 0.02])
grid on
title('Year 2')

% Year 2 ind 4 
subplot(1,7,2)
plot(glider_DOresp_rate_umolkg_day{4},depth,'.','Color',blue)
hold on
legend(num2str(glider{4}.glidernum),'Location','SW');
axis ij
ylabel('Pressure (db)')
title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
xlim([-0.6 0.02])
grid on
title('Year 2')

% Year 3 ind 5 
subplot(1,7,3)
plot(glider_DOresp_rate_umolkg_day{5},depth,'.','Color',blue)
hold on
legend(num2str(glider{5}.glidernum),'Location','SW');
axis ij
ylabel('Pressure (db)')
title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
xlim([-0.6 0.02])
grid on
title('Year 3')

% Year 4 index = 6 and 7
subplot(1,7,4)
plot(glider_DOresp_rate_umolkg_day{6},depth,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{7},depth,'.','Color',red)
legend(num2str(glider{6}.glidernum),num2str(glider{7}.glidernum),'Location','SW');
axis ij
ylabel('Pressure (db)')
title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
xlim([-0.6 0.02])
grid on
title('Year 4')

% Year 5 index = 8 and 9
subplot(1,7,5)
plot(glider_DOresp_rate_umolkg_day{8},depth,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{9},depth,'.','Color',red)
legend(num2str(glider{8}.glidernum),num2str(glider{9}.glidernum),'Location','SW');
axis ij
ylabel('Pressure (db)')
title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
xlim([-0.6 0.02])
grid on
title('Year 5')

% Year 6 index = 10 and 11
subplot(1,7,6)
plot(glider_DOresp_rate_umolkg_day{10},depth,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{11},depth,'.','Color',red)
legend(num2str(glider{10}.glidernum),num2str(glider{11}.glidernum),'Location','SW');
axis ij
ylabel('Pressure (db)')
title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
xlim([-0.6 0.02])
grid on
title('Year 6')

% Year 8 index = 12 and 13
subplot(1,7,7)
plot(glider_DOresp_rate_umolkg_day{12},depth,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{13},depth,'.','Color',red)
legend(num2str(glider{12}.glidernum),num2str(glider{13}.glidernum),'Location','SW');
axis ij
ylabel('Pressure (db)')
title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
xlim([-0.6 0.02])
grid on
title('Year 7')
sgtitle('Run 4: Respiration Rate (\mumol DO kg^-^1 d^-^1): Outliers removed')
%%
for j = 1:13
    figure % Compare all on one plot
    plot(glider_DOresp_rate_umolkg_day{j},depth,'.')
    hold on
    p = find(glider_p_value{j} >= 0.05);
    plot(glider_DOresp_rate_umolkg_day{j}(p),p,'.k')
    plot(glider_DOresp_rate_umolkg_day{j}(glider_DOresp_rate_umolkg_day{j} == 0),depth(glider_DOresp_rate_umolkg_day{j}==0),'.','Color',rgb('gray'))
    axis ij
    ylabel('Pressure (db)')
    title('Glider Respiration Rates (\mumol DO kg^-^1 d^-^1)')
    xlim([-0.7 0])
    grid on
    legend(num2str(j))
end
%%

mycolors = [maroon; red; yellow; green; forestgreen; blue; purple; brightpurple; rgb('dark pink');...
    maroon; red; yellow; green; forestgreen; blue; purple; brightpurple; rgb('dark pink')];

for j = 1:13
    figure
    set(gcf,'position',[100,100,850,400])
    subplot(1,2,1)
    plot(glider_DOresp_rate_umolkg_day{j},depth,'.','Color',mycolors(j,:))
    hold on
    plot(glider_DOresp_rate_umolkg_day_95CI_low{j},depth,'.','Color',mycolors(j+1,:)) 
    plot(glider_DOresp_rate_umolkg_day_95CI_high{j},depth,'.','Color',mycolors(j+2,:)) 
    p = find(glider_p_value{j} >= 0.05);
    plot(glider_DOresp_rate_umolkg_day{j}(p),p,'.k')
    axis ij
    ylabel('Pressure (db)')
    title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
    grid on
    
    subplot(1,2,2)
    plot(glider_regress_days{j},1:max(z),'.','Color',mycolors(j,:))
    hold on
%     plot(resp_length_days{j}(1:1000),1:1000,'.k')
    axis ij
    ylabel('Pressure (db)')
    title('Regression and Stratification Lengths (days)')
    grid on
    sgtitle(['Glider Deployment Number =  ' num2str(glider{j}.glidernum)])
    legend('Regression Length','Stratification Length')
end
%%
% glider_DOresp_rate_umolkg_day1 = glider_DOresp_rate_umolkg_day;
% glider_DOresp_rate_umolkg_day_95CI_high1 = glider_DOresp_rate_umolkg_day_95CI_high;
% glider_DOresp_rate_umolkg_day_95CI_low1 = glider_DOresp_rate_umolkg_day_95CI_low; 
% glider_b_umolkg1 = glider_b_umolkg;
% glider_p_value1 = glider_p_value;
% glider_R21 = glider_R2;
% glider_regress_days1 = glider_regress_days; 
% glider_DOresp_season_umolkg1 = glider_DOresp_season_umolkg; % rate (slope) *resp_days 
% glider_DOresp_season_umolkg_95CI_high1 = glider_DOresp_season_umolkg_95CI_high; % rate (slope) *resp_days 
% glider_DOresp_season_umolkg_95CI_low1 = glider_DOresp_season_umolkg_95CI_low; % rate (slope) *resp_days 
% glider_regress_prho1 = glider_regress_prho;
% glider_DOresp_season_molm31 = glider_DOresp_season_molm3; 
% glider_DOresp_season_molm3_95CI_high1 = glider_DOresp_season_molm3_95CI_high;
% glider_DOresp_season_molm3_95CI_low1 = glider_DOresp_season_molm3_95CI_low;

glider_DOresp_rate_umolkg_day4 = glider_DOresp_rate_umolkg_day;
glider_DOresp_rate_umolkg_day_95CI_high4 = glider_DOresp_rate_umolkg_day_95CI_high;
glider_DOresp_rate_umolkg_day_95CI_low4 = glider_DOresp_rate_umolkg_day_95CI_low; 
glider_b_umolkg4 = glider_b_umolkg;
glider_p_value4 = glider_p_value;
glider_R24 = glider_R2;
glider_regress_days4 = glider_regress_days; 
glider_DOresp_season_umolkg4 = glider_DOresp_season_umolkg; % rate (slope) *resp_days 
glider_DOresp_season_umolkg_95CI_high4 = glider_DOresp_season_umolkg_95CI_high; % rate (slope) *resp_days 
glider_DOresp_season_umolkg_95CI_low4 = glider_DOresp_season_umolkg_95CI_low; % rate (slope) *resp_days 
glider_regress_prho4 = glider_regress_prho;
glider_DOresp_season_molm34 = glider_DOresp_season_molm3; 
glider_DOresp_season_molm3_95CI_high4 = glider_DOresp_season_molm3_95CI_high;
glider_DOresp_season_molm3_95CI_low4 = glider_DOresp_season_molm3_95CI_low;
%%
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
save glider_resp_rates4.mat glider*

%% Plot to compare
clearvars; close all

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load glider_resp_rates1.mat
load glider_resp_rates2.mat
load glider_resp_rates3.mat
load glider_resp_rates4.mat

load wfp_respiration1.mat
load wfp_respiration2.mat
load wfp_respiration3.mat
load wfp_respiration4.mat

%%
close all

for yr = 1:7
    figure(100)
    subplot(1,7,yr)
    plot(wfp_DOresp_rate_umolkg_day1{yr},1:2000,'.')
    hold on
    plot(wfp_DOresp_rate_umolkg_day2{yr},1:2000,'.')  
    plot(wfp_DOresp_rate_umolkg_day3{yr},1:2000,'.')
    plot(wfp_DOresp_rate_umolkg_day4{yr},1:2000,'.')
    axis ij
    ylabel('Pressure (db)')
    title(['Yr ' num2str(yr)])
    xlim([-0.2 0.02])
    grid on
end

%%


for gn = 1:13 % glider number
    figure(gn)
    plot(glider_DOresp_rate_umolkg_day1{gn},1:1000,'.')
    hold on
    plot(glider_DOresp_rate_umolkg_day2{gn},1:1000,'.')
    plot(glider_DOresp_rate_umolkg_day3{gn},1:1000,'.')
    plot(glider_DOresp_rate_umolkg_day4{gn},1:1000,'.')
    axis ij
    ylabel('Pressure (db)')
    title(['Glider Num. ' num2str(gn)])
    grid on
end
%%
% close all
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load glider_resp_rates1.mat
load glider_resp_rates2.mat
load glider_resp_rates3.mat
load glider_resp_rates4.mat

load wfp_respiration1.mat
load wfp_respiration2.mat
load wfp_respiration3.mat
load wfp_respiration4.mat
%%
yr = 2; % Deployment year 
j = 3;
z1 = 500; 

% [resp_start,~] = find(glider{j}.time > glider_resp_start{j}(z1),1,'first');
% [resp_end,~] = find(glider{j}.time < glider_resp_end{j}(z1),1,'last');
% 
regress_ind_z1 = regress_resp{z1}.start(yr):regress_resp{z1}.end(yr);
figure(10)
set(gcf,'position',[100,100,800,300])
days_pad = 0; 
ax1 = gca;
% plot(glider{j}.time(resp_start-days_pad:resp_end+days_pad),...
%     glider{j}.doxy(z1,resp_start-days_pad:resp_end+days_pad),'o','Color','none','MarkerFaceColor',purple)
plot(resp1.time(regress_ind_z1),...
    resp1.doxy(z1,regress_ind_z1),'o','Color','none','MarkerFaceColor',blue)
hold on
plot(resp2.time(regress_ind_z1),...
    resp2.doxy(z1,regress_ind_z1),'o','Color','none','MarkerFaceColor',red)
plot(resp3.time(regress_ind_z1),...
    resp3.doxy(z1,regress_ind_z1),'o','Color','none','MarkerFaceColor',yellow)
plot(resp4.time(regress_ind_z1),...
    resp4.doxy(z1,regress_ind_z1),'o','Color','none','MarkerFaceColor',purple)
% hold on
% plot(resp.time(regress_ind_z1),...
%     resp.doxy(z1_ind,regress_ind_z1),'o','Color','none','MarkerFaceColor',blue)
% plot(resp.time(regress_ind_z1(bad_prho_z1 == 1| bad_doxy_z1 == 1)),...
%     resp.doxy(z1_ind,regress_ind_z1(bad_prho_z1 == 1 | bad_doxy_z1 == 1)),'o','Color','none','MarkerFaceColor',red)
% % plot(resp.time(regress_ind_z1(bad_prho_z1 == 0| bad_doxy_z1 == 0)),...
% %     resp.doxy(z1_ind,regress_ind_z1(bad_prho_z1 == 0| bad_doxy_z1 == 0)),'o','Color','none','MarkerFaceColor',blue)
% plot([resp.time(regress_ind_z1(1)) resp.time(regress_ind_z1(end))],[(resp.time(regress_ind_z1(1))*mdl_z1.Coefficients.Estimate(2) + mdl_z1.Coefficients.Estimate(1)) (resp.time(regress_ind_z1(end))*mdl_z1.Coefficients.Estimate(2) + mdl_z1.Coefficients.Estimate(1))],'k','Linewidth',2)
grid on
ylabel('\mumol kg^-^1')
ax1.FontSize = 14;
datetick
title(['Oxygen at ' num2str(z1) ' db'])

%% Creating just one full profile for each year 
for j = 1:7
    DOresp_rate_umolkg_day{j} = NaN(2000,1);
    DOresp_rate_umolkg_day_95CI_high{j} = NaN(2000,1);
    DOresp_rate_umolkg_day_95CI_low{j} = NaN(2000,1);
    p_value{j} = NaN(2000,1);
    prho{j} = NaN(2000,1); 
end

% For all gliders/wfp years 
glid_top = 1; 
wfp_bottom = 2000; 

% Year 1, glider 3 
yr = 1; glid_ind = 3;
glid_bottom = 185;
wfp_top = glid_bottom + 1; 
% Glider 
DOresp_rate_umolkg_day{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day{glid_ind}(glid_top:glid_bottom);
DOresp_rate_umolkg_day_95CI_high{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day_95CI_high{glid_ind}(glid_top:glid_bottom);
DOresp_rate_umolkg_day_95CI_low{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day_95CI_low{glid_ind}(glid_top:glid_bottom);
p_value{yr}(glid_top:glid_bottom) = glider_p_value{glid_ind}(glid_top:glid_bottom);
prho{yr}(glid_top:glid_bottom) = glider_regress_prho{glid_ind}(glid_top:glid_bottom);
% WFP 
DOresp_rate_umolkg_day{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day{yr}(wfp_top:wfp_bottom);
DOresp_rate_umolkg_day_95CI_high{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day_95CI_high{yr}(wfp_top:wfp_bottom);
DOresp_rate_umolkg_day_95CI_low{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day_95CI_low{yr}(wfp_top:wfp_bottom);
p_value{yr}(wfp_top:wfp_bottom) = wfp_p_value{yr}(wfp_top:wfp_bottom);
prho{yr}(wfp_top:wfp_bottom) = wfp_Dprod_prho{yr}(wfp_top:wfp_bottom);

% Year 2, glider 4 
yr = 2; glid_ind = 4;
glid_bottom = 500;
wfp_top = glid_bottom + 1; 
% Glider 
DOresp_rate_umolkg_day{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day{glid_ind}(glid_top:glid_bottom);
DOresp_rate_umolkg_day_95CI_high{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day_95CI_high{glid_ind}(glid_top:glid_bottom);
DOresp_rate_umolkg_day_95CI_low{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day_95CI_low{glid_ind}(glid_top:glid_bottom);
p_value{yr}(glid_top:glid_bottom) = glider_p_value{glid_ind}(glid_top:glid_bottom);
prho{yr}(glid_top:glid_bottom) = glider_regress_prho{glid_ind}(glid_top:glid_bottom);
% WFP 
DOresp_rate_umolkg_day{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day{yr}(wfp_top:wfp_bottom);
DOresp_rate_umolkg_day_95CI_high{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day_95CI_high{yr}(wfp_top:wfp_bottom);
DOresp_rate_umolkg_day_95CI_low{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day_95CI_low{yr}(wfp_top:wfp_bottom);
p_value{yr}(wfp_top:wfp_bottom) = wfp_p_value{yr}(wfp_top:wfp_bottom);
prho{yr}(wfp_top:wfp_bottom) = wfp_Dprod_prho{yr}(wfp_top:wfp_bottom);

% Year 3, glider none  
yr = 3; % glid_ind = 5;
glid_bottom = 199;
wfp_top = glid_bottom + 1; 
% % Glider 
% DOresp_rate_umolkg_day{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day{glid_ind}(glid_top:glid_bottom);
% DOresp_rate_umolkg_day_95CI_high{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day_95CI_high{glid_ind}(glid_top:glid_bottom);
% DOresp_rate_umolkg_day_95CI_low{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day_95CI_low{glid_ind}(glid_top:glid_bottom);
% p_value{yr}(glid_top:glid_bottom) = glider_p_value{glid_ind}(glid_top:glid_bottom);
% prho{yr}(glid_top:glid_bottom) = glider_regress_prho{glid_ind}(glid_top:glid_bottom);

% WFP 
DOresp_rate_umolkg_day{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day{yr}(wfp_top:wfp_bottom);
DOresp_rate_umolkg_day_95CI_high{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day_95CI_high{yr}(wfp_top:wfp_bottom);
DOresp_rate_umolkg_day_95CI_low{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day_95CI_low{yr}(wfp_top:wfp_bottom);
p_value{yr}(wfp_top:wfp_bottom) = wfp_p_value{yr}(wfp_top:wfp_bottom);
prho{yr}(wfp_top:wfp_bottom) = wfp_Dprod_prho{yr}(wfp_top:wfp_bottom);

% Year 4, glider 6 
yr = 4; glid_ind = 6;
glid_bottom = 350;
wfp_top = glid_bottom + 1; 
% Glider 
DOresp_rate_umolkg_day{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day{glid_ind}(glid_top:glid_bottom);
DOresp_rate_umolkg_day_95CI_high{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day_95CI_high{glid_ind}(glid_top:glid_bottom);
DOresp_rate_umolkg_day_95CI_low{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day_95CI_low{glid_ind}(glid_top:glid_bottom);
p_value{yr}(glid_top:glid_bottom) = glider_p_value{glid_ind}(glid_top:glid_bottom);
prho{yr}(glid_top:glid_bottom) = glider_regress_prho{glid_ind}(glid_top:glid_bottom);
% WFP 
DOresp_rate_umolkg_day{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day{yr}(wfp_top:wfp_bottom);
DOresp_rate_umolkg_day_95CI_high{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day_95CI_high{yr}(wfp_top:wfp_bottom);
DOresp_rate_umolkg_day_95CI_low{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day_95CI_low{yr}(wfp_top:wfp_bottom);
p_value{yr}(wfp_top:wfp_bottom) = wfp_p_value{yr}(wfp_top:wfp_bottom);
prho{yr}(wfp_top:wfp_bottom) = wfp_Dprod_prho{yr}(wfp_top:wfp_bottom);

% Year 5, glider 8 
yr = 5; glid_ind = 8;
glid_bottom = 355;
wfp_top = glid_bottom + 1; 
% Glider 
DOresp_rate_umolkg_day{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day{glid_ind}(glid_top:glid_bottom);
DOresp_rate_umolkg_day_95CI_high{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day_95CI_high{glid_ind}(glid_top:glid_bottom);
DOresp_rate_umolkg_day_95CI_low{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day_95CI_low{glid_ind}(glid_top:glid_bottom);
p_value{yr}(glid_top:glid_bottom) = glider_p_value{glid_ind}(glid_top:glid_bottom);
prho{yr}(glid_top:glid_bottom) = glider_regress_prho{glid_ind}(glid_top:glid_bottom);
% WFP 
DOresp_rate_umolkg_day{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day{yr}(wfp_top:wfp_bottom);
DOresp_rate_umolkg_day_95CI_high{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day_95CI_high{yr}(wfp_top:wfp_bottom);
DOresp_rate_umolkg_day_95CI_low{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day_95CI_low{yr}(wfp_top:wfp_bottom);
p_value{yr}(wfp_top:wfp_bottom) = wfp_p_value{yr}(wfp_top:wfp_bottom);
prho{yr}(wfp_top:wfp_bottom) = wfp_Dprod_prho{yr}(wfp_top:wfp_bottom);

% Year 6, glider 11 
yr = 6; glid_ind = 10; %11;
glid_bottom = 180;
wfp_top = glid_bottom + 1; 
% Glider 
DOresp_rate_umolkg_day{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day{glid_ind}(glid_top:glid_bottom);
DOresp_rate_umolkg_day_95CI_high{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day_95CI_high{glid_ind}(glid_top:glid_bottom);
DOresp_rate_umolkg_day_95CI_low{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day_95CI_low{glid_ind}(glid_top:glid_bottom);
p_value{yr}(glid_top:glid_bottom) = glider_p_value{glid_ind}(glid_top:glid_bottom);
prho{yr}(glid_top:glid_bottom) = glider_regress_prho{glid_ind}(glid_top:glid_bottom);
% WFP 
DOresp_rate_umolkg_day{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day{yr}(wfp_top:wfp_bottom);
DOresp_rate_umolkg_day_95CI_high{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day_95CI_high{yr}(wfp_top:wfp_bottom);
DOresp_rate_umolkg_day_95CI_low{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day_95CI_low{yr}(wfp_top:wfp_bottom);
p_value{yr}(wfp_top:wfp_bottom) = wfp_p_value{yr}(wfp_top:wfp_bottom);
prho{yr}(wfp_top:wfp_bottom) = wfp_Dprod_prho{yr}(wfp_top:wfp_bottom);

% Year 7, glider 13
yr = 7; glid_ind = 13;
glid_bottom = 175;
wfp_top = glid_bottom + 1; 
% Glider 
DOresp_rate_umolkg_day{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day{glid_ind}(glid_top:glid_bottom);
DOresp_rate_umolkg_day_95CI_high{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day_95CI_high{glid_ind}(glid_top:glid_bottom);
DOresp_rate_umolkg_day_95CI_low{yr}(glid_top:glid_bottom) = glider_DOresp_rate_umolkg_day_95CI_low{glid_ind}(glid_top:glid_bottom);
p_value{yr}(glid_top:glid_bottom) = glider_p_value{glid_ind}(glid_top:glid_bottom);
prho{yr}(glid_top:glid_bottom) = glider_regress_prho{glid_ind}(glid_top:glid_bottom);
% WFP 
DOresp_rate_umolkg_day{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day{yr}(wfp_top:wfp_bottom);
DOresp_rate_umolkg_day_95CI_high{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day_95CI_high{yr}(wfp_top:wfp_bottom);
DOresp_rate_umolkg_day_95CI_low{yr}(wfp_top:wfp_bottom) = wfp_DOresp_rate_umolkg_day_95CI_low{yr}(wfp_top:wfp_bottom);
p_value{yr}(wfp_top:wfp_bottom) = wfp_p_value{yr}(wfp_top:wfp_bottom);
prho{yr}(wfp_top:wfp_bottom) = wfp_Dprod_prho{yr}(wfp_top:wfp_bottom);


%%
% for j = 1:7
    figure(3)
%     set(gcf,'position',[50,50,1400,300])
%     subplot(1,7,j)
    plot(glider_DOresp_rate_umolkg_day3{10},1:1000,'.')
    hold on
        plot(glider_DOresp_rate_umolkg_day3{11},1:1000,'.')
    axis ij
    ax = gca; 
    grid on
%     title(['Yr ' num2str(j)])
    ylim([0 1000])
% end
% % figure(3)
% sgtitle('Seasonal export versus depth (mol C m^-^2)','Fontsize',14,'FontWeight','bold')

%% Create regression length for each science year 
k = [3 4 5 6 8 10 13]; % Since indexed by glider, pull one glider for each science year 
remin0_depth = [];
regress_length_days = [];
for j = 1:7
    regress_length_days{j} = glider_resp_length_days{k(j)}';
        % 100:2000 limit because otherwise will find very top of water
        % column
    [a,~] = find(DOresp_rate_umolkg_day{j}(100:2000) >= 0,1,'first');
    remin0_depth{j} = 100 + a; % add index min 
end

for j = 1:7
figure
plot(regress_length_days{j},1:2000) % From Meg's Product 
hold on
plot(wfp_regress_days{j},1:2000) % My regression calcul
axis ij
end
%% Find depth of maximum mixing for each year 
cd('G:\Shared drives\NSF_Irminger\Data_Files\From Meg')
load blended_mld_daily.mat

% Remove nan data and create MLDs for every day
day_mld0 = blended_mld_daily_all.mld;
day_dn0 = datenum(blended_mld_daily_all.time);

day_dn0(isnan(day_mld0)) = [];
day_mld0(isnan(day_mld0)) = [];

day_mld = interp1(day_dn0,day_mld0,datenum(blended_mld_daily_all.time),'linear');
day_mld = round(day_mld);
day_dn = datenum(blended_mld_daily_all.time); 

mld_max = islocalmax(day_mld,'MinSeparation',days(270),'SamplePoints',blended_mld_daily_all.time);
mld_max = find(mld_max); 
mld_max_ind = mld_max(1:8); % Ignore last winter, past my timeseries 

figure
plot(blended_mld_daily_all.time,day_mld,'.k')
hold on
plot(blended_mld_daily_all.time(mld_max_ind),day_mld(mld_max_ind),'*m','MarkerSize',8)
axis ij
grid on
title('Maximum Annual MLDs')
ylabel('MLDs (db)')
xlim([datetime(2015,01,01) datetime(2022,08,15)])

max_winter_mld = day_mld(mld_max_ind);
%%

DOresp_season_umolkg = [];
DOresp_season_umolkg_95CI_high = [];
DOresp_season_umolkg_95CI_low = [];
DOresp_season_molm3 = [];
DOresp_season_molm3_95CI_high = [];
DOresp_season_molm3_95CI_low = [];
DOinventory_molm2 = []; 
DOinventory_molm2_95CI_high = [];
DOinventory_molm2_95CI_low = [];
removed_depths = [];
good_depths = [];

for j = 1:7

    DOresp_season_umolkg{j} = DOresp_rate_umolkg_day{j}.*regress_length_days{j};
%     DOresp_season_umolkg{j} = DOresp_rate_umolkg_day{j}.*365.25;
    DOresp_season_umolkg_95CI_high{j} = DOresp_rate_umolkg_day_95CI_high{j}.*regress_length_days{j};
    DOresp_season_umolkg_95CI_low{j} = DOresp_rate_umolkg_day_95CI_low{j}.*regress_length_days{j};
     
    DOresp_season_molm3{j} = (DOresp_season_umolkg{j}.*prho{j})/(1000*1000);
    DOresp_season_molm3_95CI_high{j} = (DOresp_season_umolkg_95CI_high{j}.*prho{j})/(1000*1000);
    DOresp_season_molm3_95CI_low{j} = (DOresp_season_umolkg_95CI_low{j}.*prho{j})/(1000*1000);
    
end


%%

for j = 1:7
    C_cumsum{j} = cumsum(DOresp_season_molm3{j}(1:remin0_depth{j})*-0.69,'reverse');
end
for j = 1:7
    figure(3)
    set(gcf,'position',[50,50,1400,300])
    subplot(1,7,j)
    ax = gca;
    b = barh(1:remin0_depth{j},C_cumsum{j});
    b.FaceColor = 'k';
    b.EdgeColor = 'k';
    axis ij
    ylim([0 1500])
    xlim([0 10])
    title([num2str(j+2014) ' - ' num2str(j+2015)],'Fontsize',13,'Fontweight','normal')
    if j == 1
        ylabel('Pressure (db)')
    end
    hold on
    if remin0_depth{j} > max_winter_mld(j+1)
        b = barh(max_winter_mld(j+1):remin0_depth{j},C_cumsum{j}(max_winter_mld(j+1):remin0_depth{j}));
    b.FaceColor = 'k';
    b.EdgeColor = 'k';
    end
%     plot(0:10,ones(length(0:10),1)*max_winter_mld(j+1),'k--') % Subsequent winter mixing 
    grid on
    ax.FontSize = 15;
    ax.XAxisLocation = 'top';
end
% figure(3)
sgtitle('Total respired carbon versus depth (mol C m^-^2 yr^-^1)','Fontsize',18,'FontWeight','bold')

%%
depth_interest = [];
depth_interest_over_max_winter = []; 

for j = 1:7 
    inv_top = 50;
    inv_bottom = remin0_depth{j};
    depth_interest{j} = inv_top:inv_bottom;
    depth_interest_top_100m = 1:100;
    depth_interest_100m_500m = 100:500;
    depth_interest_500m_1000m = 500:1000;
    depth_interest_over_1000m = 1000:1500;
    depth_interest_over_max_winter{j} = max_winter_mld(j+1):1500;
    depth_interest_below_max_winter{j} = inv_top:max_winter_mld(j+1);
    if j == 5
        depth_interest_over_max_winter{j} = max_winter_mld(j+1):max_winter_mld(j+1)+1;
        depth_interest_below_max_winter{j} = inv_top:remin0_depth{j};
    end
    if j == 1
        depth_interest_below_max_winter{j} = inv_top:remin0_depth{j};
    end
% 
    DOinventory_molm2(j) = min(cumsum(DOresp_season_molm3{j}(depth_interest{j}),'omitnan'));
    DOinventory_molm2_95CI_high(j) = min(cumsum(DOresp_season_molm3_95CI_high{j}(depth_interest{j}),'omitnan'));
    DOinventory_molm2_95CI_low(j) = min(cumsum(DOresp_season_molm3_95CI_low{j}(depth_interest{j}),'omitnan'));

    DOinventory_molm2_top_100m(j) = min(cumsum(DOresp_season_molm3{j}(depth_interest_top_100m),'omitnan'));
    DOinventory_molm2_95CI_high_top_100m(j) = min(cumsum(DOresp_season_molm3_95CI_high{j}(depth_interest_top_100m),'omitnan'));
    DOinventory_molm2_95CI_low_top_100m(j) = min(cumsum(DOresp_season_molm3_95CI_low{j}(depth_interest_top_100m),'omitnan'));

    DOinventory_molm2_100m_500m(j) = min(cumsum(DOresp_season_molm3{j}(depth_interest_100m_500m),'omitnan'));
    DOinventory_molm2_95CI_high_100m_500m(j) = min(cumsum(DOresp_season_molm3_95CI_high{j}(depth_interest_100m_500m),'omitnan'));
    DOinventory_molm2_95CI_low_100m_500m(j) = min(cumsum(DOresp_season_molm3_95CI_low{j}(depth_interest_100m_500m),'omitnan'));

    DOinventory_molm2_500m_1000m(j) = min(cumsum(DOresp_season_molm3{j}(depth_interest_500m_1000m),'omitnan'));
    DOinventory_molm2_95CI_high_500m_1000m(j) = min(cumsum(DOresp_season_molm3_95CI_high{j}(depth_interest_500m_1000m),'omitnan'));
    DOinventory_molm2_95CI_low_500m_1000m(j) = min(cumsum(DOresp_season_molm3_95CI_low{j}(depth_interest_500m_1000m),'omitnan'));

    DOinventory_molm2_over_1000m(j) = min(cumsum(DOresp_season_molm3{j}(depth_interest_over_1000m),'omitnan'));
    DOinventory_molm2_95CI_high_over_1000m(j) = min(cumsum(DOresp_season_molm3_95CI_high{j}(depth_interest_over_1000m),'omitnan'));
    DOinventory_molm2_95CI_low_over_1000m(j) = min(cumsum(DOresp_season_molm3_95CI_low{j}(depth_interest_over_1000m),'omitnan'));
    if max_winter_mld(j+1) < remin0_depth{j}      
        DOinventory_molm2_over_max_winter(j) = min(cumsum(DOresp_season_molm3{j}(max_winter_mld(j+1):remin0_depth{j}),'omitnan'));
        DOinventory_molm2_95CI_high_over_max_winter(j) = min(cumsum(DOresp_season_molm3_95CI_high{j}(max_winter_mld(j+1):remin0_depth{j}),'omitnan'));
        DOinventory_molm2_95CI_low_over_max_winter(j) = min(cumsum(DOresp_season_molm3_95CI_low{j}(max_winter_mld(j+1):remin0_depth{j}),'omitnan'));
    else
        DOinventory_molm2_over_max_winter(j) = NaN;
        DOinventory_molm2_95CI_high_over_max_winter(j) = NaN;
        DOinventory_molm2_95CI_low_over_max_winter(j) = NaN;
    end
    DOinventory_molm2_below_max_winter(j) = min(cumsum(DOresp_season_molm3{j}(depth_interest_below_max_winter{j}),'omitnan'));
    DOinventory_molm2_95CI_high_below_max_winter(j) = min(cumsum(DOresp_season_molm3_95CI_high{j}(depth_interest_below_max_winter{j}),'omitnan'));
    DOinventory_molm2_95CI_low_below_max_winter(j) = min(cumsum(DOresp_season_molm3_95CI_low{j}(depth_interest_below_max_winter{j}),'omitnan'));

end
%%
for j = 1:7
figure(10)
set(gcf,'position',[100,100,500,400])
subplot(1,7,j)
plot(DOinventory_molm2(j)*-0.69,depth_interest{j},'k')
hold on
plot(DOinventory_molm2_95CI_high(j)*-0.69,depth_interest{j},'b')
plot(DOinventory_molm2_95CI_low(j)*-0.69,depth_interest{j},'r')

axis ij
ylabel('Pressure (db)')
xlabel('Inventory Cumulative C mol m2 ')
end
%%
run('GeneralSettings.m')
% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
set(gcf,'position',[100,100,1200,250])
hold(axes1,'on');
Cinventory_molm2 = DOinventory_molm2*-0.69;
Cinventory_molm2_95CI_low = DOinventory_molm2_95CI_low*-0.69;
Cinventory_molm2_95CI_high = DOinventory_molm2_95CI_high*-0.69;
x = 2:8;
b = bar(x,Cinventory_molm2);
hold on
b.FaceColor = purple;
% errorbar(2:8,Cinventory_molm2,Cinventory_molm2_95CI_high - Cinventory_molm2,Cinventory_molm2_95CI_low - Cinventory_molm2,'ok')
er = errorbar(x,Cinventory_molm2,Cinventory_molm2 - Cinventory_molm2_95CI_low,Cinventory_molm2 - Cinventory_molm2_95CI_high);
er.Color = [ 0 0 0];
er.LineStyle = 'none';

b2 = bar(1,nanmean(Cinventory_molm2));
b2.FaceColor = purple;
% er = errorbar(1,nanmean(Cinventory_molm2),nanstd(Cinventory_molm2),nanstd(Cinventory_molm2));
% er.Color = [ 0 0 0];
er.LineStyle = 'none';
ylabel('mol C m^-^2 yr^-^1')
box(axes1,'on');
hold(axes1,'off');
set(axes1,'XTick',[1:8],...
    'XTickLabel',...
    {'Mean','2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022'});
title('Run 4: Seasonal Export thru Remin0')
axes1.FontSize = 13;
grid on
ylim([0 20])
