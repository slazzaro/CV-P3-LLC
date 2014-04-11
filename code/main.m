%function [ imgTrain, imgTest, trainLblVector, testLblVector] = main( mainDir ,imgCount)
function [ trainfeatureVector, testfeatureVector, trainLblVector, testLblVector] = main( mainDir ,imgCount)

    dirContents = dir(mainDir); % all dir contents
    subFolders=[dirContents(:).isdir]; % just subfolder
    folderNames = {dirContents(subFolders).name};    %subfolder names
    folderNames(ismember(folderNames,{'.','..'})) = []; %remove . & ..
    
    trainImgCount=0;
    testImgCount=0;
    scenceCount=0;
    
    for i=1:length(folderNames)
        %each folder=new scene
        oneFolder=folderNames{i};
        if strcmp(oneFolder ,'data') == 1
            continue;
        end
        
        localTrainCount=0;
        localTestCount=0;
        scenceCount=scenceCount+1;
        sceneNameList{scenceCount}=oneFolder;
        
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing images for scence "',oneFolder,'"'));
        sceneDir = strcat(mainDir,'/',  oneFolder,'/');
        
        imgFiles = dir(strcat(sceneDir,'*.jpg')); 
        
        for k = 1:imgCount
            trainImgCount=trainImgCount+1;
            localTrainCount=localTrainCount+1;
            imgTrain{trainImgCount}=strcat(oneFolder,'/',imgFiles(k).name);
            trainLblVector{trainImgCount}=scenceCount;
        end
        
        for j=imgCount+1:length(imgFiles)
            testImgCount=testImgCount+1;
            localTestCount=localTestCount+1;
            imgTest{testImgCount}=strcat(oneFolder,'/',imgFiles(j).name);
            testLblVector{testImgCount}=scenceCount;
        end
        
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] ... Train Images :',num2str(localTrainCount)));
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] ... Test Images :',num2str(localTestCount)));
    end    
    
    imgTrain=cellstr(imgTrain);
    imgTest=cellstr(imgTest);
    sceneNameList=cellstr(sceneNameList);    
    
    trainfeatureVector=zeros(trainImgCount,4200); %morework
    testfeatureVector=zeros(testImgCount,4200); %morework  
        
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total scenes : ',num2str(length(folderNames))));
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total train images : ',num2str(trainImgCount)));
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total test images : ',num2str(testImgCount)));
    
    outDir=strcat(mainDir,'/data');
    mkdir(outDir);
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Data directory created at : ',outDir));
    addpath('../SpatialPyramid');
    trainfeatureVector = BuildPyramid(imgTrain, mainDir, outDir);
    testfeatureVector = BuildPyramid(imgTest, mainDir, outDir);
    rmpath('../SpatialPyramid');
    
    %deleteData(mainDir);
end
