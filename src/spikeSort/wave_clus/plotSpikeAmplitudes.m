function plotSpikeAmplitudes()
% plot spike Amplitudes for selected clusters.

[spikes, classes] = getUserData([2, 6]);

peakWindow = getSpikePeakWindow(spikes);
spikeAmplitudes = getSpikeAmplitude(spikes, peakWindow);


spikeAmplitudeDistributionUI(classes, spikeAmplitudes)

end


function spikeAmplitudeDistributionUI(classes, spikeAmplitudes)
    % Ensure classes and spikeAmplitudes are column vectors
    classes = classes(:);
    spikeAmplitudes = spikeAmplitudes(:);

    % Get unique classes
    uniqueClasses = unique(classes);

    % Define a color map for the classes
    colors = lines(length(uniqueClasses));

    % Create the main figure
    fig = figure('Name', 'Spike Amplitude Distribution', 'NumberTitle', 'off', 'Position', [100, 100, 800, 600]);

    % Create axes for plotting
    ax = axes('Parent', fig, 'Position', [0.3, 0.2, 0.65, 0.7]);
    xlabel(ax, 'Spike Amplitudes');
    ylabel(ax, 'Frequency');
    title(ax, 'Spike Amplitude Distribution');
    hold(ax, 'on');

    % Create a panel for checkboxes
    checkboxPanel = uipanel('Parent', fig, 'Title', 'Classes', 'Position', [0.05, 0.2, 0.2, 0.7]);

    % Create checkboxes for each class
    checkboxes = gobjects(length(uniqueClasses), 1);
    for i = 1:length(uniqueClasses)
        checkboxes(i) = uicontrol('Parent', checkboxPanel, 'Style', 'checkbox', 'String', sprintf('Class %d', uniqueClasses(i)), ...
            'Position', [10, 300 - 30 * i, 100, 20], 'Value', 1);
    end

    % Create an edit box for bin size
    uicontrol('Parent', fig, 'Style', 'text', 'String', 'Bin Size:', 'Position', [200, 50, 60, 20]);
    binSizeEdit = uicontrol('Parent', fig, 'Style', 'edit', 'String', '30', 'Position', [260, 50, 60, 25]);

    % Create a button to plot
    plotButton = uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', 'Plot', ...
        'Position', [350, 50, 100, 40], 'Callback', @plotButtonCallback);

    % Callback function for the plot button
    function plotButtonCallback(~, ~)
        % Get selected classes
        selectedClasses = uniqueClasses(arrayfun(@(cb) get(cb, 'Value'), checkboxes) == 1);

        % Get bin size from edit box
        binSize = str2double(get(binSizeEdit, 'String'));
        if isnan(binSize) || binSize <= 0
            errordlg('Please enter a valid positive number for the bin size.', 'Invalid Input');
            return;
        end

        % Clear the axes
        cla(ax);
        legendEntries = {};

        % Plot histograms for each selected class
        for i = 1:length(selectedClasses)
            classIdx = selectedClasses(i);
            classAmplitudes = spikeAmplitudes(classes == classIdx);
            histogram(ax, classAmplitudes, 'BinEdges', linspace(min(spikeAmplitudes), max(spikeAmplitudes), binSize), ...
                'FaceColor', colors(i, :), 'EdgeColor', 'none', 'FaceAlpha', 0.7);
            legendEntries{end+1} = sprintf('Class %d', classIdx); %#ok<AGROW>
        end

        % Add legend
        legend(ax, legendEntries, 'Location', 'best');
        xlabel(ax, 'Spike Amplitudes');
        ylabel(ax, 'Frequency');
        title(ax, sprintf('Spike Amplitude Distribution for Classes [%s]', num2str(selectedClasses')));
    end
end


