%% Load workspace 
clearvars; close all

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('wfpmerge_output_fixedPc1600db.mat')

% Sort time to be in ascending order
[time,IND] = sort(wggmerge.time);
doxy = wggmerge.doxy(:,IND);
prho = wggmerge.pdens(:,IND);
temp = wggmerge.temp(:,IND);

resp.time = time;
resp.doxy = doxy; 
resp.prho = prho; 
resp.temp = temp; 
clear time doxy IND

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
wfp_DOresp_rate_umolkg_day = [];
wfp_DOresp_rate_umolkg_day_95CI_high = [];
wfp_DOresp_rate_umolkg_day_95CI_low = []; 
wfp_b_umolkg = [];
wfp_p_value = [];
wfp_R2 = [];
wfp_regress_days = []; 
wfp_Dremin_days = [];
wfp_DOresp_season_umolkg = []; % rate (slope) *remin_days 
wfp_DOresp_season_umolkg_95CI_high = []; % rate (slope) *remin_days 
wfp_DOresp_season_umolkg_95CI_low = []; % rate (slope) *remin_days 
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
        dt_days = resp.time(regress_ind) - resp.time(regress_ind(1)); 
        Dremin_days = resp.time(regress_resp{z}.end(yr)) - resp.time(regress_resp{z}.start(yr));

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
        wfp_Dremin_days{yr-1}(z) = Dremin_days;
        wfp_DOresp_season_umolkg{yr-1}(z) = mdl.Coefficients.Estimate(2)*Dremin_days; % rate (slope) *Remin_days
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

    regress_yr_length(yr) = max(wfp_regress_days{yr});
    
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
    sgtitle('Respiration Rate (\mumol DO kg^-^1 d^-^1): Outliers removed')
    xlim([-0.1 0.04])
    grid on
end

for yr = 1:7
    figure(9)
    set(gcf,'position',[100,100,1200,400])
    subplot(1,7,yr)
    plot(wfp_regress_days{yr},1:max(z),'.')
    hold on
    plot(wfp_Dremin_days{yr},1:max(z),'.')
    axis ij
    ylabel('Pressure (db)')
    xlabel(['Year: ' num2str(yr)])
    xlim([0 500])
    sgtitle('Length of Regression Window/Dremin (days)')
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


% %%
% cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
% save wfp_respiration.mat wfp* resp