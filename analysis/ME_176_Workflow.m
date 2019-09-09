%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ME176 Workflow to Analyse the Visual Alien Data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('/Users/44737483/Documents/ME176_visual_snow/analysis');
addpath(genpath('/Users/44737483/Documents/scripts_mcq/MQ_MEG_Scripts'));
addpath(genpath('/Users/44737483/Documents/scripts_mcq/MEMES'));

%% Preprocessing
dir_name = '/Users/44737483/Documents/ME176_visual_snow/raw_data/3376'
confile = [dir_name '/3376_HJ_ME174_2019_06_07_aliens.con'];
elpfile = [dir_name '/3376_HJ_ME174_2019_06_07.elp'];
hspfile = [dir_name '/3376_HJ_ME174_2019_06_07.hsp'];
confile = [dir_name '/3376_HJ_ME174_2019_06_07_aliens.con'];
mrkfile = [dir_name '/3376_HJ_ME174_2019_06_07_aliens_PRE.mrk'];

bad_coil = '';

%%
preprocessing_ME176

%% Sensory Realign

[grad_trans] = mq_realign_sens(dir_name, elpfile, hspfile, confile,...
    mrkfile, bad_coil,'rot3dfit');

%% Downsample Headshape
headshape_downsampled = downsample_headshape(hspfile, 'yes');
save headshape_downsampled headshape_downsampled

%% TFR
sensor_level_tfr_ME176(dir_name)

%% MEMES

path_to_MRI_library = ['/Users/44737483/Documents/scripts_mcq/'...
    'new_HCP_library_for_MEMES/'];

MEMES3(dir_name,grad_trans,headshape_downsampled,...
    path_to_MRI_library,'average',[0.98:0.01:1.02])

%% Gamma Source Analysis
source_localisation_gamma_ME176(dir_name)
