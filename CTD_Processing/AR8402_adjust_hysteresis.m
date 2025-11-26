clearvars
CTD_sen = 2; 

cd('C:\Users\fogaren\Desktop\Irminger_2024\AR84_02\CTDdata\hyst_tweak\raw_copy')
files = ls('*.cnv');

cast = []; % Read all my processed SBE cast into matlab 
for j = 1:height(files)
    cast{j} = readSBScnv(files(j,:));
end

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
end
%%
close all
% Default = [-0.033, 5000, 1450];
% newH = [-0.025, 5000, 1450];
newH = [-0.020, 5000, 1800];

newH = [-0.020, 5000, 1850];

for j = 1:height(files)
    cast{j} = adjust_hysteresis_KF(cast{j},newH,cal,CTD_sen);
end
%%
function [cast] = adjust_hysteresis_KF(cast,H,cal,CTD_sen)
% H = [-0.033, 5000, 1450]; % Default 

if CTD_sen == 1
    cast.t = cast.t090C;
    cast.cond = cast.c0mScm;
    cast.DOv = cast.sbeox0V;
elseif CTD_sen == 2
    cast.t = cast.t190C;
    cast.cond = cast.c1mScm;
    cast.DOv = cast.sbeox1V;
end

cast.SP = gsw_SP_from_C(cast.cond,cast.t,cast.pm); 
% cast.SA = gsw_SA_from_SP(cast.SP,cast.pm,cast.lon,cast.lat);
% cast.CT = gsw_CT_from_t(cast.SA,cast.t090C,cast.pm);
% cast.DOv = cast.DO_a1v;
     
[cast.oxmLL, cast.oxV] = sbe43oxygen( cast.t, cast.SP, cast.pm, cast.DOv, cast.timeS, cal, [-0.033, 5000, 1450], 'taucorrection','off','hysteresiscorrection','off' );
[cast.oxmLL_defaultH, cast.oxV_defaultH] = sbe43oxygen( cast.t, cast.SP, cast.pm, cast.DOv, cast.timeS, cal, [-0.033, 5000, 1450], 'taucorrection','off','hysteresiscorrection','on' );
[cast.oxmLL_newH, cast.oxV_newH] = sbe43oxygen( cast.t, cast.SP, cast.pm, cast.DOv, cast.timeS, cal, H, 'taucorrection','off','hysteresiscorrection','on' );

figure
ax1 = subplot(1,3,1);
plot(cast.t,cast.pm)
axis ij
ylabel('Pressure')
xlabel('Temp')

ax2 = subplot(1,3,2);
plot(cast.oxV,cast.pm)
axis ij
hold on
plot(cast.oxV_defaultH,cast.pm)
plot(cast.oxV_newH,cast.pm)
xlabel('Oxygen (V)')
% title('Input')

ax3 = subplot(1,3,3);
plot(cast.oxmLL*44.661,cast.pm,'Linewidth',1.5)
hold on
plot(cast.oxmLL_defaultH*44.661,cast.pm,'Linewidth',1.5)
plot(cast.oxmLL_newH*44.661,cast.pm,'Linewidth',1.5)
axis ij
%     xlim([1.5 2.5])
xlabel('Oxygen (umol/L)')
legend('No hyst','Default','Tweaked')

linkaxes([ax3 ax2 ax1],'y')

end