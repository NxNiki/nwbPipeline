function [trials, TTLs, unrecognizedTTLs, TTLsUsedForTrialParsing, TTLsIgnoredForTrialParsing] = parseTTLs_Screening(eventsFile, ttlLogFile)
% Events are the output of the .nev file.
% This parses events into an n-TTL by 2 cell array with times and strings
% in each column.
% By accepting TTLs instead of events in the first argument, this allows
% someone to hand-modify the TTL cell array and then return it for furhter
% processing, in case something strange happened with the TTL creation
% during the experiment.

%% Load TTLs
TTLs = parseDAQTTLs(eventsFile, ttlLogFile);

%% divide TTLs by type
matches = @(str)cellfun(@(x)~isempty(regexp(x,str,'once')),TTLs(:,2));

serialInit = find(matches('serial_init'));
expt_start = find(matches('STARTING EXPERIMENT'));
timer_start = find(matches('Timer Start'));
start_frame = find(matches('Start Frame'));
instructions = find(matches('INSTRUCTION SLIDE'));
intro_slide = find(matches('Intro Slide'));
image_on = find(matches('IMAGE ON\:'));
image_off = find(matches('IMAGE OFF'));
behavioral_result = find(matches('correct'));
pressed_button = find(matches('PRESSED '));
new_room = find(matches('BEGINNING ROOM'));
score_slide = find(matches('SCORE SLIDE'));
bonus_sound = find(matches('bonus sound'));
ttlTest = find(matches('testingTTLs'));

recognizedTTLs = false(1,size(TTLs,2));
recognizedTTLs([serialInit;expt_start;pressed_button;new_room;...
    instructions;image_on;image_off;behavioral_result;...
    score_slide;bonus_sound;timer_start;start_frame;intro_slide;ttlTest])=1;

unrecognizedTTLs = TTLs(~recognizedTTLs,:);

TTLsUsedForTrialParsing = sort([expt_start;image_on;image_off;...
    pressed_button;new_room;behavioral_result]);
TTLsUsedForTrialParsing = TTLs(TTLsUsedForTrialParsing,:);

TTLsIgnoredForTrialParsing = sort([serialInit;instructions;...
    score_slide;bonus_sound; ttlTest]);
TTLsIgnoredForTrialParsing = TTLs(TTLsIgnoredForTrialParsing,:);

stimParams.stimulationType = 'None';
stimParams.stimOffset = [];
stimParams.stimOnset = [];

sessionIncludedStimulation = ~strcmp(stimParams.stimulationType, 'None');
if sessionIncludedStimulation
    stimDuration = stimParams.stimOffset-stimParams.stimOnset;
    fieldsToCopy = {'amp1','width1','amp2','width2','interPulseDelay','pulseFrequency',...
        'nPulsesPerBurst','interBurstDelay'};
    warning('Parsing for stimulation hasn''t been implemented yet!!');
end

%% Create trial info from TTLs

trialTemplate = struct('entryNumber',[],'trialNumber',[],...
    'trialTag',[],'imageID',[],'roomNumber',[],'roomInstruction',[],...
    'trialStartTime',[],'stimulusOnsetTime',[],...
    'stimulusOffsetTime',[],'trialEndTime',[],'response',[],...
    'delayToResponse',[],'respondedAtTime',[],...
    'wasStimulated',[],'stimulationOnsetTime',[],'stimulationOffsetTime',[],...
    'amp1',[],'width1',[],'amp2',[],'width2',[],...
    'interPulseDelay',[],'pulseFrequency',[],...
    'nPulsesPerBurst',[],'interBurstDelay',[],...
    'behavioralResult',[],'experimentPhase',[],...
    'excludeFromAnalysis',[],'reasonToExclude',[],...
    'experimentWithinDay',[],'inThisImageSet',[],...
    'imageCharacteristics',[],...
    'lfpTimeStamps',[]);

imageCharactersitcs = struct('human',[],'place',[],'animal',[],'edible',[],...
    'fantasyCreature',[],'sportEvent',[],'man',[],...
    'filmOrTVcelebrity',[],'sportsCelebrity',[],'musicCelebrity',[],...
    'religiousFigure',[],'politician',[],'terroristOrEnemy',[],...
    'fromUCLA',[],'landmark',[],'building',[],...
    'naturalLandscape',[],'cuteAnimal',[],'scaryAnimal',[],'livesOnLand',[],...
    'livesInWater',[],'canFly',[],'mammal',[],'adult',[],'dangerous',[],...
    'cartoon',[],'containsLetters',[],'containsPlants',[]);
charactersticFieldNames = {'human','place','animal','edible',...
    'fantasyCreature','sportEvent','man',...
    'filmOrTVcelebrity','sportsCelebrity','musicCelebrity',...
    'religiousFigure','politician','terroristOrEnemy',...
    'fromUCLA','landmark','building',...
    'naturalLandscape','cuteAnimal','scaryAnimal','livesOnLand',...
    'livesInWater','canFly','mammal','adult','dangerous',...
    'cartoon','containsLetters','containsPlants'};

instructions = {'people','animals','buildings','men','plants','women',...
    'men or animals','women or buildings','mammals'};

paradigmSpecificParameters.trialStartBeforeImageOnset = 1;
paradigmSpecificParameters.trialEndAfterImageOffset = 2;

stimPresentations = image_on;
nextPresentations = [stimPresentations(2:end);size(TTLs,1)];
% make a trial struct for each presentation
experimentNumberCounter = 0;
entryCounter = 0;
trials(length(stimPresentations)) = trialTemplate;

for s=1:length(stimPresentations)
    thisPresentation = stimPresentations(s);
    entryCounter = entryCounter+1;
    % if we've just gotten to a new experiment, reset the trial numbers
    if experimentNumberCounter < length(new_room) && ...
            thisPresentation > new_room(experimentNumberCounter+1)
        experimentNumberCounter = experimentNumberCounter+1;
        trialNumberCounter = 0;
        % check that the most recent "new_room" matches the current
        % experimentNumberCounter
        thisNewRoom = new_room(find(new_room<thisPresentation,1,'last'));
        roomNumber = str2double(regexp(TTLs{thisNewRoom,2},...
            '(?<=BEGINNING ROOM )\d+','match','once'));
        if roomNumber ~=experimentNumberCounter
            warning(['When room number said ',num2str(roomNumber),...
                ', experimentCounter said ',num2str(experimentNumberCounter),...
                '. Please double check your TTLs!'])
        end
    end

    thisTrial = trialTemplate;
    trialNumberCounter = trialNumberCounter+1;
    thisTrial.entryNumber = entryCounter;
    thisTrial.trialNumber = trialNumberCounter;
    thisTrial.stimulusOnsetTime = TTLs{thisPresentation,1};
    thisTrial.trialStartTime = thisTrial.stimulusOnsetTime-...
        paradigmSpecificParameters.trialStartBeforeImageOnset;
    thisTrial.roomNumber = roomNumber;
    thisTrial.roomInstruction = instructions{roomNumber};
    thisTrial.stimulusOffsetTime = TTLs{...
        image_off(image_off>thisPresentation &...
        image_off<nextPresentations(s)),1};
    thisTrial.trialEndTime = thisTrial.stimulusOffsetTime+...
        paradigmSpecificParameters.trialEndAfterImageOffset;
    response = pressed_button(pressed_button>thisPresentation &...
        pressed_button<nextPresentations(s));
    responseString = TTLs{response,2};
    thisTrial.response = lower(regexp(responseString,'(?<=PRESSED )\w*','match','once'));
    thisTrial.delayToResponse = str2double(regexp(responseString,'(?<=at )(\d|\.)+','match','once'));
    thisTrial.respondedAtTime = TTLs{response,1};
    behInd = behavioral_result(behavioral_result>thisPresentation &...
        behavioral_result<nextPresentations(s));
    if isempty(behInd)
        behInd = behavioral_result(behavioral_result>thisPresentation);
    end
    thisTrial.behavioralResult = TTLs{behInd,2};
    thisTrial.experimentPhase = 'imageClassification';
    thisTrial.experimentWithinDay = experimentNumberCounter;
    thisTrial.trialTag = regexp(TTLs{thisPresentation,2},...
        '(?<=IMAGE ON\: ).*?(?=_id)','match','once');
    [imageID e] = regexp(TTLs{thisPresentation,2},...
        '(?<=_id)\d+','match','end','once');
    thisTrial.imageID = str2double(imageID);
    trialCharactersticsString = regexp(TTLs{thisPresentation,2}(e+2:end),...
        '[01]*','match','once');
    theseCharacterstics = imageCharactersitcs;
    for f = 1:length(charactersticFieldNames)
        theseCharacterstics.(charactersticFieldNames{f}) = ...
            logical(str2double(trialCharactersticsString(f)));
    end
    thisTrial.imageCharacteristics = theseCharacterstics;
    trials(s) = thisTrial;
end


trialTags = {trials.trialTag};
for t=1:length(trials)
    if isempty(trials(t).inThisImageSet)
        tag = trials(t).trialTag;
        sameTag = find(ismember(trialTags,tag));
        for s=1:length(sameTag)
            trials(sameTag(s)).inThisImageSet = sameTag;
        end
    end
end

% sanity check for TTL success
imageSetSizes = mode(arrayfun(@(x)length(x.inThisImageSet),trials));
looksGood = arrayfun(@(x)length(x.trialStartTime)==1,trials);
looksGood(2,:) = arrayfun(@(x)length(x.trialEndTime)==1,trials);
looksGood(3,:) = arrayfun(@(x)length(x.respondedAtTime)==1,trials);
looksGood(4,:) = arrayfun(@(x)~isempty(regexp(x.response,'^(yes)|(no)$','once')),trials);
looksGood(5,:) = arrayfun(@(x)length(x.inThisImageSet)==imageSetSizes,trials);

suspicious = find(~all(looksGood));
if ~isempty(suspicious)
    warning(['TTLs for the following trials were suspicious. Please double check!  ',num2str(suspicious)]);
end