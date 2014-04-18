function [ trainfeatureVector, testfeatureVector, trainLblVector, testLblVector, mat, order] = mainLLC( mainDir ,imgCount)

    dirContents = dir(mainDir); % all dir contents
    subFolders=[dirContents(:).isdir]; % just subfolder
    folderNames = {dirContents(subFolders).name};    %subfolder names
    folderNames(ismember(folderNames,{'.','..'})) = []; %remove . & ..
    
    trainImgCount=0;
    testImgCount=0;
    sceneCount=0;
    
    for i=1:length(folderNames)
        %each folder=new scene
        oneFolder=folderNames{i};
        if strcmp(oneFolder ,'dataLLC') == 1
            continue;
        end
        
        localTrainCount=0;
        localTestCount=0;
        sceneCount=sceneCount+1;
        sceneNameList{sceneCount}=oneFolder;
        
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing images for scene "',oneFolder,'"'));
        sceneDir = strcat(mainDir,'/',  oneFolder,'/');
        
        imgFiles = dir(strcat(sceneDir,'*.jpg')); 
        
        for k = 1:imgCount
            trainImgCount=trainImgCount+1;
            localTrainCount=localTrainCount+1;
            imgTrain{trainImgCount}=strcat(oneFolder,'/',imgFiles(k).name);
            trainLblVector(trainImgCount,1)=sceneCount;
        end
        
        for j=imgCount+1:length(imgFiles)
            testImgCount=testImgCount+1;
            localTestCount=localTestCount+1;
            imgTest{testImgCount}=strcat(oneFolder,'/',imgFiles(j).name);
            testLblVector(testImgCount,1)=sceneCount;
        end
        
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] ... Train Images :',num2str(localTrainCount)));
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] ... Test Images :',num2str(localTestCount)));
    end    
    
    imgTrain=cellstr(imgTrain);
    imgTest=cellstr(imgTest);
    sceneNameList=cellstr(sceneNameList);    
        
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total scenes : ',num2str(length(folderNames))));
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total train images : ',num2str(trainImgCount)));
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total test images : ',num2str(testImgCount)));
    
    outDir=strcat(mainDir,'/dataLLC');
    mkdir(outDir);
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Data directory created at : ',outDir));
    addpath('../SpatialPyramid');
    trainfeatureVector = BuildPyramidLLC(imgTrain, mainDir, outDir, 5);
    testfeatureVector = BuildPyramidLLC(imgTest, mainDir, outDir, 5);
    trainfeatureVector=sparse(double(trainfeatureVector));
    testfeatureVector=sparse(double(testfeatureVector));
%     display('creating train kernel');
%     traink = hist_isect(trainfeatureVector, trainfeatureVector);
%     display('creating test kernel');
%     testk = hist_isect(testfeatureVector, trainfeatureVector);
%     traink=sparse(double(traink));
%     testk=sparse(double(testk));
    rmpath('../SpatialPyramid');
    addpath('../liblinear/matlab');
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Training model'));
   
    trainLblVector=double(trainLblVector);
    testLblVector=double(testLblVector);
    
    %[cluster1, cluster2] = findClusterAssignments(trainfeatureVector, folderNames, imgCount, mainDir);
    %display(cluster1);
    %display(cluster2);
    
    
    
    %svm
    model = train(trainLblVector, trainfeatureVector );    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Predict'));    
    [predictLblVector, accuracy, decision_values] = predict(testLblVector, testfeatureVector, model);
    
    %knn
%     predictLblVector = kNN(trainLblVector, trainfeatureVector, testLblVector, testfeatureVector, 50);

    %neural net
%     display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Feeding Forward net'));
%     net = feedforwardnet(5,'trainrp');
%     display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Configuring net'));
%     net = configure(net,trainfeatureVector', trainLblVector');
%     display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Training net'));
%     %net.efficiency.memoryReduction = 1000000000;
%     %net = fitnet(200, 'trainrp');
%     net.trainFcn = 'trainrp';
%     net = train(net,trainfeatureVector', trainLblVector');
%     display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Predicting labels net'));
%     [predictLblVector,Xf,Af] = sim(net, testfeatureVector');
%     %[predictLblVector,Xf,Af] = net(testfeatureVector);
    
    display(predictLblVector);
    
    rmpath('../liblinear/matlab');
    
    meanAccuracy = calcMeanAccuracy(sceneCount, testLblVector, predictLblVector');
    display(strcat('Mean accuracy:', num2str(meanAccuracy),'%'));
    
    %[ mat, order ] = confusionMat(testLblVector, predictLblVector)
end
