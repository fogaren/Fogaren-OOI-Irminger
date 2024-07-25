%% Playing with WFP data and buoyancy frequency determined MLD 
clearvars
close all
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Sept2023')
load('wfpmerge_output.mat')
prs = [150:1:2600];

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load wfp_chl_KF_Sep2023.mat
addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))
run('GeneralSettings.m')
% ind = isnan(wfp_chl.time);
% wfp_chl.dt = datetime(wfp_chl.time,'ConvertFrom','datenum');
%%

aa = NaN(size(wggmerge.time)); % For temp MLD
bb = NaN(size(wggmerge.time)); % For prho MLD
cc = NaN(size(wggmerge.time)); % For N2 MLD 
dd = NaN(size(wggmerge.time)); % For chl MLD; since finding wggmerge_fl profiles == wggmerge profiles 

wfp_toptemp = NaN(size(wggmerge.time)); 
wfp_toppdens = NaN(size(wggmerge.time));
wfp_topchl_mean = NaN(size(wggmerge_fl.time));
wfp_topchl_std = NaN(size(wggmerge_fl.time));

for j = 1:length(wggmerge.time)
    jj = find(wggmerge_fl.time == wggmerge.time(j)); % different number of flur profiles 
    
    [ia,~] = find(~isnan(wggmerge.temp(:,j)));
    [ib,~] = find(~isnan(wggmerge.pdens(:,j)));
    [id,~] = find(~isnan(wggmerge_fl.chla(:,jj))); 
    if ~isempty(ia) % Find average temp for top 5 m of WFP ~= NaN 
        wfp_toptemp(j) = nanmean(wggmerge.temp(min(ia):min(ia)+5,j));
    end
    if ~isempty(ib) % Find average density for top 5 m of WFP ~= NaN 
        wfp_toppdens(j) = nanmean(wggmerge.pdens(min(ib):min(ib)+5,j));
    end
    if ~isempty(id) % Find average density for top 5 m of WFP ~= NaN 
        wfp_topchl_mean(j) = nanmean(wggmerge_fl.chla(min(id):min(id)+5,jj));
        wfp_topchl_std(j) = nanstd(wggmerge_fl.chla(min(id):min(id)+5,jj));
    end

    [a,~] = find(wggmerge.temp(:,j) >= (wfp_toptemp(j) - 0.05),1,'last'); % temp threshold MLD
    if ~isempty(a)
        aa(j) = prs(a);
    end

    [b,~] = find(wggmerge.pdens(:,j) >= (wfp_toppdens(j) + 0.01),1,'first'); % pdens threshold MLD
    if ~isempty(b)
        bb(j) = prs(b);
    end
    
    N2 = (9.8./(wggmerge.pdens(1:end-1,j))).*diff(wggmerge.pdens(:,j));
    N2_cut = N2(1:1851);
    [~,c] = max(N2_cut);
    if ~isempty(c)
        cc(j) = prs(c(1));
    end
    
    if ~isempty(jj)
        [d,~] = find(wggmerge_fl.chla(:,jj) >= (wfp_topchl_mean(j) - (3*wfp_topchl_std(j))),1,'last'); % chl MLD
        if ~isempty(d)
            dd(j) = prs(d);
        end
    end

    clear a b c d ia ib id
end

% for j = 1:length(wggmerge.time)
%     clear a b c 
% 
% 
%     jj = find(wggmerge_fl.time == wggmerge.time(j)); % different number of flur profiles 
% 
%     if ~isempty(jj) 
%         if ~isnan(wfp_chl.mld_db_time(jj))
%                 N2 = (9.8./(wggmerge.pdens(1:end-1,j))).*diff(wggmerge.pdens(:,j));
%                 N2_cut = N2(1:1851);
%                 [~,c] = max(N2_cut);
%             if ~isempty(c)% == 1 
%                 cc(j) = prs(c(1));
%             end
%         end
%     end
% end

%%
% prs = [150:1:2100];
% cc = NaN(size(wggmerge.time)); 

ind = find(wggmerge.deploy_yr == 6);
% mld5 = NaN(size(ind));
% mld = zeros(size(ind));
% ind = 1:length(wggmerge.time);
clear M1
for j = 2275:ind(end)%ind(1):ind(end)
    jj = find(wggmerge_fl.time == wggmerge.time(j));
    figure(1)
    clf

    ax1 = subplot(1,5,1);
%     plot(wggmerge.temp(:,j-1),prs,'.','Color',rgb('gray'))
%     hold on
    plot(wggmerge.temp(:,j),prs,'.','Color',blue)
    hold on
    plot(wggmerge.temp(prs == aa(j),j),aa(j),'sk','MarkerSize',8)
    axis ij; grid on
    title('temp')
    
    ax2 = subplot(1,5,2);
    if ~isnan(wfp_toppdens(j))
%         plot(wggmerge.pdens(:,j-1),prs,'.','Color',rgb('gray'))
%         hold on
        plot(wggmerge.pdens(:,j),prs,'.','Color',blue)
        hold on
        if ~isnan(bb(j))
            plot(wggmerge.pdens(prs == bb(j),j),bb(j),'sk','MarkerSize',8)
        end
    elseif isnan(wfp_toppdens(j))
        plot(NaN,NaN)
        box on
    end
    axis ij; grid on 
    title('prho')
    
    N2 = (9.8./(wggmerge.pdens(1:end-1,j))).*diff(wggmerge.pdens(:,j));
    ax3 = subplot(1,5,3);
    plot(N2,prs(1:end-1)+diff(prs),'.')
    hold on
    plot(N2(prs == cc(j)),cc(j),'sk','MarkerSize',8)
    axis ij; grid on
    title('N2')

    ax4 = subplot(1,5,4); 
    plot(wggmerge.doxy(:,j-2),prs,'.','Color',rgb('light grey'))
    hold on
    plot(wggmerge.doxy(:,j-1),prs,'.','Color',rgb('grey'))
    plot(wggmerge.doxy(:,j),prs,'.','Color',blue)
    axis ij; grid on
    title('DO \mumol/kg')

    ax5 = subplot(1,5,5);
    if ~isempty(jj) 
        try
            plot(wggmerge_fl.chla(:,jj-2),prs,'.','Color',rgb('light grey'))
            hold on
            plot(wggmerge_fl.chla(:,jj-1),prs,'.','Color',rgb('grey'))
        end
        plot(wggmerge_fl.chla(:,jj),prs,'.','Color',blue)
        hold on
        plot(wggmerge_fl.chla(prs == dd(j),jj),dd(j),'sk','MarkerSize',8)
    elseif isempty(jj)
        plot(NaN,NaN)
        box on
        hold on
    end
    if ~isnan(wfp_chl.mld_db_time(jj))
%     chl_time = find(wfp_chl.time == wggmerge_fl.time(jj)); % not needed since wfp_chl time is same as wggmerge_fl.time
        plot(wggmerge_fl.chla(prs == wfp_chl.mld_db_time(jj),jj),wfp_chl.mld_db_time(jj),'.k','MarkerSize',20)
    end
    axis ij; grid on
    title('chl-a')

    sgtitle([datestr(wggmerge.time(j)) ', prof num = ' num2str(j)])
    linkaxes([ax5 ax4 ax3 ax2 ax1],'y')
    prompt = '0 = none, 1 = temp, 2 = prho, 3 = N2, 4 = chl-Top, 5 = chl-bottom, 6 = user enter';
    mld_input = input(prompt)
    mld(j) = mld_input;
    
    if mld_input == 1
        subplot(1,5,1)
        plot(wggmerge.temp(prs == aa(j),j),aa(j),'o','MarkerSize',10,'Linewidth',1.5,'Color',rgb('orange'))        
    elseif mld_input == 2
        subplot(1,5,2)
        plot(wggmerge.pdens(prs == bb(j),j),bb(j),'o','MarkerSize',10,'Linewidth',1.5,'Color',rgb('orange'))
    elseif mld_input == 3
        subplot(1,5,3)
        plot(N2(prs == cc(j)),cc(j),'o','MarkerSize',10,'Linewidth',1.5,'Color',rgb('orange'))
    elseif mld_input == 4
        subplot(1,5,5)
        plot(wggmerge_fl.chla(prs == dd(j),jj),dd(j),'o','MarkerSize',10,'Linewidth',1.5,'Color',rgb('orange'))
    elseif mld_input == 5
        subplot(1,5,5)
        plot(wggmerge_fl.chla(prs == wfp_chl.mld_db_time(jj),jj),wfp_chl.mld_db_time(jj),'o','MarkerSize',10,'Linewidth',1.5,'Color',rgb('orange'))
    end

    
    %             k = 1 + length(M1);
    %             M1(k) = getframe(gcf);
     M1(j-ind(1)+1) = getframe(gcf);
end
%% calculate N2 for each profile
ind = 1:length(wggmerge.time);
N2 = [];

for j = ind(1):ind(end)
    N2(:,j) = (9.8./(wggmerge.pdens(1:end-1,j))).*diff(wggmerge.pdens(:,j));
end
%% 130
ind = find(wggmerge.deploy_yr == 1);
% ind = 1:length(wggmerge.time);
clear M1
for j = 1862:ind(end)%ind(1):ind(end)%ind(1):ind(end)
    jj = find(wggmerge_fl.time == wggmerge.time(j));
    figure(1)
    clf


    ax1 = subplot(1,3,1);
    if jj > 1
        plot(wggmerge_fl.chla(:,jj-1),prs,'.')
        hold on
        if ~isnan(cc(j-1))
            plot(wggmerge_fl.chla(prs == cc(j-1),jj-1),cc(j-1),'sk','MarkerSize',8)
        end
        if ~isnan(dd(j-1))
            plot(wggmerge_fl.chla(prs == dd(j-1),jj-1),dd(j-1),'.k','MarkerSize',20)
        end
    else
        plot(NaN,NaN)
    end
    axis ij; grid on
    title(['prof num = ' num2str(j-1)])

    ax2 = subplot(1,3,2);
    if jj > 0 
        plot(wggmerge_fl.chla(:,jj),prs,'.')
        hold on
        if ~isnan(cc(j))
            plot(wggmerge_fl.chla(prs == cc(j),jj),cc(j),'sk','MarkerSize',8)
        end
        if ~isnan(dd(j))
            plot(wggmerge_fl.chla(prs == dd(j),jj),dd(j),'.k','MarkerSize',20)
        end
    else
        plot(NaN,NaN)
    end
    axis ij; grid on
    title(['prof num = ' num2str(j)])
    
%     ax3 = subplot(1,3,3);
%     if jj < (ind(end) -1)
%         plot(wggmerge_fl.chla(:,jj+1),prs,'.')
%         hold on
%         if ~isnan(cc(j+1))
%             plot(wggmerge_fl.chla(prs == cc(j+1),jj+1),cc(j+1),'sk','MarkerSize',8)
%         end
%         if ~isnan(dd(j+1))
%             plot(wggmerge_fl.chla(prs == dd(j+1),jj+1),dd(j+1),'.k','MarkerSize',20)
%         end
%     else
%         plot(NaN,NaN)
%     end
%     axis ij; grid on
%     title(['prof num = ' num2str(j+1)])

    ax3 = subplot(1,3,3);
    if jj > 1
        plot(wggmerge_fl.chla(:,jj)-wggmerge_fl.chla(:,jj-1),prs,'.')
        hold on
        plot(smooth((wggmerge_fl.chla(:,jj)-wggmerge_fl.chla(:,jj-1)),0.1,'loess'),prs)
    else
        plot(NaN,NaN)
    end
    axis ij; grid on
    title(['prof num = ' num2str(j) ' - ' num2str(j-1)])

    sgtitle(['Chl-a profiles ' datestr(wggmerge.time(j))])
    linkaxes([ax3 ax2 ax1],'y')
    pause
    
%     %             k = 1 + length(M1);
%     %             M1(k) = getframe(gcf);
%      M1(j-ind(1)+1) = getframe(gcf);
end
%%
ind = find(wggmerge.deploy_yr == 2);
% ind = 1:length(wggmerge.time);
clear M1
for j = ind(1):ind(end)%ind(1):ind(end)%ind(1):ind(end)
    jj = find(wggmerge_fl.time == wggmerge.time(j));
    figure(1)
    clf

    ax1 = subplot(1,5,1);
    if jj > 3
        plot(wggmerge_fl.chla(:,jj-2),prs,'.')
        hold on
        plot(wggmerge.temp(:,j-2)/50,prs,'.')
        if ~isnan(cc(j-2))
            plot(wggmerge_fl.chla(prs == cc(j-2 ),jj-2),cc(j-2),'sk','MarkerSize',8)
        end
        if ~isnan(dd(j-2))
            plot(wggmerge_fl.chla(prs == dd(j-2),jj-2),dd(j-2),'.k','MarkerSize',20)
        end
    else
        plot(NaN,NaN)
    end
    axis ij; grid on
    title(['prof num = ' num2str(j-2)])
    
    ax2 = subplot(1,5,2);
    if jj > 2
        plot(wggmerge_fl.chla(:,jj-1),prs,'.')
        hold on
                plot(wggmerge.temp(:,j-1)/50,prs,'.')
        if ~isnan(cc(j-1))
            plot(wggmerge_fl.chla(prs == cc(j-1),jj-1),cc(j-1),'sk','MarkerSize',8)
        end
        if ~isnan(dd(j-1))
            plot(wggmerge_fl.chla(prs == dd(j-1),jj-1),dd(j-1),'.k','MarkerSize',20)
        end
    else
        plot(NaN,NaN)
    end
    axis ij; grid on
    title(['prof num = ' num2str(j-1)])

    ax3 = subplot(1,5,3);
    if jj > 0 
        plot(wggmerge_fl.chla(:,jj),prs,'.')
        hold on
                plot(wggmerge.temp(:,j)/50,prs,'.')
        if ~isnan(cc(j))
            plot(wggmerge_fl.chla(prs == cc(j),jj),cc(j),'sk','MarkerSize',8)
        end
        if ~isnan(dd(j))
            plot(wggmerge_fl.chla(prs == dd(j),jj),dd(j),'.k','MarkerSize',20)
        end
    else
        plot(NaN,NaN)
    end
    axis ij; grid on
    title(['prof num = ' num2str(j)])
    
    ax4 = subplot(1,5,4);
    if jj < (ind(end) -2)
        plot(wggmerge_fl.chla(:,jj+1),prs,'.')
        hold on
                plot(wggmerge.temp(:,j+1)/50,prs,'.')
        if ~isnan(cc(j+1))
            plot(wggmerge_fl.chla(prs == cc(j+1),jj+1),cc(j+1),'sk','MarkerSize',8)
        end
        if ~isnan(dd(j+1))
            plot(wggmerge_fl.chla(prs == dd(j+1),jj+1),dd(j+1),'.k','MarkerSize',20)
        end
    else
        plot(NaN,NaN)
    end
    axis ij; grid on
    title(['prof num = ' num2str(j+1)])

    ax5 = subplot(1,5,5);
    if jj < (ind(end) -1)
        plot(wggmerge_fl.chla(:,jj+2),prs,'.')
        hold on
                    plot(wggmerge.temp(:,j+2)/50,prs,'.')
        if ~isnan(cc(j+2))
            plot(wggmerge_fl.chla(prs == cc(j+2),jj+2),cc(j+2),'sk','MarkerSize',8)
        end
        if ~isnan(dd(j+2))
            plot(wggmerge_fl.chla(prs == dd(j+2),jj+2),dd(j+2),'.k','MarkerSize',20)
        end
    else
        plot(NaN,NaN)
    end
    axis ij; grid on
    title(['prof num = ' num2str(j+2)])

    sgtitle(['Chl-a profiles ' datestr(wggmerge.time(j))])
    linkaxes([ax5 ax4 ax3 ax2 ax1],'y')
    pause
end
%% Year 1 after profile 101
% Year 2 starting with 535
% Year 3 starting with 987
% Year 4 starting with 1418 (late start?)
% Year 5 starting with 1862
% Year 6 starting with 2275
% Year 7 starting with 2537
% hand_picked = zeros(size(wggmerge.time));
% hand_picked(1:404) = test;
mld6 = [];
for j = 1:length(mld)
    jj = find(wggmerge_fl.time == wggmerge.time(j));
    if mld(j) == 0
        mld6(j) = NaN;
    elseif mld(j) == 1
        mld6(j) = aa(j);
    elseif mld(j) == 2
        mld6(j) = bb(j);
    elseif mld(j) == 3
        mld6(j) = cc(j);
    elseif mld(j) == 4
        mld6(j) = dd(j);
    elseif mld(j) == 5
        mld6(j) = wfp_chl.mld_db_time(jj);
    end
end

%%
figure
plot(mld6)
axis ij


%%
figure
% plot(wggmerge.time,aa,'.','Markersize',20)
% hold on
% plot(wggmerge.time,bb,'.','Markersize',20)
plot(wggmerge.time,cc,'.','Markersize',20)
hold on
% plot(wggmerge.time,dd,'.','MarkerSize',20)
plot(wfp_chl.time,wfp_chl.mld_db_time,'.','MarkerSize',20)
% plot(wggmerge.time(ind(1):ind(end)),mld1,'ok','Markersize',8,'Linewidth',1.5)
% plot(wggmerge.time,mld,'k.')
% hold on
% plot(wggmerge.time,smooth(mld),'Linewidth',1.2)
axis ij
datetick
%%
test = [aa bb cc dd];
test1 = nanmean(test,2);
test2 = nanmedian(test,2);

figure
plot(wggmerge_fl.time,smooth(wfp_chl.mld_db_time),'-')
hold on
plot(wggmerge.time,mld,'.')
axis ij
datetick
%%
figure
plot(wggmerge.time,aa,'.')
hold on
% plot(wggmerge.time,bb,'.')
% plot(wggmerge.time,cc,'.')
% plot(wggmerge.time,dd,'.')
plot(wfp_chl.time,wfp_chl.mld_db_time,'.k')
axis ij
grid on
datetick
ylim([200 1800])
legend('Temp','Chl')
%%
figure
for i = 1:length(dd)
    if ~isnan(dd(i))
        ind = find(wfp_chl.dn == wggmerge.time(dd(i)));
        if ~isempty(ind)
        figure(8)
        plot(dd(i),wfp_chl.mld_db(ind),'o')
        end
        
        hold on
    end
end
grid on
%%
myVideo = VideoWriter('WFP_DeployYear8');
myVideo.Quality = 100;
myVideo.FrameRate = 1;
open(myVideo)
writeVideo(myVideo,M1)
close(myVideo)
% movie(M4)
toc