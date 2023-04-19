%% Multiple linear regression
AR45 = readtable('Winkler AR45.xlsx','sheet','matlab');

% These outliers were identified as not matching w/ replicates
outliers = [21;57;65;66];

% Two additional outliers based on the MLR analysis..
%outliers = [21;57;65;66;30;37];
AR45(outliers,:) = [];

n = height(AR45);
% convert from excel to matlab datenumber 
AR45.daten = 693960+AR45.Date;

% convert seabird to umol kg
AR45.O2_SBE_umolkg = 1000.*44.6596.*AR45.O2_SBE43./AR45.rho0;

% t in days since 01 July, 2020
tref = datenum(2020,7,1);

% The MLR predicts gain
AR45.gain = AR45.O2./AR45.O2_SBE_umolkg;

X = [ones(n,1), AR45.Pressure,AR45.daten-tref];

[b,bint,r,rint,stats] = regress(AR45.gain,X,0.05);


% apply MLR to correct SBE43
AR45.O2_SBE43_corr = AR45.O2_SBE_umolkg.*X*b;


%% Figures for Winkler vs. Corrected SBE43 
rng = [250, 310];
figure;
set(gcf,'Units','centimeters','PaperPositionMode', 'auto','Position',[1 1 14 22]);
subplot(2,1,1);
plot(rng,rng,'k');
hold on;
title(['O_{2,corr} = O2_{raw}(' ,num2str(b(1)),' + ',num2str(b(2)), '(P_{dbar})', '-',abs(num2str(b(2))),'(t_{rel}))']);
box on;
scatter(AR45.O2,AR45.O2_SBE_umolkg,20,'filled');
scatter(AR45.O2,AR45.O2_SBE43_corr,30,AR45.daten-tref,'filled');
colorbar;
legend({'1:1','original','calibrated'},'location','northwest');
legend box off;
xlabel('Winkler O_2');
ylabel('SBE43 O_2');

subplot(2,1,2);
plot(rng,rng,'k');
hold on;
title(['O_{2,corr} = O2_{raw}(' ,num2str(b(1)),' + ',num2str(b(2)), '(P_{dbar})', '-',abs(num2str(b(2))),'(t_{rel}))']);
box on;
scatter(AR45.O2,AR45.O2_SBE_umolkg,20,'filled');
scatter(AR45.O2,AR45.O2_SBE43_corr,30,AR45.Pressure,'filled');
colorbar;
legend({'1:1','original','calibrated'},'location','northwest');
legend box off;
xlabel('Winkler O_2');
ylabel('SBE43 O_2');
caxis([0 2000]);

