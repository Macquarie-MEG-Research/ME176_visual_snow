cd('/Volumes/Robert T5/ME176_data_preprocessed/3566');
load('VE_max.mat');

data = vertcat(VE.trial{:});

figure; plot(data(1,1:1000));



cfg                         = [];
cfg.Fs                      = 300;
cfg.phase_freqs             = [7:1:13];
cfg.amp_freqs               = [36:2:100];
cfg.method                  = 'tort';
cfg.filt_order              = 4;
cfg.surr_method             = 'swap_blocks';
cfg.surr_N                  = 300;
cfg.amp_bandw_method        = 'centre_freq';
%cfg.amp_bandw               = 30;
cfg.mask                    = [1141 1504];
[MI_grating,surr_grating]   = PACmeg(cfg,data);
cfg.mask                    = [601 1050];
[MI_baseline,surr_baseline] = PACmeg(cfg,data);

N = (MI_grating - squeeze(mean(surr_grating)))./squeeze(std(surr_grating));
%N(N<0) = 0;
M = (MI_baseline - squeeze(mean(surr_baseline)))./squeeze(std(surr_baseline));
%M(M<0) = 0;

U = (N-M);

plot_comod(cfg.phase_freqs,cfg.amp_freqs,M);

