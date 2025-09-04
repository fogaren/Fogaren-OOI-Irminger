cd('C:\Users\fogaren\Desktop\Irminger12')
load Prelim_dDO.mat
%%
close all
figure
errorbar(dDO.Shipboard_Winkler_mean_umolkg,dDO.Winkler_mean_umolkg,...
    dDO.Winkler_std_umolkg,dDO.Winkler_std_umolkg,...
    dDO.Shipboard_Winkler_std_umolkg,dDO.Shipboard_Winkler_std_umolkg,'ok')
hold on
unique_cast = unique(dDO.cast);
for j = 1:length(unique_cast)
    p{j} = plot(dDO.Shipboard_Winkler_mean_umolkg(dDO.cast == unique_cast(j)),dDO.Winkler_mean_umolkg(dDO.cast == unique_cast(j)),...
        '.','MarkerSize',20)
end
axis([270 305 270 305])
daspect([1 1 1])
grid on
p{j+1} = plot([270:305],[270:305],'k--');
legend([p{1} p{2} p{3} p{4} p{5} p{6}],[{'Cast 5'},{'Cast 12'},{'Cast 17'},{'Cast 18'},{'Cast 22'},{'1:1 line'}],'location','southeast')
ylabel('Delayed Winkler (\mumol kg^-^1)')
xlabel('Shipboard Winkler (\mumol kg^-^1)')
ax = gca;
set(ax,'FontSize',12)

