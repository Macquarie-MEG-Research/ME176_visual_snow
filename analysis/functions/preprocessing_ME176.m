function preprocessing_ME176(dir_name, confile,subject,subj_info)

disp('Running Preprocessing Script for Project ME176 - Alien Task');

pd = mq_find_subj(subj_info,subject,'pd');

if strcmp(pd,'photodetector')
    pd_chan = mq_find_subj(subj_info,subject,'pd_chan');
end

%% CD to correct directory
disp('Going to the directory specified by dir_name')
cd(dir_name);

if strcmp(mq_find_subj(subj_info,subject,'tSSS'),'yes')
    disp('Loading tSSS .fif file');
    confile_tsss = [confile(1:end-4) '_raw_tsss.fif'];
    
    cfg = [];
    cfg.headerfile = confile_tsss;
    cfg.datafile = confile_tsss;
    cfg.trialdef.triallength = Inf;
    cfg.trialdef.ntrials = 1;
    cfg = ft_definetrial(cfg)
    
    cfg.continuous = 'yes';
    alldata_tsss = ft_preprocessing(cfg);
end

%% Epoching & Filtering
% Epoch the whole dataset into one continous dataset and apply
% the appropriate filters
cfg = [];
cfg.headerfile = confile;
cfg.datafile = confile;
cfg.trialdef.triallength = Inf;
cfg.trialdef.ntrials = 1;
cfg = ft_definetrial(cfg)

cfg.continuous = 'yes';
alldata = ft_preprocessing(cfg);

% Replace data with tSSS data if specified
if strcmp(mq_find_subj(subj_info,subject,'tSSS'),'yes')
    alldata.trial{1,1}(1:160,:) = alldata_tsss.trial{1,1}(1:160,:);
end

cfg.continuous = 'yes';
cfg.bpfilter = 'yes';
cfg.bpfreq = [0.5 250];
alldata = ft_preprocessing(cfg);

% Deal with 50Hz line noise
cfg = [];
cfg.bsfilter = 'yes';
cfg.bsfreq = [49.5 50.5];
alldata = ft_preprocessing(cfg,alldata);

% Deal with 100Hz line noise
cfg = [];
cfg.bsfilter = 'yes';
cfg.bsfreq = [99.5 100.5];
alldata = ft_preprocessing(cfg,alldata);

% Create layout file for later + save
cfg             = [];
cfg.grad        = alldata.grad;
lay             = ft_prepare_layout(cfg, alldata);
save lay lay

% Cut out other channels(?)
cfg = [];
cfg.channel = alldata.label(1:160);
alldata = ft_selectdata(cfg,alldata);

% Define trials using custom trialfun
cfg = [];
cfg.dataset                 = confile;
cfg.continuous              = 'yes';
% If photodector present, use this to correct
if strcmp(pd,'photodetector')
    cfg.how_correct             = 'photodetector';
    cfg.pd_chan                 = pd_chan;
    % Otherwise use constant delay
else
    cfg.how_correct             = 'constant';
end

cfg.trialdef.prestim = 3.5;         % pre-stimulus interval
cfg.trialdef.poststim = 3.0;        % post-stimulus interval
cfg.trialfun                = 'ME176_photodetector';
data_raw 			    = ft_definetrial(cfg);

% Redefines the filtered data
cfg = [];
data = ft_redefinetrial(data_raw,alldata);

% Detrend and demean each trial
cfg = [];
cfg.demean = 'yes';
cfg.detrend = 'yes';
data = ft_preprocessing(cfg,data)

%% Downsample the data
cfg = [];
cfg.resamplefs = 300;
cfg.detrend = 'no';
data_clean_150 = ft_resampledata(cfg,data);

%% Select 'trials' timelocked to the grating onset
disp('Selecting Grating Trials');
grating_trials = (find(data.trialinfo == 181));
cfg = [];
cfg.trials = grating_trials;
grating = ft_redefinetrial(cfg,data_clean_150); %redefines the data

grating.trialnum = [1:1:length(grating_trials)]';

if length(grating_trials) ~= 120
    ft_warning('Incorrect number of grating trials?');
end

% cfg = [];
% cfg.viewmode = 'vertical';
% ft_databrowser(cfg,grating)

% Load the summary again so you can manually remove any deviant trials
cfg = [];
cfg.method = 'summary';
cfg.keepchannel = 'yes';
grating = ft_rejectvisual(cfg, grating);

disp('Saving...');
save grating grating
clear grating_trials

disp('Selecting Alien Trials');
alien_ast_trials = (find(data.trialinfo == 183));

if length(alien_ast_trials) ~= 120
    ft_warning('Incorrect number of grating trials?');
end

cfg = [];
cfg.trials = alien_ast_trials;
alien_ast = ft_redefinetrial(cfg,data_clean_150); %redefines the data

% Reject the same trials as for the grating
alien_ast.trialnum = [1:1:length(alien_ast_trials)]';

cfg = [];
cfg.trials = grating.trialnum;
alien_ast = ft_selectdata(cfg,alien_ast); %redefines the data

disp('Saving...');
save alien_ast alien_ast
clear alien_ast_trials

end

