
% Files with oxygen values output in voltages with default hysteresis
% correction 

close all
cd(samp_dir)
files = ls('*.cnv'); % Depends on file naming convention 
cast = [];

a1 = 4; a2 = 5; a3 = 6; % Time lags to try for oxygen
for j = 1:height(files)
    cast = readSBScnv(files(j,:));
    if max(cast.pm) > 250 % Only look at casts deeper than 250 dbar 
        align_CTD_Year12(cast,a1,a2,a3)
    end
end
%% pH sensor lag
close all
% SBE reported sensor response time is 1 second 
p1 = 1; p2 = 2; p3 = 3; % Time lags to try for pH sensor
cast = [];
for j = 1:height(files)
    cast = readSBScnv(files(j,:));
    align_pH_Year12(cast,p1,p2,p3)
end

%%
function align_CTD_Year12(cast,a1,a2,a3) 

SP = gsw_SP_from_C(cast.c0mScm,cast.t090C,cast.pm);
SA = gsw_SA_from_SP(SP,cast.pm,cast.lon,cast.lat);
CT = gsw_CT_from_t(SA,cast.t090C,cast.pm);
cast.pt = gsw_pt_from_CT(SA,CT); 

CastString = ['Cast: ' cast.source(8:10)]; % Depends on file naming convention 

cast.DO_a1v = SBE_alignCTDW(cast.sbeox0V, a1, 1/24 );
cast.DO_a2v = SBE_alignCTDW(cast.sbeox0V, a2, 1/24 );
cast.DO_a3v = SBE_alignCTDW(cast.sbeox0V, a3, 1/24 );

pres = 25; % To remove surface noise from plots 

figure('Position',[ 100 50 1200 600]);
ax1 = subplot(1,6,1);
plot(cast.pt(cast.pm >= pres),cast.pm(cast.pm >= pres))
axis ij
ylabel('Pressure')
xlabel('pot. temp (\circC)')
set(gca,'Fontsize',11)
title('Temp')

ax2 = subplot(1,6,2);
plot(cast.sbeox0V(cast.pm >= pres),cast.pm(cast.pm >= pres))
axis ij
xlabel('Oxygen (V)')
ylabel('Pressure')
set(gca,'Fontsize',11)
title('Oxygen')

ax3 = subplot(1,6,3);
plot(cast.sbeox0V(cast.pm >= pres),cast.pt(cast.pm >= pres))
ylabel('Temp')
xlabel('DO (V)')
title('0 sec align')
set(gca,'Fontsize',11)

ax4 = subplot(1,6,4);
plot(cast.DO_a1v(cast.pm >= pres),cast.pt(cast.pm >= pres))
ylabel('Temp')
xlabel('DO (V)')
title([num2str(a1) ' sec align'])
set(gca,'Fontsize',11)

ax5 = subplot(1,6,5);
plot(cast.DO_a2v(cast.pm >= pres),cast.pt(cast.pm >= pres))
ylabel('Temp')
xlabel('DO (V)')
title([num2str(a2) ' sec align'])
set(gca,'Fontsize',11)

ax6 = subplot(1,6,6);
plot(cast.DO_a3v(cast.pm >= pres),cast.pt(cast.pm >= pres))
ylabel('Temp')
xlabel('DO (V)')
title([num2str(a3) ' sec align'])
sgtitle(CastString)
set(gca,'Fontsize',11)
linkaxes([ax3 ax4 ax5 ax6],'xy')

end

function align_pH_Year12(cast,a1,a2,a3) 

SP = gsw_SP_from_C(cast.c0mScm,cast.t090C,cast.pm);
SA = gsw_SA_from_SP(SP,cast.pm,cast.lon,cast.lat);
CT = gsw_CT_from_t(SA,cast.t090C,cast.pm);
cast.pt = gsw_pt_from_CT(SA,CT); 

CastString = ['Cast: ' cast.source(8:10)]; % Depends on file naming convention 

cast.pH_a1v = SBE_alignCTDW(cast.ph, a1, 1/24 );
cast.pH_a2v = SBE_alignCTDW(cast.ph, a2, 1/24 );
cast.pH_a3v = SBE_alignCTDW(cast.ph, a3, 1/24 );

pres = 25; % To remove surface noise from plots 

figure('Position',[ 100 50 1200 600]);
ax1 = subplot(1,6,1);
plot(cast.pt(cast.pm >= pres),cast.pm(cast.pm >= pres))
axis ij
ylabel('Pressure')
xlabel('pot. temp (\circC)')
set(gca,'Fontsize',11)
title('Temp')

ax2 = subplot(1,6,2);
plot(cast.ph(cast.pm >= pres),cast.pm(cast.pm >= pres))
axis ij
xlabel('pH')
ylabel('Pressure')
set(gca,'Fontsize',11)
title('pH')

ax3 = subplot(1,6,3);
plot(cast.ph(cast.pm >= pres),cast.pt(cast.pm >= pres))
ylabel('Temp')
xlabel('pH')
title('0 sec align')
set(gca,'Fontsize',11)

ax4 = subplot(1,6,4);
plot(cast.pH_a1v(cast.pm >= pres),cast.pt(cast.pm >= pres))
ylabel('Temp')
xlabel('pH')
title([num2str(a1) ' sec align'])
set(gca,'Fontsize',11)

ax5 = subplot(1,6,5);
plot(cast.pH_a2v(cast.pm >= pres),cast.pt(cast.pm >= pres))
ylabel('Temp')
xlabel('pH')
title([num2str(a2) ' sec align'])
set(gca,'Fontsize',11)

ax6 = subplot(1,6,6);
plot(cast.pH_a3v(cast.pm >= pres),cast.pt(cast.pm >= pres))
ylabel('Temp')
xlabel('pH')
title([num2str(a3) ' sec align'])
sgtitle(CastString)
set(gca,'Fontsize',11)
linkaxes([ax3 ax4 ax5 ax6],'xy')

end