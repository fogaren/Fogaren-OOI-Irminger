%% To look at oxygen regression for different isobars for a particular year.
% Request by reviewer 


%%

j = 7;
for z = 200:25:400
    if j ~= 6 
        if resp_end{j}(z) > resp_start{j}(z)
            [resp_start_z,~] = find(daily.time > resp_start{j}(z),1,'first');
            [resp_end_z,~] = find(daily.time < resp_end{j}(z),1,'last');
            resp_ind = resp_start_z:resp_end_z;
            Dremin_days = daily.time(resp_ind) - daily.time(resp_ind(1));
            dt_days = Dremin_days; 
            
            % Oxygen and density outliers have already been removed 
            mdl = fitlm(dt_days,daily.doxy(z,resp_ind));
            CI = mdl.coefCI;
    
            regress_prho{j}(z) = mean(daily.prho(z,resp_ind),'omitnan');
            regress_temp{j}(z) = mean(daily.temp(z,resp_ind),'omitnan');

            figure(100)
            nexttile
            plot(fitlm(dt_days,daily.doxy(z,resp_ind))); hold on
            title([num2str(z) ' dbar'])
            legend off 
            ylabel('\mumol kg^-^1','Interpreter','tex')
            xlabel('day')
            sgtitle(['Oxygen by isobar for ' num2str(j + 2014) '-' num2str(j+2015)])
                    
        else 
            Dremin_days = 0; 
            dt_days = 0; 
            resp_start_z = NaN;
            resp_end_z = NaN; 
            mdl = fitlm(NaN,NaN);
            regress_prho{j}(z) = NaN;
            CI(1:2,1:2) = 0;
            resp_ind = 0;  
        end
    end
end

%% Look at regression with reviewer suggested transfer efficiency  
fit_T600_200_maxMLD = fitlm(day_mld(mld_max_ind(1:6)),T600_200(1:6));

% d: mld vs zstar 
figure
set(gcf,'position',[100,100,450,400])
ax = gca;
for yr = 1:7
    plot(day_mld(mld_max_ind(yr)),T600_200(yr),'.','Color',colorblind(yr,:),'MarkerSize',30)
    hold on
end
plot([400:1600],fit_T600_200_maxMLD.Coefficients.Estimate(2)*(400:1600) + fit_T600_200_maxMLD.Coefficients.Estimate(1),'k--','Linewidth',1.2)
plot(day_mld(mld_max_ind(7)),T600_200(7),'kx','MarkerSize',8,'Linewidth',1.5)
grid on
ax.FontSize = 12;
% text(450,375,['R^2 = ' num2str(fit_zstar_maxMLD.Rsquared.Ordinary,2)])
text(425,0.45,'R^2 = 0.98 (p = 0.00012)') % For 2 decimal places
ylabel('T_e_f_f_-_6_0_0_/_2_0_0')
xlabel('MLD_m_a_x of previous winter (dbar)')
l = legend('1: 2015-2016','2: 2016-2017','3: 2017-2018','4: 2018-2019','5: 2019-2020','6: 2020-2021','7: 2021-2022','Location','SE');
l.FontSize = 10;
title(l,'Remin. Year')

%%
asset_num = unique(combo.asset);

for j = 1:length(asset_num)
    [m1,n1] = size(combo.DO_bad(1:2000,combo.asset == asset_num(j)));
    assnan = sum(sum(isnan(combo.DO_bad(1:2000,combo.asset == asset_num(j)))));
    assbad = sum(sum(combo.DO_bad(1:2000,combo.asset == asset_num(j)),'omitnan'));
    
    perbad(j) = assbad/((m1*n1)-assnan)*100;
end
%%
%% Sinking pulses with exponential fit
figure
for j = 1:length(atten_pulses_good)
    subplot(2,3,j)
    plot(sinkingpulse_max_gaussfilter_omitnan(:,1,atten_pulses_good(j)),wfpmerge.sinkingpulsedepths,'.','markersize', M)
    hold on
    plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.b*(200:2000)),200:2000,'k','Linewidth',2)
    plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.b*(50:200)),50:200,'Color',rgb('gray'),'Linewidth',1.5)
    legend off
    axis ij
    ylabel ('Pressure (m)')
    xlabel('max b_b_l (m^-^1)') 
    if yrstr(atten_pulses_good(j)) == 2016
        title('First pulse 2016')
    elseif yrstr(atten_pulses_good(j)) == 2016.5
        title('Second pulse 2016')
    else
        title(string(yrstr(atten_pulses_good(j))))
    end
    xlim([0 0.00025])
end
%%
for j = 1:5,8;
    % [curve_exp_gaussfilter_omitnan{j},gof_exp_gaussfilter_omitnan{j}] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan(:,1,j)./sinkingpulse_max_gaussfilter_omitnan(1,1,j),'exp1'); 
    [curve_exp_gaussfilter_omitnan{j},gof_exp_gaussfilter_omitnan{j}] = fit(wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan(:,1,j),'exp1');
end
%% 
figure
for j = 1:5,8;
    % plot(curve_exp_gaussfilter_omitnan{j},wfpmerge.sinkingpulsedepths,sinkingpulse_max_gaussfilter_omitnan(:,1,j)./sinkingpulse_max_gaussfilter_omitnan(1,1,j),'predobs'); hold on
    plot(curve_exp_gaussfilter_omitnan{j},'predfunc'); hold on
end
%%
figure
plot(curve_exp_gaussfilter_omitnan_mean.a*exp(curve_exp_gaussfilter_omitnan_mean.b*(200:2000)),200:2000)
%%
j = 1
figure
plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.b*(200:2000)),200:2000,'k','Linewidth',2); hold on
plot(1.017*exp(-0.0001861*(200:2000)),200:2000,'k--','Linewidth',2)
plot(1.362*exp(-0.0004611*(200:2000)),200:2000,'k--','Linewidth',2)
%%
figure
er1 = 161.1695*exp(-0.0005*(200:2000));
er2 = 215.9366*exp(-0.0002*(200:2000));
errorbar(curve_exp_gaussfilter_omitnan{1}.a*exp(curve_exp_gaussfilter_omitnan{1}.b*(200:2000)),200:2000,er2,er1,'horizontal'); hold on
axis ij


figure
for j = 1:length(atten_pulses_good)
plot(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.a*exp(curve_exp_gaussfilter_omitnan{atten_pulses_good(j)}.b*(200:2000)),200:2000,'Linewidth',2); hold on
axis ij
h = plot(curve_exp_gaussfilter_omitnan{1},'predob'); hold on
end