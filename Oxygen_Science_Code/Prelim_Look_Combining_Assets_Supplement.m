%%
% Create empty output variables 
glider_DOresp_rate_umolkg_day = [];
glider_DOresp_rate_umolkg_day_95CI_high = [];
glider_DOresp_rate_umolkg_day_95CI_low = []; 
glider_b_umolkg = [];
glider_p_value = [];
glider_R2 = [];
glider_regress_days = []; 
glider_DOresp_season_umolkg = []; % rate (slope) *resp_days 
glider_DOresp_season_umolkg_95CI_high = []; % rate (slope) *resp_days 
glider_DOresp_season_umolkg_95CI_low = []; % rate (slope) *resp_days 
glider_regress_prho = [];
glider_DOresp_season_molm3 = []; 
glider_DOresp_season_molm3_95CI_high = [];
glider_DOresp_season_molm3_95CI_low = [];
%%
% yr = 1;
% j1 = 1;
% j2 = 2;
% j3 = 3; 

% yr = 7;
% j1 = 12;
% j2 = 13;
% j3 = NaN;

z = 200; 
        
        time_test = find(glider{j1}.time < glider_resp_end{j1}(z));
        if glider_resp_start{j1}(z) == glider_resp_end{j1}(z)
            dt_days = 0;
            resp_start = NaN;
            resp_end = NaN; 
        elseif isempty(time_test) 
            dt_days = 0; 
        else
            [resp_start,~] = find(glider{j1}.time > glider_resp_start{j1}(z),1,'first');
            [resp_end,~] = find(glider{j1}.time < glider_resp_end{j1}(z),1,'last');
            dt_days1 = glider{j1}.time(resp_start:resp_end) - glider{j1}.time(resp_start);
        end
            resp_ind1 = resp_start:resp_end;

        time_test = find(glider{j2}.time < glider_resp_end{j2}(z));
        if glider_resp_start{j2}(z) == glider_resp_end{j2}(z)
            dt_days = 0;
            resp_start = NaN;
            resp_end = NaN; 
        elseif isempty(time_test) 
            dt_days = 0; 
        else
            [resp_start,~] = find(glider{j2}.time > glider_resp_start{j2}(z),1,'first');
            [resp_end,~] = find(glider{j2}.time < glider_resp_end{j2}(z),1,'last');
            dt_days2 = glider{j2}.time(resp_start:resp_end) - glider{j2}.time(resp_start);
        end
            resp_ind2 = resp_start:resp_end;

%         time_test = find(glider{j3}.time < glider_resp_end{j3}(z));
%         if glider_resp_start{j3}(z) == glider_resp_end{j3}(z)
%             dt_days = 0;
%             resp_start = NaN;
%             resp_end = NaN; 
%         elseif isempty(time_test) 
%             dt_days = 0; 
%         else
%             [resp_start,~] = find(glider{j3}.time > glider_resp_start{j3}(z),1,'first');
%             [resp_end,~] = find(glider{j3}.time < glider_resp_end{j3}(z),1,'last');
%             dt_days3 = glider{j3}.time(resp_start:resp_end) - glider{j3}.time(resp_start);
%         end
%             resp_ind3 = resp_start:resp_end;

% 
%             prho = [glider{j1}.pdens(z,resp_ind1)'; glider{j2}.pdens(z,resp_ind2)'; glider{j3}.pdens(z,resp_ind3)'];
%             DO = [glider{j1}.doxy(z,resp_ind1)'; glider{j2}.doxy(z,resp_ind2)'; glider{j3}.doxy(z,resp_ind3)'];
%             tt = [glider{j1}.time(resp_ind1); glider{j2}.time(resp_ind2); glider{j3}.time(resp_ind3)];

            prho = [glider{j1}.pdens(z,resp_ind1)'; glider{j2}.pdens(z,resp_ind2)'];
            DO = [glider{j1}.doxy(z,resp_ind1)'; glider{j2}.doxy(z,resp_ind2)'];
            tt = [glider{j1}.time(resp_ind1); glider{j2}.time(resp_ind2)];
            dt_days = tt - min(tt); 

            [time,IND] = sort(tt);
            prho = prho(IND);
            DO = DO(IND);
            dt_days = time - time(1);
            % Sort time to be in ascending order

            % Remove prho outliers 
            prho_detrend = detrend(prho,'omitnan');
            bad_prho = isoutlier(prho_detrend,'quartiles','SamplePoints',dt_days);
%             Oxygen filter doens't filter out any process, not using
            doxy_detrended = detrend(DO,'omitnan');
            bad_doxy = isoutlier(doxy_detrended,'quartiles','SamplePoints',dt_days);

            mdl = fitlm(dt_days(bad_prho == 0 & bad_doxy == 0),DO(bad_prho == 0 & bad_doxy == 0))
            CI = mdl.coefCI;


figure
plot(dt_days,DO,'ok','MarkerFaceColor',blue)
hold on
plot(dt_days(bad_prho == 1),DO(bad_prho == 1),'ok','MarkerFaceColor',red)
plot(dt_days(bad_doxy == 1),DO(bad_doxy == 1),'ok','MarkerFaceColor',yellow)

figure(8)
clf
plot(dt_days1,glider{j1}.doxy(z,resp_ind1),'ok','MarkerFaceColor',blue)
hold on
plot(dt_days2,glider{j2}.doxy(z,resp_ind2),'ok','MarkerFaceColor',red)
% plot(dt_days3,glider{j3}.doxy(z,resp_ind3),'ok','MarkerFaceColor',yellow)
ylabel('DO (\mumol kg^-^1)')
title(['Depth = ' num2str(z)])
% legend('Glider 1','Glider 2','Glider 3','Location','SW')
grid on
xlabel('Days below ML')

