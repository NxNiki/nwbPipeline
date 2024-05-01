classdef NeuralynxIO < BaseIO
    % Subclass for Neuralynx format
    
    properties (Access = public)
        samplingRate    % Sampling rate specific to Neuralynx
    end
    
    methods
        function obj = NeuralynxIO(filenames)
            obj@BaseIO(filenames);
            
        end
        
        function readData(obj)
            % Implementation specific to Neuralynx format
            disp(['Reading Neuralynx data from ' obj.filename]);

            obj.samplingRate = samplingRate;
        end
    end
end
