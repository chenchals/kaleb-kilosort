classdef (Abstract=true) DataAdapter < handle
    
    properties (Access=protected)
        dataSource;
        dirStruct;
        fidArray;
    end
    
    methods (Abstract)
        getSampsToRead(obj,nChannels)
        batchRead(obj, readOffsetAllChan, nChannels, nSamples, dataTypeString)
        getWaveforms(obj, sampleWin, samples, channelNos)
    end
    
    methods (Access=public)
        % Close file handles
        function [] = closeAll(obj)
            for i = 1:numel(obj.fidArray)
               fclose(obj.fidArray(i));
            end
        end
    end
    
    methods (Static)
        function adapter = newDataAdapter(recordingSystem, source)
            switch lower(recordingSystem)
                case 'emouse'
                    adapter = EMouseDataAdapter(source);
                case 'tdt'
                    adapter = TdtDataAdapter(source);
                otherwise
                    error('Type must be either emouse or tdt');
            end
        end
    end
end



