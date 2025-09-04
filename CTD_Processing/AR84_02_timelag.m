clearvars
addpath('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\CTD_Processing')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird_Oxygen_Toolbox')
addpath('G:\My Drive\Matlab_work\Github\Sea-Bird-Toolbox')
addpath(genpath('G:\My Drive\Matlab_work\Github\GSW-Matlab'))
%% Factory sensor calibrations 
% For first sensor 
% From SBE factory calibration 
% Serial number 0072, Calibration Date 3-Oct-2023
cal1.SOC = 4.63190e-001;
cal1.VOFFSET = -4.88200e-001;
cal1.A = -5.35510e-003;
cal1.B = 2.42950e-004; 
cal1.C = -3.49330e-006;
cal1.E = 3.60000e-002;
cal1.Tau20 = 1.19000e+000;
cal1.INSTRUMENT_TYPE = 'SBE43';
cal1.SERIALNO = '0072';
cal1.OCALDATE = '03-Oct-2023';

% For second sensor 
% From SBE factory calibration 
% Serial number 0449, Calibration Date 06-Mar-24
cal2.SOC = 3.81570e-001;
cal2.VOFFSET = -7.17000e-001;
cal2.A = -3.49850e-003;
cal2.B = 1.49470e-004; 
cal2.C = -2.69920e-006;
cal2.E = 3.60000e-002;
cal2.Tau20 = 1.12000e+000;
cal2.INSTRUMENT_TYPE = 'SBE43';
cal2.SERIALNO = '0449';
cal2.OCALDATE = '06-Mar-24';

%% Default hysteresis check
% Convert files using no hysteresis correction and read in 
cd('C:\Users\fogaren\Documents\SBE_Processing\AR84-02\no_hyst')
files = ls('*.cnv');
cast = [];
for j = 1:length(files)
    cast{j} = readSBScnv(files(j,:));
    cast{j}.SP1 = gsw_SP_from_C(cast{j}.c0mScm,cast{j}.t090C,cast{j}.pm);
    cast{j}.SP2 = gsw_SP_from_C(cast{j}.c1mScm,cast{j}.t190C,cast{j}.pm);
end

%%
H = [-0.033, 5000, 1450]; % Default 
Hadj = [-0.033, 5000, 1800]; % Adjusted hysteresis correction 
for j = 1:length(files)
    [cast{j}.oxmLL1_nohyst, cast{j}.oxyvolts1_nohyst] = sbe43oxygen( cast{j}.t090C, cast{j}.SP1, cast{j}.pm, cast{j}.sbeox0V, cast{j}.timeS, cal1, H, 'taucorrection','off','hysteresiscorrection','off' );
    [cast{j}.oxmLL1_default, cast{j}.oxyvolts1_default] = sbe43oxygen( cast{j}.t090C, cast{j}.SP1, cast{j}.pm, cast{j}.sbeox0V, cast{j}.timeS, cal1, H, 'taucorrection','off','hysteresiscorrection','on' );
    [cast{j}.oxmLL1_adj, cast{j}.oxyvolts1_adj] = sbe43oxygen( cast{j}.t090C, cast{j}.SP1, cast{j}.pm, cast{j}.sbeox0V, cast{j}.timeS, cal1, Hadj, 'taucorrection','off','hysteresiscorrection','on' );
    cast{j}.oxumolL1_nohyst = cast{j}.oxmLL1_nohyst*44.661;
    cast{j}.oxumolL1_default = cast{j}.oxmLL1_default*44.661;
    cast{j}.oxumolL1_adj = cast{j}.oxmLL1_adj*44.661;
    
    [cast{j}.oxmLL2_nohyst, cast{j}.oxyvolts2_nohyst] = sbe43oxygen( cast{j}.t190C, cast{j}.SP2, cast{j}.pm, cast{j}.sbeox1V, cast{j}.timeS, cal2, H, 'taucorrection','off','hysteresiscorrection','off' );
    [cast{j}.oxmLL2_default, cast{j}.oxyvolts2_default] = sbe43oxygen( cast{j}.t190C, cast{j}.SP2, cast{j}.pm, cast{j}.sbeox1V, cast{j}.timeS, cal2, H, 'taucorrection','off','hysteresiscorrection','on' );
    [cast{j}.oxmLL2_adj, cast{j}.oxyvolts2_adj] = sbe43oxygen( cast{j}.t190C, cast{j}.SP2, cast{j}.pm, cast{j}.sbeox1V, cast{j}.timeS, cal2, Hadj, 'taucorrection','off','hysteresiscorrection','on' );
    cast{j}.oxumolL2_nohyst = cast{j}.oxmLL2_nohyst*44.661;
    cast{j}.oxumolL2_default = cast{j}.oxmLL2_default*44.661;
    cast{j}.oxumolL2_adj = cast{j}.oxmLL2_adj*44.661;
end

%%
for j = 20:30

    figure
    ax1 = subplot(1,2,1);
    % plot(cast{j}.oxyvolts1_nohyst,cast{j}.pm)
    % hold on
    % plot(cast{j}.oxyvolts1_default,cast{j}.pm)
    % axis ij
    % plot(cast{j}.oxyvolts1_adj,cast{j}.pm)
    % grid on
    plot(cast{j}.t090C,cast{j}.pm,'Linewidth',1.2)
    hold on
    plot(cast{j}.t190C,cast{j}.pm,'Linewidth',1.2)
    axis ij
    grid on
    
    ax2 = subplot(1,2,2);
    plot(cast{j}.oxumolL1_nohyst,cast{j}.pm,'Linewidth',1.2)
    hold on
    plot(cast{j}.oxumolL1_default,cast{j}.pm,'Linewidth',1.2)
    plot(cast{j}.oxumolL1_adj,cast{j}.pm,'Linewidth',1.2)
    plot(cast{j}.oxumolL2_nohyst,cast{j}.pm,'Linewidth',1.2)
    plot(cast{j}.oxumolL2_default,cast{j}.pm,'Linewidth',1.2)
    axis ij
    plot(cast{j}.oxumolL2_adj,cast{j}.pm,'Linewidth',1.2)
    grid on
    sgtitle(['Filenumber: ' num2str(j)])
    linkaxes([ax1 ax2],'y')
end
%%
clearvars
cd('C:\Users\fogaren\Documents\SBE_Processing\AR84-02\raw') % location of cnv files on computer 
a1 = 4; a2 = 5; a3 = 6; % Timelags you want to try 

pack_num = 1; % 1 or 2 since two CTD-DO packages 
files = ls('*.cnv');
cast = [];
for i = 1:length(files)-100
    cast = readSBScnv(files(i,:));
    if max(cast.pm) > 250 % Only looks at casts deeper than 250
        align_CTD_DO(cast,a1,a2,a3,pack_num)
    end
end
%%
function align_CTD_DO(cast,a1,a2,a3,pack_sen) 

cast.pm(cast.pm < 0) = 0; % Sets neg values to 0 for GSW processing
lon = 135;
lat = 60;
% can look at oxygen in pot. temp or density space 
SP1 = gsw_SP_from_C(cast.c0mScm,cast.t090C,cast.pm);
SA1 = gsw_SA_from_SP(SP1,cast.pm,lon,lat);
CT1 = gsw_CT_from_t(SA1,cast.t090C,cast.pm);
SP2 = gsw_SP_from_C(cast.c1mScm,cast.t190C,cast.pm);
SA2 = gsw_SA_from_SP(SP2,cast.pm,lon,lat);
CT2 = gsw_CT_from_t(SA2,cast.t190C,cast.pm);

cast.pt1 = gsw_pt_from_CT(SA1,CT1); 
cast.prho1 = gsw_rho_CT_exact(SA1,CT1,0);
cast.pt2 = gsw_pt_from_CT(SA2,CT2); 
cast.prho2 = gsw_rho_CT_exact(SA2,CT2,0);

CastString = ['Cast: ' cast.source(end-6:end-4)]; 

% Function from Sea-Brid-Toolbox 
cast.DO1_a1v = SBE_alignCTDW(cast.sbeox0V, a1, 1/24 );
cast.DO1_a2v = SBE_alignCTDW(cast.sbeox0V, a2, 1/24 );
cast.DO1_a3v = SBE_alignCTDW(cast.sbeox0V, a3, 1/24 );

% Function from Sea-Brid-Toolbox 
cast.DO2_a1v = SBE_alignCTDW(cast.sbeox1V, a1, 1/24 );
cast.DO2_a2v = SBE_alignCTDW(cast.sbeox1V, a2, 1/24 );
cast.DO2_a3v = SBE_alignCTDW(cast.sbeox1V, a3, 1/24 );

pres = 25; % To remove surface noise from plots 

figure('Position',[ 100 50 1200 600]);
subplot(1,6,1)
if pack_sen == 1
    plot(cast.prho1(cast.pm >= pres),cast.pm(cast.pm >= pres))
elseif pack_sen == 2
    plot(cast.prho2(cast.pm >= pres),cast.pm(cast.pm >= pres))
end
axis ij
ylabel('Pressure')
xlabel('Pot. Density')

subplot(1,6,2)
if pack_sen == 1
    plot(cast.sbeox0V(cast.pm >= pres),cast.pm(cast.pm >= pres))
elseif pack_sen == 2
    plot(cast.sbeox1V(cast.pm >= pres),cast.pm(cast.pm >= pres))
end
axis ij
xlabel('Oxygen (V)')

subplot(1,6,3)
if pack_sen == 1
    % plot(cast.sbeox0V(cast.pm >= pres),cast.prho1(cast.pm >= pres))
    plot(cast.sbeox0V(cast.pm >= pres),cast.pt1(cast.pm >= pres))
elseif pack_sen == 2
    % plot(cast.sbeox1V(cast.pm >= pres),cast.prho2(cast.pm >= pres))
    plot(cast.sbeox1V(cast.pm >= pres),cast.pt2(cast.pm >= pres))
end
ylabel('Pot. Density')
xlabel('DO (V)')
title('0 sec align')

subplot(1,6,4)
if pack_sen == 1
    % plot(cast.DO1_a1v(cast.pm >= pres),cast.prho1(cast.pm >= pres))
    plot(cast.DO1_a1v(cast.pm >= pres),cast.pt1(cast.pm >= pres))
elseif pack_sen == 2
    % plot(cast.DO2_a1v(cast.pm >= pres),cast.prho2(cast.pm >= pres))
    plot(cast.DO2_a1v(cast.pm >= pres),cast.pt2(cast.pm >= pres))
end
ylabel('Pot. Density')
xlabel('DO (V)')
title([num2str(a1) ' sec align'])

subplot(1,6,5)
if pack_sen == 1
    % plot(cast.DO1_a2v(cast.pm >= pres),cast.prho1(cast.pm >= pres))
    plot(cast.DO1_a2v(cast.pm >= pres),cast.pt1(cast.pm >= pres))
elseif pack_sen == 2
    % plot(cast.DO2_a2v(cast.pm >= pres),cast.prho2(cast.pm >= pres))
    plot(cast.DO2_a2v(cast.pm >= pres),cast.pt2(cast.pm >= pres))
end
ylabel('Pot. Density')
xlabel('DO (V)')
title([num2str(a2) ' sec align'])

subplot(1,6,6)
if pack_sen == 1
    % plot(cast.DO1_a3v(cast.pm >= pres),cast.prho1(cast.pm >= pres))
    plot(cast.DO1_a3v(cast.pm >= pres),cast.pt1(cast.pm >= pres))
elseif pack_sen == 2
    % plot(cast.DO2_a3v(cast.pm >= pres),cast.prho2(cast.pm >= pres))
    plot(cast.DO2_a3v(cast.pm >= pres),cast.pt2(cast.pm >= pres))
end
ylabel('Pot. Density')
xlabel('DO (V)')
title([num2str(a3) ' sec align'])
sgtitle(CastString)

end