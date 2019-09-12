function source_localisation_gamma_ME176(dir_name,mri,template_grid,atlas)

cd(dir_name);

%% Source analysis
disp('Loading Data...');
load('grating.mat');
load('headmodel.mat');
load('sourcemodel3d.mat');
load('grad_trans.mat');
load('headshape_downsampled.mat');

grating.grad = grad_trans;

%% BP Filter
cfg = [];
cfg.bpfilter = 'yes'
cfg.bpfreq = [40 70];    %band-pass filter in the required range
data_filtered = ft_preprocessing(cfg,grating);

%% Here we redefine trials based on the time-points of interest.
% Make sure the timepoints are of equivalent length

cfg = [];
cfg.toilim = [-1.5 -0.3];
datapre = ft_redefinetrial(cfg, data_filtered);
cfg.toilim = [0.3 1.5];
datapost = ft_redefinetrial(cfg, data_filtered);

%% Create leadfield
cfg = [];
cfg.grid = sourcemodel3d;
cfg.headmodel = headmodel;
cfg.grad = grad_trans;
cfg.normalize = 'yes'; % May not need this
lf = ft_prepare_leadfield(cfg);

% make a figure of the single subject{i} headmodel, and grid positions
figure; hold on;
ft_plot_vol(headmodel,  'facecolor', 'cortex', 'edgecolor', 'none');alpha 0.5; camlight;
ft_plot_mesh(lf.pos(lf.inside,:));
ft_plot_sens(grad_trans, 'style', 'r*')

% Here we are keeping all parts of the trial to compute the
% covariance matrix --> common filter
cfg = [];
cfg.covariance = 'yes';
cfg.covariancewindow = [-1.5 1.5]
avg = ft_timelockanalysis(cfg,data_filtered);

% Time lock analysis for datapre and datapost period
cfg = [];
cfg.covariance='yes';
avgpre = ft_timelockanalysis(cfg,datapre);
avgpst = ft_timelockanalysis(cfg,datapost);

% Create a figure to illustrate the averaged timecourse
figure
plot(avg.time,avg.avg)

%% Do ya beamforming
% Source reconstruction for the whole trial
cfg=[];
cfg.method='lcmv';
cfg.grid=lf;
cfg.headmodel=headmodel;
cfg.lcmv.keepfilter='yes';
cfg.lcmv.fixedori = 'yes';
cfg.grad = grad_trans;
sourceavg=ft_sourceanalysis(cfg, avg);

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
saveas(gcf,'sourceI_new3.png'); drawnow;

disp('Producing 3D Plot');
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
title('% Change Gamma Power vs Baseline');
set(gca,'FontSize',14);
print('vis_gamma_1','-dpng','-r300');
view([-60 0]);
print('vis_gamma_2','-dpng','-r300');
view([60 0]);
print('vis_gamma_3','-dpng','-r300');

%% Create VE from max point

% Find filter from max point
filter = sourceavg.avg.filter{find(sourceR.pow == max(sourceR.pow)),1};

VE = [];
VE.label = {'max'};
VE.trialinfo = grating.trialinfo;
for subs=1:(length(grating.trialinfo))
    % note that this is the non-filtered "raw" data
    VE.time{subs}       = grating.time{subs};
    VE.trial{subs}(1,:) = filter(1,:)*grating.trial{subs}(:,:);
end

% Compute TFR using multitapers
cfg = [];
cfg.method = 'mtmconvol';
cfg.output = 'pow';
cfg.pad = 'nextpow2'
cfg.foi = 1:1:100;
cfg.toi = -2.0:0.02:3.0;
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;
cfg.tapsmofrq  = ones(length(cfg.foi),1).*8;

multitaper = ft_freqanalysis(cfg, VE);

% Plot
cfg                 = [];
cfg.ylim            = [30 100];
cfg.xlim            = [-0.5 1.5];
cfg.baseline        = [-1.5 -0.3];
cfg.baselinetype    = 'normchange';
cfg.zlim = 'maxabs';
figure; ft_singleplotTFR(cfg, multitaper);
title('MAX','Interpreter','none');
ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
colormap(flipud(brewermap(64,'RdBu'))) % change the colormap
xlabel('Time (s)'); ylabel('Frequency (Hz)');
set(gca,'FontSize',20); drawnow;
print('VE_TFR_MAX','-dpng','-r200');

% Save to file with label and subject information
save('VE_max','VE');

clear VE

%% Do VE analysis
disp('Creating ROIs in L_Calcarine and R_Calcarine');

% Interpolate the atlas onto 10mm grid
cfg = [];
cfg.interpmethod = 'nearest';
cfg.parameter = 'tissue';
sourcemodel2 = ft_sourceinterpolate(cfg, atlas, template_grid);

labels = {'Calcarine_L','Calcarine_R'};

for lab = 1:length(labels)
%     % Find atlas points
%     atlas_points = find(sourcemodel2.tissue==...
%         find(contains(sourcemodel2.tissuelabel,labels{lab})));
%     
%     % Concatenate spatial filter
%     F    = cat(1,sourceavg.avg.filter{atlas_points});
%     
%     % Do SVD
%     [u,s,v] = svd(F*avg.cov*F');
%     filter = u'*F;
%     
%     % Create VE
%     VE = [];
%     VE.label = {labels{lab}};
%     VE.trialinfo = grating.trialinfo;
%     for subs=1:(length(grating.trialinfo))
%         % note that this is the non-filtered "raw" data
%         VE.time{subs}       = grating.time{subs};
%         VE.trial{subs}(1,:) = filter(1,:)*grating.trial{subs}(:,:);
%     end
%     
%     % Save to file with label and subject information
%     save(sprintf('VE_%s',labels{lab}),'VE');
%     
%     % Compute TFR using multitapers
%     cfg = [];
%     cfg.method = 'mtmconvol';
%     cfg.output = 'pow';
%     cfg.pad = 'nextpow2'
%     cfg.foi = 1:1:100;
%     cfg.toi = -2.0:0.02:3.0;
%     cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;
%     cfg.tapsmofrq  = ones(length(cfg.foi),1).*8;
%     
%     multitaper = ft_freqanalysis(cfg, VE);
%     
%     % Plot
%     cfg                 = [];
%     cfg.ylim            = [30 100];
%     cfg.xlim            = [-0.5 1.5];
%     cfg.baseline        = [-1.5 -0.3];
%     cfg.baselinetype    = 'relative';
%     %cfg.zlim = 'maxabs';
%     figure; ft_singleplotTFR(cfg, multitaper);
%     title(labels{lab},'Interpreter','none');
%     ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
%     colormap(flipud(brewermap(64,'RdBu'))) % change the colormap
%     xlabel('Time (s)'); ylabel('Frequency (Hz)');
%     set(gca,'FontSize',20); drawnow;
%     print(sprintf('VE_TFR_%s',labels{lab}),'-dpng','-r200');
end

clear data_filtered sourceavg 

