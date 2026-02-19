plot(combo.time,combo.doxy(500,:),'.')
hold on
plot(combo.time(combo.DO_bad(500,:) == 1),combo.doxy(500,(combo.DO_bad(500,:) == 1)),'.')

%%
assets = unique(combo.asset);

figure
for j = 1:length(assets)
    plot(combo.time(combo.asset == assets(j)),combo.doxy(500,combo.asset == assets(j)),'.')
    hold on
end
plot(combo.time(combo.DO_bad(500,:) == 1),combo.doxy(500,(combo.DO_bad(500,:) == 1)),'k.')
plot(combo.time(combo.bad_prho(500,:) == 1),combo.doxy(500,(combo.bad_prho(500,:) == 1)),'ro')


%%

for j = 1:length(assets)

   temp = combo.DO_bad(:,combo.asset == assets(j));
   [m1,n1] = size(temp);
   normnan = sum(isnan(temp));
   DOout_byasset(j) = sum(sum(temp,'omitnan'))/((m1*n1) - sum(normnan))*100;

end
%%

   temp = combo.DO_bad;
   [m1,n1] = size(temp);
   normnan = sum(isnan(temp),2);
   DObad = sum(sum(temp,'omitnan'))/((m1*n1) - sum(normnan))*100;

%%
DOout = sum(temp,2,'omitnan');
figure
plot(ones(size(normnan(1:2000)))*n1,1:2000)
hold on
plot(normnan(1:2000),1:2000)
axis ij
plot(n1 - normnan(1:2000),1:2000)
plot(DOout(1:2000),1:2000)


figure
plot(DOout(1:2000)./(n1 - normnan(1:2000))*100,1:2000)
axis ij
%%
close all
for j = 1:13

    figure(j)
    clf
    plot(glider{j}.doxy(150,:),'.'); hold on
    plot(glider{j}.doxy(500,:),'.')
end

%%
colorblind2 = [grey         
    0    0.6196    0.4510
    0.3372    0.7059    0.9137
    0.9412    0.8941    0.2588
    0.9020    0.6235         0
    0.8353    0.3686         0
    0.8000    0.4745    0.6549 
    navy; 
    red; 
    yellow; 
    green; 
    purple; 
    brightpurple];
close all
for j = 1:length(assets)

    figure(1)
    ax1 = subplot(3,1,1);
    if j == 1
        plot(combo.time(combo.asset == assets(j)),combo.doxy(175,combo.asset == assets(j)),'.','Markersize',10,'Color',colorblind2(j,:))
    else
        plot(combo.time(combo.asset == assets(j)),combo.doxy(175,combo.asset == assets(j)),'.','Markersize',8,'Color',colorblind2(j,:))
    end
    hold on
    title('Oxygen at 175 dbar')
    datetick
    ylabel('DO (\mumol kg^-^1)')
    axis tight

    ax2 = subplot(3,1,2);
    if j == 1
        plot(combo.time(combo.asset == assets(j)),combo.doxy(300,combo.asset == assets(j)),'.','Markersize',10,'Color',colorblind2(j,:))
    else
        plot(combo.time(combo.asset == assets(j)),combo.doxy(300,combo.asset == assets(j)),'.','Markersize',8,'Color',colorblind2(j,:))
    end
    hold on
    title('Oxygen at 300 dbar')
    datetick
    ylabel('DO (\mumol kg^-^1)')
    axis tight

    ax3 = subplot(3,1,3);
    if j == 1
        plot(combo.time(combo.asset == assets(j)),combo.doxy(500,combo.asset == assets(j)),'.','Markersize',10,'Color',colorblind2(j,:))
    else
        plot(combo.time(combo.asset == assets(j)),combo.doxy(500,combo.asset == assets(j)),'.','Markersize',8,'Color',colorblind2(j,:))
    end
    hold on
    title('Oxygen at 500 dbar')
    linkaxes([ax1 ax2 ax3],'x')
    datetick
    ylabel('DO (\mumol kg^-^1)')
    axis tight
end