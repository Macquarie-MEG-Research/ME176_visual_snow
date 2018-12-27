dir_name = '/Users/44737483/Documents/new_alien_paradigm/PI176'
confile = '/Users/44737483/Documents/new_alien_paradigm/PI176/3238_JL_PI176_2018_12_11_alien_two.con'


%% CD to correct directory
disp('Going to the directory specified by dir_name')
cd(dir_name);

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
cfg.trialdef.prestim = 2.0;         % pre-stimulus interval
cfg.trialdef.poststim = 3.0;        % post-stimulus interval
cfg.trialfun                = 'mytrialfun_new_alien';
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