classdef BaseIO
    % Base class for IO operations
    % this class defines the variable names, file names, and path for the
    % outputs of the analysis pipeline for neuralyphysiological data.
    
    properties (Abstract)
        samplingRate           % Sampling rate for the data
        system
    end
    
    properties
        basePath
        workDir

        expName
        expId
        patientId

        microCscVarName = 'data';       % Continuously Sample Channel (CSC) Acquisition Entities
        macroCSCVarName = 'data';
        spikeVarName = 'spikes';

        microCscFilePath       % cell (n, 1). Name of the files
        macroCscFilePath
        spikeFilePath
        microLfpFilePath
        macroLfpFilePath

        microChannels = {};      % cell (n, 1). Name of the files
        macroChannels = {};

        nwbFileName
    end
    
    % Abstract method to be implemented in subclasses
    methods (Abstract)
        readData(obj)   
        writeData(obj)
    end
    
    methods
        function obj = BaseIO(patientId, expName, expId)
            if isunix
                homeDir = getenv('HOME');
                basePath = fullfile(homeDir, 'u', 'project', 'ifried', 'data', 'PIPELINE_vc', 'ANALYSIS');
            elseif ismac
                homeDir = getenv('HOME');
                basePath = fullfile(homeDir, 'HoffmanMount', 'data', 'PIPELINE_vc', 'ANALYSIS');
            else
                error('Unknown system.');
            end

            obj.workDir = fullfile(basePath, expName, [num2str(patientId), '_', expName], ['Experiment', sprintf('-%d', expId)]);
            if length(expId) == 1
                obj.microCscFilePath = fullfile(obj.workDir, 'CSC_micro');
                obj.macroCscFilePath = fullfile(obj.workDir, 'CSC_macro');
            end

            obj.microLfpFilePath = fullfile(obj.workDir, 'LFP_micro');
            obj.spikeFilePath = fullfile(obj.workDir, 'CSC_micro_spikes');
            obj.macroLfpFilePath = fullfile(obj.workDir, 'LFP_macro');
        end
    end

end
