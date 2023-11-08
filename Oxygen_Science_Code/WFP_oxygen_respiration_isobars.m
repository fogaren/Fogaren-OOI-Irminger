% % Working with Hilary's files 
% addpath(genpath('G:\My Drive\Matlab_work\Functions'))


cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Sept2023')
% load('glidermerge_output.mat')
load('wfpmerge_output.mat')
prs = 150:1:2600;

%%
%Load Kristen's MLD calculated from WFP chl data
addpath('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
% load MLD_CHL_WFP.mat
% load MLD_CHL_WFP7.mat
load('wfp_chl_KF_Sep2023.mat')
%chldt_mat = datenum(floor(chldt),0,0) + 365*(chldt - floor(chldt));
% chldt_mat = [chldt; chldt7];
% chlmld = [chlmld; chlmld7];
% chlmld(138) = NaN; % Bad data point 
% Linear interpolation of MLD product onto WFP DO timegrid 
mld_DO_dt = interp1(wfp_chl.dn,wfp_chl.mld_db,wggmerge.time,'linear');

figure
plot(wggmerge.time,mld_DO_dt)
axis ij
grid on
%%

mld = []; dt =[]; mld_interp = [];
for yr = 1:length(year(wfp_chl.dn(1)):year(wfp_chl.dn(end)))-1
    i = 2013 + yr;
    ind = find(wfp_chl.dn > datenum(i,09,01) & wfp_chl.dn < datenum(i+1,09,01));
    ind2 = find(wfp_chl.time > datenum(i,09,01) & wfp_chl.time < datenum(i+1,09,01));
    mld{yr} = wfp_chl.mld_db(ind); 
    doy{yr} = wfp_chl.dn(ind) - wfp_chl.time(ind2(1));
    dt{yr} = wfp_chl.dn(ind);
    dt_interp{yr} = wfp_chl.time(ind2);
    mld_interp(yr,:) = interp1(wfp_chl.dn(ind),wfp_chl.mld_db(ind),wfp_chl.time(ind2),'linear');
    doy_interp{yr} = wfp_chl.time(ind2) - wfp_chl.time(ind2(1));
end

test = interp1(wfp_chl.dn,wfp_chl.mld_db,wfp_chl.time,'linear');
figure
plot(wfp_chl.time,movmean(test,5))
axis ij
grid on

close all
for j = 1:8
figure(1)
plot(doy{j},mld{j})
hold on
% plot(doy_interp{j},smoothdata(mld_interp{j},'loess',21),'Linewidth',1.5)
axis ij
grid on
hold on
end

% Earliest mld at 200 is about day 70 + 9/1
% Latest mld at 200 is about day 290 + 9/1

%%
% Sort oxygen data by time (overlapping deployment issue)
DOdt = wggmerge.time;
DOwfp = wggmerge.doxy;

[DOdt,index] = sortrows(DOdt,'ascend');
DOwfp = DOwfp(:,index);

%% Scatter plot with WFP data
% profilerng = [1:1:3371];
sz = 1;
ymax = 2000;

f = figure;
f.Position = [100 100 1200 400];
[X,Y] = meshgrid(wggmerge.time, prs);
scatter(X(:),Y(:),5,DOwfp(:),'filled'); hold on;
plot(chldt_mat, chlmld, 'k.','markersize',8); hold on; 
axis ij; axis tight; xlim([datenum(2014,9,10) datenum(2022,1,1)]); ylim([0 ymax]);
ylabel('Pressure (db)', 'Fontsize', 14); hcb = colorbar; set(hcb,'location','eastoutside')
datetick('x',2,'keeplimits');
title('OOI Irminger WFP oxygen concentration', 'Fontsize', 14)
hcb.Label.String = 'DO (\mumol kg^-^1)';
hcb.FontSize = 12;
box on
set(gca, 'TickDir', 'out')
%%

ind250 = find(prs == 250); %ind = find(prs == z);
ind500 = find(prs == 500);
ind750 = find(prs == 750);
ind1000 = find(prs == 1000);
ind1500 = find(prs == 1500);

figure
plot(DOdt,DOwfp(ind250,:),'.')
axis tight; grid on
datetick('x','KeepLimits')
figure
plot(DOdt,DOwfp(ind500,:),'.')
axis tight; grid on
datetick('x','KeepLimits')
figure 
plot(DOdt,DOwfp(ind750,:),'.')
axis tight; grid on
datetick('x','KeepLimits')
figure
plot(DOdt,DOwfp(ind1000,:),'.')
axis tight; grid on
datetick('x','KeepLimits')
figure
plot(DOdt,DOwfp(ind1500,:),'.')
axis tight; grid on
datetick('x','KeepLimits')


%%
ind250 = [];
ind500 = [];
ind750 = [];
ind1000 = [];
%%
for yr = 1:length(year(DOdt(1)):year(DOdt(end)))-1
    i = 2014 + yr;
    ind = find(DOdt > datenum(i,04,01) & DOdt < datenum(i,11,01));
    figure
    plot(DOdt(ind),DOwfp(ind250,ind),'.')
    datetick


end
%%

for yr = 1
    ind250 = find(mld >= 250); %ind250e = find(mld > 250);
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
plot(chldt_mat,chlmld,'.','MarkerSize',20,'Color',blue)
hold on
plot(chldt_mat,ones(length(chldt_mat),1)*250,'k','Linewidth',2)
plot(chldt_mat,ones(length(chldt_mat),1)*500,'k','Linewidth',2)
plot(chldt_mat,ones(length(chldt_mat),1)*750,'k','Linewidth',2)
plot(chldt_mat,ones(length(chldt_mat),1)*1000,'k','Linewidth',2)
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
    DOyy = DO(prs == iso(i),:)';
    yy{i} = smooth(DOdt,DOyy,0.025,'loess');
end
%%


figure(6)
clf
subplot(4,1,1)
plot(DOdt,DO(prs == 250,:),'.','Color',grey); hold on
for i = 1:length(MLD250) 
    plot(DOdt(MLD250ind{i}),DO(prs == 250,MLD250ind{i}),'.','Color',blue)
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
plot(DOdt,DO(prs == 500,:),'.','Color',grey)
hold on
for i = 1:length(MLD500) 
    plot(DOdt(MLD500ind{i}),DO(prs == 500,MLD500ind{i}),'.','Color',blue)
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
plot(DOdt,DO(prs == 750,:),'.','Color',grey)
hold on
for i = 1:length(MLD750) 
    plot(DOdt(MLD750ind{i}),DO(prs == 750,MLD750ind{i}),'.','Color',blue)
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
plot(DOdt,DO(prs == 1000,:),'.','Color',grey)
for i = 1:length(MLD1000)
    plot(DOdt(MLD1000ind{i}),DO(prs == 1000,MLD1000ind{i}),'.','Color',blue)
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
plot(DOdt,DO(prs == 1500,:),'.','Color',grey)
hold on
plot(DOdt,yy{5},'Linewidth',1.5,'Color','k') 
% ylim([260 320])
xlim([datenum(2014,09,01) datenum(2022,01,01)])
datetick('keeplimits','x'); grid on
ylabel('\mumol L^-^1')
title('Oxygen at 1500 db')
f = gca; f.FontSize = 14;

subplot(3,1,2)
plot(DOdt,DO(prs == 2000,:),'.','Color',grey)
hold on
plot(DOdt,yy{6},'Linewidth',1.5,'Color','k')
% ylim([260 320])
xlim([datenum(2014,09,01) datenum(2022,01,01)])
datetick('keeplimits','x'); grid on
ylabel('\mumol L^-^1')
title('Oxygen at 2000 db')
f = gca; f.FontSize = 14;

subplot(3,1,3)
plot(DOdt,DO(prs == 2400,:),'.','Color',grey)
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
    DOyy = DO(prs == iso(ii),:)';
    yyiso{ii} = smooth(DOdt,DOyy,0.025,'loess');
    yyisotest(ii,:) = yyiso{ii};
end
%%
PTiso = [];
for ii = 1:length(iso)
    PTiso(ii,:) = gsw_pt_from_CT(wggmerge.SA(prs ==iso(ii),:),wggmerge.CT(prs == iso(ii),:));
end
prhoiso = []; 
for ii = 1:length(iso)
    prhoiso(ii,:) = wggmerge.pdens(prs == iso(ii),:);
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



