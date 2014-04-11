function [ ] = deleteOldData( parentDir )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    dirContents = dir(parentDir); % all dir contents
    subFolders=[dirContents(:).isdir]; % just subfolder
    folderNames = {dirContents(subFolders).name};    %subfolder names
    folderNames(ismember(folderNames,{'.','..'})) = []; %remove . & ..
    for i=1:length(folderNames)
        oneFolder=folderNames{i};
        delFolders = dir(strcat(parentDir,'/',oneFolder,'/','data'));  
        subDelFol = [delFolders(:).isdir];
        delFoldersNames={delFolders(subDelFol).name};
        for j=1:length(delFoldersNames)
           oneDelF=delFoldersNames{j};
           oneDelF=strcat(parentDir,'/',oneFolder,'/',oneDelF);
           display(strcat(datestr(now,'HH:MM:SS'),' [INFO] ', ...
                ' Removing: ',oneDelF));
           rmdir(oneDelF,'s');
        end    
    end
end

