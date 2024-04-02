classdef BaseIO
    % Base class for IO operations
    
    properties (Abstract)
        samplingRate    % Sampling rate for the data
        data        % Data read from the file
    end
    
    properties
        dirname
        filenames    % cell (n, 1). Name of the files
    end
    
    % Abstract method to be implemented in subclasses
    methods (Abstract)
        readData(obj)   

        writeData(obj)
    end
    
    methods
        function obj = BaseIO(filenames)
            obj.filenames = filenames;
        end
    end
end
