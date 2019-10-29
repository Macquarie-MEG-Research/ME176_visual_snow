%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now let's analyse the response to the astronaut & alien

alien_ast_trials = (find(data.trialinfo == 181));

cfg = [];
cfg.trials = alien_ast_trials;
alien_ast = ft_redefinetrial(cfg,data_clean_150); %redefines the data

alien_ast.grad = grad_trans;

%% BP Filter (Gamma)
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [40 70];    %band-pass filter in the required range
data_filtered_alien_ast = ft_preprocessing(cfg,alien_ast);
data_filtered = ft_preprocessing(cfg,grating); clear data_clean_noICA_250


%% Here we redefine trials based on the time-points of interest.
% Make sure the timepoints are of equivalent length

cfg = [];
cfg.toilim = [-1.5 -0.8];
datapre = ft_redefinetrial(cfg, data_filtered);
cfg.toilim = [0.3 1.0];
datapost = ft_redefinetrial(cfg, data_filtered_alien_ast);

% Time lock analysis for datapre and datapost period
cfg = [];
cfg.covariance='yes';
avgpre = ft_timelockanalysis(cfg,datapre);
avgpst = ft_timelockanalysis(cfg,datapost);

%% Create common covariance matrix with 1s of baseline and 1s of astronaut/alien

cfg = [];
cfg.latency = [-1.5 -0.5];
baseline_1_s = ft_selectdata(cfg,data_filtered);

cfg = [];
cfg.latency = [0 1];
alien_ast_1_s = ft_selectdata(cfg,data_filtered_alien_ast);

cfg = [];
cfg.covariance = 'yes';
cfg.covariancewindow = 'all';
avg_alien_ast_1_s = ft_timelockanalysis(cfg,alien_ast_1_s);
avg_baseline_1_s = ft_timelockanalysis(cfg,baseline_1_s);

alien_ast_baseline_common = avg_alien_ast_1_s;
% average over covariance matrix
alien_ast_baseline_common.cov = ((avg_alien_ast_1_s.cov+...
    avg_baseline_1_s.cov)./2);

%% Do ya beamforming
% Source reconstruction for the whole trial
cfg=[];
cfg.method='lcmv';
cfg.grid=lf;
cfg.headmodel=headmodel;
cfg.lcmv.keepfilter='yes';
cfg.grad = grad_trans;
sourceavg=ft_sourceanalysis(cfg, alien_ast_baseline_common);

% Now do beamforming for the two time points separately using the same spatial
% filter computed from the whole trial
cfg = [];
cfg.method='lcmv';
cfg.grid=lf;
cfg.grid.filter=sourceavg.avg.filter; %uses the grid from the whole trial average
cfg.headmodel=headmodel;
%Pre-grating
sourcepreS1 = ft_sourceanalysis(cfg, avgpre);
%Post-grating
sourcepstS1=ft_sourceanalysis(cfg, avgpst);

% Make sure your field positions match the template grid

sourcepreS1.pos=template_grid.pos; % right(?)
sourcepstS1.pos=template_grid.pos; % right(?)

% save sourcepreS1 sourcepreS1
% save sourcepstS1 sourcepstS1

%Plot the difference - not necessary but useful for illustration purposes
cfg = [];
cfg.parameter = 'avg.pow';
cfg.operation = '((x1-x2)./x2)*100';
sourceR=ft_math(cfg,sourcepstS1,sourcepreS1);

mri = ft_read_mri('/Users/44737483/Documents/fieldtrip-20170501/template/anatomy/single_subj_T1.nii');

% Interpolate onto SPM brain
cfg              = [];
cfg.voxelcoord   = 'no';
cfg.parameter    = 'pow';
cfg.interpmethod = 'nearest';
sourceI  = ft_sourceinterpolate(cfg, sourceR, mri);

%% Plot
cfg = [];
cfg.funparameter = 'pow';
ft_sourceplot(cfg,sourceI);
ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
colormap(flipud(brewermap(64,'RdBu'))) % change the colormap
saveas(gcf,'sourceI_alien_ast.png');

cfg = [];
cfg.method         = 'surface';
cfg.funparameter   = 'pow';
cfg.projmethod     = 'nearest';
cfg.surfinflated   = 'surface_inflated_both.mat';
%cfg.surfdownsample = 10
%cfg.projthresh     = 0.2;
cfg.camlight       = 'no';
ft_sourceplot(cfg, sourceI);
ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
colormap(flipud(brewermap(64,'RdBu'))) % change the colormap
%view ([70 0 50])
%delete(findall(gcf,'Type','light'))
light ('Position',[0 0 50])
light ('Position',[0 -50 0])
material dull;
drawnow;
view([0 0]);
title({'% Change Gamma Power vs Baseline' ; 'Alien/Astronaut'});
set(gca,'FontSize',14);
print('vis_gamma_alien_ast_3238_1','-dpng','-r300');
view([-60 0]);
print('vis_gamma_alien_ast_3238_2','-dpng','-r300');
view([60 0]);
print('vis_gamma_alien_ast_3238_3','-dpng','-r300');


%% Do VE analysis
atlas = ft_read_atlas('/Users/44737483/Documents/fieldtrip-20170501/template/atlas/aal/ROI_MNI_V4.nii');
atlas = ft_convert_units(atlas,'mm');

% Interpolate the atlas onto 8mm grid
cfg = [];
cfg.interpmethod = 'nearest';
cfg.parameter = 'tissue';
sourcemodel2 = ft_sourceinterpolate(cfg, atlas, template_grid);

labels = {'Calcarine_L','Calcarine_R'};

for lab = 1:length(labels)
    % Find atlas points
    atlas_points = find(sourcemodel2.tissue==...
        find(contains(sourcemodel2.tissuelabel,labels{lab})));
    
    % Concatenate spatial filter
    F    = cat(1,sourceavg.avg.filter{atlas_points});
    
    % Do SVD
    [u,s,v] = svd(F*avg.cov*F');
    filter = u'*F;
    
    % Create a baseline VE from the grating data, but using the spatial 
    % from the alien/astronauts analysis
    VE_grating = [];
    VE_grating.label = {labels{lab}};
    VE_grating.trialinfo = grating.trialinfo;
    for subs=1:(length(grating.trialinfo))
        % note that this is the non-filtered "raw" data
        VE_grating.time{subs}       = grating.time{subs};
        VE_grating.trial{subs}(1,:) = filter(1,:)*grating.trial{subs}(:,:);
    end
    
    % Save to file with label and subject information
    %save(sprintf('VE_%s_3180',labels{lab}),'VE');
    
    % Do your TFR
    cfg = [];
    cfg.method = 'mtmconvol';
    cfg.output = 'pow';
    cfg.pad = 'nextpow2'
    cfg.foi = 1:1:100;
    cfg.toi = -2:0.02:3.0;
    cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;
    cfg.tapsmofrq  = ones(length(cfg.foi),1).*8;
    multitaper_grating = ft_freqanalysis(cfg, VE_grating);
    
    % Correct for grating onset
    %multitaper_grating.time = multitaper_grating.time-1.5;
    
    % Plot
    cfg                 = [];
    cfg.ylim            = [50 100];
    cfg.xlim            = [-0.5 2.5];
    cfg.baseline        = [-1.5 0];
    cfg.baselinetype    = 'relative';
    %cfg.zlim = 'maxabs';
    figure; ft_singleplotTFR(cfg, multitaper_grating);
    title(labels{lab},'Interpreter','none');
    ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
    colormap(flipud(brewermap(64,'RdBu'))) % change the colormap
    xlabel('Time (s)'); ylabel('Frequency (Hz)');
    set(gca,'FontSize',20); drawnow;
    print(sprintf('VE_TFR_alien_ast_%s_3238',labels{lab}),'-dpng','-r200');

end

%% PAC

load('VE_Calcarine_R_3180.mat');

addpath(genpath('/Users/44737483/Documents/scripts_mcq/sensory_PAC-master 2'));

% Add path to PAC functions
[matrix_post] = calc_MI(VE,[0.3 1.5],[7 20],[30 80]...
    ,'no','no','ozkurt');

[matrix_pre] = calc_MI(VE,[-1.5 -0.3],[7 20],[30 80]...
    ,'no','no','ozkurt');

% Compare MI matrix for pre-grating to post-grating
comb = (matrix_post - matrix_pre);

% Plot and save
figure('color', 'w');
pcolor(7:1:20,30:2:80,comb)
shading interp; colormap(jet)
ylabel('Frequency (Hz)'); xlabel('Phase (Hz)')
colorbar
saveas(gcf,'comod_tort_MI.png')








