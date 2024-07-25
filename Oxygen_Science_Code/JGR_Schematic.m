

% Remove nan data and create MLDs for every day
% day_dn0 = datenum(blended_mld_daily_all.time);
% day_mld0 = blended_mld_daily_all.mld; 
% day_dn0(isnan(day_mld0)) = [];
% day_mld0(isnan(day_mld0)) = [];
% 
% day_mld = interp1(day_dn0,day_mld0,datenum(blended_mld_daily_all.time),'linear');
% day_mld = round(day_mld); % Because oxygen product is gridded by meter
day_dn = datenum(blended_mld_daily_all.time); 
day_dn = day_dn(1:2741);
day_mld = blended_mld_daily_all.mld;
day_mld = day_mld(1:2741);

% mon_dn = [datenum(2022,05,15,12,00,00)
%     datenum(2022,06,15,00,00,00)
%     datenum(2022,07,15,12,00,00)
%     datenum(2022,08,15,12,00,00)
%     datenum(2022,09,15,00,00,00)
%     datenum(2022,10,15,12,00,00)
%     datenum(2022,11,15,00,00,00)
%     datenum(2022,12,15,12,00,00)
%     datenum(2023,01,15,12,00,00)
%     datenum(2023,02,14,00,00,00)
%     datenum(2023,03,15,12,00,00)
%     datenum(2023,04,15,00,00,00)
%     datenum(2023,05,15,12,00,00)
%     datenum(2023,06,15,00,00,00)];


mon_dn = [datenum(2021,12,15,12,00,00)
    datenum(2022,01,15,00,00,00)
    datenum(2022,02,14,00,00,00)
    datenum(2022,03,15,12,00,00)
    datenum(2022,04,15,00,00,00)
    datenum(2022,05,15,12,00,00)
    datenum(2022,06,15,00,00,00)
    datenum(2022,07,15,12,00,00)
    datenum(2022,08,15,12,00,00)
    datenum(2022,09,15,00,00,00)
    datenum(2022,10,15,12,00,00)
    datenum(2022,11,15,00,00,00)
    datenum(2022,12,15,12,00,00)
    datenum(2023,01,15,12,00,00)
    datenum(2023,02,14,00,00,00)
    datenum(2023,03,15,12,00,00)
    datenum(2023,04,15,00,00,00)
    datenum(2023,05,15,12,00,00)
    datenum(2023,06,15,00,00,00)];

Xmld_mean = [];
mon_order = month(mon_dn);
for j = 1:length(mon_order)
    Xmld_mean(j) = monthly(day_mld,day_dn,mon_order(j),@mean,'omitnan');
    Xmld_std(j) = monthly(day_mld,day_dn,mon_order(j),@std,'omitnan');
end

Xmld_mean_scaled = [];
% Scale the Xmld averaged depth to be correct on the schematic's scale
for j = 1:length(Xmld_mean)
    if Xmld_mean(j) < 50
        Xmld_mean_scaled(j) = Xmld_mean(j)*4;
    elseif Xmld_mean(j) > 50 & Xmld_mean(j) < 100
        Xmld_mean_scaled(j) = ((Xmld_mean(j)-50)*4) + 200;
    elseif Xmld_mean(j) > 100 & Xmld_mean(j) <250
        Xmld_mean_scaled(j) = ((Xmld_mean(j) - 100) *1.333) + 400;
    elseif Xmld_mean(j) > 250 & Xmld_mean(j) < 500
        Xmld_mean_scaled(j) = ((Xmld_mean(j) - 250) *1.333) + 600;
    elseif Xmld_mean(j) > 500 & Xmld_mean(j) < 1000
        Xmld_mean_scaled(j) = ((Xmld_mean(j) - 500) *0.800) + 1000;
    end
end

Xmld_std_high = Xmld_mean + Xmld_std;
Xmld_std_high_scaled = [];
% Scale the Xmld averaged depth to be correct on the schematic's scale
for j = 1:length(Xmld_std_high)
    if Xmld_std_high(j) < 50
        Xmld_std_high_scaled(j) = Xmld_std_high(j)*4;
    elseif Xmld_std_high(j) > 50 & Xmld_std_high(j) < 100
        Xmld_std_high_scaled(j) = ((Xmld_std_high(j)-50)*4) + 200;
    elseif Xmld_std_high(j) > 100 & Xmld_std_high(j) <250
        Xmld_std_high_scaled(j) = ((Xmld_std_high(j) - 100) *1.333) + 400;
    elseif Xmld_std_high(j) > 250 & Xmld_std_high(j) < 500
        Xmld_std_high_scaled(j) = ((Xmld_std_high(j) - 250) *1.333) + 600;
    elseif Xmld_std_high(j) > 500 & Xmld_std_high(j) < 1000
        Xmld_std_high_scaled(j) = ((Xmld_std_high(j) - 500) *0.800) + 1000;
    elseif Xmld_std_high(j) >1000 
        Xmld_std_high_scaled(j) = ((Xmld_std_high(j)-1000) * 0.800) + 1400;
    end
end

Xmld_std_low = Xmld_mean - Xmld_std;
Xmld_std_low_scaled = [];
% Scale the Xmld averaged depth to be correct on the schematic's scale
for j = 1:length(Xmld_std_low)
    if Xmld_std_low(j) < 50
        Xmld_std_low_scaled(j) = Xmld_std_low(j)*4;
    elseif Xmld_std_low(j) > 50 & Xmld_std_low(j) < 100
        Xmld_std_low_scaled(j) = ((Xmld_std_low(j)-50)*4) + 200;
    elseif Xmld_std_low(j) > 100 & Xmld_std_low(j) <250
        Xmld_std_low_scaled(j) = ((Xmld_std_low(j) - 100) *1.333) + 400;
    elseif Xmld_std_low(j) > 250 & Xmld_std_low(j) < 500
        Xmld_std_low_scaled(j) = ((Xmld_std_low(j) - 250) *1.333) + 600;
    elseif Xmld_std_low(j) > 500 & Xmld_std_low(j) < 1000
        Xmld_std_low_scaled(j) = ((Xmld_std_low(j) - 500) *0.800) + 1000;
    elseif Xmld_std_low(j) >1000 
        Xmld_std_low_scaled(j) = ((Xmld_std_low(j)-1000) * 0.800) + 1400;
    end
end

er = [Xmld_mean_scaled'- Xmld_std_low_scaled' Xmld_std_high_scaled' - Xmld_mean_scaled'];
%% Blank depth schematic
figure
axes1 = gca;
set(gcf,'position',[100,100,1000,600])
plot(mon_dn,Xmld_mean_scaled,'k','Linewidth',2)
hold on
plot(mon_dn,Xmld_std_high_scaled,'k--','Linewidth',2)
plot(mon_dn,Xmld_std_low_scaled,'k--','Linewidth',2)
ylim([0 2200])
axis ij
set(axes1,'YTick',[0 200 400 600 1000 1400 1800 2200],...
    'YTickLabel',...
    {'0','50','100','250','500','1000','1500','2000'});
% xlim([dt_test(1) dt_test(end)])
axes1.FontSize = 14;
datetick('x','Keeplimits')
ylabel('Pressure (dbar)')

figure
axes1 = gca;
set(gcf,'position',[100,100,1000,600])
[l,p] = boundedline(mon_dn,Xmld_mean_scaled,er,'alpha');
l.Color = 'k'; l.LineWidth = 2;
p.FaceColor = rgb('grey'); p.FaceAlpha = 0.1;
ylim([0 2200])
axis ij; box on
set(axes1,'YTick',[0 200 400 600 1000 1400 1800 2200],...
    'YTickLabel',...
    {'0','50','100','250','500','1000','1500','2000'});
xlim([datenum(2022,01,01) datenum(2023,06,01)])
axes1.FontSize = 13;
datetick('x','Keeplimits')
ylabel('Pressure (dbar)')

figure
axes1 = gca;
set(gcf,'position',[100,100,1000,500])
[l,p] = boundedline(mon_dn,Xmld_mean_scaled,er,'alpha');
l.Color = 'k'; l.LineWidth = 2;
p.FaceColor = rgb('grey'); p.FaceAlpha = 0.1;
ylim([0 1800])
axis ij; box on
set(axes1,'YTick',[0 200 400 600 1000 1400 1800],...
    'YTickLabel',...
    {'0','50','100','250','500','1000','2000'});
xlim([datenum(2022,01,01) datenum(2023,06,01)])
axes1.FontSize = 13;
datetick('x','Keeplimits')
ylabel('Pressure (dbar)')
%% 
figure
axes1 = gca;
set(gcf,'position',[100,100,1400,500])
plot(mon_dn,Xmld_mean,'k','Linewidth',2)
hold on
plot(mon_dn,Xmld_mean-Xmld_std,'k--','Linewidth',2)
plot(mon_dn,Xmld_mean+Xmld_std,'k--','Linewidth',2)
axis ij
ylim([0 2000])
axis ij
xlim([dt_test(1) dt_test(end)])
axes1.FontSize = 14;
datetick('x','Keeplimits')
ylabel('Pressure (dbar)')