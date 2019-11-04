function [trl, sample] = ME176_photodetector(cfg)

% Get the photodetector channel from cfg (should be 165 or 209)
pd_chan = cfg.pd_chan;

% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);

%% Grating Trials
% Get grating events from channel 181
disp('Finding grating trials...');
event_grating = ft_read_event(cfg.dataset,'trigindx',181,'threshold',...
    2,'detectflank','up');
event_grating_type = str2num((vertcat(event_grating(:).type)));
event_grating = [event_grating(:).sample]';

% Get photodetector events from channel 209
pd_event = ft_read_event(cfg.dataset,'trigindx',pd_chan,'threshold',4e-3,'detectflank','up');
pd_event2 = [pd_event(:).sample]';

% Find photodetector events within 300ms of grating events 
event_grating_corr = zeros(length(event_grating),1);
no_pd_found = [];
pd_found    = [];
count = 1;
count2 = 1;

for trial = 1:length(event_grating)
    pd_spare = find((pd_event2 > event_grating(trial)) & ...
        (pd_event2 < event_grating(trial)+300));
    
    if isempty(pd_spare)
        no_pd_found(count) = trial;
        count = count+1;
    else
        event_grating_corr(trial,1) = pd_event2(pd_spare);
        pd_found(count2) = trial;
        count2 = count2+1;
    end
    
end

% Check for any errors
if isempty(pd_found)
    warning('No photodetector triggers within 300ms of a grating trigger')
else
    
    mean_diff = mean((event_grating_corr(pd_found)-event_grating(pd_found)),1)./1000;
    fprintf('Mean difference between trigger and photodetector: %.3fs\n',mean_diff);
end

% If no trigger is found, simply use the average delay as a proxy
if ~isempty(no_pd_found)
    
    fprintf(['Found %d trial(s) with no trigger...\nReplacing with average difference'...
        ' of %.3fs\n'],length(no_pd_found),mean_diff)
    
    for trial = 1:length(no_pd_found)
        trial_num =  no_pd_found(trial)
        event_grating_corr(trial_num) = event_grating(trial_num) + mean_diff;
    end
end

%% Astronaut/Alien
% Get astronaut/alien events from channel 183
disp('Finding alien/astronaut trials...');
event_alien = ft_read_event(cfg.dataset,'trigindx',183,'threshold',...
    2,'detectflank','up');
event_alien_type = str2num((vertcat(event_alien(:).type)));
event_alien = [event_alien(:).sample]';

% Get photodetector events from channel 209
pd_event = ft_read_event(cfg.dataset,'trigindx',pd_chan,'threshold',4e-3,'detectflank','down');
pd_event2 = [pd_event(:).sample]';

% Find photodetector events within 300ms of astronaut/alien events 
event_alien_corr = zeros(length(event_alien),1);
no_pd_found = [];
pd_found    = [];
count = 1;
count2 = 1;

for trial = 1:length(event_alien)
    pd_spare = find((pd_event2 > event_alien(trial)) & ...
        (pd_event2 < event_alien(trial)+300));
    
    if isempty(pd_spare)
        no_pd_found(count) = trial;
        count = count+1;
    else
        event_alien_corr(trial,1) = pd_event2(pd_spare);
        pd_found(count2) = trial;
        count2 = count2+1;
    end
    
end

if isempty(pd_found)
    warning('No photodetector triggers within 300ms of a grating trigger')
else
    
    mean_diff = mean((event_alien_corr(pd_found)-event_alien(pd_found)),1)./1000;
    fprintf('Mean difference between trigger and photodetector: %.3fs\n',mean_diff);
end

% If no trigger is found, simply use the average delay as a proxy
if ~isempty(no_pd_found)
    
    fprintf(['Found %d trial(s) with no trigger...\nReplacing with average difference'...
        ' of %.3fs\n'],length(no_pd_found),mean_diff)
    
    for trial = 1:length(no_pd_found)
        trial_num =  no_pd_found(trial)
        event_grating_alien(trial_num) = event_alien(trial_num) + mean_diff;
    end
end


%% Get the 'type' and sample information from the event list

value = vertcat(event_grating_type, event_alien_type);
sample = vertcat(event_grating_corr, event_alien_corr);

assignin('base','sample',sample);

% create trl structure based upon the events
trl = [];

for j = 1:length(value)
    if sample(j) - cfg.trialdef.prestim*hdr.Fs > 0
        trlbegin = sample(j) - cfg.trialdef.prestim*hdr.Fs;
        trlend   = sample(j) + cfg.trialdef.poststim*hdr.Fs;
        offset        = -cfg.trialdef.prestim*hdr.Fs;
        trl(end+1, :) = ([trlbegin trlend offset value(j)]);
    end
end
end