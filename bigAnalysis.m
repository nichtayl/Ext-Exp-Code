%%% batch concatenate animals' performace across days
%%% assumes trialdata files have already been generated
% OK148 included as part of the control group because he had no virus expression


%%% NOTE ABOUT FRAME RATE ERRORS
%%% Sessions run before 171008 have frame rate error where cameras were
%%% collecting 1 frame/4.9 seconds or so --> 202.5 frames/s in the videos.
%%% Sessions run on/after 171008 have correct frame rate of 200 frames/sec


clear all
close all

basedir = 'L:\users\okim\behavior';
savedir = 'C:\olivia\data\concat beh dat';
cd(basedir)
%mice = dir('OK*');
mice(1,1).name='OK135';
mice(2,1).name='OK137';
mice(3,1).name='OK138';
mice(4,1).name='OK134';
mice(5,1).name='OK159';
mice(6,1).name='OK160';
mice(7,1).name='OK148';
mice(8,1).name='OK161';
mice(9,1).name='OK162';

perfData = setUpPerfData;
dayData = setUpDayData;

for m = 1:length(mice);
    
    mouse = mice(m,1).name;
    goHere = strcat(basedir, '\', mouse);
    cd(goHere)
    days = dir('1*');
    tDay = 1;
    increment = 0;
    
    for d = 1:length(days)
        thisDay = strcat(goHere,'\',days(d).name);
        cd(thisDay)
        if exist('trialdata.mat')
            load('trialdata.mat')
            
            if sum(trials.c_usdur)>0
                increment = 1;
            end
            
            if increment % training has begun, start incrementing training counter and collect data
                % make min eyelid pos 0 on eyelid position scale. I also
                % have this set up to make the ~max eyelid pos 1 on the
                % eyelid position scale. Read function comments for
                % reasoning.
                if trials.c_usdur(end-1,1)>0 % to include the first day as possibly needing to be rezeroed, want to pick a middling trial with US presentation
                    trials = reZeroEyelidpos(trials,1);
                end
                
                perfData.eyelidpos=[perfData.eyelidpos;trials.eyelidpos];
                
                
                
                
                [rows cols]=size(trials.eyelidpos);
                stableBaseline = zeros(rows,1);
                URAmp = [];
                URInt = [];
                peakval = nan(rows,1);
                peaktm = nan(rows,1);
                temp = [];
                for t=1:rows
                    baseline(t,1) = mean(trials.eyelidpos(t,1:40));
                    lidAt180(t,1) = trials.eyelidpos(t, 76);
                    cradjamp(t,1) = lidAt180(t,1)-baseline(t,1);
                    if max(trials.eyelidpos(t,1:40))<0.3
                        stableBaseline(t,1)=1;
                    end
                    URAmp(t,1)=max(trials.eyelidpos(t,80:100));
                    URInt(t,1)=trapz(trials.tm(1,80:140),trials.eyelidpos(t,80:140));
                    [peakval(t,1) temp] = max(trials.eyelidpos(t,40:80)); % find peak eyelidpos during ISI
                    peaktm(t,1) = ((temp+40)*5)-200; % convert bin of peak eyelidpos closure into latency from CS onset
                end
                perfData.cradjamp = [perfData.cradjamp;cradjamp];
                perfData.baselineMvt = [perfData.baselineMvt;stableBaseline==0];
                
                
                perfData.URAmp = [perfData.URAmp;URAmp];
                perfData.URInt = [perfData.URInt;URInt];
                dayData.URAmp = [dayData.URAmp; mean(URAmp(strcmpi(trials.type,'Conditioning')==1 & ...
                    stableBaseline==1 & trials.c_usdur>0))];
                
                perfData.peakval = [perfData.peakval; peakval];
                perfData.peaktm = [perfData.peaktm; peaktm];
                dayData.peakval = [dayData.peakval; mean(peakval(stableBaseline==1))];
                dayData.peaktm = [dayData.peaktm; mean(peaktm(stableBaseline==1))];
                
                dayData.meanCRAllTrials = [dayData.meanCRAllTrials;mean(...
                    trials.eyelidpos(strcmpi(trials.type,'Conditioning')==1 &...
                    stableBaseline==1,:))];
                perfData.hitIdx = [perfData.hitIdx;strcmpi(trials.type,'Conditioning')==1 & ...
                    stableBaseline==1 & trials.c_usdur>0 & cradjamp>0.1];
                perfData.hitIdx2 = [perfData.hitIdx2;strcmpi(trials.type,'Conditioning')==1 & ...
                    stableBaseline==1 & trials.c_usdur>0 & cradjamp>0.2];
                perfData.missIdx = [perfData.missIdx;strcmpi(trials.type,'Conditioning')==1 & ...
                    stableBaseline==1 & trials.c_usdur>0 & cradjamp<0.1];
                perfData.missIdx2 = [perfData.missIdx2;strcmpi(trials.type,'Conditioning')==1 & ...
                    stableBaseline==1 & trials.c_usdur>0 & cradjamp<0.2];
                
                
                
                if sum(strcmpi(trials.type,'Conditioning')==1 & ...
                        stableBaseline==1 & cradjamp>0.1)>1
                    dayData.meanCRHitTrials = [dayData.meanCRHitTrials;mean(...
                        trials.eyelidpos(strcmpi(trials.type,'Conditioning')==1 & ...
                        stableBaseline==1 & cradjamp>0.1,:))];
                elseif sum(strcmpi(trials.type,'Conditioning')==1 & ...
                        stableBaseline==1 & cradjamp>0.1)==1
                    dayData.meanCRHitTrials = [dayData.meanCRHitTrials;...
                        trials.eyelidpos(strcmpi(trials.type,'Conditioning')==1 & ...
                        stableBaseline==1 & cradjamp>0.1,:)];
                else
                    dayData.meanCRHitTrials = [dayData.meanCRHitTrials;...
                        nan(1,200)];
                end
                dayData.CRAdjAmpAllTrials = [dayData.CRAdjAmpAllTrials;mean(...
                    cradjamp(strcmpi(trials.type,'Conditioning')==1 &...
                    stableBaseline==1,:))];
                dayData.CRAdjAmpHitTrials = [dayData.CRAdjAmpHitTrials;mean(...
                    cradjamp(strcmpi(trials.type,'Conditioning')==1 & ...
                    stableBaseline==1 & cradjamp>0.1,:))];
                
                hitTrials = sum(strcmpi(trials.type,'Conditioning')==1 & ...
                    stableBaseline==1 & cradjamp>0.1);
                hitTrials2 = sum(strcmpi(trials.type,'Conditioning')==1 & ...
                    stableBaseline==1 & cradjamp>0.2);
                allTrials = sum(strcmpi(trials.type,'Conditioning')==1 & ...
                    stableBaseline==1);
                dayData.CRProb = [dayData.CRProb;hitTrials/allTrials];
                dayData.CRProb2 = [dayData.CRProb2;hitTrials2/allTrials];
                clear cradjamp hitTrials hitTrials2 allTrials URAmp rows cols
                
                perfData.FEC180 = [perfData.FEC180;lidAt180];
                perfData.baseline = [perfData.baseline;baseline];
                clear lidAt180 baseline
                
                if isfield(trials,'encoder_displacement')
                    perfData.encoder_displacement = [perfData.encoder_displacement;trials.encoder_displacement];
                else
                    [rows cols] = size(trials.eyelidpos);
                    perfData.encoder_displacement = [perfData.encoder_displacement;NaN(rows,cols,'like',perfData.eyelidpos)];
                end
                
                perfData.c_isi = [perfData.c_isi;trials.c_isi];
                dayData.c_isi = [dayData.c_isi;trials.c_isi(1,1)];
                
                perfData.c_csnum = [perfData.c_csnum;trials.c_csnum];
                perfData.c_csdur = [perfData.c_csdur;trials.c_csdur];
                perfData.c_usnum = [perfData.c_usnum;trials.c_usnum];
                perfData.c_usdur = [perfData.c_usdur;trials.c_usdur];
                perfData.type = [perfData.type;strcmpi(trials.type,'Conditioning')]; % for ease of use later, let 1 = conditioning trials and 0=other
                
                perfData.tDay = [perfData.tDay;tDay*ones(length(trials.c_csnum),1)];
                dayData.tDay = [dayData.tDay;tDay];
                
                date = str2double(days(d).name);
                perfData.date = [perfData.date;date*ones(length(trials.c_csnum),1)];
                dayData.date = [dayData.date;date];
                
                perfData.mouse= [perfData.mouse;m*ones(length(trials.c_csnum),1)];
                dayData.mouse = [dayData.mouse;m];
                
                perfData.laserDur = [perfData.laserDur;trials.laser.dur];
                dayData.laserDel = [dayData.laserDel;trials.laser.delay];
                dayData.laserDur = [dayData.laserDur;trials.laser.dur];
                
                tDay = tDay + 1;
            end
        end
        
        
    end
    
    timeVector = trials.tm(1,:);
end




%% load the days to plot
% the spreadsheet itself should be self-explanatory. Each row lists the
% dates for a mouse's manipulation/pre-manipulation days. When the mouse
% had less than 10 days of the manipulation, there is a NaN. The headers in
% the file note which mouse/manipulation type there is.
cd('C:\olivia\data summaries')
[num, txt, raw] = xlsread('ExperimentalAndControl.xlsx');

%% get performance metrics for whole days for each mouse/day you want to plot
% use CRProb2 for 135 and 138, CRProb for 137 and 134
[rows cols] = size(raw);
plotData.during.crprob.data = nan(9,18);
plotData.during.cradjamp.data = nan(9,18);
plotData.during.cradjampHit.data=nan(9,18);
plotData.during.uramp.data = nan(9,18);
plotData.during.missuramp.data = nan(9,18);
plotData.during.hituramp.data = nan(9,18);
plotData.during.urint.data = nan(9,18);
plotData.during.missurint.data = nan(9,18);
plotData.during.hiturint.data = nan(9,18);
plotData.during.peaktm.data = nan(9,18);
plotData.after.crprob.data = nan(4,18);
plotData.after.cradjamp.data = nan(4,18);
plotData.after.cradjampHit.data=nan(4,18);
plotData.after.uramp.data = nan(4,18);
plotData.after.missuramp.data = nan(9,18);
plotData.after.hituramp.data = nan(9,18);
plotData.after.urint.data = nan(9,18);
plotData.after.missurint.data = nan(9,18);
plotData.after.hiturint.data = nan(9,18);
plotData.after.peaktm.data = nan(9,18);
plotData.late.crprob.data = nan(4,18);
plotData.late.cradjamp.data = nan(4,18);
plotData.late.cradjampHit.data=nan(4,18);
plotData.late.uramp.data = nan(4,18);
plotData.late.missuramp.data = nan(9,18);
plotData.late.hituramp.data = nan(9,18);
plotData.late.urint.data = nan(9,18);
plotData.late.missurint.data = nan(9,18);
plotData.late.hiturint.data = nan(9,18);
plotData.late.peaktm.data = nan(9,18);
plotData.early.crprob.data = nan(9,18);
plotData.early.cradjamp.data = nan(9,18);
plotData.early.cradjampHit.data=nan(9,18);
plotData.early.uramp.data = nan(9,18);
plotData.early.missuramp.data = nan(9,18);
plotData.early.hituramp.data = nan(9,18);
plotData.early.urint.data = nan(9,18);
plotData.early.missurint.data = nan(9,18);
plotData.early.hiturint.data = nan(9,18);
plotData.early.peaktm.data = nan(9,18);
eyelidPos.during.mean = nan(18,1800);
eyelidPos.during.sem = nan(18,1800);
eyelidPos.after.mean = nan(18,800);
eyelidPos.after.sem = nan(18,800);
eyelidPos.late.sem = nan(18,800);
eyelidPos.late.mean = nan(18,800);
eyelidPos.early.mean = nan(18,1800);
eyelidPos.early.sem = nan(18,1800);
eyelidpos.during.hitmean = nan(18,1800);
eyelidpos.during.missmean = nan(18,1800);
for r = 2:rows % start at row 2 because row 1 is just headers
    for c = 3:cols % start at col 3 because rows 1-2 is just headers
        thisDay = raw{r,c};
        thisMouse = raw{r,1};
        thisPhase = raw{r,2};
        mouse = 0;
        eyelidposCol = 1;
        %try
        % this if statement is here since I want to have different CR
        % criterion for OK138 since he had a big startle/SLR
        if ~ischar(thisDay) && ~isnan(thisDay) % skip days without numbers
            if strcmpi(thisMouse,'OK135')
                mouse=1;
                eyelidposcol = 1;
                crprob = dayData.CRProb2(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
                missuramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx2,1));
                hituramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx2,1));
                missurint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx2,1));
                hiturint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx2,1));
                eyelidpos.during.hitmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.hitIdx2,:));
                eyelidpos.during.missmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.missIdx2,:));
            elseif strcmpi(thisMouse,'OK137')
                mouse=2;
                eyelidposCol = 201;
                crprob = dayData.CRProb(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
                missuramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx,1));
                hituramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx,1));
                missurint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx,1));
                hiturint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx,1));
                eyelidpos.during.hitmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.hitIdx,:));
                eyelidpos.during.missmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.missIdx,:));
            elseif strcmpi(thisMouse,'OK138')
                mouse=3;
                eyelidposCol = 401;
                crprob = dayData.CRProb2(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
                missuramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx2,1));
                hituramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx2,1));
                missurint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx2,1));
                hiturint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx2,1));
                eyelidpos.during.hitmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.hitIdx2,:));
                eyelidpos.during.missmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.missIdx2,:));
            elseif strcmpi(thisMouse,'OK134')
                mouse=4;
                eyelidposCol = 601;
                crprob = dayData.CRProb(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
                missuramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx,1));
                hituramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx,1));
                missurint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx,1));
                hiturint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx,1));
                eyelidpos.during.hitmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.hitIdx,:));
                eyelidpos.during.missmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.missIdx,:));
            elseif strcmpi(thisMouse,'OK159')
                mouse=5;
                eyelidposCol = 801;
                crprob = dayData.CRProb(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
                missuramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx,1));
                hituramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx,1));
                missurint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx,1));
                hiturint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx,1));
                eyelidpos.during.hitmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.hitIdx,:));
                eyelidpos.during.missmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.missIdx,:));
            elseif strcmpi(thisMouse,'OK160')
                mouse=6;
                eyelidposCol = 1001;
                crprob = dayData.CRProb(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
                missuramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx,1));
                hituramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx,1));
                missurint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx,1));
                hiturint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx,1));
                eyelidpos.during.hitmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.hitIdx,:));
                eyelidpos.during.missmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.missIdx,:));
            elseif strcmpi(thisMouse,'OK148')
                mouse=7;
                eyelidposCol = 1201;
                crprob = dayData.CRProb(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
                missuramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx,1));
                hituramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx,1));
                missurint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx,1));
                hiturint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx,1));
                eyelidpos.during.hitmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.hitIdx,:));
                eyelidpos.during.missmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.missIdx,:));
            elseif strcmpi(thisMouse,'OK161')
                mouse=8;
                eyelidposCol = 1401;
                crprob = dayData.CRProb(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
                missuramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx,1));
                hituramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx,1));
                missurint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx,1));
                hiturint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx,1));
                eyelidpos.during.hitmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.hitIdx,:));
                eyelidpos.during.missmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.missIdx,:));
            elseif strcmpi(thisMouse,'OK162')
                mouse=9;
                eyelidposCol = 1601;
                crprob = dayData.CRProb(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
                missuramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx,1));
                hituramp = mean(perfData.URAmp(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx,1));
                missurint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.missIdx,1));
                hiturint = mean(perfData.URInt(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx,1));
                eyelidpos.during.hitmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.hitIdx,:));
                eyelidpos.during.missmean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0 & perfData.missIdx,:));
            end
            cradjampAll = dayData.CRAdjAmpAllTrials(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
            cradjampHit = dayData.CRAdjAmpHitTrials(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
            uramp = dayData.URAmp(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
            peaktm = mean(perfData.peaktm(perfData.date(:,1)==thisDay & perfData.mouse(:,1)==mouse & perfData.hitIdx,1));
            
            if strcmpi(thisPhase,'during')
                plotData.during.crprob.data(mouse,c-2) = crprob;
                plotData.during.cradjamp.data(mouse,c-2) = cradjampAll;
                plotData.during.cradjampHit.data(mouse,c-2) = cradjampHit;
                plotData.during.uramp.data(mouse,c-2)=uramp;
                plotData.during.missuramp.data(mouse,c-2)=missuramp;
                plotData.during.hituramp.data(mouse,c-2)=hituramp;
                plotData.during.missurint.data(mouse,c-2)=missurint;
                plotData.during.hiturint.data(mouse,c-2)=hiturint;
                plotData.during.peaktm.data(mouse,c-2)=peaktm;
                
                eyelidPos.during.mean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0,:));
                eyelidPos.during.sem(c-2,eyelidposCol:eyelidposCol+199) = std(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0,:))/sqrt(...
                    sum(perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0));
            elseif strcmpi(thisPhase,'after')
                plotData.after.crprob.data(mouse,c-2) = crprob;
                plotData.after.cradjamp.data(mouse,c-2) = cradjampAll;
                plotData.after.cradjampHit.data(mouse,c-2) = cradjampHit;
                plotData.after.uramp.data(mouse,c-2)=uramp;
                plotData.after.missuramp.data(mouse,c-2)=missuramp;
                plotData.after.hituramp.data(mouse,c-2)=hituramp;
                plotData.after.missurint.data(mouse,c-2)=missurint;
                plotData.after.hiturint.data(mouse,c-2)=hiturint;
                plotData.after.peaktm.data(mouse,c-2)=peaktm;
                
                eyelidPos.after.mean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0,:));
                eyelidPos.after.sem(c-2,eyelidposCol:eyelidposCol+199) = std(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0,:))/sqrt(...
                    sum(perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0));
            elseif strcmpi(thisPhase,'late')
                plotData.late.crprob.data(mouse,c-2) = crprob;
                plotData.late.cradjamp.data(mouse,c-2) = cradjampAll;
                plotData.late.cradjampHit.data(mouse,c-2) = cradjampHit;
                plotData.late.uramp.data(mouse,c-2)=uramp;
                plotData.late.missuramp.data(mouse,c-2)=missuramp;
                plotData.late.hituramp.data(mouse,c-2)=hituramp;
                plotData.late.missurint.data(mouse,c-2)=missurint;
                plotData.late.hiturint.data(mouse,c-2)=hiturint;
                plotData.late.peaktm.data(mouse,c-2)=peaktm;
                
                eyelidPos.late.mean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0,:));
                eyelidPos.late.sem(c-2,eyelidposCol:eyelidposCol+199) = std(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0,:))/sqrt(...
                    sum(perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0));
            elseif strcmpi(thisPhase,'early')
                plotData.early.crprob.data(mouse,c-2) = crprob;
                plotData.early.cradjamp.data(mouse,c-2) = cradjampAll;
                plotData.early.cradjampHit.data(mouse,c-2) = cradjampHit;
                plotData.early.uramp.data(mouse,c-2)=uramp;
                plotData.early.missuramp.data(mouse,c-2)=missuramp;
                plotData.early.hituramp.data(mouse,c-2)=hituramp;
                plotData.early.missurint.data(mouse,c-2)=missurint;
                plotData.early.hiturint.data(mouse,c-2)=hiturint;
                plotData.early.peaktm.data(mouse,c-2)=peaktm;
                
                eyelidPos.early.mean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0,:));
                eyelidPos.late.sem(c-2,eyelidposCol:eyelidposCol+199) = std(perfData.eyelidpos...
                    (perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0,:))/sqrt(...
                    sum(perfData.date(:,1)==thisDay & ...
                    perfData.mouse(:,1)==mouse & perfData.type==1 &...
                    perfData.baselineMvt==0));
            end
        end
        
        %catch isnan(thisDay)
        %end
        
        clear crprob cradjampAll uramp mouse thisDay thisMouse thisPhase
    end
end

pause


%% make plots for CR Prob, amp, and uramp
colordef black
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.crprob, plotData.after.crprob, plotData.late.crprob, plotData.early.crprob, 'CR Probability', [0 1], [0 19], 'mean');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.cradjamp, plotData.after.cradjamp, plotData.late.cradjamp, plotData.early.cradjamp, 'CR Amplitude (adjusted)', [0 0.6], [0 19], 'mean');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.cradjampHit, plotData.after.cradjampHit, plotData.late.cradjampHit, plotData.early.cradjampHit, 'CR Amplitude (adjusted; Hit trials only)', [0 0.7], [0 19], 'mean');
plotExpVsCntPreAndManipulation(plotData.during.uramp, plotData.after.uramp, plotData.late.uramp, plotData.early.uramp, 'UR Amplitude', [0.5 1.05], [0 19], 'mean')
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.hituramp, plotData.after.hituramp, plotData.late.hituramp, plotData.early.hituramp, 'UR Amp (adjusted; Hit trials only)', [0.5 1.05], [0 19], 'mean');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.missuramp, plotData.after.missuramp, plotData.late.missuramp, plotData.early.missuramp, 'UR Amp (adjusted; Miss trials only)', [0.5 1.05], [0 19], 'mean');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.hiturint, plotData.after.hiturint, plotData.late.hiturint, plotData.early.hiturint, 'UR Amp (adjusted; Hit trials only)', [0.03 0.2], [0 19], 'mean');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.missurint, plotData.after.missurint, plotData.late.missurint, plotData.early.missurint, 'UR Amp (adjusted; Miss trials only)', [0.03 0.2], [0 19], 'mean');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.peaktm, plotData.after.peaktm, plotData.late.peaktm, plotData.early.peaktm, 'Latency to Eyelidpos Peak in ISI', [100 220], [0 19], 'mean');



[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.crprob, plotData.after.crprob, plotData.late.crprob, plotData.early.crprob, 'CR Probability', [0 1], [0 19], 'median');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.cradjamp, plotData.after.cradjamp, plotData.late.cradjamp, plotData.early.cradjamp, 'CR Amplitude (adjusted)', [0 0.6], [0 19], 'median');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.cradjampHit, plotData.after.cradjampHit, plotData.late.cradjampHit, plotData.early.cradjampHit, 'CR Amplitude (adjusted; Hit trials only)', [0 0.7], [0 19], 'median');
plotExpVsCntPreAndManipulation(plotData.during.uramp, plotData.after.uramp, plotData.late.uramp, plotData.early.uramp, 'UR Amplitude', [0.5 1.05], [0 19], 'median')
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.hituramp, plotData.after.hituramp, plotData.late.hituramp, plotData.early.hituramp, 'UR Amp (adjusted; Hit trials only)', [0.5 1.05], [0 19], 'median');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.missuramp, plotData.after.missuramp, plotData.late.missuramp, plotData.early.missuramp, 'UR Amp (adjusted; Miss trials only)', [0.5 1.05], [0 19], 'median');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.hiturint, plotData.after.hiturint, plotData.late.hiturint, plotData.early.hiturint, 'UR Amp (adjusted; Hit trials only)', [0.03 0.2], [0 19], 'median');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.missurint, plotData.after.missurint, plotData.late.missurint, plotData.early.missurint, 'UR Amp (adjusted; Miss trials only)', [0.03 0.2], [0 19], 'median');
[during, after, late, early]=plotExpVsCntPreAndManipulation(plotData.during.peaktm, plotData.after.peaktm, plotData.late.peaktm, plotData.early.peaktm, 'Latency to Eyelidpos Peak in ISI', [100 220], [0 19], 'median');



%% plot mean hit and miss eyelid traces from first 4 days of during manipulation for experimental animals
legLabs.one='first day during';
legLabs.two='second day during';
legLabs.three='third day during';
legLabs.four='fourth day during';
[baseline, first, third, final] = plotEyelidTraces_groupDataOK135478...
    (timeVector, eyelidpos.during.hitmean, ...
    [3,3,3,3;4,4,4,4;5,5,5,5;6,6,6,6], legLabs, ...
    [180 380],'hit');
[baseline, first, third, final] = plotEyelidTraces_groupDataOK135478...
    (timeVector, eyelidpos.during.missmean, ...
    [3,3,3,3;4,4,4,4;5,5,5,5;6,6,6,6], legLabs, ...
    [180 380],'miss');
[baseline, first, third, final] = plotEyelidTraces_groupDataOK159606148...
    (timeVector, eyelidpos.during.hitmean, ...
    [3,3,3,3,3;4,4,4,4,4;5,5,5,5,5;6,6,6,6,6], legLabs, ...
    [180 380],'hit');
[baseline, first, third, final] = plotEyelidTraces_groupDataOK159606148...
    (timeVector, eyelidpos.during.missmean, ...
    [3,3,3,3,3;4,4,4,4,4;5,5,5,5,5;6,6,6,6,6], legLabs, ...
    [180 380],'miss');

%% plot mean eyelid traces from first 4 days of during manipulation for experimental and control animals
legLabs.one='first day during';
legLabs.two='second day during';
legLabs.three='third day during';
legLabs.four='fourth day during';
[baseline, first, third, final] = plotEyelidTraces_groupDataOK135478_seb...
    (timeVector, eyelidPos.during.mean, ...
    [3,3,3,3;4,4,4,4;5,5,5,5;6,6,6,6], legLabs, ...
    [180 380],'baseline,during');
[baseline, first, third, final] = plotEyelidTraces_groupDataOK159606148_seb...
    (timeVector, eyelidPos.during.mean, ...
    [3,3,3,3,3;4,4,4,4,4;5,5,5,5,5;6,6,6,6,6], legLabs, ...
    [180 380],'baseline,during');
[baseline, first, third, final] = plotEyelidTraces_groupDataOK135478...
    (timeVector, eyelidPos.during.mean, ...
    [3,3,3,3;4,4,4,4;5,5,5,5;6,6,6,6], legLabs, ...
    [180 380],'baseline,during');
[baseline, first, third, final] = plotEyelidTraces_groupDataOK159606148...
    (timeVector, eyelidPos.during.mean, ...
    [3,3,3,3,3;4,4,4,4,4;5,5,5,5,5;6,6,6,6,6], legLabs, ...
    [180 380],'baseline,during');


%% plot mean eyelid traces from last day of baseline and then a number of days of the during manipulation
legLabs.one='baseline';
legLabs.two='first day during';
legLabs.three='third day during';
legLabs.four='last day during';
[baseline, first, third, final] = plotEyelidTraces_groupDataOK135478_seb...
    (timeVector, eyelidPos.during.mean, ...
    [2,2,2,2;3,3,3,3;5,5,5,5;8,11,12,12], legLabs, ...
    [180 380],'baseline,during');
[baseline, first, third, final] = plotEyelidTraces_groupDataOK159606148_seb...
    (timeVector, eyelidPos.during.mean, ...
    [2,2,2,2,2;3,3,3,3,3;5,5,5,5,5;8,11,12,12,12], legLabs, ...
    [180 380],'baseline,during');
[baseline, first, third, final] = plotEyelidTraces_groupDataOK135478...
    (timeVector, eyelidPos.during.mean, ...
    [2,2,2,2;3,3,3,3;5,5,5,5;8,11,12,12], legLabs, ...
    [180 380],'baseline,during');
[baseline, first, third, final] = plotEyelidTraces_groupDataOK159606148...
    (timeVector, eyelidPos.during.mean, ...
    [2,2,2,2,2;3,3,3,3,3;5,5,5,5,5;8,11,12,12,12], legLabs, ...
    [180 380],'baseline,during');

%% plot mean eyelid traces from last day of during manipulation and then a number of days of reacquisition
legLabs.one='last day during';
legLabs.two='first day reacq';
legLabs.three='third day reacq';
legLabs.four='last day reacq';
[baseline, first, third, final] =plotEyelidTraces_groupDataOK135478(timeVector, eyelidPos.during.mean, [8,11,12,12;13,13,13,13;15,15,15,15;18,18,18,18], legLabs, [180 380],'during,reacq');
[baseline, first, third, final] =plotEyelidTraces_groupDataOK135478_seb(timeVector, eyelidPos.during.mean, [8,11,12,12;13,13,13,13;15,15,15,15;18,18,18,18], legLabs, [180 380],'during,reacq');


%% plot mean eyelid traces from last day of reacquition and then some days of late laser manipulation
legLabs.one='last day reacq';
legLabs.two='first day late';
legLabs.three='third day late';
legLabs.four='last day late';
[baseline, first, third, final] =plotEyelidTraces_groupDataOK135478(timeVector, eyelidPos.late.mean, [2,2,2,2;3,3,3,3;5,5,5,5;12,12,12,12], legLabs, [300 500],'reacq,late');
[baseline, first, third, final] =plotEyelidTraces_groupDataOK135478_seb(timeVector, eyelidPos.late.mean, [2,2,2,2;3,3,3,3;5,5,5,5;12,12,12,12], legLabs, [300 500],'reacq,late');

%% plot mean eyelid traces from last day of reacquisition and then some days of after laser manipulation
legLabs.one='last day reacq';
legLabs.two='first day after';
legLabs.three='third day after';
legLabs.four='last day after';
[baseline, first, third, final] =plotEyelidTraces_groupDataOK135478(timeVector, eyelidPos.after.mean, [2,2,2,2;3,3,3,3;5,5,5,5;8,12,11,12], legLabs, [550 750],'reacq, after');
[baseline, first, third, final] =plotEyelidTraces_groupDataOK135478_seb(timeVector, eyelidPos.after.mean, [2,2,2,2;3,3,3,3;5,5,5,5;8,12,11,12], legLabs, [550 750],'reacq, after');

%% plot mean eyelid traces from last day of reacquisition and then some days of early laser manipulation
legLabs.one='last day reacq';
legLabs.two='first day early';
legLabs.three='third day early';
legLabs.four='last day early';
[baseline, first, third, final] =plotEyelidTraces_groupDataOK135478(timeVector, eyelidPos.early.mean, [2,2,2,2;3,3,3,3;5,5,5,5;12,10,12,12], legLabs, [0 200],'reacq, early');
[baseline, first, third, final] =plotEyelidTraces_groupDataOK159606148(timeVector, eyelidPos.early.mean, [2,2,2,2;3,3,3,3;5,5,5,5;12,10,12,12], legLabs, [0 200],'reacq, early');
[baseline, first, third, final] =plotEyelidTraces_groupDataOK135478_seb(timeVector, eyelidPos.early.mean, [2,2,2,2;3,3,3,3;5,5,5,5;12,10,12,12], legLabs, [0 200],'reacq, early');
[baseline, first, third, final] =plotEyelidTraces_groupDataOK159606148_seb(timeVector, eyelidPos.early.mean, [2,2,2,2;3,3,3,3;5,5,5,5;12,10,12,12], legLabs, [0 200],'reacq, early');


%% plot mean eyelid traces from last day of early laser and then some days of reacquisition
legLabs.one='last day early';
legLabs.two='first day reacq';
legLabs.three='third day reacq';
legLabs.four='last day reacq';
[baseline, first, third, final] =plotEyelidTraces_groupDataOK135478(timeVector, eyelidPos.early.mean, [12,10,12,12;13,13,13,13;15,15,15,15;18,18,18,18], legLabs, [0 200],'early, reacq');
%[baseline, first, third, final] =plotEyelidTraces_groupDataOK135478_seb(timeVector, eyelidPos.early.mean, [12,10,12,12;13,13,13,13;15,15,15,15;18,18,18,18], legLabs, [0 200],'early, reacq');



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
        eyelidPos.lasAlone.mean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
            (perfData.date(:,1)==thisDay & ...
            perfData.mouse(:,1)==mouse & perfData.type(:,1)==1 &...
            perfData.baselineMvt(:,1)==0 & perfData.c_csdur(:,1) == 0,:));
        eyelidPos.lasAlone.sem(c-2,eyelidposCol:eyelidposCol+199) = std(perfData.eyelidpos...
            (perfData.date(:,1)==thisDay & ...
            perfData.mouse(:,1)==mouse & perfData.type==1 &...
            perfData.baselineMvt==0 & perfData.c_csdur==0,:))/sqrt(...
            sum(perfData.date(:,1)==thisDay & ...
            perfData.mouse(:,1)==mouse & perfData.type==1 &...
            perfData.baselineMvt==0 & perfData.c_csdur==0));
        eyelidPos.earlyOnTest.mean(c-2,eyelidposCol:eyelidposCol+199) = mean(perfData.eyelidpos...
            (perfData.date(:,1)==thisDay & ...
            perfData.mouse(:,1)==mouse & perfData.type==1 &...
            perfData.baselineMvt==0 & perfData.c_csdur == 500,:));
        eyelidPos.earlyOnTest.sem(c-2,eyelidposCol:eyelidposCol+199) = std(perfData.eyelidpos...
            (perfData.date(:,1)==thisDay & ...
            perfData.mouse(:,1)==mouse & perfData.type==1 &...
            perfData.baselineMvt==0 & perfData.c_csdur==500,:))/sqrt(...
            sum(perfData.date(:,1)==thisDay & ...
            perfData.mouse(:,1)==mouse & perfData.type==1 &...
            perfData.baselineMvt==0 & perfData.c_csdur == 500));
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



%%% STOPPED MODIFYING HERE


%% plot mean eyelid traces from last day extinction manipulation and first few trials of normal retraining
figure
hold on
% idx= find(perfData.mouse==1 & perfData.tDay==30 & perfData.type==1);
% mean1 = mean(perfData.eyelidpos(idx(end-10:end),:));
% idx=find(perfData.mouse==2 & perfData.tDay==29 & perfData.type==1);
% mean2 = mean(perfData.eyelidpos(idx(end-10:end),:));
% idx=find(perfData.mouse==3 & perfData.tDay==53 & perfData.type==1);
% mean3 = mean(perfData.eyelidpos(idx(end-10:end),:));
% idx=find(perfData.mouse==4 & perfData.tDay==44 & perfData.type==1);
% mean4 = mean(perfData.eyelidpos(idx(end-10:end),:));
% %idx=[idx;find(perfData.mouse==5 & perfData.tDay==30 & perfData.type==1)];
% plot(timeVector*1000, mean([mean1;mean2;mean3;mean4]))
% holdme = mean([mean1;mean2;mean3;mean4]);
idx= find(perfData.mouse==1 & perfData.tDay==31 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx(end-10:end),:));
idx=find(perfData.mouse==2 & perfData.tDay==30 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx(end-10:end),:));
idx=find(perfData.mouse==3 & perfData.tDay==54 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx(end-10:end),:));
idx=find(perfData.mouse==4 & perfData.tDay==45 & perfData.type==1);
mean4 = mean(perfData.eyelidpos(idx(end-10:end),:));
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==30 & perfData.type==1)];
plot(timeVector*1000, mean([mean1;mean2;mean3;mean4]))
holdme = mean([mean1;mean2;mean3;mean4]);
idx= find(perfData.mouse==1 & perfData.tDay==32 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx(1:10),:));
idx=find(perfData.mouse==2 & perfData.tDay==31 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx(1:10),:));
idx=find(perfData.mouse==3 & perfData.tDay==55 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx(1:10),:));
idx=find(perfData.mouse==4 & perfData.tDay==46 & perfData.type==1);
mean4 = mean(perfData.eyelidpos(idx(1:10),:));
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==30 & perfData.type==1)];
plot(timeVector*1000, mean([mean1;mean2;mean3;mean4]))
holdme = mean([mean1;mean2;mean3;mean4]);
legend('last 10 during', 'first 10 normal', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 1], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 1.03, 'tone on')
plot([220 220], [0 1], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 1.03, 'puff on')
rectangle('Position', [180 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(250, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')

%only one mouse
figure
hold on
idx=find(perfData.mouse==4 & perfData.tDay==45 & perfData.type==1);
mean4 = mean(perfData.eyelidpos(idx(end-10:end),:));
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==30 & perfData.type==1)];
plot(timeVector*1000, mean4)
holdme = mean4;
idx=find(perfData.mouse==4 & perfData.tDay==46 & perfData.type==1);
mean4 = mean(perfData.eyelidpos(idx(1:10),:));
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==30 & perfData.type==1)];
plot(timeVector*1000, mean4)
holdme = mean4;
legend('last 10 during', 'first 10 normal', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
ylim([0 0.2])
plot([0 0], [0 1], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 1.03, 'tone on')
plot([220 220], [0 1], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 1.03, 'puff on')
rectangle('Position', [180 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(250, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')

%% plot mean eyelid traces from last day of weak US then a number of days of extinction manipulation
% things look bad when I include OK148 but I don't think I can get away
% from showing his data. try showing average of averages instead of average
% of all trials

% also store UR amplitudes
groupURAmp = [0;0;0;0];

idx = find(perfData.mouse==1 & perfData.tDay==25 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
URAmp1_135 = [];
for u = 1:length(idx)
    URAmp1_135=[URAmp1_135;max(perfData.eyelidpos(idx(u),80:100))];
end
idx=find(perfData.mouse==2 & perfData.tDay==20 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
URAmp1_137 = [];
for u = 1:length(idx)
    URAmp1_137=[URAmp1_137;max(perfData.eyelidpos(idx(u),80:100))];
end
idx=find(perfData.mouse==3 & perfData.tDay==44 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
URAmp1_138 = [];
for u = 1:length(idx)
    URAmp1_138=[URAmp1_138;max(perfData.eyelidpos(idx(u),80:100))];
end
idx=find(perfData.mouse==4 & perfData.tDay==35 & perfData.type==1);
mean4 = mean(perfData.eyelidpos(idx,:));
URAmp1_134 = [];
for u = 1:length(idx)
    URAmp1_134=[URAmp1_134;max(perfData.eyelidpos(idx(u),80:100))];
end
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==29 & perfData.type==1)];
figure
plot(timeVector*1000, mean([mean1;mean2;mean3;mean4]))
holdme = mean([mean1;mean2;mean3;mean4]);
groupURAmp(1,1) = max(holdme(1,80:100));
hold on
idx= find(perfData.mouse==1 & perfData.tDay==26 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
URAmp2_135 = [];
for u = 1:length(idx)
    URAmp2_135=[URAmp2_135;max(perfData.eyelidpos(idx(u),80:100))];
end
idx=find(perfData.mouse==2 & perfData.tDay==21 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
URAmp2_137 = [];
for u = 1:length(idx)
    URAmp2_137=[URAmp2_137;max(perfData.eyelidpos(idx(u),80:100))];
end
idx=find(perfData.mouse==3 & perfData.tDay==45 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
URAmp2_138 = [];
for u = 1:length(idx)
    URAmp2_138=[URAmp2_138;max(perfData.eyelidpos(idx(u),80:100))];
end
idx=find(perfData.mouse==4 & perfData.tDay==36 & perfData.type==1);
mean4 = mean(perfData.eyelidpos(idx,:));
URAmp2_134 = [];
for u = 1:length(idx)
    URAmp2_134=[URAmp2_134;max(perfData.eyelidpos(idx(u),80:100))];
end
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==30 & perfData.type==1)];
plot(timeVector*1000, mean([mean1;mean2;mean3;mean4]))
holdme = mean([mean1;mean2;mean3;mean4]);
groupURAmp(2,1) = max(holdme(1,80:100));
idx= find(perfData.mouse==1 & perfData.tDay==29 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
URAmp3_135 = [];
for u = 1:length(idx)
    URAmp3_135=[URAmp3_135;max(perfData.eyelidpos(idx(u),80:100))];
end
idx=find(perfData.mouse==2 & perfData.tDay==24 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
URAmp3_137 = [];
for u = 1:length(idx)
    URAmp3_137=[URAmp3_137;max(perfData.eyelidpos(idx(u),80:100))];
end
idx=find(perfData.mouse==3 & perfData.tDay==48 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
URAmp3_138 = [];
for u = 1:length(idx)
    URAmp3_138=[URAmp3_138;max(perfData.eyelidpos(idx(u),80:100))];
end
idx=find(perfData.mouse==4 & perfData.tDay==39 & perfData.type==1);
mean4 = mean(perfData.eyelidpos(idx,:));
URAmp3_134 = [];
for u = 1:length(idx)
    URAmp3_134=[URAmp3_134;max(perfData.eyelidpos(idx(u),80:100))];
end
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==33 & perfData.type==1)];
plot(timeVector*1000, mean([mean1;mean2;mean3;mean4]))
holdme = mean([mean1;mean2;mean3;mean4]);
groupURAmp(3,1) = max(holdme(1,80:100));
idx= find(perfData.mouse==1 & perfData.tDay==31 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
URAmp4_135 = [];
for u = 1:length(idx)
    URAmp4_135=[URAmp4_135;max(perfData.eyelidpos(idx(u),80:100))];
end
idx=find(perfData.mouse==2 & perfData.tDay==30 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
URAmp4_137 = [];
for u = 1:length(idx)
    URAmp4_137=[URAmp4_137;max(perfData.eyelidpos(idx(u),80:100))];
end
idx=find(perfData.mouse==3 & perfData.tDay==54 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
URAmp4_138 = [];
for u = 1:length(idx)
    URAmp4_138=[URAmp4_138;max(perfData.eyelidpos(idx(u),80:100))];
end
idx=find(perfData.mouse==4 & perfData.tDay==45 & perfData.type==1); % UPDATE AS SESSIONS PROGRESS
mean4 = mean(perfData.eyelidpos(idx,:));
URAmp4_134 = [];
for u = 1:length(idx)
    URAmp4_134=[URAmp4_134;max(perfData.eyelidpos(idx(u),80:100))];
end
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==34 & perfData.type==1)]; % UPDATE AS SESSIONS PROGRESS
plot(timeVector*1000, mean([mean1;mean2;mean3;mean4]))
holdme = mean([mean1;mean2;mean3;mean4]);
groupURAmp(4,1) = max(holdme(1,80:100));
legend('weak US', 'first', 'fourth', 'last', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
rectangle('Position', [180 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(250, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')

meanURAmp_135(1,1)=mean(URAmp1_135);
meanURAmp_135(1,2)=std(URAmp1_135)/sqrt(length(URAmp1_135));
meanURAmp_135(2,1)=mean(URAmp2_135);
meanURAmp_135(2,2)=std(URAmp2_135)/sqrt(length(URAmp2_135));
meanURAmp_135(3,1)=mean(URAmp3_135);
meanURAmp_135(3,2)=std(URAmp3_135)/sqrt(length(URAmp3_135));
meanURAmp_135(4,1)=mean(URAmp4_135);
meanURAmp_135(4,2)=std(URAmp4_135)/sqrt(length(URAmp4_135));

meanURAmp_137(1,1)=mean(URAmp1_137);
meanURAmp_137(1,2)=std(URAmp1_137)/sqrt(length(URAmp1_137));
meanURAmp_137(2,1)=mean(URAmp2_137);
meanURAmp_137(2,2)=std(URAmp2_137)/sqrt(length(URAmp2_137));
meanURAmp_137(3,1)=mean(URAmp3_137);
meanURAmp_137(3,2)=std(URAmp3_137)/sqrt(length(URAmp3_137));
meanURAmp_137(4,1)=mean(URAmp4_137);
meanURAmp_137(4,2)=std(URAmp4_137)/sqrt(length(URAmp4_137));

meanURAmp_138(1,1)=mean(URAmp1_138);
meanURAmp_138(1,2)=std(URAmp1_138)/sqrt(length(URAmp1_138));
meanURAmp_138(2,1)=mean(URAmp2_138);
meanURAmp_138(2,2)=std(URAmp2_138)/sqrt(length(URAmp2_138));
meanURAmp_138(3,1)=mean(URAmp3_138);
meanURAmp_138(3,2)=std(URAmp3_138)/sqrt(length(URAmp3_138));
meanURAmp_138(4,1)=mean(URAmp4_138);
meanURAmp_138(4,2)=std(URAmp4_138)/sqrt(length(URAmp4_138));

meanURAmp_134(1,1)=mean(URAmp1_134);
meanURAmp_134(1,2)=std(URAmp1_134)/sqrt(length(URAmp1_134));
meanURAmp_134(2,1)=mean(URAmp2_134);
meanURAmp_134(2,2)=std(URAmp2_134)/sqrt(length(URAmp2_134));
meanURAmp_134(3,1)=mean(URAmp3_134);
meanURAmp_134(3,2)=std(URAmp3_134)/sqrt(length(URAmp3_134));
meanURAmp_134(4,1)=mean(URAmp4_134);
meanURAmp_134(4,2)=std(URAmp4_134)/sqrt(length(URAmp4_134));


day1_scatter = [meanURAmp_135(1,1);meanURAmp_137(1,1);meanURAmp_138(1,1);meanURAmp_134(1,1);];
day2_scatter = [meanURAmp_135(2,1);meanURAmp_137(2,1);meanURAmp_138(2,1);meanURAmp_134(2,1);];
day3_scatter = [meanURAmp_135(3,1);meanURAmp_137(3,1);meanURAmp_138(3,1);meanURAmp_134(3,1);];
day4_scatter = [meanURAmp_135(4,1);meanURAmp_137(4,1);meanURAmp_138(4,1);meanURAmp_134(4,1);];
figure
scatter([1;1;1;1], day1_scatter)
hold on
plot([0.8 1.2], [mean(day1_scatter) mean(day1_scatter)])
scatter([2;2;2;2], day2_scatter)
plot([1.8 2.2], [mean(day2_scatter) mean(day2_scatter)])
scatter([3;3;3;3], day3_scatter)
plot([2.8 3.2], [mean(day3_scatter) mean(day3_scatter)])
scatter([4;4;4;4], day4_scatter)
plot([3.8 4.2], [mean(day4_scatter) mean(day4_scatter)])
ylim([0 1])
ylabel('FEC')
xlabel('session')

x = [1;1;1;1;2;2;2;2;3;3;3;3;4;4;4;4];
y = [day1_scatter;day2_scatter;day3_scatter;day4_scatter];
[r,p]=corr(x,y);

%% plot mean eyelid traces from last day of weak US then some days of trial long photostimulation
idx = find(perfData.mouse==1 & perfData.tDay==100 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));

idx=find(perfData.mouse==3 & perfData.tDay==139 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));

%idx=[idx;find(perfData.mouse==5 & perfData.tDay==29 & perfData.type==1)];
figure
plot(timeVector*1000, mean([mean1;mean3]))
holdme = mean([mean1;mean3]);
hold on
idx= find(perfData.mouse==1 & perfData.tDay==101 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));

idx=find(perfData.mouse==3 & perfData.tDay==140 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));

%idx=[idx;find(perfData.mouse==5 & perfData.tDay==30 & perfData.type==1)];
plot(timeVector*1000, mean([mean1;mean3]))
holdme = mean([mean1;mean3]);
idx= find(perfData.mouse==1 & perfData.tDay==105 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));

idx=find(perfData.mouse==3 & perfData.tDay==144 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));

%idx=[idx;find(perfData.mouse==5 & perfData.tDay==33 & perfData.type==1)];
plot(timeVector*1000, mean([mean1;mean3]))
holdme = mean([mean1;mean3]);
idx= find(perfData.mouse==1 & perfData.tDay==111 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));

idx=find(perfData.mouse==3 & perfData.tDay==149 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));

%idx=[idx;find(perfData.mouse==5 & perfData.tDay==34 & perfData.type==1)]; % UPDATE AS SESSIONS PROGRESS
plot(timeVector*1000, mean([mean1;mean3]))
holdme = mean([mean1;mean3]);
legend('weak US', 'first', 'fourth', 'last', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
rectangle('Position', [180 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(250, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')


%% plot mean eyelid traces from last day of weak US then a number of days of early photostim manipulation

% also store UR amplitudes
groupURAmp = [0;0;0;0];

idx = find(perfData.mouse==1 & perfData.tDay==78 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==2 & perfData.tDay==49 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==3 & perfData.tDay==115 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==29 & perfData.type==1)];
figure
plot(timeVector*1000, mean([mean1;mean2;mean3]))
holdme = mean([mean1;mean2;mean3]);
groupURAmp(1,1) = max(holdme(1,80:100));
hold on
idx= find(perfData.mouse==1 & perfData.tDay==79 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==2 & perfData.tDay==50 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==3 & perfData.tDay==116 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
plot(timeVector*1000, mean([mean1;mean2;mean3]))
holdme = mean([mean1;mean2;mean3]);
groupURAmp(2,1) = max(holdme(1,80:100));
idx= find(perfData.mouse==1 & perfData.tDay==80 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==2 & perfData.tDay==51 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==3 & perfData.tDay==117 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
plot(timeVector*1000, mean([mean1;mean2;mean3]))
holdme = mean([mean1;mean2;mean3]);
groupURAmp(3,1) = max(holdme(1,80:100));
idx= find(perfData.mouse==1 & perfData.tDay==89 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==2 & perfData.tDay==57 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==3 & perfData.tDay==126 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
plot(timeVector*1000, mean([mean1;mean2;mean3]))
holdme = mean([mean1;mean2;mean3]);
groupURAmp(4,1) = max(holdme(1,80:100));
legend('weak US', 'first', 'second', 'last', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
rectangle('Position', [0 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(50, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')

%% plot mean eyelid traces from last day of early photostim manipulation then a number of days of weak US

% also store UR amplitudes
groupURAmp = [0;0;0;0];

idx = find(perfData.mouse==1 & perfData.tDay==89 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==2 & perfData.tDay==57 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==3 & perfData.tDay==126 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==29 & perfData.type==1)];
figure
plot(timeVector*1000, mean([mean1;mean2;mean3]))
holdme = mean([mean1;mean2;mean3]);
groupURAmp(1,1) = max(holdme(1,80:100));
hold on
idx= find(perfData.mouse==1 & perfData.tDay==91 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==2 & perfData.tDay==58 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==3 & perfData.tDay==128 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
plot(timeVector*1000, mean([mean1;mean2;mean3]))
holdme = mean([mean1;mean2;mean3]);
groupURAmp(2,1) = max(holdme(1,80:100));
idx= find(perfData.mouse==1 & perfData.tDay==92 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==2 & perfData.tDay==59 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
%idx=find(perfData.mouse==3 & perfData.tDay==129 & perfData.type==1); MUST
%UPDATE THIS WEEK
mean3 = mean(perfData.eyelidpos(idx,:));
plot(timeVector*1000, mean([mean1;mean2]))%;mean3]))
holdme = mean([mean1;mean2]);%;mean3]);
groupURAmp(3,1) = max(holdme(1,80:100));
idx= find(perfData.mouse==1 & perfData.tDay==100 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==2 & perfData.tDay==61 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
%idx=find(perfData.mouse==3 & perfData.tDay==126 & perfData.type==1); %
%MUST UPDATE THIS WEEK
mean3 = mean(perfData.eyelidpos(idx,:));
plot(timeVector*1000, mean([mean1;mean2]))%;mean3]))
holdme = mean([mean1;mean2]);%;mean3]);
groupURAmp(4,1) = max(holdme(1,80:100));
legend('early laser', 'first', 'second', 'last', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
rectangle('Position', [0 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(50, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')

%% plot mean eyelid traces from early photostim + photostim alone trials

% also store UR amplitudes

idx = find(perfData.mouse==1 & perfData.tDay==90 & perfData.type==1);
pairedTrials = [1:10,12:21,23:32,34:43,45:54,56:65,67:76,78:87,89:98,100:110];
lasAloneTrials = [11,22,33,44,55,66,77,88,99];
mean1 = mean(perfData.eyelidpos(idx(pairedTrials),:));
mean1las = mean(perfData.eyelidpos(idx(lasAloneTrials),:));
idx=find(perfData.mouse==3 & perfData.tDay==127 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx(pairedTrials),:));
mean3las = mean(perfData.eyelidpos(idx(lasAloneTrials),:));
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==29 & perfData.type==1)];
figure
plot(timeVector*1000, mean([mean1;mean3]))
holdme = mean([mean1;mean3]);
hold on
plot(timeVector*1000, mean([mean1las;mean3las]))
holdme = mean([mean1las;mean3las]);
legend('early laser+CS+US', 'laser alone', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
rectangle('Position', [0 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(50, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')

% one mouse OK138
idx=find(perfData.mouse==3 & perfData.tDay==127 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx(pairedTrials),:));
figure
plot(timeVector*1000, mean3)
hold on
plot(timeVector*1000, perfData.eyelidpos(idx(lasAloneTrials(2)),:))
plot(timeVector*1000, perfData.eyelidpos(idx(lasAloneTrials(5)),:))
plot(timeVector*1000, perfData.eyelidpos(idx(lasAloneTrials(8)),:))
legend('early laser+CS+US', 'laser alone early','laser alone middle','laser alone late', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
rectangle('Position', [0 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(50, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')


%% plot mean eyelid traces from last day of weak US then a number of days of early photostim manipulation
% OK137 only
% also store UR amplitudes
groupURAmp = [0;0;0;0];

colordef black
idx=find(perfData.mouse==2 & perfData.tDay==49 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
figure
plot(timeVector*1000, mean2)
hold on
idx=find(perfData.mouse==2 & perfData.tDay==50 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
plot(timeVector*1000, mean2)
idx=find(perfData.mouse==2 & perfData.tDay==51 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
plot(timeVector*1000, mean2)
idx=find(perfData.mouse==2 & perfData.tDay==57 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
plot(timeVector*1000, mean2)
legend('weak US', 'first', 'second', 'last', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
rectangle('Position', [0 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(50, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')

%% plot mean eyelid traces from last day of early photostim manipulation then a number of days of weak US

% also store UR amplitudes
groupURAmp = [0;0;0;0];

idx=find(perfData.mouse==2 & perfData.tDay==57 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
figure
plot(timeVector*1000, mean2)
hold on
idx=find(perfData.mouse==2 & perfData.tDay==58 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
plot(timeVector*1000, mean2)
idx=find(perfData.mouse==2 & perfData.tDay==59 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
plot(timeVector*1000, mean2)
idx=find(perfData.mouse==2 & perfData.tDay==61 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
plot(timeVector*1000, mean2)
legend('early laser', 'first', 'second', 'last', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
rectangle('Position', [0 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(50, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')


%% plot mean eyelid traces from last day of during photostim then a number of days of reacquisition
%MUST UPDATE THIS WEEK
% also store UR amplitudes
groupURAmp = [0;0;0;0];

idx = find(perfData.mouse==1 & perfData.tDay==31 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==2 & perfData.tDay==30 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==3 & perfData.tDay==54 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==4 & perfData.tDay==45 & perfData.type==1);
mean4 = mean(perfData.eyelidpos(idx,:));
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==29 & perfData.type==1)];
figure
plot(timeVector*1000, mean([mean1;mean2;mean3;mean4]))
holdme = mean([mean1;mean2;mean3;mean4]);
groupURAmp(1,1) = max(holdme(1,80:100));
hold on
idx= find(perfData.mouse==1 & perfData.tDay==32 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==2 & perfData.tDay==31 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==3 & perfData.tDay==55 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==4 & perfData.tDay==46 & perfData.type==1);
mean4 = mean(perfData.eyelidpos(idx,:));
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==30 & perfData.type==1)];
plot(timeVector*1000, mean([mean1;mean2;mean3;mean4]))
holdme = mean([mean1;mean2;mean3;mean4]);
groupURAmp(2,1) = max(holdme(1,80:100));
idx= find(perfData.mouse==1 & perfData.tDay==34 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==2 & perfData.tDay==33 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==3 & perfData.tDay==57 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==4 & perfData.tDay==48 & perfData.type==1);
mean4 = mean(perfData.eyelidpos(idx,:));
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==33 & perfData.type==1)];
plot(timeVector*1000, mean([mean1;mean2;mean3;mean4]))
holdme = mean([mean1;mean2;mean3;mean4]);
groupURAmp(3,1) = max(holdme(1,80:100));
idx= find(perfData.mouse==1 & perfData.tDay==39 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==2 & perfData.tDay==36 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==3 & perfData.tDay==62 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==4 & perfData.tDay==49 & perfData.type==1); % UPDATE AS SESSIONS PROGRESS
mean4 = mean(perfData.eyelidpos(idx,:));
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==34 & perfData.type==1)]; % UPDATE AS SESSIONS PROGRESS
plot(timeVector*1000, mean([mean1;mean2;mean3;mean4]))
holdme = mean([mean1;mean2;mean3;mean4]);
groupURAmp(4,1) = max(holdme(1,80:100));
legend('during photostim', 'first', 'third', 'last', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')


%% plot mean eyelid traces from last day of baseline then a number of days of photostimulation control
% also store UR amplitudes
groupURAmp = [0;0;0;0];

idx = find(perfData.mouse==1 & perfData.tDay==39 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==2 & perfData.tDay==36 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==3 & perfData.tDay==62 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==4 & perfData.tDay==58 & perfData.type==1);
mean4 = mean(perfData.eyelidpos(idx,:));
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==29 & perfData.type==1)];
figure
plot(timeVector*1000, mean([mean1;mean2;mean3;mean4]))
holdme = mean([mean1;mean2;mean3;mean4]);
groupURAmp(1,1) = max(holdme(1,80:100));
hold on
idx= find(perfData.mouse==1 & perfData.tDay==40 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==2 & perfData.tDay==37 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==3 & perfData.tDay==63 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==4 & perfData.tDay==59 & perfData.type==1);
mean4 = mean(perfData.eyelidpos(idx,:));
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==30 & perfData.type==1)];
plot(timeVector*1000, mean([mean1;mean2;mean3;mean4]))
holdme = mean([mean1;mean2;mean3;mean4]);
groupURAmp(2,1) = max(holdme(1,80:100));
idx= find(perfData.mouse==1 & perfData.tDay==42 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==2 & perfData.tDay==39 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==3 & perfData.tDay==65 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==4 & perfData.tDay==61 & perfData.type==1);
mean4 = mean(perfData.eyelidpos(idx,:));
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==33 & perfData.type==1)];
plot(timeVector*1000, mean([mean1;mean2;mean3;mean4]))
holdme = mean([mean1;mean2;mean3;mean4]);
groupURAmp(3,1) = max(holdme(1,80:100));
idx= find(perfData.mouse==1 & perfData.tDay==45 & perfData.type==1);
mean1 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==2 & perfData.tDay==46 & perfData.type==1);
mean2 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==3 & perfData.tDay==70 & perfData.type==1);
mean3 = mean(perfData.eyelidpos(idx,:));
idx=find(perfData.mouse==4 & perfData.tDay==68 & perfData.type==1);
mean4 = mean(perfData.eyelidpos(idx,:));
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==34 & perfData.type==1)]; % UPDATE AS SESSIONS PROGRESS
plot(timeVector*1000, mean([mean1;mean2;mean3;mean4]))
holdme = mean([mean1;mean2;mean3;mean4]);
groupURAmp(4,1) = max(holdme(1,80:100));
legend('baseline', 'first', 'third', 'last', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')

%% plot mean eyelid traces from last day of weak US then a number of days of extinction manipulation
% no CR trials
% things look bad when I include OK148 but I don't think I can get away
% from showing his data
%idx = find(perfData.mouse==1 & perfData.tDay==25 & perfData.type==1 & perfData.cradjamp<0.1);
idx=[idx;find(perfData.mouse==2 & perfData.tDay==20 & perfData.type==1& perfData.cradjamp<0.1)];
idx=[idx;find(perfData.mouse==3 & perfData.tDay==44 & perfData.type==1& perfData.cradjamp<0.1)];
idx=[idx;find(perfData.mouse==4 & perfData.tDay==35 & perfData.type==1& perfData.cradjamp<0.1)];
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==29 & perfData.type==1)];
figure
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
hold on
%idx= find(perfData.mouse==1 & perfData.tDay==26 & perfData.type==1& perfData.cradjamp<0.1);
idx=[idx;find(perfData.mouse==2 & perfData.tDay==21 & perfData.type==1& perfData.cradjamp<0.1)];
idx=[idx;find(perfData.mouse==3 & perfData.tDay==45 & perfData.type==1& perfData.cradjamp<0.1)];
idx=[idx;find(perfData.mouse==4 & perfData.tDay==36 & perfData.type==1& perfData.cradjamp<0.1)];
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==30 & perfData.type==1)];
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
%idx= find(perfData.mouse==1 & perfData.tDay==29 & perfData.type==1& perfData.cradjamp<0.1);
idx=[idx;find(perfData.mouse==2 & perfData.tDay==24 & perfData.type==1& perfData.cradjamp<0.1)];
idx=[idx;find(perfData.mouse==3 & perfData.tDay==48 & perfData.type==1& perfData.cradjamp<0.1)];
idx=[idx;find(perfData.mouse==4 & perfData.tDay==39 & perfData.type==1& perfData.cradjamp<0.1)];
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==33 & perfData.type==1)];
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
%idx= find(perfData.mouse==1 & perfData.tDay==31 & perfData.type==1& perfData.cradjamp<0.1);
idx=[idx;find(perfData.mouse==2 & perfData.tDay==30 & perfData.type==1& perfData.cradjamp<0.1)];
idx=[idx;find(perfData.mouse==3 & perfData.tDay==54 & perfData.type==1& perfData.cradjamp<0.1)];
idx=[idx;find(perfData.mouse==4 & perfData.tDay==44 & perfData.type==1& perfData.cradjamp<0.1)]; % UPDATE AS SESSIONS PROGRESS
%idx=[idx;find(perfData.mouse==5 & perfData.tDay==34 & perfData.type==1)]; % UPDATE AS SESSIONS PROGRESS
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
legend('weak US', 'first', 'fourth', 'last', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
rectangle('Position', [180 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(250, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')

%% plot mean eyelid traces from last day of weak US then a number of days of photostim control
idx = find(perfData.mouse==1 & perfData.tDay==39 & perfData.type==1);
idx=[idx;find(perfData.mouse==2 & perfData.tDay==36 & perfData.type==1)];
idx=[idx;find(perfData.mouse==3 & perfData.tDay==62 & perfData.type==1)];
figure
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
hold on
idx= find(perfData.mouse==1 & perfData.tDay==40 & perfData.type==1);
idx=[idx;find(perfData.mouse==2 & perfData.tDay==37 & perfData.type==1)];
idx=[idx;find(perfData.mouse==3 & perfData.tDay==63 & perfData.type==1)];
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==1 & perfData.tDay==41 & perfData.type==1);
idx=[idx;find(perfData.mouse==2 & perfData.tDay==38 & perfData.type==1)];
idx=[idx;find(perfData.mouse==3 & perfData.tDay==64 & perfData.type==1)];
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==1 & perfData.tDay==45 & perfData.type==1);
idx=[idx;find(perfData.mouse==2 & perfData.tDay==46 & perfData.type==1)];
idx=[idx;find(perfData.mouse==3 & perfData.tDay==70 & perfData.type==1)];
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
legend('weak US', 'first', 'second', 'last', 'Location', 'NorthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
rectangle('Position', [550 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(550, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')

%% repeat two plots above for OK135
idx = find(perfData.mouse==1 & perfData.tDay==25 & perfData.type==1);
figure
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
hold on
idx= find(perfData.mouse==1 & perfData.tDay==26 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==1 & perfData.tDay==29 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==1 & perfData.tDay==31 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
legend('weak US', 'first', 'fourth', 'last', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
rectangle('Position', [180 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(250, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')
title('OK135 laser during puff')

idx = find(perfData.mouse==1 & perfData.tDay==39 & perfData.type==1);
figure
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
hold on
idx= find(perfData.mouse==1 & perfData.tDay==40 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==1 & perfData.tDay==41 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==1 & perfData.tDay==45 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
legend('weak US', 'first', 'second', 'last', 'Location', 'NorthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
rectangle('Position', [550 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(550, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')
title('OK135 laser after puff')


%% repeat two plots above for OK138
idx = find(perfData.mouse==3 & perfData.tDay==44 & perfData.type==1);
figure
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
hold on
idx= find(perfData.mouse==3 & perfData.tDay==45 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==3 & perfData.tDay==48 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==3 & perfData.tDay==54 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
legend('weak US', 'first', 'fourth', 'last', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
rectangle('Position', [180 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(250, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')
title('OK138 laser during puff')

idx = find(perfData.mouse==3 & perfData.tDay==62 & perfData.type==1);
figure
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
hold on
idx= find(perfData.mouse==3 & perfData.tDay==63 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==3 & perfData.tDay==64 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==3 & perfData.tDay==70 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
legend('weak US', 'first', 'second', 'last', 'Location', 'NorthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
rectangle('Position', [550 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(550, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')
title('OK138 laser after puff')

%% repeat two plots above for OK134
idx = find(perfData.mouse==4 & perfData.tDay==35 & perfData.type==1);
figure
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
hold on
idx= find(perfData.mouse==4 & perfData.tDay==36 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==4 & perfData.tDay==39 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==4 & perfData.tDay==45 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
legend('weak US', 'first', 'fourth', 'last', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
rectangle('Position', [180 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(250, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')
title('OK134 laser during puff')

%% repeat two plots above for OK137
idx = find(perfData.mouse==2 & perfData.tDay==20 & perfData.type==1);
figure
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
hold on
idx= find(perfData.mouse==2 & perfData.tDay==21 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==2 & perfData.tDay==24 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==2 & perfData.tDay==30 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
legend('weak US', 'first', 'fourth', 'last', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 1], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 01.03, 'tone on')
plot([220 220], [0 1], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 01.03, 'puff on')
rectangle('Position', [180 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(250, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')
title('OK137 laser during puff')

idx = find(perfData.mouse==2 & perfData.tDay==36 & perfData.type==1);
figure
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
hold on
idx= find(perfData.mouse==2 & perfData.tDay==37 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==2 & perfData.tDay==39 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==2 & perfData.tDay==46 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
legend('weak US', 'first', 'third', 'last', 'Location', 'NorthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
rectangle('Position', [550 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(550, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')
title('Ok137 laser after trial')
holdme = mean(perfData.eyelidpos(idx,:));

idx = find(perfData.mouse==2 & perfData.tDay==30 & perfData.type==1);
figure
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
hold on
idx= find(perfData.mouse==2 & perfData.tDay==31 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==2 & perfData.tDay==33 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
idx= find(perfData.mouse==2 & perfData.tDay==36 & perfData.type==1);
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
legend('during laser', 'first', 'third', 'last', 'Location', 'NorthEast')
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
xlim([-100 600])
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-25, 0.93, 'tone on')
plot([220 220], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(195, 0.93, 'puff on')
rectangle('Position', [550 0.02 200 0.02], ...
    'FaceColor', [0 1 1], 'EdgeColor', [1 1 1])
text(550, 0.07, 'laser')
ylabel('Fraction Eyelid Closure (FEC)')
xlabel('Time (ms)')
title('Ok137 re-acquisition')


holdme= mean(perfData.eyelidpos(idx,:));



%% compare OK138's response to laser alone vs response to laser with CS
idx = find(perfData.mouse==3 & perfData.c_csdur==0 & perfData.laserDur==400 & perfData.c_usdur==0);
figure
plot(timeVector*1000, mean(perfData.eyelidpos(idx,:)))
ylim([0 0.9])
hold on
idx = find(perfData.mouse==3 & perfData.tDay==21 & perfData.laserDur==200);
plot((timeVector*1000)-180, mean(perfData.eyelidpos(idx,:)))%-mean(perfData.eyelidpos(idx,76)))
idx = find(perfData.mouse==3 & perfData.tDay==21 & perfData.laserDur==0);
plot((timeVector*1000)-180, mean(perfData.eyelidpos(idx,:)))%-mean(perfData.eyelidpos(idx,76)))
xlim([-180 100])
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out')
plot([0 0], [0 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(-20, 0.93, 'laser on')
plot([40 40], [0.4 0.9], 'LineStyle', ':', 'Color', [1 1 1])
text(20, 0.93, 'puff on')
legend('laser', 'tone + laser + puff', 'tone + puff', 'Location', 'NorthWest')
ylabel('FEC')
xlabel('time (ms)')


%% MOTOR EFFECT OF LASER

% doesn't look like motor effect amplitude scales with CR amplitude very
% obviously
% % % start with OK135 (mouse with most pronounced motor effect)
% % idx = find(perfData.mouse==1 & perfData.type==1 & perfData.tDay>=26 & perfData.tDay<=31);
% % motorFXAmp = nan(length(idx),1);
% % % define amplitude of motor effect as difference between eyelidpos at 180
% % % ms (bin 76) and eyelidpos at 220 ms (bin 84; approx US time when account for the delay of the tubing)
% % for i = 1:length(idx)
% %     motorFXAmp(i,1)=perfData.eyelidpos(idx(i),83) - perfData.eyelidpos(idx(i),76);
% % end
% % figure
% % scatter(perfData.cradjamp(idx,1),motorFXAmp)
% % lsline
% % xlabel('laser motor FX Amp')
% % ylabel('CRAdjAmp')
% % title('OK135')
% %
% %
% % idx = find(perfData.mouse==4 & perfData.type==1 & perfData.tDay>=36 & perfData.tDay<=45);
% % motorFXAmp = nan(length(idx),1);
% % % define amplitude of motor effect as difference between eyelidpos at 180
% % % ms (bin 76) and eyelidpos at 220 ms (bin 84; approx US time when account for the delay of the tubing)
% % for i = 1:length(idx)
% %     motorFXAmp(i,1)=perfData.eyelidpos(idx(i),83) - perfData.eyelidpos(idx(i),76);
% % end
% % figure
% % scatter(perfData.cradjamp(idx,1),motorFXAmp)
% % lsline
% % xlabel('laser motor FX Amp')
% % ylabel('CRAdjAmp')
% % title('OK134')
% %
% %
% % idx = find(perfData.mouse==3 & perfData.type==1 & perfData.tDay>=45 & perfData.tDay<=54);
% % motorFXAmp = nan(length(idx),1);
% % % define amplitude of motor effect as difference between eyelidpos at 180
% % % ms (bin 76) and eyelidpos at 220 ms (bin 84; approx US time when account for the delay of the tubing)
% % for i = 1:length(idx)
% %     motorFXAmp(i,1)=perfData.eyelidpos(idx(i),83) - perfData.eyelidpos(idx(i),76);
% % end
% % figure
% % scatter(perfData.cradjamp(idx,1),motorFXAmp)
% % lsline
% % xlabel('laser motor FX Amp')
% % ylabel('CRAdjAmp')
% % title('OK137')
% %
% %
% % idx = find(perfData.mouse==2 & perfData.type==1 & perfData.tDay>=21 & perfData.tDay<=30);
% % motorFXAmp = nan(length(idx),1);
% % % define amplitude of motor effect as difference between eyelidpos at 180
% % % ms (bin 76) and eyelidpos at 220 ms (bin 84; approx US time when account for the delay of the tubing)
% % for i = 1:length(idx)
% %     motorFXAmp(i,1)=perfData.eyelidpos(idx(i),83) - perfData.eyelidpos(idx(i),76);
% % end
% % figure
% % scatter(perfData.cradjamp(idx,1),motorFXAmp)
% % lsline
% % xlabel('laser motor FX Amp')
% % ylabel('CRAdjAmp')
% % title('OK138')
% %
% %
% % idx = find(perfData.mouse==1 & perfData.type==1 & perfData.tDay>=26 & perfData.tDay<=31);
% % idx = [idx;find(perfData.mouse==4 & perfData.type==1 & perfData.tDay>=36 & perfData.tDay<=45)];
% % idx = [idx;find(perfData.mouse==3 & perfData.type==1 & perfData.tDay>=45 & perfData.tDay<=54)];
% % idx = [idx;find(perfData.mouse==2 & perfData.type==1 & perfData.tDay>=21 & perfData.tDay<=30)];
% % motorFXAmp = nan(length(idx),1);
% % % define amplitude of motor effect as difference between eyelidpos at 180
% % % ms (bin 76) and eyelidpos at 220 ms (bin 84; approx US time when account for the delay of the tubing)
% % for i = 1:length(idx)
% %     motorFXAmp(i,1)=perfData.eyelidpos(idx(i),83) - perfData.eyelidpos(idx(i),76);
% % end
% % figure
% % scatter(perfData.cradjamp(idx,1),motorFXAmp)
% % lsline
% % xlabel('laser motor FX Amp')
% % ylabel('CRAdjAmp')
% % title('all')

%
% %look at last day before laser and first day with
% idx = find(perfData.mouse==1 & perfData.type==1 & perfData.tDay==26);
% figure
% plot(mean(perfData.eyelidpos(idx,:))')
% hold on
% idx = find(perfData.mouse==1 & perfData.type==1 & perfData.tDay==25);
% plot(mean(perfData.eyelidpos(idx,:))')
% plot([76 76],[0 1])
%
% idx = find(perfData.mouse==2 & perfData.type==1 & perfData.tDay==21);
% figure
% plot(mean(perfData.eyelidpos(idx,:))')
% hold on
% idx = find(perfData.mouse==2 & perfData.type==1 & perfData.tDay==20);
% plot(mean(perfData.eyelidpos(idx,:))')
% plot([76 76],[0 1])
%
% idx = find(perfData.mouse==3 & perfData.type==1 & perfData.tDay==45);
% figure
% plot(mean(perfData.eyelidpos(idx,:))')
% hold on
% idx = find(perfData.mouse==3 & perfData.type==1 & perfData.tDay==44);
% plot(mean(perfData.eyelidpos(idx,:))')
% plot([76 76],[0 1])
%
% idx = find(perfData.mouse==4 & perfData.type==1 & perfData.tDay==36);
% figure
% plot(mean(perfData.eyelidpos(idx,:))')
% hold on
% idx = find(perfData.mouse==4 & perfData.type==1 & perfData.tDay==35);
% plot(mean(perfData.eyelidpos(idx,:))')
% plot([76 76],[0 1])
%
% % try first 10 trials
% idx = find(perfData.mouse==2 & perfData.type==1 & perfData.tDay==21);
% figure
% plot(mean(perfData.eyelidpos(idx(1:10),:))')
% hold on
% idx = find(perfData.mouse==2 & perfData.type==1 & perfData.tDay==20);
% plot(mean(perfData.eyelidpos(idx(end-10:end),:))')
% plot([76 76],[0 1])
%
% % try first 20 trials
% idx = find(perfData.mouse==1 & perfData.type==1 & perfData.tDay==31);
% figure
% plot(mean(perfData.eyelidpos(idx(end-20:end),:)-(perfData.FECbaseline(idx(end-20:end),:)*ones(1,200)))')
% hold on
% idx = find(perfData.mouse==1 & perfData.type==1 & perfData.tDay==32);
% plot(mean(perfData.eyelidpos(idx(1:20),:)-(perfData.FECbaseline(idx(1:20),:)*ones(1,200)))')
% plot([76 76],[0 1])
%
% % try first trials
% idx = find(perfData.mouse==1 & perfData.type==1 & perfData.tDay==26);
% figure
% plot(perfData.eyelidpos(idx(1),:)')
% hold on
% idx = find(perfData.mouse==1 & perfData.type==1 & perfData.tDay==25);
% plot(perfData.eyelidpos(idx(end),:)')
% plot([76 76],[0 1])
%
% idx = find(perfData.mouse==2 & perfData.type==1 & perfData.tDay==21);
% figure
% plot(perfData.eyelidpos(idx(1),:)')
% hold on
% idx = find(perfData.mouse==2 & perfData.type==1 & perfData.tDay==20);
% plot(perfData.eyelidpos(idx(end),:)')
% plot([76 76],[0 1])
%
% idx = find(perfData.mouse==3 & perfData.type==1 & perfData.tDay==45);
% figure
% plot(perfData.eyelidpos(idx(1),:)')
% hold on
% idx = find(perfData.mouse==3 & perfData.type==1 & perfData.tDay==44);
% plot(perfData.eyelidpos(idx(end),:)')
% plot([76 76],[0 1])
%
% idx = find(perfData.mouse==4 & perfData.type==1 & perfData.tDay==36);
% figure
% plot(perfData.eyelidpos(idx(1),:)')
% hold on
% idx = find(perfData.mouse==4 & perfData.type==1 & perfData.tDay==35);
% plot(perfData.eyelidpos(idx(end),:)')
% plot([76 76],[0 1])
%
% % try zooming in and averaging
% idx = find(perfData.mouse==1 & perfData.type==1 & perfData.tDay==26);
% figure
% temp = perfData.eyelidpos(idx,:)-(perfData.eyelidpos(idx,76)*ones(1,200));
% plot(temp')
% hold on
% plot(mean(temp)', 'color', [0 0 0], 'LineWidth', 3)
% xlim([76 84])
%
% figure
% idx = find(perfData.mouse==1 & perfData.type==1 & perfData.tDay==25);
% temp = perfData.eyelidpos(idx,:)-(perfData.eyelidpos(idx,76)*ones(1,200));
% plot(temp')
% hold on
% plot(mean(temp)', 'color', [0 0 0], 'LineWidth', 3)
% xlim([76 84])
%
%
%
% idx = find(perfData.mouse==2 & perfData.type==1 & perfData.tDay==21);
% figure
% temp = perfData.eyelidpos(idx,:)-(perfData.eyelidpos(idx,76)*ones(1,200));
% plot(temp')
% hold on
% plot(mean(temp)', 'color', [0 0 0], 'LineWidth', 3)
% xlim([76 84])
%
% figure
% idx = find(perfData.mouse==2 & perfData.type==1 & perfData.tDay==20);
% temp = perfData.eyelidpos(idx,:)-(perfData.eyelidpos(idx,76)*ones(1,200));
% plot(temp')
% hold on
% plot(mean(temp)', 'color', [0 0 0], 'LineWidth', 3)
% xlim([76 84])

% ONLY OK135's FIRST PLOT IS PROPERLY FORMATTED/COMPLETE (SORRY FUTURE
% PERSON)
% try velocity for last day without and first day with 135
timeVectorBinWidth = timeVector(2)-timeVector(1);
timeVectorVel = timeVector(1:end-1)+timeVectorBinWidth;
idx = find(perfData.mouse==1 & perfData.type==1 & perfData.tDay==26);
figure
hold on
vels = [];
for i = 1:length(idx)
    temp = diff(perfData.eyelidpos(idx(i),:));
    temp = temp/timeVectorBinWidth;
    plot(timeVectorVel*1000, temp', 'Color', [0.5 0.5 0.5])
    vels = [vels;temp];
end
plot(timeVectorVel*1000, vels(1,:)', 'color', [0 1 0.75], 'LineWidth', 3)
plot(timeVectorVel*1000, mean(vels)', 'color', [0 0 0], 'LineWidth', 3)
xlim([180 220])
ylim([-30 30])
xlabel('time (ms) from puff')
ylabel('FEC/s')

idx = find(perfData.mouse==1 & perfData.type==1 & perfData.tDay==25);
figure
hold on
vels = [];
for i = 1:length(idx)
    temp = diff(perfData.eyelidpos(idx(i),:));
    temp = temp/timeVectorBinWidth;
    plot(temp', 'Color', [0.5 0.5 0.5])
    vels = [vels;temp];
end
plot(vels(1,:)', 'color', [0 1 0.75], 'LineWidth', 3)
plot(mean(vels)', 'color', [0 0 0], 'LineWidth', 3)
xlim([76 84])
ylim([-30 30])


% try velocity for last day with and first day back without 135
idx = find(perfData.mouse==1 & perfData.type==1 & perfData.tDay==31);
figure
hold on
vels = [];
for i = 1:length(idx)
    temp = diff(perfData.eyelidpos(idx(i),:));
    temp = temp/timeVectorBinWidth;
    plot(temp')
    vels = [vels;temp];
end
plot(mean(vels)', 'color', [0 0 0], 'LineWidth', 3)
xlim([76 84])
ylim([-20 20])

idx = find(perfData.mouse==1 & perfData.type==1 & perfData.tDay==32);
figure
hold on
vels = [];
for i = 1:length(idx)
    temp = diff(perfData.eyelidpos(idx(i),:));
    temp = temp/timeVectorBinWidth;
    plot(temp')
    vels = [vels;temp];
end
plot(mean(vels)', 'color', [0 0 0], 'LineWidth', 3)
xlim([76 84])
ylim([-20 20])

% try velocity for last day without and first day with 137
idx = find(perfData.mouse==2 & perfData.type==1 & perfData.tDay==21);
figure
hold on
vels = [];
for i = 1:length(idx)
    temp = diff(perfData.eyelidpos(idx(i),:));
    temp = temp/timeVectorBinWidth;
    plot(temp')
    vels = [vels;temp];
end
plot(mean(vels)', 'color', [0 0 0], 'LineWidth', 3)
xlim([76 84])
ylim([-30 30])

idx = find(perfData.mouse==2 & perfData.type==1 & perfData.tDay==20);
figure
hold on
vels = [];
for i = 1:length(idx)
    temp = diff(perfData.eyelidpos(idx(i),:));
    temp = temp/timeVectorBinWidth;
    plot(temp')
    vels = [vels;temp];
end
plot(mean(vels)', 'color', [0 0 0], 'LineWidth', 3)
xlim([76 84])
ylim([-30 30])


% try velocity for last day with and first day back without 137
idx = find(perfData.mouse==2 & perfData.type==1 & perfData.tDay==30);
figure
hold on
vels = [];
for i = 1:length(idx)
    temp = diff(perfData.eyelidpos(idx(i),:));
    temp = temp/timeVectorBinWidth;
    plot(temp')
    vels = [vels;temp];
end
plot(mean(vels)', 'color', [0 0 0], 'LineWidth', 3)
xlim([76 84])
ylim([-20 20])

idx = find(perfData.mouse==2 & perfData.type==1 & perfData.tDay==31);
figure
hold on
vels = [];
for i = 1:length(idx)
    temp = diff(perfData.eyelidpos(idx(i),:));
    temp = temp/timeVectorBinWidth;
    plot(temp')
    vels = [vels;temp];
end
plot(mean(vels)', 'color', [0 0 0], 'LineWidth', 3)
xlim([76 84])
ylim([-20 20])

% try velocity for last day without and first day with 138
idx = find(perfData.mouse==3 & perfData.type==1 & perfData.tDay==45);
figure
hold on
vels = [];
for i = 1:length(idx)
    temp = diff(perfData.eyelidpos(idx(i),:));
    temp = temp/timeVectorBinWidth;
    plot(temp')
    vels = [vels;temp];
end
plot(mean(vels)', 'color', [0 0 0], 'LineWidth', 3)
xlim([76 84])
ylim([-30 30])

idx = find(perfData.mouse==3 & perfData.type==1 & perfData.tDay==44);
figure
hold on
vels = [];
for i = 1:length(idx)
    temp = diff(perfData.eyelidpos(idx(i),:));
    temp = temp/timeVectorBinWidth;
    plot(temp')
    vels = [vels;temp];
end
plot(mean(vels)', 'color', [0 0 0], 'LineWidth', 3)
xlim([76 84])
ylim([-30 30])


% try velocity for last day with and first day back without 138
idx = find(perfData.mouse==3 & perfData.type==1 & perfData.tDay==54);
figure
hold on
vels = [];
for i = 1:length(idx)
    temp = diff(perfData.eyelidpos(idx(i),:));
    temp = temp/timeVectorBinWidth;
    plot(temp')
    vels = [vels;temp];
end
plot(mean(vels)', 'color', [0 0 0], 'LineWidth', 3)
xlim([76 84])
ylim([-20 20])

idx = find(perfData.mouse==3 & perfData.type==1 & perfData.tDay==55);
figure
hold on
vels = [];
for i = 1:length(idx)
    temp = diff(perfData.eyelidpos(idx(i),:));
    temp = temp/timeVectorBinWidth;
    plot(temp')
    vels = [vels;temp];
end
plot(mean(vels)', 'color', [0 0 0], 'LineWidth', 3)
xlim([76 84])
ylim([-20 20])

% try velocity for last day without and first day with 134
idx = find(perfData.mouse==4 & perfData.type==1 & perfData.tDay==36);
figure
hold on
vels = [];
for i = 1:length(idx)
    temp = diff(perfData.eyelidpos(idx(i),:));
    temp = temp/timeVectorBinWidth;
    plot(temp')
    vels = [vels;temp];
end
plot(mean(vels)', 'color', [0 0 0], 'LineWidth', 3)
xlim([76 84])
ylim([-30 30])

idx = find(perfData.mouse==4 & perfData.type==1 & perfData.tDay==35);
figure
hold on
vels = [];
for i = 1:length(idx)
    temp = diff(perfData.eyelidpos(idx(i),:));
    temp = temp/timeVectorBinWidth;
    plot(temp')
    vels = [vels;temp];
end
plot(mean(vels)', 'color', [0 0 0], 'LineWidth', 3)
xlim([76 84])
ylim([-30 30])

% try velocity for last day with and first day back without 134
idx = find(perfData.mouse==4 & perfData.type==1 & perfData.tDay==45);
figure
hold on
vels = [];
for i = 1:length(idx)
    temp = diff(perfData.eyelidpos(idx(i),:));
    temp = temp/timeVectorBinWidth;
    plot(temp')
    vels = [vels;temp];
end
plot(mean(vels)', 'color', [0 0 0], 'LineWidth', 3)
xlim([76 84])
ylim([-20 20])

idx = find(perfData.mouse==4 & perfData.type==1 & perfData.tDay==46);
figure
hold on
vels = [];
for i = 1:length(idx)
    temp = diff(perfData.eyelidpos(idx(i),:));
    temp = temp/timeVectorBinWidth;
    plot(temp')
    vels = [vels;temp];
end
plot(mean(vels)', 'color', [0 0 0], 'LineWidth', 3)
xlim([76 84])
ylim([-20 20])






%% Get mean CRAmp and CRProb during each phase of the experiment across mice
[srows scols] = size(sessNums);
clear scols
phaseData_CRAdjAmp =  NaN(4,12);
phaseData_CRAdjAmpSTD =  NaN(4,12);
phaseData_CRAdjAmpN =  NaN(4,12);
phaseData_CRProb =  NaN(4,12);
phaseData_CRProbSTD =  NaN(4,12);
phaseData_CRProb2 =  NaN(4,12);
phaseData_CRProb2STD =  NaN(4,12);
phaseData_CRProbVar = NaN(4,12); % so that OK134 can have 10% CR criterion and the others can have 20% CR criterion
phaseData_CRProbVarSTD = NaN(4,12);
phaseData_CRProbVar2 = NaN(4,12); % so that OK134 can have 10% CR criterion and the others can have 20% CR criterion
phaseData_CRProbVar2STD = NaN(4,12);
indivData=[];
indivData.CRAdjAmp={};
indivData.CRProb={};
indivData.CRProb2={};
for p = 1:8 % 5 phases of the experiment that I want to plot
    thisPhaseIdx = sessNums(:,2)==p;
    sessNums_thisPhase = sessNums(thisPhaseIdx,:);
    [temprows tempcols] = size(sessNums_thisPhase);
    
    % store data for this phase in an array formatted like:
    %  data = [mouse 1 day 1, mouse 1 day 2, mouse 1 day 3;
    %          mouse 2 day 1, mouse 2 day 2, mouse 2 day 3;
    %          and so on];
    data_CRAdjAmp = NaN(temprows,12);
    data_CRProb = NaN(temprows,12);
    data_CRProb2 = NaN(temprows,12);
    data_CRProbVar = NaN(temprows,12);
    data_CRProbVar2 = NaN(temprows,12);
    for m = 1:temprows
        dayfirst = sessNums_thisPhase(m, 3);
        daylast = sessNums_thisPhase(m, 4);
        session = [dayfirst:daylast];
        if p==1 % fix the first phase at 2 days long since one animal only had 2 days
            session = [daylast-1:daylast];
        elseif p==3 % fix the 3rd phase at 3 days long
            tempBeg = [dayfirst:dayfirst+3];
            tempEnd = [daylast-1:daylast];
            session = [tempBeg,tempEnd];
        end
        count = 1;
        while count <= length(session)
            if session(count) <= dayfirst+11
                data_CRAdjAmp(m, count) = CRAdjAmps(CRAdjAmps(:,1)==m & ...
                    CRAdjAmps(:,2)==session(count), 3);
                data_CRProb(m, count) = CRProbs(CRProbs(:,1)==m & ...
                    CRProbs(:,2)==session(count), 3);
                data_CRProb2(m, count) = CRProbs2(CRProbs2(:,1)==m & ...
                    CRProbs2(:,2)==session(count), 3);
                if m==4
                    data_CRProbVar(m, count) = CRProbs(CRProbs(:,1)==m & ...
                        CRProbs(:,2)==session(count), 3);
                    data_CRProbVar2(m, count) = CRProbs(CRProbs(:,1)==m & ...
                        CRProbs(:,2)==session(count), 3);
                elseif m==2
                    data_CRProbVar(m, count) = CRProbs2(CRProbs(:,1)==m & ...
                        CRProbs2(:,2)==session(count), 3);
                    data_CRProbVar2(m, count) = CRProbs(CRProbs(:,1)==m & ...
                        CRProbs(:,2)==session(count), 3);
                else
                    data_CRProbVar(m, count) = CRProbs2(CRProbs2(:,1)==m & ...
                        CRProbs2(:,2)==session(count), 3);
                    data_CRProbVar2(m, count) = CRProbs2(CRProbs2(:,1)==m & ...
                        CRProbs2(:,2)==session(count), 3);
                end
            end
            count = count+1;
        end
        indivData.CRAdjAmp{m,p}=data_CRAdjAmp(m, :);
        indivData.CRProb{m,p}=data_CRProb(m, :);
        indivData.CRProb2{m,p}=data_CRProb2(m, :);
    end
    
    if temprows>1
        phaseData_CRAdjAmp(p,:) = nanmean(data_CRAdjAmp);
        phaseData_CRAdjAmpSTD(p,:)=nanstd(data_CRAdjAmp);
        phaseData_CRAdjAmpN(p,:)=sum(isnan(data_CRAdjAmp)==0);
        phaseData_CRProb(p,:) = nanmean(data_CRProb);
        phaseData_CRProbSTD(p,:)=nanstd(data_CRProb);
        phaseData_CRProb2(p,:) = nanmean(data_CRProb2);
        phaseData_CRProb2STD(p,:) = nanstd(data_CRProb2);
        phaseData_CRProbVar(p,:) = nanmean(data_CRProbVar);
        phaseData_CRProbVarSTD(p,:) = nanstd(data_CRProbVar);
        phaseData_CRProbVar2(p,:) = nanmean(data_CRProbVar2);
        phaseData_CRProbVar2STD(p,:) = nanstd(data_CRProbVar2);
    else
        phaseData_CRAdjAmp(p,:) = data_CRAdjAmp;
        phaseData_CRAdjAmpSTD(p,:)=NaN;
        phaseData_CRAdjAmpN(p,:)=ones(1, length(data_CRAdjAmp));
        phaseData_CRProb(p,:) = data_CRProb;
        phaseData_CRProbSTD(p,:)=NaN;
        phaseData_CRProb2(p,:) = data_CRProb2;
        phaseData_CRProb2STD(p,:)=NaN;
        phaseData_CRProbVar(p,:) = data_CRProbVar;
        phaseData_CRProbVarSTD(p,:) = NaN;
        phaseData_CRProbVar2(p,:) = data_CRProbVar2;
        phaseData_CRProbVar2STD(p,:) = NaN;
    end
    clear temprows tempcols session count dayfirst daylast
end

%% temporary plots to appraise data
colordef black

sz=15;
figure
range=[1:2];
phase = 1;
r =[1:2];
a=phaseData_CRAdjAmpSTD(1,isnan(phaseData_CRAdjAmp(1,:))==0);
b=sqrt(phaseData_CRAdjAmpN(1,phaseData_CRAdjAmpN(1,:)>0));
e=errorbar([1:2], phaseData_CRAdjAmp(1,isnan(phaseData_CRAdjAmp(1,:))==0),...
    [a(1)/b(1), a(2)/b(2)], '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
hold on
%plot individual mouse data
scatter(range,indivData.CRAdjAmp{1,phase}(r), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter(range,indivData.CRAdjAmp{2,phase}(r), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter(range,indivData.CRAdjAmp{3,phase}(r), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter(range,indivData.CRAdjAmp{4,phase}(r), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

% calc error bars
err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRAdjAmpSTD(2,erri)/...
        sqrt(phaseData_CRAdjAmpN(2,erri));
end
e=errorbar([3:12], phaseData_CRAdjAmp(2,isnan(phaseData_CRAdjAmp(2,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'green';
%plot individual mouse data
scatter([3:12],indivData.CRAdjAmp{1,2}(1:10), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([3:12],indivData.CRAdjAmp{2,2}(1:10), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([3:12],indivData.CRAdjAmp{3,2}(1:10), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([3:12],indivData.CRAdjAmp{4,2}(1:10), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRAdjAmpSTD(3,erri)/...
        sqrt(phaseData_CRAdjAmpN(3,erri));
end
e=errorbar([13:18], phaseData_CRAdjAmp(3,isnan(phaseData_CRAdjAmp(3,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
%plot individual mouse data
scatter([13:18],indivData.CRAdjAmp{1,3}(1:6), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([13:18],indivData.CRAdjAmp{2,3}(1:6), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([13:18],indivData.CRAdjAmp{3,3}(1:6), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([13:18],indivData.CRAdjAmp{4,3}(1:6), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])


err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRAdjAmpSTD(4,erri)/...
        sqrt(phaseData_CRAdjAmpN(4,erri));
end
e=errorbar([19:28], phaseData_CRAdjAmp(4,isnan(phaseData_CRAdjAmp(4,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = [1 0.5 0];
%plot individual mouse data
scatter([19:28],indivData.CRAdjAmp{1,4}(1:10), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([19:28],indivData.CRAdjAmp{2,4}(1:10), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([19:28],indivData.CRAdjAmp{3,4}(1:10), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([19:28],indivData.CRAdjAmp{4,4}(1:10), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRAdjAmpSTD(5,erri)/...
        sqrt(phaseData_CRAdjAmpN(5,erri));
end
e=errorbar([29:31], phaseData_CRAdjAmp(5,1:3),err(1:3,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
%plot individual mouse data
scatter([29:31],indivData.CRAdjAmp{1,5}(1:3), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([29:31],indivData.CRAdjAmp{2,5}(1:3), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([29:31],indivData.CRAdjAmp{3,5}(1:3), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([29:31],indivData.CRAdjAmp{4,5}(1:3), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRAdjAmpSTD(6,erri)/...
        sqrt(phaseData_CRAdjAmpN(6,erri));
end
e=errorbar([32:34], phaseData_CRAdjAmp(6,1:3),err(1:3,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
%plot individual mouse data
scatter([32:34],indivData.CRAdjAmp{1,6}(1:3), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([32:34],indivData.CRAdjAmp{2,6}(1:3), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([32:34],indivData.CRAdjAmp{3,6}(1:3), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([32:34],indivData.CRAdjAmp{4,6}(1:3), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRAdjAmpSTD(7,erri)/...
        sqrt(phaseData_CRAdjAmpN(7,erri));
end
e=errorbar([35:44], phaseData_CRAdjAmp(7,1:10),err(1:10,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'cyan';
%plot individual mouse data
scatter([35:44],indivData.CRAdjAmp{1,7}(1:10), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([35:44],indivData.CRAdjAmp{2,7}(1:10), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([35:44],indivData.CRAdjAmp{3,7}(1:10), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([35:44],indivData.CRAdjAmp{4,7}(1:10), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRAdjAmpSTD(8,erri)/...
        sqrt(phaseData_CRAdjAmpN(8,erri));
end
e=errorbar([45:49], phaseData_CRAdjAmp(8,1:5),err(1:5,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
%plot individual mouse data
scatter([45:49],indivData.CRAdjAmp{1,8}(1:5), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([45:49],indivData.CRAdjAmp{2,8}(1:5), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([45:49],indivData.CRAdjAmp{3,8}(1:5), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([45:49],indivData.CRAdjAmp{4,8}(1:5), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

%
%
% for i = 1:sum(phaseData_CRAdjAmpN(1,:)>0)
%     text(i+0.1, phaseData_CRAdjAmp(1,i)+0.01, num2str(phaseData_CRAdjAmpN(1,i)))
% end
% for i = 1:sum(phaseData_CRAdjAmpN(2,:)>0)
%     text(i+2.1, phaseData_CRAdjAmp(2,i)+0.01, num2str(phaseData_CRAdjAmpN(2,i)), 'Color','g')
% end
% for i = 1:sum(phaseData_CRAdjAmpN(3,:)>0)
%     text(i+12.1, phaseData_CRAdjAmp(3,i)+0.01, num2str(phaseData_CRAdjAmpN(3,i)))
% end
% for i = 1:sum(phaseData_CRAdjAmpN(4,:)>0)
%     text(i+18.1, phaseData_CRAdjAmp(4,i)+0.01, num2str(phaseData_CRAdjAmpN(4,i)), 'Color', [1 0.5 0])
% end
% for i = 1:sum(phaseData_CRAdjAmpN(5,:)>0)
%     text(i+28.1, phaseData_CRAdjAmp(5,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
% end
%xlim([0 24.5])
ylabel('CR Amp (minus baseline)')
xlabel('Session')
title('CR Adj Amp')
set(gca,'TickDir','out')
set(gca,'box','off')




% next figure
figure
a=phaseData_CRProbSTD(1,isnan(phaseData_CRProb(1,:))==0);
b=sqrt(phaseData_CRAdjAmpN(1,phaseData_CRAdjAmpN(1,:)>0));
e=errorbar([1:2], phaseData_CRProb(1,isnan(phaseData_CRAdjAmp(1,:))==0),...
    [a(1)/b(1), a(2)/b(2)], '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
hold on
scatter(range,indivData.CRProb{1,phase}(r), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter(range,indivData.CRProb{2,phase}(r), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter(range,indivData.CRProb{3,phase}(r), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter(range,indivData.CRProb{4,phase}(r), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

% calc error bars
err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbSTD(2,erri)/...
        sqrt(phaseData_CRAdjAmpN(2,erri));
end
e=errorbar([3:12], phaseData_CRProb(2,isnan(phaseData_CRAdjAmp(2,:))==0),err(isnan(err)==0,1),'.');
e.MarkerSize = 10;
e.Color = 'green';
scatter([3:12],indivData.CRProb{1,2}(1:10), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([3:12],indivData.CRProb{2,2}(1:10), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([3:12],indivData.CRProb{3,2}(1:10), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([3:12],indivData.CRProb{4,2}(1:10), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbSTD(3,erri)/...
        sqrt(phaseData_CRAdjAmpN(3,erri));
end
e=errorbar([13:18], phaseData_CRProb(3,isnan(phaseData_CRAdjAmp(3,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
scatter([13:18],indivData.CRProb{1,3}(1:6), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([13:18],indivData.CRProb{2,3}(1:6), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([13:18],indivData.CRProb{3,3}(1:6), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([13:18],indivData.CRProb{4,3}(1:6), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbSTD(4,erri)/...
        sqrt(phaseData_CRAdjAmpN(4,erri));
end
e=errorbar([19:28], phaseData_CRProb(4,isnan(phaseData_CRAdjAmp(4,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = [1 0.5 0];
scatter([19:28],indivData.CRProb{1,4}(1:10), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([19:28],indivData.CRProb{2,4}(1:10), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([19:28],indivData.CRProb{3,4}(1:10), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([19:28],indivData.CRProb{4,4}(1:10), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbSTD(5,erri)/...
        sqrt(phaseData_CRAdjAmpN(5,erri));
end
e=errorbar([29:31], phaseData_CRProb(5,1:3),err(1:3,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
%plot individual mouse data
scatter([29:31],indivData.CRProb{1,5}(1:3), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([29:31],indivData.CRProb{2,5}(1:3), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([29:31],indivData.CRProb{3,5}(1:3), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([29:31],indivData.CRProb{4,5}(1:3), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbSTD(6,erri)/...
        sqrt(phaseData_CRAdjAmpN(6,erri));
end
e=errorbar([32:34], phaseData_CRProb(6,1:3),err(1:3,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
%plot individual mouse data
scatter([32:34],indivData.CRProb{1,6}(1:3), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([32:34],indivData.CRProb{2,6}(1:3), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([32:34],indivData.CRProb{3,6}(1:3), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([32:34],indivData.CRProb{4,6}(1:3), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbSTD(7,erri)/...
        sqrt(phaseData_CRAdjAmpN(7,erri));
end
e=errorbar([35:44], phaseData_CRProb(7,1:10),err(1:10,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'cyan';
%plot individual mouse data
scatter([35:44],indivData.CRProb{1,7}(1:10), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([35:44],indivData.CRProb{2,7}(1:10), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([35:44],indivData.CRProb{3,7}(1:10), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([35:44],indivData.CRProb{4,7}(1:10), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbSTD(8,erri)/...
        sqrt(phaseData_CRAdjAmpN(8,erri));
end
e=errorbar([45:49], phaseData_CRProb(8,1:5),err(1:5,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
%plot individual mouse data
scatter([45:49],indivData.CRProb{1,8}(1:5), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([45:49],indivData.CRProb{2,8}(1:5), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([45:49],indivData.CRProb{3,8}(1:5), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([45:49],indivData.CRProb{4,8}(1:5), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])


% for i = 1:sum(phaseData_CRAdjAmpN(1,:)>0)
%     text(i+0.1, phaseData_CRProb(1,i)+0.01, num2str(phaseData_CRAdjAmpN(1,i)))
% end
% for i = 1:sum(phaseData_CRAdjAmpN(2,:)>0)
%     text(i+2.1, phaseData_CRProb(2,i)+0.01, num2str(phaseData_CRAdjAmpN(2,i)), 'Color','g')
% end
% for i = 1:sum(phaseData_CRAdjAmpN(3,:)>0)
%     text(i+12.1, phaseData_CRProb(3,i)+0.01, num2str(phaseData_CRAdjAmpN(3,i)))
% end
% for i = 1:sum(phaseData_CRAdjAmpN(4,:)>0)
%     text(i+18.1, phaseData_CRProb(4,i)+0.01, num2str(phaseData_CRAdjAmpN(4,i)), 'Color', [1 0.5 0])
% end
% for i = 1:sum(phaseData_CRAdjAmpN(5,:)>0)
%     text(i+28.1, phaseData_CRProb(5,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
% end
ylabel('CR Prob')
xlabel('Session')
title('FEC 0.1 increase criterion')
set(gca,'TickDir','out')
set(gca,'box','off')
%xlim([0 24.5])

% next figure
figure
a=phaseData_CRProb2STD(1,isnan(phaseData_CRProb2(1,:))==0);
b=sqrt(phaseData_CRAdjAmpN(1,phaseData_CRAdjAmpN(1,:)>0));
e=errorbar([1:2], phaseData_CRProb2(1,isnan(phaseData_CRAdjAmp(1,:))==0),...
    [a(1)/b(1), a(2)/b(2)], '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
hold on
scatter(range,indivData.CRProb2{1,phase}(r), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter(range,indivData.CRProb2{2,phase}(r), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter(range,indivData.CRProb2{3,phase}(r), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter(range,indivData.CRProb2{4,phase}(r), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

% calc error bars
err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProb2STD(2,erri)/...
        sqrt(phaseData_CRAdjAmpN(2,erri));
end
e=errorbar([3:12], phaseData_CRProb2(2,isnan(phaseData_CRAdjAmp(2,:))==0),err(isnan(err)==0,1),'.');
e.MarkerSize = 10;
e.Color = 'green';
scatter([3:12],indivData.CRProb2{1,2}(1:10), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([3:12],indivData.CRProb2{2,2}(1:10), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([3:12],indivData.CRProb2{3,2}(1:10), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([3:12],indivData.CRProb2{4,2}(1:10), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProb2STD(3,erri)/...
        sqrt(phaseData_CRAdjAmpN(3,erri));
end
e=errorbar([13:18], phaseData_CRProb2(3,isnan(phaseData_CRAdjAmp(3,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
scatter([13:18],indivData.CRProb2{1,3}(1:6), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([13:18],indivData.CRProb2{2,3}(1:6), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([13:18],indivData.CRProb2{3,3}(1:6), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([13:18],indivData.CRProb2{4,3}(1:6), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProb2STD(4,erri)/...
        sqrt(phaseData_CRAdjAmpN(4,erri));
end
e=errorbar([19:28], phaseData_CRProb2(4,isnan(phaseData_CRAdjAmp(4,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = [1 0.5 0];
scatter([19:28],indivData.CRProb2{1,4}(1:10), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([19:28],indivData.CRProb2{2,4}(1:10), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([19:28],indivData.CRProb2{3,4}(1:10), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([19:28],indivData.CRProb2{4,4}(1:10), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProb2STD(5,erri)/...
        sqrt(phaseData_CRAdjAmpN(5,erri));
end
e=errorbar([29:31], phaseData_CRProb2(5,1:3),err(1:3,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
%plot individual mouse data
scatter([29:31],indivData.CRProb2{1,5}(1:3), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([29:31],indivData.CRProb2{2,5}(1:3), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([29:31],indivData.CRProb2{3,5}(1:3), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([29:31],indivData.CRProb2{4,5}(1:3), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProb2STD(6,erri)/...
        sqrt(phaseData_CRAdjAmpN(6,erri));
end
e=errorbar([32:34], phaseData_CRProb2(6,1:3),err(1:3,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
%plot individual mouse data
scatter([32:34],indivData.CRProb2{1,6}(1:3), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([32:34],indivData.CRProb2{2,6}(1:3), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([32:34],indivData.CRProb2{3,6}(1:3), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([32:34],indivData.CRProb2{4,6}(1:3), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProb2STD(7,erri)/...
        sqrt(phaseData_CRAdjAmpN(7,erri));
end
e=errorbar([35:44], phaseData_CRProb2(7,1:10),err(1:10,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'cyan';
%plot individual mouse data
scatter([35:44],indivData.CRProb2{1,7}(1:10), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([35:44],indivData.CRProb2{2,7}(1:10), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([35:44],indivData.CRProb2{3,7}(1:10), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([35:44],indivData.CRProb2{4,7}(1:10), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProb2STD(8,erri)/...
        sqrt(phaseData_CRAdjAmpN(8,erri));
end
e=errorbar([45:49], phaseData_CRProb2(8,1:5),err(1:5,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
%plot individual mouse data
scatter([45:49],indivData.CRProb2{1,8}(1:5), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([45:49],indivData.CRProb2{2,8}(1:5), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([45:49],indivData.CRProb2{3,8}(1:5), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([45:49],indivData.CRProb2{4,8}(1:5), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])
%
% for i = 1:sum(phaseData_CRAdjAmpN(1,:)>0)
%     text(i+0.1, phaseData_CRProb2(1,i)+0.01, num2str(phaseData_CRAdjAmpN(1,i)))
% end
% for i = 1:sum(phaseData_CRAdjAmpN(2,:)>0)
%     text(i+2.1, phaseData_CRProb2(2,i)+0.01, num2str(phaseData_CRAdjAmpN(2,i)), 'Color','g')
% end
% for i = 1:sum(phaseData_CRAdjAmpN(3,:)>0)
%     text(i+12.1, phaseData_CRProb2(3,i)+0.01, num2str(phaseData_CRAdjAmpN(3,i)))
% end
% for i = 1:sum(phaseData_CRAdjAmpN(4,:)>0)
%     text(i+18.1, phaseData_CRProb2(4,i)+0.01, num2str(phaseData_CRAdjAmpN(4,i)), 'Color', [1 0.5 0])
% end
% for i = 1:sum(phaseData_CRAdjAmpN(5,:)>0)
%     text(i+28.1, phaseData_CRProb2(5,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
% end
ylabel('CR Prob')
xlabel('Session')
title('FEC 0.2 increase criterion')
set(gca,'TickDir','out')
set(gca,'box','off')
%xlim([0 24.5])


% variable CRProb criterion so 134 has 10% criterion and others have 20%
% criterion
figure
a=phaseData_CRProbVarSTD(1,isnan(phaseData_CRProb2(1,:))==0);
b=sqrt(phaseData_CRAdjAmpN(1,phaseData_CRAdjAmpN(1,:)>0));
e=errorbar([1:2], phaseData_CRProbVar(1,isnan(phaseData_CRAdjAmp(1,:))==0),...
    [a(1)/b(1), a(2)/b(2)], '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
hold on
scatter(range,indivData.CRProb2{1,phase}(r), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter(range,indivData.CRProb2{2,phase}(r), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter(range,indivData.CRProb2{3,phase}(r), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter(range,indivData.CRProb{4,phase}(r), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

% calc error bars
err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbVarSTD(2,erri)/...
        sqrt(phaseData_CRAdjAmpN(2,erri));
end
e=errorbar([3:12], phaseData_CRProbVar(2,isnan(phaseData_CRAdjAmp(2,:))==0),err(isnan(err)==0,1),'.');
e.MarkerSize = 10;
e.Color = 'green';
scatter([3:12],indivData.CRProb2{1,2}(1:10), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([3:12],indivData.CRProb2{2,2}(1:10), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([3:12],indivData.CRProb2{3,2}(1:10), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([3:12],indivData.CRProb{4,2}(1:10), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbVarSTD(3,erri)/...
        sqrt(phaseData_CRAdjAmpN(3,erri));
end
e=errorbar([13:18], phaseData_CRProbVar(3,isnan(phaseData_CRAdjAmp(3,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
scatter([13:18],indivData.CRProb2{1,3}(1:6), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([13:18],indivData.CRProb2{2,3}(1:6), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([13:18],indivData.CRProb2{3,3}(1:6), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([13:18],indivData.CRProb{4,3}(1:6), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbVarSTD(4,erri)/...
        sqrt(phaseData_CRAdjAmpN(4,erri));
end
e=errorbar([19:28], phaseData_CRProbVar(4,isnan(phaseData_CRAdjAmp(4,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = [1 0.5 0];
scatter([19:28],indivData.CRProb2{1,4}(1:10), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([19:28],indivData.CRProb2{2,4}(1:10), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([19:28],indivData.CRProb2{3,4}(1:10), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([19:28],indivData.CRProb{4,4}(1:10), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbVarSTD(5,erri)/...
        sqrt(phaseData_CRAdjAmpN(5,erri));
end
e=errorbar([29:31], phaseData_CRProbVar(5,1:3),err(1:3,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
%plot individual mouse data
scatter([29:31],indivData.CRProb2{1,5}(1:3), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([29:31],indivData.CRProb2{2,5}(1:3), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([29:31],indivData.CRProb2{3,5}(1:3), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([29:31],indivData.CRProb{4,5}(1:3), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbVarSTD(6,erri)/...
        sqrt(phaseData_CRAdjAmpN(6,erri));
end
e=errorbar([32:34], phaseData_CRProbVar(6,1:3),err(1:3,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
%plot individual mouse data
scatter([32:34],indivData.CRProb2{1,6}(1:3), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([32:34],indivData.CRProb2{2,6}(1:3), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([32:34],indivData.CRProb2{3,6}(1:3), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([32:34],indivData.CRProb{4,6}(1:3), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbVarSTD(7,erri)/...
        sqrt(phaseData_CRAdjAmpN(7,erri));
end
e=errorbar([35:44], phaseData_CRProbVar(7,1:10),err(1:10,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'cyan';
%plot individual mouse data
scatter([35:44],indivData.CRProb2{1,7}(1:10), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([35:44],indivData.CRProb2{2,7}(1:10), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([35:44],indivData.CRProb2{3,7}(1:10), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([35:44],indivData.CRProb{4,7}(1:10), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbVarSTD(8,erri)/...
        sqrt(phaseData_CRAdjAmpN(8,erri));
end
e=errorbar([45:49], phaseData_CRProbVar(8,1:5),err(1:5,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
%plot individual mouse data
scatter([45:49],indivData.CRProb2{1,8}(1:5), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([45:49],indivData.CRProb2{2,8}(1:5), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([45:49],indivData.CRProb2{3,8}(1:5), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([45:49],indivData.CRProb{4,8}(1:5), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])
%
% for i = 1:sum(phaseData_CRAdjAmpN(1,:)>0)
%     text(i+0.1, phaseData_CRProbVar(1,i)+0.01, num2str(phaseData_CRAdjAmpN(1,i)))
% end
% for i = 1:sum(phaseData_CRAdjAmpN(2,:)>0)
%     text(i+2.1, phaseData_CRProbVar(2,i)+0.01, num2str(phaseData_CRAdjAmpN(2,i)), 'Color','g')
% end
% for i = 1:sum(phaseData_CRAdjAmpN(3,:)>0)
%     text(i+12.1, phaseData_CRProbVar(3,i)+0.01, num2str(phaseData_CRAdjAmpN(3,i)))
% end
% for i = 1:sum(phaseData_CRAdjAmpN(4,:)>0)
%     text(i+18.1, phaseData_CRProbVar(4,i)+0.01, num2str(phaseData_CRAdjAmpN(4,i)), 'Color', [1 0.5 0])
% end
% for i = 1:sum(phaseData_CRAdjAmpN(5,:)>0)
%     text(i+28.1, phaseData_CRProbVar(5,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
% end
ylabel('CR Prob')
xlabel('Session')
title('FEC increase criterion var')
set(gca,'TickDir','out')
set(gca,'box','off')
%xlim([0 24.5])


% variable CRProb criterion so 134 and 137 have 10% criterion and others have 20%
% criterion
figure
a=phaseData_CRProbVar2STD(1,isnan(phaseData_CRProb2(1,:))==0);
b=sqrt(phaseData_CRAdjAmpN(1,phaseData_CRAdjAmpN(1,:)>0));
e=errorbar([1:2], phaseData_CRProbVar2(1,isnan(phaseData_CRAdjAmp(1,:))==0),...
    [a(1)/b(1), a(2)/b(2)], '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
hold on
scatter(range,indivData.CRProb2{1,phase}(r), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter(range,indivData.CRProb{2,phase}(r), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter(range,indivData.CRProb2{3,phase}(r), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter(range,indivData.CRProb{4,phase}(r), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

% calc error bars
err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbVar2STD(2,erri)/...
        sqrt(phaseData_CRAdjAmpN(2,erri));
end
e=errorbar([3:12], phaseData_CRProbVar2(2,isnan(phaseData_CRAdjAmp(2,:))==0),err(isnan(err)==0,1),'.');
e.MarkerSize = 10;
e.Color = 'green';
scatter([3:12],indivData.CRProb2{1,2}(1:10), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([3:12],indivData.CRProb{2,2}(1:10), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([3:12],indivData.CRProb2{3,2}(1:10), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([3:12],indivData.CRProb{4,2}(1:10), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbVar2STD(3,erri)/...
        sqrt(phaseData_CRAdjAmpN(3,erri));
end
e=errorbar([13:18], phaseData_CRProbVar2(3,isnan(phaseData_CRAdjAmp(3,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
scatter([13:18],indivData.CRProb2{1,3}(1:6), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([13:18],indivData.CRProb{2,3}(1:6), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([13:18],indivData.CRProb2{3,3}(1:6), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([13:18],indivData.CRProb{4,3}(1:6), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbVar2STD(4,erri)/...
        sqrt(phaseData_CRAdjAmpN(4,erri));
end
e=errorbar([19:28], phaseData_CRProbVar2(4,isnan(phaseData_CRAdjAmp(4,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = [1 0.5 0];
scatter([19:28],indivData.CRProb2{1,4}(1:10), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([19:28],indivData.CRProb{2,4}(1:10), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([19:28],indivData.CRProb2{3,4}(1:10), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([19:28],indivData.CRProb{4,4}(1:10), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbVar2STD(5,erri)/...
        sqrt(phaseData_CRAdjAmpN(5,erri));
end
e=errorbar([29:31], phaseData_CRProbVar2(5,1:3),err(1:3,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
%plot individual mouse data
scatter([29:31],indivData.CRProb2{1,5}(1:3), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([29:31],indivData.CRProb{2,5}(1:3), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([29:31],indivData.CRProb2{3,5}(1:3), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([29:31],indivData.CRProb{4,5}(1:3), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbVar2STD(6,erri)/...
        sqrt(phaseData_CRAdjAmpN(6,erri));
end
e=errorbar([32:34], phaseData_CRProbVar2(6,1:3),err(1:3,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
%plot individual mouse data
scatter([32:34],indivData.CRProb2{1,6}(1:3), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([32:34],indivData.CRProb{2,6}(1:3), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([32:34],indivData.CRProb2{3,6}(1:3), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([32:34],indivData.CRProb{4,6}(1:3), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbVar2STD(7,erri)/...
        sqrt(phaseData_CRAdjAmpN(7,erri));
end
e=errorbar([35:44], phaseData_CRProbVar2(7,1:10),err(1:10,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'cyan';
%plot individual mouse data
scatter([35:44],indivData.CRProb2{1,7}(1:10), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([35:44],indivData.CRProb{2,7}(1:10), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([35:44],indivData.CRProb2{3,7}(1:10), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([35:44],indivData.CRProb{4,7}(1:10), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])

err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRProbVar2STD(8,erri)/...
        sqrt(phaseData_CRAdjAmpN(8,erri));
end
e=errorbar([45:49], phaseData_CRProbVar2(8,1:5),err(1:5,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
%plot individual mouse data
scatter([45:49],indivData.CRProb2{1,8}(1:5), sz, 'MarkerFaceColor', [0 1 0], 'MarkerEdgeColor', [1 1 1])
scatter([45:49],indivData.CRProb{2,8}(1:5), sz, 'MarkerFaceColor', [1 0 1], 'MarkerEdgeColor', [1 1 1])
scatter([45:49],indivData.CRProb2{3,8}(1:5), sz, 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [1 1 1])
scatter([45:49],indivData.CRProb{4,8}(1:5), sz, 'MarkerFaceColor', [1 1 0], 'MarkerEdgeColor', [1 1 1])
%
% for i = 1:sum(phaseData_CRAdjAmpN(1,:)>0)
%     text(i+0.1, phaseData_CRProbVar(1,i)+0.01, num2str(phaseData_CRAdjAmpN(1,i)))
% end
% for i = 1:sum(phaseData_CRAdjAmpN(2,:)>0)
%     text(i+2.1, phaseData_CRProbVar(2,i)+0.01, num2str(phaseData_CRAdjAmpN(2,i)), 'Color','g')
% end
% for i = 1:sum(phaseData_CRAdjAmpN(3,:)>0)
%     text(i+12.1, phaseData_CRProbVar(3,i)+0.01, num2str(phaseData_CRAdjAmpN(3,i)))
% end
% for i = 1:sum(phaseData_CRAdjAmpN(4,:)>0)
%     text(i+18.1, phaseData_CRProbVar(4,i)+0.01, num2str(phaseData_CRAdjAmpN(4,i)), 'Color', [1 0.5 0])
% end
% for i = 1:sum(phaseData_CRAdjAmpN(5,:)>0)
%     text(i+28.1, phaseData_CRProbVar(5,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
% end
ylabel('CR Prob')
xlabel('Session')
title('FEC increase criterion var2')
set(gca,'TickDir','out')
set(gca,'box','off')

pause
clear phaseData_CRAdjAmp phaseData_CRProb phaseData_CRProb2...
    phaseData_CRAdjAmpSTD phaseData_CRProb phaseData_CRProb2...
    phaseData_CRAdjAmpN



%% Get mean CRAmp and CRProb during early photostim and surrounding CS+ US periods
[srows scols] = size(sessNums);
clear scols

for p = 1:3 % 3 phases of the experiment that I want to plot
    thisPhaseIdx = sessNums(:,2)==p+5;
    sessNums_thisPhase = sessNums(thisPhaseIdx,:);
    [temprows tempcols] = size(sessNums_thisPhase);
    
    % store data for this phase in an array formatted like:
    %  data = [mouse 1 day 1, mouse 1 day 2, mouse 1 day 3;
    %          mouse 2 day 1, mouse 2 day 2, mouse 2 day 3;
    %          and so on];
    data_CRAdjAmp = NaN(temprows,12);
    data_CRProb = NaN(temprows,12);
    data_CRProb2 = NaN(temprows,12);
    for m = 1:temprows
        dayfirst = sessNums_thisPhase(m, 3);
        daylast = sessNums_thisPhase(m, 4);
        if p==1 % fix the first phase at 3 days long since one animal only had 2 days
            dayfirst = daylast-2;
        end
        session = dayfirst;
        count = 1;
        while session <= daylast
            data_CRAdjAmp(m, count) = CRAdjAmps(CRAdjAmps(:,1)==m & ...
                CRAdjAmps(:,2)==session, 3);
            data_CRProb(m, count) = CRProbs(CRProbs(:,1)==m & ...
                CRProbs(:,2)==session, 3);
            data_CRProb2(m, count) = CRProbs2(CRProbs2(:,1)==m & ...
                CRProbs2(:,2)==session, 3);
            session = session + 1;
            count = count+1;
        end
    end
    
    if temprows>1
        phaseData_CRAdjAmp(p,:) = nanmean(data_CRAdjAmp);
        phaseData_CRAdjAmpSTD(p,:)=nanstd(data_CRAdjAmp);
        phaseData_CRAdjAmpN(p,:)=sum(isnan(data_CRAdjAmp)==0);
        phaseData_CRProb(p,:) = nanmean(data_CRProb);
        phaseData_CRProbSTD(p,:)=nanstd(data_CRProb);
        phaseData_CRProb2(p,:) = nanmean(data_CRProb2);
        phaseData_CRProb2STD(p,:) = nanstd(data_CRProb2);
    else
        phaseData_CRAdjAmp(p,:) = data_CRAdjAmp;
        phaseData_CRAdjAmpSTD(p,:)=NaN;
        phaseData_CRAdjAmpN(p,:)=ones(1, length(data_CRAdjAmp));
        phaseData_CRProb(p,:) = data_CRProb;
        phaseData_CRProbSTD(p,:)=NaN;
        phaseData_CRProb2(p,:) = data_CRProb2;
        phaseData_CRProb2STD(p,:)=NaN;
    end
    clear temprows tempcols session count dayfirst daylast
end

%% temporary plots to appraise data
colordef black

figure
a=phaseData_CRAdjAmpSTD(1,isnan(phaseData_CRAdjAmp(1,:))==0);
b=sqrt(phaseData_CRAdjAmpN(1,phaseData_CRAdjAmpN(1,:)>0));
e=errorbar([1:3], phaseData_CRAdjAmp(1,isnan(phaseData_CRAdjAmp(1,:))==0),...
    [a(1)/b(1), a(2)/b(2), a(3)/b(3)], '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
hold on
% calc error bars
err=[];
for erri = 1:11
    err(erri,1) = phaseData_CRAdjAmpSTD(2,erri)/...
        sqrt(phaseData_CRAdjAmpN(2,erri));
end
e=errorbar([4:14], phaseData_CRAdjAmp(2,isnan(phaseData_CRAdjAmp(2,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'red';
err=[];
for erri = 1:12
    err(erri,1) = phaseData_CRAdjAmpSTD(3,erri)/...
        sqrt(phaseData_CRAdjAmpN(3,erri));
end
e=errorbar([15:24], phaseData_CRAdjAmp(3,isnan(phaseData_CRAdjAmp(3,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
for i = 1:sum(phaseData_CRAdjAmpN(1,:)>0)
    text(i+0.1, phaseData_CRAdjAmp(1,i)+0.01, num2str(phaseData_CRAdjAmpN(1,i)))
end
for i = 1:sum(phaseData_CRAdjAmpN(2,:)>0)
    text(i+3.1, phaseData_CRAdjAmp(2,i)+0.01, num2str(phaseData_CRAdjAmpN(2,i)), 'Color','r')
end
for i = 1:sum(phaseData_CRAdjAmpN(3,:)>0)
    text(i+15.1, phaseData_CRAdjAmp(3,i)+0.01, num2str(phaseData_CRAdjAmpN(3,i)))
end
xlim([0 18.5])
ylabel('CR Amp (minus baseline)')
xlabel('Session')
title('CR Adj Amp')
set(gca,'TickDir','out')
set(gca,'box','off')
ylim([0 0.6])


pause
clear phaseData_CRAdjAmp phaseData_CRProb phaseData_CRProb2...
    phaseData_CRAdjAmpSTD phaseData_CRProb phaseData_CRProb2...
    phaseData_CRAdjAmpN phaseData_CRProbVar phaseData_CRProbVarSTD

%% try again but group days differently
% Get mean CRAmp and CRProb during each phase of the experiment across mice
[srows scols] = size(sessNums);
clear scols

for p = 1:8 % 5 phases of the experiment that I want to plot
    thisPhaseIdx = sessNums(:,2)==p;
    sessNums_thisPhase = sessNums(thisPhaseIdx,:);
    [temprows tempcols] = size(sessNums_thisPhase);
    
    % store data for this phase in an array formatted like:
    %  data = [mouse 1 day 1, mouse 1 day 2, mouse 1 day 3;
    %          mouse 2 day 1, mouse 2 day 2, mouse 2 day 3;
    %          and so on];
    data_CRAdjAmp = NaN(temprows,12);
    data_CRProb = NaN(temprows,12);
    data_CRProb2 = NaN(temprows,12);
    data_CRProbVar = NaN(temprows,12);
    data_CRProbVar2 = NaN(temprows,12);
    for m = 1:temprows
        dayfirst = sessNums_thisPhase(m, 3);
        daylast = sessNums_thisPhase(m, 4);
        if p==1 % fix the first phase at 2 days long since one animal only had 2 days
            dayfirst = daylast-1;
        end
        session = dayfirst;
        count = 1;
        while session <= daylast
            data_CRAdjAmp(m, count) = CRAdjAmps(CRAdjAmps(:,1)==m & ...
                CRAdjAmps(:,2)==session, 3);
            data_CRProb(m, count) = CRProbs(CRProbs(:,1)==m & ...
                CRProbs(:,2)==session, 3);
            data_CRProb2(m, count) = CRProbs2(CRProbs2(:,1)==m & ...
                CRProbs2(:,2)==session, 3);
            if m==4
                data_CRProbVar(m, count) = CRProbs(CRProbs(:,1)==m & ...
                    CRProbs(:,2)==session, 3);
            else
                data_CRProbVar(m, count) = CRProbs2(CRProbs2(:,1)==m & ...
                    CRProbs2(:,2)==session, 3);
            end
            if m==4 || m==2
                data_CRProbVar2(m, count) = CRProbs(CRProbs(:,1)==m & ...
                    CRProbs(:,2)==session, 3);
            else
                data_CRProbVar2(m, count) = CRProbs2(CRProbs2(:,1)==m & ...
                    CRProbs2(:,2)==session, 3);
            end
            session = session + 1;
            count = count+1;
        end
    end
    
    [trows tcols] = size(data_CRAdjAmp);
    iter = 1;
    for t = 1:2:tcols-1
        temp = [data_CRAdjAmp(:,t); data_CRAdjAmp(:,t+1)];
        phaseData_CRAdjAmp(p,iter) = nanmean(temp);
        phaseData_CRAdjAmpSTD(p,iter) = nanstd(temp);
        phaseData_CRAdjAmpN(p,iter) = sum(isnan(temp)==0);
        temp = [data_CRProb(:,t); data_CRProb(:,t+1)];
        phaseData_CRProb(p,iter) = nanmean(temp);
        phaseData_CRProbSTD(p,iter) = nanstd(temp);
        %phaseData_CRProbN(p,iter) = sum(isnan(temp)==0);
        temp = [data_CRProb2(:,t); data_CRProb2(:,t+1)];
        phaseData_CRProb2(p,iter) = nanmean(temp);
        phaseData_CRProb2STD(p,iter) = nanstd(temp);
        %phaseData_CRProb2N(p,iter) = sum(isnan(temp)==0);
        temp = [data_CRProbVar(:,t); data_CRProbVar(:,t+1)];
        phaseData_CRProbVar(p,iter) = nanmean(temp);
        phaseData_CRProbVarSTD(p,iter) = nanstd(temp);
        temp = [data_CRProbVar2(:,t); data_CRProbVar2(:,t+1)];
        phaseData_CRProbVar2(p,iter) = nanmean(temp);
        phaseData_CRProbVar2STD(p,iter) = nanstd(temp);
        iter=iter+1;
    end
    
    clear temprows tempcols session count dayfirst daylast iter
end

% temporary plots to appraise data
colordef black

figure
e=errorbar([1], phaseData_CRAdjAmp(1,isnan(phaseData_CRAdjAmp(1,:))==0),...
    phaseData_CRAdjAmpSTD(1,isnan(phaseData_CRAdjAmpSTD(1,:))==0)/...
    sqrt(phaseData_CRAdjAmpN(1,phaseData_CRAdjAmpN(1,:)>0)), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
hold on
% calc error bars
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRAdjAmpSTD(2,erri)/...
        sqrt(phaseData_CRAdjAmpN(2,erri));
end
e=errorbar([2:6], phaseData_CRAdjAmp(2,isnan(phaseData_CRAdjAmp(2,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'green';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRAdjAmpSTD(3,erri)/...
        sqrt(phaseData_CRAdjAmpN(3,erri));
end
e=errorbar([7:10], phaseData_CRAdjAmp(3,1:4),err(1:4,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRAdjAmpSTD(4,erri)/...
        sqrt(phaseData_CRAdjAmpN(4,erri));
end
e=errorbar([11:15], phaseData_CRAdjAmp(4,isnan(phaseData_CRAdjAmp(4,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = [1 0.5 0];
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRAdjAmpSTD(5,erri)/...
        sqrt(phaseData_CRAdjAmpN(5,erri));
end
e=errorbar([16:18], phaseData_CRAdjAmp(5,1:3),err(1:3,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRAdjAmpSTD(6,erri)/...
        sqrt(phaseData_CRAdjAmpN(6,erri));
end
e=errorbar([19:20], phaseData_CRAdjAmp(6,1:2),err(1:2,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRAdjAmpSTD(7,erri)/...
        sqrt(phaseData_CRAdjAmpN(7,erri));
end
e=errorbar([21:25], phaseData_CRAdjAmp(7,1:5),err(1:5,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'cyan';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRAdjAmpSTD(8,erri)/...
        sqrt(phaseData_CRAdjAmpN(8,erri));
end
e=errorbar([26:30], phaseData_CRAdjAmp(8,1:5),err(1:5,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
text(1.2, phaseData_CRAdjAmp(1,1)+0.01, num2str(phaseData_CRAdjAmpN(1,1)))
for i = 1:sum(phaseData_CRAdjAmpN(2,:)>0)
    text(i+1.1, phaseData_CRAdjAmp(2,i)+0.01, num2str(phaseData_CRAdjAmpN(2,i)), 'Color','g')
end
for i = 1:4
    text(i+6.1, phaseData_CRAdjAmp(3,i)+0.01, num2str(phaseData_CRAdjAmpN(3,i)))
end
for i = 1:sum(phaseData_CRAdjAmpN(4,:)>0)
    text(i+10.1, phaseData_CRAdjAmp(4,i)+0.01, num2str(phaseData_CRAdjAmpN(4,i)), 'Color', [1 0.5 0])
end
for i = 1:3
    text(i+15.1, phaseData_CRAdjAmp(5,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
end
for i = 1:2
    text(i+18.1, phaseData_CRAdjAmp(6,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
end
for i = 1:5
    text(i+20.1, phaseData_CRAdjAmp(7,i)+0.01, num2str(phaseData_CRAdjAmpN(7,i)), 'Color', 'c')
end
for i = 1:4
    text(i+25.1, phaseData_CRAdjAmp(8,i)+0.01, num2str(phaseData_CRAdjAmpN(8,i)))
end
xlim([0 30.5])
ylabel('CR Amp (minus baseline)')
xlabel('Session (blocks of 2)')
title('CR Adj Amp')
set(gca,'TickDir','out')
set(gca,'box','off')

%next figure
figure
e = errorbar([1], phaseData_CRProb(1,isnan(phaseData_CRAdjAmp(1,:))==0),...
    phaseData_CRProbSTD(1,isnan(phaseData_CRAdjAmpSTD(1,:))==0)/...
    sqrt(phaseData_CRAdjAmpN(1,phaseData_CRAdjAmpN(1,:)>0)), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
hold on
% calc error bars
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbSTD(2,erri)/...
        sqrt(phaseData_CRAdjAmpN(2,erri));
end
e=errorbar([2:6], phaseData_CRProb(2,isnan(phaseData_CRAdjAmp(2,:))==0),err(isnan(err)==0,1),'.');
e.MarkerSize = 10;
e.Color = 'green';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbSTD(3,erri)/...
        sqrt(phaseData_CRAdjAmpN(3,erri));
end
e=errorbar([7:10], phaseData_CRProb(3,1:4),err(1:4,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbSTD(4,erri)/...
        sqrt(phaseData_CRAdjAmpN(4,erri));
end
e=errorbar([11:15], phaseData_CRProb(4,isnan(phaseData_CRAdjAmp(4,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = [1 0.5 0];
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbSTD(5,erri)/...
        sqrt(phaseData_CRAdjAmpN(5,erri));
end
e=errorbar([16:18], phaseData_CRProb(5,1:3),err(1:3,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbSTD(6,erri)/...
        sqrt(phaseData_CRAdjAmpN(6,erri));
end
e=errorbar([19:20], phaseData_CRProb(6,1:2),err(1:2,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbSTD(7,erri)/...
        sqrt(phaseData_CRAdjAmpN(7,erri));
end
e=errorbar([21:25], phaseData_CRProb(7,1:5),err(1:5,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'cyan';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbSTD(8,erri)/...
        sqrt(phaseData_CRAdjAmpN(8,erri));
end
e=errorbar([26:30], phaseData_CRProb(8,1:5),err(1:5,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
text(1.2, phaseData_CRProb(1,1)+0.01, num2str(phaseData_CRAdjAmpN(1,1)))
for i = 1:sum(phaseData_CRAdjAmpN(2,:)>0)
    text(i+1.1, phaseData_CRProb(2,i)+0.01, num2str(phaseData_CRAdjAmpN(2,i)), 'Color','g')
end
for i = 1:4
    text(i+6.1, phaseData_CRProb(3,i)+0.01, num2str(phaseData_CRAdjAmpN(3,i)))
end
for i = 1:sum(phaseData_CRAdjAmpN(4,:)>0)
    text(i+10.1, phaseData_CRProb(4,i)+0.01, num2str(phaseData_CRAdjAmpN(4,i)), 'Color', [1 0.5 0])
end
for i = 1:3
    text(i+15.1, phaseData_CRProb(5,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
end
for i = 1:2
    text(i+18.1, phaseData_CRProb(6,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
end
for i = 1:5
    text(i+20.1, phaseData_CRProb(7,i)+0.01, num2str(phaseData_CRAdjAmpN(7,i)), 'Color', 'c')
end
for i = 1:4
    text(i+25.1, phaseData_CRProb(8,i)+0.01, num2str(phaseData_CRAdjAmpN(8,i)))
end
xlim([0 29.5])
ylabel('CR Prob')
xlabel('Session (blocks of 2)')
title('CR Prob')
set(gca,'TickDir','out')
set(gca,'box','off')

% next figure
figure
e = errorbar([1], phaseData_CRProb2(1,isnan(phaseData_CRAdjAmp(1,:))==0),...
    phaseData_CRProb2STD(1,isnan(phaseData_CRAdjAmpSTD(1,:))==0)/...
    sqrt(phaseData_CRAdjAmpN(1,phaseData_CRAdjAmpN(1,:)>0)), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
hold on
% calc error bars
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProb2STD(2,erri)/...
        sqrt(phaseData_CRAdjAmpN(2,erri));
end
e=errorbar([2:6], phaseData_CRProb2(2,isnan(phaseData_CRAdjAmp(2,:))==0),err(isnan(err)==0,1),'.');
e.MarkerSize = 10;
e.Color = 'green';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProb2STD(3,erri)/...
        sqrt(phaseData_CRAdjAmpN(3,erri));
end
e=errorbar([7:10], phaseData_CRProb2(3,1:4),err(1:4,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProb2STD(4,erri)/...
        sqrt(phaseData_CRAdjAmpN(4,erri));
end
e=errorbar([11:15], phaseData_CRProb2(4,isnan(phaseData_CRAdjAmp(4,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = [1 0.5 0];
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProb2STD(5,erri)/...
        sqrt(phaseData_CRAdjAmpN(5,erri));
end
e=errorbar([16:18], phaseData_CRProb2(5,1:3),err(1:3,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProb2STD(6,erri)/...
        sqrt(phaseData_CRAdjAmpN(6,erri));
end
e=errorbar([19:20], phaseData_CRProb2(6,1:2),err(1:2,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProb2STD(7,erri)/...
        sqrt(phaseData_CRAdjAmpN(7,erri));
end
e=errorbar([21:25], phaseData_CRProb2(7,1:5),err(1:5,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'cyan';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProb2STD(8,erri)/...
        sqrt(phaseData_CRAdjAmpN(8,erri));
end
e=errorbar([26:30], phaseData_CRProb2(8,1:5),err(1:5,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
text(1.2, phaseData_CRProb2(1,1)+0.01, num2str(phaseData_CRAdjAmpN(1,1)))
for i = 1:sum(phaseData_CRAdjAmpN(2,:)>0)
    text(i+1.1, phaseData_CRProb2(2,i)+0.01, num2str(phaseData_CRAdjAmpN(2,i)), 'Color','g')
end
for i = 1:4
    text(i+6.1, phaseData_CRProb2(3,i)+0.01, num2str(phaseData_CRAdjAmpN(3,i)))
end
for i = 1:sum(phaseData_CRAdjAmpN(4,:)>0)
    text(i+10.1, phaseData_CRProb2(4,i)+0.01, num2str(phaseData_CRAdjAmpN(4,i)), 'Color', [1 0.5 0])
end
for i = 1:3
    text(i+15.1, phaseData_CRProb2(5,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
end
for i = 1:2
    text(i+18.1, phaseData_CRProb2(6,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
end
for i = 1:5
    text(i+20.1, phaseData_CRProb2(7,i)+0.01, num2str(phaseData_CRAdjAmpN(7,i)), 'Color', 'c')
end
for i = 1:4
    text(i+25.1, phaseData_CRProb2(8,i)+0.01, num2str(phaseData_CRAdjAmpN(8,i)))
end
xlim([0 29.5])
ylabel('CR Prob (0.2 FEC criterion)')
xlabel('Session (blocks of 2)')
title('CR Prob(0.2 FEC criterion)')
set(gca,'TickDir','out')
set(gca,'box','off')

% next figure, variable CR criterion so that 134 has 10% criterion and
% others have 20% criterion
%next figure
figure
e = errorbar([1], phaseData_CRProbVar(1,isnan(phaseData_CRAdjAmp(1,:))==0),...
    phaseData_CRProbVarSTD(1,isnan(phaseData_CRAdjAmpSTD(1,:))==0)/...
    sqrt(phaseData_CRAdjAmpN(1,phaseData_CRAdjAmpN(1,:)>0)), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
hold on
% calc error bars
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbVarSTD(2,erri)/...
        sqrt(phaseData_CRAdjAmpN(2,erri));
end
e=errorbar([2:6], phaseData_CRProbVar(2,isnan(phaseData_CRAdjAmp(2,:))==0),err(isnan(err)==0,1),'.');
e.MarkerSize = 10;
e.Color = 'green';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbVarSTD(3,erri)/...
        sqrt(phaseData_CRAdjAmpN(3,erri));
end
e=errorbar([7:10], phaseData_CRProbVar(3,1:4),err(1:4,1), '.'); % I am forcing this to be 3 points long because the data are grouped weirdly in the last 2 points
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbVarSTD(4,erri)/...
        sqrt(phaseData_CRAdjAmpN(4,erri));
end
e=errorbar([11:15], phaseData_CRProbVar(4,isnan(phaseData_CRAdjAmp(4,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = [1 0.5 0];
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbVarSTD(5,erri)/...
        sqrt(phaseData_CRAdjAmpN(5,erri));
end
e=errorbar([16:18], phaseData_CRProbVar(5,1:3),err(1:3,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbVarSTD(6,erri)/...
        sqrt(phaseData_CRAdjAmpN(6,erri));
end
e=errorbar([19:20], phaseData_CRProbVar(6,1:2),err(1:2,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbVarSTD(7,erri)/...
        sqrt(phaseData_CRAdjAmpN(7,erri));
end
e=errorbar([21:25], phaseData_CRProbVar(7,1:5),err(1:5,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'cyan';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbVarSTD(8,erri)/...
        sqrt(phaseData_CRAdjAmpN(8,erri));
end
e=errorbar([26:30], phaseData_CRProbVar(8,1:5),err(1:5,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
text(1.2, phaseData_CRProbVar(1,1)+0.01, num2str(phaseData_CRAdjAmpN(1,1)))
for i = 1:sum(phaseData_CRAdjAmpN(2,:)>0)
    text(i+1.1, phaseData_CRProbVar(2,i)+0.01, num2str(phaseData_CRAdjAmpN(2,i)), 'Color','g')
end
for i = 1:4
    text(i+6.1, phaseData_CRProbVar(3,i)+0.01, num2str(phaseData_CRAdjAmpN(3,i)))
end
for i = 1:sum(phaseData_CRAdjAmpN(4,:)>0)
    text(i+10.1, phaseData_CRProbVar(4,i)+0.01, num2str(phaseData_CRAdjAmpN(4,i)), 'Color', [1 0.5 0])
end
for i = 1:3
    text(i+15.1, phaseData_CRProbVar(5,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
end
for i = 1:2
    text(i+18.1, phaseData_CRProbVar(6,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
end
for i = 1:5
    text(i+20.1, phaseData_CRProbVar(7,i)+0.01, num2str(phaseData_CRAdjAmpN(7,i)), 'Color', 'c')
end
for i = 1:4
    text(i+25.1, phaseData_CRProbVar(8,i)+0.01, num2str(phaseData_CRAdjAmpN(8,i)))
end
xlim([0 29.5])
ylabel('CR Prob')
xlabel('Session (blocks of 2)')
title('CR Prob(Var criterion)')
set(gca,'TickDir','out')
set(gca,'box','off')

% next figure, variable CR criterion so that 134 and 137 has 10% criterion and
% 135 and 138 have 20% criterion
%next figure
figure
e = errorbar([1], phaseData_CRProbVar2(1,isnan(phaseData_CRAdjAmp(1,:))==0),...
    phaseData_CRProbVar2STD(1,isnan(phaseData_CRAdjAmpSTD(1,:))==0)/...
    sqrt(phaseData_CRAdjAmpN(1,phaseData_CRAdjAmpN(1,:)>0)), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
hold on
% calc error bars
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbVar2STD(2,erri)/...
        sqrt(phaseData_CRAdjAmpN(2,erri));
end
e=errorbar([2:6], phaseData_CRProbVar2(2,isnan(phaseData_CRAdjAmp(2,:))==0),err(isnan(err)==0,1),'.');
e.MarkerSize = 10;
e.Color = 'green';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbVar2STD(3,erri)/...
        sqrt(phaseData_CRAdjAmpN(3,erri));
end
e=errorbar([7:10], phaseData_CRProbVar2(3,1:4),err(1:4,1), '.'); % I am forcing this to be 3 points long because the data are grouped weirdly in the last 2 points
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbVar2STD(4,erri)/...
        sqrt(phaseData_CRAdjAmpN(4,erri));
end
e=errorbar([11:15], phaseData_CRProbVar2(4,isnan(phaseData_CRAdjAmp(4,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = [1 0.5 0];
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbVar2STD(5,erri)/...
        sqrt(phaseData_CRAdjAmpN(5,erri));
end
e=errorbar([16:18], phaseData_CRProbVar2(5,1:3),err(1:3,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbVar2STD(6,erri)/...
        sqrt(phaseData_CRAdjAmpN(6,erri));
end
e=errorbar([19:20], phaseData_CRProbVar2(6,1:2),err(1:2,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbVar2STD(7,erri)/...
        sqrt(phaseData_CRAdjAmpN(7,erri));
end
e=errorbar([21:25], phaseData_CRProbVar2(7,1:5),err(1:5,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'cyan';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbVar2STD(8,erri)/...
        sqrt(phaseData_CRAdjAmpN(8,erri));
end
e=errorbar([26:30], phaseData_CRProbVar2(8,1:5),err(1:5,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
text(1.2, phaseData_CRProbVar2(1,1)+0.01, num2str(phaseData_CRAdjAmpN(1,1)))
for i = 1:sum(phaseData_CRAdjAmpN(2,:)>0)
    text(i+1.1, phaseData_CRProbVar2(2,i)+0.01, num2str(phaseData_CRAdjAmpN(2,i)), 'Color','g')
end
for i = 1:4
    text(i+6.1, phaseData_CRProbVar2(3,i)+0.01, num2str(phaseData_CRAdjAmpN(3,i)))
end
for i = 1:sum(phaseData_CRAdjAmpN(4,:)>0)
    text(i+10.1, phaseData_CRProbVar2(4,i)+0.01, num2str(phaseData_CRAdjAmpN(4,i)), 'Color', [1 0.5 0])
end
for i = 1:3
    text(i+15.1, phaseData_CRProbVar2(5,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
end
for i = 1:2
    text(i+18.1, phaseData_CRProbVar2(6,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
end
for i = 1:5
    text(i+20.1, phaseData_CRProbVar2(7,i)+0.01, num2str(phaseData_CRAdjAmpN(7,i)), 'Color', 'c')
end
for i = 1:4
    text(i+25.1, phaseData_CRProbVar2(8,i)+0.01, num2str(phaseData_CRAdjAmpN(8,i)))
end
xlim([0 29.5])
ylabel('CR Prob')
xlabel('Session (blocks of 2)')
title('CR Prob(Var criterion so 137 and 134 have 0.1 FEC crit)')
set(gca,'TickDir','out')
set(gca,'box','off')

clear phaseData_CRAdjAmp phaseData_CRProb phaseData_CRProb2...
    phaseData_CRAdjAmpSTD phaseData_CRProb phaseData_CRProb2...
    phaseData_CRAdjAmpN


%% Get mean CRAmp and CRProb during each phase of the experiment across mice
% modified to show first 2 days of "extinction" phase by themself and then show
% the rest of the days grouped into pairs
% ALSO THIS PART IS FUCKED UP BUT I DON'T HAVE TIME TO FIX IT BEFORE THE
% COMMITEE MEETING SO IT'S JUST GONNA STAY THAT WAY RIGHT NOW
% Get mean CRAmp and CRProb during each phase of the experiment across mice
[srows scols] = size(sessNums);
clear scols

for p = 1:5 % 5 phases of the experiment that I want to plot
    thisPhaseIdx = sessNums(:,2)==p;
    sessNums_thisPhase = sessNums(thisPhaseIdx,:);
    [temprows tempcols] = size(sessNums_thisPhase);
    
    % store data for this phase in an array formatted like:
    %  data = [mouse 1 day 1, mouse 1 day 2, mouse 1 day 3;
    %          mouse 2 day 1, mouse 2 day 2, mouse 2 day 3;
    %          and so on];
    data_CRAdjAmp = NaN(temprows,12);
    data_CRProb = NaN(temprows,12);
    data_CRProb2 = NaN(temprows,12);
    for m = 1:temprows
        dayfirst = sessNums_thisPhase(m, 3);
        daylast = sessNums_thisPhase(m, 4);
        
        if p==1 % fix the first phase at 2 days long since one animal only had 2 days
            dayfirst = daylast-1;
        end
        session = dayfirst;
        count = 1;
        while session <= daylast
            data_CRAdjAmp(m, count) = CRAdjAmps(CRAdjAmps(:,1)==m & ...
                CRAdjAmps(:,2)==session, 3);
            data_CRProb(m, count) = CRProbs(CRProbs(:,1)==m & ...
                CRProbs(:,2)==session, 3);
            data_CRProb2(m, count) = CRProbs2(CRProbs2(:,1)==m & ...
                CRProbs2(:,2)==session, 3);
            session = session + 1;
            count = count+1;
        end
        
    end
    
    [trows tcols] = size(data_CRAdjAmp);
    iter = 1;
    if p==2
        temp = [data_CRAdjAmp(:,1); data_CRAdjAmp(:,t+1)];
        phaseData_CRAdjAmp(p,1) = nanmean(data_CRAdjAmp(:,1));
        phaseData_CRAdjAmp(p,2) = nanmean(data_CRAdjAmp(:,2));
        phaseData_CRAdjAmpSTD(p,1) = nanstd(data_CRAdjAmp(:,1));
        phaseData_CRAdjAmpSTD(p,2) = nanstd(data_CRAdjAmp(:,2));
        phaseData_CRAdjAmpN(p,1) = sum(isnan(data_CRAdjAmp(:,1))==0);
        phaseData_CRAdjAmpN(p,2) = sum(isnan(data_CRAdjAmp(:,2))==0);
        phaseData_CRProb(p,1) = nanmean(data_CRProb(:,1));
        phaseData_CRProb(p,2) = nanmean(data_CRProb(:,2));
        phaseData_CRProbSTD(p,1) = nanstd(data_CRProb(:,1));
        phaseData_CRProbSTD(p,2) = nanstd(data_CRProb(:,2));
        phaseData_CRProb2(p,1) = nanmean(data_CRProb2(:,1));
        phaseData_CRProb2(p,2) = nanmean(data_CRProb2(:,2));
        phaseData_CRProb2STD(p,1) = nanstd(data_CRProb2(:,1));
        phaseData_CRProb2STD(p,2) = nanstd(data_CRProb2(:,2));
        iter=3;
        for t = 3:2:tcols
            temp = [data_CRAdjAmp(:,t); data_CRAdjAmp(:,t+1)];
            phaseData_CRAdjAmp(p,iter) = nanmean(temp);
            phaseData_CRAdjAmpSTD(p,iter) = nanstd(temp);
            phaseData_CRAdjAmpN(p,iter) = sum(isnan(temp)==0);
            temp = [data_CRProb(:,t); data_CRProb(:,t+1)];
            phaseData_CRProb(p,iter) = nanmean(temp);
            phaseData_CRProbSTD(p,iter) = nanstd(temp);
            %phaseData_CRProbN(p,iter) = sum(isnan(temp)==0);
            temp = [data_CRProb2(:,t); data_CRProb2(:,t+1)];
            phaseData_CRProb2(p,iter) = nanmean(temp);
            phaseData_CRProb2STD(p,iter) = nanstd(temp);
            %phaseData_CRProb2N(p,iter) = sum(isnan(temp)==0);
            iter=iter+1;
        end
    else
        for t = 1:2:tcols
            temp = [data_CRAdjAmp(:,t); data_CRAdjAmp(:,t+1)];
            phaseData_CRAdjAmp(p,iter) = nanmean(temp);
            phaseData_CRAdjAmpSTD(p,iter) = nanstd(temp);
            phaseData_CRAdjAmpN(p,iter) = sum(isnan(temp)==0);
            temp = [data_CRProb(:,t); data_CRProb(:,t+1)];
            phaseData_CRProb(p,iter) = nanmean(temp);
            phaseData_CRProbSTD(p,iter) = nanstd(temp);
            %phaseData_CRProbN(p,iter) = sum(isnan(temp)==0);
            temp = [data_CRProb2(:,t); data_CRProb2(:,t+1)];
            phaseData_CRProb2(p,iter) = nanmean(temp);
            phaseData_CRProb2STD(p,iter) = nanstd(temp);
            %phaseData_CRProb2N(p,iter) = sum(isnan(temp)==0);
            iter=iter+1;
        end
    end
    
    clear temprows tempcols session count dayfirst daylast iter
end

% temporary plots to appraise data
colordef black

figure
e=errorbar([1], phaseData_CRAdjAmp(1,1),...
    phaseData_CRAdjAmpSTD(1,1)/...
    sqrt(phaseData_CRAdjAmpN(1,1)), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
hold on
% calc error bars
err=[];
for erri = 1:7
    err(erri,1) = phaseData_CRAdjAmpSTD(2,erri)/...
        sqrt(phaseData_CRAdjAmpN(2,erri));
end
e=errorbar([2:7], phaseData_CRAdjAmp(2,isnan(phaseData_CRAdjAmp(2,:))==0),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'green';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRAdjAmpSTD(3,erri)/...
        sqrt(phaseData_CRAdjAmpN(3,erri));
end
e=errorbar([8:11], phaseData_CRAdjAmp(3,1:4),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRAdjAmpSTD(4,erri)/...
        sqrt(phaseData_CRAdjAmpN(4,erri));
end
e=errorbar([12:16], phaseData_CRAdjAmp(4,1:5),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = [1 0.5 0];
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRAdjAmpSTD(5,erri)/...
        sqrt(phaseData_CRAdjAmpN(5,erri));
end
e=errorbar([17:22], phaseData_CRAdjAmp(5,1:6),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
text(1.2, phaseData_CRAdjAmp(1,1)+0.01, num2str(phaseData_CRAdjAmpN(1,1)))
for i = 1:sum(phaseData_CRAdjAmpN(2,:)>0)
    text(i+1.1, phaseData_CRAdjAmp(2,i)+0.01, num2str(phaseData_CRAdjAmpN(2,i)), 'Color','g')
end
for i = 1:sum(phaseData_CRAdjAmpN(3,:)>0)
    text(i+7.1, phaseData_CRAdjAmp(3,i)+0.01, num2str(phaseData_CRAdjAmpN(3,i)))
end
for i = 1:sum(phaseData_CRAdjAmpN(4,:)>0)
    text(i+11.1, phaseData_CRAdjAmp(4,i)+0.01, num2str(phaseData_CRAdjAmpN(4,i)), 'Color', [1 0.5 0])
end
for i = 1:sum(phaseData_CRAdjAmpN(5,:)>0)
    text(i+16.1, phaseData_CRAdjAmp(5,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
end
xlim([0 16.5])
ylabel('CR Amp (minus baseline)')
xlabel('Session (blocks of 2)')
title('CR Adj Amp')
set(gca,'TickDir','out')
set(gca,'box','off')

figure
e = errorbar([1], phaseData_CRProb(1,1),...
    phaseData_CRProbSTD(1,1)/...
    sqrt(phaseData_CRAdjAmpN(1,1)), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
hold on
% calc error bars
err=[];
for erri = 1:7
    err(erri,1) = phaseData_CRProbSTD(2,erri)/...
        sqrt(phaseData_CRAdjAmpN(2,erri));
end
e=errorbar([2:7], phaseData_CRProb(2,1:6),err(isnan(err)==0,1),'.');
e.MarkerSize = 10;
e.Color = 'green';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbSTD(3,erri)/...
        sqrt(phaseData_CRAdjAmpN(3,erri));
end
e=errorbar([8:11], phaseData_CRProb(3,1:4),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbSTD(4,erri)/...
        sqrt(phaseData_CRAdjAmpN(4,erri));
end
e=errorbar([12:16], phaseData_CRProb(4,1:5),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = [1 0.5 0];
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProbSTD(5,erri)/...
        sqrt(phaseData_CRAdjAmpN(5,erri));
end
e=errorbar([17:22], phaseData_CRProb(5,1:6),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
text(1.2, phaseData_CRProb(1,1)+0.01, num2str(phaseData_CRAdjAmpN(1,1)))
for i = 1:sum(phaseData_CRAdjAmpN(2,:)>0)
    text(i+1.1, phaseData_CRProb(2,i)+0.01, num2str(phaseData_CRAdjAmpN(2,i)), 'Color','g')
end
for i = 1:sum(phaseData_CRAdjAmpN(3,:)>0)
    text(i+7.1, phaseData_CRProb(3,i)+0.01, num2str(phaseData_CRAdjAmpN(3,i)))
end
for i = 1:sum(phaseData_CRAdjAmpN(4,:)>0)
    text(i+11.1, phaseData_CRProb(4,i)+0.01, num2str(phaseData_CRAdjAmpN(4,i)), 'Color', [1 0.5 0])
end
for i = 1:sum(phaseData_CRAdjAmpN(5,:)>0)
    text(i+16.1, phaseData_CRProb(5,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
end
xlim([0 16.5])
ylabel('CR Prob')
xlabel('Session (blocks of 2)')
title('FEC 0.1 increase criterion')
set(gca,'TickDir','out')
set(gca,'box','off')

figure
e = errorbar([1], phaseData_CRProb2(1,1),...
    phaseData_CRProb2STD(1,1)/...
    sqrt(phaseData_CRAdjAmpN(1,1)), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
hold on
% calc error bars
err=[];
for erri = 1:7
    err(erri,1) = phaseData_CRProb2STD(2,erri)/...
        sqrt(phaseData_CRAdjAmpN(2,erri));
end
e=errorbar([2:7], phaseData_CRProb2(2,1:6),err(isnan(err)==0,1),'.');
e.MarkerSize = 10;
e.Color = 'green';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProb2STD(3,erri)/...
        sqrt(phaseData_CRAdjAmpN(3,erri));
end
e=errorbar([8:11], phaseData_CRProb2(3,1:4),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProb2STD(4,erri)/...
        sqrt(phaseData_CRAdjAmpN(4,erri));
end
e=errorbar([12:16], phaseData_CRProb2(4,1:5),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = [1 0.5 0];
err=[];
for erri = 1:6
    err(erri,1) = phaseData_CRProb2STD(5,erri)/...
        sqrt(phaseData_CRAdjAmpN(5,erri));
end
e=errorbar([17:22], phaseData_CRProb2(5,1:6),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
text(1.2, phaseData_CRProb2(1,1)+0.01, num2str(phaseData_CRAdjAmpN(1,1)))
for i = 1:sum(phaseData_CRAdjAmpN(2,:)>0)
    text(i+1.1, phaseData_CRProb2(2,i)+0.01, num2str(phaseData_CRAdjAmpN(2,i)), 'Color','g')
end
for i = 1:sum(phaseData_CRAdjAmpN(3,:)>0)
    text(i+7.1, phaseData_CRProb2(3,i)+0.01, num2str(phaseData_CRAdjAmpN(3,i)))
end
for i = 1:sum(phaseData_CRAdjAmpN(4,:)>0)
    text(i+11.1, phaseData_CRProb2(4,i)+0.01, num2str(phaseData_CRAdjAmpN(4,i)), 'Color', [1 0.5 0])
end
for i = 1:sum(phaseData_CRAdjAmpN(5,:)>0)
    text(i+16.1, phaseData_CRProb2(5,i)+0.01, num2str(phaseData_CRAdjAmpN(5,i)))
end
xlim([0 16.5])
ylabel('CR Prob')
xlabel('Session (blocks of 2)')
title('FEC 0.2 increase criterion')
set(gca,'TickDir','out')
set(gca,'box','off')


%% Get mean CRAmp and CRProb during trial long photostim and surrounding CS+ US periods
[srows scols] = size(sessNums);
clear scols
clear phaseData_CRAdjAmp phaseData_CRAdjAmpSTD phaseData_CRProb ...
    phaseData_CRProbSTD phaseData_CRProb2 phaseData_CRProb2STD
for p = 8:9 % 3 phases of the experiment that I want to plot
    thisPhaseIdx = sessNums(:,2)==p;
    sessNums_thisPhase = sessNums(thisPhaseIdx,:);
    [temprows tempcols] = size(sessNums_thisPhase);
    
    % store data for this phase in an array formatted like:
    %  data = [mouse 1 day 1, mouse 1 day 2, mouse 1 day 3;
    %          mouse 2 day 1, mouse 2 day 2, mouse 2 day 3;
    %          and so on];
    data_CRAdjAmp = NaN(temprows,12);
    data_CRProb = NaN(temprows,12);
    data_CRProb2 = NaN(temprows,12);
    for m = 1:2:3
        try
            dayfirst = sessNums_thisPhase(m, 3);
            daylast = sessNums_thisPhase(m, 4);
        catch ME % don't have any data for mouse 2 so this is a quick fix
            dayfirst = sessNums_thisPhase(2, 3);
            daylast = sessNums_thisPhase(2, 4);
        end
        % fix the first phase at 3 days long since one animal only had 2 days
        if p==8
            dayfirst = daylast-2;
        end
        
        session = dayfirst;
        count = 1;
        while session <= daylast && session-dayfirst<=9 % added session restriction to fix weird problem where I was getting 12 days for one of the animals
            data_CRAdjAmp(m, count) = CRAdjAmps(CRAdjAmps(:,1)==m & ...
                CRAdjAmps(:,2)==session, 3);
            data_CRProb(m, count) = CRProbs(CRProbs(:,1)==m & ...
                CRProbs(:,2)==session, 3);
            data_CRProb2(m, count) = CRProbs2(CRProbs2(:,1)==m & ...
                CRProbs2(:,2)==session, 3);
            session = session + 1;
            count = count+1;
        end
    end
    
    if temprows>1
        phaseData_CRAdjAmp(p-7,:) = nanmean(data_CRAdjAmp);
        phaseData_CRAdjAmpSTD(p-7,:)=nanstd(data_CRAdjAmp);
        phaseData_CRAdjAmpN(p-7,:)=sum(isnan(data_CRAdjAmp)==0);
        phaseData_CRProb(p-7,:) = nanmean(data_CRProb);
        phaseData_CRProbSTD(p-7,:)=nanstd(data_CRProb);
        phaseData_CRProb2(p-7,:) = nanmean(data_CRProb2);
        phaseData_CRProb2STD(p-7,:) = nanstd(data_CRProb2);
    else
        phaseData_CRAdjAmp(p-7,:) = data_CRAdjAmp;
        phaseData_CRAdjAmpSTD(p-7,:)=NaN;
        phaseData_CRAdjAmpN(p-7,:)=ones(1, length(data_CRAdjAmp));
        phaseData_CRProb(p-7,:) = data_CRProb;
        phaseData_CRProbSTD(p-7,:)=NaN;
        phaseData_CRProb2(p-7,:) = data_CRProb2;
        phaseData_CRProb2STD(p-7,:)=NaN;
    end
    clear temprows tempcols session count dayfirst daylast
end

% temporary plots to appraise data
colordef black

figure
err=[];
for erri = 1:2
    err(erri,1) = phaseData_CRAdjAmpSTD(1,erri)/...
        sqrt(phaseData_CRAdjAmpN(1,erri));
end
e=errorbar([1:2], phaseData_CRAdjAmp(1,2:3),...
    err, '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
hold on
% calc error bars
err=[];
for erri = 1:9
    err(erri,1) = phaseData_CRAdjAmpSTD(2,erri)/...
        sqrt(phaseData_CRAdjAmpN(2,erri));
end
e=errorbar([3:11], phaseData_CRAdjAmp(2,1:9),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'green';
for i = 1:2
    text(i, phaseData_CRAdjAmp(1,i+1)+0.01, num2str(phaseData_CRAdjAmpN(1,1)))
end
for i = 1:9
    text(i+2.1, phaseData_CRAdjAmp(2,i)+0.01, num2str(phaseData_CRAdjAmpN(2,i)), 'Color','g')
end
xlim([0 11.5])
ylabel('CR Amp (minus baseline)')
xlabel('Session')
title('CR Adj Amp')
set(gca,'TickDir','out')
set(gca,'box','off')
ylim([0 0.6])

%prob
figure
err=[];
for erri = 1:2
    err(erri,1) = phaseData_CRProbSTD(1,erri)/...
        sqrt(phaseData_CRAdjAmpN(1,erri));
end
e=errorbar([1:2], phaseData_CRProb(1,2:3),...
    err, '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
hold on
% calc error bars
err=[];
for erri = 1:9
    err(erri,1) = phaseData_CRProbSTD(2,erri)/...
        sqrt(phaseData_CRAdjAmpN(2,erri));
end
e=errorbar([3:11], phaseData_CRProb(2,1:9),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'green';
for i = 1:2
    text(i, phaseData_CRProb(1,i+1)+0.01, num2str(phaseData_CRAdjAmpN(1,1)))
end
for i = 1:9
    text(i+2.1, phaseData_CRProb(2,i)+0.01, num2str(phaseData_CRAdjAmpN(2,i)), 'Color','g')
end
xlim([0 11.5])
ylabel('Probability')
xlabel('Session')
title('CR Prob (0.1 FEC criterion)')
set(gca,'TickDir','out')
set(gca,'box','off')
ylim([0 1])

%prob2
figure
err=[];
for erri = 1:2
    err(erri,1) = phaseData_CRProb2STD(1,erri)/...
        sqrt(phaseData_CRAdjAmpN(1,erri));
end
e=errorbar([1:2], phaseData_CRProb2(1,2:3),...
    err, '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'white';
hold on
% calc error bars
err=[];
for erri = 1:9
    err(erri,1) = phaseData_CRProb2STD(2,erri)/...
        sqrt(phaseData_CRAdjAmpN(2,erri));
end
e=errorbar([3:11], phaseData_CRProb2(2,1:9),err(isnan(err)==0,1), '.');
e.Marker = '.';
e.MarkerSize = 10;
e.Color = 'green';
for i = 1:2
    text(i, phaseData_CRProb2(1,i+1)+0.01, num2str(phaseData_CRAdjAmpN(1,1)))
end
for i = 1:9
    text(i+2.1, phaseData_CRProb2(2,i)+0.01, num2str(phaseData_CRAdjAmpN(2,i)), 'Color','g')
end
xlim([0 11.5])
ylabel('Probability')
xlabel('Session')
title('CR Prob (0.2 FEC criterion)')
set(gca,'TickDir','out')
set(gca,'box','off')
ylim([0 1])