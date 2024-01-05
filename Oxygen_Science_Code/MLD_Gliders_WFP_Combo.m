%% Playing with WFP data and buoyancy frequency determined MLD 
clearvars
close all
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_Sept2023')
load('wfpmerge_output.mat')
wfp_prs = [150:1:2600];
load('glidermerge_output.mat')
glid_prs = 1:1000;
% Working with Hilary's files 
addpath(genpath('G:\My Drive\Matlab_work\Functions'))

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load glider_wfp.mat

cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load wfp_chl_KF_Sep2023.mat
%%
ind = find(wggmerge.deploy_yr == 7); % 3 is interesting 
% ind = 1:length(wggmerge.time);
clear M1
zlim = 500;
for j = ind(1):ind(end)
    jj = find(wggmerge_fl.time == wggmerge.time(j));
    % find closest glider time; 
    i_diff = (abs(glidermerge.time - wggmerge.time(j)))*24; % diff in hours 
    [ia, ib] = min(i_diff);
    [ia, ib] = find(i_diff < 6);

    figure(1)
    clf
    ax1 = subplot(1,5,1);
    plot(wggmerge.temp(:,j),wfp_prs,'.')
    hold on
    if ~isempty(ia)
        plot(glidermerge.temp(:,ia),glid_prs,'.')
        try
            plot(glidermerge.temp(glid_prs == glider.aa(ia(1)),ia(1)),glider.aa(ia(1)),'.k','MarkerSize',20)
        end
        try
            plot(glidermerge.temp(glid_prs == glider.aa(ia(2)),ia(2)),glider.aa(ia(2)),'.k','MarkerSize',20)
        end
        try
            plot(glidermerge.temp(glid_prs == glider.aa(ia(3)),ia(1)),glider.aa(ia(1)),'.k','MarkerSize',20)
        end
    end
    
    if ~isnan(wfp.aa(j))
        plot(wggmerge.temp(wfp_prs == wfp.aa(j),j),wfp.aa(j),'sk','MarkerSize',8)
    end
    axis ij; grid on
    title('temp')
    ylim([0 zlim])

    ax2 = subplot(1,5,2);
    plot(wggmerge.pdens(:,j),wfp_prs,'.')
    hold on

    if ~isempty(ia)
        plot(glidermerge.pdens(:,ia),glid_prs,'.')
        try
            plot(glidermerge.pdens(glid_prs == glider.bb(ia(1)),ia(1)),glider.bb(ia(1)),'.k','MarkerSize',20)
        end
        try
            plot(glidermerge.pdens(glid_prs == glider.bb(ia(2)),ia(2)),glider.bb(ia(2)),'.k','MarkerSize',20)
        end
        try
            plot(glidermerge.pdens(glid_prs == glider.bb(ia(3)),ia(1)),glider.bb(ia(1)),'.k','MarkerSize',20)
        end
    end
    if ~isnan(wfp.bb(j))
        plot(wggmerge.pdens(wfp_prs == wfp.bb(j),j),wfp.bb(j),'sk','MarkerSize',8)
    end
    axis ij; grid on
    title('prho')
    ylim([0 zlim])
    
    wfp_N2 = (9.8./(wggmerge.pdens(1:end-1,j))).*diff(wggmerge.pdens(:,j));
    glid_N2 = (9.8./(glidermerge.pdens(1:end-1,ia))).*diff(glidermerge.pdens(:,ia));

    ax3 = subplot(1,5,3);
    plot(wfp_N2,wfp_prs(1:end-1)+diff(wfp_prs),'.')
    hold on
    glid_N2 = []; 
    if ~isempty(ia)
        for k = 1:length(ia)
            glid_N2{k} = (9.8./(glidermerge.pdens(1:end-1,ia(k)))).*diff(glidermerge.pdens(:,ia(k)));
            plot(glid_N2{k},glid_prs(1:end-1)+diff(glid_prs),'.')
            hold on
        end
        for k = 1:length(ia)
            if ~isnan(glider.cc(ia(k)))
                plot(glid_N2{k}(glid_prs == glider.cc(ia(k))),glider.cc(ia(k)),'.k','MarkerSize',20)
            end
        end
    end
    
    if ~isnan(wfp.cc(j))
        plot(wfp_N2(wfp_prs == wfp.cc(j)),wfp.cc(j),'sk','MarkerSize',8)
    end

    axis ij; grid on
    title('N2')
    ylim([0 zlim])

    ax4 = subplot(1,5,4);        
    plot(wggmerge.doxy(:,j),wfp_prs,'.')
    hold on
    if ~isempty(ia)
        plot(glidermerge.doxy(:,ia),glid_prs,'.') 
    end
    axis ij; grid on
    title('DO \mumol/kg')

    ax5 = subplot(1,5,5);
    if ~isempty(jj)   
        plot(wggmerge_fl.chla(:,jj),wfp_prs,'.')
        hold on
    elseif isempty(jj)
        plot(NaN,NaN)
        box on
        hold on
    end

    if ~isempty(ia)
        plot(glidermerge.chla(:,ia),glid_prs,'.')
    end
    
    if ~isnan(wfp.dd(jj)) 
        plot(wggmerge_fl.chla(wfp_prs == wfp.dd(j),jj),wfp.dd(j),'sk','MarkerSize',8)
    end

    if ~isnan(wfp_chl.mld_db_time(jj))
        plot(wggmerge_fl.chla(wfp_prs == wfp_chl.mld_db_time(jj),jj),wfp_chl.mld_db_time(jj),'.k','MarkerSize',20)
    end

    axis ij; grid on
    title('chl-a')
        
    if length(ia) > 1
        sgtitle({['wfp = ' datestr(wggmerge.time(j)) ', prof num = ' num2str(j)]...
            ['glid = ' datestr(glidermerge.time(ia(1))) ' - ' datestr(glidermerge.time(ia(end))) ', prof num = ' num2str(ia(1)) '-' num2str(ia(end))]})
    else
        sgtitle({['wfp = ' datestr(wggmerge.time(j)) ', prof num = ' num2str(j)]...
            ['glid = ' datestr(glidermerge.time(ia)) ', prof num = ' num2str(ia)]})
    end
    ylim([0 zlim])   
        linkaxes([ax5 ax4 ax3 ax2 ax1],'y')
            ylim([0 zlim])   
     pause 
    clear ia
%     
%     M1(j-ind(1)+1) = getframe(gcf);

end
%%
myVideo = VideoWriter('Combo_DeployYear7_1000m');
myVideo.Quality = 100;
myVideo.FrameRate = 1;
open(myVideo)
writeVideo(myVideo,M1)
close(myVideo)
% movie(M4)
toc
