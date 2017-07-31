%% Pull waveforms and spike times for each cluster... but also figure out the channel

function out = klRezToSpks(rez)

% Set defaults
sampWin = -10:20;
% rangeWin = [-10:10]; % This part is used to get "maxChan" but is obsolete
nChannels = 1:rez.ops.NchanTOT;
percThresh = .05;
chanOff = 0;
sampleRate = 24414;

% Decode varargin

% Get what we need from rez before clearing
resultPath = rez.ops.resultPath;
sourceFile = rez.ops.fbinary;
isPos = rez.ops.spkTh > 0;
clear rez;

% Get clusters and times
clusts = readNPY([resultPath, '/spike_clusters.npy']);% rez.st3(:,5);
tms = double(readNPY([resultPath,'/spike_times.npy']));

% Get unique clusters
uClusts = unique(clusts);

% NB: rez.st3(:,2) are the templates

% temporary (?) load in templates
% templateWaves = readNPY(fullfile(resultPath, 'templates.npy'));


% Get a list of times for later
tmVect = (1:max(tms)).*(1000/sampleRate);

% Make a vector of number of units identified per channel
chanNoUnits = zeros(1,max(nChannels));

% Start cluster loop
for ic = 1:length(uClusts)
    % Open DataAdapter (here because the parfor didn't like it being
    % outside...
    T=DataAdapter.newDataAdapter('tdt',sourceFile);

    thisClust = uClusts(ic);
    fprintf('Pulling waves for cluster %d (%d of %d)...',thisClust,ic,length(uClusts));
    % Get this cluster waveforms and times
    clusterWaves = T.getWaveforms(sampWin,tms(clusts==thisClust),nChannels);
    clusterTimes = tms(clusts==thisClust);
  
    % Get the maximum range (commented below) or value at the time of the
    % spike
%     [~,maxChan] = max(range(clusterWaves(:,ismember(sampWin,rangeWin),:),2),[],3);
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
        % Eval doesn't realize that the tow variables below are used
        % blelow...
        thisChanUnitWaves = clusterWaves(maxAbs==uMaxChan(iu),:,uMaxChan(iu));
        thisChanUnitTimes = tmVect(clusterTimes(maxAbs==uMaxChan(iu)));
        
        % Put it in the struct
        chanNoUnits(uMaxChan(iu)) = chanNoUnits(uMaxChan(iu)) + 1;
        unitStr = sprintf('chan%d%s',uMaxChan(iu)+chanOff,num2abc(chanNoUnits(uMaxChan(iu))));
        eval(sprintf('%s.spkTimes=thisChanUnitTimes;',unitStr));
        eval(sprintf('%s.waves=thisChanUnitWaves;',unitStr));
    end
    fprintf('\n');
    
end
% Clear the variables that we don't want that start with "chan"
clear chanNoUnits chansMeetCrit chanOff
% Now clear everything that doesn't start with "chan"
clearvars -except chan*

% Grab the variables that start with "chan" so we can put them in the
% output structure
currVars = who;
% Initialize "out"
for iv = 1:length(currVars)
    out.(currVars{iv}) = struct('spkTimes',[],'waves',[]);
end
for iv = 1:length(currVars)
    eval(sprintf('out.%s = %s;',currVars{iv},currVars{iv}));
end

