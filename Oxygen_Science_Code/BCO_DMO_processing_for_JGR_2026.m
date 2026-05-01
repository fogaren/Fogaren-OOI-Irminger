% Produce data product submitted to BCO-DMO for JGR Oceans 2026
tic

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('glider_griddall_fixedPc1600db.mat')
glider = glidergrid; clear glidergrid;
glider_prs = 1:1000;

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('wfpmerge_output_fixedPc1600db.mat')
wfp_prs = 150:1:2600; % Depths of Hilary's product
%% Rename data and pick variables 
wfp.prs = wfp_prs;
wfp.prs = wfp.prs';
wfp.dn = wggmerge.time;
wfp.dt = datetime(wggmerge.time,'ConvertFrom','datenum');
wfp.lat = round(wggmerge.lat,3);
wfp.lon = round(wggmerge.lon,3);
wfp.deploy_yr = wggmerge.deploy_yr;
wfp.temp = round(wggmerge.temp,3);
wfp.pracsal = round(wggmerge.pracsal,3);
wfp.DO_umolkg = round(wggmerge.doxy,1); 

wfp_output = [];
for j = 1:length(wfp.dt)
    pn = repmat(j,size(wfp.prs)); % profile number 
    dn_pn = repmat(wfp.dn(j),size(wfp.prs)); % dt x profile number 
    lon_pn = repmat(wfp.lon(j),size(wfp.prs));
    lat_pn = repmat(wfp.lat(j),size(wfp.prs));
    dy_pn = repmat(wfp.deploy_yr(j),size(wfp.prs));
    prs_pn = wfp.prs;
    temp_pn = wfp.temp(:,j);
    pracsal_pn = wfp.pracsal(:,j);
    DO_umolkg = wfp.DO_umolkg(:,j);
    var1 = [pn dn_pn lon_pn lat_pn dy_pn prs_pn temp_pn pracsal_pn DO_umolkg];
    wfp_output = [wfp_output; var1];
    clear var1
end
%%
wfp_table = array2table(wfp_output,'VariableNames',{'profile_number','dn','longitude','latitude','deploy_yr','prs_dbar','temp_degC','pracsal','DO_umolkg'});
wfp_table.datetime = datetime(wfp_table.dn,'ConvertFrom','datenum');
wfp_tt = table2timetable(wfp_table,"RowTimes",wfp_table.datetime);
wfp_tt = removevars(wfp_tt,{'dn','datetime'});

indnan = find(isnan(wfp_tt.temp_degC) & isnan(wfp_tt.pracsal) & isnan(wfp_tt.DO_umolkg));

wfp_tt(indnan,:) = [];
%%
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
writetimetable(wfp_tt,'wfp.csv')

%% Clean up glider data

for j = 1:13
    glider{j}.prs = glider_prs;
    glider{j}.prs = glider{j}.prs';
    glider{j}.dn = glider{j}.time;
    glider{j}.dt = datetime(glider{j}.time,'ConvertFrom','datenum');
    glider{j}.temp = round(glider{j}.temp,3);
    glider{j}.pracsal = round(glider{j}.pracsal,3);
    glider{j}.DO_umolkg = round(glider{j}.doxy,1);

    glider{j} = rmfield(glider{j},{'time','duration','SA','CT','pdens','chla','backscatter','doxy'});
end
glider{5} = {}; % Bad oxygen drift, removed but left space so that rest of my code works 

clear j glider_prs
%%
glider_output = [];
for k = 1:13
    if k ~= 5 % glider with bad DO data 
        for j = 1:length(glider{k}.dt)
            gn = repmat(glider{k}.glidernum,size(glider{k}.prs)); 
            pn = repmat(j,size(glider{k}.prs)); % profile number 
            dn_pn = repmat(glider{k}.dn(j),size(glider{k}.prs)); % dt x profile number 
            lon_pn = repmat(glider{k}.lon(j),size(glider{k}.prs));
            lat_pn = repmat(glider{k}.lat(j),size(glider{k}.prs));
            dy_pn = repmat(glider{k}.deploy_yr(j),size(glider{k}.prs));
            prs_pn = glider{k}.prs;
            temp_pn = glider{k}.temp(:,j);
            pracsal_pn = glider{k}.pracsal(:,j);
            DO_umolkg = glider{k}.DO_umolkg(:,j);
            var1 = [gn pn dn_pn lon_pn lat_pn dy_pn prs_pn temp_pn pracsal_pn DO_umolkg];
            glider_output = [glider_output; var1];
            clear var1
        end
    end
end
%%
glider_table = array2table(glider_output,'VariableNames',{'glider_number','profile_number','dn','longitude','latitude','deploy_yr','prs_dbar','temp_degC','pracsal','DO_umolkg'});
glider_table.datetime = datetime(glider_table.dn,'ConvertFrom','datenum');
glider_tt = table2timetable(glider_table,"RowTimes",glider_table.datetime);
glider_tt = removevars(glider_tt,{'dn','datetime'});
% Find all points with nan to remove for BCO DMO submission 
indnan = find(isnan(glider_tt.temp_degC) & isnan(glider_tt.pracsal) & isnan(glider_tt.DO_umolkg));

glider_tt(indnan,:) = [];

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
writetimetable(glider_tt,'glider.csv')
%%
cd('G:\Shared drives\NSF_Irminger\Data_Files\From Meg')
load blended_mld_daily.mat

blended_mld_daily_all.dt = blended_mld_daily_all.time;
blended_mld_daily_all = rmfield(blended_mld_daily_all,'time');
daily_mld = blended_mld_daily_all;

ind = find(daily_mld.dt == datetime(2022,08,31)); % cut timeseries
daily_mld.dt = daily_mld.dt(1:ind);
daily_mld.mld = round(daily_mld.mld(1:ind),0);
daily_mld = struct2table(daily_mld);
daily_mld = daily_mld(:,{'dt','mld'});


cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
writetable(daily_mld,'daily_mld.csv');
clear blended_mld_daily*

%%
cd('G:\Shared drives\NSF_Irminger\OOI_DO_fixed_depth\Data\mixed_layer')
load mixed_layer_calibrated_oxygen.mat

sumo = ML_DO(ML_DO.prs == 1,:);
sumo = sumo(sumo.t > -4,:);
nsif = ML_DO(ML_DO.prs > 1,:);

sumo.lat = round(sumo.lat,3);
sumo.lon = round(sumo.lon,3);
sumo.temp_degC = round(sumo.t,3);
sumo.pracsal = round(sumo.SP,3);
sumo.DO_umolkg = round(sumo.DO_umolkg_final,1);
sumo = sumo(:,{'deployment','lat','lon','prs','temp_degC','pracsal','DO_umolkg'});
indnan = find(isnan(sumo.temp_degC) & isnan(sumo.pracsal) & isnan(sumo.DO_umolkg));

sumo(indnan,:) = [];

nsif.lat = round(nsif.lat,3);
nsif.lon = round(nsif.lon,3);
nsif.temp_degC = round(nsif.t,3);
nsif.pracsal = round(nsif.SP,3);
nsif.DO_umolkg = round(nsif.DO_umolkg_final,1);
nsif = nsif(:,{'deployment','lat','lon','prs','temp_degC','pracsal','DO_umolkg'});
indnan = find(isnan(nsif.temp_degC) & isnan(nsif.pracsal) & isnan(nsif.DO_umolkg));

nsif(indnan,:) = [];

sumo1 = sumo;
sumo7 = nsif;
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
writetimetable(sumo1,'sumo1.csv');
writetimetable(sumo7,'sumo7.csv');

%% Run after running whole workflow, pick up from here.  
% Blended 1-m daily oxygen product 
cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\Oxygen_Science_Code\')
run('Workflow_for_Combined_DO_Remineralization_Calculations.m')
close all

daily_DO.dn = daily.time;
daily_DO.dt = datetime(daily_DO.dn,'ConvertFrom','datenum');
daily_DO.prs = double(1:2600);
daily_DO.prs = daily_DO.prs';
daily_DO.DO_umolkg = daily.doxy;

daily_output = [];
for j = 1:length(daily_DO.dt)
    pn = repmat(j,size(daily_DO.prs)); % profile number 
    dn_pn = repmat(daily_DO.dn(j),size(daily_DO.prs)); % dt x profile number 
    lon_pn = repmat(round(lon_wfp,3),size(daily_DO.prs)); % mean lon of wfp
    lat_pn = repmat(round(lat_wfp,3),size(daily_DO.prs)); % mean lat of wfp
    prs_pn = daily_DO.prs;
    DO_umolkg = round(daily_DO.DO_umolkg(:,j),1);
    var1 = [pn dn_pn lon_pn lat_pn prs_pn DO_umolkg];
    daily_output = [daily_output; var1];
    clear var1
end
%%
daily_table = array2table(daily_output,'VariableNames',{'profile_number','dn','longitude','latitude','prs_dbar','DO_umolkg'});
daily_table.datetime = datetime(daily_table.dn,'ConvertFrom','datenum');
daily_tt = table2timetable(daily_table,"RowTimes",daily_table.datetime);
daily_tt = removevars(daily_tt,{'dn','datetime'});
% Find all points with nan to remove for BCO DMO submission 
indnan = find(isnan(daily_tt.DO_umolkg));

daily_tt(indnan,:) = [];
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
writetimetable(daily_tt,'daily_DO.csv');
%% Binned 
binned_bbl.dn = wfpmerge.profile_start_filt';
binned_bbl.dt = datetime(binned_bbl.dn,'ConvertFrom','datenum');
binned_bbl.centerofdepthbin = wfpmerge.sinkingpulsedepths;
binned_bbl.binned_bbl = wfpmerge.binned_filteredspikes_filt;

[m,n] = size(binned_bbl.centerofdepthbin);

binned_output = [];
for j = 1:length(binned_bbl.dt)
    pn = repmat(j,size(binned_bbl.centerofdepthbin)); % profile number 
    dn_pn = repmat(binned_bbl.dn(j),size(binned_bbl.centerofdepthbin)); % dt x profile number 
    lon_pn = repmat(round(lon_wfp,3),size(binned_bbl.centerofdepthbin)); % mean lon of wfp
    lat_pn = repmat(round(lat_wfp,3),size(binned_bbl.centerofdepthbin)); % mean lat of wfp
    prs_pn = binned_bbl.centerofdepthbin;
    bbl_npts = squeeze(wfpmerge.binned_filteredspikes_filt(j,:,1))';
    bbl_mean = squeeze(wfpmerge.binned_filteredspikes_filt(j,:,2))';
    bbl_std = squeeze(wfpmerge.binned_filteredspikes_filt(j,:,3))';
    bbl_max = squeeze(wfpmerge.binned_filteredspikes_filt(j,:,4))';
    bbl_med = squeeze(wfpmerge.binned_filteredspikes_filt(j,:,5))';
    bbl_95p = squeeze(wfpmerge.binned_filteredspikes_filt(j,:,6))';
    var1 = [pn dn_pn lon_pn lat_pn prs_pn bbl_npts bbl_mean bbl_std bbl_max bbl_med bbl_95p];
    binned_output = [binned_output; var1];
    clear var1
end
%%
binned_table = array2table(binned_output,'VariableNames',{'profile_number','dn','longitude','latitude','centerofbin_m','bbl_npts','bbl_mean','bbl_std','bbl_max','bbl_med','bbl_95per'});
binned_table.datetime = datetime(binned_table.dn,'ConvertFrom','datenum');
binned_tt = table2timetable(binned_table,"RowTimes",binned_table.datetime);
binned_tt = removevars(binned_tt,{'dn','datetime'});
% Find all points with nan to remove for BCO DMO submission 
indnan = find(isnan(binned_tt.bbl_npts) & isnan(binned_tt.bbl_mean) & isnan(binned_tt.bbl_std));

binned_tt(indnan,:) = [];
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
writetimetable(binned_tt,'binned.csv');

toc

%% 
figure % Check binned data 
plot(binned_tt.bbl_95per(binned_tt.profile_number == 8),binned_tt.centerofbin_m(binned_tt.profile_number == 8),'.')
hold on
plot(squeeze(wfpmerge.binned_filteredspikes_filt(8,:,6)),wfpmerge.sinkingpulsedepths,'o')

figure % Check oxygen data 
plot(daily_tt.DO_umolkg(daily_tt.profile_number == 8),daily_tt.prs_dbar(daily_tt.profile_number == 8),'.')
hold on
plot(daily.doxy(:,8),1:2600,'o')

