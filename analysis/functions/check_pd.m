function check_pd(confile,dir_name,pd_chan)

    cd(dir_name);
    
    cfg = [];
    cfg.headerfile = confile;
    cfg.datafile = confile;
    cfg.trialdef.triallength = Inf;
    cfg.trialdef.ntrials = 1;
    cfg = ft_definetrial(cfg)
    
    cfg.continuous = 'yes';
    alldata = ft_preprocessing(cfg);
    
    figure; 
    set(gcf,'Position',[100 100 1200 600]);
    subplot(4,1,1);plot(alldata.trial{1,1}(166,50000:200000));
    title('Channel 166');
    subplot(4,1,2);plot(alldata.trial{1,1}(208,50000:200000));
    title('Channel 209');
        subplot(4,1,3);plot(alldata.trial{1,1}(210,50000:200000));
    title('Channel 210');
    subplot(4,1,4);plot(alldata.trial{1,1}(181,50000:200000));
    title('Channel 181');
    subject{sub}
    
    cfg = [];
    cfg.dataset                 = confile;
    cfg.continuous              = 'yes';
    cfg.how_correct             = 'photodetector';
    cfg.pd_chan                 = pd_chan;
    cfg.trialdef.prestim        = 3.5;         % pre-stimulus interval
    cfg.trialdef.poststim       = 3.0;        % post-stimulus interval
    cfg.trialfun                = 'ME176_photodetector';
    data_raw                    = ft_definetrial(cfg);
end

    
%     figure; 
%     set(gcf,'Position',[100 100 1200 600]);
%     plot(alldata.trial{1,1}(181,250000:260000),'r'); hold on;
%     plot(alldata.trial{1,1}(166,250000:260000),'b'); hold on;