function trials=processTrials_fromShogoRig(folder,calib)
% TRIALS=processConditioningTrials(FOLDER,CALIB,{MAXFRAMES})
% Return trials structure containing eyelid data and trial parameters for all trials in a session
% Specify either filename of trial to use for calibration or "calib" structure containing pre-calculated scale and offset.
% Optionally, specify threshold for binary image and maximum number of video frames per trial to use for extracting eyelid trace

% Error checking
if isstruct(calib)
	if ~isfield(calib,'scale') || ~isfield(calib,'offset')
		error('You must specify a valid calibration structure or file from which the structure can be computed')
	end
elseif exist(calib,'file')
	[data,metadata]=loadCompressed(calib);
	if ~exist('thresh')
		thresh=metadata.cam.thresh;
	end
	[y,t]=vid2eyetrace(data,metadata,thresh,5);
	calib=getcalib(y);
else
	error('You must specify a valid calibration structure or file from which the structure can be computed')
end

% By now we should have a valid calib structure to use for calibrating all files

if ~exist(folder,'dir')
	error('The directory you specified (%s) does not exist',folder);
end

% Get our directory listing, assuming the only AVI files containined in the directory are the trials
% Later we will sort out those that aren't type='conditioning' based on metadata
fnames=getFullFileNames(folder,dir(fullfile(folder,'*.avi')));
%fnames=getFullFileNames(folder,dir(fullfile(folder,'*.mp4')));

% Preallocate variables so we can use parfor loop to process the files
eyelidpos=cell(length(fnames),1);	% We have to use a cell array because trials may have different lengths
tm=cell(length(fnames),1);			% Same for time

c_isi=NaN(length(fnames),1);
c_csnum=NaN(length(fnames),1);
c_csdur=NaN(length(fnames),1);
c_csintensity=NaN(length(fnames),1);
c_usnum=NaN(length(fnames),1);
c_usdur=NaN(length(fnames),1);

trialnum=zeros(length(fnames),1);
ttype=cell(length(fnames),1);

laserdelay=zeros(length(fnames),1);
laserdur=zeros(length(fnames),1);
laseramp=zeros(length(fnames),1);
laserfreq=zeros(length(fnames),1);
laserpulsewidth=zeros(length(fnames),1);

numframes=zeros(length(fnames),1);

% Use a parallel for loop to speed things up
% if matlabpool('size') == 0
%     matlabpool open	% Start a parallel computing pool using default number of labs (usually 4-8).
% %     cleaner = onCleanup(@() matlabpool('close'));
% end

disp('just before fnames loop')
for i=1:length(fnames)
    disp('got into fnames loop')
	[p,basename,ext]=fileparts(fnames{i});

    try
        [data,metadata]=loadCompressed(fnames{i});
    catch
        disp(sprintf('Problem with file %s', fnames{i}))
    end
    
    [eyelidpos{i},tm{i}]=vid2eyetrace(data,metadata,thresh,5,calib);

	c_isi(i)=metadata.stim.c.isi;
%     if metadata.cam.trialnum <=19
%         c_csnum(i)=0;
%         c_csdur(i)=0;
%         c_csintensity(i)=0;
%     else
        c_csnum(i)=metadata.stim.c.csnum;
        c_csdur(i)=metadata.stim.c.csdur;
        %c_csintensity(i)=metadata.stim.c.csint;
%    end
	c_usnum(i)=metadata.stim.c.usnum;
	c_usdur(i)=metadata.stim.c.usdur;
    
    laserdelay(i)=metadata.stim.l.delay;
    laserdur(i)=metadata.stim.l.traindur;
    laseramp(i)=metadata.stim.l.amp;
    laserfreq(i)=metadata.stim.l.freq;
    laserpulsewidth(i)=metadata.stim.l.pulsewidth;
    
	
	trialnum(i)=metadata.cam.trialnum;
	ttype{i}=metadata.stim.type;

	numframes(i)=length(eyelidpos{i});

	fprintf('Processed file %s\n',basename)
	
end


disp('Done reading data')

% matlabpool close

% if length(varargin) > 1
% 	MAXFRAMES=varargin{2};
% else
	MAXFRAMES=max(numframes);
% end

% Now that we know how long each trial is turn the cell arrays into matrices

traces=NaN(length(fnames),MAXFRAMES);
times=NaN(length(fnames),MAXFRAMES);
try
	for i=1:length(fnames) 
		trace=eyelidpos{i}; 
		t=tm{i}; 
		en=length(trace); 
		if en > MAXFRAMES
			en=MAXFRAMES; 
		end 
		traces(i,1:en)=trace(1:en); 
		times(i,1:en)=t(1:en); 
	end
catch
    disp(i)
end

% % We read the encoder data in a separate loop once we have all of the eyelid data
% encoder_displacement = NaN(size(traces));
% encoder_counts = NaN(size(traces));
% 
% encoder_filelist=getFullFileNames(folder,dir(fullfile(folder, '*encoder*.mat')));
% 
% for i=1:length(encoder_filelist)
%     d=load(encoder_filelist{i});
%     
%     trialnum_match=regexp(encoder_filelist{i},'_s?\d\d[a-d]?_(\d\d\d)','tokens','once');
%     if ~isempty(trialnum_match)
%         encoder_trialnum = str2double(trialnum_match{1});
%     else
%         encoder_trialnum = 0;
%         warning('Could not extract trial number from %s',encoder_filelist{i});
%     end
%     
%     current_trial_idx = find(trialnum == encoder_trialnum & strcmp(ttype,'Conditioning'));
%     if isempty(current_trial_idx)
%         continue
%     end
%     
%     % Interpolate encoder data to have same time base as eyelid
% 	% Encoder times start at 0 (when camera starts) but trial times start at -pretime so we have to correct for this
%     enc_tm = (d.encoder.time)./1e3 + times(current_trial_idx,1); % add don't subtract bc pretime is negative
%     enc_disp = interp1(enc_tm,d.encoder.displacement,times(current_trial_idx,:),'spline');
%     enc_cnt = interp1(enc_tm,d.encoder.counts,times(current_trial_idx,:),'spline');
%     
%     encoder_displacement(current_trial_idx,:) = enc_disp;
%     encoder_counts(current_trial_idx,:) = enc_cnt;
%     
% end
% 
% trials.encoder_displacement = encoder_displacement;
% trials.encoder_counts = encoder_counts;


%session_of_day = cellfun(@str2double, sess_cell);
%session_of_day = ones(100, 1);

trials.eyelidpos=traces;
trials.tm=times;
trials.fnames=fnames;

trials.c_isi=c_isi;
trials.c_csnum=c_csnum;
trials.c_csdur=c_csdur;
trials.c_csintensity=c_csintensity;
trials.c_usnum=c_usnum;
trials.c_usdur=c_usdur;

trials.laser.delay=laserdelay;
trials.laser.dur=laserdur;
trials.laser.amp=laseramp;
trials.laser.freq=laserfreq;
trials.laser.pulsewidth=laserpulsewidth;

trials.trialnum=trialnum;
trials.type=ttype;
trials.filename=fnames;