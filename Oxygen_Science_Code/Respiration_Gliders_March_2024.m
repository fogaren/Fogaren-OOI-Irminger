clearvars; close all

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('glider_griddall_fixedPc1600db.mat')
glider = glidergrid; clear glidergrid;
glider_prs = 1:1000;

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
subplot(1,3,1)
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

subplot(1,3,2)
plot(glider_regress_days{1},1:max(z),'.','Color',blue)
hold on
plot(glider_regress_days{2},1:max(z),'.','Color',red)
plot(glider_regress_days{3},1:max(z),'.','Color',yellow)
plot(glider_resp_length_days{1}(1:1000),1:1000,'.k')  
axis ij
ylabel('Pressure (db)')
title('Regression and Stratification Lengths (days)')
grid on

subplot(1,3,3)
plot(glider_DOresp_season_molm3{1}*-0.69,1:max(z),'.','Color',blue)
hold on
plot(glider_DOresp_season_molm3{2}*-0.69,1:max(z),'.','Color',red)
plot(glider_DOresp_season_molm3{3}*-0.69,1:max(z),'.','Color',yellow)
axis ij
ylabel('Pressure (db)')
title('Total Respired (mol C m^-^3)')
grid on
xlim([0 0.1])
sgtitle('Year 1: 2015-2016')

% Year 2 ind 4 
figure
set(gcf,'position',[100,100,1250,400])
subplot(1,3,1)
plot(glider_DOresp_rate_umolkg_day{4},depth,'.','Color',blue)
hold on
legend(num2str(glider{4}.glidernum),'Location','SW');
axis ij
ylabel('Pressure (db)')
title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
xlim([-0.6 0.02])
grid on

subplot(1,3,2)
plot(glider_regress_days{4},1:max(z),'.','Color',blue)
hold on
plot(glider_resp_length_days{4}(1:1000),1:1000,'.k')  
axis ij
ylabel('Pressure (db)')
title('Regression and Stratification Lengths (days)')
grid on

subplot(1,3,3)
plot(glider_DOresp_season_molm3{4}*-0.69,1:max(z),'.','Color',blue)
axis ij
ylabel('Pressure (db)')
title('Total Respired (mol C m^-^3)')
grid on
xlim([0 0.1])
sgtitle('Year 2: 2016-2017')

% Year 3 ind 5 
figure
set(gcf,'position',[100,100,1250,400])
subplot(1,3,1)
plot(glider_DOresp_rate_umolkg_day{5},depth,'.','Color',blue)
hold on
legend(num2str(glider{5}.glidernum),'Location','SW');
axis ij
ylabel('Pressure (db)')
title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
xlim([-0.6 0.02])
grid on

subplot(1,3,2)
plot(glider_regress_days{5},1:max(z),'.','Color',blue)
hold on
plot(glider_resp_length_days{5}(1:1000),1:1000,'.k')  
axis ij
ylabel('Pressure (db)')
title('Regression and Stratification Lengths (days)')
grid on

subplot(1,3,3)
plot(glider_DOresp_season_molm3{5}*-0.69,1:max(z),'.','Color',blue)
axis ij
ylabel('Pressure (db)')
title('Total Respired (mol C m^-^3)')
grid on
xlim([0 0.1])
sgtitle('Year 3: 2017-2018')

% Year 4 index = 6 and 7
figure
set(gcf,'position',[100,100,1250,400])
subplot(1,3,1)
plot(glider_DOresp_rate_umolkg_day{6},depth,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{7},depth,'.','Color',red)
legend(num2str(glider{6}.glidernum),num2str(glider{7}.glidernum),'Location','SW');
axis ij
ylabel('Pressure (db)')
title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
xlim([-0.6 0.02])
grid on

subplot(1,3,2)
plot(glider_regress_days{6},1:max(z),'.','Color',blue)
hold on
plot(glider_regress_days{7},1:max(z),'.','Color',red)
plot(glider_resp_length_days{6}(1:1000),1:1000,'.k')  
axis ij
ylabel('Pressure (db)')
title('Regression and Stratification Lengths (days)')
grid on

subplot(1,3,3)
plot(glider_DOresp_season_molm3{6}*-0.69,1:max(z),'.','Color',blue)
hold on
plot(glider_DOresp_season_molm3{7}*-0.69,1:max(z),'.','Color',red)
axis ij
ylabel('Pressure (db)')
title('Total Respired (mol C m^-^3)')
grid on
xlim([0 0.1])
sgtitle('Year 4: 2018-2019')

% Year 5 index = 8 and 9
figure
set(gcf,'position',[100,100,1250,400])
subplot(1,3,1)
plot(glider_DOresp_rate_umolkg_day{8},depth,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{9},depth,'.','Color',red)
legend(num2str(glider{8}.glidernum),num2str(glider{9}.glidernum),'Location','SW');
axis ij
ylabel('Pressure (db)')
title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
xlim([-0.6 0.02])
grid on

subplot(1,3,2)
plot(glider_regress_days{8},1:max(z),'.','Color',blue)
hold on
plot(glider_regress_days{9},1:max(z),'.','Color',red)
plot(glider_resp_length_days{8}(1:1000),1:1000,'.k')  
axis ij
ylabel('Pressure (db)')
title('Regression and Stratification Lengths (days)')
grid on

subplot(1,3,3)
plot(glider_DOresp_season_molm3{8}*-0.69,1:max(z),'.','Color',blue)
hold on
plot(glider_DOresp_season_molm3{9}*-0.69,1:max(z),'.','Color',red)
axis ij
ylabel('Pressure (db)')
title('Total Respired (mol C m^-^3)')
grid on
xlim([0 0.1])
sgtitle('Year 5: 2019-2020')

% Year 6 index = 10 and 11
figure
set(gcf,'position',[100,100,1250,400])
subplot(1,3,1)
plot(glider_DOresp_rate_umolkg_day{10},depth,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{11},depth,'.','Color',red)
legend(num2str(glider{10}.glidernum),num2str(glider{11}.glidernum),'Location','SW');
axis ij
ylabel('Pressure (db)')
title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
xlim([-0.6 0.02])
grid on

subplot(1,3,2)
plot(glider_regress_days{10},1:max(z),'.','Color',blue)
hold on
plot(glider_regress_days{11},1:max(z),'.','Color',red)
plot(glider_resp_length_days{10}(1:1000),1:1000,'.k')  
axis ij
ylabel('Pressure (db)')
title('Regression and Stratification Lengths (days)')
grid on

subplot(1,3,3)
plot(glider_DOresp_season_molm3{10}*-0.69,1:max(z),'.','Color',blue)
hold on
plot(glider_DOresp_season_molm3{11}*-0.69,1:max(z),'.','Color',red)
axis ij
ylabel('Pressure (db)')
title('Total Respired (mol C m^-^3)')
grid on
xlim([0 0.1])
sgtitle('Year 6: 2020-2021')

% Year 8 index = 12 and 13
figure
set(gcf,'position',[100,100,1250,400])
subplot(1,3,1)
plot(glider_DOresp_rate_umolkg_day{12},depth,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{13},depth,'.','Color',red)
legend(num2str(glider{12}.glidernum),num2str(glider{13}.glidernum),'Location','SW');
axis ij
ylabel('Pressure (db)')
title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
xlim([-0.6 0.02])
grid on

subplot(1,3,2)
plot(glider_regress_days{12},1:max(z),'.','Color',blue)
hold on
plot(glider_regress_days{13},1:max(z),'.','Color',red)
plot(glider_resp_length_days{12}(1:1000),1:1000,'.k')  
axis ij
ylabel('Pressure (db)')
title('Regression and Stratification Lengths (days)')
grid on

subplot(1,3,3)
plot(glider_DOresp_season_molm3{12}*-0.69,1:max(z),'.','Color',blue)
hold on
plot(glider_DOresp_season_molm3{13}*-0.69,1:max(z),'.','Color',red)
axis ij
ylabel('Pressure (db)')
title('Total Respired (mol C m^-^3)')
grid on
xlim([0 0.1])
sgtitle('Year 7: 2020-2021')
%%
depth = 1:1000;
close all
for j = 1:13%[2:4 6:11 13]
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

%% Looking at calibration issue with Glider Deployment Year 4 
run_this = 0;

if run_this == 1
    j = 4;
    mycolors = [maroon; red; yellow; green; forestgreen; navy; blue; purple; brightpurple];
    mc = 1; 
    for z1 = 100:100:900
    
        figure(2)
        subplot(2,1,1)
    %     plot(glider{j}.time_dt,glider{j}.doxy(z1,:),'.')
    %     hold on
        plot(glider{j}.time_dt,glider{j}.doxy_sm(z1,:),'Color',mycolors(mc,:),'Linewidth',2)
        hold on
        grid on
        ylabel('DO (\mumol kg^-^1)')
        title('Smoothed Glider Oxygen')
        
        subplot(2,1,2)
        plot(glider{j}.time_dt,z1,'.','Color',mycolors(mc,:))
        grid on
        hold on
        axis ij
        ylabel('Pressure (db)')
        title('Glider Depth')
        mc = mc+1;
    end 
    sgtitle('Glider Deployment Year 4: Oxygen on different isobars')
    
    % aug 10, 2017
    [~, wfp1] = min(abs(resp.time - datenum(2017,08,10)));
    [~, gld1] = min(abs(glider{4}.time - datenum(2017,08,10)));
    % aug 24, 2017
    [~, wfp2] = min(abs(resp.time - datenum(2017,08,24)));
    [~, gld2] = min(abs(glider{4}.time - datenum(2017,08,24)));
    % sept 7, 2017
    [~, wfp3] = min(abs(resp.time - datenum(2017,09,07)));
    [~, gld3] = min(abs(glider{4}.time - datenum(2017,09,07)));
    % sept 21, 2017
    [~, wfp4] = min(abs(resp.time - datenum(2017,09,21)));
    [~, gld4] = min(abs(glider{4}.time - datenum(2017,09,21)));
    % oct 04, 2017
    [~, wfp5] = min(abs(resp.time - datenum(2017,10,04)));
    [~, gld5] = min(abs(glider{4}.time - datenum(2017,10,04)));
    
    figure
    subplot(1,5,1)
    plot(resp.doxy(:,wfp1),wfp_prs,'k','Linewidth',2)
    hold on
    plot(glider{4}.doxy(:,gld1-1),glider_prs,'Linewidth',2)
    plot(glider{4}.doxy(:,gld1),glider_prs,'Linewidth',2)
    plot(glider{4}.doxy(:,gld1+1),glider_prs,'Linewidth',2)
    axis ij
    xlim([270 310]); grid on
    title(datestr(resp.time(wfp1)))
    
    subplot(1,5,2)
    plot(resp.doxy(:,wfp2),wfp_prs,'k','Linewidth',2)
    hold on
    plot(glider{4}.doxy(:,gld2-1),glider_prs,'Linewidth',2)
    plot(glider{4}.doxy(:,gld2),glider_prs,'Linewidth',2)
    plot(glider{4}.doxy(:,gld2+1),glider_prs,'Linewidth',2)
    axis ij
    xlim([270 310]); grid on
    title(datestr(resp.time(wfp2)))
    
    subplot(1,5,3)
    plot(resp.doxy(:,wfp3),wfp_prs,'k','Linewidth',2)
    hold on
    plot(glider{4}.doxy(:,gld3-1),glider_prs,'Linewidth',2)
    plot(glider{4}.doxy(:,gld3),glider_prs,'Linewidth',2)
    plot(glider{4}.doxy(:,gld3+1),glider_prs,'Linewidth',2)
    axis ij
    xlim([270 310]); grid on
    title(datestr(resp.time(wfp3)))
    
    subplot(1,5,4)
    plot(resp.doxy(:,wfp4),wfp_prs,'k','Linewidth',2)
    hold on
    plot(glider{4}.doxy(:,gld4-1),glider_prs,'Linewidth',2)
    plot(glider{4}.doxy(:,gld4),glider_prs,'Linewidth',2)
    plot(glider{4}.doxy(:,gld4+1),glider_prs,'Linewidth',2)
    axis ij
    xlim([270 310]); grid on
    title(datestr(resp.time(wfp4)))
    
    subplot(1,5,5)
    plot(resp.doxy(:,wfp5),wfp_prs,'k','Linewidth',2)
    hold on
    plot(glider{4}.doxy(:,gld5-1),glider_prs,'Linewidth',2)
    plot(glider{4}.doxy(:,gld5),glider_prs,'Linewidth',2)
    plot(glider{4}.doxy(:,gld5+1),glider_prs,'Linewidth',2)
    axis ij
    xlim([270 310]); grid on
    title(datestr(resp.time(wfp5)))
    sgtitle('Deployment Yr 4: WFP vs Glider Oxygen')
end
%%
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
save glider_resp_rates.mat glider*

