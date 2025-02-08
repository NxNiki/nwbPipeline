function [] = rasters_by_image(subject, trialFolder, stimDirectory, targetLabel, outputPath)

if ~exist('targetLabel', "var")
    targetLabel = [];
end

if ~exist('outputPath', "var")
    outputPath = trialFolder;
end

outputPath = fullfile(outputPath, 'raster_plots_byimage');
if ~exist(outputPath, "dir")
    mkdir(outputPath)
end

% select reponsive clusters:
[clustersToPlot, sr] = getClusters(trialFolder, 1, targetLabel);

log10_thresh = 3;
nCols = 5; 
nRows = 8;
plotsPerPage = nCols * nRows;

if height(clustersToPlot) < 1
    return
end

numImages = length(clustersToPlot{1, 'stim'}{1});
numClusters = height(clustersToPlot);
pagesPerImage = ceil(numClusters/plotsPerPage);%7*ones(size(responsiveClusters, 1), 1);%
numPages = numImages*pagesPerImage;

% reorganize cluster information by stimuli:
imageCharacteristics = [];
for i = 1:numImages
    thisImage.name = clustersToPlot{1, 'stim'}{1}(i).stimName;
    thisImage.stimId = clustersToPlot{1, 'stim'}{1}(i).stimId;
    clusterInfo = struct;
    for j = 1:numClusters
        clusterInfo(j).spikes = clustersToPlot{j, 'stim'}{1}(i).spikes;
        clusterInfo(j).score = clustersToPlot{j, 'stim'}{1}(i).score;
        clusterInfo(j).responseOnset = clustersToPlot{j, 'stim'}{1}(i).responseOnset;
        if isempty(clusterInfo(j).responseOnset), clusterInfo(j).responseOnset = NaN; end
        clusterInfo(j).csc_num = clustersToPlot{j, 'csc_num'};
        clusterInfo(j).cluster_num = clustersToPlot{j, 'cluster_num'};
        clusterInfo(j).cluster_region = clustersToPlot{j, 'cluster_region'};
    end
    thisImage.totalScore = sum([clusterInfo.score]);
    thisImage.numResponsiveClusters = sum([clusterInfo.score]>log10_thresh);
    thisImage.clusterInfo = {clusterInfo};
    imageCharacteristics = [imageCharacteristics; struct2table(thisImage, 'AsArray', 1)];
end
clear clustersToPlot;

imageCharacteristics = sortrows(imageCharacteristics, 'numResponsiveClusters', 'descend');
figNames = {};
[~, stimIds, stimNames] = getStimInfo(stimDirectory);

parfor i = 1:numPages

    disp([num2str(i) ' of ' num2str(numPages)]);
    stimIndex = floor((i-1)/pagesPerImage)+1;

    % get units to plot on the current page:
    posInPage = mod(i-1, pagesPerImage)+1;
    unitsToPlot = (posInPage-1) * plotsPerPage + 1:plotsPerPage;
    unitsToPlot(unitsToPlot > numClusters) = [];

    figNames{i} = fullfile(outputPath, ['image_rasters_p' num2str(i) '.pdf']);
    figure('Name', ['Page ',num2str(i)], ...
        'units','normalized', ...
        'position',[0.0238    0.0736    0.8    0.9],...
        'PaperUnits','inches', ...
        'PaperPosition',[0 0 11 8.5], ...
        'PaperOrientation','landscape', ...
        'Visible', 'off' ...
        );
    set(gcf, 'Color', 'white');

    clusterInfo = imageCharacteristics{stimIndex, 'clusterInfo'}{1};
    stimId = imageCharacteristics{stimIndex, 'stimId'};
    [~, unitOrder] = sort([clusterInfo.responseOnset], 'ascend');

    xLimit = [-500, 1000];
    xTicks = -500:500:1000;
    stimName = stimNames{stimIds==stimId};
    if endsWith(stimName, '.jpg')
        image = imread(fullfile(stimDirectory, stimName));
        imageAxes = axes(gcf, 'Position', [.425, .8 .15 .15]);
        imshow(image, 'Parent', imageAxes);
    elseif endsWith(stimName, '.aiff')
        xLimit = [-500, 1500]; 
        xTicks = -500:1000:1500;
    elseif endsWith(stimName, '.mp4')
        xLimit = [-2500, 10000];
        xTicks = -2500:2500:10000;
    else
        warning('unrecognized stim type for %s\n', stimName);
    end

    for j = 1:length(unitsToPlot)
        
        clusterIndex = unitOrder(unitsToPlot(j));
        if clusterInfo(clusterIndex).score < 2.7
            continue
        end

        responseOnset = clusterInfo(clusterIndex).responseOnset;
        rasterAxes = axes(gcf, 'Position', getAxisRect(j, 0, nCols, nRows));
        spikeTimes = clusterInfo(clusterIndex).spikes;
        for k = 1:length(spikeTimes)
            if numel(spikeTimes{k}) > 0
                thisTrialSpikeTime = [spikeTimes{k}, spikeTimes{k}];
                thisTrialVertPos = repmat([k-.4, k+.4], numel(spikeTimes{k}), 1);
                plot(rasterAxes, thisTrialSpikeTime', thisTrialVertPos', 'Color', 'black');
                hold(rasterAxes, 'on');
            end
        end

        xlim(rasterAxes, xLimit); xticks(rasterAxes, xTicks);
        ylim(rasterAxes, [.6, length(spikeTimes)+.4]);

        if ~isnan(responseOnset) && responseOnset
            axesTitle = sprintf( ...
                'CSC %d Unit %d %s, %d ms (%.2f)', ...
                clusterInfo(clusterIndex).csc_num, ...
                clusterInfo(clusterIndex).cluster_num, ...
                strrep(clusterInfo(clusterIndex).cluster_region{1}, 'times_', ''), ...
                responseOnset, ...
                clusterInfo(clusterIndex).score ...
            );
            
            plot(rasterAxes, [responseOnset, responseOnset ], [.6, length(spikeTimes)+.4], 'Color', 'red');
        else
            axesTitle = sprintf( ...
                'CSC %d Unit %d %s, (%.1f)', ...
                clusterInfo(clusterIndex).csc_num, ...
                clusterInfo(clusterIndex).cluster_num, ...
                strrep(clusterInfo(clusterIndex).cluster_region{1}, 'times_', ''), ...
                clusterInfo(clusterIndex).score ...
            );
        end
        title(rasterAxes, axesTitle, 'FontSize', 8);
        hold(rasterAxes, 'off');
    end

    thisTitle = [strrep(imageCharacteristics{stimIndex, 'name'}{1}, '_', '\_')];
    annotation('textbox', [0 .9625 1 .025], 'units', 'normalized', 'String', thisTitle, 'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center', 'FontSize', 15, 'FontWeight', 'bold', 'interpreter', 'tex');

    xtickangle(findobj(gcf, 'type', 'axes'), 0)
    print(gcf, '-dpdf', '-r100', '-vector', figNames{i})
end

merge_fn = ['Rasters_p' num2str(subject) '_screening_byImage.pdf'];
mergePdfs(figNames, fullfile(outputPath, merge_fn))
cellfun(@delete, figNames)

end

