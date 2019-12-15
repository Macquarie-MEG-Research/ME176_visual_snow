%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ME176 Workflow to Analyse the Resting-State Data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Set up paths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

script_path = ['/Users/rseymoue/Documents/GitHub/ME176_visual_snow'];

% Path to the raw data
data_path   = ['/Volumes/Robert T5/BIDS/BIDS-2019-19/ME176/'];

% Path to where the data should be saved
save_path   = ['/Volumes/Robert T5/ME176_data_preprocessed_rs/'];

% Path to where you want to save the group-level results
group_dir = '/Users/rseymoue/Dropbox/Research/Projects/visual_snow2019/';

% Path to MQ_MEG_Scripts
% Download from https://github.com/Macquarie-MEG-Research/MQ_MEG_Scripts
path_to_MQ_MEG_Scripts = ['/Users/rseymoue/Documents/GitHub/MQ_MEG_Scripts/'];

% Path to MEMES
% Download from https://github.com/Macquarie-MEG-Research/MEMES
path_to_MEMES = ['/Users/rseymoue/Documents/GitHub/MEMES/'];

% Path to MRI Library for MEMES
path_to_MRI_library = '/Volumes/Robert T5/new_HCP_library_for_MEMES/';
    
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Add MQ_MEG_Scripts and MEMES to path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Adding MQ_MEG_Scripts and MEMES to your MATLAB path');
warning(['Please note that MQ_MEG_Scripts and MEMES are designed for'...
    ' MATLAB 2016b or later and have been tested using Fieldtrip'...
    ' version 20181213']);
addpath(genpath(path_to_MQ_MEG_Scripts));
addpath(genpath(path_to_MEMES));
addpath(genpath(script_path));

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Load Subject List
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subject_VS = {'3120','3317','3321','3323','3324','3326','3350','3351',...
    '3354','3376','3492','3567','3568','3569','3592','3593','3595','3605',...
    '3606','3626'};

subject_control = {'3565','3566','3588','3589','3610','3611','3627',...
    '3630','3633','3655','3658','3659'};

subject = {'3653','3655','3658','3659'};

% Load subject information from excel file
subj_info = csv2struct([data_path 'subject_info_ME176.xlsx']);

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Make a subject specific results folder for saving
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Making subject specific folders for saving');
for sub = 1:length(subject)
    % Get the path to the saving directory
    dir_name = [save_path subject{sub}];
    % Make the directory!
    mkdir(dir_name);
end

%%

pWelch_VS = [];
count = 1;

for sub = 1:length(subject_VS)
    try
        
        confile = [data_path 'sub-' subject_VS{sub} '/ses-1/meg/sub-' subject_VS{sub}...
            '_ses-1_task-resting_run-1_meg.con'];
        
        % Get the path to the saving directory
        dir_name = [save_path subject_VS{sub}];
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
        cfg.trialdef.prestim = 0;         % pre-stimulus interval
        cfg.trialdef.poststim = 300.0;        % post-stimulus interval
        cfg.trialfun                = 'mytrialfun_rs_mq';
        data_raw 			    = ft_definetrial(cfg);
        
        % Redefines the filtered data
        cfg = [];
        data = ft_redefinetrial(data_raw,alldata);
        
        %% Calculate pWelch
        [pxx,f] = pwelch(data.trial{1,1}',3000,1500,3000,1000);
        
        figure; plot(f(3:140),log10(mean(pxx(3:140,:),2)));
        
        pWelch_VS(count,:) = mean(pxx(3:140,:),2);
        
        count = count+1;
    catch
        fprintf('Subject %s could not be processed\n', subject_VS{sub});
    end
    
end




pWelch_control = [];
count = 1;

for sub = 1:length(subject_control)
    try
        
        confile = [data_path 'sub-' subject_control{sub} '/ses-1/meg/sub-' subject_control{sub}...
            '_ses-1_task-resting_run-1_meg.con'];
        
        % Get the path to the saving directory
        dir_name = [save_path subject_control{sub}];
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
        cfg.trialdef.prestim = 0;         % pre-stimulus interval
        cfg.trialdef.poststim = 300.0;        % post-stimulus interval
        cfg.trialfun                = 'mytrialfun_rs_mq';
        data_raw 			    = ft_definetrial(cfg);
        
        % Redefines the filtered data
        cfg = [];
        data = ft_redefinetrial(data_raw,alldata);
        
        %% Calculate pWelch
        [pxx,f] = pwelch(data.trial{1,1}',3000,1500,3000,1000);
        
        figure; plot(f(3:140),log10(mean(pxx(3:140,:),2)));
        
        pWelch_control(count,:) = mean(pxx(3:140,:),2);
        
        count = count+1;
    catch
        fprintf('subject_control %s could not be processed\n', subject_control{sub});
    end
    
end


cd(group_dir);
cols = [0 0.3255 0.5020; 0.8000 0.2745 0.0784];

% Plot average
[mean_VS, CI_VS] = mq_get_confidence(log10(pWelch_VS(:,1:89)));
[mean_control, CI_control] = mq_get_confidence(log10(pWelch_control(:,1:89)));

figure;
boundedline(f(3:91), mean_VS, CI_VS(2,:),f(3:91), mean_control,...
    CI_control(2,:),'cmap',cols,'alpha');
%ylim([-50 40]);
%xlim([0 30]);
set(gca,'FontSize',20);
ylabel('Power (dB)','FontSize',25);
xlabel('Frequency (Hz)','FontSize',25);
legend({'Visual Snow','Control'});
print('resting_state_power','-dpng','-r300');







