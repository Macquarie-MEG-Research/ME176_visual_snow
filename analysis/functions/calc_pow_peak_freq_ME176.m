function calc_pow_peak_freq_ME176(subject_VS,subject_control,...
    save_path,group_dir,~)

% Array to hold all data
perc_change_all_VS = [];

% For every subject_VS
for sub = 1:length(subject_VS)
    
    dir_name = [save_path subject_VS{sub}];
    
    cd(dir_name);
    fprintf('Loading Data for %s...\n',subject_VS{sub});
    load('VE_max.mat');
    
    cfg = [];
    cfg.method = 'mtmconvol';
    cfg.output = 'pow';
    cfg.pad = 10;
    cfg.foi = 30:1:150;
    cfg.toi = VE.time{1,1};
    cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;
    cfg.tapsmofrq  = ones(length(cfg.foi),1).*4;
    ddd = ft_freqanalysis(cfg, VE);
    
    cfg = [];
    cfg.latency = [-1.5 -0.3];
    baseline_pow = ft_freqdescriptives(cfg,ddd);
    cfg.latency = [0.3 1.5];
    grating_pow = ft_freqdescriptives(cfg,ddd);
    
    perc_change = (((squeeze(mean(grating_pow.powspctrm,3))-...
        squeeze(mean(baseline_pow.powspctrm,3)))./...
        squeeze(mean(baseline_pow.powspctrm,3))).*100);
    
    perc_change_all_VS(sub,:) = perc_change;
    
    clear ddd perc_change grating_pow baseline_pow VE
    
end

% Array to hold all data
perc_change_all_control = [];

% For every subject_VS
for sub = 1:length(subject_control)
    
    dir_name = [save_path subject_control{sub}];
    
    cd(dir_name);
    fprintf('Loading Data for %s...\n',subject_control{sub});
    load('VE_max.mat');
    
    cfg = [];
    cfg.method = 'mtmconvol';
    cfg.output = 'pow';
    cfg.pad = 10;
    cfg.foi = 30:1:150;
    cfg.toi = VE.time{1,1};
    cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;
    cfg.tapsmofrq  = ones(length(cfg.foi),1).*4;
    ddd = ft_freqanalysis(cfg, VE);
    
    cfg = [];
    cfg.latency = [-1.5 -0.3];
    baseline_pow = ft_freqdescriptives(cfg,ddd);
    cfg.latency = [0.3 1.5];
    grating_pow = ft_freqdescriptives(cfg,ddd);
    
    perc_change = (((squeeze(mean(grating_pow.powspctrm,3))-...
        squeeze(mean(baseline_pow.powspctrm,3)))./...
        squeeze(mean(baseline_pow.powspctrm,3))).*100);
    
    perc_change_all_control(sub,:) = perc_change;
    
    clear ddd perc_change grating_pow baseline_pow VE
    
end

%% Plot average gamma frequency with 95% confidence intervals

cd(group_dir);
cols = [0    0.3255    0.5020;   0.8000    0.2745    0.0784];

% Plot average
[mean_VS, CI_VS] = mq_get_confidence(perc_change_all_VS);
[mean_control, CI_control] = mq_get_confidence(perc_change_all_control);

figure;
boundedline(30:150, mean_VS, CI_VS(2,:),30:150, mean_control,...
    CI_control(2,:),'cmap',cols,'alpha');
ylim([-10 150]);
xlim([29 150]);
set(gca,'FontSize',20);
ylabel('% Power Change','FontSize',25);
xlabel('Frequency (Hz)','FontSize',25);
legend({'Visual Snow','Control'});
print('gamma_perc_change_VS_vs_control','-dpng','-r300')

% Extract power change and peak frequency

freq = 30:150;
pow_change_all_VS = [];
peak_freq_all_VS = [];

% Figure for quality checking
figure;
for sub=1:length(subject_VS)
    peakss = max(findpeaks(perc_change_all_VS(sub,:)));
    pow_change_all_VS(sub) = peakss;
    peak_freq = freq(find(perc_change_all_VS(sub,:)==peakss));
    peak_freq_all_VS(sub) = peak_freq;
    
    subplot(5,4,sub); plot(freq,perc_change_all_VS(sub,:));
    hold on; plot(peak_freq,peakss,'o','MarkerFaceColor','r');
    
end

% Repeat for controls
pow_change_all_control = [];
peak_freq_all_control = [];

% Figure for quality checking
figure;
for sub=1:length(subject_control)
    peakss = max(findpeaks(perc_change_all_control(sub,:)));
    pow_change_all_control(sub) = peakss;
    peak_freq = freq(find(perc_change_all_control(sub,:)==peakss));
    peak_freq_all_control(sub) = peak_freq;
    
    subplot(3,4,sub); plot(freq,perc_change_all_control(sub,:));
    hold on; plot(peak_freq,peakss,'o','MarkerFaceColor','r');
    
end


%% Generate Raincloud Plots
% Generate Colors
cols = [0    0.3255    0.5020;   0.8000    0.2745    0.0784];

% Number of Occurences
figure;
set(gcf,'Position',[1200 1200 1200 600]);

% Plot the raincloud
subplot(1,2,1);

h1 = raincloud_plot(peak_freq_all_VS, 'box_on', 1, 'color', cols(1,:), 'alpha', 0.5,...
     'box_dodge', 1, 'box_dodge_amount', .15, 'dot_dodge_amount', .35,...
     'box_col_match', 1);
h2 = raincloud_plot(peak_freq_all_control, 'box_on', 1, 'color', cols(2,:), 'alpha', 0.5,...
     'box_dodge', 1, 'box_dodge_amount', .55, 'dot_dodge_amount', .75,...
     'box_col_match', 1);
 
 legend([h1{1} h2{1}], {'Visual Snow', 'Control'});

set(h1{2}, 'SizeData', 60);
set(h2{2}, 'SizeData', 60);

%ylim([-0.04 0.06]);
yticklabels('');
set(gca,'FontSize',20);
xlabel('Frequency (Hz)','FontSize',25);
title('Peak Frequency (Hz)','FontSize',30);

subplot(1,2,2);
h1 = raincloud_plot(pow_change_all_VS, 'box_on', 1, 'color', cols(1,:), 'alpha', 0.5,...
     'box_dodge', 1, 'box_dodge_amount', .15, 'dot_dodge_amount', .35,...
     'box_col_match', 1);
h2 = raincloud_plot(pow_change_all_control, 'box_on', 1, 'color', cols(2,:), 'alpha', 0.5,...
     'box_dodge', 1, 'box_dodge_amount', .55, 'dot_dodge_amount', .75,...
     'box_col_match', 1);
 
 legend([h1{1} h2{1}], {'Visual Snow', 'Control'});

set(h1{2}, 'SizeData', 60);
set(h2{2}, 'SizeData', 60);

ylim([-4e-3 10e-3]);
yticklabels('');
set(gca,'FontSize',20);
xlabel('% Change','FontSize',25);
title({'Percentage Change'; 'vs Baseline'}','FontSize',30);
print('VS_vs_control_peak_pow_change','-dpng','-r300');


end


















    