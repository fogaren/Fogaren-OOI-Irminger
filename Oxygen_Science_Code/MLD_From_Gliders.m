% Working with Hilary's files 
addpath(genpath('G:\My Drive\Matlab_work\Functions'))

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Sept2023')
load('glidermerge_output.mat') % Longest glider deployment for each year 
prs = 1:1000;

%%
% Preallocate vectors  
aa = NaN(size(glidermerge.time)); % For temp threshold
bb = NaN(size(glidermerge.time)); % For density threshold
cc = NaN(size(glidermerge.time)); % For maximum bouyancy frequency 

surf_temp = NaN(size(glidermerge.time));
ind_surf = NaN(size(glidermerge.time));
mid_temp = NaN(size(glidermerge.time));
bot_temp = NaN(size(glidermerge.time));

show_figure = 0;

for j = 1:length(glidermerge.time) % 2200 % 380
    clear a b c % 
    if isnan(nanmean(glidermerge.temp(:,j)))
        ind_surf(j) = NaN;
        surf_temp(j) = NaN;
    else
        ind_surf(j) = find(~isnan(glidermerge.temp(:,j)),1); % Index of first value that is not a nan
        surf_temp(j) = glidermerge.temp(ind_surf(j),j); % Value of first non-nan bin
    end
    
    mid_temp(j) = nanmean(glidermerge.temp(190:200,j)); % average temp near 200 m mark
    bot_temp(j) = nanmean(glidermerge.temp(390:400,j)); % average temp near 1000 m mark

    surf_prho = nanmean(glidermerge.pdens(1:10,j)); % Top 10 m average 

    N2 = (9.8./(glidermerge.pdens(1:end-1,j))).*diff(glidermerge.pdens(:,j));
    
    % If want to find profiles with temperature inversion 
    temp_diff = surf_temp(j) - mid_temp(j);

    if temp_diff > 0.0 % for ignoring profiles with temp inversion; can fuss with this later  
    
        [a,~] = find(glidermerge.temp(:,j) >= (surf_temp(j) - 0.1),1,'last'); % temp threshold MLD
        data_end = find(isnan(glidermerge.temp(:,j)) == 1);
        if isempty(find((a+10) == data_end)) == 0
            aa(j) = NaN; % if value too close to end (10 m) then overwrite with NaN
        else
            aa(j) = prs(a);
        end
    else % if not a nan and less than temp diff, write as NaN 
        a = []; 
    end
    
    if ~isnan(surf_prho) == 1 % If surface density isn't equal to NaN
        [b,~] = find(glidermerge.pdens(:,j) >= (surf_prho + 0.075),1,'first'); % pdens threshold MLD
        if ~isempty(b) == 1
            bb(j) = prs(b);
        end
    else % If surface density is equal to NaN
        b = [];
    end

    if temp_diff > 0.0 % for ignoring profiles with temp inversion; can fuss with this later
        [~,c] = max(N2);
        if ~isempty(c) == 1 
            cc(j) = prs(c(1));
        end
    else 
        c = [];
    end

end
%% If want to create a movie of each figure 
ind = find(glidermerge.deploy_yr == 5); % By deployment year 
% ind = 1:length(glidermerge.time); % For all deployments 
clear M1 % Movie 
for j = ind(1):ind(end)
    figure(1)
    clf
    ax1 = subplot(1,5,1);
    plot(glidermerge.temp(:,j),prs,'.')
    hold on
    if ~isnan(aa(j)) == 1
        plot(glidermerge.temp(aa(j),j),prs(aa(j)),'.k','MarkerSize',20)
    end
    axis ij; grid on
    title('temp')
    
    ax2 = subplot(1,5,2);
    plot(glidermerge.pdens(:,j),prs,'.')
    hold on
    if ~isnan(bb(j)) == 1
        plot(glidermerge.pdens(bb(j),j),prs(bb(j)),'.k','MarkerSize',20)
    end
    axis ij; grid on
    title('prho')
    
    N2 = (9.8./(glidermerge.pdens(1:end-1,j))).*diff(glidermerge.pdens(:,j));
    ax3 = subplot(1,5,3);
    plot(N2,prs(1:end-1)+diff(prs),'.')
    hold on
    if ~isnan(cc(j)) == 1
        plot(N2(cc(j)),prs(cc(j)),'.k','MarkerSize',20)
    end
    axis ij; grid on
    title('N2')
    
    ax4 = subplot(1,5,4);
    plot(glidermerge.chla(:,j),prs,'.')
    axis ij; grid on
    title('chl-a')
    
    ax5 = subplot(1,5,5);
    plot(glidermerge.doxy(:,j)./glidermerge.O2sat(:,j),prs,'.')
    axis ij; grid on
    title('DO')
    sgtitle([datestr(glidermerge.time(j)) ', prof num = ' num2str(j)])
    linkaxes([ax5 ax4 ax3 ax2 ax1],'y')

%     pause % If want to step thru each profile
%     M1(j-ind(1)+1) = getframe(gcf); %Endable to make movie 
end

%%
myVideo = VideoWriter('rename');
myVideo.Quality = 100;
myVideo.FrameRate = 1;
open(myVideo)
writeVideo(myVideo,M1)
close(myVideo)

%% Plot of MLD from different methods 
figure
plot(glidermerge.time,aa,'.')
hold on
plot(glidermerge.time,bb,'.')
hold on
plot(glidermerge.time,cc,'.')
axis ij; grid on
datetick
ylim([0 1000])
legend('Temp','Density','N2','Location', 'SE')
%%
figure
plot(glidermerge.time,aa,'.')
hold on
plot(glidermerge.time(ind_surf <=15),aa(ind_surf <=15),'.')
plot(glidermerge.time(ind_surf <=10),aa(ind_surf <=10),'.')
plot(glidermerge.time(ind_surf <=5),aa(ind_surf <=5),'.k')
axis ij
grid on
datetick('x','KeepTicks')
legend('> 15 m','< 15 m','< 10 m','< 5m','Location','SW');
title('Glider MLD by Surface Bin Depth')
ylabel('MLD (db)')

figure
aa2 = aa;
aa2(ind_surf>15) = NaN;
aa2(aa2>200) = NaN;

plot(glidermerge.time,aa2,'.')
hold on
% plot(glidermerge.time(1):glidermerge.time(end),ones(length(glidermerge.time(1):glidermerge.time(end)),1)*200,'k:')
% plot(glidermerge.time(ind_surf <=15),aa(ind_surf <=15),'.')
% plot(glidermerge.time(ind_surf <=10),aa(ind_surf <=10),'.')
% plot(glidermerge.time(ind_surf <=5),aa(ind_surf <=5),'.k')
axis ij
grid on
datetick('x','KeepTicks')
title('Glider MLD by Surface Bin Depth')
ylabel('MLD (db)')
%% Compare MLD outputs as a function of day of year 
yr = year(datetime(glidermerge.time,'ConvertFrom','datenum'));
doy = day(datetime(glidermerge.time,'ConvertFrom','datenum'),'dayofyear');

% ind = find(yr == 2015); % By year 
ind = 1:length(glidermerge.time); % For all data 

figure
scatter(aa(ind),bb(ind),[],doy(ind))
axis([0 400 0 400])
daspect([1 1 1]); grid on
xlabel('Temp MLD')
ylabel('Density MLD')
hold on
plot([0 400],[0 400],'k--')
cmocean('phase')
c = colorbar;
clim([0 365])
c.Ticks = [0 60 121 182 244 305];
c.TickLabels = {'Jan 1','Mar 1','May 1','Jul 1','Sep 1','Nov 1',};

figure
scatter(aa(ind),cc(ind),[],doy(ind))
axis([0 400 0 400])
daspect([1 1 1]); grid on
xlabel('Temp MLD')
ylabel('N2 MLD')
hold on
plot([0 400],[0 400],'k--')
cmocean('phase')
c = colorbar;
clim([0 365])
c.Ticks = [0 60 121 182 244 305];
c.TickLabels = {'Jan 1','Mar 1','May 1','Jul 1','Sep 1','Nov 1',};

figure
scatter(bb(ind),cc(ind),[],doy(ind))
axis([0 400 0 400])
daspect([1 1 1]); grid on
xlabel('Density MLD')
ylabel('N2 MLD')
hold on
plot([0 400],[0 400],'k--')
cmocean('phase')
c = colorbar;
clim([0 365])
c.Ticks = [0 60 121 182 244 305];
c.TickLabels = {'Jan 1','Mar 1','May 1','Jul 1','Sep 1','Nov 1',};
%% Look at glider depth range and MLD output
max_depth = NaN(size(ind)); 
for i = 1:length(ind)
    [ia,~] = find(~isnan(glidermerge.temp(:,i)));
    if ~isempty(ia)
        max_depth(i) = max(ia);
    end
end

f = figure;
f.Position = [50 50 900 600];
subplot(2,1,1)
plot(glidermerge.time(ind),max_depth,'.k','MarkerSize',10)
axis ij
title('Deepest glider Temp data')
datetick
ylabel('m')
grid on

subplot(2,1,2)
plot(glidermerge.time(ind),aa(ind),'o','MarkerSize',5)
hold on
plot(glidermerge.time(ind),bb(ind),'^','MarkerSize',5)
plot(glidermerge.time(ind),cc(ind),'s','MarkerSize',7)
grid on
axis ij
datetick
ylabel('MLD')
legend('Temp','Density','N2','Location','SW')
title('MLD Calculation')
ylim([0 1000])
%% Glider MLD outputs and method comparison by Day of Year 
% ind = find(glidermerge.deploy_yr == 8);
ind = 1:length(glidermerge.time);
zlim = 200;

f = figure;
f.Position = [50 50 900 600];
subplot(2,2,[1 2])
plot(glidermerge.time(ind),aa(ind),'o','MarkerSize',5)
hold on
plot(glidermerge.time(ind),bb(ind),'^','MarkerSize',5)
plot(glidermerge.time(ind),cc(ind),'s','MarkerSize',7)
grid on
axis ij
datetick
ylabel('MLD')
legend('Temp','Density','N2','Location','SW')
ylim([0 zlim])

subplot(2,2,3)
scatter(aa(ind),bb(ind),[],doy(ind))
daspect([1 1 1]); grid on; box on
xlabel('Temp MLD')
ylabel('Density MLD')
hold on
plot([0 zlim],[0 zlim],'k--')
axis([0 zlim 0 zlim])
cmocean('phase')
c = colorbar;
clim([0 365])
c.Ticks = [0 60 121 182 244 305];
c.TickLabels = {'Jan 1','Mar 1','May 1','Jul 1','Sep 1','Nov 1',};

subplot(2,2,4)
scatter(bb(ind),cc(ind),[],doy(ind))
daspect([1 1 1]); grid on; box on
xlabel('Density MLD')
ylabel('N2 MLD')
hold on
plot([0 zlim],[0 zlim],'k--')
axis([0 zlim 0 zlim])
cmocean('phase')
c = colorbar;
clim([0 365])
c.Ticks = [0 60 121 182 244 305];
c.TickLabels = {'Jan 1','Mar 1','May 1','Jul 1','Sep 1','Nov 1',};
sgtitle([num2str(year(glidermerge.time(ind(1)))) ' - ' num2str(year(glidermerge.time(ind(end))))]);
