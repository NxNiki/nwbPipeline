function startParPool(mem_per_worker)

    if nargin < 1
        % Estimate memory usage per worker (in bytes, e.g., 1 GB)
        mem_per_worker = 1 * 1024^3;  
    end

    % Get system memory info
    if ispc  % For Windows
        [~, system_info] = memory;
        totalPhysicalMemory = system_info.PhysicalTotal;
    else  % For UNIX/Mac, example using system command
        [~, cmdout] = system('sysctl hw.memsize');
        totalPhysicalMemory = str2double(regexp(cmdout, '\d+', 'match'));
    end

    % Calculate max number of workers
    max_workers = floor(totalPhysicalMemory *.8 / mem_per_worker);

    % Get current pool information
    pool = gcp('nocreate');

    % Adjust the pool size if necessary
    fprintf('start pool with %d workers', max_workers);
    if isempty(pool)
        parpool(max_workers);
    elseif pool.NumWorkers ~= max_workers
        delete(pool);
        parpool(max_workers);
    end
end
