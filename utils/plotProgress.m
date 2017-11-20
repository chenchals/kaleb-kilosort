

%%
%Waves(timeSamples,samplePoints,channels)
%for ii=1:10:191, tempWaves=wavesAllBatches1{ii}; plotProgress,pause,end
%fprintf('Doing plot...%d\n',ii)
nWavesLimit = 10000;
sampleWin = -25:25;
waves=rez_kl.waves(1:nWavesLimit,:,:);%tempWaves; 
nSamples = size(waves,1);
xLim=minmax(sampleWin);
xVals = sampleWin;
nChannels =32;%34
%Compute for whole matrx
% Range for each channel per timesample waveform
waveformRange = squeeze(range(waves,2));
% MaxRange for each timesample (ie max of 32 channels)
[maxRangePerTimesample, chanNoWithMaxRange] = max(waveformRange, [], 2);
grandYLim=round(minmax(waves(:)'));
if exist('ii','var')
    figure(ii);
else
    figure();
end

for ch=1:nChannels
    subplot(4,9,ch)
    hold on
    wavesWithMaxRngForChannel =  find(chanNoWithMaxRange==ch);
    otherWaves = setdiff(1:nSamples,wavesWithMaxRngForChannel);
    % overplot
    if numel(otherWaves)>0
        plot(xVals,waves(otherWaves,:,ch),'-b')
    end
    
    if numel(wavesWithMaxRngForChannel)>0
        plot(xVals,waves(wavesWithMaxRngForChannel,:,ch),'-r')
    end
    drawnow
end
set(findobj('type','axes'),'xlim',xLim,'xgrid','on','ylim',grandYLim,'ygrid','on')
drawnow



