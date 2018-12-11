%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ME176 Workflow to Analyse the Visual Alien Data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('/Users/44737483/Documents/ME176_visual_snow/analysis');

%% Preprocessing
dir_name = '/Users/44737483/Documents/new_alien_paradigm/PI176'
confile = '/Users/44737483/Documents/new_alien_paradigm/PI176/3238_JL_PI176_2018_12_11_alien.con';

preprocessing_ME176(dir_name, confile)

%% TFR
sensor_level_tfr_ME176(dir_name)

%% MEMES

dir_name = '/Users/44737483/Documents/new_alien_paradigm/PI176';
elpfile = '/Users/44737483/Documents/new_alien_paradigm/PI176/3238_JL_PI176_2018_12_11.elp';
hspfile = '/Users/44737483/Documents/new_alien_paradigm/PI176/3238_JL_PI176_2018_12_11.hsp';
confile = '/Users/44737483/Documents/new_alien_paradigm/PI176/3238_JL_PI176_2018_12_11_alien.con';
mrkfile = '/Users/44737483/Documents/new_alien_paradigm/PI176/3238_JL_PI176_2018_12_11_alien_PRE.mrk';
addpath(genpath('/Users/44737483/Documents/scripts_mcq/MEMES'));
path_to_MRI_library = '/Users/44737483/Documents/scripts_mcq/new_HCP_library_for_MEMES/';
bad_coil = '';

MEMES3(dir_name,elpfile,hspfile,confile,mrkfile,...
    path_to_MRI_library,'','average',1,8,'yes','rot3dfit');

%% Gamma Source Analysis
source_localisation_gamma_ME176(dir_name)
