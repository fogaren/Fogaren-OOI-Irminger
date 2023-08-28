clearvars
% Write processed files to csv for BCO-DMO
cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\Year5')
load Year5_Processed_KF.mat
bco_dmo = 'G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\BCO-DMO Submission\AR30-03';

cast_num = cast_num_yr5;
btl_num = btl_num_yr5;
downcasts = downcasts_yr5;
upcasts = upcasts_yr5;
btlsum = btlsum_yr5; 
%% Commented out so that files aren't accidently overwritten.
 % Certain files have had flags manually changed in excel. 
% cd(bco_dmo)
% for i = 1:length(cast_num)
%     dwn_out = downcasts{cast_num(i)};
%     
%     temp_flag = ones(size(dwn_out.t))*2;
%     sal_flag = ones(size(dwn_out.t))*2;
%     oxycur_flag = ones(size(dwn_out.t))*2;
%     ctdoxy_flag = ones(size(dwn_out.t))*2;
% 
%     fheader = ['AR30-03    Calibrated Oxygen Downcast   Station: ' num2str(cast_num(i)) newline...
%     'Latitude: ' sprintf('%.4f',dwn_out.lat(1)) '   Longitude: ' sprintf('%.4f',dwn_out.lon(1))...
%     '   ' datestr(dwn_out.StartTimeUTC(1)) newline...
%     sprintf('CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
%     sprintf('dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 
% 
%     fileIDd = fopen(['AR30-03_' sprintf('%03d',cast_num(i)) 'd.csv'],'w');
%     fprintf(fileIDd,fheader);
%     for ii = 1:length(dwn_out.prs)
%         fprintf(fileIDd,'%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n', dwn_out.prs(ii),dwn_out.t(ii),temp_flag(ii),dwn_out.SP(ii),sal_flag(ii),dwn_out.oxy_volts(ii),oxycur_flag(ii),dwn_out.DOcorr_umolkg(ii),ctdoxy_flag(ii));
%     end
%     fclose(fileIDd);
% end
% 
% for i = 1:length(cast_num)
%     up_out = upcasts{cast_num(i)};
% 
%     temp_flag = ones(size(up_out.t))*2;
%     sal_flag = ones(size(up_out.t))*2;
%     oxycur_flag = ones(size(up_out.t))*2;
%     ctdoxy_flag = ones(size(up_out.t))*2;
% 
%     fheader = ['AR30-03    Calibrated Oxygen Upcast   Station: ' num2str(cast_num(i)) newline...
%     'Latitude: ' sprintf('%.4f',up_out.lat(1)) '   Longitude: ' sprintf('%.4f',up_out.lon(1))...
%     '   ' datestr(up_out.StartTimeUTC(1)) newline...
%     sprintf('CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
%     sprintf('dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 
% 
%     fileIDu = fopen(['AR30-03_' sprintf('%03d',cast_num(i)) 'u.csv'],'w');
%     fprintf(fileIDu,fheader);
%     for ii = 1:length(up_out.prs)
%         fprintf(fileIDd,'%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n', up_out.prs(ii),up_out.t(ii),temp_flag(ii),up_out.SP(ii),sal_flag(ii),up_out.oxy_volts(ii),oxycur_flag(ii),up_out.DOcorr_umolkg(ii),ctdoxy_flag(ii));
%     end
%     fclose(fileIDu);
% end

%%
% Pull all bottle files and create one large table 
btlsum_tbl = [];
for i = 1:length(btlsum)
    btlsum_tbl = [btlsum_tbl; btlsum{i}];
end

% Rename variables because already had working code 
btlsum_tbl.Winkler1_umolkg = btlsum_tbl.Winkler_OOI_umolkg;
btlsum_tbl.Winkler2_umolkg = btlsum_tbl.Winkler1_HIP_umolkg;
btlsum_tbl.Winkler3_umolkg = btlsum_tbl.Winkler2_HIP_umolkg;
btlsum_tbl.NLMR_Outlier1 = btlsum_tbl.NLMR_OOI_Outlier;
btlsum_tbl.NLMR_Outlier2 = btlsum_tbl.NLMR_HIP1_Outlier;
btlsum_tbl.NLMR_Outlier3 = btlsum_tbl.NLMR_HIP2_Outlier;

% Put back into structure format for bottle 
btlsum = []; 
for i = 1:length(cast_num)
        btlsum{cast_num(i)} = btlsum_tbl(btlsum_tbl.Cast == cast_num(i),:); 
end
% btlsum_yr5 = btlsum;
 % The bottle code doesn't work for bottle 21 (No Winkler1 but Winklers 2
 % and 3)
%%
% cd(bco_dmo)
% for i = 1:length(btl_num)
%     btl_out = btlsum{btl_num(i)};
%     index1 = max(~(isnan(btl_out.Winkler1_umolkg)));
%     index2 = max(~(isnan(btl_out.Winkler1_umolkg) | isnan(btl_out.Winkler2_umolkg)));
%     index3 = max(~(isnan(btl_out.Winkler1_umolkg) | isnan(btl_out.Winkler2_umolkg) | isnan(btl_out.Winkler3_umolkg)));
%     
%     btl_out.NLMR_Outlier1(isnan(btl_out.Winkler1_umolkg)) = 9;
%     btl_out.NLMR_Outlier1(btl_out.NLMR_Outlier1 == 1) = 3; % Or should this be 4?
%     btl_out.NLMR_Outlier1(btl_out.NLMR_Outlier1 == 0) = 2;
%     btl_out.Winkler1_umolkg(isnan(btl_out.Winkler1_umolkg)) = -999;
%     
%     btl_out.NLMR_Outlier2(isnan(btl_out.Winkler2_umolkg)) = 9;
%     btl_out.NLMR_Outlier2(btl_out.NLMR_Outlier2 == 1) = 3; % Or should this be 4?
%     btl_out.NLMR_Outlier2(btl_out.NLMR_Outlier2 == 0) = 2;
%     btl_out.Winkler2_umolkg(isnan(btl_out.Winkler2_umolkg)) = -999;
% 
%     btl_out.NLMR_Outlier3(isnan(btl_out.Winkler3_umolkg)) = 9;
%     btl_out.NLMR_Outlier3(btl_out.NLMR_Outlier3 == 1) = 3; % Or should this be 4?
%     btl_out.NLMR_Outlier3(btl_out.NLMR_Outlier3 == 0) = 2;
%     btl_out.Winkler3_umolkg(isnan(btl_out.Winkler3_umolkg)) = -999;
% % 
%     temp_flag = ones(size(btl_out.t))*2;
%     sal_flag = ones(size(btl_out.t))*2;
%     oxycur_flag = ones(size(btl_out.t))*2;
%     ctdoxy_flag = ones(size(btl_out.t))*2;
% 
%     data =  [btl_out.Bottle,btl_out.prs,btl_out.t,temp_flag,btl_out.SP,sal_flag,btl_out.oxy_volts,oxycur_flag,btl_out.DOcorr_umolkg,ctdoxy_flag,...
%         btl_out.Winkler1_umolkg,btl_out.NLMR_Outlier1,btl_out.Winkler2_umolkg,btl_out.NLMR_Outlier2,btl_out.Winkler3_umolkg,btl_out.NLMR_Outlier3];
% 
%     if index1 + index2 + index3 == 3
%         fheader = ['AR30-03    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
%         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag, Oxygen1, Oxygen1_flag, Oxygen2, Oxygen2_flag, Oxygen3, Oxygen3_flag') newline...
%         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a., umol/kg, n.a., umol/kg, n.a., umol/kg, n.a.') newline];
%         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d,%.1f,%d,%.1f,%d,%.1f,%d\n';
%         data_format = data;
%     elseif index1 + index2 + index3 == 2
%         fheader = ['AR30-03    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
%         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag, Oxygen1, Oxygen1_flag, Oxygen2, Oxygen2_flag') newline...
%         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a., umol/kg, n.a., umol/kg, n.a.') newline];   
%         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d,%.1f,%d,%.1f,%d\n';
%         data_format = data(:,1:end-2);
%     elseif index1 + index2 + index3 == 1
%         fheader = ['AR30-03    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
%         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag, Oxygen1, Oxygen1_flag') newline...
%         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a., umol/kg, n.a.') newline];
%         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d,%.1f,%d\n';
%         data_format = data(:,1:end-4);
%     else
%         fheader = ['AR30-03    Post-CTD Oxygen Calibration   Station: ' num2str(btl_num(i)) newline...
%         sprintf('Niskin_ID, CTDPRES, CTDTEMP_ITS90, CTDTEMP_flag, CTDSAL_PSS78, CTDSAL_flag, CTDOXYCUR, CTDOXYCUR_flag, CTDOXY, CTDOXY_flag') newline...
%         sprintf('n.a., dbar, deg_C, n.a., n.a., n.a., volts, n.a., umol/kg, n.a.') newline]; 
%         string_format = '%d,%.1f,%.3f,%d,%.3f,%d,%.5f,%d,%.1f,%d\n';
%         data_format = data(:,1:end-6);
%     end
% 
%     fileID = fopen(['AR30-03_' sprintf('%03d',btl_num(i)) 'btl.csv'],'w');
%     fprintf(fileID,fheader);
%         for ii = 1:length(btl_out.Bottle)
%             fprintf(fileID,string_format, data_format(ii,:));
%         end
%     fclose(fileID);
% end