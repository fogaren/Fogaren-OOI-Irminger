% Set up workspace 
clearvars
addpath('G:\My Drive\Matlab_work\BC\Irminger\colab-workspace\CTD_Processing')
addpath('G:\My Drive\Matlab_work\BC\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\Functions\GSW')
addpath('C:\Users\fogaren\Desktop')
cd('G:\My Drive\Matlab_work\OSU\GeneralCode')
run('GeneralSettings.m')

% Calculate oxygen sensor lag for CTD alignment 
cd('C:\Users\fogaren\Documents\SBE\Year9')

% Casts 
cast06d = readSBScnv( 'dar69-01_006.cnv' );
cast07d = readSBScnv( 'dar69-01_007.cnv' );
cast08d = readSBScnv( 'dar69-01_008.cnv' );
cast09d = readSBScnv( 'dar69-01_009.cnv' );
cast10d = readSBScnv( 'dar69-01_010.cnv' );
cast11d = readSBScnv( 'dar69-01_011.cnv' );
cast12d = readSBScnv( 'dar69-01_012.cnv' );
cast13d = readSBScnv( 'dar69-01_013.cnv' );
cast14d = readSBScnv( 'dar69-01_014.cnv' );
cast15d = readSBScnv( 'dar69-01_015.cnv' );
cast16d = readSBScnv( 'dar69-01_016.cnv' );
cast17d = readSBScnv( 'dar69-01_017.cnv' );
cast18d = readSBScnv( 'dar69-01_018.cnv' );
cast19d = readSBScnv( 'dar69-01_019.cnv' );
cast20d = readSBScnv( 'dar69-01_020.cnv' );
cast21d = readSBScnv( 'dar69-01_021.cnv' );
cast22d = readSBScnv( 'dar69-01_022.cnv' );
cast23d = readSBScnv( 'dar69-01_023.cnv' );

% Casts 
cast06u = readSBScnv( 'uar69-01_006.cnv' );
cast07u = readSBScnv( 'uar69-01_007.cnv' );
cast08u = readSBScnv( 'uar69-01_008.cnv' );
cast09u = readSBScnv( 'uar69-01_009.cnv' );
cast10u = readSBScnv( 'uar69-01_010.cnv' );
cast11u = readSBScnv( 'uar69-01_011.cnv' );
cast12u = readSBScnv( 'uar69-01_012.cnv' );
cast13u = readSBScnv( 'uar69-01_013.cnv' );
cast14u = readSBScnv( 'uar69-01_014.cnv' );
cast15u = readSBScnv( 'uar69-01_015.cnv' );
cast16u = readSBScnv( 'uar69-01_016.cnv' );
cast17u = readSBScnv( 'uar69-01_017.cnv' );
cast18u = readSBScnv( 'uar69-01_018.cnv' );
cast19u = readSBScnv( 'uar69-01_019.cnv' );
cast20u = readSBScnv( 'uar69-01_020.cnv' );
cast21u = readSBScnv( 'uar69-01_021.cnv' );
cast22u = readSBScnv( 'uar69-01_022.cnv' );
cast23u = readSBScnv( 'uar69-01_023.cnv' );

% Casts 
cast06 = readSBScnv( 'ar69-01_006.cnv' );
cast07 = readSBScnv( 'ar69-01_007.cnv' );
cast08 = readSBScnv( 'ar69-01_008.cnv' );
cast09 = readSBScnv( 'ar69-01_009.cnv' );
cast10 = readSBScnv( 'ar69-01_010.cnv' );
cast11 = readSBScnv( 'ar69-01_011.cnv' );
cast12 = readSBScnv( 'ar69-01_012.cnv' );
cast13 = readSBScnv( 'ar69-01_013.cnv' );
cast14 = readSBScnv( 'ar69-01_014.cnv' );
cast15 = readSBScnv( 'ar69-01_015.cnv' );
cast16 = readSBScnv( 'ar69-01_016.cnv' );
cast17 = readSBScnv( 'ar69-01_017.cnv' );
cast18 = readSBScnv( 'ar69-01_018.cnv' );
cast19 = readSBScnv( 'ar69-01_019.cnv' );
cast20 = readSBScnv( 'ar69-01_020.cnv' );
cast21 = readSBScnv( 'ar69-01_021.cnv' );
cast22 = readSBScnv( 'ar69-01_022.cnv' );
cast23 = readSBScnv( 'ar69-01_023.cnv' );

% Same Oxygen Sensor for whole cruise 
% Calibration standards from SBE xmlcon file 

cal.SOC = double(4.46780e-001);
cal.VOFFSET = double(-5.08600e-001);
cal.A = double(-5.00190e-003);
cal.B = double(2.51320e-004);
cal.C = double(-3.59380e-006);
cal.E = double(3.60000e-002);
cal.Tau20 = double(1.22000e+000);
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '1960';
cal.OCALDATE = '31-Jul-21';

H_default = [-0.033, 5000, 1450]; % Default 
H = [-0.03, 5000, 2050];
%%
castd = cast16d;
castu = cast16u; 
cast = cast16;

figure
plot(castd.t090C,castd.pm)
hold on
plot(castu.t090C,castu.pm)
axis ij

cast.SP = gsw_SP_from_C(cast.c0mScm,cast.t090C,cast.pm);
castd.SP = gsw_SP_from_C(castd.c0mScm,castd.t090C,castd.pm);
castu.SP = gsw_SP_from_C(castu.c0mScm,castu.t090C,castu.pm);
%%
H1 = -0.02:-0.001:-0.05; 
H1 = H1';
H2 = 5000;
H3 = 1200:100:2000; %1000:10:3000; 
H3 = 1450;
H3 = H3';

% Create all possible combinations 
[h1, h2, h3] = ndgrid(1:length(H1), 1:length(H2), 1:length(H3));
h123 = [h1(:),h2(:),h3(:)];
H = [H1(h123(:,1)) H2(h123(:,2)) H3(h123(:,3))];
%%
close all
% RMS = [];
% for i = 1:length(H)
%     [~, castd_volts] = sbe43oxygen( castd.t090C, castd.SP, castd.pm, castd.sbeox0V, castd.timeS, cal, H(i,:), 'taucorrection','off','hysteresiscorrection','on' );
%     [~, castu_volts] = sbe43oxygen( castu.t090C, castu.SP, castu.pm, castu.sbeox0V, castu.timeS, cal, H(i,:), 'taucorrection','off','hysteresiscorrection','on' );
% 
%     ind_down = find(castd.pm > 1000 & castd.pm < 2900);
%     ind_up = find(castu.pm > 1000 & castu.pm < 2900);
% 
% %     [~,ind_down] = sort(castd.pm(ind_down));
% 
% %     [~,ind_up] = sort(castu.pm(ind_up));
% 
%     RMS(i) = mean((castu_volts(ind_up) - castd_volts(ind_down)));
% end

RMS = [];
for i = 1:length(H)
    [~, cast_volts] = sbe43oxygen( cast.t090C, cast.SP, cast.pm, cast.sbeox0V, cast.timeS, cal, H(i,:), 'taucorrection','off','hysteresiscorrection','on' );
    [~, cast_volts_default] = sbe43oxygen( cast.t090C, cast.SP, cast.pm, cast.sbeox0V, cast.timeS, cal, H_default, 'taucorrection','off','hysteresiscorrection','on' );
    [~, cast_volts_nohyst] = sbe43oxygen( cast.t090C, cast.SP, cast.pm, cast.sbeox0V, cast.timeS, cal, H_default, 'taucorrection','off','hysteresiscorrection','off' );
   figure(1)
   clf
   plot(cast_volts,cast.pm)
   hold on
%    plot(cast_volts_default,cast.pm)
   plot(cast_volts_nohyst,cast.pm)
   axis ij
   pause
end

%%
figure(1)
plot(H1,RMS)
[~,min_ind] = find(RMS == min(RMS))
%%
figure(2)
plot(castd_volts(ind_down),castd.pm(ind_down))
hold on
plot(castu_volts(ind_up),castu.pm(ind_up))
title('Optimal')
%%
H = [-0.028, 5000, 1450];
[~, castd_volts] = sbe43oxygen( castd.t090C, castd.SP, castd.pm, castd.sbeox0V, castd.timeS, cal, H,'taucorrection','off','hysteresiscorrection','on' );
[~, castu_volts] = sbe43oxygen( castu.t090C, castu.SP, castu.pm, castu.sbeox0V, castu.timeS, cal, H, 'taucorrection','off','hysteresiscorrection','on' );
[~, cast_volts] = sbe43oxygen( cast.t090C, cast.SP, cast.pm, cast.sbeox0V, cast.timeS, cal, H,'taucorrection','off','hysteresiscorrection','on' );

oxsol_d = sbsoxygensol(castd.t090C,castd.SP,'sbs');
oxsol_u = sbsoxygensol(castu.t090C,castu.SP,'sbs');
oxsol = sbsoxygensol(cast.t090C,cast.SP,'sbs');

x = [castd_volts,oxsol_d,castd.t090C,castd.pm];
DOdown_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.E*x(:,4))./(x(:,3) + 273.15))*44.661;

x = [castu_volts,oxsol_u,castu.t090C,castu.pm];
DOup_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.E*x(:,4))./(x(:,3) + 273.15))*44.661;

x = [cast_volts,oxsol,cast.t090C,cast.pm];
DO_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.E*x(:,4))./(x(:,3) + 273.15))*44.661;

figure(3)
% plot(DOdown_umolkg,castd.pm)
% hold on
% plot(DOup_umolkg,castu.pm)
plot(movmean(DO_umolkg,24*4),cast.pm)
axis ij
title('Optimal')
%%
[~, castd_volts] = sbe43oxygen( castd.t090C, castd.SP, castd.pm, castd.sbeox0V, castd.timeS, cal, H_default,'taucorrection','off','hysteresiscorrection','on' );
[~, castu_volts] = sbe43oxygen( castu.t090C, castu.SP, castu.pm, castu.sbeox0V, castu.timeS, cal, H_default, 'taucorrection','off','hysteresiscorrection','on' );

x = [castd_volts,oxsol_d,castd.t090C,castd.pm];
DOdown_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.E*x(:,4))./(x(:,3) + 273.15))*44.661;

x = [castu_volts,oxsol_u,castu.t090C,castu.pm];
DOup_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
    .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
    .*exp((cal.E*x(:,4))./(x(:,3) + 273.15))*44.661;

figure(3)
plot(DOdown_umolkg,castd.pm)
hold on
plot(DOup_umolkg,castu.pm)
axis ij
title('Default H')

figure(2)
plot(castd_volts,castd.pm)
hold on
plot(castu_volts,castu.pm)
title('Default')
axis ij
    
        % SBE functional form without SOC drift 

