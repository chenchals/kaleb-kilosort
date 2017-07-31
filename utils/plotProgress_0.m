

%%
%Waves(timeSamples,samplePoints,channels)
%for ii=1:10:191, tempWaves=wavesAllBatches1{ii}; plotProgress,pause,end
fprintf('Doing plot...%d\n',ii)
waves=tempWaves;
nSamples = size(waves,1);
xLim=minmax(sampleWin);
xVals = sampleWin;
%Compute for whole matrx
% Range for each channel per timesample waveform
waveformRange = squeeze(range(waves,2));
% MaxRange for each timesample (ie max of 32 channels)
[maxRangePerTimesample, chanNoWithMaxRange] = max(waveformRange, [], 2);
grandYLim=round(minmax(waves(:)'));
figure()

for t=1:nSamples
    dat = squeeze(waves(t,:,:));
    %Range for a timeSample
    rng = range(dat);
    maxChInd = find(rng==max(rng));
    yLim = round(minmax(squeeze(dat(:,maxChInd)')));
    for ch=1:34
        subplot(4,9,ch)
        hold on
        if ch==maxChInd
            plot(xVals,dat(:,ch),'-r')
        else
            plot(xVals,dat(:,ch),'-b')
        end
        %drawnow        
    end
    %set(findobj('type','axes'),'xlim',xLim,'xgrid','on','ylim',yLim,'ygrid','on')
    %pause
end
set(findobj('type','axes'),'xlim',xLim,'xgrid','on','ylim',grandYLim,'ygrid','on')
drawnow



