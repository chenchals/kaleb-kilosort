
baseDataDir = '/Volumes/scratch/Kaleb-data/dataRaw';
baseResultDir = './testProcess';
sessions = dir(baseDataDir);
sessions = sessions(arrayfun(@(x) isempty(regexp(x.name,'^\.','match')),sessions));
chansPerProbe = 32;
clear sessions
sessions.name = 'Init_SetUp-161005-134520';
% masterTdt(baseDataDir, baseResultDir, sessionDir, probeNum)
for sessInd = 1: numel(sessions)
    session = sessions(sessInd).name;
    % Check if there are 64 channels?
    numProbes = floor(numel(dir(fullfile(baseDataDir,session, '/*Wav1_Ch*.sev')))/chansPerProbe);
    for probeNum = 1:numProbes
        fprintf('\nDoing session %s probeNum %d of %d\n',session,probeNum,numProbes);
        tic;
        masterTdt(baseDataDir, baseResultDir, session, probeNum);
        toc;
        fprintf('\n');
    end
    fprintf('**********************\n');
end