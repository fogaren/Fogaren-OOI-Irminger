clearvars; clc; close all
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
run('GeneralSettings.m') % For colors

ns = 9; % Start of cast numbers in file name
ne = 11; % End of cast numbers in file name 
CTD_sen = 1;
%%

% Casts with no hysteresis correction 
cd('C:\Users\fogaren\Documents\SBE_Processing\AR84-02\cnv\no_hyst')
files = ls('*.cnv');
cast_num = str2num(files(:,ns:ne)); % Pulls out cast numbers 

cast = [];
for j = 1:length(cast_num)
    cast{cast_num(j)} = readSBScnv(files(j,:));
end
%%
CTD_sen = 2;
if CTD_sen == 1
    % Oxygen, SBE 43
    % From SBE factory calibration 
    % Serial number 0449, Calibration Date 06-Mar-24
    cal.SOC = 4.63190e-001;
    cal.VOFFSET = -4.88200e-001;
    cal.A = -5.35510e-003;
    cal.B = 2.42950e-004; 
    cal.C = -3.49330e-006;
    cal.E = 3.60000e-002;
    cal.Tau20 = 1.19000e+000;
    cal.INSTRUMENT_TYPE = 'SBE43';
    cal.SERIALNO = '0072';
    cal.OCALDATE = '03-Oct-23';
    cal0 = cal; 
elseif CTD_sen == 2
    % Oxygen, SBE 43, 2
    % From SBE factory calibration 
    % Serial number 0449, Calibration Date 06-Mar-24
    cal.SOC = 3.81570e-001;
    cal.VOFFSET = -7.17000e-001;
    cal.A = -3.49850e-003;
    cal.B = 1.49470e-004; 
    cal.C = -2.69920e-006;
    cal.E = 3.60000e-002;
    cal.Tau20 = 1.12000e+000;
    cal.INSTRUMENT_TYPE = 'SBE43';
    cal.SERIALNO = '0449';
    cal.OCALDATE = '06-Mar-24';
    cal0 = cal; 
end
%%

a1 = 4; a2 = 5; a3 = 6; % Time lags to try for oxygen
for j = min(cast_num):max(cast_num)
    if max(cast{j}.pm) > 2000 % Only look at casts deeper than 250 dbar 
        cast{j} = align_CTD_Year11(cast{j},a1,a2,a3);
    end
end

%% 
pres = 25; 
H = [-0.015, 5000, 1050]; 
H = [-0.015, 5000, 1850]; 
for j = min(cast_num):max(cast_num)
    if max(cast{j}.pm > 2000)
        cast{j}.volts_used = cast{j}.DO_a1v; %sbeox0V;
        cast{j}.psal0 = gsw_SP_from_C(cast{j}.c0mScm,cast{j}.t090C,cast{j}.pm);
        [cast{j}.oxy_noH, ~] = sbe43oxygen( cast{j}.t090C, cast{j}.psal0, cast{j}.pm, cast{j}.volts_used, cast{j}.timeS, cal, [-0.033, 5000, 1450], 'taucorrection','off','hysteresiscorrection','off' );
        [cast{j}.oxy_H, ~] = sbe43oxygen( cast{j}.t090C, cast{j}.psal0, cast{j}.pm, cast{j}.volts_used, cast{j}.timeS, cal,  [-0.033, 5000, 1450], 'taucorrection','off','hysteresiscorrection','on' );
        [cast{j}.oxy_newH, ~] = sbe43oxygen( cast{j}.t090C, cast{j}.psal0, cast{j}.pm, cast{j}.volts_used, cast{j}.timeS, cal, H, 'taucorrection','off','hysteresiscorrection','on' );
    
        figure 
        ax1 = subplot(1,3,1);
        plot(cast{j}.oxy_noH(cast{j}.pm >= pres)*44.661,cast{j}.pm(cast{j}.pm >= pres))
        axis ij
        grid on
        
        ax2 = subplot(1,3,2);
        plot(cast{j}.oxy_H(cast{j}.pm >= pres)*44.661,cast{j}.pm(cast{j}.pm >= pres))
        axis ij
        grid on 
        
        ax3 = subplot(1,3,3);
        plot(cast{j}.oxy_newH(cast{j}.pm >= pres)*44.661,cast{j}.pm(cast{j}.pm >= pres))
        axis ij
        grid on
        
        linkaxes([ax3 ax2 ax1],'xy')
    end

end
%%
function cast = align_CTD_Year11(cast,a1,a2,a3) 
cast.volts_used = cast.sbeox1V; 
SP = gsw_SP_from_C(cast.c0mScm,cast.t090C,cast.pm);
SA = gsw_SA_from_SP(SP,cast.pm,cast.lon,cast.lat);
CT = gsw_CT_from_t(SA,cast.t090C,cast.pm);
cast.pt = gsw_pt_from_CT(SA,CT); 

CastString = ['Cast: ' cast.source(9:11)]; % Depends on file naming convention 

cast.DO_a1v = SBE_alignCTDW(cast.volts_used, a1, 1/24 );
cast.DO_a2v = SBE_alignCTDW(cast.volts_used, a2, 1/24 );
cast.DO_a3v = SBE_alignCTDW(cast.volts_used, a3, 1/24 );

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
plot(cast.volts_used(cast.pm >= pres),cast.pm(cast.pm >= pres))
axis ij
xlabel('Oxygen (V)')
ylabel('Pressure')
set(gca,'Fontsize',11)
title('Oxygen')

ax3 = subplot(1,6,3);
plot(cast.volts_used(cast.pm >= pres),cast.pt(cast.pm >= pres))
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
set(gca,'Fontsize',11)
linkaxes([ax3 ax4 ax5 ax6],'xy')
sgtitle(CastString)
end


%%
