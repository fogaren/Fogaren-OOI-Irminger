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
