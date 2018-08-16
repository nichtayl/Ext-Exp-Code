clear all
close all

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
                    % let group 3 be CS only extinction animals
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

cd(savedir)

tempstr = date;
correctFormatDate = reformatDate(tempstr);
filename = strcat(correctFormatDate,'_WTExtExpt_allAnimBehData.mat');
save(filename, 'extdat')

filename = strcat(correctFormatDate,'_WTExtExpt_timeVector.mat');
save(filename, 'timeVector')