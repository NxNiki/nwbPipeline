function [clu, tree] = run_cluster(par, multi_files)
% cluster_*.exe cannot handle long input file. So we copy it to the working
% directory and run the command without path of the input file name.

fprintf('run_cluster...\n');

% TO DO: check running time if fast we can avoid saving clu and tree...
tic
dim = par.inputs;
fname = par.fnamespc;
fname_in = par.fname_in;

currentDir = pwd;
[workingDir, fileName] = fileparts(fname);

% cluster*.exe needs to work in the directory of the input file.
cd(workingDir);

[~, fileNameIn] = fileparts(fname_in);

% DELETE PREVIOUS FILES
if exist([fname '.dg_01.lab'], 'file')
    delete([fname '.dg_01.lab']);
    delete([fname '.dg_01']);
end

dat = load(fname_in, '-ascii');
n = length(dat);
fid = fopen(sprintf('%s.run', fname), 'wt');
fprintf(fid, 'NumberOfPoints: %s\n', num2str(n));
fprintf(fid, 'DataFile: %s\n', fileNameIn);
fprintf(fid, 'OutFile: %s\n', fileName);
fprintf(fid, 'Dimensions: %s\n', num2str(dim));
fprintf(fid, 'MinTemp: %s\n', num2str(par.mintemp));
fprintf(fid, 'MaxTemp: %s\n', num2str(par.maxtemp));
fprintf(fid, 'TempStep: %s\n', num2str(par.tempstep));
fprintf(fid, 'SWCycles: %s\n', num2str(par.SWCycles));
fprintf(fid, 'KNearestNeighbours: %s\n', num2str(par.KNearNeighb));
fprintf(fid, 'MSTree|\n');
fprintf(fid, 'DirectedGrowth|\n');
fprintf(fid, 'SaveSuscept|\n');
fprintf(fid, 'WriteLables|\n');
fprintf(fid, 'WriteCorFile~\n');
if par.randomseed ~= 0
    fprintf(fid, 'ForceRandomSeed: %s\n', num2str(par.randomseed));
end    
fclose(fid);

system_type = computer;


switch system_type
    % window not tested.
    case {'PCWIN'}    
        [status, result] = dos(sprintf('"%s" %s.run', which('cluster.exe'), fname));
    case {'PCWIN64'}    
        [status, result] = dos(sprintf('"%s" %s.run', which('cluster_64.exe'), fname));
    case {'MAC'}
        cluster_file = which('cluster_mac.exe');
        [status, result] = unix(sprintf('%s %s.run', cluster_file, fname));
    case {'MACI', 'MACI64'}
        cluster_file = which('cluster_maci.exe');
        [status, result] = unix(sprintf('%s %s.run', cluster_file, fname));
    case {'GLNX86'}  
        cluster_file = which('cluster_linux.exe');
        [status, result] = unix(sprintf('%s %s.run', cluster_file, fname));
    case {'GLNXA64', 'GLNXI64'}
        cluster_file = which('cluster_linux64.exe');
        [status, result] = unix(sprintf('%s %s.run', cluster_file, fname));
    otherwise 
    	ME = MException('MyComponent:NotSupportedArq', '%s type of computer not supported.', system_type);
    	throw(ME)
end

if status ~= 0
    disp(result)
end

if exist('multi_files', 'var') && multi_files==true
	log_name = [par.filename 'spc_log.txt'];
	f = fopen(log_name, 'w');
	fprintf(f, ['----------\nSPC result of file: ' par.filename '\n']);
	fprintf(f, result);
	fclose(f);
else
	log_name = 'spc_log.txt';
	f = fopen(log_name, 'w');
	fprintf(f, result);
	fclose(f);
end

clu = load([fname '.dg_01.lab'], '-ascii');
tree = load([fname '.dg_01'], '-ascii'); 

clu = single(clu);
tree = single(tree);

fprintf('delete temp files for spike clustering\n %s', fname);
delete(sprintf('%s.run', fname));    
delete([fname '*.mag']);
delete([fname '*.edges']);
delete([fname '*.param']);
% delete([fname '.knn']);
delete(fname_in); 
delete([fname '.dg_01.lab']);
delete([fname '.dg_01']);
disp('delete files done!')
toc

cd(currentDir);
