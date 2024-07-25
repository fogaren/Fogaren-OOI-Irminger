%% Load workspace 
clearvars; close all
addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('wfpmerge_output_fixedPc1600db.mat')
wfp_prs = 150:1:2600; % Depths of Hilary's product

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('glider_griddall_fixedPc1600db.mat')
glider = glidergrid; clear glidergrid;
glider_prs = 1:1000;
%%
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load respiration_length_by_year.mat

%%
% Create empty output variables 
DOresp_rate_umolkg_day = [];
DOresp_rate_umolkg_day_95CI_high = [];
DOresp_rate_umolkg_day_95CI_low = []; 
b_umolkg = [];
p_value = [];
R2 = [];
regress_days = []; 
DOresp_season_umolkg = []; % rate (slope) *resp_days 
DOresp_season_umolkg_95CI_high = []; % rate (slope) *resp_days 
DOresp_season_umolkg_95CI_low = []; % rate (slope) *resp_days 
regress_prho = [];
DOresp_season_molm3 = []; 
DOresp_season_molm3_95CI_high = [];
DOresp_season_molm3_95CI_low = [];
DO_out_removed = doxy;

%%
for j = 1:7

    for z =  1:2000
        
        time_test = find(time < resp_end{j}(z));
        if resp_start{j}(z) == resp_end{j}(z)
            dt_days = 0;
            resp_start_z = NaN;
            resp_end_z = NaN; 
        elseif isempty(time_test) 
            dt_days = 0; 
        else
            [resp_start_z,~] = find(time > resp_start{j}(z),1,'first');
            [resp_end_z,~] = find(time < resp_end{j}(z),1,'last');
            dt_days = time(resp_start_z:resp_end_z) - time(resp_start_z);
        end

        if isempty(dt_days) %Number of days for regression
            % If less than that #, output NaN/0 data 
            mdl = fitlm(NaN,NaN);
            regress_prho{j}(z) = NaN;
            CI(1:2,1:2) = 0;
            resp_ind = 0;  
            dt_days = 0;
        elseif dt_days < 20 %Number of days for regression
            % If less than that #, output NaN/0 data 
            mdl = fitlm(NaN,NaN);
            regress_prho{j}(z) = NaN;
            CI(1:2,1:2) = 0;
            resp_ind = 0;  
            dt_days = 0;
        elseif max(dt_days) >= 20
            resp_ind = resp_start_z:resp_end_z;

            % Remove prho outliers 
            prho_detrend = detrend(prho(z,resp_ind),'omitnan');
            bad_prho = isoutlier(prho_detrend,'quartiles','SamplePoints',time(resp_start_z:resp_end_z));
%             Oxygen filter doens't filter out any process, not using
            doxy_detrended = detrend(doxy(z,resp_ind),'omitnan');
            bad_doxy = isoutlier(doxy_detrended,'quartiles','SamplePoints',time(resp_start_z:resp_end_z));

            mdl = fitlm(dt_days(bad_prho == 0 & bad_doxy == 0),doxy(z,resp_ind(bad_prho == 0 & bad_doxy == 0)));
            CI = mdl.coefCI;

            regress_prho{j}(z) = nanmean(prho(z,resp_ind(bad_prho == 0 & bad_doxy == 0)));
                    
            DO_out_removed(z,resp_ind(bad_prho == 1)) = NaN;
            DO_out_removed(z,resp_ind(bad_doxy == 1)) = NaN;

        end
        

        % Stores them by actual depth 
        DOresp_rate_umolkg_day{j}(z) = mdl.Coefficients.Estimate(2);
        DOresp_rate_umolkg_day_95CI_high{j}(z) = CI(2,1);
        DOresp_rate_umolkg_day_95CI_low{j}(z) = CI(2,2); 
        b_umolkg{j}(z) = mdl.Coefficients.Estimate(1);
        p_value{j}(z) = mdl.Coefficients.pValue(2);
        R2{j}(z) = mdl.Rsquared.Ordinary;
        regress_days{j}(z) = max(dt_days); 

        DOresp_season_umolkg{j}(z) = mdl.Coefficients.Estimate(2)*resp_length_days{j}(z); % rate (slope) *resp_days
        DOresp_season_umolkg_95CI_high{j}(z) = CI(2,1)*resp_length_days{j}(z); % rate (slope) *resp_days
        DOresp_season_umolkg_95CI_low{j}(z) = CI(2,2)*resp_length_days{j}(z);% rate (slope) *resp_days

        DOresp_season_molm3{j}(z) = (DOresp_season_umolkg{j}(z).*regress_prho{j}(z))/(1000*1000);
        DOresp_season_molm3_95CI_high{j}(z) = (DOresp_season_umolkg_95CI_high{j}(z).*regress_prho{j}(z))/(1000*1000);
        DOresp_season_molm3_95CI_low{j}(z) = (DOresp_season_umolkg_95CI_low{j}(z).*regress_prho{j}(z))/(1000*1000);
    end
end
%% Looking at Year 3 R(z) calculations from glider and WFP during same Dproduction 
wfp_yr3_DOresp_rate_umolkg_day = []; 
glid_yr3_DOresp_rate_umolkg_day = [];

for z = 175:1000

    [resp_start_z,~] = find(resp.time > glider{5}.time(1),1,'first');
    [resp_end_z,~] = find(resp.time < glider{5}.time(end),1,'last');
    dt_days = resp.time(resp_start_z:resp_end_z) - resp.time(resp_start_z);
    resp_ind = resp_start_z:resp_end_z;
    
    % Remove prho outliers 
    prho_detrend = detrend(wfp_prho(z,resp_ind),'omitnan');
    bad_prho = isoutlier(prho_detrend,'quartiles','SamplePoints',time(resp_start_z:resp_end_z));
    % Oxygen filter 
    doxy_detrended = detrend(wfp_DO(z,resp_ind),'omitnan');
    bad_doxy = isoutlier(doxy_detrended,'quartiles','SamplePoints',time(resp_start_z:resp_end_z));
    
    mdl = fitlm(dt_days(bad_prho == 0 & bad_doxy == 0),wfp_DO(z,resp_ind(bad_prho == 0 & bad_doxy == 0)));
    
    wfp_yr3_DOresp_rate_umolkg_day(z) = mdl.Coefficients.Estimate(2);
end
%65 days 

for z = 1:1000

    dt_days = glider{5}.time - glider{5}.time(1);
    
    % Remove prho outliers 
    prho_detrend = detrend(glider{5}.pdens(z,:),'omitnan');
    bad_prho = isoutlier(prho_detrend,'quartiles','SamplePoints',glider{5}.time);
    % Oxygen filter 
    doxy_detrended = detrend(glider{5}.doxy(z,:),'omitnan');
    bad_doxy = isoutlier(doxy_detrended,'quartiles','SamplePoints',glider{5}.time);
    
    mdl = fitlm(dt_days(bad_prho == 0 & bad_doxy == 0),glider{5}.doxy(z,(bad_prho == 0 & bad_doxy == 0)));
    
    glid_yr3_DOresp_rate_umolkg_day(z) = mdl.Coefficients.Estimate(2);
end

figure
plot(wfp_yr3_DOresp_rate_umolkg_day*-0.69,1:1000,'Linewidth',2)
hold on
plot(glid_yr3_DOresp_rate_umolkg_day*-0.69,1:1000,'Linewidth',2)
ax = gca;
ax.XAxisLocation = 'top';
title({'Respiration Rate during glider deployment (\mumol C kg^-^1 d^-^1)'})
axis ij; xlim([0 0.35]); ylim([ 0 950])
grid on
legend('WFP','Glider','Location','SE')

%% Looking at Year 7 R(z) calculations from glider and WFP during same Dproduction 
wfp_yr7_DOresp_rate_umolkg_day = []; 
glid_yr7_DOresp_rate_umolkg_day = [];

for z = 175:2000
    z_ind = find(wfp_prs == z);
    [resp_start_z,~] = find(resp.time > glider{12}.time(1),1,'first');
    [resp_end_z,~] = find(resp.time < glider{12}.time(end),1,'last');
    dt_days = resp.time(resp_start_z:resp_end_z) - resp.time(resp_start_z);
    resp_ind = resp_start_z:resp_end_z;
    
    % Remove prho outliers 
    prho_detrend = detrend(resp.prho(z_ind,resp_ind),'omitnan');
    bad_prho = isoutlier(prho_detrend,'quartiles','SamplePoints',time(resp_start_z:resp_end_z));
    % Oxygen filter 
    doxy_detrended = detrend(resp.doxy(z_ind,resp_ind),'omitnan');
    bad_doxy = isoutlier(doxy_detrended,'quartiles','SamplePoints',time(resp_start_z:resp_end_z));
    
%     mdl = fitlm(dt_days(bad_prho == 0 & bad_doxy == 0),resp.doxy(z_ind,resp_ind(bad_prho == 0 & bad_doxy == 0)));
    mdl = fitlm(dt_days,resp.doxy(z_ind,resp_ind));

    wfp_yr7_DOresp_rate_umolkg_day(z) = mdl.Coefficients.Estimate(2);
end


for z = 1:1000

    
    t1 = find(glider{12}.time >= 7.383878347685186e+05 ,1,'first');
    dt_days = glider{12}.time(t1:end) - glider{12}.time(t1);
    resp_ind = t1:length(glider{12}.time);
    
    
    % Remove prho outliers 
    prho_detrend = detrend(glider{12}.pdens(z,t1:end),'omitnan');
    bad_prho = isoutlier(prho_detrend,'quartiles','SamplePoints',glider{12}.time(resp_ind));
    % Oxygen filter 
    doxy_detrended = detrend(glider{12}.doxy(z,t1:end),'omitnan');
    bad_doxy = isoutlier(doxy_detrended,'quartiles','SamplePoints',glider{12}.time(resp_ind));
    
    %mdl = fitlm(dt_days(bad_prho == 0 & bad_doxy == 0),glider{12}.doxy(z,resp_ind(bad_prho == 0 & bad_doxy == 0)));
    mdl = fitlm(dt_days,glider{12}.doxy(z,resp_ind));
    
    glid_yr7_DOresp_rate_umolkg_day(z) = mdl.Coefficients.Estimate(2);
end
%%
z = [267 480 665 900];
figure
plot(wfp_yr7_DOresp_rate_umolkg_day(175:1000),175:1000,'Linewidth',2,'Color',rgb('dark gray'))
hold on
plot(glid_yr7_DOresp_rate_umolkg_day,1:1000,'Linewidth',2,'Color','blue')
for i = 1:length(z)
    plot(-0.3:0.1:0.1,ones(5,1)*z(i),'k--','Linewidth',1.2)
end
ax = gca;
ax.XAxisLocation = 'top';
title({'Respiration Rate during overlapping deployments (\mumol DO kg^-^1 d^-^1)'})
axis ij; ylim([ 0 950]); xlim([-0.3 0.1])
grid on
legend('WFP','Glider','Location','SE')
%% To look at year 7
j = 12; %glider number 
    [resp_start_z,~] = find(resp.time > glider{j}.time(1),1,'first');
    [resp_end_z,~] = find(resp.time < glider{j}.time(end),1,'last');
    wfp_dt_days = resp.time(resp_start_z:resp_end_z) - resp.time(resp_start_z);
    resp_ind = resp_start_z:resp_end_z;

    t1 = find(glider{12}.time >= 7.383878347685186e+05 ,1,'first');
    dt_days = glider{12}.time(t1:end) - glider{12}.time(t1);
    glid_resp_ind = t1:length(glider{12}.time);

for z = [267 480 665 900]
    z_ind = find(wfp_prs == z);
    figure
    subplot(2,1,1)
    plot(glider{j}.time(glid_resp_ind),glider{j}.doxy(z,glid_resp_ind),'ok','MarkerFaceColor','blue')
    hold on
    plot(resp.time(resp_start_z:resp_end_z),resp.doxy(z_ind,resp_start_z:resp_end_z),'ok','MarkerFaceColor',rgb('dark gray'))
    grid on
    datetick
    ylabel('DO')

    subplot(2,1,2)
    plot(resp.time(resp_start_z:resp_end_z),resp.prho(z_ind,resp_start_z:resp_end_z),'ok','MarkerFaceColor',rgb('dark gray'))
    hold on; grid on
    plot(glider{j}.time(glid_resp_ind),glider{j}.pdens(z,glid_resp_ind),'ok','MarkerFaceColor','blue')
    ylabel('density')
    datetick
    sgtitle(['Year 7: Glider ' num2str(j) ' Depth = ' num2str(z)])
end
%% To look at year 6

% Looking at Year 6 R(z) calculations from glider and WFP during same Dproduction 
wfp_yr6_DOresp_rate_umolkg_day = []; 
glid_yr6_DOresp_rate_umolkg_day = [];

for z = 200; % 175:2000
    z_ind = find(wfp_prs == z);
    [resp_start_z,~] = find(resp.time > glider{11}.time(1),1,'first');
    [resp_end_z,~] = find(resp.time < glider{11}.time(end),1,'last');
    dt_days = resp.time(resp_start_z:resp_end_z) - resp.time(resp_start_z);
    resp_ind = resp_start_z:resp_end_z;
    
    % Remove prho outliers 
    prho_detrend = detrend(resp.prho(z_ind,resp_ind),'omitnan');
    bad_prho = isoutlier(prho_detrend,'quartiles','SamplePoints',time(resp_start_z:resp_end_z));
    % Oxygen filter 
    doxy_detrended = detrend(resp.doxy(z_ind,resp_ind),'omitnan');
    bad_doxy = isoutlier(doxy_detrended,'quartiles','SamplePoints',time(resp_start_z:resp_end_z));
    
     mdl = fitlm(dt_days(bad_prho == 0 & bad_doxy == 0),resp.doxy(z_ind,resp_ind(bad_prho == 0 & bad_doxy == 0)));
%     mdl = fitlm(dt_days,resp.doxy(z_ind,resp_ind));

    wfp_yr6_DOresp_rate_umolkg_day(z) = mdl.Coefficients.Estimate(2);
end
%%
for z = 200

    resp_ind = 1:length(glider{11}.time);
    dt_days = glider{j}.time - glider{j}.time(1);
    
    
    % Remove prho outliers 
    prho_detrend = detrend(glider{11}.pdens(z,:),'omitnan');
    bad_prho = isoutlier(prho_detrend,'quartiles','SamplePoints',glider{11}.time(resp_ind));
    % Oxygen filter 
    doxy_detrended = detrend(glider{11}.doxy(z,:),'omitnan');
    bad_doxy = isoutlier(doxy_detrended,'quartiles','SamplePoints',glider{11}.time(resp_ind));
    
    mdl = fitlm(dt_days(bad_prho == 0 & bad_doxy == 0),glider{11}.doxy(z,resp_ind(bad_prho == 0 & bad_doxy == 0)));
     mdl = fitlm(dt_days,glider{11}.doxy(z,resp_ind));
    
    glid_yr6_DOresp_rate_umolkg_day(z) = mdl.Coefficients.Estimate(2);
end
%%
 z = [200 329 486];
figure
plot(wfp_yr6_DOresp_rate_umolkg_day(175:1000),175:1000,'Linewidth',2,'Color',rgb('dark gray'))
hold on
plot(glid_yr6_DOresp_rate_umolkg_day,1:1000,'Linewidth',2,'Color','blue')
for i = 1:length(z)
    plot(-0.3:0.1:0.1,ones(5,1)*z(i),'k--','Linewidth',1.2)
end
ax = gca;
ax.XAxisLocation = 'top';
title({'Respiration Rate during overlapping deployments (\mumol DO kg^-^1 d^-^1)'})
axis ij; ylim([ 0 950]); xlim([-0.15 0.05])
grid on
legend('WFP','Glider','Location','SW')
%%
j = 11; %glider number 10 or 11
    [resp_start_z,~] = find(resp.time > glider{j}.time(1),1,'first');
    [resp_end_z,~] = find(resp.time < glider{j}.time(end),1,'last');
    wfp_dt_days = resp.time(resp_start_z:resp_end_z) - resp.time(resp_start_z);
    resp_ind = resp_start_z:resp_end_z;


    glid_resp_ind = 1:length(glider{j}.time);

for  z = [200 329 486]
    
    z_ind = find(wfp_prs == z);
    figure
    subplot(2,1,1)
    plot(glider{j}.time(glid_resp_ind),glider{j}.pdens(z,glid_resp_ind),'ok','MarkerFaceColor','blue')
    hold on
%     plot(resp.time(resp_start_z:resp_end_z),resp.doxy(z_ind,resp_start_z:resp_end_z),'ok','MarkerFaceColor',rgb('dark gray'))
    grid on
    datetick
    ylabel('density')
title(['Year 6: Glider ' num2str(j) ' Depth = ' num2str(z)])
    subplot(2,1,2)
%     plot(resp.time(resp_start_z:resp_end_z),resp.prho(z_ind,resp_start_z:resp_end_z),'ok','MarkerFaceColor',rgb('dark gray'))
%     hold on; grid on
%     plot(glider{j}.time(glid_resp_ind),glider{j}.pdens(z,glid_resp_ind),'ok','MarkerFaceColor','blue')
plot(resp.time(resp_start_z:resp_end_z),resp.prho(z_ind,resp_start_z:resp_end_z),'ok','MarkerFaceColor',rgb('dark gray'))
grid on
ylabel('density')
    datetick
    title(['Year 6: WFP Depth = ' num2str(z)])
    
end
%%
prs_grid = 1:2600;
[X2,Y2] = meshgrid(time,prs_grid);

figure
set(gcf,'position',[100,100,900,300])
scatter(X2(~isnan(DO_out_removed)),Y2(~isnan(DO_out_removed)),5,doxy(~isnan(DO_out_removed)),'filled')
hold on; axis ij; box on
plot(dt,mld_db,'ok','MarkerSize',2,'MarkerFaceColor','k')
for j = 1:length(mld_max_ind)-1
%     plot(dt(mld_max_ind(j):mld_max_ind(j+1)),ones(1,length(mld_max_ind(j):mld_max_ind(j+1)))*1800,'k')
    dt_text = round((mld_max_ind(j+1) - mld_max_ind(j))/2) + mld_max_ind(j);
    text(dt(dt_text)-108,1900,['Year ' num2str(j)],'Fontsize',12,'FontWeight','bold')
end
for j = 1:length(mld_max_ind)
    plot(dt(mld_max_ind(j))*ones(201,1),1800:2000,'k','Linewidth',2)
end
ylim([0 2000])
clim([260 320])
datetick('x','yyyy');
xlim([datenum(2015,01,01) datenum(2022,04,01)])
cmocean('dense')
ylabel('Pressure (dbar)', 'Fontsize', 12); hcb = colorbar; set(hcb,'location','eastoutside')
hcb.Label.String = 'DO (\mumol kg^-^1)';
hcb.FontSize = 12;
ax = gca;
set(ax, 'TickDir', 'out')
ax.FontSize = 12;
%% Respiration Rate versus depth for all Years 
close all
figure
    for yr = 1:7 % Science year 
        set(gcf,'position',[50,50,1200,600])
        subplot(1,7,yr)
        ax = gca;
%         boundedline(DOresp_rate_umolkg_day{yr}*-0.69,1:2000,...
    %                 DOresp_rate_umolkg_day_95CI_high{yr}*-0.69 -DOresp_rate_umolkg_day{yr}*-0.69,'orientation','horiz','alpha')   
       if yr ~= 3
            plot(DOresp_rate_umolkg_day{yr}(50:1500),50:1500,'Linewidth',2)
       end
       if yr == 3
           plot(DOresp_rate_umolkg_day{yr}(208:1500),208:1500,'Linewidth',2)
       end
        axis ij
        ylabel('Pressure (db)')
        xlim([-0.55 0])
        ylim([50 1500])
        grid on
        ax.XAxisLocation = 'top';
        sgtitle({'Respiration Rate (\mumol O_2 kg^-^1 d^-^1)'})
        title([num2str(2014+yr) ' - ' num2str(2015+yr)])
        % legend('95% confidence intervals','Location','SE','Box','off')
%         ax.FontSize = 15;
        box on
    end

%% 

 yr = 3; 
 z = 900; 
 z_ind = find(wfp_prs == z);
if yr == 1
    j1 = 1;
    j2 = 2;
    j3 = 3; 
elseif yr == 2
    j1 = 4;
elseif yr == 3
    j1 = 5;
elseif yr == 4
    j1 = 6;
    j2 = 7;
elseif yr == 5
    j1 = 8;
    j2 = 9;
elseif yr == 6
    j1 = 10;
    j2 = 11;
elseif yr == 7
    j1 = 12;
    j2 = 13;
end



        % For first glider 
        time_test = find(glider{j1}.time < resp_end{yr}(z));
        if resp_start{yr}(z) == resp_end{yr}(z)
            dt_days = 0;
            resp_start_z = NaN;
            resp_end_z = NaN; 
        elseif isempty(time_test) 
            dt_days = 0; 
        else
            [resp_start_z,~] = find(glider{j1}.time > resp_start{yr}(z),1,'first');
            [resp_end_z,~] = find(glider{j1}.time < resp_end{yr}(z),1,'last');
        end
            resp_ind1 = resp_start_z:resp_end_z;
        
        % For second glider 

        if yr == 1 || yr == 4 || yr == 5 || yr == 6 || yr ==7

            time_test = find(glider{j2}.time < resp_end{yr}(z));
            if resp_start{yr}(z) == resp_end{yr}(z)
                dt_days = 0;
                resp_start_z = NaN;
                resp_end_z = NaN; 
            elseif isempty(time_test) 
                dt_days = 0; 
            else
                [resp_start_z,~] = find(glider{j2}.time > resp_start{yr}(z),1,'first');
                [resp_end_z,~] = find(glider{j2}.time < resp_end{yr}(z),1,'last');
            end
                resp_ind2 = resp_start_z:resp_end_z;
        end

        % For third glider 
        if yr == 1

            time_test = find(glider{j3}.time < resp_end{yr}(z));
            if resp_start{yr}(z) == resp_end{yr}(z)
                dt_days = 0;
                resp_start_z = NaN;
                resp_end_z = NaN; 
            elseif isempty(time_test) 
                dt_days = 0; 
            else
                [resp_start_z,~] = find(glider{j3}.time > resp_start{yr}(z),1,'first');
                [resp_end_z,~] = find(glider{j3}.time < resp_end{yr}(z),1,'last');
            end
                resp_ind3 = resp_start_z:resp_end_z;
        end
        
        % For wfp data 
        time_test = find(resp.time < resp_end{yr}(z));
        if resp_start{yr}(z) == resp_end{yr}(z)
            dt_days = 0;
            resp_start_z = NaN;
            resp_end_z = NaN; 
        elseif isempty(time_test) 
            dt_days = 0; 
        else
            [resp_start_z,~] = find(resp.time > resp_start{yr}(z),1,'first');
            [resp_end_z,~] = find(resp.time < resp_end{yr}(z),1,'last');
        end
            resp_ind_wfp = resp_start_z:resp_end_z;
    
        % For combined data 
        time_test = find(time < resp_end{yr}(z));
        if resp_start{yr}(z) == resp_end{yr}(z)
            dt_days = 0;
            resp_start_z = NaN;
            resp_end_z = NaN; 
        elseif isempty(time_test) 
            dt_days = 0; 
        else
            [resp_start_z,~] = find(time > resp_start{yr}(z),1,'first');
            [resp_end_z,~] = find(time < resp_end{yr}(z),1,'last');
        end
            resp_ind_time = resp_start_z:resp_end_z;

% figure
% subplot(2,1,1)
% plot(glider{j1}.time(resp_ind1),glider{j1}.doxy(z,resp_ind1),'o','Color','none','MarkerFaceColor',rgb('blue'))
% hold on
% if yr == 4 || yr == 5 || yr == 6 || yr ==7
%     plot(glider{j2}.time(resp_ind2),glider{j2}.doxy(z,resp_ind2),'o','Color','none','MarkerFaceColor',rgb('red'))
% end
% if yr == 1
%     plot(glider{j2}.time(resp_ind2),glider{j2}.doxy(z,resp_ind2),'o','Color','none','MarkerFaceColor',rgb('red'))
%     plot(glider{j3}.time(resp_ind3),glider{j3}.doxy(z,resp_ind3),'o','Color','none','MarkerFaceColor',rgb('yellow'))
% end
% plot(resp.time(resp_ind_wfp),wfp_DO(z,resp_ind_wfp),'o','Color','none','MarkerFaceColor',rgb('gray'))
% % plot(time(resp_ind_time),DO_out_removed(z,resp_ind_time),'ok')
% ylabel('DO (\mumol kg^-^1)')
% datetick
% title(['Yr = ' num2str(yr) ' , Depth = ' num2str(z)])
% % legend('Glider 1','Glider 2','Glider 3','Location','SW')
% grid on
% 
% subplot(2,1,2)
% plot(glider{j1}.time(resp_ind1),glider{j1}.pracsal(z,resp_ind1),'o','Color','none','MarkerFaceColor',rgb('blue'))
% hold on
% if yr == 4 || yr == 5 || yr == 6 || yr ==7
%     plot(glider{j2}.time(resp_ind2),glider{j2}.pracsal(z,resp_ind2),'o','Color','none','MarkerFaceColor',rgb('red'))
% end
% if yr == 1
%     plot(glider{j2}.time(resp_ind2),glider{j2}.pracsal(z,resp_ind2),'o','Color','none','MarkerFaceColor',rgb('red'))
%     plot(glider{j3}.time(resp_ind3),glider{j3}.pracsal(z,resp_ind3),'o','Color','none','MarkerFaceColor',rgb('yellow'))
% end
% plot(resp.time(resp_ind_wfp),wfp_sal(z,resp_ind_wfp),'o','Color','none','MarkerFaceColor',rgb('gray'))
% % plot(time(resp_ind_time),DO_out_removed(z,resp_ind_time),'ok')
% ylabel('Salinity (PSU)')
% datetick
% grid on

figure(2)
clf
plot(glider{j1}.time(resp_ind1),glider{j1}.doxy(z,resp_ind1),'o','Color','none','MarkerFaceColor',rgb('blue'))
hold on
if yr == 4 || yr == 5 || yr == 6 || yr ==7
    plot(glider{j2}.time(resp_ind2),glider{j2}.doxy(z,resp_ind2),'o','Color','none','MarkerFaceColor',rgb('red'))
end
if yr == 1
    plot(glider{j2}.time(resp_ind2),glider{j2}.doxy(z,resp_ind2),'o','Color','none','MarkerFaceColor',rgb('red'))
    plot(glider{j3}.time(resp_ind3),glider{j3}.doxy(z,resp_ind3),'o','Color','none','MarkerFaceColor',rgb('yellow'))
end
plot(resp.time(resp_ind_wfp),wfp_DO(z,resp_ind_wfp),'o','Color','none','MarkerFaceColor',rgb('gray'))
% plot(time(resp_ind_time),DO_out_removed(z,resp_ind_time),'ok')
ylabel('DO (\mumol kg^-^1)')
xlim([datenum(2017,04,01) datenum(2018,04,01)])
datetick('x','KeepLimits')
title(['Yr = ' num2str(yr) ' , Depth = ' num2str(z)])
% legend('Glider 1','Glider 2','Glider 3','Location','SW')
grid on
