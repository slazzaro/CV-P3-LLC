function [ ] = main( mainDir, countTrainImgs )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    dirContents = dir(mainDir); % all dir contents
    subFolders=[dirContents(:).isdir]; % just subfolder
    folderNames = {dirContents(subFolders).name};    %subfolder names
    folderNames(ismember(folderNames,{'.','..'})) = []; %remove . & ..
    labels = containers.Map;    
    for i=1:length(folderNames)
        oneFolder=folderNames{i};
        labels(oneFolder)=i;
        %display(strcat(oneFolder,'-->',num2str(labels(oneFolder))));
        runBuildPyramidOnImages(mainDir, strcat(mainDir,'/',oneFolder,'/'),countTrainImgs);
    end
end

