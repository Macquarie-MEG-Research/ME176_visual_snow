function sensor_level_tfr_ME176(dir_name)

%% Load the data
cd(dir_name);
disp('Loading data...');
load('grating.mat');
load('lay.mat');

%% TFR Calculation
disp('Calculating Visual Gamma...');
cfg = [];
cfg.method = 'mtmconvol';
cfg.output = 'pow';
cfg.foi = 1:2:100;
cfg.pad = 'nextpow2';
cfg.t_ftimwin = ones(length(cfg.foi),1).*0.5;
cfg.tapsmofrq  = ones(length(cfg.foi),1).*8;
cfg.toi = -2.0:0.020:3.0;
fprintf('Time of interest = %.2fs to %.2fs\n',cfg.toi(1), cfg.toi(end));
multitaper = ft_freqanalysis(cfg, grating);

% Whole brain TFR
cfg = [];
cfg.baseline     = [-1.5 -0];
cfg.xlim         = [0 3.5];
cfg.ylim         = [40 100];
cfg.baselinetype = 'relative';
%cfg.zlim = 'maxabs';
cfg.showlabels   = 'yes';
cfg.layout       = lay;

figure; ft_multiplotTFR(cfg, multitaper);
title('High Frequencies 35-100Hz')

% Topoplot Gamma
cfg = [];
cfg.baseline     = [-1.5 -0];
cfg.xlim         = [0 3.5];
cfg.ylim         = [40 70];
cfg.baselinetype = 'relative';
cfg.showlabels   = 'yes';
cfg.layout       = lay;
cfg.colorbar = 'yes';

figure; ft_topoplotTFR(cfg, multitaper);
try
    ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
    colormap(flipud(brewermap(64,'RdBu'))) % change the colormap
    set(gca,'FontSize',20);
    print('gamma_topoplot','-dpng','-r200');
catch
end

% Mean of Occipital Channels
cfg = [];
cfg.channel = {'AG134', 'AG139', 'AG140', 'AG145', 'AG149', 'AG151', 'AG154'}
cfg.baseline     = [-1.5 -0];
cfg.xlim         = [0 3.5];
cfg.ylim         = [40 100];
cfg.baselinetype = 'relative';
cfg.showlabels   = 'yes';
cfg.layout       = lay;
cfg.colorbar = 'yes';

figure; ft_singleplotTFR(cfg, multitaper);
title('Mean Occipital 7 Chans');
try
    ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
    colormap(flipud(brewermap(64,'RdBu'))) % change the colormap
    set(gca,'FontSize',20);
    print('gamma_occipital_sensors','-dpng','-r200');
catch
end


