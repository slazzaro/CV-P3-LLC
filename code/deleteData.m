function [ ] = deleteData( parentDir )
    %dataDir=strcat(parentDir,'/data');
    dataDir=parentDir;
    if exist(dataDir,'dir')
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Removing :',dataDir));
        rmdir(dataDir,'s');      
    else
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] No data folder found to remove.'));
    end
    
end

