% Default options are in parenthesis after the comment

useGPU = 1;
percentSamplesToUse = 100;
baseDir = '/home/subravcr/Kaleb/';
codeDir = [baseDir 'code/'];
baseDataDir = '/scratch/Kaleb-data/dataRaw/'; % where on disk do you want the simulation? ideally and SSD...
baseResultDir = [baseDir 'dataProcessed/']; % For results
sessionDir = 'Init_SetUp-160811-145107/';

fpath = baseResultDir;
configPath = [codeDir 'processTdt'];
dataPath = [baseDataDir sessionDir]; % must be called fpath used in configTdt
resultPath = [baseResultDir sessionDir];

addpath(genpath([codeDir 'KiloSort'])) % path to kilosort folder
addpath(genpath([codeDir 'npy-matlab'])) % path to npy-matlab scripts

run(fullfile(configPath, 'configTdt.m'))

if ~exist(resultPath,'dir')
    mkdir(resultPath);
end

tic; % start timer
%
if ops.GPU     
    gpuDevice(1); % initialize GPU (will erase any existing GPU arrays)
end

% if strcmp(ops.datatype , 'sev') && ~exist([ops.fbinary],'file')
%    ops = convertTdtWavSevToRawBinary(ops);  % convert data, only for OpenEphys
% end
%
[rez, DATA, uproj] = preprocessData(ops); % preprocess data and extract spikes for initialization
rez                = fitTemplates(rez, DATA, uproj);  % fit templates iteratively
rez                = fullMPMU(rez, DATA);% extract final spike times (overlapping extraction)

% AutoMerge. rez2Phy will use for clusters the new 5th column of st3 if you run this)
%     rez = merge_posthoc2(rez);

% save matlab results file
save(fullfile(ops.root,  'rez.mat'), 'rez', '-v7.3');

% save python results file for Phy
rezToPhy(rez, ops.root);

% Save DATA & individual channels of DATA(samples,channels,batches)
save(fullfile(ops.root,  'DATA.mat'), 'DATA', '-v7.3');
for ii = 1:size(DATA,2)
    chNoStr = num2str(ii);
    var = ['Ch_' chNoStr];
    eval([var ' = DATA(:,' chNoStr ',:);']);
    save(fullfile(ops.root, [var '.mat']), var, '-v7.3');
end

% remove temporary file
%delete(ops.fproc);
%%
