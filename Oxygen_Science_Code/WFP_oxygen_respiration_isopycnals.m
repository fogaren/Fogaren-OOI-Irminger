% Working with Hilary's files 
addpath(genpath('G:\My Drive\Matlab_work\Functions'))

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Sept2023')
load('glidermerge_output.mat')
load('wfpmerge_output.mat')
pres_grid = [150:1:2600];
pres_grid_hypm = pres_grid;
pt_grid = [1.5:0.02:5]; 

%% Load Kristen's MLD calculated from WFP chl data
cd('G:\Shared drives\NSF_Irminger\Data_Files\From Meg')
load blended_mld.mat
blended_mld_all.dn = datenum(blended_mld_all.time); % Converts to datenum 

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load wfp_chl_KF_Sep2023.mat
wfp_chl.dt = datetime(wfp_chl.dn,'ConvertFrom','datenum'); %datetime of just observations
wfp_chl.time_dt = datetime(wfp_chl.time,'ConvertFrom','datenum'); % datetime evenly spaced with NaNs
% %%
% % renames variables
% DOpres = pres_grid_hypm;
% DOdt = wggmerge.time;
% DOwfp = wggmerge.doxy;
% 
% % sort oxygen data by time
% [DOdt,index] = sortrows(wggmerge.time,'ascend');
% DOwfp = DOwfp(:,index);
% prho_wfp = wggmerge.pdens(:,index);


%% Scatter plot with WFP data

sz = 1;
ymax = 2000;

f = figure;
f.Position = [100 100 1200 400];
C = cmocean('dense'); %set colormap
[X,Y] = meshgrid(wggmerge.time, pres_grid_hypm);
scatter(X(:),Y(:),5,wggmerge.doxy(:),'filled'); hold on;
% scatter(X(:),Y(:),5,prho_wfp(:),'filled'); hold on;
plot(blended_mld_all.dn,blended_mld_all.mld,'k','Linewidth',1.4)
axis ij; axis tight; 
% xlim([datenum(2015,1,1) datenum(2022,1,1)]); ylim([0 ymax]);
colormap(C); ylabel('Pressure (db)', 'Fontsize', 14); hcb = colorbar; set(hcb,'location','eastoutside')
datetick('x',2,'keeplimits');
clim([260 320])
% clim([1027.6 1027.95])
title('OOI WFP oxygen concentration', 'Fontsize', 14)
hcb.Label.String = 'DO (\mumol kg^-^1)';
hcb.FontSize = 12;
box on
set(gca, 'TickDir', 'out')

%%
yr = unique(year(wfp_chl.dn)); % Years of deployments; 

% Using calendar year -- decide how to define respiration year
% Finds all the points in a 3/15 to 3/15 year
res_yr = []; % "Respiration year"
for i = 1:length(yr)-1 % don't have full respiration year for first yera 
    res_yr{i} = find((wggmerge.time > datenum(yr(i),03,15)) & (wggmerge.time < datenum(yr(i+1),03,15)));     
end

% find average prho for every 10 db from 200 to 2000
prho_mean_by_db =[]; prho_median_by_db = []; prho_mode_by_db = []; 
db_ind = 51:10:1851; % Indices for db every 10 db from 280 to 2000
for i = 1:length(yr)-1
    prho_mean_by_db{i} = nanmean(wggmerge.pdens(db_ind,res_yr{i}),2);
    prho_median_by_db{i} = nanmedian(wggmerge.pdens(db_ind,res_yr{i}),2);
    prho_mode_by_db{i} = mode(wggmerge.pdens(db_ind,res_yr{i}),2);
end

i = 2; 
figure
plot(prho_mean_by_db{i},pres_grid_hypm(db_ind),'.-')
hold on
plot(prho_median_by_db{i},pres_grid_hypm(db_ind),'.-')
plot(prho_mode_by_db{i},pres_grid_hypm(db_ind),'.-')
axis ij
grid on
legend('Mean','Median','Mode','Location','SW')
%%
%Start with mean 
prho_grid = prho_mean_by_db{i}; 
S = 5;
pdens_grid = []; 
for i = 1:length(yr)-1
    pdens_grid{i}.doxy = NaN*ones(length(prho_grid),length(res_yr{i}));
    
    for j = 1:length(res_yr{i})
        ind = find(~isnan(wggmerge.pdens(:,res_yr{i}(j))) & ~isnan(wggmerge.doxy(:,res_yr{i}(j))));
        if ~isempty(ind)
            pdens_grid{i}.doxy(:,j) = interp1(wggmerge.pdens(ind,res_yr{i}(j)),wggmerge.doxy(ind,res_yr{i}(j)),prho_grid,'makima');
        end
    end
end
%%
i = 2; j = 1;
figure
plot(wggmerge.doxy(:,res_yr{i}(j)),pres_grid_hypm)
hold on
plot(plot(pdens_grid{i}.doxy(:,j),pres_grid_hypm(db_ind)))

%%


for i = 2:length(yr)-1
    figure(i)
%     scatter(X(:,res_yr{i}),Y(:,res_yr{i}),5,DOwfp(:,res_yr{i}),'filled'); hold on;
%     pcolor(wggmerge.time(res_yr{i}),pres_grid_hypm,DOwfp(:,res_yr{i}))
    pcolor(wggmerge.time(res_yr{i}),pres_grid_hypm,prho_wfp(:,res_yr{i}))
    shading interp
    axis ij
    datetick
    colorbar
    title(num2str(yr(i)))

%     plot(wfp_chl.time(res_yr{i})-datenum(yr(i),08,15),wfp_chl.mld_db_time(res_yr{i}),'.k')
%     hold on
%     plot(blended_mld_all.dn(dn_yr_blended{i})-datenum(yr(i),08,15),blended_mld_all.mld(dn_yr_blended{i}),'Linewidth',1.4)
%     grid on
%     axis ij
%     ylim([200 1500])
%     xlim([100 350])
%     ylabel('MLD (db)')
%     legend(num2str(yr(i)),'Location','SE')
end
% xlabel('Days since August 15')
% sgtitle('Mixed Layer Progression by Year')
% legend('14-15','15-16','16-17','17-18','18-19','19-20','20-21','21-22')
%%
% Calculate average pdens for target isopycnal 

ind_target = find(pres_grid == 700 );
pdens_target = nanmean(wggmerge.pdens(ind_target,:)); % target density
% Should we do this for most stratified time of year?
% Should we target density for 1st profile or average of all profiles 

% Find index in each profile that is closest to target density 
a = []; b = [];
for i = 1:length(wggmerge.time)
%     if ~isnan(wggmerge.pdens(ind_target,i))
        [a(i),b(i)] = min(abs(wggmerge.pdens(:,i) - pdens_target));
%     end

    if a(i) > 0.00002 % What do we want to call the same isopycnal? 
        b(i) = NaN;
    end

    if isnan(wggmerge.pdens(ind_target,i))
        b(i) = NaN;
    end
end
%%
for i = 1:length(wggmerge.time)
    figure(1)
    clf
    subplot(1,2,1)
    plot(abs(wggmerge.pdens(:,i) - pdens_target),pres_grid);
    axis ij; grid on
    title('Profile pdens - target pdens')

    subplot(1,2,2)
    plot(wggmerge.doxy(:,i),pres_grid);
    axis ij; grid on
    title('Oxygen')
    sgtitle(datestr(wggmerge.time(i)))
    pause
end
%%
test = []; test2 = []; test3 = []; test4 = [];
for i = 1:length(b)
    if ~isnan(b(i))
            
        test(i) = wggmerge.doxy(b(i),i);
        test2(i) = wggmerge.temp(b(i),i);
        test3(i) = pres_grid(b(i));
        test4(i) = wggmerge.pdens(b(i),i);
    end
    if isnan(b(i))
        test(i) = NaN;
        test2(i) = NaN;
        test3(i) = NaN;
        test4(i) = NaN;
    end
end
testyy = smooth(wggmerge.time,test,0.025,'loess');
figure(1)
clf
subplot(3,1,1)
plot(wggmerge.time,test,'.')
hold on
% plot(wggmerge.time,testyy,'k','Linewidth',1.5)
title(['Oxygen of isopycnal ' num2str(pdens_target)])
datetick
grid on
ylabel('umol kg^-^1')

subplot(3,1,2)
% yyaxis left
plot(wggmerge.time,test2,'.')
ylabel('\circC')

% yyaxis right
% plot(wggmerge.time,test4,'.')
% ylabel('PSU')
title(['Temp of isopycnal ' num2str(pdens_target)])
datetick

grid on

subplot(3,1,3)
plot(wggmerge.time,test3,'.')
title(['Pressure of isopycnal ' num2str(pdens_target)])
datetick
axis ij
ylabel('dbar')
grid on
sgtitle(['Mean isopycnal at ' num2str(pres_grid(ind_target)) ' dbar = ' num2str(pdens_target)])


figure
plot(wggmerge.time,test4,'.')
%%

ind200= find(pres_grid == 200);
pdens200 = nanmean(wggmerge.pdens(ind200,:)); % target density 

ind250= find(pres_grid == 250);
pdens250 = nanmean(wggmerge.pdens(ind250,:)); % target density 

ind500= find(pres_grid == 500);
pdens500 = nanmean(wggmerge.pdens(ind500,:)); % target density 

ind750= find(pres_grid == 750);
pdens750 = nanmean(wggmerge.pdens(ind750,:)); % target density

ind1000= find(pres_grid == 1000);
pdens1000 = nanmean(wggmerge.pdens(ind1000,:)); % target density 

ind2000= find(pres_grid == 2000);
pdens2000 = nanmean(wggmerge.pdens(ind2000,:)); % target density 
%%
prs250 = [];
prs500 = [];
prs750 = [];
prs1000 = [];

% prs250e = [];
% prs500e = [];
% prs750e = [];
% prs1000e = [];

for yr = 1:length(year(wfp_chl.dn(1)):year(wfp_chl.dn(end)))
    i = 2013 + yr;
    ind = find(wfp_chl.dn > datenum(i,09,01) & wfp_chl.dn < datenum(i+1,06,01));
    mld = wfp_chl.mld_db(ind); % Need to convert to pdens space 
    dt = wfp_chl.dn(ind);

    ind250 = find(mld >= 250); %ind250e = find(mld > 250); % Convert to pdense space 
    ind500 = find(mld >= 500); %ind500e = find(mld > 500);
    ind750 = find(mld >= 750); %ind750e = find(mld > 750);
    ind1000 = find(mld >= 1000); %ind1000e = find(mld > 1000);
    
    if isempty(ind250) ~= 1
        prs250{yr} = dt(ind250); 
    else
        prs250{yr} = []; 
    end
%     if isempty(ind250) ~= 1
%         prs250e{yr} = dt(ind250e(end)); 
%     else
%         prs250e{yr} = []; 
%     end
    if isempty(ind500) ~= 1
        prs500{yr} = dt(ind500); 
    else
        prs500{yr} = []; 
    end
%     if isempty(ind500) ~= 1
%         prs500e{yr} = dt(ind500e(end)); 
%     else
%         prs500e{yr} = []; 
%     end
    if isempty(ind750) ~= 1
        prs750{yr} = dt(ind750); 
    else
        prs750{yr} = []; 
    end
%     if isempty(ind750) ~= 1
%         prs750e{yr} = dt(ind750e(end)); 
%     else
%         prs750e{yr} = []; 
%     end
    if isempty(ind1000) ~= 1
        prs1000{yr} = dt(ind1000); 
    else
        prs1000{yr} = []; 
    end
%     if isempty(ind1000) ~= 1
%         prs1000e{yr} = dt(ind1000e(end));
%     else
%         prs1000e{yr} = [];
%     end
end


%%
run('GeneralSettings.m')
figure
plot(wfp_chl.dn,chlmld,'.','MarkerSize',20,'Color',blue)
hold on
plot(wfp_chl.dn,ones(length(wfp_chl.dn),1)*250,'k','Linewidth',2)
plot(wfp_chl.dn,ones(length(wfp_chl.dn),1)*500,'k','Linewidth',2)
plot(wfp_chl.dn,ones(length(wfp_chl.dn),1)*750,'k','Linewidth',2)
plot(wfp_chl.dn,ones(length(wfp_chl.dn),1)*1000,'k','Linewidth',2)
datetick
axis ij
grid on
%%
%%
MLD250 = [735935	736122
736305	736468
736689	736870
737064	737263
737418	737569
737820	737919
738133	738305]; 

MLD500 = [735971	736192
736340	736437
736716	736832
737107	737167
737523	737541
737832	737914]; 

MLD750 = [735987	736107
736365	736437
736741	736815
737121	737157
737895	737896];

MLD1000 = [736009	736057
736387	736405
737141	737152];

MLD250ind = [];
for i = 1:length(MLD250)
    inds = find(DOdt >= MLD250(i,1));
    inde = find(DOdt <= MLD250(i,2));
    MLD250ind{i} = inds(1):inde(end);
end

MLD500ind = [];
for i = 1:length(MLD500)
    inds = find(DOdt >= MLD500(i,1));
    inde = find(DOdt <= MLD500(i,2));
    MLD500ind{i} = inds(1):inde(end);
end

MLD750ind = [];
for i = 1:length(MLD750)
    inds = find(DOdt >= MLD750(i,1));
    inde = find(DOdt <= MLD750(i,2));
    MLD750ind{i} = inds(1):inde(end);
end

MLD1000ind = [];
for i = 1:length(MLD1000)
    inds = find(DOdt >= MLD1000(i,1));
    inde = find(DOdt <= MLD1000(i,2));
    MLD1000ind{i} = inds(1):inde(end);
end
disp('Done')

%%
yy = [];
iso = [250; 500; 750; 1000; 1500; 2000; 2400]; % indexed by 1 , 2 , 3, and 4 in figure below. 
for i = 1:length(iso)
    DOyy = DO(DOpres == iso(i),:)';
    yy{i} = smooth(DOdt,DOyy,0.025,'loess');
end
%%


figure(6)
clf
subplot(4,1,1)
plot(DOdt,DO(DOpres == 250,:),'.','Color',grey); hold on
for i = 1:length(MLD250) 
    plot(DOdt(MLD250ind{i}),DO(DOpres == 250,MLD250ind{i}),'.','Color',blue)
end
plot(DOdt(1:end-970),yy{1}(1:end-970),'Linewidth',1.5,'Color','k')
plot(DOdt(2420:end-300),yy{1}(2420:end-300),'Linewidth',1.5,'Color','k')
ylim([260 320])
xlim([datenum(2014,09,01) datenum(2022,01,01)])
datetick('keeplimits','x'); grid on
ylabel('\mumol L^-^1')
text(datenum(2015,04,01),270,'250 db','FontWeight','bold','FontSize',13.5)
title('WFP Oxygen')
f = gca; f.FontSize = 13;

subplot(4,1,2)
plot(DOdt,DO(DOpres == 500,:),'.','Color',grey)
hold on
for i = 1:length(MLD500) 
    plot(DOdt(MLD500ind{i}),DO(DOpres == 500,MLD500ind{i}),'.','Color',blue)
end
plot(DOdt(1:end-970),yy{2}(1:end-970),'Linewidth',1.5,'Color','k')
plot(DOdt(2420:end-300),yy{2}(2420:end-300),'Linewidth',1.5,'Color','k')
ylim([260 320])
xlim([datenum(2014,09,01) datenum(2022,01,01)])
datetick('keeplimits','x'); grid on
ylabel('\mumol L^-^1')
text(datenum(2015,04,01),270,'500 db','FontWeight','bold','FontSize',13.5)
f = gca; f.FontSize = 13;

subplot(4,1,3)
plot(DOdt,DO(DOpres == 750,:),'.','Color',grey)
hold on
for i = 1:length(MLD750) 
    plot(DOdt(MLD750ind{i}),DO(DOpres == 750,MLD750ind{i}),'.','Color',blue)
end
plot(DOdt(1:end-970),yy{3}(1:end-970),'Linewidth',1.5,'Color','k')
plot(DOdt(2420:end-300),yy{3}(2420:end-300),'Linewidth',1.5,'Color','k')
ylim([260 320])
xlim([datenum(2014,09,01) datenum(2022,01,01)])
datetick('keeplimits','x'); grid on
ylabel('\mumol L^-^1')
text(datenum(2015,04,01),270,'750 db','FontWeight','bold','FontSize',13.5)
f = gca; f.FontSize = 13;

subplot(4,1,4)
plot(NaN,NaN,'.','Markersize',10,'Color',blue) % For figure legend 
hold on
plot(NaN,NaN,'.','Markersize',10,'Color',grey)
plot(NaN,NaN,'k-','Linewidth',1.5)
hold on
plot(DOdt,DO(DOpres == 1000,:),'.','Color',grey)
for i = 1:length(MLD1000)
    plot(DOdt(MLD1000ind{i}),DO(DOpres == 1000,MLD1000ind{i}),'.','Color',blue)
end
plot(DOdt(1:end-970),yy{4}(1:end-970),'Linewidth',1.5,'Color','k')
plot(DOdt(2420:end-300),yy{4}(2420:end-300),'Linewidth',1.5,'Color','k')
ylim([260 320])
xlim([datenum(2014,09,01) datenum(2022,01,01)])
datetick('keeplimits','x'); grid on
ylabel('\mumol L^-^1')
text(datenum(2015,04,01),270,'1000 db','FontWeight','bold','FontSize',13.5)
legend('In Mixed Layer','Below Mixed Layer','Smoothed Data','Orientation','horizontal','Location','Southoutside')
f = gca; f.FontSize = 13;
%%
figure
subplot(3,1,1)
plot(DOdt,DO(DOpres == 1500,:),'.','Color',grey)
hold on
plot(DOdt,yy{5},'Linewidth',1.5,'Color','k') 
% ylim([260 320])
xlim([datenum(2014,09,01) datenum(2022,01,01)])
datetick('keeplimits','x'); grid on
ylabel('\mumol L^-^1')
title('Oxygen at 1500 db')
f = gca; f.FontSize = 14;

subplot(3,1,2)
plot(DOdt,DO(DOpres == 2000,:),'.','Color',grey)
hold on
plot(DOdt,yy{6},'Linewidth',1.5,'Color','k')
% ylim([260 320])
xlim([datenum(2014,09,01) datenum(2022,01,01)])
datetick('keeplimits','x'); grid on
ylabel('\mumol L^-^1')
title('Oxygen at 2000 db')
f = gca; f.FontSize = 14;

subplot(3,1,3)
plot(DOdt,DO(DOpres == 2400,:),'.','Color',grey)
hold on
plot(DOdt,yy{7},'Linewidth',1.5,'Color','k')
% ylim([260 320])
xlim([datenum(2014,09,01) datenum(2022,01,01)])
datetick('keeplimits','x'); grid on
ylabel('\mumol L^-^1')
title('Oxygen at 2400 db')
f = gca; f.FontSize = 14;
%%

yyiso = [];
yyistotest = [];
iso = 200:10:2400; % Pressure vector
for ii = 1:length(iso)
    DOyy = DO(DOpres == iso(ii),:)';
    yyiso{ii} = smooth(DOdt,DOyy,0.025,'loess');
    yyisotest(ii,:) = yyiso{ii};
end
%%
PTiso = [];
for ii = 1:length(iso)
    PTiso(ii,:) = gsw_pt_from_CT(wggmerge.SA(DOpres ==iso(ii),:),wggmerge.CT(DOpres == iso(ii),:));
end
prhoiso = []; 
for ii = 1:length(iso)
    prhoiso(ii,:) = wggmerge.pdens(DOpres == iso(ii),:);
end

    
    % PT = gsw_pt_from_CT(wggmerge.SA,wggmerge.CT);

[ptsorted, ptind] = sort(PTiso,1,'descend');
[prhosorted, prhoind] = sort(prhoiso,1,'ascend');
yyiso_pt = yyisotest(ptind);
yyiso_prho = yyisotest(prhoind);
%%
yyiso_pt_sm = []; 
for i = 1:length(DOdt)
    yyiso_pt_sm(:,i) = smooth(yyiso_pt(:,i),0.025,'loess');
end
%%
yyiso_prho_sm = []; 
for i = 1:length(DOdt)
    yyiso_prho_sm(:,i) = smooth(yyiso_prho(:,i),0.025,'loess');
end

%%
yyiso_prho_sm_sm = [];
for i = 1:length(iso)
    yyiso_prho_sm_sm(i,:) = smooth(yyiso_prho_sm(i,:),0.025,'loess');
end
disp('Done')
%%
figure
plot(yyiso_pt_sm(:,100),ptsorted(:,100),'.k')
%%
figure
plot(yyiso_prho(:,100),prhosorted(:,100),'.')
hold on
plot(yyiso_prho_sm(:,100),prhosorted(:,100),'-')


%%
DOresp = []; 
for yr = 1:7
    i = 2013 + yr; 
    for ii = 1:length(iso)
        ind = find(DOdt > datenum(i,01,01) & DOdt < datenum(i+1,03,01));
        [maxyy,imax] = max(yyiso{ii}(ind));
        [minyy,imin] = min(yyiso{ii}(ind));

%         DOresp{yr}.DOdecrease = [];
%         DOresp{yr}.DOmax = [];
%         DOresp{yr}.DOmin = [];
%         DOresp{yr}.DOmaxdt = [];
%         DOresp{yr}.DOmindt = [];

        DOresp{yr}.DOdecrease(ii) = maxyy - minyy; 
        DOresp{yr}.DOmax(ii) = maxyy;
        DOresp{yr}.DOmin(ii) = minyy;
        DOresp{yr}.DOmaxdt(ii) = DOdt(ind(imax));
        DOresp{yr}.DOmindt(ii) = DOdt(ind(imin));
    end
end
%%
mldmax_yr = [1390; 1430; 950; 1335; 510; 805; 440]; % max chl measured MLD
figure
for yr = 1:7
   subplot(1,7,yr)
    plot(DOresp{yr}.DOdecrease,iso,'.k'); hold on
    axis ij
    ylim([200 2400])
    xlim([0 35])
    grid on; 
    plot(0:35,ones(length(0:35),1)*mldmax_yr(yr),'--','Linewidth',1.5,'Color',blue)
    if yr == 1
    ylabel('Pressure (dbar)')
    end
    xlabel('DO decrease (\mumol L^-^1)')
    title([num2str(yr + 2014) ' stratified season'])
end
sgtitle('Total stratified season respiration by year ')
%%

%%
colors = [maroon; red; yellow; green; blue; purple; brightpurple];
DOresp_all = [DOresp{1}.DOdecrease; DOresp{2}.DOdecrease; DOresp{3}.DOdecrease; DOresp{4}.DOdecrease;...
    DOresp{5}.DOdecrease; DOresp{6}.DOdecrease; DOresp{7}.DOdecrease];

DOresp_yr1 = DOresp{1}.DOdecrease;
DOresp_yr2 = DOresp{2}.DOdecrease;
DOresp_yr3 = DOresp{3}.DOdecrease;
DOresp_yr4 = DOresp{4}.DOdecrease;
DOresp_yr5 = DOresp{5}.DOdecrease;
DOresp_yr6 = DOresp{6}.DOdecrease;
DOresp_yr7 = DOresp{7}.DOdecrease;

meanDOresp = nanmean(DOresp_all,1);

DOresp_m = -gsw_z_from_p(iso,nanmean(wggmerge.lat));

figure
for yr = 1:7
    plot(DOresp{yr}.DOdecrease,iso,'','Color',colors(yr,:)); hold on
    axis ij
%     ylim([200 2400])
%     xlim([0 35])
    grid on; 
    ylabel('Pressure (dbar)')
    xlabel('DO decrease (\mumol L^-^1)')
end
plot(meanDOresp,iso,'--k','Linewidth',2)
sgtitle('Total stratified season respiration by year ')

%%
figure
for yr = 1:7
   subplot(1,7,yr)
%     plot(DOresp{yr}.DOdecrease,iso,'.','Color',colors(yr,:),'MarkerSize',10); hold on
    plot(DOresp{yr}.DOdecrease,iso,'.','Color',blue,'MarkerSize',10); hold on
    plot(meanDOresp,iso,'--k','Linewidth',2)
    axis ij
    ylim([200 1000])
    xlim([0 35])
    grid on; 
    if yr == 1
    ylabel('Pressure (dbar)')
    end
    xlabel('DO decrease (\mumol L^-^1)')
    title([num2str(yr + 2014) ' stratified season'])
end
sgtitle('Total stratified season respiration by year ')



