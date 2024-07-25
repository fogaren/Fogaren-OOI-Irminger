clearvars; close all
cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\AR69-03')
% load AR6903_DO_caldeep.mat
load('AR6903_Processed_KF_notfinal.mat')
load('AR6903_Processed_Wink1_cal_KF.mat')
run('GeneralSettings.m')
%%
figure
plot(btlsum_tbl_AR6903.Date(btlsum_tbl_AR6903.Cast >= 173),btlsum_tbl_AR6903.Winkler1_umolkg(btlsum_tbl_AR6903.Cast >= 173)-btlsum_tbl_AR6903.CTDOXY_umolkg(btlsum_tbl_AR6903.Cast >= 173),'ok','MarkerFaceColor',blue)
hold on
plot(btlsum_tbl_AR6903.Date(btlsum_tbl_AR6903.Cast >= 173),btlsum_tbl_AR6903.Winkler2_umolkg(btlsum_tbl_AR6903.Cast >= 173)-btlsum_tbl_AR6903.CTDOXY_umolkg(btlsum_tbl_AR6903.Cast >= 173),'ok','MarkerFaceColor',blue)
plot(btlsum_tbl_Wink1.Date(btlsum_tbl_Wink1.Cast >= 173),btlsum_tbl_Wink1.Winkler1_umolkg(btlsum_tbl_Wink1.Cast >= 173)-btlsum_tbl_Wink1.CTDOXY_umolkg(btlsum_tbl_Wink1.Cast >= 173),'ok','MarkerFaceColor',red)


%%

downcasts1 = downcasts_AR6903; upcasts1 = upcasts_AR6903;
% downcasts2 = downcasts_deep; upcasts2 = upcasts_deep;
downcasts2 = downcasts_Wink1; upcasts2 = upcasts_Wink1;


blue = [0     0.44706     0.74118];
grey = [0.5 0.5 0.5];
cast_num = cast_num_AR6903;


downcast_diff = []; 
upcast_diff = [];

for i = 1:length(cast_num)
    downcast_diff(i) = mean(((downcasts1{cast_num(i)}.DOcorr_umolkg) - (downcasts2{cast_num(i)}.DOcorr_umolkg)));
    upcast_diff(i) = mean(((upcasts1{cast_num(i)}.DOcorr_umolkg) - (upcasts2{cast_num(i)}.DOcorr_umolkg)));
end

z = 1000;
downcast_diff_z = []; 
upcast_diff_z = [];
for i = 1:length(cast_num)
    if max(downcasts1{cast_num(i)}.prs)> z
        z_ind = find(downcasts1{cast_num(i)}.prs == z);
        downcast_diff_z(i) = downcasts1{cast_num(i)}.DOcorr_umolkg(z_ind) - downcasts2{cast_num(i)}.DOcorr_umolkg(z_ind);
        upcast_diff_z(i) = upcasts1{cast_num(i)}.DOcorr_umolkg(z_ind) - upcasts2{cast_num(i)}.DOcorr_umolkg(z_ind);
    else 
        downcast_diff_z(i) = NaN;
        upcast_diff_z(i) = NaN;
    end
end

figure
plot(cast_num,downcast_diff,'ok','MarkerFaceColor',blue)
hold on
plot(cast_num,downcast_diff_z,'ok','MarkerFaceColor',red)
grid on
ylabel('Mean Cal1 - Cal2 (\mumol/kg)')
xlabel('Cast Number')
legend('Mean Cast Diff','Difference at 1000 m ','Location','NE')
%%
plot_compare_calibrations(downcasts_AR6903,upcasts_AR6903,downcasts_Wink1,upcasts_Wink1,cast_num(173:end),'Group 7')

function plot_compare_calibrations(downcasts1,upcasts1,downcasts2,upcasts2,cast_num,TitleString)
% For plotting purposes 
blue = [0     0.44706     0.74118];
grey = [0.5 0.5 0.5];



% f = figure;
% f.Position = [100 100 840 500];
% subplot(1,2,1)
% for i = 1:length(cast_num)    
%     plot(downcasts1{cast_num(i)}.DOcorr_umolkg(downcasts1{cast_num(i)}.ctdoxy_flag == 2),downcasts1{cast_num(i)}.pt(downcasts1{cast_num(i)}.ctdoxy_flag == 2),'Linewidth',1,'Color',grey)
%     hold on
% end
% 
% for i = 1:length(cast_num)    
%     plot(downcasts2{cast_num(i)}.DOcorr_umolkg(downcasts2{cast_num(i)}.ctdoxy_flag == 2),downcasts2{cast_num(i)}.pt(downcasts2{cast_num(i)}.ctdoxy_flag == 2),'Linewidth',1,'Color',blue)
% end
% ylabel('PT (\circC)')
% xlabel('DO (\mumol kg^-^1)')
% title('Downcasts')
% grid on
% 
% subplot(1,2,2)
% for i = 1:length(cast_num)    
%     plot(upcasts1{cast_num(i)}.DOcorr_umolkg(upcasts1{cast_num(i)}.ctdoxy_flag == 2),upcasts1{cast_num(i)}.pt(upcasts1{cast_num(i)}.ctdoxy_flag == 2),'Linewidth',1,'Color',grey)
%     hold on
% end
% 
% for i = 1:length(cast_num)    
%     plot(upcasts2{cast_num(i)}.DOcorr_umolkg(upcasts2{cast_num(i)}.ctdoxy_flag == 2),upcasts2{cast_num(i)}.pt(upcasts2{cast_num(i)}.ctdoxy_flag == 2),'Linewidth',1,'Color',blue)
% end
% ylabel('PT (\circC)')
% xlabel('DO (\mumol kg^-^1)')
% title('Upcasts')
% grid on
% sgtitle(TitleString)
% legend('Cal1','Cal2','Location','NW')
% 
% for i = 1:length(cast_num)
%     figure
%     subplot(1,2,1)
%     plot(downcasts1{cast_num(i)}.DOcorr_umolkg(downcasts1{cast_num(i)}.ctdoxy_flag == 2),downcasts1{cast_num(i)}.prs(downcasts1{cast_num(i)}.ctdoxy_flag == 2),'Linewidth',2,'Color',grey)
%     hold on
%     plot(downcasts2{cast_num(i)}.DOcorr_umolkg(downcasts2{cast_num(i)}.ctdoxy_flag == 2),downcasts2{cast_num(i)}.prs(downcasts2{cast_num(i)}.ctdoxy_flag == 2),'Linewidth',2,'Color',blue)
%     axis ij
%     ylabel('prs (db)')
%     xlabel('DO (\mumol kg^-^1)')
%     title('Downcasts')
%     grid on
% 
%     subplot(1,2,2)
%     plot(upcasts1{cast_num(i)}.DOcorr_umolkg(upcasts1{cast_num(i)}.ctdoxy_flag == 2),upcasts1{cast_num(i)}.prs(upcasts1{cast_num(i)}.ctdoxy_flag == 2),'Linewidth',2,'Color',grey)
%     hold on
%     plot(upcasts2{cast_num(i)}.DOcorr_umolkg(upcasts2{cast_num(i)}.ctdoxy_flag == 2),upcasts2{cast_num(i)}.prs(upcasts2{cast_num(i)}.ctdoxy_flag == 2),'Linewidth',2,'Color',blue)
%     axis ij
%     ylabel('prs (db)')
%     xlabel('DO (\mumol kg^-^1)')
%     title('Upcasts')
%     grid on
%     sgtitle(['Cast: ' num2str(cast_num(i))])
% end

f = figure;
f.Position = [100 100 840 500];
subplot(1,2,1)
for i = 1:length(cast_num)    
    plot(downcasts1{cast_num(i)}.DOcorr_umolkg,downcasts1{cast_num(i)}.pt,'Linewidth',1,'Color',grey)
    hold on
end

for i = 1:length(cast_num)    
    plot(downcasts2{cast_num(i)}.DOcorr_umolkg,downcasts2{cast_num(i)}.pt,'Linewidth',1,'Color',blue)
end
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Downcasts')
grid on

subplot(1,2,2)
for i = 1:length(cast_num)    
    plot(upcasts1{cast_num(i)}.DOcorr_umolkg,upcasts1{cast_num(i)}.pt,'Linewidth',1,'Color',grey)
    hold on
end

for i = 1:length(cast_num)    
    plot(upcasts2{cast_num(i)}.DOcorr_umolkg,upcasts2{cast_num(i)}.pt,'Linewidth',1,'Color',blue)
end
ylabel('PT (\circC)')
xlabel('DO (\mumol kg^-^1)')
title('Upcasts')
grid on
sgtitle(TitleString)
legend('Cal1','Cal2','Location','NW')

for i = 1:length(cast_num)
    figure
    subplot(1,2,1)
    plot(downcasts1{cast_num(i)}.DOcorr_umolkg,downcasts1{cast_num(i)}.prs,'Linewidth',2,'Color',grey)
    hold on
    plot(downcasts2{cast_num(i)}.DOcorr_umolkg,downcasts2{cast_num(i)}.prs,'Linewidth',2,'Color',blue)
    axis ij
    ylabel('prs (db)')
    xlabel('DO (\mumol kg^-^1)')
    title('Downcasts')
    grid on

    subplot(1,2,2)
    plot(upcasts1{cast_num(i)}.DOcorr_umolkg,upcasts1{cast_num(i)}.prs,'Linewidth',2,'Color',grey)
    hold on
    plot(upcasts2{cast_num(i)}.DOcorr_umolkg,upcasts2{cast_num(i)}.prs,'Linewidth',2,'Color',blue)
    axis ij
    ylabel('prs (db)')
    xlabel('DO (\mumol kg^-^1)')
    title('Upcasts')
    grid on
    sgtitle(['Cast: ' num2str(cast_num(i))])
end
end