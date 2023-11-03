%% *CSV for bottles associated with Casts 6 and 9 have been removed

addpath(genpath('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\AR69-03'))
files = ls('*downcast*'); % List of Leah's calibrated bottle files 
casts = str2num(files(:,1:3)); % Pulls out cast numbers that have bottle files 


fnd = '007_profile_downcast_2db.nc';
fnu = '007_profile_upcast_2db.nc';
oxyd = ncread(fnd,'CTDOXY_SIO');
oxyu = ncread(fnu,'CTDOXY_SIO');
prsd = ncread(fnd,'CTDPRS');
prsu = ncread(fnu,'CTDPRS');

figure
plot(oxyd,prsd)
hold on
plot(downcasts_AR6903{7}.DOcorr_umolkg,downcasts_AR6903{7}.prs)
grid on
axis ij
title('Downcast 7')
figure
plot(oxyu,prsu)
hold on
plot(upcasts_AR6903{7}.DOcorr_umolkg,upcasts_AR6903{7}.prs)
grid on
axis ij
title('Upcast 7')
xlim([250 300])