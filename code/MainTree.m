function [  ] = MainTree( mainDir ,imgCount, testName, useLLC, useKer, ...
                           delOld, dictionarySize, pyramidLevels, ...
                           numTextonImages, patchSize, gridSpacing, k)
                
                   
%     class1=['CALsuburb'	'MITcoast' 'MITforest' 'MIThighway'	'MITinsidecity'	'MITmountain' 'MITopencountry' 'MITstreet' 'MITtallbuilding'];
%     class2=['PARoffice'	'bedroom' 'industrial' 'kitchen' 'livingroom' 'store'];               
    class1=[1 2 3 4 5 6 7 8 9 12];
    class2=[10 11 13 14 15];
    
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
        if strcmp(oneFolder ,'dataTREE') == 1
            continue;
        end
        if strcmp(oneFolder ,'dataLLCTREE') == 1
            continue;
        end
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
    params.pyramidLevels = pyramidLevels;folderNames
    %params.oldSift = false;
    
    addpath('../SpatialPyramid');
    if(useLLC==1)  
        outDir=strcat(mainDir,'/dataLLCTREE');
        mkdir(outDir);
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Data directory created at : ',outDir));          
        trainfeatureVector = BuildPyramidLLC(imgTrain, mainDir, outDir, k, params);
        testfeatureVector = BuildPyramidLLC(imgTest, mainDir, outDir, k, params);
    else
        outDir=strcat(mainDir,'/dataTREE');
        mkdir(outDir);
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Data directory created at : ',outDir));  
        trainfeatureVector = BuildPyramid(imgTrain, mainDir, outDir, params);
        testfeatureVector = BuildPyramid(imgTest, mainDir, outDir, params);
    end        
    
    %[class1, class2] = findClusterAssignments( trainfeatureVector, folderNames, imgCount, mainDir )
    class1 = [2 4 6 7];
    class2 = [1 3 5 8 9 10 11 12 13 14 15];
    
    
%     levelOneBag=zeros(scenceCount);
    for i=1:length(class1)
        n=class1(1,i);
        levelOneBag(n)=1;
    end
    for i=1:length(class2)
        n=class2(1,i);
        levelOneBag(n)=2;
    end 
    
    trainLblVector=double(trainLblVector);
    trainfeatureVector=sparse(double(trainfeatureVector));
    testLblVector=double(testLblVector);
    testfeatureVector=sparse(double(testfeatureVector));
    
    l1trainLblVector=trainLblVector;
    l1testLblVector=testLblVector;
    
    for i=1:length(l1trainLblVector)
        l1trainLblVector(i)=levelOneBag(l1trainLblVector(i));
    end
    for i=1:length(l1testLblVector)
        l1testLblVector(i)=levelOneBag(l1testLblVector(i));
    end
        
%     trainLblVector=double(l1trainLblVector);
%     testLblVector=double(l2testfeatureVector);
    
    if (useKer==1)
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Creating training kernel')); 
        l1trainKernel = hist_isect(trainfeatureVector, trainfeatureVector);
        l1trainKernel=sparse(l1trainKernel);
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Creating testing kernel'));  
        l1testKernel = hist_isect(testfeatureVector,trainfeatureVector);
        l1testKernel=sparse(l1testKernel);       
    end   
    rmpath('../SpatialPyramid');
    
    addpath('../liblinear/matlab');    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Training model on LIBLINEAR')); 
    if (useKer==1)
        l1model = train(l1trainLblVector, l1trainKernel, 's','4');  
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Predict on LIBLINEAR'));    
        [l1predictLblVector, l1accuracy, l1decision_values] = predict(l1testLblVector, l1testKernel, l1model, 's','4');        
    else
        l1model = train(l1trainLblVector, trainfeatureVector, 's','4'); 
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Predict on LIBLINEAR'));    
        [l1predictLblVector, l1accuracy, l1decision_values] = predict(l1testLblVector, testfeatureVector, l1model, 's','4');        
    end
    rmpath('../liblinear/matlab');
    
    [ l1confMat, l1order ] = confusionMat(l1testLblVector, l1predictLblVector);  
    l1meanAcc = calcMeanAccuracy(2, l1testLblVector, l1predictLblVector);
    
    %save(strcat('../vars/',testName,'_predictLblVector.mat'),'predictLblVector');
    save(strcat('../vars/',testName,'_l1confMat.mat'),'l1confMat');
    save(strcat('../vars/',testName,'_l1order.mat'),'l1order');    
    save(strcat('../vars/',testName,'_l1accuracy.mat'),'l1accuracy');  
    save(strcat('../vars/',testName,'_l1meanAcc.mat'),'l1meanAcc');
    %save(strcat('../vars/',testName,'_l1sceneNameList.mat'),'l1sceneNameList');
 
    if (delOld==1)
        deleteData(outDir);
    end  
    
    %class1 & class2 sub-classification
% % %     c1
% % %     trainLblVector=double(trainLblVector);
% % %     trainfeatureVector=sparse(double(trainfeatureVector));
% % %     testLblVector=double(testLblVector);
% % %     testfeatureVector=sparse(double(testfeatureVector));
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Creating training data for level2')); 
    c1Count=0;
    c2Count=0;    
    for i=1:length(trainLblVector)
        if(l1trainLblVector(i)==1)
            c1Count=c1Count+1;
            c1trainLblVector(c1Count,1)=trainLblVector(i);
            c1trainfeatureVector(c1Count,:)=trainfeatureVector(i,:);
        else
            c2Count=c2Count+1;
            c2trainLblVector(c2Count,1)=trainLblVector(i);    
            c2trainfeatureVector(c2Count,:)=trainfeatureVector(i,:);         
        end
    end
    
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Creating test data for level2'));
    c1Count=0;
    c2Count=0;
    for i=1:length(testLblVector)
        if(l1predictLblVector(i)==1)
            c1Count=c1Count+1;
            c1testLblVector(c1Count,1)=testLblVector(i);
            c1testfeatureVector(c1Count,:)=testfeatureVector(i,:);
        else
            c2Count=c2Count+1;
            c2testLblVector(c2Count,1)=testLblVector(i); 
            c2testfeatureVector(c2Count,:)=testfeatureVector(i,:);            
        end
    end
    
    c1trainLblVector=double(c1trainLblVector);
    c1trainfeatureVector=double(c1trainfeatureVector);
    c1testLblVector=double(c1testLblVector);
    c1testfeatureVector=double(c1testfeatureVector); 
    c2trainLblVector=double(c2trainLblVector);
    c2trainfeatureVector=double(c2trainfeatureVector);
    c2testLblVector=double(c2testLblVector);
    c2testfeatureVector=double(c2testfeatureVector);
    
    %c1 sub classification
    
    addpath('../SpatialPyramid');
    if (useKer==1)
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Creating C1 training kernel')); 
        c1trainKernel = hist_isect(c1trainfeatureVector, c1trainfeatureVector);
        c1trainKernel=sparse(c1trainKernel);
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Creating C1 testing kernel'));  
        c1testKernel = hist_isect(c1testfeatureVector,c1trainfeatureVector);
        c1testKernel=sparse(c1testKernel);       
        
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Creating C2 training kernel')); 
        c2trainKernel = hist_isect(c2trainfeatureVector, c2trainfeatureVector);
        c2trainKernel=sparse(c2trainKernel);
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Creating C2 testing kernel'));  
        c2testKernel = hist_isect(c2testfeatureVector,c2trainfeatureVector);
        c2testKernel=sparse(c2testKernel);  
    end   
    rmpath('../SpatialPyramid');
                       
    addpath('../liblinear/matlab');    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Training C model on LIBLINEAR')); 
    if (useKer==1)
        c1model = train(c1trainLblVector, c1trainKernel, 's','4');  
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Predict C1 on LIBLINEAR'));    
        [c1predictLblVector, c1accuracy, c1decision_values] = predict(c1testLblVector, c1testKernel, c1model, 's','4');   
        
        c2model = train(c2trainLblVector, c2trainKernel, 's','4');  
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Predict C2 on LIBLINEAR'));    
        [c2predictLblVector, c2accuracy, c2decision_values] = predict(c2testLblVector, c2testKernel, c2model, 's','4'); 
    else
        c1model = train(c1trainLblVector, c1trainfeatureVector, 's','4'); 
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Predict C1 on LIBLINEAR'));    
        [c1predictLblVector, c1accuracy, c1decision_values] = predict(c1testLblVector, c1testfeatureVector, c1model, 's','4');   
        
        c2model = train(c2trainLblVector, c2trainfeatureVector, 's','4'); 
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Predict C2 on LIBLINEAR'));    
        [c2predictLblVector, c2accuracy, c2decision_values] = predict(c2testLblVector, c2testfeatureVector, c2model, 's','4');  
    end
    rmpath('../liblinear/matlab');
    
    nCount=0;
    for i=1:length(c1predictLblVector)
        nCount=nCount+1;
        actualLbl(nCount)=c1testLblVector(i);
        predictLbl(nCount)=c1predictLblVector(i);
    end
    
    for i=1:length(c2predictLblVector)
        nCount=nCount+1;
        actualLbl(nCount)=c2testLblVector(i);
        predictLbl(nCount)=c2predictLblVector(i);        
    end
    
    
    [ finalConfMat, finalOrder ] = confusionMat(actualLbl, predictLbl);  
    finalMeanAcc = calcMeanAccuracy(15, actualLbl, predictLbl);
    
    %save(strcat('../vars/',testName,'_predictLblVector.mat'),'predictLblVector');
    save(strcat('../vars/',testName,'_finalConfMat.mat'),'finalConfMat');
    save(strcat('../vars/',testName,'_finalOrder.mat'),'finalOrder');    
    save(strcat('../vars/',testName,'_c1accuracy.mat'),'c1accuracy');    
    save(strcat('../vars/',testName,'_c2accuracy.mat'),'c2accuracy');  
    save(strcat('../vars/',testName,'_finalMeanAcc.mat'),'finalMeanAcc');
    save(strcat('../vars/',testName,'_sceneNameList.mat'),'sceneNameList');
    
    
    
                       
end

