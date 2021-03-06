

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


rbdat.eyelidpos = [];
rbdat.baseline = [];
rbdat.baselineMvt = [];
rbdat.encoder_displacement = [];
rbdat.c_isi = [];
rbdat.c_csnum = [];
rbdat.c_csdur = [];
rbdat.c_usnum = [];
rbdat.c_usdur = [];
rbdat.type = []; % for ease of use later, let 1 = conditioning trials and 0=other
rbdat.tDay = [];
rbdat.group = []; % 1 is experimental and 2 is control
rbdat.date = [];
rbdat.mouse = [];
rbdat.laserDur = [];
rbdat.laserDel = [];
rbdat.mvtlatency = [];

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
                
                rbdat.eyelidpos=[rbdat.eyelidpos;trials.eyelidpos];
                
                
                baselines = nan(length(trials.c_csdur),1);
                baselineMvt = zeros(length(trials.c_csdur),1);
                latencies = nan(length(trials.c_csdur),1);
                for t = 1:length(trials.c_usdur)
                    baselines(t,1)=mean(trials.eyelidpos(t,1:39));
                    deviations = trials.eyelidpos(t,1:39)-baselines(t,1);
                    if abs(max(deviations))>=0.1
                        baselineMvt(t,1) = 1;
                    end
                    latencies(t,1) = latencyIntersecOfSlopes(trials.eyelidpos(t,:), trials.tm(t,:), baselines(t,1));
                end
                
                rbdat.baseline = [rbdat.baseline; baselines];
                rbdat.baselineMvt = [rbdat.baselineMvt; baselineMvt];
                rbdat.mvtlatency = [rbdat.mvtlatency; latencies];
               
                if isfield(trials,'encoder_displacement')
                    rbdat.encoder_displacement = [rbdat.encoder_displacement;trials.encoder_displacement];
                else
                    [rows cols] = size(trials.eyelidpos);
                    rbdat.encoder_displacement = [rbdat.encoder_displacement;NaN(rows,cols,'like',rbdat.eyelidpos)];
                end
                
                rbdat.c_isi = [rbdat.c_isi;trials.c_isi];
                rbdat.c_csnum = [rbdat.c_csnum;trials.c_csnum];
                rbdat.c_csdur = [rbdat.c_csdur;trials.c_csdur];
                rbdat.c_usnum = [rbdat.c_usnum;trials.c_usnum];
                rbdat.c_usdur = [rbdat.c_usdur;trials.c_usdur];
                rbdat.type = [rbdat.type;strcmpi(trials.type,'Conditioning')]; % for ease of use later, let 1 = conditioning trials and 0=other
                rbdat.tDay = [rbdat.tDay;tDay*ones(length(trials.c_csnum),1)];
                
                thisDate = str2double(days(d).name);
                rbdat.date = [rbdat.date;thisDate*ones(length(trials.c_csnum),1)];
                rbdat.mouse= [rbdat.mouse;m*ones(length(trials.c_csnum),1)];
                
                rbdat.laserDur = [rbdat.laserDur;trials.laser.dur];
                rbdat.laserDel = [rbdat.laserDel;trials.laser.delay];
                
                if m <=4
                    % depends on not adding more animals to the groups
                    % let group 1 be experimental and group 2 be control
                    grouptemp = 1;
                else
                    grouptemp = 2;
                end
                rbdat.group = [rbdat.group; grouptemp*ones(length(trials.c_csnum),1)];
                
                tDay = tDay + 1;
            end
        end
        
        
    end
    
    timeVector = trials.tm(1,:);
end

cd(savedir)

tempstr = date;
correctFormatDate = reformatDate(tempstr);
filename = strcat(correctFormatDate,'_DCNChR2ExtExpt_allAnimBehData.mat');
save(filename, 'rbdat')

filename = strcat(correctFormatDate,'_DCNChR2ExtExpt_timeVector.mat');
save(filename, 'timeVector')