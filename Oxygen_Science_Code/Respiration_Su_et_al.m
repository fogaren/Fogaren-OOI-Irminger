%% Playing with WFP data and buoyancy frequency determined MLD 
clearvars
close all
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Sept2023')
load('wfpmerge_output.mat')
wfp_prs = [150:1:2600];

%% This method seems to work well when there is a strong seasonal signal in the DO record
% Aka the upper water column
% Should use the MLD product to determine the deeper layer and then use the
% whole unmixed time period to calculate rate and p value 


time_redo = wggmerge.time(1):(20/24):wggmerge.time(end);

wggmerge.year = year(wggmerge.time);

DOresp_rate_umolkg_day =[];
b_umolkg = [];
p_value = [];
R2 = [];
resp_length_days = []; 
DOresp_season_umolkg = []; % rate (slope) *resp_days 

for yr = 1:7 % Deployment year 
    ind_yr = find(wggmerge.year == yr + 2014);
    nxt_yr = find(wggmerge.year == yr + 2015);

    for z = 1000 % Depth to start at 

        z_ind = find(wfp_prs == z); % Finds the index of that depth
        nan_ind = ~isnan(wggmerge.doxy(z_ind,:));
        vq = interp1(wggmerge.time(nan_ind),wggmerge.doxy(z_ind,nan_ind),wggmerge.time);
        vq = interp1(wggmerge.time(nan_ind),wggmerge.doxy(z_ind,nan_ind),time_redo);
        yy1 = smooth(time_redo,vq,0.1,'loess');

    
            [~,yr_max] = max(yy1(ind_yr));
        dt_yr_max = wggmerge.time(ind_yr(yr_max));
        dt_yr_max_ind = find(wggmerge.time == dt_yr_max);

        [~,nxt_yr_max] = max(yy1(nxt_yr));

        [~,yr_min] = min(yy1(ind_yr(yr_max):nxt_yr(nxt_yr_max)));
        dt_dum = wggmerge.time(ind_yr(yr_max):nxt_yr(nxt_yr_max));
        dt_yr_min = dt_dum(yr_min);
        dt_yr_min_ind = find(wggmerge.time == dt_yr_min);
        
        dt_days = wggmerge.time(dt_yr_max_ind:dt_yr_min_ind) - wggmerge.time(dt_yr_max_ind);

        figure
        plot(wggmerge.time,wggmerge.doxy(z_ind,:),'.')
        hold on
        plot(wggmerge.time,yy1,'Linewidth',1.5)
        plot(wggmerge.time(dt_yr_max_ind),yy1(dt_yr_max_ind),'ro')
        plot(wggmerge.time(dt_yr_min_ind),yy1(dt_yr_min_ind),'ro')
        datetick
        title(num2str(z))
    
        figure
        plot(dt_days,wggmerge.doxy(z_ind,dt_yr_max_ind:dt_yr_min_ind),'ok')
%         hold on
%         plot(wggmerge.time(yr_max-50:yr_min+50),wggmerge.doxy(z,yr_max-50:yr_min+50),'.','MarkerSize',20)
    
        mdl = fitlm(dt_days,wggmerge.doxy(z_ind,dt_yr_max_ind:dt_yr_min_ind));
        
        % Stores them by actual depth 
        DOresp_rate_umolkg_day{yr}(z) = mdl.Coefficients.Estimate(2);
        b_umolkg{yr}(z) = mdl.Coefficients.Estimate(1);
        p_value{yr}(z) = mdl.Coefficients.pValue(2);
        R2{yr}(z) = mdl.Rsquared.Ordinary;
        resp_length_days{yr}(z) = max(dt_days); 
        DOresp_season_umolkg{yr}(z) = mdl.Coefficients.Estimate(2)*max(dt_days); % rate (slope) *resp_days 
        

    end 
end
    

%%
for yr = 6
    figure(1)
    plot(DOresp_rate_umolkg_day{yr},1:max(z))
    hold on
    axis ij
    ylabel('Pressure (db)')
    xlabel('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
    title('Respiration Rate during D_p_r_o_d')
    
    figure(2)
    plot(resp_length_days{yr},1:max(z))
    hold on
    axis ij
    ylabel('Pressure (db)')
    xlabel('Length of D_p_r_o_d (days)')
    title('D_p_r_o_d length')
    
    figure(3)
    plot(DOresp_rate_umolkg_day{yr}.*resp_length_days{yr}*-0.69,1:max(z))
    hold on
    axis ij
    ylabel('Pressure (db)')
    xlabel('Exported Carbon (\mumol kg^-^1)')
    title('Carbon Respired during D_p_r_o_d')
end
 
   %% This method seems to work well when there is a strong seasonal signal in the DO record
% Aka the upper water column
% Should use the MLD product to determine the deeper layer and then use the
% whole unmixed time period to calculate rate and p value 


time_redo = wggmerge.time(1):(20/24):wggmerge.time(end);

wggmerge.year = year(time_redo);

DOresp_rate_umolkg_day =[];
b_umolkg = [];
p_value = [];
R2 = [];
resp_length_days = []; 
DOresp_season_umolkg = []; % rate (slope) *resp_days 

for yr = 1%:7 % Deployment year 
    ind_yr = find(wggmerge.year == yr + 2014);
    nxt_yr = find(wggmerge.year == yr + 2015);

    for z = 1000 % Depth to start at 

        z_ind = find(wfp_prs == z); % Finds the index of that depth
        nan_ind = ~isnan(wggmerge.doxy(z_ind,:));
        vq = interp1(wggmerge.time(nan_ind),wggmerge.doxy(z_ind,nan_ind),wggmerge.time);
        vq = interp1(wggmerge.time(nan_ind),wggmerge.doxy(z_ind,nan_ind),time_redo);
        yy1 = smooth(time_redo,vq,0.05,'loess');
        yy2 = smooth(wggmerge.time,wggmerge.doxy(z_ind,:),0.2,'loess');

    
            [~,yr_max] = max(yy1(ind_yr));
%         dt_yr_max = wggmerge.time(ind_yr(yr_max));
        dt_yr_max = time_redo(ind_yr(yr_max));
        [~,dt_yr_max_ind] = min(abs(wggmerge.time - dt_yr_max));

        [~,nxt_yr_max] = max(yy1(nxt_yr));

        [~,yr_min] = min(yy1(ind_yr(yr_max):nxt_yr(nxt_yr_max)));
%         dt_dum = wggmerge.time(ind_yr(yr_max):nxt_yr(nxt_yr_max));
        dt_dum = time_redo(ind_yr(yr_max):nxt_yr(nxt_yr_max));
        dt_yr_min = dt_dum(yr_min);
        [~,dt_yr_min_ind] = min(abs(wggmerge.time - dt_yr_min));
        
        dt_days = wggmerge.time(dt_yr_max_ind:dt_yr_min_ind) - wggmerge.time(dt_yr_max_ind);

        figure
        plot(wggmerge.time,wggmerge.doxy(z_ind,:),'.')
        hold on
        plot(time_redo,yy1,'Linewidth',1.5)
%         plot(wggmerge.time,yy2,'Linewidth',1.5)
%         plot(wggmerge.time(dt_yr_max_ind),wggmerge.doxy(z_ind,dt_yr_max_ind),'c*')
%         plot(wggmerge.time(dt_yr_min_ind),wggmerge.doxy(z_ind,dt_yr_min_ind),'c*')
        datetick
        title(num2str(z))
    
        figure
        plot(dt_days,wggmerge.doxy(z_ind,dt_yr_max_ind:dt_yr_min_ind),'ok')
%         hold on
%         plot(wggmerge.time(yr_max-50:yr_min+50),wggmerge.doxy(z,yr_max-50:yr_min+50),'.','MarkerSize',20)
    
        mdl = fitlm(dt_days,wggmerge.doxy(z_ind,dt_yr_max_ind:dt_yr_min_ind));
        
        % Stores them by actual depth 
        DOresp_rate_umolkg_day{yr}(z) = mdl.Coefficients.Estimate(2);
        b_umolkg{yr}(z) = mdl.Coefficients.Estimate(1);
        p_value{yr}(z) = mdl.Coefficients.pValue(2);
        R2{yr}(z) = mdl.Rsquared.Ordinary;
        resp_length_days{yr}(z) = max(dt_days); 
        DOresp_season_umolkg{yr}(z) = mdl.Coefficients.Estimate(2)*max(dt_days); % rate (slope) *resp_days 
        

    end 
end
    