% I added some 2 s pauses because MATLAB kept crashing, I think from trying
% to deal with the figures

% binval and rasterTime cells organized so that row corresponds to the
% different values in puffDurs and columns correspond to different values
% in laserAmps

function [ssbinvals, cspkbinvals, ssRasterTimes, cspkRasterTimes, output]...
    =singlePCWithBehRasterPETHS(fileBeg, puffDurs, ...
    laserAmps, binedges, makeFig)

%% load relelevant data arrays

% electrophysiology info (recall that spikes only sorted in the -0.2 s
% before trial onset and 1 s after trial onset)
load(strcat(fileBeg,'SSts.mat')); 
load(strcat(fileBeg,'CSpkts.mat'));

% behavior info from TDT file
load(strcat(fileBeg,'trialInfo.mat'));
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
    tempstr = strcat(fileBeg, 'badTrials.mat');
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

% get only relevant trial indices
relevantTrialTimes = trialTs(goodTrials);
relevantPuffTimes = puffOn(goodTrials);
relevantLaserTimes = laserOn(goodTrials);
relevantPuffDurs = puffDur(goodTrials);
relevantLaserDurs = laserDur(goodTrials);
relevantLaserAmps = laserAmp(goodTrials);

% make an output structure
output.CSpkToPuff = NaN;
output.CSpkToPuffLat = NaN;
output.CSpkToPuffProb = NaN;

output.CSpkToLas = NaN;
output.CSpkToLasPuffProb = NaN;
output.CSpkToLasPuffLat = NaN;

output.CSpkRate = NaN;


output.SSToPuff = NaN;
output.SSToPuffLat = NaN;
output.SSToPuffDev = NaN;

output.SSToLas = NaN;
output.SSToLasLat = NaN;
output.SSToLasDev = NaN;

output.SSRate = NaN;


%% figure out the CSpk rate during the 200 ms before and 200 ms after starting a trial since this is what's been sorted and what comes before any stimuli are presented
% also pull CSpk and SS times during trials so can make proper SS PETHs
% centered on CSpks
[sortedSSTimes, numSS, totalTimeSS, output.SSRate] = ...
    getPreTrialSpikes(SS_times, trialTs(goodTrials), 0.2);
[sortedCSpkTimes, numCSpk, totalTimeCSpk, output.CSpkRate] = ...
    getPreTrialSpikes(CSpk_times, trialTs(goodTrials), 0.2);


%% make a SS centered on CSpk histogram
% needs to be focused on sorted parts
if makeFig
    colordef white
    rasterPETH_frequency(sortedSSTimes, sortedCSpkTimes, 0.050,-0.05:0.001:0.05) % not sure if this function is right
    xlabel('time from CSpk')
    ylabel('count/(bin duration*number of trials)')
    hold on
    plot([0 0], [0 150])
    ylim([0 150])
    title('SS centered on CSpk')
    figurename = strcat(fileBeg, 'SSonCSpkPSTH.fig');
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
thisSession = fileBeg(14:16);
[m,n] = size(trials.filename);
filesThisSess = [];
for i = 1:m
    if isempty(cell2mat(strfind(trials.filename(i,1),thisSession)))
        filesThisSess(i,1)=0;
    else
        filesThisSess(i,1)=1;
    end
end

% set rig-specific parameters
tubingDelay = 0.01;


%% figure out whether a cell has a CSpk and/or SS response to the different stimuli
% puff only trials
if sum(relevantPuffDurs>0 & isnan(relevantLaserTimes))>0
    for i = 1:length(puffDurs)
        % get data for relevant trials
        USOnly.times = relevantPuffTimes(relevantPuffDurs==puffDurs(i) &...
            isnan(relevantLaserDurs));
        behwithpuffOnly = filesThisSess & trials.c_usdur==puffDurs(i) & ...
            trials.c_csdur==0;
        
        if min(relevantLaserTimes - relevantTrialTimes) < 0.2 || ...
                min(relevantPuffTimes - relevantTrialTimes) < 0.2
            disp('BINNING ASSUMPTION VIOLATED. THERE ARE SOMETIMES LESS THAN 200 MS BETWEEN TRIAL ONSET AND EVENT ONSET')
            pause
        end
        
        [hasCSpkToPuff(i,1), CSpkChangeToPuffDir(i,1), CSpkToPuffProb(i,1), ...
            medianCSpkLatencyToPuff(i,1), hasSSToPuff(i,1), ...
            SSChangeToPuffDir(i,1), SSToPuffRate(i,1), SSRespToPuffLat(i,1), ...
            SSRespToPuffDeviation(i,1)] = ...
            gatherSpikeResponseMetrics(CSpk_times, SS_times, relevantTrialTimes,...
            USOnly.times+tubingDelay, 0.005, -0.2, 0.05, 1);
        
        if hasSSToPuff(i,1) || hasCSpkToPuff(i,1)
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
                figurename = strcat(fileBeg, 'SSCSpkTo', num2str(puffDurs(i)), 'msPuff.fig');
                if ~exist(figurename, 'file')
                    savefig(gcf, figurename, 'compact')
                end
                pause(2)
                close gcf
            end
        end
    end
else
    disp('CELL HAS NO PUFF ALONE TRIALS...?')
    pause
end

% laser only trials
if sum(isnan(relevantPuffTimes) & relevantLaserDurs>0)>0
    for m = 1:length(laserAmps)
        % get data for relevant trials
        laserOnly.times = relevantLaserTimes(relevantLaserDurs>0 & ...
            relevantPuffDurs==0 & relevantLaserAmps == laserAmps(m));
        behwithlaserOnly = filesThisSess & trials.c_csdur>0 & trials.c_csnum == 8 ...
            & trials.laser.amp==laserAmps(m) & trials.c_usdur == 0;
        
        [hasCSpkToLaser(1,m), CSpkChangeToLaserDir(1,m), CSpkToLaserProb(1,m), ...
            medianCSpkLatencyToLaser(1,m), hasSSToLaser(1,m), ...
            SSChangeToLaserDir(1,m), SSToLaserRate(1,m), SSRespToLaserLat(1,m), ...
            SSRespToLaserDeviation(1,m)] = ...
            gatherSpikeResponseMetrics(CSpk_times, SS_times, relevantTrialTimes,...
            laserOnly.times, 0.005, -0.2, 0.05, 1);
        
        if hasSSToLaser(m,1) || hasCSpkToLaser(m,1)
            % SS and CSpk on puff alone trials
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
                figurename = strcat(fileBeg, 'SSCSpkTo', num2str(laserAmps(m)), ...
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

% puff and laser trials
if sum(relevantPuffTimes>0 & relevantLaserTimes>0)>0
    for i = 1:length(puffDurs)
        for m = 1:length(laserAmps)
            USAndLaser.UTimes = relevantPuffTimes(relevantPuffDurs==puffDurs(i) & ...
                relevantLaserDurs>0 & relevantLaserAmps == laserAmps(m));
            USAndLaser.LTimes = relevantLaserTimes(relevantPuffDurs==puffDurs(i) & ...
                relevantLaserDurs>0 & relevantLaserAmps == laserAmps(m));
            behwithlaserandpuff = filesThisSess & trials.c_usdur==puffDurs(i) &...
                trials.c_csdur>0 & trials.c_csnum==8 & trials.laser.amp==laserAmps(m);
            
            % the analysis window here has to be 0.04 because of the
            % triggering of the US at 0.04
            [hasCSpkToLaserOnPuffTrials(i,m), CSpkChangeToLaserOnPuffTrialsDir(i,m), CSpkToLaserOnPuffTrialsProb(i,m), ...
                medianCSpkLatencyToLaserOnPuffTrials(i,m), hasSSToLaserOnPuffTrials(i,m), ...
                SSChangeToLaserOnPuffTrialsDir(i,m), SSToLaserOnPuffTrialsRate(i,m), SSRespToLaserOnPuffTrialsLat(i,m), ...
                SSRespToLaserOnPuffTrialsDeviation(i,m)] = ...
                gatherSpikeResponseMetrics(CSpk_times, SS_times, relevantTrialTimes,...
                USAndLaser.LTimes, 0.005, -0.2, 0.04, 1);
            
            % this analysis might be messed up for the SS if they have a
            % response to the laser alone...
            [hasCSpkToPuffOnLaserTrials(i,m), CSpkChangeToPuffOnLaserTrialsDir(i,m), CSpkToPuffOnLaserTrialsProb(i,m), ...
                medianCSpkLatencyToPuffOnLaserTrials(i,m), hasSSToPuffOnLaserTrials(i,m), ...
                SSChangeToPuffOnLaserTrialsDir(i,m), SSToPuffOnLaserTrialsRate(i,m), SSRespToPuffOnLaserTrialsLat(i,m), ...
                SSRespToPuffOnLaserTrialsDeviation(i,m)] = ...
                gatherSpikeResponseMetrics(CSpk_times, SS_times, relevantTrialTimes,...
                USAndLaser.UTimes, 0.005, -0.2, 0.05, 1);
            
            
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
                figurename = strcat(fileBeg, 'SSCSpkTo', num2str(puffDurs(i)), 'msPuffAnd',...
                    num2str(laserAmps(m)), 'mWLaser.fig');
                if ~exist(figurename, 'file')
                    savefig(gcf, figurename, 'compact')
                end
                pause(2)
                close gcf
            end
            
        end
    end
end


% values to return
end

