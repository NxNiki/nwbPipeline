function [] = rasters_by_image(subject, trialFolder, imageDirectory, outputPath)

if ~exist('outputPath', "var")
    outputPath = trialFolder;
end

outputPath = fullfile(outputPath, 'raster_plots_byimage');

if ~exist(outputPath, "dir")
    mkdir(outputPath)
end

clusterFile = load(fullfile(trialFolder, 'clusterCharacteristics.mat'));
allClusters = clusterFile.clusterCharacteristics;


responsiveClusters = allClusters(allClusters.numSelective > 0, :);
log10_thresh = 3;
nCols = 5; nRows = 8;
plotsPerPage = nCols * nRows;

if height(responsiveClusters) < 1
    return
end
numImages = length(responsiveClusters{1, 'stim'}{1});
numClusters = height(responsiveClusters);

pagesPerImage = ceil(numClusters/plotsPerPage);%7*ones(size(responsiveClusters, 1), 1);%
numPages = numImages*pagesPerImage;

imageCharacteristics = [];
for i = 1:numImages
    thisImage.name = responsiveClusters{1, 'stim'}{1}(i).stimName;
    clusterInfo = struct;
    for j = 1:numClusters
        clusterInfo(j).spikes = responsiveClusters{j, 'stim'}{1}(i).spikes;
        clusterInfo(j).score = responsiveClusters{j, 'stim'}{1}(i).score;
        clusterInfo(j).responseOnset = responsiveClusters{j, 'stim'}{1}(i).responseOnset;
        if isempty(clusterInfo(j).responseOnset), clusterInfo(j).responseOnset = NaN; end
        clusterInfo(j).csc_num = responsiveClusters{j, 'csc_num'};
        clusterInfo(j).cluster_num = responsiveClusters{j, 'cluster_num'};
        clusterInfo(j).cluster_region = responsiveClusters{j, 'cluster_region'};
    end
    thisImage.totalScore = sum([clusterInfo.score]);
    thisImage.numResponsiveClusters = sum([clusterInfo.score]>log10_thresh);
    thisImage.clusterInfo = {clusterInfo};
    imageCharacteristics = [imageCharacteristics; struct2table(thisImage, 'AsArray', 1)];
end

imageCharacteristics = sortrows(imageCharacteristics,'numResponsiveClusters','descend');

allImageDir = dir(fullfile(imageDirectory, '*.jpg'));
allImageTrialTags = regexp({allImageDir.name}, '.*?(?=_id)','match','once');

allVideoDir = dir(fullfile(imageDirectory, '*.mp4'));
allVideoTrialTags = regexp({allVideoDir.name}, '.*?(?=_id)','match','once');

allAudioDir = dir(fullfile(imageDirectory, '*.aiff'));
allAudioTrialTags = regexp({allAudioDir.name}, '.*?(?=_id)','match','once');

figNames = {};

parfor i = 1:numPages
    figNames{i} = fullfile(outputPath, ['image_rasters_p' num2str(i) '.pdf']);
    figure('Name',['Page ',num2str(i)],'units','normalized','position',[0.0238    0.0736    0.8    0.9],...
        'PaperUnits','inches','PaperPosition',[0 0 11 8.5],'PaperOrientation','landscape', 'Visible', 'off');
    set(gcf, 'Color', 'white');
    disp([num2str(i) ' of ' num2str(numPages)]);
    imageToPlot = floor((i-1)/pagesPerImage)+1;
    posInPage = mod(i-1, pagesPerImage)+1;

    clusterInfo = imageCharacteristics{imageToPlot, 'clusterInfo'}{1};
    [~, unitOrder] = sort([clusterInfo.responseOnset], 'ascend');
    unitsToPlot = (posInPage-1)*plotsPerPage + [1:plotsPerPage];
    unitsToPlot(unitsToPlot > numClusters) = [];

    thisImageTrialTag = imageCharacteristics{imageToPlot, 'name'}{1};
    imageLookupIdx = find(strcmp(allImageTrialTags, thisImageTrialTag), 1);
    videoLookupIdx = find(strcmp(allVideoTrialTags, thisImageTrialTag), 1);
    audioLookupIdx = find(strcmp(allAudioTrialTags, thisImageTrialTag), 1);

    for j = 1:length(unitsToPlot)

        if clusterInfo(unitOrder(unitsToPlot(j))).score < 2.7
            continue
        end
        responseOnset = clusterInfo(unitOrder(unitsToPlot(j))).responseOnset;
        rasterAxes = axes(gcf, 'Position', getAxisRect(j, 0, nCols, nRows));
        spikeTimes = clusterInfo(unitOrder(unitsToPlot(j))).spikes;
        for k = 1:length(spikeTimes)
            if numel(spikeTimes{k}) > 0
                thisTrialSpikeTime = [spikeTimes{k}, spikeTimes{k}];
                thisTrialVertPos = repmat([k-.4, k+.4], numel(spikeTimes{k}), 1);
                plot(rasterAxes, thisTrialSpikeTime', thisTrialVertPos', 'Color', 'black');
                hold(rasterAxes, 'on');
            end
        end

        if ~isempty(imageLookupIdx)
            xlim(rasterAxes, [-500, 1000]); xticks(rasterAxes, -500:500:1000);
            ylim(rasterAxes, [.6, length(spikeTimes)+.4]);
        elseif ~isempty(audioLookupIdx)
            xlim(rasterAxes, [-500, 1500]); xticks(rasterAxes, -500:1000:1500);
            ylim(rasterAxes, [.6, length(spikeTimes)+.4]);

        elseif ~isempty(videoLookupIdx)
            xlim(rasterAxes, [-2500, 10000]); xticks(rasterAxes, -2500:2500:10000);
            ylim(rasterAxes, [.6, length(spikeTimes)+.4]);

        else
            xlim(rasterAxes, [-500, 1000]); xticks(rasterAxes, -500:500:1000);
            ylim(rasterAxes, [.6, length(spikeTimes)+.4]);
        end

        if ~isnan(responseOnset) && responseOnset
            title(rasterAxes, ['CSC ', num2str(clusterInfo(unitOrder(unitsToPlot(j))).csc_num), ...
                ' Unit ', num2str(clusterInfo(unitOrder(unitsToPlot(j))).cluster_num) ' ', ...
                clusterInfo(unitOrder(unitsToPlot(j))).cluster_region{1} ', ' ...
                num2str(round(responseOnset)) ' ms (' num2str(round(clusterInfo(unitOrder(unitsToPlot(j))).score, 1)) ')'], 'FontSize', 8);
            plot(rasterAxes, [responseOnset, responseOnset ], [.6, length(spikeTimes)+.4], 'Color', 'red');
        else
            title(rasterAxes, ['CSC ', num2str(clusterInfo(unitOrder(unitsToPlot(j))).csc_num), ...
                ' Unit ' num2str(clusterInfo(unitOrder(unitsToPlot(j))).cluster_num) ' ', ...
                clusterInfo(unitOrder(unitsToPlot(j))).cluster_region{1} ' (', ...
                num2str(round(clusterInfo(unitOrder(unitsToPlot(j))).score, 1)) ')'], 'FontSize', 8);
        end
        hold(rasterAxes, 'off');
    end

    imageAxes = axes(gcf, 'Position', [.425, .8 .15 .15]);
    thisImageTrialTag = imageCharacteristics{imageToPlot, 'name'}{1};
    lookupIdx = find(strcmp(allImageTrialTags, thisImageTrialTag), 1);
    if ~isempty(lookupIdx)
        image = imread(fullfile(imageDirectory, allImageDir(lookupIdx).name));
        imshow(image, 'Parent', imageAxes);
    end

    thisTitle = [strrep(imageCharacteristics{imageToPlot, 'name'}{1}, '_', '\_')];
    annotation('textbox',[0 .9625 1 .025], 'units', 'normalized', 'String', thisTitle, 'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center', 'FontSize', 15, 'FontWeight', 'bold', 'interpreter', 'tex');

    xtickangle(findobj(gcf,'type','axes'),0)
    print(gcf,'-dpdf','-r100','-vector', figNames{i})
end

merge_fn = ['Rasters_p' num2str(subject) '_screening_byImage.pdf'];
mergePdfs(figNames, fullfile(outputPath, merge_fn))
cellfun(@delete, figNames)

end

