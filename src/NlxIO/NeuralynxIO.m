classdef NeuralynxIO < BaseIO
    % Subclass for Neuralynx format

    properties (Access = public)
        samplingRate = 32000;       % Sampling rate specific to Neuralynx
        system = 'Neuralynx';
    end

    methods
        function obj = NeuralynxIO(patientId, expName, expId)
            obj@BaseIO(patientId, expName, expId);
        end

        function readData(obj, inputPath)
            % Implementation specific to Neuralynx format
            disp(['Reading Neuralynx data from ' inputPath]);

        end

        function writeData(obj)
            disp(['Writing Neuralynx data to ' obj.basePath]);
        end
    end
end
