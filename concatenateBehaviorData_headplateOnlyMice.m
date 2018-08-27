% I think this is messed up 
% it was messed up because of directories that needed to transfer,
% transferring and then going to check again tomorrow


clear all
close all

%% tone CS animals
basedir = 'L:\users\shamanth';
savedir = 'C:\olivia\data\concat beh dat';
cd(basedir)
mice(1,1).name='OS005';
mice(2,1).name='OS006';
mice(3,1).name='OS007';
mice(4,1).name='OS008';


extdat.eyelidpos = [];
extdat.encoder_displacement = [];
extdat.c_isi = [];
extdat.c_csnum = [];
extdat.c_csdur = [];
extdat.c_usnum = [];
extdat.c_usdur = [];
extdat.type = []; % for ease of use later, let 1 = conditioning trials and 0=other
extdat.tDay = [];
extdat.group = []; % 1 is experimental and 2 is control
extdat.date = [];
extdat.mouse = [];
extdat.laserDur = [];
extdat.laserDel = [];

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
                
                extdat.eyelidpos=[extdat.eyelidpos;trials.eyelidpos];
               
                if isfield(trials,'encoder_displacement')
                    extdat.encoder_displacement = [extdat.encoder_displacement;trials.encoder_displacement];
                else
                    [rows cols] = size(trials.eyelidpos);
                    extdat.encoder_displacement = [extdat.encoder_displacement;NaN(rows,cols,'like',extdat.eyelidpos)];
                end
                
                extdat.c_isi = [extdat.c_isi;trials.c_isi];
                extdat.c_csnum = [extdat.c_csnum;trials.c_csnum];
                extdat.c_csdur = [extdat.c_csdur;trials.c_csdur];
                extdat.c_usnum = [extdat.c_usnum;trials.c_usnum];
                extdat.c_usdur = [extdat.c_usdur;trials.c_usdur];
                extdat.type = [extdat.type;strcmpi(trials.type,'Conditioning')]; % for ease of use later, let 1 = conditioning trials and 0=other
                extdat.tDay = [extdat.tDay;tDay*ones(length(trials.c_csnum),1)];
                
                thisDate = str2double(days(d).name);
                extdat.date = [extdat.date;thisDate*ones(length(trials.c_csnum),1)];
                extdat.mouse= [extdat.mouse;m*ones(length(trials.c_csnum),1)];
                
                if isfield(trials, 'laser')
                    extdat.laserDur = [extdat.laserDur;trials.laser.dur];
                    extdat.laserDel = [extdat.laserDel;trials.laser.delay];
                end
                
                %if m<=4
                    % depends on not adding more animals to the groups
                    % let group 3 be CS only extinction animals with tone
                    % CS
                    grouptemp = 3;
                %else
                    %grouptemp = 2;
                %end
                extdat.group = [extdat.group; grouptemp*ones(length(trials.c_csnum),1)];
                
                tDay = tDay + 1;
            end
        end
        
        
    end
    
    timeVector = trials.tm(1,:);
end


%% light CS animals
basedir = 'L:\users\okim\behavior';

mice(1,1).name = 'OK001'; % dim LED CS, CS only extinction
mice(2,1).name = 'OK002'; % dim LED CS, CS only extinction
mice(3,1).name = 'OK003'; % dim LED CS, CS only extinction
mice(4,1).name = 'OK004'; % dim LED CS, CS only extinction
mice(5,1).name = 'OK005'; % bright LED CS, CS only extinction
mice(6,1).name = 'OK006'; % bright LED CS, CS only extinction
mice(7,1).name = 'OK007'; % bright LED CS, CS only extinction
mice(8,1).name = 'OK008'; % bright LED CS, CS only extinction
mice(9,1).name = 'S146'; % bright LED CS, unpaired extinction
mice(10,1).name = 'S147'; % bright LED CS, unpaired extinction
mice(11,1).name = 'S148'; % bright LED CS, unpaired extinction
mice(12,1).name = 'S149'; % bright LED CS, unpaired extinction

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
                
                extdat.eyelidpos=[extdat.eyelidpos;trials.eyelidpos];
               
                if isfield(trials,'encoder_displacement')
                    extdat.encoder_displacement = [extdat.encoder_displacement;trials.encoder_displacement];
                else
                    [rows cols] = size(trials.eyelidpos);
                    extdat.encoder_displacement = [extdat.encoder_displacement;NaN(rows,cols,'like',extdat.eyelidpos)];
                end
                
                extdat.c_isi = [extdat.c_isi;trials.c_isi];
                extdat.c_csnum = [extdat.c_csnum;trials.c_csnum];
                extdat.c_csdur = [extdat.c_csdur;trials.c_csdur];
                extdat.c_usnum = [extdat.c_usnum;trials.c_usnum];
                extdat.c_usdur = [extdat.c_usdur;trials.c_usdur];
                extdat.type = [extdat.type;strcmpi(trials.type,'Conditioning')]; % for ease of use later, let 1 = conditioning trials and 0=other
                extdat.tDay = [extdat.tDay;tDay*ones(length(trials.c_csnum),1)];
                
                thisDate = str2double(days(d).name);
                extdat.date = [extdat.date;thisDate*ones(length(trials.c_csnum),1)];
                extdat.mouse= [extdat.mouse;(m+4)*ones(length(trials.c_csnum),1)];
                
                if isfield(trials, 'laser')
                    extdat.laserDur = [extdat.laserDur;trials.laser.dur];
                    extdat.laserDel = [extdat.laserDel;trials.laser.delay];
                end
                
                if m<=4
                    % depends on not adding more animals to the groups
                    % let group 4 be CS only extinction animals with dim
                    % LED CS
                    grouptemp = 4;
                elseif m<=8
                    % let group 5 be CS only extinction animals with bright LED CS 
                    grouptemp = 5;
                else
                    % let group 6 be explicitly unpaired extinction animals
                    % with bright LED CS
                    grouptemp = 6;
                end
                extdat.group = [extdat.group; grouptemp*ones(length(trials.c_csnum),1)];
                
                tDay = tDay + 1;
            end
        end
        
        
    end
    
    timeVector = trials.tm(1,:);
end

cd(savedir)

tempstr = date;
correctFormatDate = reformatDate(tempstr);
filename = strcat(correctFormatDate,'_WTExtExpt_allAnimBehData.mat');
save(filename, 'extdat')

filename = strcat(correctFormatDate,'_WTExtExpt_timeVector.mat');
save(filename, 'timeVector')