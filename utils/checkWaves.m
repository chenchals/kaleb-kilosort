
sessionDir = 'Init_SetUp-160802-144253_probe1_/';
dList = dir([sessionDir 'chan*.mat']);
dList = strcat({dList.folder}', '/',{dList.name}');
data=struct();
for ii = 1:numel(dList)
    [~,ch,~] = fileparts(char(dList{ii}));
    data.(ch) = load(char(dList{ii}),'-mat'); 
end
clear ch ii dList sessionDir
data = orderfields(data);
units = fieldnames(data);
chanNoStrs = regexp(units,'(\d{2})[a-z]$','tokens');
chanNoStrs = unique(cellfun(@(x) char(x{:}),chanNoStrs,'UniformOutput',false));
clustNos = unique(structfun(@(x) x.clustNo, data));
cmap = {'-r','-g','-b','-c','-m','-y','-k',':r',':g',':b',':c',':m',':y',':k'};
figure()
%set(gcf,'Position',[0.1 0.1 0.9 0.9]);
set(gcf,'Units','normalized');
nRows = ceil(sqrt(length(units)));
nCols = nRows;
for plotNo = 1:numel(units) 
    unitStr = char(units(plotNo));
    unit = data.(unitStr);
    x = 1:size(unit.waves,2);
    subplot(nRows,nCols,plotNo)
    plot(1:size(unit.waves,2),unit.waves(1:end,:),'Color',[0.5 0.5 0.5]);
    hold on
    colInd = find(clustNos==unit.clustNo);
    plot(1:size(unit.waves,2),mean(unit.waves,1),cmap{colInd},'LineWidth',2)
    txt = {['Unit: ' unitStr], ['Clust: ' num2str(unit.clustNo)], ['nWaves: ' num2str(size(unit.waves,1))]};
    drawnow
    xlim([0 max(x)]);
    ylim([min(unit.waves(:))*1.05 max(unit.waves(:))*1.05]);
    text(2,max(ylim)*0.95,char(join(txt,'; ')),'FontWeight','bold','FontSize', 10);
    thisPlot.pos = get(gca,'Position');
    thisPlot.zoom = 0;
    set(gca,'UserData',thisPlot);
    set(gca,'ButtonDownFcn',@plotZoom);
    
end
