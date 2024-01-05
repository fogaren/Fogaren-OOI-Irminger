cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Sept2023')
load wfpmerge_output.mat
wggmerge_fl.prs = 150:1:2600;

addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))
run('GeneralSettings.m')
%% Take a look at the data 
[X1,Y1] = ndgrid(wggmerge_fl.time,wggmerge_fl.prs);
X1 = X1'; Y1 = Y1';
ind = ~isnan(wggmerge_fl.chla);
figure
scatter(X1(ind),Y1(ind),[],wggmerge_fl.chla(ind),'filled')
axis ij
datetick
cmocean('algae')
colorbar


%%
figure
plot(movmean(wggmerge_fl.chla(:,100),25),wggmerge_fl.prs,'.-')
axis ij
grid on
%%

j = 5; % movmean 

MLchl_db = NaN(size(wggmerge_fl.time));
deep_ind_s = find(wggmerge_fl.prs == 2000); % Find depth index of interest
deep_ind_e = find(wggmerge_fl.prs == 2500); 

for i = 1:length(wggmerge_fl.time)
    
    castmean = movmean(wggmerge_fl.chla(:,i),j);

    deepmean = mean(wggmerge_fl.chla(deep_ind_s:deep_ind_e,i),'omitnan'); % Chla mean beyond 2000 m 
    deepstd = std(wggmerge_fl.chla(deep_ind_s:deep_ind_e,i),'omitnan'); % Chla std beyond 2000 m 
    ind = find(castmean < (deepmean + deepstd));

    if ~isempty(ind)
    chldata = wggmerge_fl.prs(~isnan(wggmerge_fl.chla(:,i)))';
    chldata = chldata(1:15); % first 15 depths with chl data 
    removetop = find(wggmerge_fl.prs(ind(1)) == chldata);
    end

    if isempty(ind) 
        MLchl_db(i) = NaN;
    end
    if ~isempty(ind)
        MLchl_db(i) = wggmerge_fl.prs(ind(1));  
    end
    if ~isempty(ind) & ~isempty(removetop) 
        MLchl_db(i) = NaN;
    end
end

indnan = ~isnan(wggmerge_fl.chla);

figure
scatter(X1(indnan),Y1(indnan),[],wggmerge_fl.chla(indnan),'filled')
hold on
plot(wggmerge_fl.time,MLchl_db,'.k')
axis ij
shading interp
datetick
cmocean('algae')
colorbar
%% Remove "blank"
castblanked = [];
j = 1; % movmean 

MLchl_db = NaN(size(wggmerge_fl.time));
deep_ind_s = find(wggmerge_fl.prs == 2000); % Find depth index of interest
deep_ind_e = find(wggmerge_fl.prs == 2500); 

for i = 1:length(wggmerge_fl.time)
    castmin = min(wggmerge_fl.chla(:,i));
    castblanked(:,i) = wggmerge_fl.chla(:,(i)) - castmin;
    
    castmean = movmean(castblanked(:,i),j);

    deepmean = mean(castblanked(deep_ind_s:deep_ind_e,i),'omitnan'); % Chla mean beyond 2000 m 
    deepstd = std(castblanked(deep_ind_s:deep_ind_e,i),'omitnan'); % Chla std beyond 2000 m 
    ind = find(castmean < (deepmean + deepstd));

    if ~isempty(ind)
    chldata = wggmerge_fl.prs(~isnan(castblanked(:,i)))';
    chldata = chldata(1:15); % first 15 depths with chl data 
    removetop = find(wggmerge_fl.prs(ind(1)) == chldata);
    end

    if isempty(ind) 
        MLchl_db(i) = NaN;
    end
    if ~isempty(ind)
        MLchl_db(i) = wggmerge_fl.prs(ind(1));  
    end
    if ~isempty(ind) & ~isempty(removetop) 
        MLchl_db(i) = NaN;
    end
end

[X1,Y1] = ndgrid(wggmerge_fl.time,wggmerge_fl.prs);
X1 = X1'; Y1 = Y1';
indgood = ~isnan(castblanked);
figure
% pcolor(fl.time(deployment),fl.prs,castblanked)
scatter(X1(indgood),Y1(indgood),[],castblanked(indgood),'filled')
hold on
plot(wggmerge_fl.time,MLchl_db,'.k')
axis ij
% shading interp
datetick
% cmocean('algae')
colorbar

% figure
% pcolor(fl.time,fl.prs,castblanked)
% hold on
% plot(fl.time,MLchl_db,'.k')
% axis ij
% shading interp
% datetick
% cmocean('algae')
% colorbar

%% Remove "blank" by deployment 
% this was supposed to find subsurface chl maxima but still needs some
% work. 
castblanked = [];
j = 5; % movmean 
deployment = find(wggmerge_fl.deploy_yr == 8); 
MLchl_db_min = NaN(size(deployment));
MLchl_db_max = NaN(size(deployment));
deep_ind_s = find(wggmerge_fl.prs == 2000); % Find depth index of interest
deep_ind_e = find(wggmerge_fl.prs == 2500); 
castblanked = [];


for i = 1:length(deployment)
    castmin = min(wggmerge_fl.chla(:,deployment(i)));
    castblanked(:,i) = wggmerge_fl.chla(:,deployment(i)) - castmin;
end

deepmean_all = nanmean(nanmean(castblanked(deep_ind_s:deep_ind_e,:)));
deepstd_all = nanmean(nanstd(castblanked(deep_ind_s:deep_ind_e,:)));

for i = 1:length(deployment)
    
    castmean = movmean(castblanked(:,i),j);

    deepmean = mean(castblanked(deep_ind_s:deep_ind_e,i),'omitnan'); % Chla mean beyond 2000 m 
    deepstd = std(castblanked(deep_ind_s:deep_ind_e,i),'omitnan'); % Chla std beyond 2000 m 
    if ~isnan(deepmean) 
        ind = find(castmean < (deepmean + deepstd*3));
        indmax = find(castmean > (deepmean + deepstd*3));
    end
    if isnan(deepmean)
        ind = find(castmean < (deepmean_all + deepstd_all*3));
        indmax = find(castmean > (deepmean + deepstd*3));
    end

    indm = find(diff(indmax) > 1);
    if isempty(indmax)
        indmax = ind; 
    end
    if ~isempty(indm)
        indmax = indm(end);
    end


    if ~isempty(ind)
    chldata = wggmerge_fl.prs(~isnan(castblanked(:,i)))';
    chldata = chldata(1:15); % first 15 depths with chl data 
    removetop = find(wggmerge_fl.prs(ind(1)) == chldata);
    end

    if isempty(ind) 
        MLchl_db_min(i) = NaN;
        MLchl_db_max(i) = NaN;
    end
    if ~isempty(ind)
        MLchl_db_min(i) = wggmerge_fl.prs(ind(1)); 
        MLchl_db_max(i) = wggmerge_fl.prs(indmax(end));
    end
    if ~isempty(ind) & ~isempty(removetop) 
        MLchl_db_min(i) = NaN;
        MLchl_db_max(i) = NaN; 
    end
%     if ~isempty(ind) & chldata < (deepmean_all + deepstd_all*2) 
%         MLchl_db(i) = NaN;
%     end

    figure(1)
    plot(castblanked(:,i),wggmerge_fl.prs)
    hold on 
    plot(castmean,wggmerge_fl.prs,'Linewidth',1.5)
    plot(min(castblanked(:,i)):0.01:max(castblanked(:,i)),ones(size(min(castblanked(:,i)):0.01:max(castblanked(:,i))))*MLchl_db_min(i),'k--')
    plot(min(castblanked(:,i)):0.01:max(castblanked(:,i)),ones(size(min(castblanked(:,i)):0.01:max(castblanked(:,i))))*MLchl_db_max(i),'g--')
    axis ij
    title(num2str(i))
    pause
    clf
end

[X1,Y1] = ndgrid(wggmerge_fl.time(deployment),wggmerge_fl.prs);
X1 = X1'; Y1 = Y1';
indgood = ~isnan(castblanked);
figure
% pcolor(fl.time(deployment),fl.prs,castblanked)
scatter(X1(indgood),Y1(indgood),[],castblanked(indgood),'filled')
hold on
plot(wggmerge_fl.time(deployment),MLchl_db_min,'.k')
% plot(fl.time(deployment),MLchl_db_max,'.r')
axis ij
% shading interp
datetick 
cmocean('algae')
colorbar
title(['Deployment ' num2str(wggmerge_fl.deploy_yr(deployment(1)))])
% 

%% Process all deployments 
castblanked = [];
j = 1; % movmean 
MLchl_db = NaN(size(wggmerge_fl.time));
deep_ind_s = find(wggmerge_fl.prs == 2000); % Find depth index of interest
deep_ind_e = find(wggmerge_fl.prs == 2500); 

for i = 1:length(wggmerge_fl.time)
    castmin = min(wggmerge_fl.chla(:,i));
    castblanked(:,i) = wggmerge_fl.chla(:,i) - castmin;
end

deepmean_all = nanmean(nanmean(castblanked(deep_ind_s:deep_ind_e,:)));
deepstd_all = nanmean(nanstd(castblanked(deep_ind_s:deep_ind_e,:)));

for i = 1:length(wggmerge_fl.time)
    
    castmean = movmean(castblanked(:,i),j);

    deepmean = mean(castblanked(deep_ind_s:deep_ind_e,i),'omitnan'); % Chla mean beyond 2000 m 
    deepstd = std(castblanked(deep_ind_s:deep_ind_e,i),'omitnan'); % Chla std beyond 2000 m 
    if ~isnan(deepmean)
    ind = find(castmean < (deepmean + deepstd));
    end
    if isnan(deepmean)
        ind = find(castmean< (deepmean_all + deepstd_all));
    end


    if ~isempty(ind)
    chldata = wggmerge_fl.prs(~isnan(castblanked(:,i)))';
    chldata = chldata(1:15); % first 15 depths with chl data 
    removetop = find(wggmerge_fl.prs(ind(1)) == chldata);
    end

    if isempty(ind) 
        MLchl_db(i) = NaN;
    end
    if ~isempty(ind)
        MLchl_db(i) = wggmerge_fl.prs(ind(1));  
    end
    if ~isempty(ind) & ~isempty(removetop) 
        MLchl_db(i) = NaN;
    end
%     if ~isempty(ind) & chldata < (deepmean_all + deepstd_all*2) 
%         MLchl_db(i) = NaN;
%     end
end
%%
[X1,Y1] = ndgrid(wggmerge_fl.time,wggmerge_fl.prs);
X1 = X1'; Y1 = Y1';
indgood = ~isnan(castblanked);
figure
scatter(X1(indgood),Y1(indgood),[],castblanked(indgood),'filled')
hold on
plot(wggmerge_fl.time,MLchl_db,'.k')
% plot(wfp_chl.dn,wfp_chl.mld_db,'.k')
axis ij
datetick 
colorbar
cmocean('algae')
% 
%%
figure
plot(wggmerge_fl.time,MLchl_db,'.k')
datetick
grid on
axis ij
%%
j = 10; % movmean 

MLchl_db = NaN(size(wggmerge_fl.time));
deep_ind_s = find(wggmerge_fl.prs == 2000); % Find depth index of interest
deep_ind_e = find(wggmerge_fl.prs == 2500); 

for i = 1:length(wggmerge_fl.time)
    castmean = movmean(castblanked(:,i),j);

    deepmean = mean(castblanked(deep_ind_s:deep_ind_e,i),'omitnan'); % Chla mean beyond 2000 m 
    deepstd = std(castblanked(deep_ind_s:deep_ind_e,i),'omitnan'); % Chla std beyond 2000 m 
    ind = find(castmean < (deepmean + deepstd));
    if isempty(ind) 
        MLchl_db(i) = NaN;
    else
        MLchl_db(i) = wggmerge_fl.prs(ind(1));  
    end
end
%% 
% Remove MLD based on chl-a if no reading for chl-a at ~300 m
% ind = isnan(fl.chla(75,:));
MLchl_db2 = MLchl_db;
MLchl_db2(MLchl_db < 170) = NaN;
% MLchlp(ind) = NaN;
% save Quick_MLD_chl.mat MLchlp MLchlz

figure
plot(wggmerge_fl.time,MLchl_db,'.')
hold on
plot(wggmerge_fl.time,MLchl_db2,'.')
axis ij
grid on
%%
for i = 1:length(wggmerge_fl.time)
    figure(1)
    plot(castblanked(:,i),wggmerge_fl.prs)
    hold on
    plot(movmean(castblanked(:,i),100),wggmerge_fl.prs,'Linewidth',1.5)
    axis ij; grid on
    pause
    clf
end

%%
ind2 = castblanked(wggmerge_fl.deploy_yr == 1); 
figure
scatter(X1(ind & ind2),Y1(ind & ind2),[],castblanked(ind & ind2),'filled')
axis ij
datetick
shading interp
cmocean('algae')
colorbar