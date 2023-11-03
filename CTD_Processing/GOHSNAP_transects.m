% Load in calibrated cruise data
cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Processed')
load AR6903_Processed_KF_notfinal.mat
addpath(genpath('G:\My Drive\Matlab_work\Github\OOI_Irminger_students\common'))
addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))
downcasts = downcasts_AR6903;
upcasts = upcasts_AR6903;
cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\BCO-DMO Submission\GOHSNAP')
load GOHSNAP_asset_locations.mat


%% Plot of AR69-03 locations and asset lat/lon to get desired cast numbers 
cast_num = cast_num_AR6903;
for i = 1:length(cast_num)  
    lon(i) = downcasts{cast_num(i)}.lon(1);
    lat(i) = downcasts{cast_num(i)}.lat(1);
end

figure
plot(lon,lat,'.k','Markersize',20)
hold on
for i = 1:length(cast_num)
    text(lon(i),lat(i),num2str(i))
end
plot(LS_assets.lon,LS_assets.lat,'ob')
plot(CF_M_assets.lon,CF_M_assets.lat,'ro')

%%
irminger_full = 2:32;
gohsnap_CF_M = 16:34;
gohsnap_LS = [85 87:105 113:118 124:126];

% param == 1 DO sat; param == 2 DOconc

% GOHSNAP Labrador 
LS_assets.StationNames = {'LS8' 'LS7' 'LS6' 'LS5' 'LS4' 'LS3' 'LS1'}; % Same order as unique lon
ax = plot_section_with_names(gohsnap_LS,upcasts,1,LS_assets); % DO Sat
ax = plot_section_with_names(gohsnap_LS,upcasts,2,LS_assets); % DO conc
% set(ax,'clim',[300 325]) % If you want to change colorbar limits  

% GOHSNAP Irminger 
CF_M_assets.StationNames = {'CF1','CF3','CF4','CF5','CF6','CF7','M1','M2','M3'};
ax = plot_section_with_names(gohsnap_CF_M,upcasts,1,CF_M_assets); % DO sat
ax = plot_section_with_names(gohsnap_CF_M,upcasts,2,CF_M_assets); % DO conc


%%
%Irminger Full
ooi_lon = -38.4407; % OOI website for WFP, Should this be closer to 40?
ax = plot_section(irminger_full,downcasts,1);
hold on
plot(CF_M_assets.lon,CF_M_assets.depth,'^','MarkerSize',10,'Color','k','Linewidth',1.5)
plot(ooi_lon:ooi_lon,1:100:2501,'*k','MarkerSize',5)
title('Irminger Section')

ax = plot_section(irminger_full,upcasts,2);
plot(CF_M_assets.lon,CF_M_assets.depth,'^','MarkerSize',10,'Color','k','Linewidth',1.5)
plot(ooi_lon:ooi_lon,1:100:2501,'*k','MarkerSize',5)
% set(ax,'clim',[300 325]) 
title('Irminger Section')
%%

function ax = plot_section_with_names(cast_num,downcasts,param,assets)

    DO = []; DOsat = []; prs = []; lon = [];
    
    for i = 1:length(cast_num)  
            lon(i) = downcasts{cast_num(i)}.lon(1);
%             lat(i) = downcasts{cast_num(i)}.lat(1);
            DO{i} = downcasts{cast_num(i)}.DOcorr_umolkg;
            DOsat{i} = (downcasts{cast_num(i)}.DOcorr_umolkg./downcasts{cast_num(i)}.O2sol_umolkg)*100;
            %add other parameters interested in 
            prs{i} = downcasts{cast_num(i)}.prs;
    end
    
    fig = figure;
    set(fig,'Position',[100 100 1100 400]) % Need to set figure size to make double axes line up 
    fontsize(fig, 12, "points")
    if param == 1
        transect(lon,prs,DOsat,'color',rgb('gray'),'markersize',5)
        c = colorbar;
        cmocean('balance','pivot',100)
        ylabel(c,'Dissolved Oxygen (% sat.)')
    end
    
    if param == 2 % Can expand on number of parameters 
        transect(lon,prs,DO,'color',rgb('gray'),'markersize',5)
        c = colorbar;
        ylabel(c,'Dissolved Oxygen (\mumol kg^-^1)','Fontsize',12)
    end
    hold on
    plot(assets.lon,assets.depth,'^','MarkerSize',10,'Color','k','Linewidth',1.5)

    xlabel('Longitude (\circW)','Fontsize',13)
    ylabel('Pressure (db)','Fontsize',13)
    c.FontSize = 12;

    ax1 = gca;

    ax2 = axes('Position',get(ax1,'Position'),'Color','none');
    set(ax2, 'Color','none','Fontsize',12,'XAxisLocation','top','YAxisLocation','Right');
    set(ax2, 'XLim', get(ax1, 'XLim'),'YLim', get(ax1, 'YLim'));
    set(ax2,'ydir','reverse');
    set(ax2,'XTick',unique(assets.lon),'YTick',[]);
    set(ax2, 'XTickLabel', assets.StationNames,'Fontsize',12);
    set(ax1,'FontSize',12)

    ax = ax1;
end

function ax = plot_section(cast_num,downcasts,param)

    DO = []; DOsat = []; prs = []; lon = [];
    
    for i = 1:length(cast_num)  
            lon(i) = downcasts{cast_num(i)}.lon(1);
%             lat(i) = downcasts{cast_num(i)}.lat(1);
            DO{i} = downcasts{cast_num(i)}.DOcorr_umolkg;
            DOsat{i} = (downcasts{cast_num(i)}.DOcorr_umolkg./downcasts{cast_num(i)}.O2sol_umolkg)*100;
            %add other parameters interested in 
            prs{i} = downcasts{cast_num(i)}.prs;
    end
    
    fig = figure;
    set(fig,'Position',[100 100 1100 400]) % Need to set figure size to make double axes line up 
    fontsize(fig, 12, "points")
    if param == 1
        transect(lon,prs,DOsat,'color',rgb('gray'),'markersize',5)
        c = colorbar;
        cmocean('balance','pivot',100)
        ylabel(c,'Dissolved Oxygen (% sat.)')
    end
    
    if param == 2 % Can expand on number of parameters 
        transect(lon,prs,DO,'color',rgb('gray'),'markersize',5)
        c = colorbar;
        ylabel(c,'Dissolved Oxygen (\mumol kg^-^1)','Fontsize',12)
    end
    hold on


    xlabel('Longitude (\circW)','Fontsize',13)
    ylabel('Pressure (db)','Fontsize',13)
    c.FontSize = 12;
    ax = gca;

end
