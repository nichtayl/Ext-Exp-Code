% just to make running through the figures easier

% probably need to make the ss latency calculation a bit more sophisticated
% and detect the first bin where FR is 3 standard deviations above the
% baseline firing rate before the trial began

% there is a problem preventing the rasters for the different laser
% intensities from being split into different rows in the
% getLatenciesFromRaster function I think... the data appears to be in the
% rasterTimes structures/cells

clear

% specify where the code is being run
 computer = 'ALBUS';
% computer = 'OREK';

recordings = {'OK168_181001_01c_sortedAroundTrials.mat';...
    'OK168_181002_01a_sortedAroundTrials.mat';...
    'OK168_181004_01b_sortedAroundTrials.mat';...
    'OK168_181010_01a_sortedAroundTrials.mat';...
    'OK172_181011_01d_sortedAroundTrials.mat'};

ssFR = nan(length(recordings), 1);
cspkFR = nan(length(recordings), 1);

rl = length(recordings);

sslatencies.puffOnly = cell(rl,1);
sslatencies.laserOnly = cell(rl,1);
sslatencies.laserpuff.puff = cell(rl,1);
sslatencies.laserpuff.laser = cell(rl,1);

cspklatencies.puffOnly = cell(rl,1);
cspklatencies.laserOnly = cell(rl,1);
cspklatencies.laserpuff.puff = cell(rl,1);
cspklatencies.laserpuff.laser = cell(rl,1);

animalData = []; % doing this for now because I am too tired to organize the output better

for r = 1:rl
    
    mouse = recordings{r,1}(1:5);
    day = recordings{r,1}(7:12);
    
    if strcmpi(computer, 'ALBUS')
        dirString = strcat('C:\olivia\data\ephys\', mouse, '\', day);
    elseif strcmpi(computer, 'OREK')
        dirString = strcat('C:\Users\kimol\Documents\data\extinction project\datasets\181012 zip up dataset for work at home\', mouse, '\', day);
    end
    cd(dirString)
    
    fileBeg = recordings{r,1}(1:17);
    puffFile = strcat(fileBeg, 'puffDurs.mat');
    laserFile = strcat(fileBeg, 'laserAmps.mat');
    load(puffFile)
    load(laserFile)
    
    binedges = -0.3:0.01:0.3;
    makeFig = 0;
    
    [ssbinvals, cspkbinvals, ssRasterTimes, cspkRasterTimes, output] = ...
        singlePCWithBehRasterPETHS(fileBeg, puffDurs, laserAmps, binedges, makeFig);
    
    animalData = [animalData; output];
    
end