% I added some 2 s pauses because MATLAB kept crashing, I think from trying
% to deal with the figures

% binval and rasterTime cells organized so that row corresponds to the
% different values in puffDurs and columns correspond to different values
% in laserAmps

function [ssbinvals, cspkbinvals, ssRasterTimes, cspkRasterTimes, preTrialFR]...
    =singlePCWithBehRasterPETHS(filebeg, puffDurs, ...
    laserAmps, binedges, makeFig)

%% load relelevant data arrays

% electrophysiology info (recall that spikes only sorted in the -0.2 s
% before trial onset and 1 s after trial onset)
load(strcat(filebeg,'SSts.mat')); 
load(strcat(filebeg,'CSpkts.mat'));

% behavior info from TDT file
load(strcat(filebeg,'trialInfo.mat'));
behData = cell2mat(writeme(2:end,:));
trialTs = behData(:,1);
laserDur = behData(:,2);
laserAmp = behData(:,3);
laserOn = behData(:,4);
puffOn = behData(:,5);
puffDur = behData(:,6);

% clean up workspace
clear writeme

% behavior info from matlab file
load('trialdata.mat')

% get list of bad trials, if exists
tempVector = [1:length(trialTs)];
goodTrials = [];
files = dir('*badTrials*');
if ~isempty(files)
    tempstr = strcat(filebeg, 'badTrials.mat');
    load(tempstr)
    badTrials = sort(badTrials);
    
    for t = 1:length(tempVector)
        if ~ismember(tempVector(t), badTrials)
            goodTrials = [goodTrials; tempVector(t)];
        end
    end
else
    badTrials = NaN;
    goodTrials = tempVector';
end


%% figure out the CSpk rate during the 200 ms before and 200 ms after starting a trial since this is what's been sorted and what comes before any stimuli are presented
% also pull CSpk and SS times during trials so can make proper SS PETHs
% centered on CSpks
[sortedSSTimes, preTrial_SS, totalTimeSS, preTrialFR.SS] = ...
    getPreTrialSpikes(SS_times, trialTs(goodTrials), 0.2);
[sortedCSpkTimes, preTrial_CSpk, totalTimeCSpk, preTrialFR.CSpk] = ...
    getPreTrialSpikes(CSpk_times, trialTs(goodTrials), 0.2);

%% figure out whether a cell has a CSpk response to the puff versus random stuff
[hasCSpkResponse.puff, realValOutlyingness] = checkForResponse_probability(spikeTimes, trialTimes,...
    eventTimes, preTrialWin, winOfInterest, makeFig);

%% make a SS centered on CSpk histogram
% needs to be focused on sorted parts
if makeFig
    colordef white
    rasterPETH_frequency(preTrial_SS, preTrial_CSpk, 0.050,-0.05:0.001:0.05) % not sure if this function is right
    xlabel('time from CSpk')
    ylabel('count/(bin duration*number of trials)')
    hold on
    plot([0 0], [0 150])
    ylim([0 150])
    title('SS centered on CSpk')
    figurename = strcat(filebeg, 'SSonCSpkPSTH.fig');
    if ~exist(figurename, 'file')
        savefig(gcf, figurename, 'compact')
    end
    pause(2)
    close gcf
end


%% calibrate MATLAB eyelid trace based on the minimum eyelid position during the 200 ms baseline on
% & the maximum eyelid position after a puff. exclude laser trials because
% of the light artifact during unplugged laser trials
[minvals] = min(trials.eyelidpos(:, 1:39));
[minmin] = min(minvals);

[maxvals] = max(trials.eyelidpos(trials.c_usdur>0 & trials.c_csdur == 0, 52:58)); % recall that csdur is laser dur in shogo's rig
[maxmax] = max(maxvals);

if minmin<0
    trials.eyelidpos = (trials.eyelidpos - minmin)/(maxmax - minmin);
else
    trials.eyelidpos = trials.eyelidpos/maxmax;
end


%% get indices for different conditions & plot
thisSession = filebeg(14:16);
[m,n] = size(trials.filename);
filesThisSess = [];
for i = 1:m
    if isempty(cell2mat(strfind(trials.filename(i,1),thisSession)))
        filesThisSess(i,1)=0;
    else
        filesThisSess(i,1)=1;
    end
end

% get arrays to match up
relevantPuffTimes = puffOn(goodTrials);
relevantLaserTimes = laserOn(goodTrials);
relevantPuffDurs = puffDur(goodTrials);
relevantLaserDurs = laserDur(goodTrials);
relevantLaserAmps = laserAmp(goodTrials);

% set rig-specific parameters
tubingDelay = 0.01;

% pulll subsets of trials and make plots
for i = 1:length(puffDurs)
    USOnly.times = relevantPuffTimes(relevantPuffDurs==puffDurs(i) &...
        isnan(relevantLaserDurs));
    behwithpuffOnly = filesThisSess & trials.c_usdur==puffDurs(i) & ...
         trials.c_csdur==0;
    % SS and CSpk on puff alone trials
    [ssbinvals.puffOnly{i,1}, cspkbinvals.puffOnly{i,1}, ssRasterTimes.puffOnly{i,1},...
        cspkRasterTimes.puffOnly{i,1}, check] = ...
        rasterPETHBeh_SSAndCSpk_choseY(SS_times, CSpk_times,...
        USOnly.times+tubingDelay, 0.3, binedges,...
        trials.tm(1,:), mean(trials.eyelidpos(behwithpuffOnly,:)),...
        'frequency', 'probability', -0.2, ...
        NaN, NaN, 1, makeFig);
    if makeFig
        set(gcf, 'Position', [100 400 400 500])
        subplot(3, 1, 1)
        titlestring = strcat('SS & CSpk to puff:', num2str(puffDurs(i)), 'ms');
        title(titlestring)
        figurename = strcat(filebeg, 'SSCSpkTo', num2str(puffDurs(i)), 'msPuff.fig');
        if ~exist(figurename, 'file')
            savefig(gcf, figurename, 'compact')
        end
        pause(2)
        close gcf
    end
    
    for m = 1:length(laserAmps)
        laserOnly.times = relevantLaserTimes(relevantLaserDurs>0 & ...
            relevantPuffDurs==0 & relevantLaserAmps == laserAmps(m));
        USAndLaser.UTimes = relevantPuffTimes(relevantPuffDurs==puffDurs(i) & ...
            relevantLaserDurs>0 & relevantLaserAmps == laserAmps(m));
        USAndLaser.LTimes = relevantLaserTimes(relevantPuffDurs==puffDurs(i) & ...
            relevantLaserDurs>0 & relevantLaserAmps == laserAmps(m));
        behwithlaserOnly = filesThisSess & trials.c_csdur>0 & trials.c_csnum == 8 ...
            & trials.laser.amp==laserAmps(m) & trials.c_usdur == 0;
        behwithlaserandpuff = filesThisSess & trials.c_usdur==puffDurs(i) &...
            trials.c_csdur>0 & trials.c_csnum==8 & trials.laser.amp==laserAmps(m);
        
        if ~isempty(USAndLaser.UTimes) % in case a laser intensity has no puffs or a puff intensity has no laser presentations
            isi = USAndLaser.UTimes(1) - USAndLaser.LTimes(1);
            
            % SS and CSpk on puff + laser trials
            [ssbinvals.laserpuff{i,m}, cspkbinvals.laserpuff{i,m}, ssRasterTimes.laserpuff{i,m},...
                cspkRasterTimes.laserpuff{i,m}, check] = ...
                rasterPETHBeh_SSAndCSpk_choseY(SS_times, CSpk_times,...
                USAndLaser.UTimes+tubingDelay, 0.3, binedges,...
                trials.tm(1,:)-(isi + tubingDelay),... % remember to subtract some time to align puff at 0
                mean(trials.eyelidpos(behwithlaserandpuff,:)),...
                'frequency', 'probability', -0.2, ...
                -1*(isi + tubingDelay), 0.2, 1, makeFig);
            if makeFig
                set(gcf, 'Position', [100 400 400 500])
                subplot(3, 1, 1)
                titlestring = strcat('SS & CSpk to puff:', num2str(puffDurs(i)), ...
                    'ms with laser:', num2str(laserAmps(m)), 'mW');
                title(titlestring)
                figurename = strcat(filebeg, 'SSCSpkTo', num2str(puffDurs(i)), 'msPuffAnd',...
                    num2str(laserAmps(m)), 'mWLaser.fig');
                if ~exist(figurename, 'file')
                    savefig(gcf, figurename, 'compact')
                end
                pause(2)
                close gcf
            end
            
        end
        
        if i == 1 && ~isempty(laserOnly.times) % only need to plot the laser alone trials during the first iteration of the outer loop
            
            % SS and CSpk on laser alone trials
            [ssbinvals.laserOnly{1,m}, cspkbinvals.laserOnly{1,m}, ssRasterTimes.laserOnly{1,m},...
                cspkRasterTimes.laserOnly{1,m}, check] = ...
                rasterPETHBeh_SSAndCSpk_choseY(SS_times, CSpk_times,...
                laserOnly.times, 0.3, binedges,...
                trials.tm(1,:), mean(trials.eyelidpos(behwithlaserOnly,:)),...
                'frequency', 'probability', -0.2, ...
                0, 0.2, 0, makeFig);
            if makeFig
                set(gcf, 'Position', [100 400 400 500])
                subplot(3, 1, 1)
                titlestring = strcat('SS & CSpk to laser:', num2str(laserAmps(m)), 'mW');
                title(titlestring)
                figurename = strcat(filebeg, 'SSCSpkTo', num2str(laserAmps(m)), ...
                    'mWLaser.fig');
                if ~exist(figurename, 'file')
                    savefig(gcf, figurename, 'compact')
                end
                pause(2)
                close gcf
            end
            
        end
                
    end
end

