% default options are in parenthesis after the comment

useGPU = 1;
percentSamplesToUse = 100;
addpath(genpath('KiloSort')) % path to kilosort folder
addpath(genpath('npy-matlab')) % path to npy-matlab scripts

codeDir = '/home/loweka/code/';
fpath = '/home/loweka/dataRaw/'; % where on disk do you want the simulation? ideally and SSD...
rpath = '/home/loweka/dataProcessed/'; % For results
sessionDir = 'Init_SetUp-160811-145107/';%'Init_SetUp-160715-150111/';

dataPath = [fpath sessionDir];

addpath(genpath([codeDir 'KiloSort'])) % path to kilosort folder
addpath(genpath([codeDir 'npy-matlab'])) % path to npy-matlab scripts

if exist(resultPath, 'dir') ~= 7
    mkdir(resultPath);
end

pathToYourConfigFile = [codeDir 'processTdt/'];
run(fullfile(pathToYourConfigFile, 'configTdt.m'))

tic; % start timer
%
if ops.GPU     
    gpuDevice(1); % initialize GPU (will erase any existing GPU arrays)
end

% if strcmp(ops.datatype , 'sev') && ~exist([ops.fbinary],'file')
%    ops = convertTdtWavSevToRawBinary(ops);  % convert data, only for OpenEphys
% end
%
[rez, DATA, dataRaw, uproj] = preprocessData(ops); % preprocess data and extract spikes for initialization
rez.ops.resultPath = resultPath;

gpuDevice(1);

rez                = fitTemplates(rez, DATA, uproj);  % fit templates iteratively

gpuDevice(1);

rez                = fullMPMU(rez, DATA);% extract final spike times (overlapping extraction)

% AutoMerge. rez2Phy will use for clusters the new 5th column of st3 if you run this)
rez = merge_posthoc2(rez);

% Assign channels to each spike
%rez = timeToChanv2(rez,DATA);

% save matlab results file
save(fullfile(resultPath,  'rez.mat'), 'rez', '-v7.3');

% save python results file for Phy
rezToPhy(rez, resultPath);

% remove temporary file
delete(ops.fproc);
%%
