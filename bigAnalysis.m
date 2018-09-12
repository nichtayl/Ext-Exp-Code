%%% examine performance of experimental and control animals across days
%%% assumes trialdata files have already been generated and that they have
%%% been concatenated using concatenateBehaviorData.mat and
%%% concatenateBehaviorData_headplateOnlyMice.mat

%%% NOTE ABOUT FRAME RATE ERRORS
%%% Sessions run before 171008 have frame rate error where cameras were
%%% collecting 1 frame/4.9 seconds or so --> 202.5 frames/s in the videos.
%%% Sessions run on/after 171008 have correct frame rate of 200 frames/sec


%% clean up workspace
clear all
close all

%% tell MATLAB whether I am working on the office desktop (ALBUS) or my laptop (OREK) so that it knows what directories to use
%machine = 'ALBUS';
machine = 'OREK';

%% establish directories and go to the one where I have the behavior data stored
if strcmp(machine, 'ALBUS')
    basedir = 'C:\olivia\data\concat beh dat';
    savedir = 'C:\olivia\data\behfigs';
elseif strcmp(machine, 'OREK')
    basedir = 'C:\Users\kimol\Documents\data\extinction project\datasets';
    savedir = 'C:\Users\kimol\Documents\data\extinction project\matlab output';
else
    disp('please tell MATLAB what machine you are using')
end
cd(basedir)
%mice = dir('OK*');

%% record of animal numbering/identity
% this is arbitrary animal numbering but consistent with what I used in
% concatenateBehaviorData and concatenateBehaviorData_OSMice
mice(1,1).name='OK135'; % WT w/ DCN-ChR2 virus
mice(2,1).name='OK137'; % WT w/ DCN-ChR2 virus
mice(3,1).name='OK138'; % WT w/ DCN-ChR2 virus
mice(4,1).name='OK134'; % WT w/ DCN-ChR2 virus
mice(5,1).name='OK159'; % WT w/ DCN-EYFP virus
mice(6,1).name='OK160'; % WT w/ DCN-EYFP virus
mice(7,1).name='OK148'; % WT w/ failed DCN-ChR2 virus (put into control group)
mice(8,1).name='OK161'; % WT w/ DCN-EYFP virus
mice(9,1).name='OK162'; % WT w/ DCN-EYFP virus

OSmice(1,1).name = 'OS005'; % WT
OSmice(2,1).name = 'OS006'; % WT
OSmice(3,1).name = 'OS007'; % WT
OSmice(4,1).name = 'OS008'; % WT

lightmice(1,1).name = 'OK001'; % dim LED CS, CS only extinction
lightmice(2,1).name = 'OK002'; % dim LED CS, CS only extinction
lightmice(3,1).name = 'OK003'; % dim LED CS, CS only extinction
lightmice(4,1).name = 'OK004'; % dim LED CS, CS only extinction
lightmice(5,1).name = 'OK005'; % bright LED CS, CS only extinction
lightmice(6,1).name = 'OK006'; % bright LED CS, CS only extinction
lightmice(7,1).name = 'OK007'; % bright LED CS, CS only extinction
lightmice(8,1).name = 'OK008'; % bright LED CS, CS only extinction
lightmice(9,1).name = 'S146'; % bring LED CS, unpaired extinction
lightmice(9,1).name = 'S147'; % bring LED CS, unpaired extinction
lightmice(9,1).name = 'S148'; % bring LED CS, unpaired extinction
lightmice(9,1).name = 'S149'; % bring LED CS, unpaired extinction

%% load behavior data
load('180830_DCNChR2ExtExpt_allAnimBehData.mat')
load('180830_DCNChR2ExtExpt_timeVector.mat')
load('180821_WTExtExpt_allAnimBehData.mat')

%% turn the trial data into useful data
%%% Things that I will need for the ultimate data analysis:
%%%     1. CR Probabiltiy for each day
%%%             a. Probability of some change in eyelid
%%%             position at the time of laser onset (180 ms from CS onset; excluding trials )
%%%     2. CR amplitude for each day
%%%             a. raw eyelid position at the time of laser onset
%%%             b. eyelid position at the time of laser onset minus eyelid
%%%             position in the baseline period
%%%     3. startle probability and amplitude for each day
%%%             a. alpha startle - short latency
%%%             b. beta startle - ~80 ms latency
%%%     4. session number and date
%%%     5. 

rbdatDayData = getDayData(rbdat, timeVector, [0.2; 0.1; 0.2; 0.1; 0.1; 0.1; 0.1; 0.1; 0.1]); 
% NOTE: NEED TO RERUN THE EXTINCTION DATASET ON
% concatenateBehaviorData_headplateOnlyMice so that there is a baseline
% field in that dataset. Changed getDayData to be able to accomodate the
% difference but it is inefficient
extdatDayData = getDayData(extdat, timeVector, 0.1*ones(length(unique(extdat.mouse)),1));


%% load the days to plot
% the spreadsheet itself should be self-explanatory. Each row lists the
% dates for a mouse's manipulation/pre-manipulation days. When the mouse
% had less than 10 days of the manipulation, there is a NaN. The headers in
% the file note which mouse/manipulation type there is.
cd('C:\olivia\data summaries')
[num, txt, raw] = xlsread('ExperimentalAndControl.xlsx');


%% organize and plot summary statistic data
[plotData.during] = trialsAndDatesIntoSummaryData(txt, raw, rbdatDayData, 'during'); % only works for the rbdat dataset so far
[plotData.after] = trialsAndDatesIntoSummaryData(txt, raw, rbdatDayData, 'after'); % only works for the rbdat dataset so far
[plotData.late] = trialsAndDatesIntoSummaryData(txt, raw, rbdatDayData, 'late'); % only works for the rbdat dataset so far
[plotData.early] = trialsAndDatesIntoSummaryData(txt, raw, rbdatDayData, 'early'); % only works for the rbdat dataset so far

colordef black
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.crprob, plotData.after.crprob, plotData.late.crprob, plotData.early.crprob, 'CR Probability', [0 1], [0 19], 'mean');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.cradjamp, plotData.after.cradjamp, plotData.late.cradjamp, plotData.early.cradjamp, 'CR Amplitude (adjusted)', [0 0.6], [0 19], 'mean');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.cradjampHit, plotData.after.cradjampHit, plotData.late.cradjampHit, plotData.early.cradjampHit, 'CR Amplitude (adjusted; Hit trials only)', [0 0.7], [0 19], 'mean');
plotExpVsCntPreAndManipulation(plotData.during.uramp, plotData.after.uramp, plotData.late.uramp, plotData.early.uramp, 'UR Amplitude', [0.5 1.05], [0 19], 'mean')
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.hituramp, plotData.after.hituramp, plotData.late.hituramp, plotData.early.hituramp, 'UR Amp (adjusted; Hit trials only)', [0.5 1.05], [0 19], 'mean');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.missuramp, plotData.after.missuramp, plotData.late.missuramp, plotData.early.missuramp, 'UR Amp (adjusted; Miss trials only)', [0.5 1.05], [0 19], 'mean');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.hiturint, plotData.after.hiturint, plotData.late.hiturint, plotData.early.hiturint, 'UR Integral (adjusted; Hit trials only)', [0.03 0.5], [0 19], 'mean');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.missurint, plotData.after.missurint, plotData.late.missurint, plotData.early.missurint, 'UR Integral (adjusted; Miss trials only)', [0.03 0.5], [0 19], 'mean');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.urint, plotData.after.urint, plotData.late.urint, plotData.early.urint, 'UR Integral ', [0.03 0.5], [0 19], 'mean');

[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.crprob, plotData.after.crprob, plotData.late.crprob, plotData.early.crprob, 'CR Probability', [0 1], [0 19], 'median');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.cradjamp, plotData.after.cradjamp, plotData.late.cradjamp, plotData.early.cradjamp, 'CR Amplitude (adjusted)', [0 0.6], [0 19], 'median');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.cradjampHit, plotData.after.cradjampHit, plotData.late.cradjampHit, plotData.early.cradjampHit, 'CR Amplitude (adjusted; Hit trials only)', [0 0.7], [0 19], 'median');
plotExpVsCntPreAndManipulation(plotData.during.uramp, plotData.after.uramp, plotData.late.uramp, plotData.early.uramp, 'UR Amplitude', [0.5 1.05], [0 19], 'median')
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.hituramp, plotData.after.hituramp, plotData.late.hituramp, plotData.early.hituramp, 'UR Amp (adjusted; Hit trials only)', [0.5 1.05], [0 19], 'median');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.missuramp, plotData.after.missuramp, plotData.late.missuramp, plotData.early.missuramp, 'UR Amp (adjusted; Miss trials only)', [0.5 1.05], [0 19], 'median');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.hiturint, plotData.after.hiturint, plotData.late.hiturint, plotData.early.hiturint, 'UR Integral (adjusted; Hit trials only)', [0.03 0.5], [0 19], 'median');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.missurint, plotData.after.missurint, plotData.late.missurint, plotData.early.missurint, 'UR Integral (adjusted; Miss trials only)', [0.03 0.5], [0 19], 'median');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.urint, plotData.after.urint, plotData.late.urint, plotData.early.urint, 'UR Integral ', [0.03 0.5], [0 19], 'median');


%% organize and plot mean eyelid trace data

[eyelidTrace.during] = trialsAndDatesIntoEyelidTraces(txt, raw, rbdatDayData, 'during', 0);
[eyelidTrace.after] = trialsAndDatesIntoEyelidTraces(txt, raw, rbdatDayData, 'after', 0);
[eyelidTrace.late] = trialsAndDatesIntoEyelidTraces(txt, raw, rbdatDayData, 'late', 0);
[eyelidTrace.early] = trialsAndDatesIntoEyelidTraces(txt, raw, rbdatDayData, 'early', 0);

[eyelidTraceAdj.during] = trialsAndDatesIntoEyelidTraces(txt, raw, rbdatDayData, 'during', 1);
[eyelidTraceAdj.after] = trialsAndDatesIntoEyelidTraces(txt, raw, rbdatDayData, 'after', 1);
[eyelidTraceAdj.late] = trialsAndDatesIntoEyelidTraces(txt, raw, rbdatDayData, 'late', 1);
[eyelidTraceAdj.early] = trialsAndDatesIntoEyelidTraces(txt, raw, rbdatDayData, 'early', 1);

% mean eyelid traces from first, second, fourth, and last days of the
% "during" manipulation
    % eyelidtrace not baseline adjusted
    legendLabels = {'baseline', 'laser 1', 'laser 3', 'laser 5', 'last laser'};
    titlestring = 'experimental animals: during photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC';
    [plottedTraces] = plotEyelidTraces(eyelidTrace.during.mean, [1,2,3,4], ...
        [2,3,5,7,8;2,3,5,7,9;2,3,5,7,12;2,3,5,7,12], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);

    legendLabels = {'baseline', 'laser 1', 'laser 3', 'laser 5', 'last laser'};
    titlestring = 'control animals: during photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC';
    [plottedTraces] = plotEyelidTraces(eyelidTrace.during.mean, [5,6,7,8,9], ...
        [2,3,5,7,12;2,3,5,7,12;2,3,5,7,12;2,3,5,7,12;2,3,5,7,12], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);

    % data adjusted to baseline each trial in getDayData
    legendLabels = {'baseline', 'laser 1', 'laser 3', 'laser 5', 'last laser'};
    titlestring = 'experimental animals: during photostimulation (FEC adjusted to baseline)';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC-baseline';
    [plottedTraces] = plotEyelidTraces(eyelidTraceAdj.during.mean, [1,2,3,4], ...
        [2,3,5,7,8;2,3,5,7,9;2,3,5,7,12;2,3,5,7,12], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    ylim([-0.01 1])

    legendLabels = {'baseline', 'laser 1', 'laser 3', 'laser 5', 'last laser'};
    titlestring = 'control animals: during photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC';
    [plottedTraces] = plotEyelidTraces(eyelidTraceAdj.during.mean, [5,6,7,8,9], ...
        [2,3,5,7,12;2,3,5,7,12;2,3,5,7,12;2,3,5,7,12;2,3,5,7,12], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    ylim([-0.01 1])
    

% plot mean hit and miss eyelid traces from during manipulation for experimental animals
    % baseline not adjusted
    legendLabels = {'baseline', 'laser 1', 'laser 3', 'laser 5', 'last laser'};
    titlestring = 'experimental animals: during photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC';
    [plottedTraces] = plotEyelidTraces(eyelidTrace.during.hitmean, [1,2,3,4], ...
        [2,3,5,7,8;2,3,5,7,9;2,3,5,7,12;2,3,5,7,12], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    
    legendLabels = {'baseline', 'laser 1', 'laser 3', 'laser 5', 'last laser'};
    titlestring = 'experimental animals: during photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC';
    [plottedTraces] = plotEyelidTraces(eyelidTrace.during.missmean, [1,2,3,4], ...
        [2,3,5,7,8;2,3,5,7,9;2,3,5,7,12;2,3,5,7,12], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    
    % baseline adjusted
    legendLabels = {'baseline', 'laser 1', 'laser 3', 'laser 5', 'last laser'};
    titlestring = 'experimental animals: during photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC';
    [plottedTraces] = plotEyelidTraces(eyelidTraceAdj.during.hitmean, [1,2,3,4], ...
        [2,3,5,7,8;2,3,5,7,9;2,3,5,7,12;2,3,5,7,12], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    ylim([-0.01 1])
    
    legendLabels = {'baseline', 'laser 1', 'laser 3', 'laser 5', 'last laser'};
    titlestring = 'experimental animals: during photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC';
    [plottedTraces] = plotEyelidTraces(eyelidTraceAdj.during.missmean, [1,2,3,4], ...
        [2,3,5,7,8;2,3,5,7,9;2,3,5,7,12;2,3,5,7,12], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    ylim([-0.01 1])


%% plot mean eyelid traces from last day of during manipulation and then a number of days of reacquisition
    % eyelidtrace not adjusted
    legendLabels = {'last laser', 'reacq 1', 'reacq 3', 'reacq 5'};
    titlestring = 'experimental animals: during photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC-baseline';
    [plottedTraces] = plotEyelidTraces(eyelidTrace.during.mean, [1,2,3,4], ...
        [8, 13, 15, 16;9, 13, 15, 16;12, 13, 15, 16;12, 13, 15, 16], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    
    
    legendLabels = {'last laser', 'reacq 1', 'reacq 2'};
    titlestring = 'control animals: during photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC';
    [plottedTraces] = plotEyelidTraces(eyelidTrace.during.mean, [5,6,7,8,9], ...
        [12, 13, 14;12, 13, 14;12, 13, NaN;12, 13, 14;12, 13, 14], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    

    % eyelidtrace baseline adjusted
    legendLabels = {'last laser', 'reacq 1', 'reacq 3', 'reacq 5'};
    titlestring = 'experimental animals: during photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC-baseline';
    [plottedTraces] = plotEyelidTraces(eyelidTraceAdj.during.mean, [1,2,3,4], ...
        [8, 13, 15, 16;9, 13, 15, 16;12, 13, 15, 16;12, 13, 15, 16], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    ylim([-0.01 1])
    
    legendLabels = {'last laser', 'reacq 1', 'reacq 2'};
    titlestring = 'control animals: during photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC';
    [plottedTraces] = plotEyelidTraces(eyelidTraceAdj.during.mean, [5,6,7,8,9], ...
        [12, 13, 14;12, 13, 14;12, 13, NaN;12, 13, 14;12, 13, 14], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    ylim([-0.01 1])

%% plot mean eyelid traces from last day of reacquition and then some days of late laser manipulation
    % eyelidtrace not adjusted
    legendLabels = {'baseline', 'laser 1', 'laser 3', 'last laser'};
    titlestring = 'experimental animals: late photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC-baseline';
    [plottedTraces] = plotEyelidTraces(eyelidTrace.late.mean, [1,2,3,4], ...
        [2, 3, 5, 12;2, 3, 5, 12;2, 3, 5, 12;2, 3, 5, 12], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    
    % eyelidtrace adjusted
    legendLabels = {'baseline', 'laser 1', 'laser 3', 'last laser'};
    titlestring = 'experimental animals: late photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC-baseline';
    [plottedTraces] = plotEyelidTraces(eyelidTraceAdj.late.mean, [1,2,3,4], ...
        [2, 3, 5, 12;2, 3, 5, 12;2, 3, 5, 12;2, 3, 5, 12], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    ylim([-0.01 1])
    

%% plot mean eyelid traces from last day of reacquisition and then some days of after laser manipulation
    % eyelidtrace not adjusted
    legendLabels = {'baseline', 'laser 1', 'laser 3', 'last laser'};
    titlestring = 'experimental animals: after photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC-baseline';
    [plottedTraces] = plotEyelidTraces(eyelidTrace.after.mean, [1,2,3,4], ...
        [2, 3, 5, 8;2, 3, 5, 12;2, 3, 5, 11;2, 3, 5, 12], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    
    % eyelidtrace adjusted
    legendLabels = {'baseline', 'laser 1', 'laser 3', 'last laser'};
    titlestring = 'experimental animals: after photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC-baseline';
    [plottedTraces] = plotEyelidTraces(eyelidTraceAdj.after.mean, [1,2,3,4], ...
        [2, 3, 5, 8;2, 3, 5, 12;2, 3, 5, 11;2, 3, 5, 12], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    ylim([-0.01 1])
    
    
%% plot mean eyelid traces from last day of reacquisition and then some days of early laser manipulation
    % eyelidtrace not adjusted
    legendLabels = {'baseline', 'laser 1', 'laser 3', 'last laser'};
    titlestring = 'experimental animals: early photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC-baseline';
    [plottedTraces] = plotEyelidTraces(eyelidTrace.early.mean, [1,2,3,4], ...
        [2, 3, 5, 12;2, 3, 5, 10;2, 3, 5, 12;2, 3, 5, 12], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    
    % eyelidtrace adjusted
    legendLabels = {'baseline', 'laser 1', 'laser 3', 'last laser'};
    titlestring = 'experimental animals: early photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC-baseline';
    [plottedTraces] = plotEyelidTraces(eyelidTraceAdj.early.mean, [1,2,3,4], ...
        [2, 3, 5, 12;2, 3, 5, 10;2, 3, 5, 12;2, 3, 5, 12], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    ylim([-0.01 1])

%% plot mean eyelid traces from last day of early laser and then some days of reacquisition
% not working for some reason
    % eyelidtrace not adjusted
    legendLabels = {'last laser', 'reacq 1', 'reacq 3', 'last reacq'};
    titlestring = 'experimental animals: early photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC-baseline';
    [plottedTraces] = plotEyelidTraces(eyelidTrace.early.mean, [1,2,3,4], ...
        [12, 13, 15, 18;10, 13, NaN, NaN;12, 13, 15, 17;12, 13, 15, 18], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    
    % eyelidtrace adjusted
    legendLabels = {'last laser', 'reacq 1', 'reacq 3', 'last reacq'};
    titlestring = 'experimental animals: early photostimulation';
    xlabelstring = 'time(s)';
    ylabelstring = 'FEC-baseline';
    [plottedTraces] = plotEyelidTraces(eyelidTraceAdj.early.mean, [1,2,3,4], ...
        [12, 13, 15, 18;10, 13, NaN, NaN;12, 13, 15, 17;12, 13, 15, 18], timeVector, legendLabels,...
        titlestring, xlabelstring, ylabelstring);
    ylim([-0.01 1])
  
%% get data for the early laser + laser alone sessions
cd('C:\olivia\data summaries')
[num, txt, raw] = xlsread('ExptAndControl_earlyLasAnd10LasAlone.xlsx');
[rows cols] = size(raw);


eyelidPos.lasAlone.mean = nan(1,1600);
eyelidPos.lasAlone.sem = nan(1,1600);
eyelidPos.earlyOnTest.mean = nan(1,1600);
eyelidPos.earlyOnTest.sem = nan(1,1600);
for r = 2:rows % start at row 2 because row 1 is just headers
    c = 3;% use col 3 because rows 1-2 is just headers
    thisDay = raw{r,c};
    thisMouse = raw{r,1};
    thisPhase = raw{r,2};
    mouse = 1;
    eyelidposCol = 1;
    if strcmpi(thisMouse,'OK137')
        mouse = 2;
        eyelidposCol = 201;
    elseif strcmpi(thisMouse,'OK138')
        mouse = 3;
        eyelidposCol = 401;
    elseif strcmpi(thisMouse,'OK134')
        mouse = 4;
        eyelidposCol = 601;
    elseif strcmpi(thisMouse,'OK159')
        mouse = 5;
        eyelidposCol = 801;
    elseif strcmpi(thisMouse,'OK160')
        mouse = 6;
        eyelidposCol = 1001;
    elseif strcmpi(thisMouse,'OK148')
        mouse = 7;
        eyelidposCol = 1201;
    elseif strcmpi(thisMouse,'OK161')
        mouse = 8;
        eyelidposCol = 1401;
    end
    
    if strcmpi(thisDay,'NaN')
        eyelidPos.lasAlone.mean(c-2,eyelidposCol:eyelidposCol+199) = nan;
        eyelidPos.lasAlone.sem(c-2,eyelidposCol:eyelidposCol+199) = nan;
        eyelidPos.earlyOnTest.mean(c-2,eyelidposCol:eyelidposCol+199) = nan;
        eyelidPos.earlyOnTest.sem(c-2,eyelidposCol:eyelidposCol+199) = nan;
    else
        eyelidPos.lasAlone.mean(c-2,eyelidposCol:eyelidposCol+199) = mean(rbdat.eyelidpos...
            (rbdat.date(:,1)==thisDay & ...
            rbdat.mouse(:,1)==mouse & rbdat.type(:,1)==1 &...
            rbdat.baselineMvt(:,1)==0 & rbdat.c_csdur(:,1) == 0,:));
        eyelidPos.lasAlone.sem(c-2,eyelidposCol:eyelidposCol+199) = std(rbdat.eyelidpos...
            (rbdat.date(:,1)==thisDay & ...
            rbdat.mouse(:,1)==mouse & rbdat.type==1 &...
            rbdat.baselineMvt==0 & rbdat.c_csdur==0,:))/sqrt(...
            sum(rbdat.date(:,1)==thisDay & ...
            rbdat.mouse(:,1)==mouse & rbdat.type==1 &...
            rbdat.baselineMvt==0 & rbdat.c_csdur==0));
        eyelidPos.earlyOnTest.mean(c-2,eyelidposCol:eyelidposCol+199) = mean(rbdat.eyelidpos...
            (rbdat.date(:,1)==thisDay & ...
            rbdat.mouse(:,1)==mouse & rbdat.type==1 &...
            rbdat.baselineMvt==0 & rbdat.c_csdur == 500,:));
        eyelidPos.earlyOnTest.sem(c-2,eyelidposCol:eyelidposCol+199) = std(rbdat.eyelidpos...
            (rbdat.date(:,1)==thisDay & ...
            rbdat.mouse(:,1)==mouse & rbdat.type==1 &...
            rbdat.baselineMvt==0 & rbdat.c_csdur==500,:))/sqrt(...
            sum(rbdat.date(:,1)==thisDay & ...
            rbdat.mouse(:,1)==mouse & rbdat.type==1 &...
            rbdat.baselineMvt==0 & rbdat.c_csdur == 500));
    end
    
    
    
    clear mouse thisDay thisMouse thisPhase
end

%% plot the two eyelid traces for laser alone trials and early laser + cs + us trials
legLabs.one='early laser + cs + us';
legLabs.two='laser alone';
[earlyOnTest, lasAlone] =plotEyelidTraces_groupDataOK135478_earlyVsLasAlone...
    (timeVector, eyelidPos.earlyOnTest.mean, eyelidPos.lasAlone.mean, [1,1,1,1;1,1,1,1], legLabs, [0 200],'early, reacq');
[earlyOnTest, lasAlone] =plotEyelidTraces_groupDataOK159606148_earlyVsLasAlone...
    (timeVector, eyelidPos.earlyOnTest.mean, eyelidPos.lasAlone.mean, [1,1,1,1;1,1,1,1], legLabs, [0 200],'early, reacq');

