clearvars; clc; %close all
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
run('GeneralSettings.m') % For colors

ns = 8; % Start of cast numbers in file name
ne = 10; % End of cast numbers in file name 

%%

% Casts with no hysteresis correction 
cd('C:\Users\fogaren\Documents\SBE_Processing\RR2505\raw\no_hyst')
files = ls('*.cnv');
cast_num = str2num(files(:,ns:ne)); % Pulls out cast numbers 

cast = [];
for j = 1:length(cast_num)
    cast{cast_num(j)} = readSBScnv(files(j,:));
end

%% *** same sensor for all casts ***
% From SBE factory calibration 
% Serial number 3521, 13-Feb-25
cal.SOC = 5.26680e-001;
cal.VOFFSET = -4.81700e-001;
cal.A = -2.87230e-003;
cal.B = 1.28360e-004; 
cal.C = -2.27210e-006;
cal.E = 3.60000e-002;
cal.Tau20 = 1.38000e+000;
cal.INSTRUMENT_TYPE = 'SBE43';
cal.SERIALNO = '3521';
cal.OCALDATE = '13-Feb-25';

H = [-0.033, 5000, 1450]; % Default 
%%
% for j = 1:length(cast_num)
%     x = [cast{cast_num(j)}.sbeox0V, cast{cast_num(j)}.oxsolMm_Kg, cast{cast_num(j)}.t090C, cast{cast_num(j)}.pm];
%     cast{cast_num(j)}.DOuncorr_umolkg = cal.SOC*(x(:,1) + cal.VOFFSET).*x(:,2)...
%         .*(1 + cal.A*x(:,3) + cal.B*x(:,3).^2 + cal.C*x(:,3).^3)...
%         .*exp((cal.E*x(:,4))./(x(:,3) + 273.15));
% end

%%
j = 15
figure
plot(cast{j}.sbox0Mm_Kg,cast{j}.pm)
axis ij

figure
plot(cast{2}.timeS,cast{2}.sbox0Mm_Kg)
hold on
grid on
%%
H = [-0.020, 5000, 1650]; 
for j = 2:22
    [cast{j}.oxy_noH, ~] = sbe43oxygen( cast{j}.t090C, cast{j}.psal0, cast{j}.pm, cast{j}.sbeox0V, cast{j}.timeS, cal, [-0.033, 5000, 1450], 'taucorrection','off','hysteresiscorrection','off' );
    [cast{j}.oxy_H, ~] = sbe43oxygen( cast{j}.t090C, cast{j}.psal0, cast{j}.pm, cast{j}.sbeox0V, cast{j}.timeS, cal, [-0.033, 5000, 1450], 'taucorrection','off','hysteresiscorrection','on' );
    [cast{j}.oxy_newH, ~] = sbe43oxygen( cast{j}.t090C, cast{j}.psal0, cast{j}.pm, cast{j}.sbeox0V, cast{j}.timeS, cal, H, 'taucorrection','off','hysteresiscorrection','on' );

    figure 
ax1 = subplot(1,3,1);
plot(cast{j}.oxy_noH*44.661,cast{j}.pm)
axis ij
grid on

ax2 = subplot(1,3,2);
plot(cast{j}.oxy_H*44.661,cast{j}.pm)
axis ij
grid on 

ax3 = subplot(1,3,3);
plot(cast{j}.oxy_newH*44.661,cast{j}.pm)
axis ij
grid on

linkaxes([ax3 ax2 ax1],'xy')
end
%%

%%
