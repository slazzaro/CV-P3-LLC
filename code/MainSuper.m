function [  ] = MainSuper( mainDir ,imgCount, testName, useLLC, useKer, ...
                           delOld, dictionarySize, pyramidLevels, ...
                           numTextonImages, patchSize, gridSpacing, k)
                
                        
    
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
        if strcmp(oneFolder ,'dataLLC') == 1
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

    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total scenes : ',num2str(length(folderNames))));
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total train images : ',num2str(trainImgCount)));
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Total test images : ',num2str(testImgCount)));
        
    %params.maxImageSize = 1000
    params.gridSpacing = gridSpacing;
    params.patchSize = patchSize;
    params.dictionarySize = dictionarySize;
    params.numTextonImages = numTextonImages;
    params.pyramidLevels = pyramidLevels;
    %params.oldSift = false;
    meanAcc
    addpath('../SpatialPyramid');
    if(useLLC==1)  
        outDir=strcat(mainDir,'/dataLLC');
        mkdir(outDir);
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Data directory created at : ',outDir));          
        trainfeatureVector = BuildPyramidLLC(imgTrain, mainDir, outDir, params);
        testfeatureVector = BuildPyramidLLC(imgTest, mainDir, outDir, params);
    else
        outDir=strcat(mainDir,'/data');
        mkdir(outDir);
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Data directory created at : ',outDir));  
        trainfeatureVector = BuildPyramid(imgTrain, mainDir, outDir, k, params);
        testfeatureVector = BuildPyramid(imgTest, mainDir, outDir, k, params);
    end        

    trainLblVector=double(trainLblVector);
    trainfeatureVector=sparse(double(trainfeatureVector));
    testLblVector=double(testLblVector);
    testfeatureVector=sparse(double(testfeatureVector));
    
    if (useKer==1)
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Creating training kernel')); 
        trainKernel = hist_isect(trainfeatureVector, trainfeatureVector);
        trainKernel=sparse(trainKernel);
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Creating testing kernel'));  
        testKernel = hist_isect(testfeatureVector,trainfeatureVector);
        testKernel=sparse(testKernel);       
    end   
    rmpath('../SpatialPyramid');
                       
    addpath('../liblinear/matlab');    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Training model on LIBLINEAR')); 
    if (useKer==1)
        model = train(trainLblVector, trainKernel);  
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Predict on LIBLINEAR'));    
        [predictLblVector, accuracy, decision_values] = predict(testLblVector, testKernel, model);        
    else
        model = train(trainLblVector, trainfeatureVector); 
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Predict on LIBLINEAR'));    
        [predictLblVector, accuracy, decision_values] = predict(testLblVector, testfeatureVector, model);        
    end
    rmpath('../liblinear/matlab');
    
    [ confMat, order ] = confusionMat(testLblVector, predictLblVector);  
    meanAcc = calcMeanAccuracy(15, testLblVector, predictLblVector);
    
    %save(strcat('../vars/',testName,'_predictLblVector.mat'),'predictLblVector');
    save(strcat('../vars/',testName,'_confMat.mat'),'confMat');
    save(strcat('../vars/',testName,'_order.mat'),'order');    
    save(strcat('../vars/',testName,'_accuracy.mat'),'accuracy');  
    save(strcat('../vars/',testName,'_meanAcc.mat'),'meanAcc');
    save(strcat('../vars/',testName,'_sceneNameList.mat'),'sceneNameList');
 
    if (delOld==1)
        deleteData(outDir);
    end          
                       
                       
end

