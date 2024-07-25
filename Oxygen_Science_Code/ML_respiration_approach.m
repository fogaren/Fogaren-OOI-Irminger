%%
close all
clearvars
run('GeneralSettings.m')
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
load Dproduction.mat

wfp_prs = 150:1:2600;
Dprod_start_used = Dprod_start;
Dprod_end_used = Dprod_end; 
%%

DOresp_rate_umolkg_day =[];
b_umolkg = [];
p_value = [];
R2 = [];
Dprod_days = []; 
DOresp_season_umolkg = []; % rate (slope) *resp_days 
Dprod_prho = [];

%%
figs = 0;
for yr = 1:length(Dprod_ind)-1

    for z = 200:2000 % Depth to start at 

        z_ind = find(wfp_prs == z); % Finds the index of that depth
        
        if isnan(Dprod_start{z}(yr))
            Dprod_start_used{z}(yr) = Dprod_ind(yr);
        end
        if isnan(Dprod_end{z}(yr))
            Dprod_end_used{z}(yr) = Dprod_ind(yr+1);
        end
        
        Dprod = Dprod_start_used{z}(yr):Dprod_end_used{z}(yr); % Dprod season for isobar

        dt_days = resp.time(Dprod) - resp.time(Dprod(1));
    
        mdl = fitlm(dt_days,resp.doxy(z_ind,Dprod));
        
        if figs == 1

            figure(1)
            clf
            plot(resp.time,resp.doxy(z_ind,:),'ok','MarkerFaceColor','k')
            hold on
            plot(resp.time(Dprod),resp.doxy(z_ind,Dprod),'ok','MarkerFaceColor',blue)
            xlim([resp.time(Dprod(1)-40) resp.time(Dprod(end)+40)])
            datetick('x','Keeplimits')
            grid on
 
            ylabel('DO (\mumol kg^-^1)')
            title(['Depth = ' num2str(z)])
                       pause
        end

        
        % Stores them by actual depth 
        DOresp_rate_umolkg_day{yr}(z) = mdl.Coefficients.Estimate(2);
        b_umolkg{yr}(z) = mdl.Coefficients.Estimate(1);
        p_value{yr}(z) = mdl.Coefficients.pValue(2);
        R2{yr}(z) = mdl.Rsquared.Ordinary;
        Dprod_days{yr}(z) = max(dt_days); 
        DOresp_season_umolkg{yr}(z) = mdl.Coefficients.Estimate(2)*max(dt_days); % rate (slope) *resp_days 
        Dprod_prho{yr}(z) = nanmean(resp.prho(z_ind,Dprod_start_used{z}(yr):Dprod_end_used{z}(yr)));
        DOresp_season_molm3{yr}(z) = (DOresp_season_umolkg{yr}(z).*Dprod_prho{yr}(z))/(1000*1000);
%         Dprod_start{yr}(z) = dt_yr_max_retimed_ind; % index for retimed series 
%         Dprod_end{yr}(z) = dt_yr_min_retimed_ind; 
    end 
end

%%
close all
z1 = 250; z1_ind = find(wfp_prs == z1);% Desired isobars in depth 
z2 = 500; z2_ind = find(wfp_prs == z2);
z3 = 750; z3_ind = find(wfp_prs == z3);
z4 = 1000; z4_ind = find(wfp_prs == z4); 
for yr = 1:9
    figure(1)
    subplot(4,4,[1 5])
    plot(-DOresp_rate_umolkg_day{yr},1:max(z),'.')
    hold on
%     p = find(p_value{yr} >= 0.05);
%     plot(DOresp_rate_umolkg_day{yr}(p),p,'.')
    axis ij
    ylabel('Pressure (db)')
    title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
    
    subplot(4,4,[9 13])
    plot(Dprod_days{yr},1:max(z),'Linewidth',1.5)
    hold on
%     plot(Dprod_retimed_days{yr},1:max(z))
    axis ij
    ylabel('Pressure (db)')
    title('Length of D_p_r_o_d (days)')

    subplot(4,4,[2 4])
    plot(resp.time,resp.doxy(z1_ind,:),'.')
    hold on
    plot(resp.time,resp.DO_out_mld(z1_ind,:),'.')
    datetick
    grid on
    ylabel('DO (umol kg^-^1)')

    subplot(4,4,[6 8])
    plot(resp.time,resp.doxy(z2_ind,:),'.')
    hold on
    plot(resp.time,resp.DO_out_mld(z2_ind,:),'.')
    datetick
    grid on
    ylabel('DO (umol kg^-^1)')

    subplot(4,4,[10 12])
    plot(resp.time,resp.doxy(z3_ind,:),'.')
    hold on
    plot(resp.time,resp.DO_out_mld(z3_ind,:),'.')
    datetick
    grid on
    ylabel('DO (umol kg^-^1)')

    subplot(4,4,[14 16])
    plot(resp.time,resp.doxy(z4_ind,:),'.')
    hold on
    plot(resp.time,resp.DO_out_mld(z4_ind,:),'.')
    datetick
    grid on
    ylabel('DO (umol kg^-^1)')

end

%%
z1 = 250; z1_ind = find(wfp_prs == z1);% Desired isobars in depth 
z2 = 500; z2_ind = find(wfp_prs == z2);
z3 = 750; z3_ind = find(wfp_prs == z3);
z4 = 1000; z4_ind = find(wfp_prs == z4); 

    figure
    subplot(4,1,1)
    plot(resp.time,resp.doxy(z1_ind,:),'.')
    hold on
    plot(resp.time,resp.DO_out_mld(z1_ind,:),'.k')
    plot(resp.time(Dprod_end_used{z1}),resp.doxy(z4_ind,Dprod_end_used{z1}),'or','MarkerFaceColor','r')
    plot(resp.time(Dprod_start_used{z1}),resp.doxy(z4_ind,Dprod_start_used{z1}),'*g','Linewidth',1.2)
    datetick
    grid on
    ylabel('DO (umol kg^-^1)')
    title(['Depth = ' num2str(z1)])

    subplot(4,1,2)
    plot(resp.time,resp.doxy(z2_ind,:),'.')
    hold on
    plot(resp.time,resp.DO_out_mld(z2_ind,:),'.k')
    plot(resp.time(Dprod_end_used{z2}),resp.doxy(z4_ind,Dprod_end_used{z2}),'or','MarkerFaceColor','r')
    plot(resp.time(Dprod_start_used{z2}),resp.doxy(z4_ind,Dprod_start_used{z2}),'*g','Linewidth',1.2)
    datetick
    grid on
    ylabel('DO (umol kg^-^1)')
    title(['Depth = ' num2str(z2)])

    subplot(4,1,3)
    plot(resp.time,resp.doxy(z3_ind,:),'.')
    hold on
    plot(resp.time,resp.DO_out_mld(z3_ind,:),'.k')
    plot(resp.time(Dprod_end_used{z3}),resp.doxy(z4_ind,Dprod_end_used{z3}),'or','MarkerFaceColor','r')
    plot(resp.time(Dprod_start_used{z3}),resp.doxy(z4_ind,Dprod_start_used{z3}),'*g','Linewidth',1.2)
    datetick
    grid on
    ylabel('DO (umol kg^-^1)')
    title(['Depth = ' num2str(z3)])

    subplot(4,1,4)
    plot(resp.time,resp.doxy(z4_ind,:),'.')
    hold on
    plot(resp.time,resp.DO_out_mld(z4_ind,:),'.k')
    plot(resp.time(Dprod_end_used{z4}),resp.doxy(z4_ind,Dprod_end_used{z4}),'or','MarkerFaceColor','r')
    plot(resp.time(Dprod_start_used{z4}),resp.doxy(z4_ind,Dprod_start_used{z4}),'*g','Linewidth',1.2)
    datetick
    grid on
    ylabel('DO (umol kg^-^1)')
    title(['Depth = ' num2str(z4)])
    sgtitle('ML Approach')


%%
mycolors = [maroon; red; yellow; green; forestgreen; blue; purple; brightpurple];
for yr = 1:8
    figure(yr)
    set(gcf,'position',[100,100,850,400])
    subplot(1,3,1)
    plot(DOresp_rate_umolkg_day{yr},1:max(z),'.','Color',mycolors(yr,:))
    hold on
%     p = find(p_value{yr} >= 0.05);
%     plot(DOresp_rate_umolkg_day{yr}(p),p,'.')
    axis ij
    ylabel('Pressure (db)')
    title('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
    grid on
    
    subplot(1,3,2)
    plot(Dprod_days{yr},1:max(z),'.','Color',mycolors(yr,:))
    hold on
%     plot(Dprod_retimed_days{yr},1:max(z))
    axis ij
    ylabel('Pressure (db)')
    title('Length of D_p_r_o_d (days)')
    grid on

    subplot(1,3,3)
    plot(DOresp_season_molm3{yr}*-0.69,1:max(z),'.','Color',mycolors(yr,:))
    hold on
    axis ij
    ylabel('Pressure (db)')
    grid on
    title('Total Respired (mol C m^-^3)')
    sgtitle(['Dproduction Year ' num2str(yr)])
end

for yr = 1:8
    figure(1)
    set(gcf,'position',[100,100,1500,400])
    subplot(1,8,yr)
    plot(DOresp_rate_umolkg_day{yr},1:max(z),'.','Color',mycolors(yr,:))
    hold on
    p = find(p_value{yr} >= 0.05);
    plot(DOresp_rate_umolkg_day{yr}(p),p,'.k')
    axis ij
    ylabel('Pressure (db)')
    xlabel(['Year: ' num2str(yr)])
    sgtitle('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
    grid on
end

for yr = 1:8
    figure(2)
    set(gcf,'position',[100,100,1500,400])
    subplot(1,8,yr)
    plot(Dprod_days{yr},1:max(z),'.','Color',mycolors(yr,:))
    hold on
%     plot(Dprod_retimed_days{yr},1:max(z))
    axis ij
    ylabel('Pressure (db)')
        xlabel(['Year: ' num2str(yr)])
    sgtitle('Length of D_p_r_o_d (days)')
    grid on
end

for yr = 1:8
    figure(3)
    set(gcf,'position',[100,100,1500,400])
    subplot(1,8,yr)
    p = find(p_value{yr} < 0.05 & DOresp_rate_umolkg_day{yr} <0);
    plot(DOresp_season_molm3{yr}*-0.69,1:max(z),'.k')
    hold on
    plot(DOresp_season_molm3{yr}(p)*-0.69,p,'.','Color',mycolors(yr,:))
    axis ij
    ylabel('Pressure (db)')
        xlabel(['Year: ' num2str(yr)])
    grid on
    sgtitle('Total Respired (mol C m^-^3)')
end
%% Integration 
DOinventory_molm2 = [];
for yr = 1:8

    p = find(p_value{yr} < 0.05 & DOresp_rate_umolkg_day{yr} <0);
    
    DOinventory_molm2(yr) = min(cumsum(DOresp_season_molm3{yr}(p)));
    figure(1)
    set(gcf,'position',[100,100,500,400])
    subplot(1,8,yr)
    plot(cumsum(DOresp_season_molm3{yr}(p)),p)
    axis ij
    ylabel('Pressure (db)')
    xlabel('Respiration Rate (\mumol DO kg^-^1 d^-^1)')
%     xlim([-0.1 0.05])
    grid on
    title(['Dproduction Year ' num2str(yr)])
end
%%
% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

bar(2014:2021,DOinventory_molm2*-0.69)
hold on
bar(2013,nanmean(DOinventory_molm2*-0.69))
ylabel('ANCP mol C m^-^2 yr^-^1')
box(axes1,'on');
hold(axes1,'off');
set(axes1,'XTick',[2013 2014 2015 2016 2017 2018 2019 2020 2021],...
    'XTickLabel',...
    {'Average','2014','2015','2016','2017','2018','2019','2020','2021'});
title('ANCP using ML approach')

