function [ finalFeatures, lblvector ] = main( mainDir ,imgCount)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    dirContents = dir(mainDir); % all dir contents
    subFolders=[dirContents(:).isdir]; % just subfolder
    folderNames = {dirContents(subFolders).name};    %subfolder names
    folderNames(ismember(folderNames,{'.','..'})) = []; %remove . & ..
    labels = containers.Map;   
    count=0;
    finalFeatures=zeros(length(folderNames)*imgCount,4200); %morework
    lblvector=zeros(length(folderNames)*imgCount,1);
    for i=1:length(folderNames)
        oneFolder=folderNames{i};
        labels(oneFolder)=i;
        %display(strcat(oneFolder,'-->',num2str(labels(oneFolder))));
        results=runBuildPyramidOnImages(strcat(mainDir,'/',oneFolder,'/'),imgCount);
        
        for j=1:size(results,1);
           finalFeatures(count+j,:)=results(j,:);
           lblvector(count+j)=i;
        end
        
        count=count+size(results,1);
    end
end

