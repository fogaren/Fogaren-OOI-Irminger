%%
addpath(genpath('G:\My Drive\Matlab_work\Github\cmocean'))
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Hilary\CalibratedOxygenProduct_March2024')
load('glider_griddall_fixedPc1600db.mat')
glider = glidergrid; clear glidergrid;
glider_prs = 1:1000;

%%
j = 1;
figure % before
pcolor(glider{j}.temp)
shading interp
axis ij

% Remove profiles less than 950 m and extrapolate for pretty plotting
removeind = isnan(glider{j}.temp(950,:));
temp = glider{j}.temp;
sal = glider{j}.pracsal;
pdens = glider{j}.pdens;
dn = glider{j}.time;

temp(:,removeind == 1) = []; 
sal(:,removeind == 1) = [];
pdens(:,removeind == 1) = [];
dn(removeind == 1) = [];

tempfilled = fillmissing(temp,'nearest',1);
salfilled = fillmissing(sal,'nearest',1);
pdens = fillmissing(pdens,'nearest',1);

figure % after 
pcolor(tempfilled)
shading interp
axis ij
cmocean('thermal')


%%
figure
pcolor(tempfilled)
axis ij
shading interp
cmocean('thermal')

%%
j = 8;
figure
tempsimp = [tempfilled(:,j) tempfilled(:,j) tempfilled(:,j)];
pcolor(tempsimp)
axis ij
shading interp
% cmocean('thermal')
colorbar
box on

%%
myVideo = VideoWriter('basic.mp4','MPEG-4');
myVideo.Quality = 100;
myVideo.FrameRate = 8;
open(myVideo)


figure('Color','w')
set(gcf,'position',[100,100,900,500])
j = 1000;
    ax1 = subplot(1,6,[1 4]);
        % ax1 = subplot(3,6,[7 16.25]);
    pcolor(tempsimp)
    axis ij
    shading interp
    % cmocean('thermal')
    hold on
    plot(1.6,1:j,'Color','none')
    ylabel('depth (m)')
    set(ax1,'Fontsize',12)
    c = colorbar;
    c.Label.String = 'temp. (\circC)';
    c.Label.Position = [0.75 8.75];
    c.Label.Rotation = 0;
    c.FontSize = 12;
    ylim([0 1000])
    set(gca,'XTickLabel',[])

    ax2 = subplot(1,6,[5.5 6]);
    plot(0,0,'Color','none'); hold on
    ylim([0 1000]); xlim([3 9])
    axis ij
    
    plot(tempsimp(1:j,1),1:j,'Color','none')
    set(ax2,'XAxisLocation','top');
    set(ax2,'Fontsize',12)
    ylabel('depth (m)')
    xlabel('temperature (\circC)','Fontsize',12)
    grid on
    sgtitle('')

drawnow
frame = getframe(gcf);
writeVideo(myVideo,frame);


for j = 1:10:1000
    ax1 = subplot(1,6,[1 4]);
    pcolor(tempsimp)
    axis ij
    shading interp
    % cmocean('thermal')
    hold on
    plot(1.6,1:j,'.k')
    ylabel('depth (m)')
    set(ax1,'Fontsize',12)
    c = colorbar;
    c.Label.String = 'temp. (\circC)';
    c.Label.Position = [0.75 8.75];
    c.Label.Rotation = 0;
    c.FontSize = 12;
    ylim([0 1000])
    set(gca,'XTickLabel',[])

    ax2 = subplot(1,6,[5.5 6]);
    plot(0,0,'Color','none'); hold on
    ylim([0 1000]); xlim([3 9])
    axis ij
    
    plot(tempsimp(1:j,1),1:j,'.k')
    set(ax2,'XAxisLocation','top');
    set(ax2,'Fontsize',12)
    ylabel('depth (m)')
    xlabel('temperature (\circC)','Fontsize',12)
    grid on
    sgtitle('')

    drawnow
    frame = getframe(gcf);
    writeVideo(myVideo,frame);
end

close(myVideo)
%%
myVideo = VideoWriter('multipleTemp.mp4','MPEG-4');
myVideo.Quality = 100;
myVideo.FrameRate = 8;
open(myVideo)
% pn = [8 89 133 1000]; % was 8 instead of 50
pn = [48 104 165 1000];
figure('Color','w')
set(gcf,'position',[100,100,900,500])
for k = 4; %1:length(pn)
    for j = 1:10:1000
        ax1 = subplot(1,6,[1 4]);
        pcolor(dn,1:1000,tempfilled)
        axis ij
        shading interp
        % cmocean('thermal')
        hold on

        plot(dn(pn(1)),1000,'pk','MarkerFaceColor','c','MarkerSize',15)
        plot(dn(pn(2)),1000,'pk','MarkerFaceColor','g','MarkerSize',15)
        plot(dn(pn(3)),1000,'pk','MarkerFaceColor','m','MarkerSize',15)
        if k == 1
            plot(dn(pn(k)),1:j,'.','Color','c')           
        elseif k == 2
            plot(dn(pn(k)),1:j,'.','Color','g')      
        elseif k == 3
            plot(dn(pn(k)),1:j,'.','Color','m')
        end
        datetick('x','keeplimits')
        ylabel('depth (m)')
        set(ax1,'Fontsize',12)
        c = colorbar;
        c.Label.String = 'temp. (\circC)';
        c.Label.Position = [0.75 9.25];
        c.Label.Rotation = 0;
        c.FontSize = 12;
        ylim([0 1000])
        % xlabel('profile number')
    
        ax2 = subplot(1,6,[5.5 6]);
        plot(0,0,'Color','none'); hold on
        ylim([0 1000]); xlim([3 9])
        axis ij
        if k == 1
            plot(tempfilled(1:j,pn(k)),1:j,'.c')
        elseif k == 2
            plot(tempfilled(1:j,pn(k)),1:j,'.g')
        elseif k == 3
            plot(tempfilled(1:j,pn(k)),1:j,'.m')
        elseif k == 4
            plot(tempfilled(:,pn(1)),1:1000,'.c')
            plot(tempfilled(:,pn(2)),1:1000,'.g')
            plot(tempfilled(:,pn(3)),1:1000,'.m')
        end
        set(ax2,'XAxisLocation','top');
        set(ax2,'Fontsize',12)
        ylabel('depth (m)')
        xlabel('temperature (\circC)','Fontsize',12)
        grid on
        sgtitle('')
        
        drawnow
        frame = getframe(gcf);
        writeVideo(myVideo,frame);    
    end
end
close(myVideo)

%%
myVideo = VideoWriter('TempInTime.mp4','MPEG-4');
myVideo.Quality = 100;
myVideo.FrameRate = 8;
open(myVideo)

depthn = [25 80 450 1000];
figure('Color','w')
set(gcf,'position',[100,100,900,500])
for k = 1:length(depthn)
    for j = 1:width(tempfilled)
        ax1 = subplot(3,6,[7 18]);
        pcolor(dn,1:1000,tempfilled)
        axis ij
        shading interp
        % cmocean('thermal')
        hold on
        ylim([0 500])
        datetick('x','keeplimits')
        ylabel('depth (m)')
        set(ax1,'Fontsize',12)
        c = colorbar;
        c.Label.String = 'temperature (\circC)';
        % c.Label.Position = [0.79 9.4];
        % c.Label.Rotation = 0;
        c.FontSize = 12;

        plot(dn(1),depthn(1),'pk','MarkerFaceColor','c','MarkerSize',15)
        plot(dn(1),depthn(2),'pk','MarkerFaceColor','g','MarkerSize',15)
        plot(dn(1),depthn(3),'pk','MarkerFaceColor','m','MarkerSize',15)
        plot(dn(end),depthn(1),'pk','MarkerFaceColor','c','MarkerSize',15)
        plot(dn(end),depthn(2),'pk','MarkerFaceColor','g','MarkerSize',15)
        plot(dn(end),depthn(3),'pk','MarkerFaceColor','m','MarkerSize',15)
        if k == 1
            plot(dn(1:j),ones(size(dn(1:j)))*depthn(k),'Color','c','Linewidth',1.5)           
        elseif k == 2
            plot(dn(1:j),ones(size(dn(1:j)))*depthn(k),'Color','g','Linewidth',1.5)     
        elseif k == 3
            plot(dn(1:j),ones(size(dn(1:j)))*depthn(k),'Color','m','Linewidth',1.5) 
        end

    
        ax2 = subplot(3,6,[1 5.5]);
        plot(0,0,'Color','none'); hold on
        ylim([3 9]); xlim([dn(1) dn(end)])
        datetick('x','keeplimits')
        if k == 1
            plot(dn(1:j),tempfilled(depthn(k),1:j),'c','Linewidth',2)
        elseif k == 2
            plot(dn(1:j),tempfilled(depthn(k),1:j),'g','Linewidth',2)
        elseif k == 3
            plot(dn(1:j),tempfilled(depthn(k),1:j),'m','Linewidth',2)
        elseif k == 4
            plot(dn,tempfilled(depthn(1),:),'c','Linewidth',2)
            plot(dn,tempfilled(depthn(2),:),'g','Linewidth',2)
            plot(dn,tempfilled(depthn(3),:),'m','Linewidth',2)
        end
        set(ax2,'Fontsize',12)
        ylabel('temperature (\circC)','Fontsize',12)
        grid on

        drawnow
        frame = getframe(gcf);
        writeVideo(myVideo,frame);    
    end
end
close(myVideo)
