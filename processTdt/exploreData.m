% load ./dataRaw/rez.mat
%load('subData.mat')

%DATA=subData;
uClusts = unique(rez.st3(:,5));
for ic = 1:length(uClusts)
    st = rez.st3(find(rez.st3(:,5)==uClusts(ic),200),1);
    for i = 1:200
        if st(i) <= size(DATA,1)
            for ii = 1:32
                tmpWav(:,ii) = DATA(st(i)+(-10:20),ii,1);
            end
            wRanges = range(tmpWav,1);
            [~,maxChans{ic}(i)] = max(wRanges,[],2);
            newWavs{ic}(:,i) = DATA(st(i)+(-10:20),maxChans{ic}(i),1);
        end
    end
end

for ic = 12 %1:length(newWavs)
    figure(ic); plot(newWavs{ic});
end
chanData = SEV2mat_kl(rez.ops.fbinary,'CHANNEL',11);
st = rez.st3(find(rez.st3(:,5)==uClusts(12),200),1);
stCheck = st(maxChans{12}==11);
for it = 1:length(stCheck),
chkWv(:,it) = DATA(stCheck(it)+(-10:20),11,1);   % From DATA - works well
chkWv2(:,it) = chanData.Wav1.data(stCheck(it)+(s-10:20)); % Assumes NO offset in .SEV files
chkWv3(:,it) = chanData.Wav1.data(stCheck(it)+(-10:20)); % Assumes 40 sample offset in .SEV files
end