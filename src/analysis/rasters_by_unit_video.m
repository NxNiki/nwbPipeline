function [] = rasters_by_unit_video(subject, trialFolder, imageDirectory, plotResponsive, outputPath, targetLabel)

if ~exist(outputPath, "dir")
    mkdir(outputPath)
end

if nargin < 7
    targetLabel = [];
end

[clustersToPlot, sr] = getClusters(trialFolder, plotResponsive, targetLabel);

plotsPerPage = 8;
totalNumStimuli = length(clustersToPlot{1, 'videoScreeningInfo'}{1});
pagesPerCluster =  ceil(clustersToPlot{:, 'videoNumSelective'}/plotsPerPage); %ceil(totalNumStimuli/plotsPerPage)*ones(size(responsiveClusters, 1), 1);
pagesPerCluster(pagesPerCluster==0) = 1;
numPages = sum(pagesPerCluster);

titleRect = [0 .9625 1 .025];

allVideoDir = dir(fullfile(imageDirectory, '*.mp4'));
allVideoTrialTags = regexp({allVideoDir.name}, '.*?(?=_id)','match','once');

allAudioDir = dir(fullfile(imageDirectory, '*.aiff'));
allAudioTrialTags = regexp({allAudioDir.name}, '.*?(?=_id)','match','once');


figNames = {};

parfor i = 1:numPages

    figNames{i} = fullfile(outputPath, ['rasters_p' num2str(i) '.pdf']);

    figure('Name',['Page ',num2str(i)],'units','normalized','position',[0.0238    0.0736    0.8    0.9],...
        'PaperUnits','inches','PaperPosition',[0 0 11 8.5],'PaperOrientation','landscape', 'Visible', 'off');
    set(gcf, 'Color', 'white');
    disp([num2str(i) ' of ' num2str(numPages)]);
    cumSumClusters = [0; cumsum(pagesPerCluster)];
    unitToPlot = find( i - cumSumClusters > 0, 1, 'last');
    posInPage = i - cumSumClusters(unitToPlot);
    nPagesInUnit = cumSumClusters(unitToPlot+1)-cumSumClusters(unitToPlot);
    clusterInfo = struct2table(clustersToPlot{unitToPlot, 'videoScreeningInfo'}{1});
    clusterInfo = sortrows(clusterInfo,'score','descend');

    axes1 = axes(gcf, 'Position', getAxisRect(0, 1));
    plot(axes1, (1:74)/sr*1000, clustersToPlot{unitToPlot, 'allWaveforms'}{1}', 'Color', 'blue');
    hold(axes1, 'on');
    plot(axes1, (1:74)/sr*1000, clustersToPlot{unitToPlot, 'meanWaveform'}{1}, 'Color', 'black', 'LineWidth', 1.5);
    hold(axes1, 'off');
    thisUnitWaveDuration = clustersToPlot{unitToPlot, 'waveDuration'};
    if thisUnitWaveDuration > .65
        title(axes1, ['Spike Width: ', num2str(round(thisUnitWaveDuration,2)), ' ms (P)']);
    else
        title(axes1, ['Spike Width: ', num2str(round(thisUnitWaveDuration,2)), ' ms (I)']);
    end
    xlim(axes1, [0 74/sr*1000]);

    axes2 = axes(gcf, 'Position', getAxisRect(0, 2));
    ISITimes = 1000*diff(clustersToPlot{unitToPlot, 'allTimes'}{1}); ISITimes(ISITimes>100)=[];
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

    unitsToPlot = (posInPage-1)*plotsPerPage + [1:plotsPerPage];
    unitsToPlot(unitsToPlot > totalNumStimuli) = [];

    imageLimits = [-500 1000]; audioLimits = [-500 2000]; videoLimits = [-1000 10000];
    ncols = 3; nrows = 3;
    for j = 1:length(unitsToPlot)

        imageAxes = axes(gcf, 'Position', getAxisRect(j, 1, ncols, nrows));
        thisImageTrialTag = clusterInfo{unitsToPlot(j), 'imageName'}{1};
        videoLookupIdx = find(strcmp(allVideoTrialTags, thisImageTrialTag), 1);
        audioLookupIdx = find(strcmp(allAudioTrialTags, thisImageTrialTag), 1);
        
        if ~isempty(videoLookupIdx)
            try
                [y, Fs] = audioread(fullfile(imageDirectory, allVideoDir(videoLookupIdx).name));
                plot(imageAxes, 1000/Fs*(1:length(y)), y(:, 1));
                xlim(imageAxes, videoLimits);
            end
        elseif ~isempty(audioLookupIdx)
            [y, Fs] = audioread(fullfile(imageDirectory, allAudioDir(audioLookupIdx).name));
            plot(imageAxes, 1000/Fs*(1:length(y)), y(:, 1));
            xlim(imageAxes, audioLimits);

        end
        if any(strcmp('responseOnset',fieldnames(clusterInfo)))% isfield(clusterInfo, 'responseOnset')
            try
                responseOnset = clusterInfo{unitsToPlot(j), 'responseOnset'}{1};
            catch
                responseOnset = clusterInfo{unitsToPlot(j), 'responseOnset'};
            end
        else
            responseOnset = [];
        end
        if length(thisImageTrialTag)>20, thisImageTrialTag = thisImageTrialTag(1:20);end
        if responseOnset
            title(imageAxes, [strrep(thisImageTrialTag, '_', '\_'), ' (' num2str(round(clusterInfo{unitsToPlot(j), 'score'},1)) '), ' num2str(round(responseOnset)) ' ms'], 'FontSize', 8,'Interpreter','tex');
        else
            title(imageAxes, [strrep(thisImageTrialTag, '_', '\_'), ' (' num2str(round(clusterInfo{unitsToPlot(j), 'score'},1)) ')'], 'FontSize', 8,'Interpreter','tex');
        end
        rasterAxes = axes(gcf, 'Position', getAxisRect(j, 2, ncols, nrows));
        if iscell(clusterInfo{unitsToPlot(j), 'spikes'}) && length(clusterInfo{unitsToPlot(j), 'spikes'}) == 1
            spikeTimes = clusterInfo{unitsToPlot(j), 'spikes'}{1};
        else
            spikeTimes = clusterInfo{unitsToPlot(j), 'spikes'}; %{1}
        end

        for k = 1:length(spikeTimes)
            if numel(spikeTimes{k}) > 0
                trialSpikeTimes = spikeTimes{k};
                if ~isempty(videoLookupIdx)
                    trialSpikeTimes(trialSpikeTimes < videoLimits(1) | trialSpikeTimes > videoLimits(2)) = [];
                elseif ~isempty(audioLookupIdx)
                    trialSpikeTimes(trialSpikeTimes < audioLimits(1) | trialSpikeTimes > audioLimits(2)) = [];
                else
                    trialSpikeTimes(trialSpikeTimes < imageLimits(1) | trialSpikeTimes > imageLimits(2)) = [];
                end
                spikeTimesToPlot = [trialSpikeTimes, trialSpikeTimes];
                thisTrialVertPos = repmat([k-.4, k+.4], numel(trialSpikeTimes), 1);
                plot(rasterAxes, spikeTimesToPlot', thisTrialVertPos', 'Color', 'black');
                hold(rasterAxes, 'on');
            end
        end

        ylim(rasterAxes, [.6, length(spikeTimes)+.4]);

        if ~isempty(audioLookupIdx)
            xlim(rasterAxes, [-500, 2000]); xticks(rasterAxes, -500:1000:2000);
        elseif ~isempty(videoLookupIdx)
            xlim(rasterAxes, [-1000, 10000]); xticks(rasterAxes, -1000:2500:10000);
        else
            xlim(rasterAxes, [-1000, 10000]); xticks(rasterAxes, -1000:2500:10000);
        end

        plot(rasterAxes, [0, 0 ], [.6, length(spikeTimes)+.4], 'Color', 'green');
        if responseOnset
            plot(rasterAxes, [responseOnset, responseOnset ], [.6, length(spikeTimes)+.4], 'Color', 'red');
        end
        hold(rasterAxes, 'off');

        histAxes = axes(gcf, 'Position', getAxisRect(j, 3, ncols, nrows));
        allSpikeTimes = vertcat(spikeTimes{:});

        if ~isempty(audioLookupIdx)
            histogram(histAxes, allSpikeTimes, -500:100:2000);
            xlim(histAxes, [-500, 2000]);   xticks(histAxes, -500:1000:2000);
            % ENM adding ylim as test
            % ylim(histAxes, [0,50]); yticks(histAxes, [0 25 50]);
        elseif ~isempty(videoLookupIdx)
            histogram(histAxes, allSpikeTimes, -1000:500:10000);
            xlim(histAxes, [-1000, 10000]);   xticks(histAxes, -1000:2500:10000);
            % ENM adding ylim as test
            % ylim(histAxes, [0,50]); yticks(histAxes, [0 25 50]);
        else
            histogram(histAxes, allSpikeTimes, -1000:500:10000);
            xlim(histAxes, [-1000, 10000]);   xticks(histAxes, -1000:2500:10000);
        end

    end

    thisTitle = [cell2mat(clustersToPlot{unitToPlot, 'cluster_region'}) ' Unit ' num2str(clustersToPlot{unitToPlot, 'cluster_num'}) ' (' num2str(posInPage) '/' num2str(nPagesInUnit) ')'];
    annotation('textbox',[0 .9625 1 .025],'units','normalized', 'String',thisTitle,'EdgeColor','none', 'HorizontalAlignment', 'center', 'FontSize', 15, 'FontWeight', 'bold','Interpreter','tex');

    xtickangle(findobj(gcf,'type','axes'),0);
    print(gcf,'-dpdf','-r100','-vector',figNames{i});

end


if plotResponsive
    merge_fn = ['Rasters_p' num2str(subject), '_ScreeningX_responsiveUnits'];
else
    merge_fn = ['Rasters_p' num2str(subject) '_ScreeningX_allUnits'];
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

% function [rect] = getAxisRect(pos, sub_pos)
% pos = pos + 1;
% vertNum = floor((pos-1)/6)+1;
% horzNum = mod(pos-1, 6) + 1;
% 
% nCols = 3; nRows = 3;
% top = .025; bottom = .025; edge = .025; verticalMaj = .05; verticalMin = .025; horiz = .025;
% verticalMajSize = 2/5*(1 - top - bottom - nRows*verticalMaj - 2*nRows*verticalMin)/nRows;
% verticalMinSize = 1/5*(1 - top - bottom - nRows*verticalMaj - 2*nRows*verticalMin)/nRows;
% horizSize = (1 - 2*edge - (nCols-1)*horiz)/nCols;
% 
% if sub_pos==1, subpos_factor = verticalMinSize+verticalMajSize+2*verticalMin;
% elseif sub_pos == 2, subpos_factor = verticalMinSize+verticalMin;
% else subpos_factor = 0;
% end
% 
% rect(1) = edge + (horzNum-1)*(horizSize+horiz);
% rect(2) = bottom + (nRows-vertNum)*(2*verticalMajSize+verticalMinSize+verticalMaj+2*verticalMin) + subpos_factor;
% rect(3) = horizSize;
% if sub_pos == 1 || sub_pos == 2, rect(4) = verticalMajSize; else rect(4) = verticalMinSize; end
% end
