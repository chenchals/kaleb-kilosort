
%%
%clearvars -except sourceDir resultDir rez clu39 sampleWin
sourceDir ='/Users/subravcr/teba/local/schalllab/Kaleb/dataRaw/Init_SetUp-160811-145107/';
resultDir ='/Users/subravcr/teba/local/schalllab/Kaleb/dataProcessed/Init_SetUp-160811-145107_100pc_ntbuff_1/';
%sourceDir ='/Users/subravcr/teba/local/schalllab/Kaleb/myEMouse/results_ntbuff1/sim_binary.dat';
%resultDir ='/Users/subravcr/teba/local/schalllab/Kaleb/myEMouse/results_ntbuff1/';
recordingType = 'tdt';%'emouse';%'tdt'
var=load([resultDir 'rez.mat']);
rez=var.rez;
sampleWin = [-10:20];
nChannels =32;%34
[n,c] = hist(rez.st3(:,5),unique(rez.st3(:,5)));

ntBuff=1; % or 64
batchSize = 8388608+ntBuff;%131136; % 8388608+ntBuff;
nBatches = 32;
nPull = 200;

%maxClusNo = c(n==max(n));
%wavesAllBatches1 = cell(length(c),1);
for ic = 1:length(c)
    fprintf('Doing for cluster No %d\n',c(ic));
    maxClusNo = c(ic);
    clusStr = ['clus' num2str(maxClusNo)];
    clus = rez.st3(rez.st3(:,5)==maxClusNo,[1 5]);
    clusterBatches = cell(nBatches,1);   
    % find samples from the middle to end if batch
    batchCenters = [0:nBatches-1]*batchSize+batchSize/2;
    %wavesAllBatches1 = cell(nBatches,1);
    T=DataAdapter.newDataAdapter(recordingType,sourceDir);
    for jj = 1:(nBatches-1)
        samples = clus(find(clus(:,1)>batchCenters(jj),nPull),:);
        clusterBatches{jj} = T.getWaveforms(sampleWin,samples,[1:nChannels]);
    end
    wavesAllBatches1.(clusStr)=clusterBatches;
    %     for ii = 1:4:31
    %         tempWaves = wavesAllBatches1{ii};
    %         plotProgress
    %     end
    %    pause
end


fprintf('done...\n');



