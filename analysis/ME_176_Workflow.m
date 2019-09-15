%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ME176 Workflow to Analyse the Visual Alien Data
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
save_path   = ['/Volumes/Robert T5/ME176_data_preprocessed/'];

% Path to where you want to save the group-level results
group_dir = '/Users/rseymoue/Dropbox/Research/Projects/visual_snow2019/';

% Path to MQ_MEG_Scripts
% Download from https://github.com/Macquarie-MEG-Research/MQ_MEG_Scripts
path_to_MQ_MEG_Scripts = ['/Users/rseymoue/Documents/GitHub/MQ_MEG_Scripts/'];

% Path to MEMES
% Download from https://github.com/Macquarie-MEG-Research/MEMES
path_to_MEMES = ['/Users/rseymoue/Documents/GitHub/MEMES/'];

% Path to MRI L:ibrary for MEMES
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
subject = {'3317','3321','3323','3324','3326','3331','3332',...
    '3350','3354','3376','3492','3120'};

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5. Calculate Saturations, downsample headshape, realign sensors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Downsamping headshape & realigning sensors');

% For every subject...
for sub = 1:length(subject)
    
    close all
    
    confile = [data_path 'sub-' subject{sub} '/ses-1/meg/sub-' subject{sub}...
        '_ses-1_task-alien_run-1_meg.con'];
    
    mrkfile = [data_path 'sub-' subject{sub}...
        '/ses-1/meg/sub-' subject{sub} '_ses-1_task-alien_run-1_markers.mrk'];
    
    elpfile = dir([data_path 'sub-' subject{sub}...
        '/ses-1/extras/*.elp']);
    elpfile = [elpfile.folder '/' elpfile.name];
    
    hspfile = dir([data_path 'sub-' subject{sub}...
        '/ses-1/extras/*.hsp']);
    hspfile = [hspfile.folder '/' hspfile.name];

    % Get the path to the saving directory
    dir_name = [save_path subject{sub}];
    cd(dir_name);
    
    %%%%%%%%%%%%%%%%%%%%%%%
    % Check for saturations
    %%%%%%%%%%%%%%%%%%%%%%%
    [sat] = mq_detect_saturations(dir_name,confile)
    save sat sat
    
    %%%%%%%%%%%%%%%%%%%%%%
    % Downsample headshape
    %%%%%%%%%%%%%%%%%%%%%%
    headshape_downsampled = downsample_headshape(hspfile,'yes',2);
    %headshape_downsampled = add_facial_info(headshape_downsampled);
    
    figure; ft_plot_headshape(headshape_downsampled);
    
    % Save
    cd(dir_name); 
    disp('Saving headshape_downsampled');
    save headshape_downsampled headshape_downsampled;

    %%%%%%%%%%%%%%%%%
    % Realign Sensors
    %%%%%%%%%%%%%%%%%
    [grad_trans] = mq_realign_sens(dir_name,elpfile,hspfile,...
        confile,mrkfile,'','rot3dfit');
    
    print('grad_trans','-dpng','-r200');
    
    %clear headshape_downsampled grad_trans 
    %close all
end


%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6. MEMES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Performing MEMES');

% For every subject...
for sub = 1:length(subject)
    % Get the path to the saving directory
    dir_name = [save_path subject{sub}];
    cd(dir_name)
    
    % Load grad_trans and headshape_downsampled
    disp('Loading grad_trans and headshape_downsampled');
    
    load('grad_trans');
    load('headshape_downsampled');
    
    MEMES3(dir_name,grad_trans,headshape_downsampled,...
        path_to_MRI_library,'average',1);
    
    close all
end


%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 7. Preprocessing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for sub = 1:length(subject)
   confile = [data_path 'sub-' subject{sub} '/ses-1/meg/sub-' subject{sub}...
        '_ses-1_task-alien_run-1_meg.con'];
    
        % Get the path to the saving directory
    dir_name = [save_path subject{sub}];
    cd(dir_name);
    
    preprocessing_ME176(dir_name, confile);
    
    close all force
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 8. Remove Saturated Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Remove saturated data
for sub = 1:length(subject)
    fprintf('Subject %s - processing\n',subject{sub});
    dir_name = [save_path subject{sub}];
    cd(dir_name);
    
    bad_sens = mq_find_subj(subj_info,subject{sub},'sat_sens_to_remove');
    
    if ~isnan(bad_sens)
        
        load('grating.mat');
        load('sat.mat');
        
        bad_sens_cell = strsplit(bad_sens,', ');
        
        [grating] = mq_remove_sat(grating,sat,bad_sens_cell,'yes');
        
        disp('Saving data');
        save grating grating
    end
    
end

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 9. Sensor-Level TFR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for sub = 1:length(subject)
    dir_name = [save_path subject{sub}];
    cd(dir_name);
    sensor_level_tfr_ME176(dir_name);
    close all force
end

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 10. Whole-Brain Source Analysis (LCMV)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Performing Single Subject Source Analysis');

% Load template sourcemodel (8mm)
load(['/Users/rseymoue/Documents/GitHub/fieldtrip/template/'...
    'sourcemodel/standard_sourcemodel3d8mm.mat']);
template_grid = sourcemodel;
template_grid = ft_convert_units(template_grid,'mm');
clear sourcemodel;

% Load the SPM T1 brain
mri = ft_read_mri(['/Users/rseymoue/Documents/GitHub/fieldtrip/'...
    'template/anatomy/single_subj_T1.nii']);

atlas = ft_read_atlas(['/Users/rseymoue/Documents/GitHub/fieldtrip/'...
    'template/atlas/aal/ROI_MNI_V4.nii']);
atlas = ft_convert_units(atlas,'mm');

for sub = 1:length(subject)
    dir_name = [save_path subject{sub}];
    cd(dir_name);
    source_localisation_gamma_ME176(dir_name,mri,template_grid,atlas);
end

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 11. Plot Grand Average Results from Virtual Electrode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot_VE_gamma(subject,save_path,group_dir,group)   
    
    
