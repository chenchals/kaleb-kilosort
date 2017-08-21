%% Pull waveforms and spike times for each cluster... but also figure out the channel

function out = processKiloSortResults(baseProcessedDir)

    sessions = getSubDirs(dir(baseProcessedDir));
    % Set defaults
    sampWin = -10:20;
    %nChannels = 1:rez.ops.NchanTOT;
    nChannels = 32;
    percThresh = .05;
    sampleRate = 24414;
    sample2TimeFactor = (1000/sampleRate);
    % For each session
    for sessionNum = 1:numel(sessions)
        probes = getSubDirs(dir(fullfile(sessions(sessionNum).folder,sessions(sessionNum).name)));
        for probeNum = 1: numel(probes)
            channelNoOffset = (probeNum-1)*nChannels;
            probe = probes(probeNum);
            sessionDir = probe.folder;
            probeDir = fullfile(sessionDir,probe.name);
            
            load(fullfile(probeDir,'rez.mat'));
            allWaves = rez.waves;
            spikeThreshold = rez.ops.spkTh;
            clear rez
            
            % Get clusters
            clusterNums = readNPY(fullfile(probeDir, 'spike_clusters.npy'));% rez.st3(:,5);
            clusterIds = unique(clusterNums);
            % Get timeSamples
            timeSamples = double(readNPY(fullfile(probeDir,'spike_times.npy')));
            
            unitsPerChannel = zeros(1,nChannels);
            
            for clusterIdIndex = 1:length(clusterIds)
                clusterId = clusterIds(clusterIdIndex);
                fprintf('Pulling waves for cluster %d (%d of %d)...',clusterId,clusterIdIndex,length(clusterIds));
                % Get this cluster waveforms and times
                clusterWaves = allWaves(clusterNums==clusterId,:,:);
                clusterTimes = timeSamples(clusterNums==clusterId);
                if spikeThreshold < 0
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
                    spkTimes = clusterTimes(maxAbs==uMaxChan(iu)).*sample2TimeFactor;
                    % Unit id
                    unitsPerChannel(uMaxChan(iu)) = unitsPerChannel(uMaxChan(iu)) + 1;
                    unitStr = sprintf('chan%02d%s',uMaxChan(iu)+channelNoOffset,num2abc(unitsPerChannel(uMaxChan(iu))));
                    
                    save(fullfile(sessionDir,[unitStr,'.mat']),'spkTimes','waves','clusterId');
                    out.(unitStr).spkTimes = spkTimes;
                    out.(unitStr).waves = waves;
                    out.(unitStr).clustNo = clusterId;
                    clear spkTimes waves
                    
                end
                fprintf('\n');
                
            end
            
        end
    end



end

function [ out ] = getSubDirs(dirStruct)
out = dirStruct(arrayfun(@(x) isempty(regexp(x.name,'^\.','match')),dirStruct));
end


