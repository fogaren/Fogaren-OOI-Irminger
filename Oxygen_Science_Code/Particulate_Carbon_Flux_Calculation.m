% From Briggs 2011

% aggregate POC(z) = bbpspike signal * 35400 mg C m-2 * z/100m^-0.28
% aggregat POC flux = aggregate POC * sinking rate of 75 m/d


% 0.13e-3*35400*75*2^-0.28 
% %(12.011 g C /mol C)
% 0.75e-3*35400*56/1000/12.01*10 
bbl_z = 50:2000;
bblfit = curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(bbl_z));

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
%%
% 95% of the particle size? Should use mean value?
for j = 1:7
    yrind{j} = find(year(wfpmerge.profile_start) == j+2014);
end
bin_ind = find(wfpmerge.sinkingpulsedepths == 1025); 
% figure
% set(gcf,'position',[100,100,1100,1700])
% % size metric set in LargeParticle_Calcs_Streamlined.m 
% for j = 1:7
%     spikes = wfpmerge.binned_filteredspikes(yrind{j},bin_ind,size_metric);
%     spikes_nonans = spikes(~isnan(spikes));
%     dt_nonans = wfpmerge.profile_start(yrind{j}(~isnan(spikes)));
%     subplot(4,2,j)
%     semilogy(wfpmerge.profile_start(yrind{j}),wfpmerge.binned_filteredspikes(yrind{j},bin_ind,size_metric),'.','MarkerSize',8)
%     hold on
%     semilogy(dt_nonans,smooth(spikes_nonans,.09),'.','MarkerSize',10) 
%     xlim([datenum(2014+j,01,01) datenum(2015+j,01,01)])
%     ylim([4.3898e-06 2.3167e-04])
%     datetick
%     ylabel('log_1_0 b_b_l (m^-^1)')
%     title(string(2014+j))
%     sgtitle('b_b_l for 1000 to 1050 m depth bin')
%     grid on
% end

figure
set(gcf,'position',[100,100,1250,600])
% size metric set in LargeParticle_Calcs_Streamlined.m
pn = [1 2 3 4 7]; % pulse number years 
for j = 1:length(pn)
    spikes = wfpmerge.binned_filteredspikes(yrind{pn(j)},bin_ind,size_metric);
    spikes_nonans = spikes(~isnan(spikes));
    dt_nonans = wfpmerge.profile_start(yrind{pn(j)}(~isnan(spikes)));
    subplot(3,2,j)
    semilogy(wfpmerge.profile_start(yrind{pn(j)}),wfpmerge.binned_filteredspikes(yrind{pn(j)},bin_ind,size_metric),'.','MarkerSize',8)
    hold on
    semilogy(dt_nonans,smooth(spikes_nonans,.09),'.','MarkerSize',10) 
    xlim([datenum(2014+pn(j),01,01) datenum(2015+pn(j),01,01)])
    ylim([4.3898e-06 2.3167e-04])
    datetick
    % ylabel('log_1_0 b_b_l (m^-^1)')
    ylabel('log$_{10}$ $\overline{b_{bl}}$ (m$^{{-}1}$)','interpreter','latex','Fontsize',14,'FontName','Arial','FontWeight','bold')
    title(string(2014+pn(j)))
    % sgtitle('b_b_l for 1000 to 1050 m depth bin')
    grid on
end

%%
pn = [1:7]; % for seven remineralization years 

bin_ind = find(wfpmerge.sinkingpulsedepths == 1025); 

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

sinkingspeed = 54;
for j = 1:length(pn)
    remin_start = find(dt >= blended_mld_daily_all.dn(mld_max_ind(j)),1);
    remin_end = find(dt >= blended_mld_daily_all.dn(mld_max_ind(j+1)),1);
    remin_yrind = remin_start:remin_end-1;
    
    June01_ind = find(dt >= datenum(pn(j)+2014,06,01),1);
    Sept15_ind = find(dt >= datenum(pn(j)+2014,09,15),1);
    
    figure
    ax1 = subplot(2,1,1);
    plot(dt_nonans,spikes_nonans*35400*sinkingspeed,'.','MarkerSize',10) 
    plot(dt(remin_yrind),poc(remin_yrind),'Linewidth',1.4)
    hold on
    plot(dt_nonans,smooth(spikes_nonans*35400*sinkingspeed,0.0075),'.')
    xlim([dt(remin_start) dt(remin_end)])
    datetick('x','Keeplimits')
    title('Daily POC flux')
    ylabel('mg C m^-^2 d^-^1')
    sgtitle(['Remin Yr ' num2str(j) ': ' num2str(year(dt(remin_start))) '-' num2str(year(dt(remin_end)))])
    grid on; box on
    
    ax2 = subplot(2,1,2);
    plot(dt(remin_yrind),cumsum(poc(remin_yrind))/1000/12.01,'Linewidth',2)
    datetick
    grid on
    ylabel('mol C m^2')
    title('POC flux since beginning of remin. year')
    % linkaxes([ax2 ax1],'x')
    xlim([dt(remin_start) dt(remin_end)])
    
    POCat2000_start = max(cumsum(poc(remin_yrind(1):June01_ind))/1000/12.01)
    POCat2000_end = max(cumsum(poc(remin_yrind(1):Sept15_ind))/1000/12.01)
    POC_at2000(j) = POCat2000_end - POCat2000_start;

end

POC_at2000_June1_Sept15 = POC_at2000';
POC_at2000_June1_Sept15(5) = NaN;
POC_at2000_June1_Sept15(6) = NaN;

nanmean(POC_at2000_June1_Sept15)
nanstd(POC_at2000_June1_Sept15)

%% Remineralization year daily flux and cumulative flux at 1025 m 
for j = 1:length(pn)

    bin_ind = find(wfpmerge.sinkingpulsedepths == 1025); 

    % spikes = wfpmerge.binned_filteredspikes(:,bin_ind,size_metric);
    % spikes_nonans = spikes(~isnan(spikes));
    % dt_nonans = wfpmerge.profile_start(~isnan(spikes));

    remin_start = find(dt >= blended_mld_daily_all.dn(mld_max_ind(j)),1);
    remin_end = find(dt >= blended_mld_daily_all.dn(mld_max_ind(j+1)),1);
    remin_yrind = remin_start:remin_end-1;
    [y,m,d] = ymd(datetime(dt(remin_yrind),'ConvertFrom','datenum'));

    dt_sameyr = datetime(y-j,m,d); %For plotting purposes 
    
    figure(401)
    if j == 5 
    
    elseif j == 6

    else

    ax1 = subplot(2,1,1);
    % plot(dt_nonans,spikes_nonans*35400*sinkingspeed,'.','MarkerSize',10) 
    % plot(day(datetime(dt(remin_yrind),'ConvertFrom','datenum'),'dayofyear'),poc(remin_yrind),'Color',colorblind(j,:),'Linewidth',2)
    plot(dt_sameyr,poc(remin_yrind),'Color',colorblind(pn(j),:),'Linewidth',2)
    hold on
    % plot(dt_nonans,smooth(spikes_nonans*35400*sinkingspeed,0.0075),'.')
    xlim([datetime(2014,02,01) datetime(2015,05,01)])
    datetick('x','Keeplimits')
    title('Daily POC flux at 1025 m')
    ylabel('mg C m^-^2 d^-^1')
    grid on; box on
    ax1.FontSize = 12;

    ax2 = subplot(2,1,2);
    plot(dt_sameyr,cumsum(poc(remin_yrind))/1000/12.01,'Color',colorblind(pn(j),:),'Linewidth',2)
    hold on
    datetick
    grid on
    ylabel('mol C m^-^2')
    title('POC flux at 1025 m since beginning of remin. year')
    ax2.FontSize = 12;
    % ylim([0 2.5])
    xlim([datetime(2014,02,01) datetime(2015,05,01)])
    end

    subplot(2,1,1)
    l = legend('1: 2015-2016','2: 2016-2017','3: 2017-2018','4: 2018-2019','7: 2021-2022','Location','NE');
    l.FontSize = 10;
    title(l,'Remin. Year')

end
%% March 1 to March 1 daily and cumulative 
for j = 1:length(pn)

    bin_ind = find(wfpmerge.sinkingpulsedepths == 1025); 

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
    
    figure(402)
    if j == 5 
    
    elseif j == 6

    else

    ax1 = subplot(2,1,1);
    % plot(dt_nonans,spikes_nonans*35400*sinkingspeed,'.','MarkerSize',10) 
    % plot(day(datetime(dt(remin_yrind),'ConvertFrom','datenum'),'dayofyear'),poc(remin_yrind),'Color',colorblind(j,:),'Linewidth',2)
    plot(dt_sameyr,poc(remin_yrind),'Color',colorblind(pn(j),:),'Linewidth',2)
    hold on
    % plot(dt_nonans,smooth(spikes_nonans*35400*sinkingspeed,0.0075),'.')
    xlim([datetime(2014,02,15) datetime(2015,03,15)])
    datetick('x','Keeplimits')
    title('Daily POC flux at 1025 m')
    ylabel('mg C m^-^2 d^-^1')
    grid on; box on
    ax1.FontSize = 12;

    ax2 = subplot(2,1,2);
    if j == 1
        plot(dt_sameyr,cumsum(poc(remin_yrind))/1000/12.01,'Color',colorblind(pn(j),:),'Linewidth',2.5)
    else
        plot(dt_sameyr,cumsum(poc(remin_yrind))/1000/12.01,'Color',colorblind(pn(j),:),'Linewidth',2)
    end
    hold on
    datetick
    grid on
    ylabel('mol C m^-^2')
    title('POC flux at 1025 m since March 1')
    ax2.FontSize = 12;
    % ylim([0 2.5])
    xlim([datetime(2014,02,15) datetime(2015,03,15)])
    end

    subplot(2,1,1)
    l = legend('1: 2015-2016','2: 2016-2017','3: 2017-2018','4: 2018-2019','7: 2021-2022','Location','NE');
    l.FontSize = 10;
    title(l,'Year')

end

