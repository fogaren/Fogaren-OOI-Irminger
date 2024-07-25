% Creates Dremineralization(z) for each remineralization year using blended
% mixed layer product (mostly from WFP, some gliders, and some ARGO)

% Assigns Dremineralization(z) to glider(s) from that remineralization year
% 
cd('G:\Shared drives\NSF_Irminger\Data_Files\From Meg')
load blended_mld_daily.mat

%%
% Remove nan data and create MLDs for every day
day_dn0 = datenum(blended_mld_daily_all.time);
day_mld0 = blended_mld_daily_all.mld; 
day_dn0(isnan(day_mld0)) = [];
day_mld0(isnan(day_mld0)) = [];
% day_dn0(2191) = [];
% day_mld0(2191) = []; % If want to change winter max for year 6

figure
plot(day_dn0,day_mld0,'.')
axis ij; grid on
%%

day_mld = interp1(day_dn0,day_mld0,datenum(blended_mld_daily_all.time),'linear');
day_mld = round(day_mld);
day_dn = datenum(blended_mld_daily_all.time); 

mld_max = islocalmax(day_mld,'MinSeparation',days(270),'SamplePoints',blended_mld_daily_all.time);
mld_max = find(mld_max); 
mld_max_ind = mld_max(1:8); % Ignore last winter, past my timeseries 

figure
plot(blended_mld_daily_all.time,day_mld,'.k')
hold on
plot(blended_mld_daily_all.time(mld_max_ind),day_mld(mld_max_ind),'*m','MarkerSize',8)
axis ij
grid on
title('Maximum Annual MLDs')
ylabel('MLDs (db)')
xlim([datetime(2015,01,01) datetime(2022,08,15)])

%% Create binary in or below the ML product

% %% Find the depth of the ML
% Everything below is a zero (not in ML)
% Everything above and == ML is a one (in the ML)
 
depth = 1:2000; 
data_in_mld = zeros(length(depth),length(day_dn));
% zeros for data not in the mixed layer

% replace with ones for data points that are in the mixed layer 
for j = 1:length(day_dn)
        [~,b] = find(depth == day_mld(j));
        data_in_mld(1:b,j) = 1; 
        clear b
end

%%
j = 8; z = 30;
    time_chunk1 = find(day_dn > datenum(2012+j,08,15) & day_dn < datenum(2013+j,08,15)); % find time between maximum winter ML mixing
    time_chunk2 = find(day_dn > datenum(2013+j,08,15) & day_dn < datenum(day_dn(mld_max(j+1))));
[~,b1] = find(data_in_mld(z,time_chunk1),1,'last');
[~,b2] = find(data_in_mld(z,time_chunk2),1,'first');
figure
subplot(2,1,1)
plot(blended_mld_daily_all.time,blended_mld_daily_all.mld,'.k')
hold on
plot(blended_mld_daily_all.time(time_chunk1),blended_mld_daily_all.mld(time_chunk1),'o');
hold on
plot(blended_mld_daily_all.time(time_chunk2),blended_mld_daily_all.mld(time_chunk2),'o')
plot(blended_mld_daily_all.time(time_chunk1(b1)),blended_mld_daily_all.mld(time_chunk1(b1)),'*g')
plot(blended_mld_daily_all.time(time_chunk2(b2)),blended_mld_daily_all.mld(time_chunk2(b2)),'*r')
grid on
axis ij

subplot(2,1,2)
plot(blended_mld_daily_all.time,data_in_mld(z,:),'.k')
hold on
plot(blended_mld_daily_all.time(time_chunk1),data_in_mld(z,time_chunk1),'o');
hold on
plot(blended_mld_daily_all.time(time_chunk2),data_in_mld(z,time_chunk2),'o')
plot(blended_mld_daily_all.time(time_chunk1(b1)),data_in_mld(z,time_chunk1(b1)),'*g')
plot(blended_mld_daily_all.time(time_chunk2(b2)),data_in_mld(z,time_chunk2(b2)),'*r')
grid on

%% Find the respiration length for each isobar each stratification season 
% Converts from deployment year to scientific analysis year 

resp_start = [];
resp_end = [];
resp_length_days = [];
for j = 2:8 % deployment yr 
    % 
    time_chunk1 = find(day_dn >= datenum(2012+j,08,15) & day_dn <= datenum(2013+j,08,15)); % find time between maximum winter ML mixing
    time_chunk2 = find(day_dn >= datenum(2013+j,08,15) & day_dn <= datenum(day_dn(mld_max(j))));
    
    % Indexed by scientific year 
    for z = 1:length(depth)
        [~,b1] = find(data_in_mld(z,time_chunk1),1,'last'); 
        if isempty(b1)
            resp_start{j-1}(z) = day_dn(mld_max(j-1));
        else
            resp_start{j-1}(z) = day_dn(time_chunk1(b1));
        end

        [~,b2] = find(data_in_mld(z,time_chunk2),1,'first');
        if isempty(b2)
            resp_end{j-1}(z) = day_dn(mld_max(j));
        else
            resp_end{j-1}(z) = day_dn(time_chunk2(b2));
        end
        
        resp_length_days{j-1}(z) = resp_end{j-1}(z) - resp_start{j-1}(z);

    end
end

% figure
% plot(day_dn,day_mld,'.')
% hold on
% plot(day_dn(mld_max_ind),day_mld(mld_max_ind),'*')
% plot(day_dn(time_chunk1),day_mld(time_chunk1),'.')
% plot(day_dn(time_chunk2),day_mld(time_chunk2),'o')
% axis ij
% grid on  
% ylim([0 2000])


%%
run('GeneralSettings')
mycolors = [maroon; red; yellow; forestgreen; blue; purple; brightpurple; pink]; 
for j = 1:7 % Full analysis year 
    figure
    plot(resp_length_days{j},1:2000,'Color',mycolors(j,:),'Linewidth',2)
    hold on
    axis ij
    title(num2str(j))

    figure(10)
    plot(resp_length_days{j},1:2000,'Linewidth',2)
    hold on
    axis ij
    grid on
    ylabel('depth (db)')
    xlabel('days')
    title('Respiration Window Length')
    legend('2015-2016','2016-2017','2017-2018','2018-2019','2019-2020','2020-2021','2021-2022','Location','SW')
end
%%
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
save respiration_length_by_year2.mat resp_*

%% Had to hard code this part, not sure why loop didn't work 
% Assign Remineralization length (1-7) to gliders 1-13 depending on what
% year they were deployed. 

glider_resp_length_days =[];
glider_resp_start = [];
glider_resp_end = []; 

% Gliders 1 -3, year 1
glider_resp_length_days{1} = resp_length_days{1};
glider_resp_start{1} = resp_start{1}; 
glider_resp_end{1} = resp_end{1}; 

glider_resp_length_days{2} = resp_length_days{1};
glider_resp_start{2} = resp_start{1}; 
glider_resp_end{2} = resp_end{1}; 

glider_resp_length_days{3} = resp_length_days{1};
glider_resp_start{3} = resp_start{1}; 
glider_resp_end{3} = resp_end{1}; 

% Gliders 4, year 2
glider_resp_length_days{4} = resp_length_days{2};
glider_resp_start{4} = resp_start{2}; 
glider_resp_end{4} = resp_end{2}; 

% Glider 5, year 3
glider_resp_length_days{5} = resp_length_days{3};
glider_resp_start{5} = resp_start{3}; 
glider_resp_end{5} = resp_end{3}; 

% Gliders 6-7, year 4
glider_resp_length_days{6} = resp_length_days{4};
glider_resp_start{6} = resp_start{4}; 
glider_resp_end{6} = resp_end{4}; 

glider_resp_length_days{7} = resp_length_days{4};
glider_resp_start{7} = resp_start{4}; 
glider_resp_end{7} = resp_end{4}; 

% Gliders 8-9, year 5
glider_resp_length_days{8} = resp_length_days{5};
glider_resp_start{8} = resp_start{5}; 
glider_resp_end{8} = resp_end{5}; 

glider_resp_length_days{9} = resp_length_days{5};
glider_resp_start{9} = resp_start{5}; 
glider_resp_end{9} = resp_end{5}; 

% Gliders 10-11, year 6
glider_resp_length_days{10} = resp_length_days{6};
glider_resp_start{10} = resp_start{6}; 
glider_resp_end{10} = resp_end{6}; 

glider_resp_length_days{11} = resp_length_days{6};
glider_resp_start{11} = resp_start{6}; 
glider_resp_end{11} = resp_end{6}; 

% Gliders 12-13, year 7 
glider_resp_length_days{12} = resp_length_days{7};
glider_resp_start{12} = resp_start{7}; 
glider_resp_end{12} = resp_end{7}; 

glider_resp_length_days{13} = resp_length_days{7};
glider_resp_start{13} = resp_start{7}; 
glider_resp_end{13} = resp_end{7}; 

%%
cd('G:\Shared drives\NSF_Irminger\Data_Files\From_Kristen')
save respiration_length_by_glider.mat glider_resp_length_days glider_resp_start glider_resp_end


