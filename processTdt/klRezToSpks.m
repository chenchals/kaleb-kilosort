%% Pull waveforms and spike times for each cluster... but also figure out the channel

function out = klRezToSpks(rez,varargin)

% Set defaults
sampWin = -10:20;
nChannels = 1:rez.ops.NchanTOT;
percThresh = .05;
chanOff = rez.ops.chOffset;
sampleRate = 24414;
resultPath = '/home/loweka/DATA/dataProcessed/';
rawPath = '/mnt/teba/data/Kaleb/antiSessions/';
% rawPath = 
pullWaves = 0;

% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-p'}
            resultPath = varargin{varStrInd(iv)+1};
        case {'-r'}
            rawPath = varargin{varStrInd(iv)+1};
        case {'-w'}
            allWaves = varargin{varStrInd(iv)+1};
    end
end


% Check if we need to get the waveforms here
if ~exist('allWaves','var')
    if ~isfield(rez,'waves')
        pullWaves = 1;  
    else
        allWaves = rez.waves;
    end
end

% Get what we need from rez before clearing
[~,sessStr] = fileparts(rez.ops.resultPath(1:(end-1)));
resultPath = [resultPath,sessStr];
ops = rez.ops;
if isfield(ops,'wvWind')
    sampWin = ops.wvWind;
end

isPos = rez.ops.spkTh > 0;

clear rez;

% Get clusters and times
clusts = readNPY([resultPath, '/spike_clusters.npy']);% rez.st3(:,5);
tms = double(readNPY([resultPath,'/spike_times.npy']));

% Load in all waves if necessary (saves read/write time, I hope...)
if pullWaves
    fprintf('Loading in all waves...\n');
    T=DataAdapter.newDataAdapter('tdt',fullfile(rawPath,sessStr(1:(strfind(sessStr,'_probe')-1))));
    maxSamples = T.getSampsToRead(nChannels);
    allWaves = T.getWaveforms(ops.wvWind,tms,(1:ops.Nchan),ops.chOffset,maxSamples);
end

% Get unique clusters
uClusts = unique(clusts);

% Get a list of times for later
tmVect = (1:max(tms)).*(1000/sampleRate);

% Make a vector of number of units identified per channel
chanNoUnits = zeros(1,max(nChannels));

% Start cluster loop
for ic = 1:length(uClusts)
    clustNo = uClusts(ic);
    fprintf('Pulling waves for cluster %d (%d spikes, %d of %d)...\n',clustNo,sum(clusts==clustNo),ic,length(uClusts));
    % Get this cluster waveforms and times
%     if pullWaves
%         T=DataAdapter.newDataAdapter('tdt',fullfile(rawPath,sessStr(1:(strfind(sessStr,'_probe')-1))));
%         maxSamples = T.getSampsToRead(nChannels);
%         clusterWaves = T.getWaveforms(ops.wvWind,tms(clusts==clustNo),(1:ops.Nchan),ops.chOffset,maxSamples);
%     else
        myClusts = find(clusts==clustNo);
        clusterWaves = allWaves(ismember(1:size(allWaves,1),myClusts),:,:);
%     end
    clusterTimes = tms(clusts==clustNo);
    if isPos
        [~,maxAbs] = max(clusterWaves(:,sampWin==0,:),[],3);
    else
        [~,maxAbs] = min(clusterWaves(:,sampWin==0,:),[],3);
    end
    [nChanClustA,cChanClustA] = hist(maxAbs,1:32);
    
    % Which channels have at least 5% of this cluster's spikes?
    chansMeetCrit = cChanClustA(nChanClustA > (percThresh*sum(nChanClustA)));
    
    % Loop through the channels that do have at leeast 5%...
    uMaxChan = unique(chansMeetCrit);
    for iu = 1:length(uMaxChan)
        waves = clusterWaves(maxAbs==uMaxChan(iu),:,uMaxChan(iu));
        spkTimes = tmVect(clusterTimes(maxAbs==uMaxChan(iu)));
        % Unit id
        chanNoUnits(uMaxChan(iu)) = chanNoUnits(uMaxChan(iu)) + 1;
        unitStr = sprintf('chan%d%s',uMaxChan(iu)+chanOff,num2abc(chanNoUnits(uMaxChan(iu))));
        
        save([resultPath,filesep,unitStr,'.mat'],'spkTimes','waves','clustNo');
        out.(unitStr).spkTimes = spkTimes;
        out.(unitStr).waves = waves;
        out.(unitStr).clustNo = clustNo;
        clear spkTimes waves

    end
    fprintf('\n');
    
end

