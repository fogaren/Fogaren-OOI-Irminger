% SBE functional form 
volts1 = 1.89592;
volts2 = 1.9202; 
DO1 = (cal.SOC*(volts1 + cal.VOFFSET))*340*(1 + cal.A*3 + cal.B*(3^2) + cal.C*(3^3))...
    *exp((cal.E*2000)/(3 + 273.15))

DO2 = (cal.SOC*(volts2 + cal.VOFFSET))*340*(1 + cal.A*3 + cal.B*(3^2) + cal.C*(3^3))...
    *exp((cal.E*2000)/(3 + 273.15))
DO2 - DO1

%%

f = figure;
f.Position = [100 100 840 500];
%Plot residuals versus pressure 
subplot(2,2,1)
plot(btlsum_tbl.prs, btlsum_tbl.Winkler1_umolkg,'.','Markersize',20); hold on;
plot(btlsum_tbl.prs, btlsum_tbl.Winkler2_umolkg,'.','Markersize',20); 
plot(btlsum_tbl.prs, btlsum_tbl.Winkler3_umolkg,'.','Markersize',20); 
plot(btlsum_tbl.prs, btlsum_tbl.BTL_OXY_umolkg,'ok','Markersize',7);
ylabel({'Winkler','(\mumol/kg)'})
xlabel('Pressure (db)')
grid on

%Plot residuals versus cast number/time 
subplot(2,2,2)
plot(btlsum_tbl.Cast, btlsum_tbl.Winkler1_umolkg,'.','Markersize',20); hold on;
plot(btlsum_tbl.Cast, btlsum_tbl.Winkler2_umolkg,'.','Markersize',20); 
plot(btlsum_tbl.Cast, btlsum_tbl.Winkler3_umolkg,'.','Markersize',20); 
plot(btlsum_tbl.Cast, btlsum_tbl.BTL_OXY_umolkg,'.','Markersize',20);
ylabel({'Winkler','(\mumol/kg)'})
xlabel('Station Number')
grid on

%Plot residuals versus temperature 
subplot(2,2,3)
plot(btlsum_tbl.t, btlsum_tbl.Winkler1_umolkg,'.','Markersize',20); hold on;
plot(btlsum_tbl.t, btlsum_tbl.Winkler2_umolkg,'.','Markersize',20); 
plot(btlsum_tbl.t, btlsum_tbl.Winkler3_umolkg,'.','Markersize',20); 
plot(btlsum_tbl.t, btlsum_tbl.BTL_OXY_umolkg,'.','Markersize',20);
ylabel({'Winkler','(\mumol/kg)'})
xlabel('Temperature (\circC)')
grid on
subplot(2,2,4)
%Plot residuals versus oxygen concentration 
plot(btlsum_tbl.DOcorr_umolkg, btlsum_tbl.Winkler1_umolkg,'.','Markersize',20); hold on;
plot(btlsum_tbl.DOcorr_umolkg, btlsum_tbl.Winkler2_umolkg,'.','Markersize',20); 
plot(btlsum_tbl.DOcorr_umolkg, btlsum_tbl.Winkler3_umolkg,'.','Markersize',20); 
plot(btlsum_tbl.CTDOXY_umolkg, btlsum_tbl.BTL_OXY_umolkg,'.','Markersize',20);
ylabel({'CTD','(\mumol/kg)'})
xlabel('Winkler DO (\mumol/kg)')
grid on
sgtitle('AR69-03')

%%
figure
plot(nanmean([btlsum_tbl.Winkler1_umolkg btlsum_tbl.Winkler2_umolkg btlsum_tbl.Winkler3_umolkg],2)-btlsum_tbl.BTL_OXY_umolkg,'.','MarkerSize',20)
hold on
grid on
ylabel('BC Replicate Mean - SIO Winkler (umol kg^-^1)')
xlabel('Unique Cast/Bottle #')
%% Look at differences between SIO submitted Irminger Section and my processing
% Doesn't look like the CTD DO has been calibrated in this submitted
% product
cd('G:\Shared drives\NSF_Irminger\OOI Cruises CTD Casts\CTD_Data\Alfresco\AR69-03\SOI_Processed')
file = '33VB20220819_ctd.nc'; % From https://cchdo.ucsd.edu/cruise/33VB20220819

cast = 2:32;
prs = ncread(file,'pressure');
DO_mLL = ncread(file,'ctd_oxygen_ml_l');
SP = ncread(file,'ctd_salinity');
t = ncread(file,'ctd_temperature');
lat = ncread(file,'latitude');
lon = ncread(file,'longitude');

    SA = gsw_SA_from_SP(SP,prs,lon,lat);
    CT = gsw_CT_from_t(SA,t,prs);
    pt = gsw_pt_from_CT(SA,CT);  
    O2sol_umolkg = gsw_O2sol(SA,CT,prs,lon,lat);
    rho = gsw_rho_CT_exact(SA,CT,prs); % in situ density
    prho = gsw_rho_CT_exact(SA,CT,0); % potential density with ref == surf
    sigma0 = gsw_sigma0_CT_exact(SA,CT); % prho - 1000 = sigma0 
%%
downcasts = downcasts_AR6903;
cast = 2:32;
for i = 1:length(cast)
    figure(i)
    plot((DO_mLL(:,i)*44.661*1000)./prho(:,i),prs(:,i))
    hold on
    plot(downcasts{cast(i)}.DOcorr_umolkg,downcasts{cast(i)}.prs)
    plot(DO_mLL(:,i)*43.570,prs(:,i)) % mL/L to umol/kg at a prho of 1.025
    axis ij
    grid on
    legend('SIO','BC','Location','SE')
    title(['Cast: ' num2str(cast(i))])
end



