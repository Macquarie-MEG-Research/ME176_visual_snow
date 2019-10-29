
subject = {'3626','3627'};

for sub = 1:length(subject)
    
    try
        
        confile = ['/Volumes/Robert T5/BIDS/BIDS-2019-19/ME176/sub-' subject{sub}...
            '/ses-1/meg/sub-' subject{sub} '_ses-1_task-alien_run-1_meg.con'];
        
        mrkfile = ['/Volumes/Robert T5/BIDS/BIDS-2019-19/ME176/sub-' subject{sub}...
            '/ses-1/meg/sub-' subject{sub} '_ses-1_task-alien_run-1_markers.mrk'];
        
        elpfile = dir(['/Volumes/Robert T5/BIDS/BIDS-2019-19/ME176/sub-' subject{sub}...
            '/ses-1/extras/*.elp']);
        elpfile = [elpfile.folder '/' elpfile.name];
        
        hspfile = dir(['/Volumes/Robert T5/BIDS/BIDS-2019-19/ME176/sub-' subject{sub}...
            '/ses-1/extras/*.hsp']);
        
        hspfile = [hspfile.folder '/' hspfile.name];
        
       cd(['/Volumes/Robert T5/BIDS/BIDS-2019-19/ME176/sub-' subject{sub} '/ses-1/meg']);
        
        system(['python /Users/rseymoue/Documents/GitHub/MQ_MEG_Scripts/'...
            'Preprocessing/mq_con2fif_maxfilter.py -con ' '''' confile '''' ' -mrk '...
            '''' mrkfile '''' ' -elp ' '''' elpfile '''' ' -hsp ' '''' hspfile '''']);
    catch
        fprintf('Could not process %s\n',subject{sub});
    end
end

