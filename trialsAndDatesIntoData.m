function [output] = trialsAndDatesIntoData(datespreadsheet_headers, datespreadsheet_dates, dayData, phase)
[rows cols] = size(datespreadsheet_dates);
output.crprob.data = nan(9,18);
output.cradjamp.data = nan(9,18);
output.cradjampHit.data=nan(9,18);
output.uramp.data = nan(9,18);
output.missuramp.data = nan(9,18);
output.hituramp.data = nan(9,18);
output.urint.data=nan(9,18);
output.missurint.data=nan(9,18);
output.hiturint.data=nan(9,18);
output.eyelidpos.sem=nan(18,1800);
output.eyelidpos.mean=nan(18,1800);
output.eyelidpos.hitmean=nan(18,1800);
output.eyelidpos.missmean=nan(18,1800);

% the different rows of the date spreadsheet specify the different days of
% each phase. that is, there is one row for the "during" phase of the
% manipulation for each animal, one row for the "after" phase, etc. each
% column corresponds to a different day of the phase specified in the row
% label in column 2 of the spreadsheet
idx = find(strcmpi(phase, datespreadsheet_headers(:,2)));
for i = 1:length(idx)
    r = idx(i);
    for c = 3:cols % start at col 3 because rows 1-2 is just headers
        thisDay = datespreadsheet_dates{r,c};
        thisMouse = datespreadsheet_dates{r,1};
        mouse = 0;
        eyelidposCol = 1;
        %try
        % this if statement is here since I want to have different CR
        % criterion for OK138 since he had a big startle/SLR
        if ~ischar(thisDay) && ~isnan(thisDay) % skip days without numbers
            if strcmpi(thisMouse,'OK135')
                mouse=1;
                eyelidposCol = 1;
            elseif strcmpi(thisMouse,'OK137')
                mouse=2;
                eyelidposCol = 201;
            elseif strcmpi(thisMouse,'OK138')
                mouse=3;
                eyelidposCol = 401;
            elseif strcmpi(thisMouse,'OK134')
                mouse=4;
                eyelidposCol = 601;
            elseif strcmpi(thisMouse,'OK159')
                mouse=5;
                eyelidposCol = 801;
            elseif strcmpi(thisMouse,'OK160')
                mouse=6;
                eyelidposCol = 1001;
            elseif strcmpi(thisMouse,'OK148')
                mouse=7;
                eyelidposCol = 1201;
            elseif strcmpi(thisMouse,'OK161')
                mouse=8;
                eyelidposCol = 1401;
            elseif strcmpi(thisMouse,'OK162')
                mouse=9;
                eyelidposCol = 1601;
            end
            crprob = dayData.CRProb(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
            missuramp = dayData.meanMissURAmp(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
            hituramp = dayData.meanHitURAmp(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
            missurint = dayData.meanMissURIntegral(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
            hiturint = dayData.meanHitURIntegral(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
            output.eyelidpos.hitmean(c-2,eyelidposCol:eyelidposCol+199) = ...
                dayData.meanHitEyelidTrace(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1:200);
            output.eyelidpos.missmean(c-2,eyelidposCol:eyelidposCol+199) = ...
                dayData.meanMissEyelidTrace(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1:200);
            
            
            cradjampAll = dayData.meanCRAdjAmp(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
            cradjampHit = dayData.hitCRAdjAmp(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
            uramp = dayData.meanURAmp(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
            urint = dayData.meanURIntegral(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1);
            
            output.crprob.data(mouse,c-2) = crprob;
            output.cradjamp.data(mouse,c-2) = cradjampAll;
            output.cradjampHit.data(mouse,c-2) = cradjampHit;
            output.uramp.data(mouse,c-2)=uramp;
            output.missuramp.data(mouse,c-2)=missuramp;
            output.hituramp.data(mouse,c-2)=hituramp;
            output.missurint.data(mouse,c-2)=missurint;
            output.hiturint.data(mouse,c-2)=hiturint;
            output.urint.data(mouse,c-2)=urint;
            
            output.eyelidpos.mean(c-2,eyelidposCol:eyelidposCol+199) = ...
                dayData.meanEyelidTrace(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1:200);
            output.eyelidpos.sem(c-2,eyelidposCol:eyelidposCol+199) = ...
                dayData.semEyelidTrace(dayData.date(:,1)==thisDay & dayData.mouse(:,1)==mouse,1:200);
            
            
            
            clear crprob cradjampAll uramp mouse thisDay thisMouse thisPhase
        end
    end
end
