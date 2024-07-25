%% Load workspace 
clearvars; close all
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Sept2023')
load('wfpmerge_output.mat')  
wggmerge1 = wggmerge; clear wggmerge wggmerge_fl

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Jan2024')
load('wfpmerge_output.mat')
wggmerge2 = wggmerge; clear wggmerge wggmerge_fl

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('wfpmerge_output_fixedPc1600db.mat') % Run 3
wggmerge3 = wggmerge; clear wggmerge wggmerge_fl

load('wfpmerge_output_variablePc1600db.mat') % Run 4 
wggmerge4 = wggmerge; clear wggmerge wggmerge_fl

wfp_prs = 150:1:2600; % Depths of Hilary's product
%%
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load Dproduction2.mat
%%
z = [250 500 750 1000];
for j = 1:length(z)
    z_ind = find(wfp_prs == z(j));

    figure
%     set(gcf,'position',[50,50,800,200])
    for dy = 1:max(unique(wggmerge3.deploy_yr))-1
        subplot(4,2,dy)
        ax = gca;
        plot(wggmerge3.time(wggmerge3.deploy_yr == dy),wggmerge3.doxy(z_ind,wggmerge3.deploy_yr == dy),'.','MarkerSize',20)
        hold on
        plot(wggmerge3.time(wggmerge3.deploy_yr == dy+1),wggmerge3.doxy(z_ind,wggmerge3.deploy_yr == dy+1),'.','MarkerSize',20)
        grid on; 
        datetick('x','mm/yy','keepticks')
        title(['Deployment ' num2str(dy) ' to ' num2str(dy+1) ': ' num2str(z(j)) ' db'])
        ax.FontSize = 14;
    end
end

%%
figure
subplot(4,1,1)
z = 250;
z_ind = find(wfp_prs == z);
for dy = 1:max(unique(wggmerge3.deploy_yr))
    plot(wggmerge3.time(wggmerge3.deploy_yr == dy),wggmerge3.doxy(z_ind,wggmerge3.deploy_yr == dy),'.')
    hold on
end
grid on; datetick
title([num2str(z) ' db'])

subplot(4,1,2)
z = 500;
z_ind = find(wfp_prs == z);
for dy = 1:max(unique(wggmerge3.deploy_yr))
    plot(wggmerge3.time(wggmerge3.deploy_yr == dy),wggmerge3.doxy(z_ind,wggmerge3.deploy_yr == dy),'.')
    hold on
end
grid on; datetick
title([num2str(z) ' db'])

subplot(4,1,3)
z = 750;
z_ind = find(wfp_prs == z);
for dy = 1:max(unique(wggmerge3.deploy_yr))
    plot(wggmerge3.time(wggmerge3.deploy_yr == dy),wggmerge3.doxy(z_ind,wggmerge3.deploy_yr == dy),'.')
    hold on
end
grid on; datetick
title([num2str(z) ' db'])

subplot(4,1,4)
z = 1000;
z_ind = find(wfp_prs == z);
for dy = 1:max(unique(wggmerge3.deploy_yr))
    plot(wggmerge3.time(wggmerge3.deploy_yr == dy),wggmerge3.doxy(z_ind,wggmerge3.deploy_yr == dy),'.')
    hold on
end
grid on; datetick
title([num2str(z) ' db'])