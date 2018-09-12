%%% temporary file to deal with the extdat dataset in its format on OREK on
%%% 180912

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
load('180821_WTExtExpt_timeVector.mat')
load('180821_WTExtExpt_allAnimBehData.mat')

extdatDayData = getDayData(extdat, timeVector, 0.1*ones(length(unique(extdat.mouse)),1));

%% What happens to the startle to the tone over acquisition and extinction?
% in the getDayData script, I defined startle as the maximum eyelid
% position in the first 50 ms after the CS is presented, and then I stored
% the mean startle amplitude in extdatDayData.meanAStartleAmp for each day

%for this part of the analysis, I only care about the animals in the OSmice
%group. And for some reason int he extdat dataset generation I assigned
%these animals numerical values 1:4 instead of keeping their string names
%in the dataset.
midx = extdatDayData.mouse<=4;

% extdatDayData.isext is already a logical array of whether a say was an
% extinction session

edges = 0:0.005:0.1;

% make scatter plots for each animal
% these plots make it look kind of like the startle amplitude just
% decreases through training, except OK005 who really dropped his startle
% amplitude
acq1 = extdatDayData.meanAStartleAmp(extdatDayData.mouse==1 & extdatDayData.isext==0);
ext1 = extdatDayData.meanAStartleAmp(extdatDayData.mouse==1 & extdatDayData.isext==1);
twoScatter(acq1, ext1, 'OK005', 'mean startle amplitude', 'startle amplitude', {'acq'; 'ext'})

acq2 = extdatDayData.meanAStartleAmp(extdatDayData.mouse==2 & extdatDayData.isext==0);
ext2 = extdatDayData.meanAStartleAmp(extdatDayData.mouse==2 & extdatDayData.isext==1);
twoScatter(acq2, ext2, 'OK006', 'mean startle amplitude', 'startle amplitude', {'acq'; 'ext'})

acq3 = extdatDayData.meanAStartleAmp(extdatDayData.mouse==3 & extdatDayData.isext==0);
ext3 = extdatDayData.meanAStartleAmp(extdatDayData.mouse==3 & extdatDayData.isext==1);
twoScatter(acq3, ext3, 'OK007', 'mean startle amplitude', 'startle amplitude', {'acq'; 'ext'})

acq4 = extdatDayData.meanAStartleAmp(extdatDayData.mouse==4 & extdatDayData.isext==0);
ext4 = extdatDayData.meanAStartleAmp(extdatDayData.mouse==4 & extdatDayData.isext==1);
twoScatter(acq4, ext4, 'OK008', 'mean startle amplitude', 'startle amplitude', {'acq'; 'ext'})

% make histograms for each animal but include the last 4 days of
% acquisition and the first 4 days of extinction
figure
histogram(acq1(end-3:end), edges)
hold on
histogram(ext1(end-3:end), edges)

figure
histogram(acq2(end-3:end), edges)
hold on
histogram(ext2(end-3:end), edges)

figure
histogram(acq3(end-3:end), edges)
hold on
histogram(ext3(end-3:end), edges)

figure
histogram(acq4(end-3:end), edges)
hold on
histogram(ext4(end-3:end), edges)

% now for the group because there isn't so much data
acqpts = [acq1(end-3:end); acq2(end-3:end); acq3(end-3:end); acq4(end-3:end)];
extpts = [ext1(end-3:end); ext2(end-3:end); ext3(end-3:end); ext4(end-3:end)];
figure
histogram(acqpts, edges)
hold on
histogram(extpts, edges)

acqptsAnimMeans = [mean(acq1(end-3:end)); mean(acq2(end-3:end));...
    mean(acq3(end-3:end)); mean(acq4(end-3:end))];
extptsAnimMeans = [mean(ext1(end-3:end)); mean(ext2(end-3:end));...
    mean(ext3(end-3:end)); mean(ext4(end-3:end))];
figure
plot([1, 2], [acqptsAnimMeans(1), extptsAnimMeans(1)], 'Marker', 'x')
hold on
plot([1, 2], [acqptsAnimMeans(2), extptsAnimMeans(2)], 'Marker', 'x')
plot([1, 2], [acqptsAnimMeans(3), extptsAnimMeans(3)], 'Marker', 'x')
plot([1, 2], [acqptsAnimMeans(4), extptsAnimMeans(4)], 'Marker', 'x')
xlim([0 3])
ylim([0 0.1])
ylabel('startle FEC')
xlabel('acq or ext')
title('last 4 days acq vs first 4 days aq')

[p, h] = ranksum(acqptsAnimMeans, extptsAnimMeans);
    % super not significant difference between the 2 distributions (p =
    % 0.2). Maybe if there were more animals there would be some effect but
    % with only 4 mice there is no effect.
    
     % kind of stopped worknig on this here
     
% try checking the difference between early and late acq
acqptsAnimMeansEarly = [mean(acq1(1:4)); mean(acq2(1:4));...
    mean(acq3(1:4)); mean(acq4(1:4))];
figure
histogram(acqptsAnimMeansEarly, edges)
hold on
histogram(extptsAnimMeans, edges)
legend('early', 'late')
[p, h] = ranksum(acqptsAnimMeans, acqptsAnimMeansEarly);
    % also super not significant (p = 0.34), probably because of low n's



% this is probably not quite the right figure because it just looks at all
% days for all animals instead of collapsing all the days within each animal
figure
h1 = histogram(extdatDayData.meanAStartleAmp(midx & extdatDayData.isext==0), edges);
hold on
h2 = histogram(extdatDayData.meanAStartleAmp(midx & extdatDayData.isext==1), edges);
ylabel('days with this mean startle amplitude')
xlabel('mean startle amplitude')
legend('acquisition/maintenance', 'extinction', 'location', 'NorthEast')

% histograms for each animal
% looks like all animals' startle amplitudes decreased during extinction
% except OK008
figure
h1 = histogram(extdatDayData.meanAStartleAmp(extdatDayData.mouse==1 & extdatDayData.isext==0), edges);
hold on
h2 = histogram(extdatDayData.meanAStartleAmp(extdatDayData.mouse==1 & extdatDayData.isext==1), edges);
ylabel('days with this mean startle amplitude')
xlabel('mean startle amplitude')
legend('acquisition/maintenance', 'extinction', 'location', 'NorthEast')
title('OS005')

figure
h1 = histogram(extdatDayData.meanAStartleAmp(extdatDayData.mouse==2 & extdatDayData.isext==0), edges);
hold on
h2 = histogram(extdatDayData.meanAStartleAmp(extdatDayData.mouse==2 & extdatDayData.isext==1), edges);
ylabel('days with this mean startle amplitude')
xlabel('mean startle amplitude')
legend('acquisition/maintenance', 'extinction', 'location', 'NorthEast')
title('OS006')

figure
h1 = histogram(extdatDayData.meanAStartleAmp(extdatDayData.mouse==3 & extdatDayData.isext==0), edges);
hold on
h2 = histogram(extdatDayData.meanAStartleAmp(extdatDayData.mouse==3 & extdatDayData.isext==1), edges);
ylabel('days with this mean startle amplitude')
xlabel('mean startle amplitude')
legend('acquisition/maintenance', 'extinction', 'location', 'NorthEast')
title('OS007')

figure
h1 = histogram(extdatDayData.meanAStartleAmp(extdatDayData.mouse==4 & extdatDayData.isext==0), edges);
hold on
h2 = histogram(extdatDayData.meanAStartleAmp(extdatDayData.mouse==4 & extdatDayData.isext==1), edges);
ylabel('days with this mean startle amplitude')
xlabel('mean startle amplitude')
legend('acquisition/maintenance', 'extinction', 'location', 'NorthEast')
title('OS008')

% make scatter plots for each animal
% these plots make it look kind of like the startle amplitude just
% decreases through training, except OK005 who really dropped his startle
% amplitude
figure
tempacq = extdatDayData.meanAStartleAmp(extdatDayData.mouse==1 & extdatDayData.isext==0);
tempext = extdatDayData.meanAStartleAmp(extdatDayData.mouse==1 & extdatDayData.isext==1);
scatter([1:length(tempacq)], tempacq)
hold on
scatter([length(tempacq)+1:length(tempacq)+length(tempext)], tempext)
ylabel('startke amplitude')
xlabel('mean startle amplitude')
legend('acquisition/maintenance', 'extinction', 'location', 'NorthEast')
title('OS005')

figure
tempacq = extdatDayData.meanAStartleAmp(extdatDayData.mouse==2 & extdatDayData.isext==0);
tempext = extdatDayData.meanAStartleAmp(extdatDayData.mouse==2 & extdatDayData.isext==1);
scatter([1:length(tempacq)], tempacq)
hold on
scatter([length(tempacq)+1:length(tempacq)+length(tempext)], tempext)
ylabel('startke amplitude')
xlabel('mean startle amplitude')
legend('acquisition/maintenance', 'extinction', 'location', 'NorthEast')
title('OS006')

figure
tempacq = extdatDayData.meanAStartleAmp(extdatDayData.mouse==3 & extdatDayData.isext==0);
tempext = extdatDayData.meanAStartleAmp(extdatDayData.mouse==3 & extdatDayData.isext==1);
scatter([1:length(tempacq)], tempacq)
hold on
scatter([length(tempacq)+1:length(tempacq)+length(tempext)], tempext)
ylabel('startke amplitude')
xlabel('mean startle amplitude')
legend('acquisition/maintenance', 'extinction', 'location', 'NorthEast')
title('OS007')

figure
tempacq = extdatDayData.meanAStartleAmp(extdatDayData.mouse==4 & extdatDayData.isext==0);
tempext = extdatDayData.meanAStartleAmp(extdatDayData.mouse==4 & extdatDayData.isext==1);
scatter([1:length(tempacq)], tempacq)
hold on
scatter([length(tempacq)+1:length(tempacq)+length(tempext)], tempext)
ylabel('startke amplitude')
xlabel('mean startle amplitude')
legend('acquisition/maintenance', 'extinction', 'location', 'NorthEast')
title('OS008')



%% What happens to performance after the animals makes a CR & doesn't get puffed versus after the animal makes no CR and doesn't get puffed?
% probably only interesting on the first day of extinction

%% What happens to CR's over the course of extinction?
% when animals make a good CR, is it the same size as their CR's during
% the maintenance phase of acquisition or does the CR get smaller
% throughout extinction?
% do animals CR probabilities decrease?
