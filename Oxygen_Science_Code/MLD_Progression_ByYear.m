%% Load Kristen's MLD calculated from WFP chl data
cd('G:\Shared drives\NSF_Irminger\Data_Files\From Meg')
load blended_mld.mat
blended_mld_all.dn = datenum(blended_mld_all.time); % Converts to datenum 

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load wfp_chl_KF_Sep2023.mat
wfp_chl.dt = datetime(wfp_chl.dn,'ConvertFrom','datenum'); %datetime of just observations
wfp_chl.time_dt = datetime(wfp_chl.time,'ConvertFrom','datenum'); % datetime evenly spaced with NaNs


%%
yr = unique(year(wfp_chl.dn)); % Years of deployments; 

% Finds all the points in a 8/15 to 8/15 year
dn_yr = []; 
dn_yr_blended = []; 
for i = 1:length(yr)-1
    dn_yr{i} = find((wfp_chl.time > datenum(yr(i),08,15)) & (wfp_chl.time < datenum(yr(i+1),08,15)));
    dn_yr_blended{i} = find((blended_mld_all.dn > datenum(yr(i),08,15)) & (blended_mld_all.dn < datenum(yr(i+1),08,15))); 
end

for i = 1:length(yr)-1
    figure(1)
    subplot(8,1,i)
    plot(wfp_chl.time(dn_yr{i})-datenum(yr(i),08,15),wfp_chl.mld_db_time(dn_yr{i}),'.k')
    hold on
    plot(blended_mld_all.dn(dn_yr_blended{i})-datenum(yr(i),08,15),blended_mld_all.mld(dn_yr_blended{i}),'Linewidth',1.4)
    grid on
    axis ij
    ylim([200 1500])
    xlim([100 350])
    ylabel('MLD (db)')
    legend(num2str(yr(i)),'Location','SE')
end
xlabel('Days since August 15')
sgtitle('Mixed Layer Progression by Year')
% legend('14-15','15-16','16-17','17-18','18-19','19-20','20-21','21-22')


