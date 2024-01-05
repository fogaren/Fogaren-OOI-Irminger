clearvars

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Sept2023')
load wfpmerge_output.mat
wggmerge_fl.prs = 150:1:2600; % Add wfp depth
prs = wggmerge_fl.prs;
addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))
run('GeneralSettings.m')
%% Processing Pipeline Notes 
% 1. Blank each cast to get relative fluorescence units 
% 2. 


%% Process all deployments 
castblanked = [];
MLchl_db = NaN(size(wggmerge_fl.time));
deep_ind_s = find(wggmerge_fl.prs == 2000); % Find depth index of interest
deep_ind_e = find(wggmerge_fl.prs == 2500); 

% Blank each cast using min observed values for each profile 
for i = 1:length(wggmerge_fl.time)
    castmin = min(wggmerge_fl.chla(:,i));
    castblanked(:,i) = wggmerge_fl.chla(:,i) - castmin;
end

% calculate average deep mean/std for all deployments for profiles that
% don't make it to 2000 m 
deepmean_all = nanmean(nanmean(castblanked(deep_ind_s:deep_ind_e,:)));
deepstd_all = nanmean(nanstd(castblanked(deep_ind_s:deep_ind_e,:)));

for i = 1:length(wggmerge_fl.time)
    
    % For each profile 
    deepmean = mean(castblanked(deep_ind_s:deep_ind_e,i),'omitnan'); % Chla mean beyond 2000 m 
    deepstd = std(castblanked(deep_ind_s:deep_ind_e,i),'omitnan'); % Chla std beyond 2000 m 

    if ~isnan(deepmean) % If profile makes it to 2000-2500 m , use 
    ind = find(castblanked(:,i) < (deepmean + (3*deepstd)));
    end
    if isnan(deepmean) % Use average if profile isn't to 2000-2500 m 
        ind = find(castblanked(:,i) < (deepmean_all + (3*deepstd_all)));
    end 

    if ~isempty(ind) % Check to see that MLD is not within first 15 bins of WFP top 
        chldata = wggmerge_fl.prs(~isnan(castblanked(:,i)))';
        chldata = chldata(1:15); % first 15 depths with chl data 
        removetop = find(wggmerge_fl.prs(ind(1)) == chldata);
    end

    if isempty(ind) % If no MLD found, MLD == NaN 
        MLchl_db(i) = NaN;
    end
    if ~isempty(ind) % If MLD found, MLD == 
        MLchl_db(i) = wggmerge_fl.prs(ind(1));  
    end
    if ~isempty(ind) & ~isempty(removetop) % If MLD, but within 15 top bins, MLD == NaN; 
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

% prof_num when ML is seen on WFP for each year. 
ind_skip = [101; 535; 987; 1418; 1862; 2275; 2537]; % wggmerge prof_num
ind_skip_fl = []; % find wggmerge_fl prof numbers 
for i = 1:length(ind_skip)
    ind_skip_fl(i) = find(wggmerge_fl.time == wggmerge.time(ind_skip(i)));
end
ind_skip_fl = [ind_skip_fl; 2877];
% 
%     mld_check = NaN(size(wggmerge_fl.time));
%     mld = NaN(size(wggmerge_fl.time));
%% To look at them by year
for i = 1 %:7 %unique(wggmerge_fl.deploy_yr)
    ind = find(wggmerge_fl.deploy_yr == i);


    clear M1
    for jj = ind_skip_fl:ind(end)
        if ~isnan(wggmerge_fl.time(jj))
            figure(1)
            clf
    
    %         try %plotting the two profiles before the current one 
    %             plot(wggmerge_fl.chla(:,jj-2),prs,'.','Color',rgb('light grey'))
    %             hold on
    %             plot(wggmerge_fl.chla(:,jj-1),prs,'.','Color',rgb('grey'))
    %         end
            plot(wggmerge_fl.chla(:,jj),prs,'.','Color',blue)
            hold on
            if ~isnan(MLchl_db(jj)) % plot MLD determined above 
                plot(wggmerge_fl.chla(prs == MLchl_db(jj),jj),MLchl_db(jj),'sk','MarkerSize',8)
            end
    
    %         if ~isnan(wfp_chl.mld_db_time(jj))
    %     %     chl_time = find(wfp_chl.time == wggmerge_fl.time(jj)); % not needed since wfp_chl time is same as wggmerge_fl.time
    %             plot(wggmerge_fl.chla(prs == wfp_chl.mld_db_time(jj),jj),wfp_chl.mld_db_time(jj),'.k','MarkerSize',20)
    %         end
            axis ij; grid on
    %         title('chl-a')
        
            sgtitle([datestr(wggmerge_fl.time(jj)) ', prof num = ' num2str(jj)])
    %         linkaxes([ax5 ax4 ax3 ax2 ax1],'y')
            prompt = '0 = skip, 1 = pass, 2 = fail, 3 = questionable';
            mld_input = input(prompt)
            mld_check(jj) = mld_input;
            
              if mld_input == 0
                  mld(jj) = NaN;
              elseif mld_input == 1
                  mld(jj) = MLchl_db(jj);
              elseif mld_input == 2
                  mld(jj) = input('user picked MLD') 
              elseif mld_input == 3
                  mld(jj) = NaN;
              end
    %         if mld_input == 1
    %             subplot(1,5,1)
    %             plot(wggmerge.temp(prs == aa(j),j),aa(j),'o','MarkerSize',10,'Linewidth',1.5,'Color',rgb('orange'))        
    %         elseif mld_input == 2
    %             subplot(1,5,2)
    %             plot(wggmerge.pdens(prs == bb(j),j),bb(j),'o','MarkerSize',10,'Linewidth',1.5,'Color',rgb('orange'))
    %         elseif mld_input == 3
    %             subplot(1,5,3)
    %             plot(N2(prs == cc(j)),cc(j),'o','MarkerSize',10,'Linewidth',1.5,'Color',rgb('orange'))
    %         elseif mld_input == 4
    %             subplot(1,5,5)
    %             plot(wggmerge_fl.chla(prs == dd(j),jj),dd(j),'o','MarkerSize',10,'Linewidth',1.5,'Color',rgb('orange'))
    %         elseif mld_input == 5
    %             subplot(1,5,5)
    %             plot(wggmerge_fl.chla(prs == wfp_chl.mld_db_time(jj),jj),wfp_chl.mld_db_time(jj),'o','MarkerSize',10,'Linewidth',1.5,'Color',rgb('orange'))
    %         end
    %     
            
            %             k = 1 + length(M1);
            %             M1(k) = getframe(gcf);
    %          M1(j-ind(1)+1) = getframe(gcf);
         end
    end
end


%% To look at them whole timeseries profile number and work on a certain section 
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load mld_visual_check.mat % File saved with visual check; use if want to redo a section withouth doing the whole thing 

figure
plot(MLchl_db,'.k')
hold on
plot(mld,'.')
grid on
axis ij
legend('Code found','Visually checked','Location','SE')

ind_start = 2600; % Profile number start  
ind_end = 2651; % profile number end 
for jj = ind_start:ind_end
    if ~isnan(wggmerge_fl.time(jj))
        figure(1)
        clf

%         try %plotting the two profiles before the current one 
%             plot(wggmerge_fl.chla(:,jj-2),prs,'.','Color',rgb('light grey'))
%             hold on
%             plot(wggmerge_fl.chla(:,jj-1),prs,'.','Color',rgb('grey'))
%         end
        plot(wggmerge_fl.chla(:,jj),prs,'.','Color',blue)
        hold on
        if ~isnan(MLchl_db(jj)) % plot MLD determined above 
            plot(wggmerge_fl.chla(prs == MLchl_db(jj),jj),MLchl_db(jj),'sk','MarkerSize',8)
        end

%         if ~isnan(wfp_chl.mld_db_time(jj))
%     %     chl_time = find(wfp_chl.time == wggmerge_fl.time(jj)); % not needed since wfp_chl time is same as wggmerge_fl.time
%             plot(wggmerge_fl.chla(prs == wfp_chl.mld_db_time(jj),jj),wfp_chl.mld_db_time(jj),'.k','MarkerSize',20)
%         end
        axis ij; grid on
%         title('chl-a')
    
        sgtitle([datestr(wggmerge_fl.time(jj)) ', prof num = ' num2str(jj)])
%         linkaxes([ax5 ax4 ax3 ax2 ax1],'y')
        prompt = '0 = skip, 1 = pass, 2 = fail, 3 = questionable';
        mld_input = input(prompt)
        mld_check(jj) = mld_input;
        
          if mld_input == 0
              mld(jj) = NaN;
          elseif mld_input == 1
              mld(jj) = MLchl_db(jj);
          elseif mld_input == 2
              mld(jj) = input('user picked MLD') 
          elseif mld_input == 3
              mld(jj) = NaN;
          end
     end
end
%% To blend with Glider data

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load mld_visual_check.mat
load glider_MLDs.mat % with cleaned up temp MLD
%%

wfp_mld = mld;
wfp_dt = mld_dt;

glid_mld = glider_mld_cleaned(:,2); %This data was visually brushed and cleaned
glid_dt = glider_mld_cleaned(:,1);

dt0 = [wfp_dt; glid_dt];
mld0 = [wfp_mld; glid_mld];

% Remove NaN times from dt and mld
ind = find(isnan(dt0));
dt0(ind) = []; mld0(ind) = []; 


[dt,b] = sort(dt0);
mld_db = mld0(b);

%%
figure
plot(wfp_dt,wfp_mld,'.')
hold on
plot(glid_dt,glid_mld,'.')
axis ij
grid on; datetick
ylabel('MLD (db)')
%%
figure
plot(dt,mld_db,'.')
axis ij; grid on
datetick
ylabel('MLD (db)')
title('Preliminary Finalized MLD')