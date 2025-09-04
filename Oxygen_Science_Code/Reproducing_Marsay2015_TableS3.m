% z = [50 150 300 500]; % K2
% poc = [133 53 34 23];

% z = [84 154 402]; % Irminger 
% poc = [2.17 1.68 0.57];

% z = [82 152 402]; % Iceland
% poc = [4.47 2.78 1.49];
% 
z = [51 184 312 446 589]; % papa
poc = [6.99 2.45 1.51 1.31 1.45];
% 
% z = [68 153 154 170 226 342 343 349 364 748];
% poc = [2.95 0.55 0.46 0.56 0.31 0.11 0.11 0.09 0.24 0.08];
% 
% z = [150 300 500]; % Aloha
% poc = [14.5 5.6 4.3];
% b term calculation from log log plot
figure
loglog(z,poc/poc(1),'.')
grid on
bfit = fitlm(log(z'),log(poc'))
% b value = the slope of the log-log plot
% b r2 and P value match those calculated by Marsay 2015 (Table S3)
%% 
% zstar calculation from semi log plot

figure
semilogy(z,poc,'mo')
grid on; hold on
testlm = fitlm(z,log(poc')) % stats match the numbers in Table S3 Marsay 2015
% plot([z(1) z(end)],[0.37 0.37],'k--')

figure
plot(z,poc/poc(1),'mo')
grid on; hold on
testlm = fitlm(z,log(poc')) % stats match the numbers in Table S3 Marsay 2015
% plot([z(1) z(end)],[0.37 0.37],'k--')


% not sure how to convert these coefficients to z star numbers. 

zdeep = 200;
z0 = 100; 
Fzdeep = exp((testlm.Coefficients.Estimate(2)+0)*zdeep+testlm.Coefficients.Estimate(1))
Fz0 = exp((testlm.Coefficients.Estimate(2)+0)*z0+testlm.Coefficients.Estimate(1))

FzdeepSE = exp((testlm.Coefficients.Estimate(2)+testlm.Coefficients.SE(2))*zdeep+testlm.Coefficients.Estimate(1))
Fz0SE = exp((testlm.Coefficients.Estimate(2)+testlm.Coefficients.SE(2))*z0+testlm.Coefficients.Estimate(1))

-(zdeep-z0)/log(Fzdeep/Fz0)
-(zdeep-z0)/log(FzdeepSE/Fz0SE) - (-(zdeep-z0)/log(Fzdeep/Fz0))
%%
figure
plot(z,poc./Fz0,'ok')
hold on
plot(zdeep,Fzdeep./Fz0,'-')
grid on
% zstar = find(Fzdeep <= (0.37*Fz0),1)


[testfit,gof] = fit(z',poc'/poc(1),'1*exp(-(x-84)/b)')

figure
plot(z,poc./Fz0,'ok')
hold on
plot(testfit)
%%
fitlm(z,(-(z-84)./(poc/Fz0)))


%%
hold on
plot(log(exp(testlm.Coefficients.Estimate(2)*(50:500)+testlm.Coefficients.Estimate(1))/exp(testlm.Coefficients.Estimate(2)*84+testlm.Coefficients.Estimate(1))))
%%
[k2fit,gof] = fit(z',poc'/poc(1),'exp1')

z = 50:500;
fit(z',k2fit.a*(exp(k2fit.b*z')),'a*exp(-(x-50)/b)')
%%

aloha_z = [150 300 500];
aloha_poc = [14.5 5.6 4.3];

figure
loglog(aloha_z,aloha_poc,'.r')
grid on

osp_z = [50 100 150 200];
osp_poc = [97 36 31 22];

figure
loglog(osp_z,osp_poc,'.m')
grid on
%fit(mean_depth_to_use',C_total_remin_mean(50:1149)','a*exp(-(x-50)/b)')


alohafit = fitlm(log(aloha_z/100'),log(aloha_poc'))
[ospfit] = fitlm(log(osp_z'),log(osp_poc'))

%%

[ospfit,gof] = fit(osp_z',osp_poc','a*exp(-(x-50)/b)')
figure
loglog(osp_z,osp_poc,'.m')
grid on
%%
for j = 3; %1:length(atten_pulses_good);
    pulsecarbon = sinkingpulse_max_gaussfilter_omitnan(:,1,atten_pulses_good(j))*35400*54;
    [pulsefit] = fitlm(wfpmerge.sinkingpulsedepths,log(pulsecarbon))
    [pulsefit2, gof2] = fit(wfpmerge.sinkingpulsedepths,pulsecarbon/pulsecarbon(1),'1*exp(-(x-200)/b)')
    figure(1)
    semilogy(wfpmerge.sinkingpulsedepths,pulsecarbon,'.','Markersize',20)
    hold on
    grid on
end

% figure(2)
% loglog(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan_mean*35400*54,'.k','Markersize',20)
% [pulsefitmean] = fitlm(log(wfpmerge.sinkingpulsedepths(1:4)),log(sinkingpulse_max_gaussfilter_omitnan_mean(1:4)*35400*54))
%%
 
for j = 1:6
pulsecarbonmean = sinkingpulse_max_gaussfilter_omitnan(:,1,atten_pulses_good(j))*35400*54;
test = fit(wfpmerge.sinkingpulsedepths,pulsecarbonmean,'a*exp(-(x-225)/b)')

figure(j)
plot(wfpmerge.sinkingpulsedepths,(pulsecarbonmean),'ok')
test2 = fitlm(wfpmerge.sinkingpulsedepths,(pulsecarbonmean))
grid on
hold on
plot([100 2000],[0.37*test2.Coefficients.Estimate(1) 0.37*test2.Coefficients.Estimate(1)],'k--')
end


pulsecarbonmean = sinkingpulse_max_gaussfilter_omitnan_mean;
test = fit(wfpmerge.sinkingpulsedepths,pulsecarbonmean,'a*exp(-(x-225)/b)')

figure(7)
plot(wfpmerge.sinkingpulsedepths,log(pulsecarbonmean),'ok')
test2 = fitlm(wfpmerge.sinkingpulsedepths,log(pulsecarbonmean))
grid on
hold on
plot([100 2000],[0.37*test2.Coefficients.Estimate(1) 0.37*test2.Coefficients.Estimate(1)],'k--')
%%
j = 3
pulsecarbon = sinkingpulse_max_gaussfilter_omitnan(:,1,atten_pulses_good(j))*35400*54;
ztest = wfpmerge.sinkingpulsedepths(1):5:wfpmerge.sinkingpulsedepths(end);
ztest = ztest';
carboninterp = interp1(wfpmerge.sinkingpulsedepths,pulsecarbon,ztest);
test2 = fit(ztest,carboninterp,'a*exp(-(x-225)/b)')