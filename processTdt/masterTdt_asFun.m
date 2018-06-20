function rez = masterTdt_asFun(subj, date, probeNum,varargin)


% Set defaults
codeDir = '/home/loweka/git/kaleb-kilosort/';
fpath = '/mnt/teba/data/Kaleb/antiSessions/';%
% fpath = '/mnt/teba/Users/Kaleb/proAntiRaw/';
% fpath = '/home/loweka/dataRaw/'; % where on disk do you want the simulation? ideally and SSD...
rpath = '/home/loweka/DATA/dataProcessed/'; % For results
%sessionDir = 'Init_SetUp-160811-145107/';%'Init_SetUp-160715-150111/';

% Decode varargin
varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-f'}
            fpath = varargin{varStrInd(iv)+1};
    end
end

% Get session names
sessionDir = [subj,'-',date];

% Get individual session files
sessFiles = dir([fpath,filesep,subj,'-',date,'*']);


% default options are in parenthesis after the comment

useGPU = 1;
wavesNow = 0;
percentSamplesToUse = 100;
addpath(genpath('KiloSort')) % path to kilosort folder
addpath(genpath('npy-matlab')) % path to npy-matlab scripts

dataPath = [fpath sessionDir];
resultPath = [rpath sessionDir '_probe' num2str(probeNum) '/'];

addpath(genpath([codeDir 'KiloSort'])) % path to kilosort folder
addpath(genpath([codeDir 'npy-matlab'])) % path to npy-matlab scripts

if exist(resultPath, 'dir') ~= 7
    mkdir(resultPath);
end

pathToYourConfigFile = [codeDir 'processTdt/'];
run(fullfile(pathToYourConfigFile, 'configTdt.m'))

ops.chOffset            = 32*(probeNum-1);

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
rez.ops.resultPath = resultPath;

gpuDevice(1);

rez                = fitTemplates(rez, DATA, uproj);  % fit templates iteratively

gpuDevice(1);

rez                = fullMPMU(rez, DATA);% extract final spike times (overlapping extraction)

% AutoMerge. rez2Phy will use for clusters the new 5th column of st3 if you run this)
rez = merge_posthoc2(rez);

% Assign channels to each spike
%rez = timeToChanv2(rez,DATA);

% Clear up some memory
clear DATA uproj

% save python results file for Phy
rezToPhy(rez, resultPath);

% Make sures spikes are within the data
save(fullfile(resultPath,  'rez.mat'), '-struct', 'rez', 'ops','st3','xc','yc','-v7.3');
% % % Set aside the times and ops for memory sake...
% % tms = rez.st3(:,1);
% % ops = rez.ops;
% % % Clear rez for memory...
% % clear rez;
% % % Open dataAdapter
% % T=DataAdapter.newDataAdapter('tdt',ops.fbinary);
% % % Get the max samples for error detection
% % maxSamples = T.getSampsToRead(ops.Nchan);
% % % goodSpikes = logical(tms(:,1) > (-1*ops.wvWind(1)) & tms < (maxSamples-ops.wvWind(end)));
% % 
% % % Grab waveforms
% % % waves(goodSpikes,:,:) = T.getWaveforms(ops.wvWind,tms(goodSpikes,1),1:ops.Nchan,ops.chOffset);
% % % fprintf('\nSaving %d spikes to file...\n',sum(goodSpikes));
% % % save(fullfile(resultPath, 'rez.mat'),'waves','-append');

% save matlab results file

close all;


% klRezToSpks(rez,'-r',resultPath);

% remove temporary file
delete(ops.fproc);
%%
