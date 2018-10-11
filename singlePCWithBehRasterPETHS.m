function singlePCWithBehRasterPETHS(filebeg, puffDurs, laserAmps)

%% load relelevant data arrays

% electrophysiology info (recall that spikes only sorted in the -0.2 s
% before trial onset and 1 s after trial onset)
load(strcat(filebeg,'SSts.mat')); % bl means bad laser attenuation setting these trials
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

%% figure out the CSpk rate during the 200 ms before and 200 ms after starting a trial since this is what's been sorted and what comes before any stimuli are presented
% also pull CSpk and SS times during trials so can make proper SS PETHs
% centered on CSpks
[preTrial_SS, preTrial_CSpk, totalTime] = getPreTrialSpikes(trialTs, 0.4, SS_times, CSpk_times);


%% make a SS centered on CSpk histogram
% needs to be focused on sorted parts
rasterPETH_frequency(preTrial_SS, preTrial_CSpk, 0.050,-0.05:0.001:0.05) % not sure if this function is right
xlabel('time from CSpk')
ylabel('count/(bin duration*number of trials)')
hold on
plot([0 0], [0 150])
ylim([0 150])
title('SS centered on CSpk')
saveas(gcf, strcat(filebeg, 'SSonCSpkPSTH.fig'))
close all


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

for i = 1:length(puffDurs)
    for m = 1:length(laserAmps)
        USOnly.times = puffOn(puffDur==puffDurs(i) & isnan(laserDur));
        laserOnly.times = laserOn(laserDur>0 & puffDur==0 & laserAmp == laserAmps(m));
        USAndLaser.UTimes = puffOn(puffDur==puffDurs(i) & laserDur>0 & laserAmp == laserAmps(m));
        USAndLaser.LTimes = laserOn(puffDur==puffDurs(i) & laserDur>0 & laserAmp == laserAmps(m));
        behwithlaserOnly = filesThisSess & trials.c_csdur>0 & trials.c_csnum == 8 ...
            & trials.laser.amp==laserAmps(m) & trials.c_usdur == 0;
        behwithpuffOnly = filesThisSess & trials.c_usdur==puffDurs(i) & trials.c_csdur==0;
        behwithlaserandpuff = filesThisSess & trials.c_usdur==puffDurs(i) &...
            trials.c_csdur>0 & trials.c_csnum==8 & trials.laser.amp==laserAmps(m);
        
        if length(USAndLaser.UTimes)>0 % in case a laser intensity has no puffs or a puff intensity has no laser presentations
            % CSpk on puff + laser trials
            rasterPETHBeh_choseY(CSpk_times, USAndLaser.UTimes+0.01, 0.3, -0.3:0.01:0.3, ...
                trials.tm(1,:)-0.04,... % remember to subtract some time to align puff at 0
                mean(trials.eyelidpos(behwithlaserandpuff,:)),...
                'counts/trials', -0.2, -0.04, 0.2, 1)
            subplot(3, 1, 1)
            titlestring = strcat('CSpk to puff:', num2str(puffDurs(i)), ...
                'ms with laser:', num2str(laserAmps(m)), 'mW');
            title(titlestring)
            saveas(gcf, strcat(filebeg, 'CSpkTo', num2str(puffDurs(i)), 'msPuffAnd',...
                num2str(laserAmps(m)), 'mWLaser.fig'))
            close gcf
            
            % SS on puff + laser trials
            rasterPETHBeh_choseY(SS_times, USAndLaser.UTimes+0.01, 0.3, -0.3:0.01:0.3, ...
                trials.tm(1,:)-0.04,...
                mean(trials.eyelidpos(behwithlaserandpuff,:)),...
                'frequency', -0.2, -0.04, 0.2, 1)
            subplot(3, 1, 1)
            titlestring = strcat('SS to puff:', num2str(puffDurs(i)), ...
                'ms with laser:', num2str(laserAmps(m)), 'mW');
            title(titlestring)
            saveas(gcf, strcat(filebeg, 'SSTo', num2str(puffDurs(i)), 'msPuffAnd',...
                num2str(laserAmps(m)), 'mWLaser.fig'))
            close gcf
        end
        
        if i == 1 % only need to plot the laser alone trials during the first iteration of the outer loop
            % CSpk on laser alone trials
            rasterPETHBeh_choseY(CSpk_times, laserOnly.times+0.01, 0.3, -0.3:0.01:0.3, ...
                trials.tm(1,:),...
                mean(trials.eyelidpos(behwithlaserOnly,:)),...
                'counts/trials', -0.2, 0, 0.2, 0)
            subplot(3, 1, 1)
            titlestring = strcat('CSpk to laser:', num2str(laserAmps(m)), 'mW');
            title(titlestring)
            saveas(gcf, strcat(filebeg, 'CSpkTo', num2str(laserAmps(m)), 'mWLaser.fig'))
            close gcf
            
            % SS on laser alone trials
            rasterPETHBeh_choseY(SS_times, laserOnly.times+0.01, 0.3, -0.3:0.01:0.3, ...
                trials.tm(1,:),...
                mean(trials.eyelidpos(behwithlaserOnly,:)),...
                'frequency', -0.2, 0, 0.2, 0)
            subplot(3, 1, 1)
            titlestring = strcat('SS to laser:', num2str(laserAmps(m)), 'mW');
            title(titlestring)
            saveas(gcf, strcat(filebeg, 'SSTo', num2str(laserAmps(m)), 'mWLaser.fig'))
            close gcf
        end
        
        if m == 1 % only need to do the puff only for the first laser duration
            % CSpk on puff alone trials
            rasterPETHBeh_choseY(CSpk_times, USOnly.times+0.01, 0.3, -0.3:0.01:0.3, ...
                trials.tm(1,:),...
                mean(trials.eyelidpos(behwithpuffOnly,:)),...
                'counts/trials', -0.2, NaN, NaN, 1)
            subplot(3, 1, 1)
            titlestring = strcat('CSpk to puff:', num2str(puffDurs(i)), 'ms');
            title(titlestring)
            saveas(gcf, strcat(filebeg, 'CSpkTo', num2str(puffDurs(i)), 'msPuff.fig'))
            close gcf
            
            % SS on puff alone trials
            rasterPETHBeh_choseY(SS_times, USOnly.times+0.01, 0.3, -0.3:0.01:0.3, ...
                trials.tm(1,:),...
                mean(trials.eyelidpos(behwithpuffOnly,:)),...
                'frequency', -0.2, NaN, NaN, 1)
            subplot(3, 1, 1)
            titlestring = strcat('SS to puff:', num2str(puffDurs(i)), 'ms');
            title(titlestring)
            saveas(gcf, strcat(filebeg, 'SSTo', num2str(puffDurs(i)), 'msPuff.fig'))
            close gcf
        end
        
    end
end

