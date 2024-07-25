%% Load workspace 
clearvars; close all

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('wfpmerge_output_fixedPc1600db.mat')

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('glider_griddall_fixedPc1600db.mat')
glider = glidergrid; clear glidergrid;
glider_prs = 1:1000;



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

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load respiration_length_by_glider.mat

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
%             Oxygen filter doens't filter out any process, not using
            doxy_detrended = detrend(glider{j}.doxy(z,resp_ind),'omitnan');
            bad_doxy = isoutlier(doxy_detrended,'quartiles','SamplePoints',glider{j}.time(resp_start:resp_end));

            mdl = fitlm(dt_days(bad_prho == 0 & bad_doxy == 0),glider{j}.doxy(z,resp_ind(bad_prho == 0 & bad_doxy == 0)));
            CI = mdl.coefCI;

            glider_regress_prho{j}(z) = nanmean(glider{j}.pdens(z,resp_ind));

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
figure
yr = 1;
subplot(1,2,1)
plot(glider_DOresp_rate_umolkg_day{1},z_glid,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{2},z_glid,'.','Color',red)
plot(glider_DOresp_rate_umolkg_day{3}(z_glid_200),z_glid_200,'.','Color',yellow)
axis ij
ylabel('Pressure (db)')
sgtitle(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on
ylim([0 200])
xlabel('DO resp (\mumol kg^-^1 d^-1)')
plot(-0.45144,50,'ok','MarkerFaceColor','k')
plot(-0.14322,100,'ok','MarkerFaceColor','k')
plot(-0.084843,150,'ok','MarkerFaceColor','k')
plot(-0.061877,200,'ok','MarkerFaceColor','k')
legend('Glider 1','Glider 2','Glider 3','All Data','Location','SW')

subplot(1,2,2)
plot(glider_regress_days{1},z_glid,'.','Color',blue)
hold on
plot(glider_regress_days{2},z_glid,'.','Color',red)
plot(glider_regress_days{3}(z_glid_200),z_glid_200,'.','Color',yellow)
axis ij
ylabel('Pressure (db)')
xlabel('Regression Length (d)')
ylim([0 200])
grid on
%%
figure
yr = 4;
subplot(1,2,1)
plot(glider_DOresp_rate_umolkg_day{6},z_glid,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{7},z_glid,'.','Color',red)
axis ij
ylabel('Pressure (db)')
sgtitle(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on
xlabel('DO resp (\mumol kg^-^1 d^-1)')
plot(-0.18848,100,'ok','MarkerFaceColor','k')
plot(-0.076155,200,'ok','MarkerFaceColor','k')
plot(-0.05781,300,'ok','MarkerFaceColor','k')
plot(-0.033239,400,'ok','MarkerFaceColor','k')
plot(-0.026289,500,'ok','MarkerFaceColor','k')
plot(-0.016154,600,'ok','MarkerFaceColor','k')
plot(-0.010764,700,'ok','MarkerFaceColor','k')
plot(-0.0075566,800,'ok','MarkerFaceColor','k')
plot(-0.005296,900,'ok','MarkerFaceColor','k')
legend('Glider 6','Glider 7','All Data','Location','SW')

subplot(1,2,2)
plot(glider_regress_days{6},z_glid,'.','Color',blue)
hold on
plot(glider_regress_days{7},z_glid,'.','Color',red)
axis ij
ylabel('Pressure (db)')
xlabel('Regression Length (d)')
grid on
%%
figure
yr = 5;
subplot(1,2,1)
plot(glider_DOresp_rate_umolkg_day{8},z_glid,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{9},z_glid,'.','Color',red)
axis ij
ylabel('Pressure (db)')
sgtitle(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on
xlabel('DO resp (\mumol kg^-^1 d^-1)')
plot(-0.19883,100,'ok','MarkerFaceColor','k')
plot(-0.089584,200,'ok','MarkerFaceColor','k')
plot(-0.070005,300,'ok','MarkerFaceColor','k')
plot(-0.036847,400,'ok','MarkerFaceColor','k')
plot(-0.012442,500,'ok','MarkerFaceColor','k')
plot(0,600,'ok','MarkerFaceColor','k')
plot(-0.0042266,700,'ok','MarkerFaceColor','k')
plot(-0.0053247,800,'ok','MarkerFaceColor','k')
plot(-0.0027697,900,'ok','MarkerFaceColor','k')
legend('Glider 8','Glider 9','All Data','Location','SW')

subplot(1,2,2)
plot(glider_regress_days{8},z_glid,'.','Color',blue)
hold on
plot(glider_regress_days{9},z_glid,'.','Color',red)
axis ij
ylabel('Pressure (db)')
xlabel('Regression Length (d)')
grid on
%%
figure
yr = 6;
subplot(1,2,1)
plot(glider_DOresp_rate_umolkg_day{10},z_glid,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{11},z_glid,'.','Color',red)
axis ij
ylabel('Pressure (db)')
sgtitle(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on
xlabel('DO resp (\mumol kg^-^1 d^-1)')
plot(-0.32031,50,'ok','MarkerFaceColor','k')
plot(-0.091578,100,'ok','MarkerFaceColor','k')
plot(-0.051581,150,'ok','MarkerFaceColor','k')
plot(-0.056331,200,'ok','MarkerFaceColor','k')
legend('Glider 10','Glider 11','All Data','Location','SW')

subplot(1,2,2)
plot(glider_regress_days{10},z_glid,'.','Color',blue)
hold on
plot(glider_regress_days{11},z_glid,'.','Color',red)
axis ij
ylabel('Pressure (db)')
xlabel('Regression Length (d)')
grid on

%%
figure
yr = 7;
subplot(1,2,1)
plot(glider_DOresp_rate_umolkg_day{12},z_glid,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{13},z_glid,'.','Color',red)
axis ij
ylabel('Pressure (db)')
sgtitle(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on
xlabel('DO resp (\mumol kg^-^1 d^-1)')
plot(-0.55392,50,'ok','MarkerFaceColor','k')
plot(-0.24964,100,'ok','MarkerFaceColor','k')
plot(-0.18208,150,'ok','MarkerFaceColor','k')
plot(-0.14214,200,'ok','MarkerFaceColor','k')
legend('Glider 10','Glider 11','All Data','Location','SW')

subplot(1,2,2)
plot(glider_regress_days{12},z_glid,'.','Color',blue)
hold on
plot(glider_regress_days{13},z_glid,'.','Color',red)
axis ij
ylabel('Pressure (db)')
xlabel('Regression Length (d)')
grid on

%%

z_glid = glider_prs;
z_glid_200 = 1:200;
depth = 175:2000;

% Year 1 index = 1, 2 and 3
figure
yr = 1;
subplot(2,4,yr)
plot(glider_DOresp_rate_umolkg_day{1},z_glid,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{2},z_glid,'.','Color',red)
plot(glider_DOresp_rate_umolkg_day{3}(z_glid_200),z_glid_200,'.','Color',yellow)
plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.k')
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on

% Year 2 ind 4 
yr = 2;
subplot(2,4,yr)
plot(glider_DOresp_rate_umolkg_day{4},z_glid,'.','Color',blue)
hold on
plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.k')
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on

% Year 3 ind 5 
yr = 3;
subplot(2,4,yr)
plot(glider_DOresp_rate_umolkg_day{5},z_glid,'.','Color',blue)
hold on
plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.k')
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on

% Year 4 index = 6 and 7
yr = 4;
subplot(2,4,yr)
plot(glider_DOresp_rate_umolkg_day{6},z_glid,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{7},z_glid,'.','Color',red)
plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.k')
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on

% Year 5 index = 8 and 9
yr = 5;
subplot(2,4,yr)
plot(glider_DOresp_rate_umolkg_day{8},z_glid,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{9},z_glid,'.','Color',red)
plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.k')
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on

% Year 6 index = 10 and 11
yr = 6;
subplot(2,4,yr)
plot(glider_DOresp_rate_umolkg_day{10}(z_glid_200),z_glid_200,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{11},z_glid,'.','Color',red)
plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.k')
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on

% Year 7 index = 12 and 13
yr = 7;
subplot(2,4,yr)
plot(glider_DOresp_rate_umolkg_day{12},z_glid,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{13}(z_glid_200),z_glid_200,'.','Color',red)
plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.k')
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on
sgtitle('Respiration Rate (\mumol DO kg^-^1 d^-^1)')