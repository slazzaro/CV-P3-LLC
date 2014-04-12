%function [ imgTrain, imgTest, trainLblVector, testLblVector] = main( mainDir ,imgCount)
function [ trainfeatureVector, testfeatureVector, trainLblVector, testLblVector] = mainLLC( mainDir ,imgCount)

    dirContents = dir(mainDir); % all dir contents
    subFolders=[dirContents(:).isdir]; % just subfolder
    folderNames = {dirContents(subFolders).name};    %subfolder names
    folderNames(ismember(folderNames,{'.','..'})) = []; %remove . & ..
    
    trainImgCount=0;
    testImgCount=0;
    scenceCount=0;
    
    %first row will be actual number of test label, and second will be
    %correct num of predictions
    numScenes = length(folderNames);
    
    for i=1:length(folderNames)
        %each folder=new scene
        oneFolder=folderNames{i};
        if strcmp(oneFolder ,'dataLLC') == 1
            numScenes = numScenes - 1;
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
            trainLblVector(trainImgCount,1)=scenceCount;
        end
        
        for j=imgCount+1:length(imgFiles)
            testImgCount=testImgCount+1;
            localTestCount=localTestCount+1;
            imgTest{testImgCount}=strcat(oneFolder,'/',imgFiles(j).name);
            testLblVector(testImgCount,1)=scenceCount;
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
    
    outDir=strcat(mainDir,'/dataLLC');
    mkdir(outDir);
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Data directory created at : ',outDir));
    addpath('../SpatialPyramid');
    trainfeatureVector = BuildPyramidLLC(imgTrain, mainDir, outDir);
    testfeatureVector = BuildPyramidLLC(imgTest, mainDir, outDir);
    rmpath('../SpatialPyramid');
    
    addpath('../liblinear/matlab');
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Training model'));
    
%     trainLblVector=trainLblVector';
%     testLblVector=testLblVector';
   
    trainLblVector=double(trainLblVector);
    trainfeatureVector=sparse(double(trainfeatureVector));
    testLblVector=double(testLblVector);
    testfeatureVector=sparse(double(testfeatureVector));
        
    model = train(trainLblVector, trainfeatureVector );    
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Predict'));    
    [predicted_label, accuracy, decision_values] = predict(testLblVector, testfeatureVector, model);
    rmpath('../liblinear/matlab');
    accuracy
    
    meanAccuracy = calcMeanAccuracy(numScenes, testLblVector, predicted_label);
    display(meanAccuracy);
    
    %print mean accuracy for all the classes
    %for i = 1:meanAccuracies
    %trainfeatureVector=htranspose(trainfeatureVector);
    %deleteData(mainDir);
end
