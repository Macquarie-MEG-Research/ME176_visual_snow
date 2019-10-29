
function alpha_gamma_PAC(subject, save_path, group_dir,group)

PAC_pre_all = [];
PAC_pst_all = [];

for sub = 1:length(subject)
    disp(subject{sub});
    dir_name = [save_path subject{sub}];
    cd(dir_name);
    load VE_max.mat

    signal = vertcat(VE.trial{:});

    cfg                     = [];
    cfg.Fs                  = 1000;
    cfg.phase_freqs         = [7:1:14];
    cfg.amp_freqs           = [36:2:150];
    cfg.method              = 'tort';
    cfg.filt_order          = 4;
    cfg.mask                = [691 1051];
    %cfg.surr_method         = 'swap_blocks';
    %cfg.surr_N              = 200;
    cfg.amp_bandw_method    = 'centre_freq';
    %cfg.amp_bandw           = 20;
    
    [MI_raw]        = PACmeg(cfg,signal);
    cfg.mask                = [151 511];
    [MI_raw2]        = PACmeg(cfg,signal);
    
    PAC_pre_all(sub,:,:) = MI_raw2;
    PAC_pst_all(sub,:,:) = MI_raw;
    
    clear MI_raw2 MI_raw signal VE
    
end


%%
cd(group_dir);

baseline_corrected = (PAC_pst_all - PAC_pre_all);

plot_comod(cfg.phase_freqs,cfg.amp_freqs,squeeze(mean(baseline_corrected)));
caxis([-8e-4 8e-4]);
yticks([40:20:150]);
h = colorbar;
ylabel(h,'PAC vs Baseline');
print(['alpha_gamma_PAC_' group],'-dpng','-r300');




% 
% % figure;
% % for sub = 1:length(subject)
% %     plot_comod(cfg.phase_freqs,cfg.amp_freqs,squeeze(baseline_corrected(sub,:,:)));
% % end
% 
% %% Perform statistics to compare 
% 
% cfg                     = [];
% cfg.Fs                  = 1000;
% cfg.phase_freqs         = [7:1:14];
% cfg.amp_freqs           = [36:2:150];
% cfg.method              = 'tort';
% cfg.filt_order          = 4;
% cfg.mask                = [691 1051];
% %cfg.surr_method         = 'swap_blocks';
% %cfg.surr_N              = 200;
% cfg.amp_bandw_method    = 'centre_freq';
% %cfg.amp_bandw           = 20;
% 
% grandavgA = [];
% 
% for i =1:length(subject)
%     
%     % Add FT-related data structure information
%     MI_post = [];
%     MI_post.label = {'MI'};
%     MI_post.dimord = 'chan_freq_time';
%     MI_post.freq = cfg.amp_freqs;
%     MI_post.time = cfg.phase_freqs;
%     MI_post.powspctrm = squeeze(PAC_pst_all(i,:,:));
%     MI_post.powspctrm = reshape(MI_post.powspctrm,[1,length(cfg.amp_freqs)...
%         ,length(cfg.phase_freqs)]);
%     % Add to meta-matrix
%     grandavgA{i} = MI_post;
%     clear MI_post
% end
% 
% grandavgB = [];
% 
% for i =1:length(subject)
%     
%     % Add FT-related data structure information
%     MI_post = [];
%     MI_post.label = {'MI'};
%     MI_post.dimord = 'chan_freq_time';
%     MI_post.freq = cfg.amp_freqs;
%     MI_post.time = cfg.phase_freqs;
%     MI_post.powspctrm = squeeze(PAC_pre_all(i,:,:));
%     MI_post.powspctrm = reshape(MI_post.powspctrm,[1,length(cfg.amp_freqs)...
%         ,length(cfg.phase_freqs)]);
%     % Add to meta-matrix
%     grandavgB{i} = MI_post;
%     clear MI_post
% end
% 
% cd(group_dir);
% 
% %%
% cfg=[];
% cfg.latency = 'all';
% cfg.frequency = 'all';
% cfg.dim         = grandavgA{1}.dimord;
% cfg.method      = 'montecarlo';
% cfg.statistic   = 'ft_statfun_depsamplesT';
% cfg.parameter   = 'powspctrm';
% cfg.correctm    = 'cluster';
% cfg.computecritval = 'yes';
% cfg.numrandomization = 3000;
% cfg.alpha       = 0.05; % Set alpha level
% cfg.tail        = 0;    % Two sided testing
% 
% % Design Matrix
% nsubj=numel(grandavgA);
% cfg.design(1,:) = [1:nsubj 1:nsubj];
% cfg.design(2,:) = [ones(1,nsubj) ones(1,nsubj)*2];
% cfg.uvar        = 1; % row of design matrix that contains unit variable (in this case: subjects)
% cfg.ivar        = 2; % row of design matrix that contains independent variable (the conditions)
% 
% stat = ft_freqstatistics(cfg,grandavgA{:}, grandavgB{:});
% 
% %% Display results of stats (very rough - use make_smoothed_comodulograms)
% cfg=[];
% cfg.parameter = 'stat';
% cfg.maskparameter = 'mask';
% cfg.maskstyle     = 'outline';
% cfg.zlim = 'maxabs';
% cfg.colorbar = 'no';
% fig = figure;
% ft_singleplotTFR(cfg,stat);
% xlabel('Phase (Hz)'); ylabel('Amplitude (Hz)');
% h = colorbar;
% ylabel(h, 't-value')
% set(gca, 'FontSize', 20);
% title('');
% try
% ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
% colormap(flipud(brewermap(64,'RdBu'))) % change the colormap
% 
% catch
%     disp('Using default colormap');
% end
% 
% print(['PAC_' group],'-dpng','-r300');
end


