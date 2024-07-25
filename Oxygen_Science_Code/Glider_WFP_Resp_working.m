clearvars; close all
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load glider_resp_rates.mat
load wfp_respiration.mat
run('GeneralSettings.m')
z_glid = 1:1000;
close all
depth = 175:2000;
full_depth = 1:2000;

%%
% Year 1 index = 1, 2 and 3
figure
yr = 1;
subplot(2,4,yr)
% plot(glider_DOresp_rate_umolkg_day{1},z_glid,'.','Color',blue)
plot(glider_DOresp_rate_umolkg_day{2},z_glid,'.','Color',red)
hold on
plot(glider_DOresp_rate_umolkg_day{3},z_glid,'.','Color',yellow)
plot(wfp_DOresp_rate_umolkg_day{yr}(wfp_p_value{yr} < 0.05),full_depth(wfp_p_value{yr} < 0.05),'.k')
%     hold on
%     plot(DOresp_rate_umolkg_day_95CI_low{1}(depth),depth,'.') 
%     plot(DOresp_rate_umolkg_day_95CI_high{1}(depth),depth,'.') 
%     p = find(p_value{1} >= 0.05);
%     plot(DOresp_rate_umolkg_day{1}(p),p,'.k')
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
%     hold on
%     plot(DOresp_rate_umolkg_day_95CI_low{yr}(depth),depth,'.') 
%     plot(DOresp_rate_umolkg_day_95CI_high{yr}(depth),depth,'.') 
%     p = find(p_value{yr} >= 0.05);
%     plot(DOresp_rate_umolkg_day{yr}(p),p,'.k')
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on

% Year 3 ind 5 
yr = 3;
subplot(2,4,yr)
% plot(glider_DOresp_rate_umolkg_day{5},z_glid,'.','Color',blue)
% l = legend(num2str(glider{5}.glidernum),'Location','SW');
    plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.k')
%     hold on
%     plot(DOresp_rate_umolkg_day_95CI_low{yr}(depth),depth,'.') 
%     plot(DOresp_rate_umolkg_day_95CI_high{yr}(depth),depth,'.') 
%     p = find(p_value{yr} >= 0.05);
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
% legend(num2str(glider{6}.glidernum),num2str(glider{7}.glidernum),'Location','SW');

    plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.k')
%     hold on
%     plot(DOresp_rate_umolkg_day_95CI_low{yr}(depth),depth,'.') 
%     plot(DOresp_rate_umolkg_day_95CI_high{yr}(depth),depth,'.') 
%     p = find(p_value{yr} >= 0.05);
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
% plot(glider_DOresp_rate_umolkg_day{9},z_glid,'.','Color',red)
% l = legend(num2str(glider{8}.glidernum),num2str(glider{9}.glidernum),'Location','SW');
    plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.k')
%     hold on
%     plot(DOresp_rate_umolkg_day_95CI_low{yr}(depth),depth,'.') 
%     plot(DOresp_rate_umolkg_day_95CI_high{yr}(depth),depth,'.') 
%     p = find(p_value{yr} >= 0.05);
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on


% Year 6 index = 10 and 11
yr = 6;
subplot(2,4,yr)
plot(glider_DOresp_rate_umolkg_day{10},z_glid,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{11},z_glid,'.','Color',red)
% l = legend(num2str(glider{10}.glidernum),num2str(glider{11}.glidernum),'Location','SW');
    plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.k')
%     hold on
%     plot(DOresp_rate_umolkg_day_95CI_low{yr}(depth),depth,'.') 
%     plot(DOresp_rate_umolkg_day_95CI_high{yr}(depth),depth,'.') 
%     p = find(p_value{yr} >= 0.05);
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on


% Year 7 index = 12 and 13
yr = 7;
subplot(2,4,yr)
% plot(glider_DOresp_rate_umolkg_day{12},z_glid,'.','Color',blue)
plot(glider_DOresp_rate_umolkg_day{13},z_glid,'.','Color',red)
hold on
% l = legend(num2str(glider{12}.glidernum),num2str(glider{13}.glidernum),'Location','SW');
    plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.k')
%     hold on
%     plot(DOresp_rate_umolkg_day_95CI_low{yr}(depth),depth,'.') 
%     plot(DOresp_rate_umolkg_day_95CI_high{yr}(depth),depth,'.') 
%     p = find(p_value{yr} >= 0.05);
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on
sgtitle('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
%%
% Overwrite zero data with Nan for calculating mean/median at each depth

for j = [2 4 6 7 8 11]
    % Removes bad data at bottom of gliders
    glider_DOresp_rate_umolkg_day{j}(950:1000) = NaN;
    glider_DOresp_rate_umolkg_day_95CI_low{j}(950:1000) = NaN;
    glider_DOresp_rate_umolkg_day_95CI_high{j}(950:1000) = NaN;
end


for j = [3 10 13]
    % Removes zero placeholder data after 200 m
    glider_DOresp_rate_umolkg_day{j}(190:1000) = NaN;
    glider_DOresp_rate_umolkg_day_95CI_low{j}(190:1000) = NaN;
    glider_DOresp_rate_umolkg_day_95CI_high{j}(190:1000) = NaN;
end

% Removes placeholder data before ~200 m
wfp_top_depth = 175;
for j = 1:7
    wfp_DOresp_rate_umolkg_day{j}(1:wfp_top_depth) = NaN;
    wfp_DOresp_rate_umolkg_day_95CI_low{j}(1:wfp_top_depth) = NaN;
    wfp_DOresp_rate_umolkg_day_95CI_high{j}(1:wfp_top_depth) = NaN;
end 
%%
% Year 1 index = 1, 2 and 3
figure
yr = 1;
subplot(2,4,yr)
% plot(glider_DOresp_rate_umolkg_day{1},z_glid,'.','Color',blue)
plot(glider_DOresp_rate_umolkg_day{2},z_glid,'.','Color',red)
hold on
plot(glider_DOresp_rate_umolkg_day{3},z_glid,'.','Color',yellow)
plot(wfp_DOresp_rate_umolkg_day{yr}(wfp_p_value{yr} < 0.05),full_depth(wfp_p_value{yr} < 0.05),'.k')
%     hold on
%     plot(DOresp_rate_umolkg_day_95CI_low{1}(depth),depth,'.') 
%     plot(DOresp_rate_umolkg_day_95CI_high{1}(depth),depth,'.') 
%     p = find(p_value{1} >= 0.05);
%     plot(DOresp_rate_umolkg_day{1}(p),p,'.k')
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
%     hold on
%     plot(DOresp_rate_umolkg_day_95CI_low{yr}(depth),depth,'.') 
%     plot(DOresp_rate_umolkg_day_95CI_high{yr}(depth),depth,'.') 
%     p = find(p_value{yr} >= 0.05);
%     plot(DOresp_rate_umolkg_day{yr}(p),p,'.k')
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on

% Year 3 ind 5 
yr = 3;
subplot(2,4,yr)
% plot(glider_DOresp_rate_umolkg_day{5},z_glid,'.','Color',blue)
% l = legend(num2str(glider{5}.glidernum),'Location','SW');
    plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.k')
%     hold on
%     plot(DOresp_rate_umolkg_day_95CI_low{yr}(depth),depth,'.') 
%     plot(DOresp_rate_umolkg_day_95CI_high{yr}(depth),depth,'.') 
%     p = find(p_value{yr} >= 0.05);
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
% legend(num2str(glider{6}.glidernum),num2str(glider{7}.glidernum),'Location','SW');

    plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.k')
%     hold on
%     plot(DOresp_rate_umolkg_day_95CI_low{yr}(depth),depth,'.') 
%     plot(DOresp_rate_umolkg_day_95CI_high{yr}(depth),depth,'.') 
%     p = find(p_value{yr} >= 0.05);
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
% plot(glider_DOresp_rate_umolkg_day{9},z_glid,'.','Color',red)
% l = legend(num2str(glider{8}.glidernum),num2str(glider{9}.glidernum),'Location','SW');
    plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.k')
%     hold on
%     plot(DOresp_rate_umolkg_day_95CI_low{yr}(depth),depth,'.') 
%     plot(DOresp_rate_umolkg_day_95CI_high{yr}(depth),depth,'.') 
%     p = find(p_value{yr} >= 0.05);
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on


% Year 6 index = 10 and 11
yr = 6;
subplot(2,4,yr)
plot(glider_DOresp_rate_umolkg_day{10},z_glid,'.','Color',blue)
hold on
plot(glider_DOresp_rate_umolkg_day{11},z_glid,'.','Color',red)
% l = legend(num2str(glider{10}.glidernum),num2str(glider{11}.glidernum),'Location','SW');
    plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.k')
%     hold on
%     plot(DOresp_rate_umolkg_day_95CI_low{yr}(depth),depth,'.') 
%     plot(DOresp_rate_umolkg_day_95CI_high{yr}(depth),depth,'.') 
%     p = find(p_value{yr} >= 0.05);
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on


% Year 7 index = 12 and 13
yr = 7;
subplot(2,4,yr)
% plot(glider_DOresp_rate_umolkg_day{12},z_glid,'.','Color',blue)
plot(glider_DOresp_rate_umolkg_day{13},z_glid,'.','Color',red)
hold on
% l = legend(num2str(glider{12}.glidernum),num2str(glider{13}.glidernum),'Location','SW');
    plot(wfp_DOresp_rate_umolkg_day{yr}(depth),depth,'.k')
%     hold on
%     plot(DOresp_rate_umolkg_day_95CI_low{yr}(depth),depth,'.') 
%     plot(DOresp_rate_umolkg_day_95CI_high{yr}(depth),depth,'.') 
%     p = find(p_value{yr} >= 0.05);
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(yr)])
xlim([-0.6 0.02])
grid on
sgtitle('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
%%
% Year 1 
for j = 1:7
    slope_yr_by_depth{j} = NaN(2000,3);
    p_value_yr_by_depth{j} = NaN(2000,3);
    prho_yr_by_depth{j} = NaN(2000,3); 
end

for j = 1:7
    p_value_yr_by_depth{j}(:,3) = wfp_p_value{j};
    slope_yr_by_depth{j}(:,3) = wfp_DOresp_rate_umolkg_day{j};
    prho_yr_by_depth{j}(:,3) = wfp_Dprod_prho{j};
end

% Year 1, gliders 2 and 3 
slope_yr_by_depth{1}(1:1000,1) = glider_DOresp_rate_umolkg_day{2};
p_value_yr_by_depth{1}(1:1000,1) = glider_p_value{2};
prho_yr_by_depth{1}(1:1000,1) = glider_regress_prho{2};

slope_yr_by_depth{1}(1:1000,2) = glider_DOresp_rate_umolkg_day{3};
p_value_yr_by_depth{1}(1:1000,2) = glider_p_value{3};
prho_yr_by_depth{1}(1:1000,2) = glider_regress_prho{3};

% Year 2, glider 4 
slope_yr_by_depth{2}(1:1000,1) = glider_DOresp_rate_umolkg_day{4};
p_value_yr_by_depth{2}(1:1000,1) = glider_p_value{4};
prho_yr_by_depth{2}(1:1000,1) = glider_regress_prho{4};

% Year 4, gliders 6 and 7
slope_yr_by_depth{4}(1:1000,1) = glider_DOresp_rate_umolkg_day{6};
p_value_yr_by_depth{4}(1:1000,1) = glider_p_value{6};
prho_yr_by_depth{4}(1:1000,1) = glider_regress_prho{6};

slope_yr_by_depth{4}(1:1000,2) = glider_DOresp_rate_umolkg_day{7};
p_value_yr_by_depth{4}(1:1000,2) = glider_p_value{7};
prho_yr_by_depth{4}(1:1000,2) = glider_regress_prho{7};

% Year 5, glider 8 
slope_yr_by_depth{5}(1:1000,1) = glider_DOresp_rate_umolkg_day{8};
p_value_yr_by_depth{5}(1:1000,1) = glider_p_value{8};
prho_yr_by_depth{5}(1:1000,1) = glider_regress_prho{8};

% Year 6, gliders 10 and 11 
slope_yr_by_depth{6}(1:1000,1) = glider_DOresp_rate_umolkg_day{10};
p_value_yr_by_depth{6}(1:1000,1) = glider_p_value{10};
prho_yr_by_depth{6}(1:1000,1) = glider_regress_prho{10};

slope_yr_by_depth{6}(1:1000,2) = glider_DOresp_rate_umolkg_day{11};
p_value_yr_by_depth{6}(1:1000,2) = glider_p_value{11};
prho_yr_by_depth{6}(1:1000,2) = glider_regress_prho{11};

% Year 7, glider 13
slope_yr_by_depth{7}(1:1000,1) = glider_DOresp_rate_umolkg_day{13};
p_value_yr_by_depth{7}(1:1000,1) = glider_p_value{13};
prho_yr_by_depth{7}(1:1000,1) = glider_regress_prho{13};
%%
for j = 1:7
    temp_var = slope_yr_by_depth{j};
    temp_var(p_value_yr_by_depth{j} > 0.05) = NaN;
    temp_var(temp_var > 0) = NaN;
    sig_slope_yr_by_depth{j} = temp_var;
end
for j = 1:7
    sig_median_resp_by_depth{j} = median(sig_slope_yr_by_depth{j},2,'omitnan');
    sig_mean_resp_by_depth{j} = mean(sig_slope_yr_by_depth{j},2,'omitnan');
    mean_resp_by_depth{j} = mean(slope_yr_by_depth{j},2,'omitnan');
    std_resp_by_depth{j} = std(sig_slope_yr_by_depth{j},0,2,'omitnan');
    mean_prho_by_depth{j} = mean(prho_yr_by_depth{j},2,'omitnan');
end

%%
% Creating just one full profile for each year 
for j = 1:7
    slope_yr_by_depth{j} = NaN(2000,1);
    slope_yr_by_depth_95CI_high{j} = NaN(2000,1);
    slope_yr_by_depth_95CI_low{j} = NaN(2000,1);
    p_value_yr_by_depth{j} = NaN(2000,1);
    prho_yr_by_depth{j} = NaN(2000,1); 
end

for j = 1:7
    p_value_yr_by_depth{j}(190:2000) = wfp_p_value{j}(190:2000);
    slope_yr_by_depth{j}(190:2000) = wfp_DOresp_rate_umolkg_day{j}(190:2000);
    slope_yr_by_depth_95CI_high{j}(190:2000) = wfp_DOresp_rate_umolkg_day_95CI_high{j}(190:2000);
    slope_yr_by_depth_95CI_low{j}(190:2000) = wfp_DOresp_rate_umolkg_day_95CI_low{j}(190:2000);
    prho_yr_by_depth{j}(190:2000) = wfp_Dprod_prho{j}(190:2000);
end

% Year 1, glider 3 
slope_yr_by_depth{1}(1:189) = glider_DOresp_rate_umolkg_day{2}(1:189);
slope_yr_by_depth_95CI_high{1}(1:189) = glider_DOresp_rate_umolkg_day_95CI_high{2}(1:189);
slope_yr_by_depth_95CI_low{1}(1:189) = glider_DOresp_rate_umolkg_day_95CI_low{2}(1:189);
p_value_yr_by_depth{1}(1:189) = glider_p_value{2}(1:189);
prho_yr_by_depth{1}(1:189) = glider_regress_prho{2}(1:189);

% Year 2, glider 4 
slope_yr_by_depth{2}(1:189) = glider_DOresp_rate_umolkg_day{4}(1:189);
slope_yr_by_depth_95CI_high{2}(1:189) = glider_DOresp_rate_umolkg_day_95CI_high{4}(1:189);
slope_yr_by_depth_95CI_low{2}(1:189) = glider_DOresp_rate_umolkg_day_95CI_low{4}(1:189);
p_value_yr_by_depth{2}(1:189) = glider_p_value{4}(1:189);
prho_yr_by_depth{2}(1:189) = glider_regress_prho{4}(1:189);

% Year 4, glider 6
slope_yr_by_depth{4}(1:189) = glider_DOresp_rate_umolkg_day{6}(1:189);
slope_yr_by_depth_95CI_high{4}(1:189) = glider_DOresp_rate_umolkg_day_95CI_high{6}(1:189);
slope_yr_by_depth_95CI_low{4}(1:189) = glider_DOresp_rate_umolkg_day_95CI_low{6}(1:189);
p_value_yr_by_depth{4}(1:189) = glider_p_value{6}(1:189);
prho_yr_by_depth{4}(1:189) = glider_regress_prho{6}(1:189);

% Year 5, glider 8 
slope_yr_by_depth{5}(1:189) = glider_DOresp_rate_umolkg_day{8}(1:189);
slope_yr_by_depth_95CI_high{5}(1:189) = glider_DOresp_rate_umolkg_day_95CI_high{8}(1:189);
slope_yr_by_depth_95CI_low{5}(1:189) = glider_DOresp_rate_umolkg_day_95CI_low{8}(1:189);
p_value_yr_by_depth{5}(1:189) = glider_p_value{8}(1:189);
prho_yr_by_depth{5}(1:189) = glider_regress_prho{8}(1:189);

% Year 6, glider 11 
slope_yr_by_depth{6}(1:300) = glider_DOresp_rate_umolkg_day{11}(1:300);
slope_yr_by_depth_95CI_high{6}(1:300) = glider_DOresp_rate_umolkg_day_95CI_high{11}(1:300);
slope_yr_by_depth_95CI_low{6}(1:300) = glider_DOresp_rate_umolkg_day_95CI_low{11}(1:300);
p_value_yr_by_depth{6}(1:300) = glider_p_value{11}(1:300);
prho_yr_by_depth{6}(1:300) = glider_regress_prho{11}(1:300);

% Year 7, glider 13
slope_yr_by_depth{7}(1:189) = glider_DOresp_rate_umolkg_day{13}(1:189);
slope_yr_by_depth_95CI_high{7}(1:189) = glider_DOresp_rate_umolkg_day_95CI_high{13}(1:189);
slope_yr_by_depth_95CI_low{7}(1:189) = glider_DOresp_rate_umolkg_day_95CI_low{13}(1:189);
p_value_yr_by_depth{7}(1:189) = glider_p_value{13}(1:189);
prho_yr_by_depth{7}(1:189) = glider_regress_prho{13}(1:189);
%%
k = [2 4 5 6 8 10 13];
for j = 1:7
    regress_length_days{j} = glider_resp_length_days{k(j)};
end

%%
for j = 1:7
figure
plot(regress_length_days{j}(1:2000))
hold on
plot(wfp_regress_days{j})
axis ij
end
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

for j = 1:7

    p = find(p_value_yr_by_depth{j} >= 0.05 | slope_yr_by_depth{j} >= 0);
    p_95CI_high = find(p_value_yr_by_depth{j} >= 0.05 | slope_yr_by_depth_95CI_high{j} >= 0); 
    p_95CI_low = find(p_value_yr_by_depth{j} >= 0.05 | slope_yr_by_depth_95CI_high{j} >= 0);
%     DOresp_season_umolkg{j} = sig_median_resp_by_depth{j}.*regress_length_days{j}';
% %     DOresp_season_umolkg{j} = sig_median_resp_by_depth{j}*365.25;
%     DOresp_season_molm3{j} = (DOresp_season_umolkg{j}.*mean_prho_by_depth{j})/(1000*1000);
%     DOinventory_molm2(j) = min(cumsum(DOresp_season_molm3{j}(50:1500),'omitnan'));
    DOresp_season_umolkg{j} = slope_yr_by_depth{j}.*regress_length_days{j}';
    DOresp_season_umolkg_95CI_high{j} = slope_yr_by_depth_95CI_high{j}.*regress_length_days{j}';
    DOresp_season_umolkg_95CI_low{j} = slope_yr_by_depth_95CI_low{j}.*regress_length_days{j}';
    DOresp_season_umolkg{j}(p) = NaN;
    DOresp_season_umolkg_95CI_high{j}(p_95CI_high) = NaN;
    DOresp_season_umolkg_95CI_low{j}(p_95CI_low) = NaN;
     
    DOresp_season_molm3{j} = (DOresp_season_umolkg{j}.*prho_yr_by_depth{j})/(1000*1000);
    DOresp_season_molm3_95CI_high{j} = (DOresp_season_umolkg_95CI_high{j}.*prho_yr_by_depth{j})/(1000*1000);
    DOresp_season_molm3_95CI_low{j} = (DOresp_season_umolkg_95CI_low{j}.*prho_yr_by_depth{j})/(1000*1000);
    DOinventory_molm2(j) = min(cumsum(DOresp_season_molm3{j}(1000:1500),'omitnan'));
    DOinventory_molm2_95CI_high(j) = min(cumsum(DOresp_season_molm3_95CI_high{j}(1000:1500),'omitnan'));
    DOinventory_molm2_95CI_low(j) = min(cumsum(DOresp_season_molm3_95CI_low{j}(1000:1500),'omitnan'));
end
%%
for j = 1:7
figure(10)
set(gcf,'position',[100,100,500,400])
subplot(1,7,j)
p = find(p_value_yr_by_depth{j} < 0.05 & slope_yr_by_depth{j} <0);

plot(cumsum(DOresp_season_molm3{j}(50:1500),'omitnan'),(50:1500))
hold on
plot(cumsum(DOresp_season_molm3_95CI_low{j}(50:1500),'omitnan'),50:1500)
plot(cumsum(DOresp_season_molm3_95CI_high{j}(50:1500),'omitnan'),50:1500)
axis ij
ylabel('Pressure (db)')
xlabel('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
end
%%
for j = 1:7
figure(11)
subplot(2,4,j)
% plot(mean_resp_by_depth{j},1:2000,'.')
% hold on
% plot(sig_mean_resp_by_depth{j},1:2000,'.')
% plot(wfp_DOresp_rate_umolkg_day_95CI_high{j},1:2000,'.')
% plot(wfp_DOresp_rate_umolkg_day_95CI_low{j},1:2000,'.')
plot(slope_yr_by_depth{j},1:2000,'.')
hold on
plot(slope_yr_by_depth_95CI_high{j},1:2000,'.')
plot(slope_yr_by_depth_95CI_low{j},1:2000,'.')
% plot(mean_resp_by_depth{j}+std_resp_by_depth{j},1:2000,'c')
% plot(mean_resp_by_depth{j}-std_resp_by_depth{j},1:2000,'m')
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(j)])
xlim([-0.6 0.02])
grid on
sgtitle('Respiration Rate (\mumol DO kg^-^1 d^-^1)')

figure(12)
subplot(2,4,j)
plot(regress_length_days{j},1:2000,'Linewidth',2)
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(j)])
grid on
xlim([0 410])
sgtitle('Days below mixed layer')

figure(13)
subplot(2,4,j)
plot(DOresp_season_umolkg{j},1:2000,'.')
hold on
% plot(DOresp_season_umolkg_95CI_high{j},1:2000,'.')
% plot(DOresp_season_umolkg_95CI_low{j},1:2000,'.')
axis ij
ylabel('Pressure (db)')
title(['Yr ' num2str(j)])
grid on
sgtitle('DOresp_season_umolkg')

end

%%
% Create figure
figure1 = figure;
set(gcf,'position',[50,50,900,300])
% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');
Cinventory_molm2 = DOinventory_molm2*-0.69;
Cinventory_molm2_95CI_low = DOinventory_molm2_95CI_low*-0.69;
Cinventory_molm2_95CI_high = DOinventory_molm2_95CI_high*-0.69;
ax = gca;
b = bar(2:8,Cinventory_molm2);
b.FaceColor = green;
b.EdgeColor = 'k';
hold on
% errorbar(2:8,Cinventory_molm2,Cinventory_molm2_95CI_high - Cinventory_molm2,Cinventory_molm2_95CI_low - Cinventory_molm2,'ok')
errorbar(2:8,Cinventory_molm2,Cinventory_molm2 - Cinventory_molm2_95CI_low,Cinventory_molm2 - Cinventory_molm2_95CI_high,'ok')

b = bar(1,nanmean(Cinventory_molm2));
b.FaceColor = 'k';
b.EdgeColor = 'k';
ylabel('mol C m^-^2 yr^-^1')
ylabel('mol C m^-^2')
box(axes1,'on');
hold(axes1,'off');
set(axes1,'XTick',[1:8],...
    'XTickLabel',...
    {'Mean','2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022'});
title('Carbon respired below the mixed layer')
grid on
ax.FontSize = 13;