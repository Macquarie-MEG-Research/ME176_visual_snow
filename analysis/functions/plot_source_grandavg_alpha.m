function plot_source_grandavg_alpha(subject,save_path,mri,group_dir,group)

source_pre_all = [];
source_pst_all = [];

for sub = 1:length(subject)
    disp(subject{sub});
    dir_name = [save_path subject{sub}];
    cd(dir_name);
    load sourcepreS1_alpha.mat
    load sourcepstS1_alpha.mat
    
    source_pre_all{sub} = sourcepreS1;
    source_pst_all{sub} = sourcepstS1;
    
    clear sourcepreS1 sourcepstS1
end
    
%% Now perform grand averaging    
cd(group_dir);

disp('Performing Grand Average');
cfg = [];
cfg.parameter = 'pow';
source_pre_grandavg = ft_sourcegrandaverage(cfg,source_pre_all{:});
source_pst_grandavg = ft_sourcegrandaverage(cfg,source_pst_all{:});

%Plot the difference - not necessary but useful for illustration purposes
cfg = [];
cfg.parameter = 'avg.pow';
cfg.operation = '((x1-x2)./x2)*100';
sourceR=ft_math(cfg,source_pst_grandavg,source_pre_grandavg);

% Interpolate onto SPM brain
cfg              = [];
cfg.voxelcoord   = 'no';
cfg.parameter    = 'pow';
cfg.interpmethod = 'nearest';
sourceI  = ft_sourceinterpolate(cfg, sourceR, mri);

%% Plot
cfg = [];
cfg.funparameter = 'pow';
cfg.location     = 'min';
ft_sourceplot(cfg,sourceI);
ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
colormap(flipud(brewermap(64,'RdBu'))) % change the colormap
saveas(gcf,['sourceI_all_alpha' group '.png']); drawnow;

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
print(['vis_alpha_1_all_' group],'-dpng','-r300');
view([-60 0]);
print(['vis_alpha_2_all_' group],'-dpng','-r300');
view([60 0]);
print(['vis_alpha_3_all_' group],'-dpng','-r300');