clearvars; close all
% Toolbox for transect plotting 
addpath(genpath('G:\My Drive\Matlab_work\Github\CDT'))
% This code using CDT to plot the Irminger Section 
% https://github.com/chadagreene/CDT

load('Fried_Figure8.mat')


%% Whole irminger Section 
cast_num = 2:22;

for i = 1:length(cast_num)  
    lon{i} = downcasts{cast_num(i)}.lon(1);
    lon_doub(i) = downcasts{cast_num(i)}.lon(1);
    lat(i) = downcasts{cast_num(i)}.lat(1);
    DO{i} = downcasts{cast_num(i)}.DOcorr_umolkg;
    DOsat{i} = (downcasts{cast_num(i)}.DOcorr_umolkg./downcasts{cast_num(i)}.O2sol_umolkg)*100;
    prho0{i} = downcasts{cast_num(i)}.prho-1000;
    SA{i} = downcasts{cast_num(i)}.SA;
    prs{i} = downcasts{cast_num(i)}.prs;
    z{i} = -gsw_z_from_p(prs{i},lat(i));
end

% Find max and min before extrapolation 
for i = 1:length(cast_num)
    minsat(i) = min(DOsat{i});
    maxsat(i) = max(DOsat{i});
    minconc(i) = min(DO{i});
    maxconc(i) = max(DO{i});
end

prsinterp = []; DOinterp =[]; DOinterpsat = []; SAinterp =[];
depth = 6:2:3500;
for i = 1:length(cast_num)  
    prsinterp{i} = depth';
    DOinterp{i} = interp1(z{i},DO{i},depth,'nearest','extrap');
    DOinterpsat{i} = interp1(z{i},DOsat{i},depth,'nearest','extrap');
    SAinterp{i} = interp1(z{i},SA{i},depth,'nearest','extrap');
end

% % Better extrapolation for density contours 
z0_all = [];
lon0_all = [];
rho0_all = [];
DO0_all = []; 

for i = 1:length(cast_num)  
    z0 = downcasts{cast_num(i)}.prs;
    lon0 = downcasts{cast_num(i)}.lon;
    rho0 = downcasts{cast_num(i)}.prho - 1000;
    DO0 = downcasts{cast_num(i)}.DOcorr_umolkg;
    z0_all = [z0_all; z0];
    lon0_all = [lon0_all; lon0];
    rho0_all = [rho0_all; rho0];
    DO0_all = [DO0_all; DO0];
end

Frho0 = scatteredInterpolant(lon0_all,z0_all,rho0_all,'linear','nearest');
FDO = scatteredInterpolant(lon0_all,z0_all,DO0_all,'linear','nearest'); 

prho02D = [];
DO2D = []; 
prs2D = [];
for i = 1:length(lon_doub)
    [X,Y] = meshgrid(lon_doub(i),1:2:3500);
    prho02D{i} = Frho0(X,Y);
    DO2D{i} = FDO(X,Y); 
    prs2D{i} = Y;
end

fig = figure;
set(fig,'Position',[100 100 1100 700]) % Set figure size 
fontsize(fig, 12, "points")

subplot(2,1,1)
transect(lon_doub,prsinterp,SAinterp,'color','none','interp','pchip') % Change color if you want to show CTD sample points 
hold on
vals = [ 27.55 27.8];
transectc(lon_doub,prs2D,prho02D,vals,'k','Linewidth',1.1,'ShowText','on')
ax = gca;
set(ax,'clim',[34.85 35.25])
set(ax,'Fontsize',12)
c = colorbar;
ylabel(c,'[g/kg]','Fontsize',12,'Rotation',0)
c.Label.Position = [0.5 35.3];
cmocean('haline')
ylim([0 3250])
xlim([-42 -31.33])
box on
set(ax,'XTickLabel',[])
ylabel('Depth [m]','Fontsize',13)


%Plot bathymetry over everything. 
basevalue = 3500;
bed.Z = -BedM_Irminger_Section.Z;
h4 = area(BedM_Irminger_Section.lon,bed.Z,basevalue);
h4(1).FaceColor = rgb('white');% [0.7 0.7 0.7]; %Creates light grey bathymetry
h4(1).EdgeColor = [0.7 0.7 0.7];
h4(1).LineWidth = 1;
text(-41.75,3000,'(a)','Fontsize',13,'FontWeight','bold')
text(-32.25,2800,'2022','Fontsize',13,'FontWeight','bold')

subplot(2,1,2)
transect(lon_doub,prsinterp,DOinterp,'color','none','interp','pchip') % Change color if you want to show CTD sample points 
hold on
vals = [ 27.55 27.8];
transectc(lon_doub,prs2D,prho02D,vals,'k','Linewidth',1.1,'ShowText','on')
ax = gca;
set(ax,'clim',[235 310])
set(ax,'Fontsize',12)
c = colorbar;
ylabel(c,'[\mumol/kg]','Fontsize',12,'Rotation',0)
c.Label.Position = [0.5 320];
cmocean('thermal')
ylim([0 3250])
xlim([-42 -31.33])
box on
xlabel('Longitude','Fontsize',13)
ylabel('Depth [m]','Fontsize',13)

%Plot bathymetry over everything. 
basevalue = 3500;
bed.Z = -BedM_Irminger_Section.Z;
h4 = area(BedM_Irminger_Section.lon,bed.Z,basevalue);
h4(1).FaceColor = rgb('white');% [0.7 0.7 0.7]; %Creates light grey bathymetry
h4(1).EdgeColor = [0.7 0.7 0.7];
h4(1).LineWidth = 1;
text(-41.75,3000,'(b)','Fontsize',13,'FontWeight','bold')
text(-32.25,2800,'2022','Fontsize',13,'FontWeight','bold')
