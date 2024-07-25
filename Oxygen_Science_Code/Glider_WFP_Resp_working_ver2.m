clearvars; close all
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load glider_resp_rates.mat
load wfp_respiration.mat
cd('G:\My Drive\Matlab_work\BC')
run('GeneralSettings.m')
addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))
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
yr = 6; glid_ind = 11;
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
    figure(3)
    set(gcf,'position',[50,50,1400,300])
    subplot(1,7,j)
    ax = gca;
    
end
% figure(3)
sgtitle('Seasonal export versus depth (mol C m^-^2)','Fontsize',14,'FontWeight','bold')

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

for j = 1:7
    figure(4)
    set(gcf,'position',[50,50,1400,300])
    subplot(1,7,j)
    ax = gca;
    b = barh(1:remin0_depth{j},C_cumsum{j});
    b.FaceColor = purple;
    b.EdgeColor = purple;
    axis ij
    ylim([0 1500])
    xlim([0 10])
    title([num2str(j+2014) ' - ' num2str(j+2015)],'Fontsize',15,'Fontweight','normal')
    if j == 1
        ylabel('Pressure (db)')
    end
    hold on
    if remin0_depth{j} > max_winter_mld(j+1)
        b = barh(max_winter_mld(j+1):remin0_depth{j},C_cumsum{j}(max_winter_mld(j+1):remin0_depth{j}));
    b.FaceColor = rgb('gray');
    b.EdgeColor = rgb('gray');
    end
    plot(0:10,ones(length(0:10),1)*max_winter_mld(j+1),'k--') % Subsequent winter mixing 
    grid on
    ax.FontSize = 15;
    ax.XAxisLocation = 'top';
end
% figure(3)
sgtitle('Total respired carbon versus depth (mol C m^-^2 yr^-^1)','Fontsize',18,'FontWeight','bold')
%%

for yr = 1:7
    figure(11)
    subplot(3,7,yr)
    plot(DOresp_rate_umolkg_day{yr}(glid_top:wfp_bottom),(glid_top:wfp_bottom),'.','Color','none')
    hold on
    if yr ~= 3
        boundedline(DOresp_rate_umolkg_day{yr}(glid_top:wfp_bottom),(glid_top:wfp_bottom),...
            DOresp_rate_umolkg_day_95CI_high{yr}(glid_top:wfp_bottom) -DOresp_rate_umolkg_day{yr}(glid_top:wfp_bottom),'k','orientation','horiz','alpha')
    end
    if yr == 3
        boundedline(DOresp_rate_umolkg_day{yr}(200:wfp_bottom),(200:wfp_bottom),...
            DOresp_rate_umolkg_day_95CI_high{yr}(200:wfp_bottom) -DOresp_rate_umolkg_day{yr}(200:wfp_bottom),'k','orientation','horiz','alpha')   
    end
    axis ij
    ylabel('Pressure (db)')
    xlim([-0.6 0])
    grid on
    legend(['Yr ' num2str(yr)],'Location','SW','Box','off')
    title({'Respiration Rate' ...
    '(\mumol DO kg^-^1 d^-^1)'})
    
    subplot(3,7,yr+7)
    plot(regress_length_days{yr},1:2000,'.','Color','none')
    hold on
    plot(regress_length_days{yr},1:2000,'k','Linewidth',1.5)
    axis ij
    ylabel('Pressure (db)')
    grid on
    xlim([0 410])
    title('Days below ML')
    legend(['Yr ' num2str(yr)],'Location','SW','Box','off')
    
    subplot(3,7,yr+14)
    plot(DOresp_season_umolkg{yr}(glid_top:wfp_bottom),(glid_top:wfp_bottom),'.','Color','none')
    hold on
    if yr ~=3
        boundedline(DOresp_season_umolkg{yr}(glid_top:wfp_bottom),(glid_top:wfp_bottom),...
            DOresp_season_umolkg_95CI_high{yr}(glid_top:wfp_bottom) - DOresp_season_umolkg{yr}(glid_top:wfp_bottom),'k','orientation','horiz','alpha')
    end
    if yr == 3
        boundedline(DOresp_season_umolkg{yr}(200:wfp_bottom),(200:wfp_bottom),...
            DOresp_season_umolkg_95CI_high{yr}(200:wfp_bottom) - DOresp_season_umolkg{yr}(200:wfp_bottom),'k','orientation','horiz','alpha')
    end    
    axis ij
    ylabel('Pressure (db)')
    legend(['Yr ' num2str(yr)],'Location','SW','Box','off')
    xlim([-45 0]); grid on
    title({'Oxygen Respired' ...
    '(\mumol DO kg^-^1)'})

end

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
b.FaceColor = green;
% errorbar(2:8,Cinventory_molm2,Cinventory_molm2_95CI_high - Cinventory_molm2,Cinventory_molm2_95CI_low - Cinventory_molm2,'ok')
er = errorbar(x,Cinventory_molm2,Cinventory_molm2 - Cinventory_molm2_95CI_low,Cinventory_molm2 - Cinventory_molm2_95CI_high);
er.Color = [ 0 0 0];
er.LineStyle = 'none';

b2 = bar(1,nanmean(Cinventory_molm2));
b2.FaceColor = green;
% er = errorbar(1,nanmean(Cinventory_molm2),nanstd(Cinventory_molm2),nanstd(Cinventory_molm2));
% er.Color = [ 0 0 0];
er.LineStyle = 'none';
ylabel('mol C m^-^2 yr^-^1')
box(axes1,'on');
hold(axes1,'off');
set(axes1,'XTick',[1:8],...
    'XTickLabel',...
    {'Mean','2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022'});
title('Seasonal Export')
axes1.FontSize = 13;
grid on

%%
% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');
Cinventory_molm2 = [ DOinventory_molm2_top_100m*-0.69; DOinventory_molm2_100m_500m*-0.69; DOinventory_molm2_500m_1000m*-0.69; DOinventory_molm2_over_1000m*-0.69; DOinventory_molm2_over_max_winter*-0.69]; % DOinventory_molm2*-0.69]; 
Cinventory_molm2_95CI_low = [ DOinventory_molm2_95CI_low_top_100m*-0.69; DOinventory_molm2_95CI_low_100m_500m*-0.69; DOinventory_molm2_95CI_low_500m_1000m*-0.69; DOinventory_molm2_95CI_low_over_1000m*-0.69; DOinventory_molm2_95CI_low_over_max_winter*-0.69];
Cinventory_molm2_95CI_high = [ DOinventory_molm2_95CI_high_top_100m*-0.69; DOinventory_molm2_95CI_high_100m_500m*-0.69; DOinventory_molm2_95CI_high_500m_1000m*-0.69; DOinventory_molm2_95CI_high_over_1000m*-0.69; DOinventory_molm2_95CI_high_over_max_winter*-0.69];

bar(1:7,Cinventory_molm2,'grouped')
hold on
% errorbar(2:8,Cinventory_molm2,Cinventory_molm2_95CI_high - Cinventory_molm2,Cinventory_molm2_95CI_low - Cinventory_molm2,'ok')
% er = errorbar(1:7,Cinventory_molm2,Cinventory_molm2 - Cinventory_molm2_95CI_low,Cinventory_molm2 - Cinventory_molm2_95CI_high);
legend('1-100m','100-500m','500-1000m','> 1000m','> max winter ventilation','Location','southoutside','orientation','horizontal');

ylabel('mol C m^-^2 yr^-^1')
box(axes1,'on');
hold(axes1,'off');
set(axes1,'XTick',[1:7],...
    'XTickLabel',...
    {'2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022'});
title('Seasonal export')
grid on
%%
% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');
Cinventory_molm2 = [ DOinventory_molm2_top_100m*-0.69; DOinventory_molm2_100m_500m*-0.69; DOinventory_molm2_500m_1000m*-0.69; DOinventory_molm2_over_1000m*-0.69]; 
% Cinventory_molm2_95CI_high = [ DOinventory_molm2_95CI_high_top_100m*-0.69; DOinventory_molm2_95CI_high_100m_500m*-0.69; DOinventory_molm2_95CI_high_500m_1000m*-0.69; DOinventory_molm2_95CI_high_over_1000m*-0.69; DOinventory_molm2_95CI_high_over_max_winter*-0.69];

bar(1:7,Cinventory_molm2,'stacked')
hold on
% errorbar(2:8,Cinventory_molm2,Cinventory_molm2_95CI_high - Cinventory_molm2,Cinventory_molm2_95CI_low - Cinventory_molm2,'ok')
% errorbar(1:7,Cinventory_molm2,Cinventory_molm2 - Cinventory_molm2_95CI_low,Cinventory_molm2 - Cinventory_molm2_95CI_high,'ok')
legend('1-100m','100-500m','500-1000m','> 1000m','Location','southoutside','orientation','horizontal');

ylabel('ANCP mol C m^-^2 yr^-^1')
box(axes1,'on');
hold(axes1,'off');
set(axes1,'XTick',[1:7],...
    'XTickLabel',...
    {'2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022'});
title('ANCP')
grid on

%%
% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');
Cinventory_molm2 = [ DOinventory_molm2*-0.69; DOinventory_molm2_below_max_winter*-0.69; DOinventory_molm2_over_max_winter*-0.69]; 
Cinventory_molm2_95CI_low = [ DOinventory_molm2_95CI_low*-0.69; DOinventory_molm2_below_max_winter*-0.69; DOinventory_molm2_95CI_low_over_max_winter*-0.69];
Cinventory_molm2_95CI_high = [ DOinventory_molm2_95CI_high*-0.69; DOinventory_molm2_below_max_winter*-0.69;  DOinventory_molm2_95CI_high_over_max_winter*-0.69];

bar(Cinventory_molm2,'grouped')
hold on
%errorbar(Cinventory_molm2,Cinventory_molm2_95CI_high - Cinventory_molm2,Cinventory_molm2_95CI_low - Cinventory_molm2,'ok')
% errorbar(Cinventory_molm2,Cinventory_molm2 - Cinventory_molm2_95CI_low,Cinventory_molm2 - Cinventory_molm2_95CI_high,'ok')
legend('seasonal export','re-enters mixed layer','biologically sequestered','Location','southoutside','orientation','horizontal');

ylabel('mol C m^-^2 yr^-^1')
box(axes1,'on');
hold(axes1,'off');
set(axes1,'XTick',[1:7],...
    'XTickLabel',...
    {'2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022'});
title('Seasonal respiration below the mixed layer')
grid on
%%
% Create figure
figure1 = figure;
ax = gca;
% % Create axes
% axes1 = axes('Parent',figure1);
% hold(axes1,'on');
% % Cinventory_molm2 = [ DOinventory_molm2*-0.69; DOinventory_molm2_below_max_winter*-0.69; DOinventory_molm2_over_max_winter*-0.69]; 
% % Cinventory_molm2_95CI_low = [ DOinventory_molm2_95CI_low*-0.69; DOinventory_molm2_below_max_winter*-0.69; DOinventory_molm2_95CI_low_over_max_winter*-0.69];
% % Cinventory_molm2_95CI_high = [ DOinventory_molm2_95CI_high*-0.69; DOinventory_molm2_below_max_winter*-0.69;  DOinventory_molm2_95CI_high_over_max_winter*-0.69];
x1 = 1:4:28;
x2 = 2:4:28;
x3 = 3:4:28;

b = bar(x1,DOinventory_molm2*-0.69);
b.FaceColor = green;
b.BarWidth = 0.2;
hold on
b = bar(x2,DOinventory_molm2_below_max_winter*-0.69);
b.FaceColor = purple;
b.BarWidth = 0.2;
b = bar(x3,DOinventory_molm2_over_max_winter*-0.69);
b.FaceColor = rgb('gray');
b.BarWidth = 0.2;
er = errorbar(x1,DOinventory_molm2*-0.69,DOinventory_molm2*-0.69 - DOinventory_molm2_95CI_low*-0.69,DOinventory_molm2*-0.69 - DOinventory_molm2_95CI_low*-0.69);
er.Color = [ 0 0 0];
er.LineStyle = 'none';
er = errorbar(x2,DOinventory_molm2_below_max_winter*-0.69,DOinventory_molm2_below_max_winter*-0.69 - DOinventory_molm2_95CI_low_below_max_winter*-0.69,DOinventory_molm2_below_max_winter*-0.69 - DOinventory_molm2_95CI_low_below_max_winter*-0.69);
er.Color = [ 0 0 0];
er.LineStyle = 'none';
er = errorbar(x3,DOinventory_molm2_over_max_winter*-0.69,DOinventory_molm2_over_max_winter*-0.69 - DOinventory_molm2_95CI_low_over_max_winter*-0.69,DOinventory_molm2_over_max_winter*-0.69 - DOinventory_molm2_95CI_low_over_max_winter*-0.69);
er.Color = [ 0 0 0]
er.LineStyle = 'none';

b2 = bar(-3,nanmean(DOinventory_molm2*-0.69));
b2.FaceColor = green;
% er = errorbar(-3,nanmean(Cinventory_molm2),nanstd(Cinventory_molm2),nanstd(Cinventory_molm2));
% er.Color = [ 0 0 0];
% er.LineStyle = 'none';

b2 = bar(-2,nanmean(DOinventory_molm2_below_max_winter*-0.69));
b2.FaceColor = purple;

b3 = bar(-1,0.81); % Need to remove the nans and add zeros for average. 
b3.FaceColor = rgb('gray')
legend('seasonal export','re-enters mixed layer','sequestered below max MLD_w_i_n_t_e_r','Location','southoutside','orientation','horizontal');

ylabel('mol C m^-^2 yr^-^1')
% box(axes1,'on');
% hold(axes1,'off');
set(ax,'XTick',[-2 x2],...
    'XTickLabel',...
    {'Mean','2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022'});
% title('Seasonal respiration below the mixed layer')
grid on
ax.FontSize = 15;
%%
seasonal_export_mean = nanmean(DOinventory_molm2*-0.69)
nanstd(DOinventory_molm2*-0.69)
reenters_ML = nanmean(DOinventory_molm2_below_max_winter*-0.69)
nanstd(DOinventory_molm2_below_max_winter*-0.69)
below_winter_ML = nansum(DOinventory_molm2_over_max_winter*-0.69)/length(DOinventory_molm2_over_max_winter)
std([0 -0.0212 0 -4.1434 0 -0.5021-3.5797]*-0.69) % What does this even mean? 
reenters_ML_percent = DOinventory_molm2_below_max_winter./DOinventory_molm2
%% % export sensitivity to regression lengths 

DOresp_season_umolkg_combos = [];
DOresp_season_molm3_combos = [];
DOinventory_molm2_combos = [];
Cinventory_molm2_combos = [];
for j = 1:7
    for k = 1:7
        inv_top = 50;
        inv_bottom = remin0_depth{j};
        depth_interest{j} = inv_top:inv_bottom;

        DOresp_season_umolkg_combos{j}{k} = DOresp_rate_umolkg_day{j}.*regress_length_days{k};    
        DOresp_season_molm3_combos{j}{k} = (DOresp_season_umolkg_combos{j}{k}.*prho{j})/(1000*1000);
        DOinventory_molm2_combos{j}{k} = min(cumsum(DOresp_season_molm3_combos{j}{k}(depth_interest{j}),'omitnan'));
        Cinventory_molm2_combos{j}(k) = DOinventory_molm2_combos{j}{k}*-0.69;
    end
end

% close all
% for j = 1:7
%     for k = 1:7
%         figure(1)
%         plot(k,Cinventory_molm2_combos{j}(k),'o','color',mycolors(j,:))
%         hold on
%     end
% end

for j = 1:7
        inv_top = 50;
        inv_bottom = remin0_depth{j};
        depth_interest{j} = inv_top:inv_bottom;

        DOresp_season_umolkg_year{j} = DOresp_rate_umolkg_day{j}.*365.25;    
        DOresp_season_molm3_year{j} = (DOresp_season_umolkg_year{j}.*prho{j})/(1000*1000);
        DOinventory_molm2_year{j} = min(cumsum(DOresp_season_molm3_year{j}(depth_interest{j}),'omitnan'));
        Cinventory_molm2_year(j) = DOinventory_molm2_year{j}*-0.69;
end
%%
    Cinventory_molm2_mean_combos= [];
    Cinventory_molm2_min_combos= [];
    Cinventory_molm2_max_combos = [];
for j = 1:7
    Cinventory_molm2_mean_combos(j) = mean(Cinventory_molm2_combos{j});
    Cinventory_molm2_min_combos(j) = min(Cinventory_molm2_combos{j});
    Cinventory_molm2_max_combos(j) = max(Cinventory_molm2_combos{j});

end

groupC = [DOinventory_molm2*-0.69; Cinventory_molm2_mean_combos; Cinventory_molm2_min_combos; Cinventory_molm2_max_combos; Cinventory_molm2_year ];
    figure(2)
    ax = gca;
    bar(1:7,groupC,'grouped');
%     ylim([0 12])
set(ax,'XTick',[1:7],...
    'XTickLabel',...
    {'2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022'});
ylabel('Seasonal export (mol C m^2)')
legend('with actual D-ML(z)','Mean of 7','Min of 7','Max of 7','Year','Location','southoutside','Orientation','horizontal')
grid on
title('Export Sensitivity to D_b_e_l_o_w _M_L(z)')
