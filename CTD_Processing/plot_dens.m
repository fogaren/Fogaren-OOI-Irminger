
function plot_dens(fig_ax)

    %% input
%     fig_ax = figure(nn);
    t = [-3:.1:20];
    s = [23:.5:36];
    dsalt = 0.005;
    dtemp = 0.05;
    densmin = 1020; densmax = 1029;
%     sigmaclines = 15:.5:32;
    sigmaclines = 15:.1:32;
    lon = -42; lat = 60;
    % zoomed in domain bounds
    % max(s)pl = 35.2;
    % min(s)pl = 34.5;
    % max(t)pl = 7;
    % min(t)pl = 1;
    % szX = 2/3*1/2;
    % szY = 1*1/2;

    % make arrays for T/S plot
    % [sgrid,tgrid] = meshgrid(s,t);
    % D = sw_pden(sgrid,tgrid,0,0)-1000;

    %% main
    % density contours 
    saltx = [min(s):dsalt:max(s)];
    tempy = [min(t):dtemp:max(t)]';
    [saltX, tempY] = meshgrid(saltx, tempy);

    saltXA = gsw_SA_from_SP(saltX,0,lon,lat);
    tempYC = gsw_CT_from_pt(saltXA,tempY);
    sigma0 = gsw_sigma0(saltXA, tempYC);

    % Begin figure
    screen_size=get(0,'ScreenSize');
    figure(fig_ax);
    % set(f,'Position',[screen_size(1) screen_size(2) screen_size(3)*szX screen_size(4)*szY]);

    hold on; box on;

    [csig,hsig] = contour(saltX,tempY,sigma0,sigmaclines,'k-','linewidth',0.5);
    clabel(csig,hsig,'fontsize',10,'color','k','labelspacing',240);
%     hx = xlabel('Salinity','fontsize',18);
%     hy = ylabel('Temperature [\circC]','fontsize',18);
    % xlim([min(s)pl max(s)pl]);
    % ylim([min(t)pl max(t)pl]);
    
%         keyboard

    % add freezing point of sw
%     fp = sw_fp(saltx,saltx.*0); %careful to use psu and pt
%     fpp = sw_ptmp(saltx,fp,saltx.*0,0);
%     plot(saltx,fppg,'r')
    
    % add freezing point of sw gibbs
%     % for Alaska 71 23.650 N, 152 2.810 W is close to AON mooring
%     long = -(152+(2.810/60));
%     lat = 71+(23.650/60);
    
    t_freezing = gsw_t_freezing(saltx,0);
    t_freezing_ct = gsw_CT_from_t(saltx,t_freezing,0);
    plot(saltx,t_freezing_ct,'r','linewidth',1.5)

end 


