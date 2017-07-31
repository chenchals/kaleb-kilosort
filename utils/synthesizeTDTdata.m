% Create fake data to mimic TDT, but with known spike times

nChannels = 32;
nSamples = 1e6;

% How much do we want to scale the noise?
noiseSD = 5;
spikeAmp = 100;

% Generate the noise matrix
noiseMat = randn(nSamples,nChannels).*noiseSD;


% Let's load in some good spikes to inject
%load('/Users/subravcr/teba/local/schalllab/Amir/DataFiles/eulsef20120904c-01.mat','WAV*')
%vars = who('WAV*');
%myMeans = cell2mat(cellfun(@(x) evalin('base',[x '.Mean']),vars,'UniformOutput',0));
load('goodSynthWaves.mat');

% Spike injection parameters
loCh=18;
hiCh=nChannels-loCh;
firingRates = [ones(loCh,1).*300;ones(hiCh,1).*700];
firingOffset = ones(1,nChannels).*50;
goodWaves = [10,14,16,21];

for ic = 1:nChannels
    myWave = myMeans(goodWaves(mod(ic,length(goodWaves))+1),:);
    myWave = myWave./(max(abs(myWave)));
    myWave = myWave.*spikeAmp;
    
    wvTimes = firingOffset(ic):firingRates(ic):nSamples;
    wvTimeInds = bsxfun(@plus,wvTimes,((1:length(myWave))-12)');
    myWaveRep = repmat(myWave,1,length(wvTimes));
    noiseMat(wvTimeInds(:),ic) = myWaveRep;
end
int16Mat = int16(noiseMat);
fid = fopen('synthDataAll34.dat','wb');
fwrite(fid,int16Mat,'*int16');
fclose(fid);

fid=fopen('synthDataAll34.dat','rb');
readMat = fread(fid,[nSamples,nChannels],'*int16');
fclose(fid);


keyboard

% 
% for i = 1:64, figure(i); plot(xx(i,:,1)); pause; close(i); end
% 
% 
% while myQual < 1
%     fprintf('Working on count %d...\n',count);
% load([x{count},'/Spikes.mat']);
% myQual = spikes.qualVect;
% count = count+1;
% end