%%
yr = 2; % Deployment year 

z1 = 250; 
z2 = 500; 
z3 = 750;

z1_ind = find(wfp_prs == z1); % Finds the index of that depth
regress_ind_z1 = regress_resp{z1}.start(yr):regress_resp{z1}.end(yr); 

temp_detrended = detrend(resp.temp(z1_ind,regress_ind_z1),'omitnan');
bad_temp_z1 = isoutlier(temp_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z1));
prho_detrended = detrend(resp.prho(z1_ind,regress_ind_z1),'omitnan');
bad_prho_z1 = isoutlier(prho_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z1));
doxy_detrended = detrend(resp.doxy(z1_ind,regress_ind_z1),'omitnan');
bad_doxy_z1 = isoutlier(doxy_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z1));

mdl_z1 = fitlm(resp.time(regress_ind_z1(bad_prho_z1 == 0 & bad_doxy_z1 == 0)),resp.doxy(z1_ind,regress_ind_z1(bad_prho_z1 == 0 & bad_doxy_z1 == 0)));

z2_ind = find(wfp_prs == z2); % Finds the index of that depth
regress_ind_z2 = regress_resp{z2}.start(yr):regress_resp{z2}.end(yr); 
% dt_days = resp.time(regress_ind_z2) - resp.time(regress_resp{z2}.start(yr));

temp_detrended = detrend(resp.temp(z2_ind,regress_ind_z2),'omitnan');
bad_temp_z2 = isoutlier(temp_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z2));
prho_detrended = detrend(resp.prho(z2_ind,regress_ind_z2),'omitnan');
bad_prho_z2 = isoutlier(prho_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z2));
doxy_detrended = detrend(resp.doxy(z2_ind,regress_ind_z2),'omitnan');
bad_doxy_z2 = isoutlier(doxy_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z2));

mdl_z2 = fitlm(resp.time(regress_ind_z2(bad_prho_z2 == 0 & bad_doxy_z2 == 0)),resp.doxy(z2_ind,regress_ind_z2(bad_prho_z2 == 0 & bad_doxy_z2 == 0)));

z3_ind = find(wfp_prs == z3); % Finds the index of that depth
regress_ind_z3 = regress_resp{z3}.start(yr):regress_resp{z3}.end(yr); 
% dt_days = resp.time(regress_ind_z3) - resp.time(regress_resp{z3}.start(yr));

temp_detrended = detrend(resp.temp(z3_ind,regress_ind_z3),'omitnan');
bad_temp_z3 = isoutlier(temp_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z3));
prho_detrended = detrend(resp.prho(z3_ind,regress_ind_z3),'omitnan');
bad_prho_z3 = isoutlier(prho_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z3));
doxy_detrended = detrend(resp.doxy(z3_ind,regress_ind_z3),'omitnan');
bad_doxy_z3 = isoutlier(doxy_detrended,'quartiles','SamplePoints',resp.time(regress_ind_z3));

mdl_z3 = fitlm(resp.time(regress_ind_z3(bad_prho_z3 == 0 & bad_doxy_z3 == 0)),resp.doxy(z3_ind,regress_ind_z3(bad_prho_z3 == 0 & bad_doxy_z3 == 0)));

figure
set(gcf,'position',[100,100,800,800])
days_pad = 100; 
ax1 = subplot(3,1,1);
plot(resp.time(regress_resp{z1}.start(yr)-days_pad:regress_resp{z1}.end(yr)+days_pad),...
    resp.doxy(z1_ind,regress_resp{z1}.start(yr)-days_pad:regress_resp{z1}.end(yr)+days_pad),'o','Color','none','MarkerFaceColor',grey)
hold on
plot(resp.time(regress_ind_z1),...
    resp.doxy(z1_ind,regress_ind_z1),'o','Color','none','MarkerFaceColor',blue)
plot(resp.time(regress_ind_z1(bad_prho_z1 == 1| bad_doxy_z1 == 1)),...
    resp.doxy(z1_ind,regress_ind_z1(bad_prho_z1 == 1 | bad_doxy_z1 == 1)),'o','Color','none','MarkerFaceColor',red)
% plot(resp.time(regress_ind_z1(bad_prho_z1 == 0| bad_doxy_z1 == 0)),...
%     resp.doxy(z1_ind,regress_ind_z1(bad_prho_z1 == 0| bad_doxy_z1 == 0)),'o','Color','none','MarkerFaceColor',blue)
plot([resp.time(regress_ind_z1(1)) resp.time(regress_ind_z1(end))],[(resp.time(regress_ind_z1(1))*mdl_z1.Coefficients.Estimate(2) + mdl_z1.Coefficients.Estimate(1)) (resp.time(regress_ind_z1(end))*mdl_z1.Coefficients.Estimate(2) + mdl_z1.Coefficients.Estimate(1))],'k','Linewidth',2)
grid on
ylabel('\mumol kg^-^1')
ax1.FontSize = 14;
datetick
title(['Oxygen at ' num2str(z1) ' db'])

days_pad = 50; 
ax2 = subplot(3,1,2);
plot(resp.time(regress_resp{z2}.start(yr)-days_pad:regress_resp{z2}.end(yr)+days_pad),...
    resp.doxy(z2_ind,regress_resp{z2}.start(yr)-days_pad:regress_resp{z2}.end(yr)+days_pad),'o','Color','none','MarkerFaceColor',grey)
hold on
plot(resp.time(regress_ind_z2),...
    resp.doxy(z2_ind,regress_ind_z2),'o','Color','none','MarkerFaceColor',blue)
plot(resp.time(regress_ind_z2(bad_prho_z2 == 1| bad_doxy_z2 == 1)),...
    resp.doxy(z2_ind,regress_ind_z2(bad_prho_z2 == 1 | bad_doxy_z2 == 1)),'o','Color','none','MarkerFaceColor',red)
plot([resp.time(regress_ind_z2(1)) resp.time(regress_ind_z2(end))],[(resp.time(regress_ind_z2(1))*mdl_z2.Coefficients.Estimate(2) + mdl_z2.Coefficients.Estimate(1)) (resp.time(regress_ind_z2(end))*mdl_z2.Coefficients.Estimate(2) + mdl_z2.Coefficients.Estimate(1))],'k','Linewidth',2)
grid on
ylabel('\mumol kg^-^1')
datetick
ax2.FontSize = 14;
title(['Oxygen at ' num2str(z2) ' db'])


days_pad = 30; 
ax3 = subplot(3,1,3);
plot(resp.time(regress_resp{z3}.start(yr)-days_pad:regress_resp{z3}.end(yr)+days_pad),...
    resp.doxy(z3_ind,regress_resp{z3}.start(yr)-days_pad:regress_resp{z3}.end(yr)+days_pad),'o','Color','none','MarkerFaceColor',grey)
hold on
plot(resp.time(regress_ind_z3),...
    resp.doxy(z3_ind,regress_ind_z3),'o','Color','none','MarkerFaceColor',blue)
plot(resp.time(regress_ind_z3(bad_prho_z3 == 1| bad_doxy_z3 == 1)),...
    resp.doxy(z3_ind,regress_ind_z3(bad_prho_z3 == 1 | bad_doxy_z3 == 1)),'o','Color','none','MarkerFaceColor',red)
plot([resp.time(regress_ind_z3(1)) resp.time(regress_ind_z3(end))],[(resp.time(regress_ind_z3(1))*mdl_z3.Coefficients.Estimate(2) + mdl_z3.Coefficients.Estimate(1)) (resp.time(regress_ind_z3(end))*mdl_z3.Coefficients.Estimate(2) + mdl_z3.Coefficients.Estimate(1))],'k','Linewidth',2)
grid on
ylabel('\mumol kg^-^1')
datetick
title(['Oxygen at ' num2str(z3) ' db'])
ax3.FontSize = 14;
linkaxes([ax3 ax2 ax1],'xy')
legend('in the mixed layer','below the mixed layer','density outlier','Location','southoutside','Orientation','horizontal')
xlim([resp.time(regress_resp{z3}.start(yr))-days_pad resp.time(regress_resp{z3}.end(yr))+days_pad])