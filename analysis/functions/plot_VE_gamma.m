function plot_VE_gamma(subject,save_path,group_dir,group)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot_VE_gamma: plot group level visual gamma from VE
%
% Some more information
%
% Author: Robert Seymour (robert.seymour@mq.edu.au)
%
%%%%%%%%%%%
% Inputs:
%%%%%%%%%%%
%
% - subject     = list of subjects e.g. {'0000','0001'}
% - save_path   = directory of saved data
% - group_dir   = directory of where to save the group results
% - group       = 'control','visual_snow','migraine_control'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


multitaper_all = [];
multitaper_all_4= [];
TFR_hann_all = [];

for sub = 1:length(subject)
    
    dir_name = [save_path subject{sub}];
    cd(dir_name);
    fprintf('Loading Data for %s.../n',subject{sub});
    load('VE_max.mat');
    
    cfg = [];
    cfg.method = 'mtmconvol';
    cfg.output = 'pow';
    cfg.pad = 'nextpow2'
    cfg.foi = 1:1:100;
    cfg.toi = -2.0:0.02:3.0;
    cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;
    cfg.tapsmofrq  = ones(length(cfg.foi),1).*8;
    multitaper_all{sub} = ft_freqanalysis(cfg, VE);
    cfg.tapsmofrq  = ones(length(cfg.foi),1).*4;
    multitaper_all_4{sub} = ft_freqanalysis(cfg, VE);
    
    
    cfg              = [];
    cfg.output       = 'pow';
    cfg.channel      = 'all';
    cfg.method       = 'mtmconvol';
    cfg.taper        = 'hanning';
    cfg.foi          = 1:1:30;                         % analysis 2 to 30 Hz in steps of 2 Hz
    cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
    cfg.toi          = -2.0:0.02:3.0;                      % the time window "slides" from -0.5 to 1.5 in 0.05 sec steps
    TFR_hann_all{sub} = ft_freqanalysis(cfg, VE);    % visual stimuli
    
    clear VE
end

cfg = [];
cfg.parameter = 'powspctrm';
multitaper_grand_avg = ft_freqgrandaverage(cfg,multitaper_all{:});
hann_grand_avg = ft_freqgrandaverage(cfg,TFR_hann_all{:});

cfg                 = [];
cfg.ylim            = [30 100];
cfg.xlim            = [-0.5 1.5];
cfg.baseline        = [-1.5 -0.3];
cfg.baselinetype    = 'db';
cfg.zlim = 'maxabs';
figure; ft_singleplotTFR(cfg, multitaper_grand_avg);
title('MAX','Interpreter','none');
ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
colormap(flipud(brewermap(64,'RdBu'))) % change the colormap
xlabel('Time (s)'); ylabel('Frequency (Hz)');
set(gca,'FontSize',20); drawnow;

cd(group_dir);
print(['VE_TFR_MAX_grandaverage_' group],'-dpng','-r300');

cfg                 = [];
cfg.ylim            = [1 30];
cfg.xlim            = [-0.5 1.5];
cfg.baseline        = [-1.5 -0.3];
cfg.baselinetype    = 'db';
cfg.zlim = 'maxabs';
figure; ft_singleplotTFR(cfg, hann_grand_avg);
title('MAX','Interpreter','none');
ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
colormap(flipud(brewermap(64,'RdBu'))) % change the colormap
xlabel('Time (s)'); ylabel('Frequency (Hz)');
set(gca,'FontSize',20); drawnow;
print(['low_freq_hanning_all_' group],'-dpng','-r300');

%% Plot % change

perc_change = [];

for sub = 1:length(subject)
    
    baseline_pow = squeeze(multitaper_all_4{1,sub}.powspctrm);
    baseline_pow = mean(baseline_pow(:,(26:86)),2);
    
    baseline_grating = squeeze(multitaper_all_4{1,sub}.powspctrm);
    baseline_grating = mean(baseline_grating(:,(116:176)),2);
    
    perc_change(sub,:) = ((baseline_grating-baseline_pow)...
        ./baseline_pow).*100;
end
    
    
cd(group_dir);
figure; plot(1:1:100,perc_change,'LineWidth',2);
hold on ; plot(1:1:100,mean(perc_change),'-k','LineWidth',8);
set(gca,'FontSize',20);
xlabel('Frequency (Hz)','FontSize',26);
ylabel('% Power Change','FontSize',26);
print(['perc_change_visual_snow_' group],'-dpng','-r200');





