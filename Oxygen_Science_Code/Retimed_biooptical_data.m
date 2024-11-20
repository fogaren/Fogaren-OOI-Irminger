%% CHL- Mixed Layer Plot 
% Nothing added by adding gliders
% Look into flanking moorings 
% Sat chl doesn't add anything really 
cd('G:\My Drive\Matlab_work\Github\Meg_Irminger_Review\FINAL')
load chl_clean.mat

% Backscatter timeseries with mixed layer depths 
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('wfpmerge_output_fixedPc1600db.mat','wggmerge_fl');

%% Sort biooptical data to be in ascending order 

[time,IND] = sort(wggmerge_fl.time);
chla = wggmerge_fl.chla(:,IND);
backscatter = wggmerge_fl.backscatter(:,IND);
spikes = wggmerge_fl.spikes(:,IND);
chlspikes = wggmerge_fl.chlspikes(:,IND);

bioopt.time = time;
bioopt.prs = 150:1:2600; % Depths of Hilary's product
bioopt.chla = chla; 
bioopt.backscatter = backscatter; 
bioopt.spikes = spikes; 
bioopt.chlspikes = chlspikes; 
clear time IND chla backscatter spikes chlspikes
%% Put daily mld timeseries onto sorted fluorescence timeseries
blended_mld_daily_all.dn = datenum(blended_mld_daily_all.time);

% MLD timeseries onto timestamp for flur timeseries
bioopt.mld_db = interp1(blended_mld_daily_all.dn,blended_mld_daily_all.mld,bioopt.time);
%% Blank the chl-a data for sensor differences across deployments 

for j = 1:length(bioopt.time)
    chlmin = min(bioopt.chla(:,j));
    bioopt.chla_blanked(:,j) = bioopt.chla(:,j) - chlmin;
end
%% Find the depth of the MLD in the biooptical prs index
rounded_mld = round(bioopt.mld_db); % interpolation results in non interger MLDs 

mld_ind = NaN(size(bioopt.time));
for j = 1:length(bioopt.time)
    if ~isnan(rounded_mld(j))
        [~,b] = find(bioopt.prs == rounded_mld(j));
        if ~isempty(b)
            mld_ind(j) = b;
        end
    end
end
bioopt.mld_ind = mld_ind; % index of the mld depth in the pressure vector
clear rounded_mld mld_ind
%% Find the avg of the blanked chl data within in the mixed layer 

bioopt.ml_chl_blanked_mean = NaN(size(bioopt.time));
bioopt.ml_chl_blanked_median = NaN(size(bioopt.time));
bioopt.ml_chl_blanked_std = NaN(size(bioopt.time));
bioopt.ml_chl_blanked_max = NaN(size(bioopt.time));
for j = 1:length(bioopt.time)
    if ~isnan(bioopt.mld_ind(j))
        bioopt.ml_chl_blanked_mean(j) = nanmean(bioopt.chla_blanked(1:bioopt.mld_ind(j),j));
        bioopt.ml_chl_blanked_median(j) = nanmedian(bioopt.chla_blanked(1:bioopt.mld_ind(j),j));
        bioopt.ml_chl_blanked_std(j) = nanstd(bioopt.chla_blanked(1:bioopt.mld_ind(j),j));
        bioopt.ml_chl_blanked_max(j) = nanmax(bioopt.chla_blanked(1:bioopt.mld_ind(j),j));
    end
end
%%
tic
t = [      736090 % Times when mld first shoals less than 200 m 
      736450
      736833
      737192
      737558
      737912
      738281
      738641];
figure
set(gcf,'position',[100,100,900,500])
subplot(3,1,1)
% set(gcf,'position',[100,100,800,150])
ax1 = gca;
for j = 1:length(t)
    plot([t(j) t(j)],[0 10],'Color',grey,'LineStyle',':','Linewidth',1.5)
    hold on
end
for j = 1:4
    for k = 2:8
    plot(chl_final{j}{k}.time,chl_final{j}{k}.data,'.','Color',rgb('forest green'),'MarkerSize',8)
    hold on
    end
end
% plot(bioopt.time,bioopt.ml_chl_blanked_mean,'.')
% plot(bioopt.time,bioopt.ml_chl_blanked_median,'.')
plot(bioopt.time,bioopt.ml_chl_blanked_max,'.','Color',rgb('green'))
datetick('x','yyyy')

% ylabel({'mixed layer'  'chl-a' '(\mug L^-^1)'},'Fontsize',14)
ylabel({'chl-a' '(\mug L^-^1)'},'Fontsize',12)
ax1.FontSize = 12;
xlim([datenum(2015,01,01) datenum(2022,04,01)])

[X2,Y2] = meshgrid(bioopt.time,bioopt.prs);

subplot(3,1,[2 3])
scatter(X2(~isnan(bioopt.spikes)),Y2(~isnan(bioopt.spikes)),2,bioopt.spikes(~isnan(bioopt.spikes)),'filled')
hold on; axis ij; box on
plot(blended_mld_daily_all.dn,blended_mld_daily_all.mld,'ok','MarkerSize',2,'MarkerFaceColor','k')
ylim([0 2000])
clim([0 7E-5])
datetick('x','yyyy');
xlim([datenum(2015,01,01) datenum(2022,04,01)])
cmocean('algae')
ylabel('Pressure (dbar)', 'Fontsize', 12); hcb = colorbar; set(hcb,'location','eastoutside')
% hcb.Label.String = 'DO (\mumol kg^-^1)';
hcb.FontSize = 12;
ax2 = gca;
set(ax2, 'TickDir', 'out')
ax2.FontSize = 12;
linkaxes([ax1 ax2],'x')

toc
% clear wggmerge_fl