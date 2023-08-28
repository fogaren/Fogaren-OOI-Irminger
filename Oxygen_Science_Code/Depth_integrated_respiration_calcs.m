% Calculate Depth integrated O2 inventory 
cd('G:\My Drive\Matlab_work\BC\Fogaren-OOI-Irminger\Oxygen_Science_Code')
load RespirationFits_GRC_July2023.mat
% Redo fits when have data on isopycnals 
% Need to run WFP_oxygen_respiration_isobars.m first 
%%
% units of x are umol/L and y are depth (m) 
mldmax_yr = [1390; 1430; 950; 1335; 510; 805; 440]; % max chl measured MLD
% ^ not sure if in prs or m; needs to be checked for finalization 
% MLD mean is 980 
% Calculate inventory for 200 to 1000 m 
int_depth = 200:1:1000; 

intmean = integrate(fitmean,int_depth,200); % fit for all data 
intmean_1000 = intmean(int_depth == 1000); % integrated to 1000 m 
intmean_MLDmean = intmean(int_depth == floor(mean(mldmax_yr)))/1000; % umol/L*m to mol/m2
intmean_1000_C = intmean_1000/1.4; % O2:C ratio of 1.4, Laws 1991
intmean_MLDmean_C = intmean_MLDmean/1.4;

int1 = integrate(fit1,int_depth,200);
int1_1000 = int1(int_depth == 1000)/1000; % umol/L*m to mol/m2;
int1_1000_C = int1_1000/1.4; % O2:C ratio of 1.4, Laws 1991
% MLD Max is greater than 1000; redo when using resp rates for whole depth profile
% int1_MLD = int1(int_depth == mldmax_yr(1))/1000; % umol/L*m to mol/m2; 

int2 = integrate(fit2,int_depth,200);
int2_1000 = int2(int_depth == 1000)/1000; % umol/L*m to mol/m2;
int2_1000_C = int2_1000/1.4; % O2:C ratio of 1.4, Laws 1991
% MLD Max is greater than 1000; redo when using resp rates for whole depth profile
% int2_MLD = int2(int_depth == mldmax_yr(2))/1000; % umol/L*m to mol/m2; 

int3 = integrate(fit3,int_depth,200);
int3_1000 = int3(int_depth == 1000)/1000; % umol/L*m to mol/m2;
int3_MLD = int3(int_depth == mldmax_yr(3))/1000; % umol/L*m to mol/m2; 
int3_1000_C = int3_1000/1.4; % O2:C ratio of 1.4, Laws 1991
int3_MLD_C = int3_MLD/1.4; 

int4 = integrate(fit4,int_depth,200);
int4_1000 = int4(int_depth == 1000)/1000; % umol/L*m to mol/m2;
% MLD Max is greater than 1000; redo when using resp rates for whole depth profile
% int4_MLD = int4(int_depth == mldmax_yr(4))/1000; % umol/L*m to mol/m2; 
int4_1000_C = int4_1000/1.4; % O2:C ratio of 1.4, Laws 1991

int5 = integrate(fit5,int_depth,200);
int5_1000 = int5(int_depth == 1000)/1000; % umol/L*m to mol/m2;
int5_MLD = int5(int_depth == mldmax_yr(5))/1000; % umol/L*m to mol/m2;
int5_1000_C = int5_1000/1.4; % O2:C ratio of 1.4, Laws 1991
int5_MLD_C = int5_MLD/1.4; 

int6 = integrate(fit6,int_depth,200);
int6_1000 = int6(int_depth == 1000)/1000; % umol/L*m to mol/m2;
int6_MLD = int6(int_depth == mldmax_yr(6))/1000; % umol/L*m to mol/m2; 
int6_1000_C = int6_1000/1.4; % O2:C ratio of 1.4, Laws 1991
int6_MLD_C = int6_MLD/1.4; 

int7 = integrate(fit7,int_depth,200);
int7_1000 = int7(int_depth == 1000)/1000; % umol/L*m to mol/m2;
int7_MLD = int7(int_depth == mldmax_yr(7))/1000; % umol/L*m to mol/m2;
int7_1000_C = int7_1000/1.4; % O2:C ratio of 1.4, Laws 1991
int7_MLD_C = int7_MLD/1.4; 
%%
% mldmax_yr = [1390; 1430; 950; 1335; 510; 805; 440]; % max chl measured MLD
int_1000 = [int1_1000; int2_1000; int3_1000; int4_1000; int5_1000; int6_1000; int7_1000];
int_MLD = [int1_1000; int2_1000; int3_MLD; int4_1000; int5_MLD; int6_MLD; int7_MLD];
int_1000_C = int_1000/1.4;
int_MLD_C = int_MLD/1.4; 
int_resp_C = int_1000_C - int_MLD_C;
int_resp_Cper = int_MLD_C./int_1000_C*100;
%%
mldmax_yr = [1390; 1430; 950; 1335; 510; 805; 440];% max chl measured MLD up to 1000 max limit 
MLDind = [];
for i = 1:length(mldmax_yr)
    [MLD, MLDind(i)] = min(abs(DOresp_m - mldmax_yr(i)));  
end
figure(2)
clf
for yr = 1:7
   subplot(1,7,yr)
    b = barh(DOresp_m,DOresp_all(yr,:)); hold on
    b.FaceColor = grey; b.LineStyle = 'none'; b.BarWidth = 2;
    b2 = barh(DOresp_m(1:MLDind(yr)),DOresp_all(yr,1:MLDind(yr)));
    b2.FaceColor = blue; b2.LineStyle = 'none'; b2.BarWidth = 2;
    plot(meanDOresp,iso,'--k','Linewidth',2)
    text(13,750,'\Sigma_M_L_D = ','Fontsize',15)
    text(13,800,[num2str(round(int_MLD_C(yr),1)) ' mol C m^-^2'],'Fontsize',14)
    text(13,900,'\Sigma_1_0_0_0_m = ','FontSize',15)
    text(13,950,[num2str(round(int_1000_C(yr),1)) ' mol C m^-^2'],'Fontsize',14)
    axis ij
    ylim([200 1000])
    xlim([0 35])
    grid on; 
    if yr == 1
    ylabel('Depth (m)')
    end
    xlabel('DO decrease (\mumol L^-^1)')
    title([num2str(yr + 2014)],'Fontsize',16)% ' stratified season'])
    f = gca; f.FontSize = 13.5;
end
sgtitle('Respiration in the seasonal thermocline','Fontsize',18,'FontWeight','Bold')


