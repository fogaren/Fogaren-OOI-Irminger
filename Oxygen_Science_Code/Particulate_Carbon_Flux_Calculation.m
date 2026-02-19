% From Briggs 2011

% aggregate POC(z) = bbpspike signal * 35400 mg C m-2 * z/100m^-0.28
% aggregat POC flux = aggregate POC * sinking rate of 75 m/d


% 0.13e-3*35400*75*2^-0.28 
% %(12.011 g C /mol C)
% 0.75e-3*35400*56/1000/12.01*10 
bbl_z = 50:2000;
bblfit = curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(bbl_z));

% If want to assume number of days for bloom length from peak bloom 
sinkingspeed = SR_allpulses_mean; % m/d bulk speed calculated in Large Particle_Calcs_Streamlined.
bloomlength = 60; % d, for number of bloom days in a year
POCmgCm3 = 35400*bblfit;
POCmgCm2d = POCmgCm3*sinkingspeed;
POCmolCm2d = POCmgCm2d/1000/12.01;
POCmolCm2yr = POCmolCm2d*bloomlength;
bblfit(bbl_z == 275)
bblfit(bbl_z == 1000)
POCmgCm2d_1000m = POCmgCm3(bbl_z == 1000)*sinkingspeed
POCmolCm2d_1000m = POCmgCm2d(bbl_z == 1000)/1000/12.01
POCmgCm2pulse_1000m = POCmgCm3(bbl_z == 1000)*sinkingspeed*bloomlength
POCmolCm2pulse_1000m = POCmgCm2d(bbl_z == 1000)/1000/12.01*bloomlength

figure
set(gcf,'position',[100,100,775,400])
subplot(1,3,1)
plot(bblfit,bbl_z,'k','Linewidth',2)
xlabel('b_b_l (m^-^1)')
axis ij; grid on
ylabel('depth (m)')
xlabel('$\overline{b_{bl}}$ (m$^{{-}1}$)','interpreter','latex','Fontsize',14,'FontName','helvetica')
title('Spike Size')
ax = gca;
ax.FontSize = 12;

subplot(1,3,2)
plot(POCmgCm3,bbl_z,'k','Linewidth',2)
axis ij; grid on
xlabel('POC (mg C m^-^3)')
title('POC concentration')
ax = gca;
ax.FontSize = 12;

subplot(1,3,3)
plot(POCmgCm2d,bbl_z,'k','Linewidth',2)
axis ij; grid on
xlabel('POC (mg C m^-^2 d^-^1)')
title('POC flux')
ax = gca;
ax.FontSize = 12;
%% Same depth bin for all years 
target_depth_bin = 1375; % Depth of bin you want to use for calculations
bin_ind = find(wfpmerge.sinkingpulsedepths == target_depth_bin); 

% 95% of the particle size? Should use mean value?
for j = 1:7
    yrind{j} = find(year(wfpmerge.profile_start) == j+2014);
end

figure(3)
set(gcf,'position',[100,100,1250,600])
% size metric set in LargeParticle_Calcs_Streamlined.m
pn = 1:7; % pulse number years 
for j = 1:length(pn)
    spikes = wfpmerge.binned_filteredspikes(yrind{pn(j)},bin_ind,size_metric);
    spikes_nonans = spikes(~isnan(spikes));
    dt_nonans = wfpmerge.profile_start(yrind{pn(j)}(~isnan(spikes)));
    subplot(4,2,j)
    semilogy(wfpmerge.profile_start(yrind{pn(j)}),wfpmerge.binned_filteredspikes(yrind{pn(j)},bin_ind,size_metric),'.','MarkerSize',8)
    hold on
    semilogy(dt_nonans,smooth(spikes_nonans,.09),'.','MarkerSize',10) 
    xlim([datenum(2014+pn(j),01,01) datenum(2015+pn(j),01,01)])
    ylim([4.3898e-06 2.3167e-04])
    ylim([4.3898e-06 1e-04])
    datetick
    ylabel('log$_{10}$ $\overline{b_{bl}}$ (m$^{{-}1}$)','interpreter','latex','Fontsize',14,'FontName','Arial','FontWeight','bold')
    % title([num2str(2014+pn(j)) ': ' num2str(target_depth_bin) ' db'])
    title([num2str(2014+pn(j))])
    grid on; box on
end
%%
bin_275 = find(wfpmerge.sinkingpulsedepths == 225);
spikes_275 = wfpmerge.binned_filteredspikes(:,bin_275,size_metric);
spikes_nonans_275 = spikes_275(~isnan(spikes_275));
dt_nonans_275 = wfpmerge.profile_start(~isnan(spikes_275));

dt_275 = datenum(2015,03,01):1:datenum(2022,03,16);
poc_eq_275 = smooth(spikes_nonans_275,.0075)*35400*sinkingspeed;
poc_275 = interp1(dt_nonans_275,poc_eq_275,dt_275,'Linear');

spikes = wfpmerge.binned_filteredspikes(:,bin_ind,size_metric);
spikes_nonans = spikes(~isnan(spikes));
dt_nonans = wfpmerge.profile_start(~isnan(spikes));

dt = datenum(2015,03,01):1:datenum(2022,03,16);
poc_eq = smooth(spikes_nonans,.0075)*35400*sinkingspeed;
poc = interp1(dt_nonans,poc_eq,dt,'Linear');

figure
plot(dt_nonans,spikes_nonans*35400*sinkingspeed,'.')
hold on
plot(dt_nonans, poc_eq,'.')
plot(dt,poc);

plot(dt_nonans_275,spikes_nonans_275*35400*sinkingspeed,'.')
plot(dt_nonans_275, poc_eq_275,'.')
plot(dt_275,poc_275);

%%
for j = 1:length(pn)
    remin_start = find(dt >= blended_mld_daily_all.dn(mld_max_ind(j)),1);
    remin_end = find(dt >= blended_mld_daily_all.dn(mld_max_ind(j+1)),1);
    remin_yrind = remin_start:remin_end-1;
    remin_yrinddt = datetime(dt(remin_yrind),'ConvertFrom','datenum');
    doy = day(remin_yrinddt,'dayofyear');
    
    June01_ind = find(dt >= datenum(pn(j)+2014,06,01),1);
    Sept15_ind = find(dt >= datenum(pn(j)+2014,09,15),1);
    
    figure(100)

    % % plot(dt_nonans,spikes_nonans*35400*sinkingspeed,'.','MarkerSize',10) 
    % % % plot(dt(remin_yrind),poc(remin_yrind),'Linewidth',1.4)
    % % hold on
    % plot(dt_nonans,smooth(spikes_nonans*35400*sinkingspeed,0.0075),'.'); hold on
    % plot(doy,smooth(spikes_nonans*35400*sinkingspeed,0.0075),'.'); hold on
    % % xlim([dt(remin_start) dt(remin_end)])
    % % datetick('x','Keeplimits')
    % title('Daily POC flux')
    % ylabel('mg C m^-^2 d^-^1')
    % sgtitle(['Remin Yr ' num2str(j) ': ' num2str(year(dt(remin_start))) '-' num2str(year(dt(remin_end)))])
    % grid on; box on
    
    % ax2 = subplot(2,1,2);
    % plot(dt(remin_yrind),cumsum(poc(remin_yrind))/1000/12.01,'Linewidth',2); hold on
    % datetick
    plot(doy,cumsum(poc(remin_yrind))/1000/12.01,'Linewidth',2); hold on
    grid on
    ylabel('mol C m^2')
    title('POC flux since beginning of remin. year')
    % linkaxes([ax2 ax1],'x')
    % xlim([dt(remin_start) dt(remin_end)])
    
    POCat_target_start = max(cumsum(poc(remin_yrind(1):June01_ind))/1000/12.01)
    POCat_target_end = max(cumsum(poc(remin_yrind(1):Sept15_ind))/1000/12.01)
    POC_at_target(j) = POCat_target_end - POCat_target_start;

    POCat_remin_end(j) = max(cumsum(poc(remin_yrind))/1000/12.01)

    POCat_275_start = max(cumsum(poc_275(remin_yrind(1):June01_ind))/1000/12.01)
    POCat_275_end = max(cumsum(poc_275(remin_yrind(1):Sept15_ind))/1000/12.01)
    POC_at_275(j) = POCat_275_end - POCat_275_start;

    POCat_275_remin_end(j) = max(cumsum(poc_275(remin_yrind))/1000/12.01)

end

POC_at_target_June1_Sept15 = POC_at_target';
POC_at_target_June1_Sept15(5) = NaN;
POC_at_target_June1_Sept15(6) = NaN;

nanmean(POC_at_target_June1_Sept15)
nanstd(POC_at_target_June1_Sept15)

POCat_remin_end = POCat_remin_end';
POCat_remin_end(5) = NaN;
POCat_remin_end(6) = NaN;

nanmean(POCat_remin_end)
nanstd(POCat_remin_end)

POC_at_275_June1_Sept15 = POC_at_275';
POC_at_275_June1_Sept15(5) = NaN;
POC_at_275_June1_Sept15(6) = NaN;

nanmean(POC_at_275_June1_Sept15)
nanstd(POC_at_275_June1_Sept15)

POCat_275_remin_end = POCat_275_remin_end';
POCat_275_remin_end(5) = NaN;
POCat_275_remin_end(6) = NaN;

nanmean(POCat_275_remin_end)
nanstd(POCat_275_remin_end)


%%
% Remineralization year daily flux and cumulative flux at target depth bin 
for j = 1:length(pn)

    % spikes = wfpmerge.binned_filteredspikes(:,bin_ind,size_metric);
    % spikes_nonans = spikes(~isnan(spikes));
    % dt_nonans = wfpmerge.profile_start(~isnan(spikes));

    remin_start = find(dt >= blended_mld_daily_all.dn(mld_max_ind(j)),1);
    remin_end = find(dt >= blended_mld_daily_all.dn(mld_max_ind(j+1)),1);
    remin_yrind = remin_start:remin_end-1;
    [y,m,d] = ymd(datetime(dt(remin_yrind),'ConvertFrom','datenum'));

    dt_sameyr = datetime(y-j,m,d); %For plotting purposes 
    

    if j == 5 
    
    elseif j == 6

    else
        figure(401)
        ax1 = subplot(2,1,1);
        % plot(dt_nonans,spikes_nonans*35400*sinkingspeed,'.','MarkerSize',10)
        % plot(day(datetime(dt(remin_yrind),'ConvertFrom','datenum'),'dayofyear'),poc(remin_yrind),'Color',colorblind(j,:),'Linewidth',2)
        plot(dt_sameyr,poc(remin_yrind),'Color',colorblind(pn(j),:),'Linewidth',2)
        hold on
        plot(dt_sameyr,poc_275(remin_yrind),'--','Color',colorblind(pn(j),:),'Linewidth',2)
        % plot(dt_nonans,smooth(spikes_nonans*35400*sinkingspeed,0.0075),'.')
        xlim([datetime(2014,02,01) datetime(2015,05,01)])
        datetick('x','Keeplimits')
        title(['Daily POC flux at target depth of ' num2str(target_depth_bin) ' m'])
        ylabel('mg C m^-^2 d^-^1')
        grid on; box on
        ax1.FontSize = 12;
    
        ax2 = subplot(2,1,2);
        plot(dt_sameyr,cumsum(poc(remin_yrind))/1000/12.01,'Color',colorblind(pn(j),:),'Linewidth',2)
        hold on
        plot(dt_sameyr,cumsum(poc_275(remin_yrind))/1000/12.01,'--','Color',colorblind(pn(j),:),'Linewidth',2)
        datetick
        grid on
        ylabel('mol C m^-^2')
        title(['POC flux at ' num2str(target_depth_bin) ' m since beginning of remin. year'])
        ax2.FontSize = 12;
        % ylim([0 2.5])
        xlim([datetime(2014,02,01) datetime(2015,05,01)])
    end

    subplot(2,1,1)
    l = legend('1: 2015-2016','2: 2016-2017','3: 2017-2018','4: 2018-2019','7: 2021-2022','Location','NE');
    l.FontSize = 10;
    title(l,'Remin. Year')

end
%%
% March 1 to March 1 daily and cumulative 
POCmarchmarch = NaN(length(pn),1);
figure
for j = 1:length(pn)

    % spikes = wfpmerge.binned_filteredspikes(:,bin_ind,size_metric);
    % spikes_nonans = spikes(~isnan(spikes));
    % dt_nonans = wfpmerge.profile_start(~isnan(spikes));

    remin_start = find(dt >= datenum(2014+j,03,01),1);
    % if j == 7
    %     remin_end = length(dt);
    % else
        remin_end = find(dt >= datenum(2015+j,03,01),1);
    % end
    
    remin_yrind = remin_start:remin_end-1;
    [y,m,d] = ymd(datetime(dt(remin_yrind),'ConvertFrom','datenum'));

    dt_sameyr = datetime(y-j,m,d); %For plotting purposes 

    
 
    if j == 5 
    
    elseif j == 6

    else
    figure(401)
    ax1 = subplot(2,1,1);
    % plot(dt_nonans,spikes_nonans*35400*sinkingspeed,'.','MarkerSize',10) 
    % plot(day(datetime(dt(remin_yrind),'ConvertFrom','datenum'),'dayofyear'),poc(remin_yrind),'Color',colorblind(j,:),'Linewidth',2)
    plot(dt_sameyr,poc(remin_yrind),'Color',colorblind(pn(j),:),'Linewidth',2)
    hold on
    % plot(dt_nonans,smooth(spikes_nonans*35400*sinkingspeed,0.0075),'.')
    xlim([datetime(2014,02,15) datetime(2015,03,15)])
    datetick('x','Keeplimits')
    title(['Daily POC flux at target depth of ' num2str(target_depth_bin) ' m'])
    ylabel('mg C m^-^2 d^-^1')
    grid on; box on
    ax1.FontSize = 12;


    ax2 = subplot(2,1,2);
        if j == 1
            plot(dt_sameyr,cumsum(poc(remin_yrind))/1000/12.01,'Color',colorblind(pn(j),:),'Linewidth',2.5); hold on
        else
            plot(dt_sameyr,cumsum(poc(remin_yrind))/1000/12.01,'Color',colorblind(pn(j),:),'Linewidth',2); hold on
        end
    hold on
    datetick
    grid on
    ylabel('mol C m^-^2')
    title(['POC flux at ' num2str(target_depth_bin) ' m since March 1'])
    ax2.FontSize = 12;
    % ylim([0 2.5])
    xlim([datetime(2014,02,15) datetime(2015,03,15)])
    
        if j == 7
            ind_7 = max(find(~isnan(poc(remin_yrind)))); % Because WFP gets stuck and want to compare 225 bin to 1375 bin and timeseries are different lenghts 
        end
        POCmarchmarch(j) = max(cumsum(poc(remin_yrind))/1000/12.01);

    subplot(2,1,2)
    l = legend('1: 2015-2016','2: 2016-2017','3: 2017-2018','4: 2018-2019','7: 2021-2022','Location','NE');
    l.FontSize = 10;
    title(l,'Year')
    end

end

POCmarchmarch = POCmarchmarch';
POCmarchmarch(5) = NaN;
POCmarchmarch(6) = NaN;

nanmean(POCmarchmarch)
nanstd(POCmarchmarch)

%%
% March 1 to March 1 daily and cumulative 
POCmarchmarch_275 = NaN(length(pn),1);

for j = 1:length(pn)

    remin_start = find(dt >= datenum(2014+j,03,01),1);
    remin_end = find(dt >= datenum(2015+j,03,01),1);
    
    remin_yrind = remin_start:remin_end-1;
    [y,m,d] = ymd(datetime(dt(remin_yrind),'ConvertFrom','datenum'));

    dt_sameyr = datetime(y-j,m,d); %For plotting purposes 
 
    if j == 5 
    
    elseif j == 6

    else
    figure
    ax1 = subplot(2,1,1);
    plot(dt_sameyr,poc_275(remin_yrind),'k','Linewidth',2); hold on
    plot(dt_sameyr,poc(remin_yrind),'Color',colorblind(pn(j),:),'Linewidth',2)
    xlim([datetime(2014,02,15) datetime(2015,03,15)])
    datetick('x','Keeplimits')
    title(['Daily POC flux for ' num2str(j+2014) ' - ' num2str(j+2015)])
    ylabel('mg C m^-^2 d^-^1')
    grid on; box on
    ax1.FontSize = 12;


    ax2 = subplot(2,1,2);
    plot(dt_sameyr,cumsum(poc_275(remin_yrind))/1000/12.01,'k','Linewidth',2); hold on
    plot(dt_sameyr,cumsum(poc(remin_yrind))/1000/12.01,'Color',colorblind(pn(j),:),'Linewidth',2.5);
    datetick
    grid on
    ylabel('mol C m^-^2')
    title(['POC flux since March 1'])
    ax2.FontSize = 12;
    xlim([datetime(2014,02,15) datetime(2015,03,15)])
    
    if j == 7
        POCmarchmarch_275(j) = max(cumsum(poc_275(remin_yrind(1:ind_7)))/1000/12.01);
    else
        POCmarchmarch_275(j) = max(cumsum(poc_275(remin_yrind))/1000/12.01);
    end
    end

    subplot(2,1,1)
    l = legend('at 225 m','at 1375 m','Location','NE');
    l.FontSize = 10;

end

POCmarchmarch_275 = POCmarchmarch_275';
POCmarchmarch_275(5) = NaN;
POCmarchmarch_275(6) = NaN;

nanmean(POCmarchmarch_275)
nanstd(POCmarchmarch_275)

diff_bt_depths = POCmarchmarch_275' - POCmarchmarch'
%% =======================================================================
%  Different depth bin for all years 
target_depth_bin_by_yr = [1025 1275 975 1275 425 675 1325]; % Depth of bin you want to use for calculations
bin_ind = [];
yrind = [];
% 95% of the particle size? Should use mean value?
for j = 1:7
    yrind{j} = find(year(wfpmerge.profile_start) == j+2014);
    bin_ind{j} = find(wfpmerge.sinkingpulsedepths == target_depth_bin_by_yr(j)); 
    bin_275 = find(wfpmerge.sinkingpulsedepths == 275);
end

figure(1)
set(gcf,'position',[100,100,1250,600])
% size metric set in LargeParticle_Calcs_Streamlined.m
pn = [1:7]; % pulse number years 
for j = 1:length(pn)
    spikes = wfpmerge.binned_filteredspikes(yrind{pn(j)},bin_ind{j},size_metric);
    spikes_nonans = spikes(~isnan(spikes));
    dt_nonans = wfpmerge.profile_start(yrind{pn(j)}(~isnan(spikes)));

    subplot(4,2,j)
    % semilogy(wfpmerge.profile_start(yrind{pn(j)}),wfpmerge.binned_filteredspikes(yrind{pn(j)},bin_ind{j},size_metric),'.','MarkerSize',8)
    semilogy(dt_nonans,smooth(spikes_nonans,.09),'.','MarkerSize',10) 
    hold on
    xlim([datenum(2014+pn(j),01,01) datenum(2015+pn(j),01,01)])
    % ylim([4.3898e-06 2.3167e-04])
    ylim([4.3898e-06 1e-04])
    datetick
    ylabel('log$_{10}$ $\overline{b_{bl}}$ (m$^{{-}1}$)','interpreter','latex','Fontsize',14,'FontName','Arial','FontWeight','bold')
    % title([num2str(2014+pn(j)) ': ' num2str(target_depth_bin_by_yr(j)) ' db'])
    title([num2str(2014+pn(j))])
    grid on
end
%% With dynamic target depth bin 
pn = [1:7]; % for seven remineralization years 
clear bin_ind poc poc_eq spikes spikes_nonans dt_nonans

for j = 1:length(pn)

    bin_ind = find(wfpmerge.sinkingpulsedepths == target_depth_bin_by_yr(j)); 
    
    spikes = wfpmerge.binned_filteredspikes(:,bin_ind,size_metric);
    spikes_nonans{j} = spikes(~isnan(spikes));
    dt_nonans{j} = wfpmerge.profile_start(~isnan(spikes));
    
    dt = datenum(2015,03,01):1:datenum(2022,03,16);
    poc_eq{j} = smooth(spikes_nonans{j},.0075)*35400*sinkingspeed;
    poc{j} = interp1(dt_nonans{j},poc_eq{j},dt,'Linear');
    
    figure
    plot(dt_nonans{j},spikes_nonans{j}*35400*sinkingspeed,'.')
    hold on
    plot(dt_nonans{j}, poc_eq{j},'.')
    plot(dt,poc{j});
    title([num2str(2014+pn(j)) ': ' num2str(target_depth_bin_by_yr(j))])
end
 %%   

for j = 1:length(pn)
    remin_start = find(dt >= blended_mld_daily_all.dn(mld_max_ind(j)),1);
    remin_end = find(dt >= blended_mld_daily_all.dn(mld_max_ind(j+1)),1);
    remin_yrind = remin_start:remin_end-1;
    
    June01_ind = find(dt >= datenum(pn(j)+2014,06,01),1);
    Sept15_ind = find(dt >= datenum(pn(j)+2014,09,15),1);
    
    figure
    ax1 = subplot(2,1,1);
    plot(dt_nonans{j},spikes_nonans{j}*35400*sinkingspeed,'.','MarkerSize',10) 
    plot(dt(remin_yrind),poc{j}(remin_yrind),'Linewidth',1.4)
    hold on
    plot(dt_nonans{j},smooth(spikes_nonans{j}*35400*sinkingspeed,0.0075),'.')
    xlim([dt(remin_start) dt(remin_end)])
    datetick('x','Keeplimits')
    title('Daily POC flux')
    ylabel('mg C m^-^2 d^-^1')
    sgtitle(['Remin Yr ' num2str(j) ': ' num2str(year(dt(remin_start))) '-' num2str(year(dt(remin_end)))])
    grid on; box on
    
    ax2 = subplot(2,1,2);
    plot(dt(remin_yrind),cumsum(poc{j}(remin_yrind))/1000/12.01,'Linewidth',2)
    datetick
    grid on
    ylabel('mol C m^2')
    title('POC flux since beginning of remin. year')
    % linkaxes([ax2 ax1],'x')
    xlim([dt(remin_start) dt(remin_end)])
    
    POCatremin0_start = max(cumsum(poc{j}(remin_yrind(1):June01_ind))/1000/12.01)
    POCatremin0_end = max(cumsum(poc{j}(remin_yrind(1):Sept15_ind))/1000/12.01)
    POC_atremin0(j) = POCatremin0_end - POCatremin0_start;

    POCmarchmarch_remin0(j) = max(cumsum(poc{j}(remin_yrind))/1000/12.01);

end
    
    POC_atremin0_June1_Sept15 = POC_atremin0';
    POC_atremin0_June1_Sept15(5) = NaN;
    POC_atremin0_June1_Sept15(6) = NaN;
    POCmarchmarch_remin0(5) = NaN;
    POCmarchmarch_remin0(6) = NaN;
    
    nanmean(POC_atremin0_June1_Sept15)
    nanstd(POC_atremin0_June1_Sept15)

diff_bt_275_remin0 = POCmarchmarch_275' - POCmarchmarch_remin0'    
%% March 1 to March 1 daily and cumulative with dynamic depth bins 
pn = [1:7]; % pulse number years 
for j = 1:length(pn)

    bin_ind = find(wfpmerge.sinkingpulsedepths == target_depth_bin_by_yr(j)); 

    % spikes = wfpmerge.binned_filteredspikes(:,bin_ind,size_metric);
    % spikes_nonans = spikes(~isnan(spikes));
    % dt_nonans = wfpmerge.profile_start(~isnan(spikes));

    remin_start = find(dt >= datenum(2014+j,03,01),1);
    % if j == 7
    %     remin_end = length(dt);
    % else
        remin_end = find(dt >= datenum(2015+j,03,01),1);
    % end
    
    remin_yrind = remin_start:remin_end-1;
    [y,m,d] = ymd(datetime(dt(remin_yrind),'ConvertFrom','datenum'));

    dt_sameyr = datetime(y-j,m,d); %For plotting purposes 
    
    figure(403)
    if j == 5 
    
    elseif j == 6

    else

    ax1 = subplot(2,1,1);
    % plot(dt_nonans,spikes_nonans*35400*sinkingspeed,'.','MarkerSize',10) 
    % plot(day(datetime(dt(remin_yrind),'ConvertFrom','datenum'),'dayofyear'),poc(remin_yrind),'Color',colorblind(j,:),'Linewidth',2)
    plot(dt_sameyr,poc{j}(remin_yrind),'Color',colorblind(pn(j),:),'Linewidth',2)
    hold on
    % plot(dt_nonans,smooth(spikes_nonans*35400*sinkingspeed,0.0075),'.')
    xlim([datetime(2014,02,15) datetime(2015,03,15)])
    datetick('x','Keeplimits')
    title(['Daily POC flux at Z_r_e_m_i_n_0 m '])
    ylabel('mg C m^-^2 d^-^1')
    grid on; box on
    ax1.FontSize = 12;

    ax2 = subplot(2,1,2);
    if j == 1
        plot(dt_sameyr,cumsum(poc{j}(remin_yrind))/1000/12.01,'Color',colorblind(pn(j),:),'Linewidth',2.5)
    else
        plot(dt_sameyr,cumsum(poc{j}(remin_yrind))/1000/12.01,'Color',colorblind(pn(j),:),'Linewidth',2)
    end
    hold on
    datetick
    grid on
    ylabel('mol C m^-^2')
    title(['POC flux at Z_r_e_m_i_n_0 m since March 1'])
    ax2.FontSize = 12;
    % ylim([0 2.5])
    xlim([datetime(2014,02,15) datetime(2015,03,15)])
    end

    subplot(2,1,1)
    l = legend('1: 2015-2016','2: 2016-2017','3: 2017-2018','4: 2018-2019','7: 2021-2022','Location','NE');
    l.FontSize = 10;
    title(l,'Year')

end

%%
figure
for j = 1:7
    if j == 5 
    
    elseif j == 6

    else
        subplot(1,2,1)
        plot(C_total_remin{j}(200),POCmarchmarch_275(j) - POCmarchmarch(j),'.','MarkerSize',30,'Color',colorblind(pn(j),:))
        hold on; grid on
        l = legend('1: 2015-2016','2: 2016-2017','3: 2017-2018','4: 2018-2019','7: 2021-2022','Location','SE');
        l.FontSize = 10;
        title(l,'Year')
        xlabel('C_r_e_m_i_n 200:Z_r_e_m_i_n_0 (mol C m^-^2 yr^-^1)')
        ylabel('POC at 1400 - 200 (mol C m^-^2 yr^-^1)')
        subplot(1,2,2)
        plot(C_total_remin{j}(200),POCmarchmarch_275(j) - POCmarchmarch_remin0(j),'.','MarkerSize',30,'Color',colorblind(pn(j),:))
        hold on; grid on
        ylabel('POC at Z_r_e_m_i_n_0 - 200 (mol C m^-^2 yr^-^1)')
        xlabel('C_r_e_m_i_n 200:Z_r_e_m_i_n_0 (mol C m^-^2 yr^-^1)')

    end
end