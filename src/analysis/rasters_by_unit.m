function [] = rasters_by_unit(subject, trialFolder, imageDirectory, plotResponsive, screeningType, targetLabel)

% screeningType: if "responseScreeningInfo", will create raster plot for
% key response, this will give larger time window before key press,
% otherwise if "screeningInfo", there will be a larger time window after
% the stimuli.

if nargin < 5
    screeningType = 'screeningInfo';
end

if nargin < 6
    targetLabel = [];
end

outputPath = fullfile(trialFolder, ['raster_plots_', screeningType]);
if ~exist(outputPath, "dir")
    mkdir(outputPath)
end

[clustersToPlot, sr] = getClusters(trialFolder, plotResponsive, targetLabel);

close all;
plotsPerPage = 17;

totalNumStimuli = length(clustersToPlot{1, screeningType}{1});

if strcmp(screeningType, 'videoScreeningInfo')
    clusterColLabel = 'videoNumSelective';
    rasterNCol = 3; rasterNRow = 3;
    stimColor = 'blue';
    stimLimits = (-1000:2500:10000);
    stimHistLimits = (-1000:500:10000);
else
    clusterColLabel = 'numSelective';
    rasterNCol = 6; rasterNRow = 3;
    stimColor = 'green';
    if strcmp(screeningType, 'responseScreeningInfo')
        stimLimits = (-1000:500:500);
        stimHistLimits = (-1000:50:500);
    else
        stimLimits = (-500:500:1000);
        stimHistLimits = (-500:50:1000);
    end
end
pagesPerCluster =  ceil(clustersToPlot{:, clusterColLabel}/plotsPerPage); %ceil(totalNumStimuli/plotsPerPage)*ones(size(responsiveClusters, 1), 1);
pagesPerCluster(pagesPerCluster==0) = 1;
numPages = sum(pagesPerCluster);

% titleRect = [0 .9625 1 .025];

allImageDir = dir(fullfile(imageDirectory, '*.jpg'));
allImageTrialTags = regexp({allImageDir.name}, '.*?(?=_id)','match','once');

allVideoDir = dir(fullfile(imageDirectory, '*.mp4'));
allVideoTrialTags = regexp({allVideoDir.name}, '.*?(?=_id)','match','once');

allAudioDir = dir(fullfile(imageDirectory, '*.aiff'));
allAudioTrialTags = regexp({allAudioDir.name}, '.*?(?=_id)','match','once');

figNames = cell(1, numPages);

% imageLimits = (-500:500:1000);
% imageHistLimits = (-500:50:1000);
% audioLimits = (-500:1000:2000);
% audioHistLimits = (-500:100:2000);
% audioLimits = (-500:500:1000);
% audioHistLimits = (-500:50:1000);
% videoLimits = (-1000:2500:10000);
% videoHistLimits = (-1000:500:10000);
% responseLimits = (-1000:500:500);
% responseHistLimits = (-1000:50:500);

parfor i = 1:numPages

    figNames{i} = fullfile(outputPath, ['rasters_', screeningType, '_p' num2str(i) '.pdf']);
    figure('Name', ['Page ',num2str(i)], ...
        'units','normalized', ...
        'position',[0.0238    0.0736    0.8    0.9],...
        'PaperUnits','inches', ...
        'PaperPosition',[0 0 11 8.5], ...
        'PaperOrientation','landscape', ...
        'Visible', 'off');
    set(gcf, 'Color', 'white');
    disp([num2str(i) ' of ' num2str(numPages)]);

    cumSumClusters = [0; cumsum(pagesPerCluster)];
    unitToPlot = find(i - cumSumClusters > 0, 1, 'last');
    posInPage = i - cumSumClusters(unitToPlot);
    nPagesInUnit = cumSumClusters(unitToPlot+1)-cumSumClusters(unitToPlot);
    clusterInfo = struct2table(clustersToPlot{unitToPlot, screeningType}{1});
    clusterInfo = sortrows(clusterInfo, 'score', 'descend');

    axes1 = axes(gcf, 'Position', getAxisRect(0, 1));
    plot(axes1, (1:74)/sr*1000, clustersToPlot{unitToPlot, 'allWaveforms'}{1}', 'Color', 'blue');
    hold(axes1, 'on');
    plot(axes1, (1:74)/sr*1000, clustersToPlot{unitToPlot, 'meanWaveform'}{1}, 'Color', 'black', 'LineWidth', 1.5);
    hold(axes1, 'off');
    thisUnitWaveDuration = clustersToPlot{unitToPlot, 'waveDuration'};
    if thisUnitWaveDuration > .65
        title(axes1, ['Spike Width: ', num2str(round(thisUnitWaveDuration, 2)), ' ms (P)']);
    else
        title(axes1, ['Spike Width: ', num2str(round(thisUnitWaveDuration, 2)), ' ms (I)']);
    end
    xlim(axes1, [0, 74/sr*1000]);

    axes2 = axes(gcf, 'Position', getAxisRect(0, 2));
    ISITimes = 1000*diff(clustersToPlot{unitToPlot, 'allTimes'}{1}); 
    ISITimes(ISITimes>100)=[];
    histogram(axes2, ISITimes, 0:10:100);
    xlim(axes2, [0 100]);

    %     allSpikeTimes = clustersToPlot{unitToPlot, 'allTimes'}{1};
    %     allTimeStamps = 0:1/1000:ceil(allSpikeTimes(end));
    %     allSpikeTrace = zeros(1, length(allTimeStamps));
    %     allSpikeTrace(round(allSpikeTimes*1e3)) = 1;
    %     smoothSpikeTrace = smooth(allSpikeTrace, 1000)*1000;
    %     smoothSpikeTrace(smoothSpikeTrace > mean(smoothSpikeTrace + 5*std(smoothSpikeTrace))) = 0;
    %     plot(axes2, allTimeStamps, smoothSpikeTrace');
    %     xlim(axes2, [0 ceil(allSpikeTimes(end))]);

    unitsToPlot = (posInPage-1)*plotsPerPage + (1:plotsPerPage);
    unitsToPlot(unitsToPlot > totalNumStimuli) = [];

    for j = 1:length(unitsToPlot)

        stimAxes = axes(gcf, 'Position', getAxisRect(j, 1, rasterNCol, rasterNRow));
        thisImageTrialTag = clusterInfo{unitsToPlot(j), 'imageName'}{1};
        imageLookupIdx = find(strcmp(allImageTrialTags, thisImageTrialTag), 1);

        % thisVideoTrialTag = clusterInfoVideo{unitsToPlot(j), 'imageName'}{1};
        videoLookupIdx = find(strcmp(allVideoTrialTags, thisImageTrialTag), 1);
        audioLookupIdx = find(strcmp(allAudioTrialTags, thisImageTrialTag), 1);
        if ~isempty(imageLookupIdx)
            imageFile = fullfile(imageDirectory, allImageDir(imageLookupIdx).name);
            fprintf('image: %s\n', allImageDir(imageLookupIdx).name)
            image = imread(imageFile);
            image = imresize(image, .2);
            imshow(image, 'Parent', stimAxes);
        elseif ~isempty(videoLookupIdx)
            try
                videoFile = fullfile(imageDirectory, allVideoDir(videoLookupIdx).name);
                fprintf('video: %s\n', allVideoDir(videoLookupIdx).name)
                [y, Fs] = audioread(videoFile);
                plot(stimAxes, 1000/Fs*(1:length(y)), y(:, 1));
                xlim(stimAxes, [stimLimits(1), stimLimits(end)]);
            catch
                warning('audio is not loaded successfully: %s', fullfile(imageDirectory, allVideoDir(videoLookupIdx).name))
            end
        elseif ~isempty(audioLookupIdx)
            [y, Fs] = audioread(fullfile(imageDirectory, allAudioDir(audioLookupIdx).name));
            plot(stimAxes, 1000/Fs*(1:length(y)), y(:, 1));
        end
        
        if any(strcmp('responseOnset', fieldnames(clusterInfo)))% isfield(clusterInfo, 'responseOnset')
            try
                responseOnset = clusterInfo{unitsToPlot(j), 'responseOnset'}{1};
            catch
                responseOnset = clusterInfo{unitsToPlot(j), 'responseOnset'};
            end
        else
            responseOnset = NaN;
        end
        if length(thisImageTrialTag)>20, thisImageTrialTag = thisImageTrialTag(1:20);end

        title(stimAxes, [strrep(thisImageTrialTag, '_', '\_'), ' (' num2str(round(clusterInfo{unitsToPlot(j), 'score'},1)) '), ' num2str(round(responseOnset)) ' ms'], 'FontSize', 8,'Interpreter','tex');
        rasterAxes = axes(gcf, 'Position', getAxisRect(j, 2 , rasterNCol, rasterNRow));
        if iscell(clusterInfo{unitsToPlot(j), 'spikes'}) && length(clusterInfo{unitsToPlot(j), 'spikes'}) == 1
            spikeTimes = clusterInfo{unitsToPlot(j), 'spikes'}{1};
        else
            spikeTimes = clusterInfo{unitsToPlot(j), 'spikes'}; %{1}
        end

        for k = 1:length(spikeTimes)
            if numel(spikeTimes{k}) > 0
                trialSpikeTimes = spikeTimes{k};
                trialSpikeTimes(trialSpikeTimes < stimLimits(1) | trialSpikeTimes > stimLimits(end)) = [];
                spikeTimesToPlot = [trialSpikeTimes, trialSpikeTimes];
                thisTrialVertPos = repmat([k-.4, k+.4], numel(trialSpikeTimes), 1);
                plot(rasterAxes, spikeTimesToPlot', thisTrialVertPos', 'Color', 'black');
                hold(rasterAxes, 'on');
            end
        end

        ylim(rasterAxes, [.6, length(spikeTimes)+.4]);
        xlim(rasterAxes, [stimLimits(1), stimLimits(end)]); 
        xticks(rasterAxes, stimLimits);

        plot(rasterAxes, [0, 0], [.6, length(spikeTimes)+.4], 'Color', stimColor);
        if ~isnan(responseOnset)
            plot(rasterAxes, [responseOnset, responseOnset], [.6, length(spikeTimes)+.4], 'Color', 'red');
        end
        hold(rasterAxes, 'off');

        histAxes = axes(gcf, 'Position', getAxisRect(j, 3, rasterNCol, rasterNRow));
        allSpikeTimes = vertcat(spikeTimes{:});

        histogram(histAxes, allSpikeTimes, stimHistLimits);
        xlim(histAxes, [stimHistLimits(1), stimHistLimits(end)]);
        xticks(histAxes, stimLimits);
    end

    thisTitle = [cell2mat(clustersToPlot{unitToPlot, 'cluster_region'}) ' Unit ' num2str(clustersToPlot{unitToPlot, 'cluster_num'}) ' (' num2str(posInPage) '/' num2str(nPagesInUnit) ')'];
    annotation('textbox', [0 .9625 1 .025], ...
        'units', 'normalized', ...
        'String', thisTitle, ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 15, ...
        'FontWeight', 'bold', ...
        'Interpreter', 'tex');

    xtickangle(findobj(gcf, 'type', 'axes'), 0);
    print(gcf,'-dpdf', '-r100', '-vector', figNames{i});

end

if plotResponsive
    merge_fn = ['Rasters_p' num2str(subject), '_', screeningType, '_responsiveUnits'];
else
    merge_fn = ['Rasters_p' num2str(subject) '_', screeningType, '_allUnits'];
end

mergeSegments = [1:50:length(figNames), length(figNames)+1];
for i = 2:length(mergeSegments)
    filenames1 = figNames(mergeSegments(i-1): (mergeSegments(i)-1));
    if length(filenames1) > 1
        mergePdfs(filenames1, fullfile(outputPath, sprintf('%s_%d_%d.pdf', merge_fn, mergeSegments(i-1), (mergeSegments(i)-1))));
    else
        movefile(filenames1{1}, fullfile(outputPath, sprintf('%s_%d_%d.pdf', merge_fn, mergeSegments(i-1), (mergeSegments(i)-1))))
    end
end

end



