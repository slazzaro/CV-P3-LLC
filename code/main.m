%function [ imgTrain, imgTest, trainLblVector, testLblVector] = main( mainDir ,imgCount)
function [ testLblVector, predictLblVector1, predictLblVector2, mat1, mat2, order1, order2, decision_values] = main( mainDir ,imgCount)

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
    
    trainLblVector=double(trainLblVector);
    trainfeatureVector=sparse(double(trainfeatureVector));
    testLblVector=double(testLblVector);
    testfeatureVector=sparse(double(testfeatureVector));
    
    addpath('../liblinear/matlab');
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Training model on LIBLINEAR'));        
    model = train(trainLblVector, trainfeatureVector);        
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Predict on LIBLINEAR'));    
    [predictLblVector1, accuracy, decision_values] = predict(testLblVector, testfeatureVector, model);
    rmpath('../liblinear/matlab');
    
    accuracy
    [ mat1, order1 ] = confusionMat(testLblVector, predictLblVector1);    
    
    addpath('../multiSVM');
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Training model on multiSVM'));    
    [res] = multisvm(trainfeatureVector,trainLblVector,testfeatureVector) %predict(testLblVector, testfeatureVector, model);
    rmpath('../multiSVM');
    
    d_Mat=zeros(testImgCount,scenceCount);
    
%     
%     for p=1:scenceCount
%         addpath('../libsvm/matlab');
%         display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Training model on LIBSVM for Scene # '));  
%         subTrainVector=zeros(testImgCount);
%         for q=1:testImgCount
%             if trainLblVector(q) == p
%                 subTrainVector(q)=1;
%             else
%                 subTrainVector(q)=0;
%             end
%         end
%         model = svmtrain( trainfeatureVector ,trainLblVector);         
%         %model = svmtrain(trainLblVector, trainfeatureVector );     
%         display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Predict on LIBSVM for Scene # '));    
%         [predictLblVector2, accuracy, decision_values] = svmpredict(testLblVector, testfeatureVector, model);
%         rmpath('../libsvm/matlab');        
%     end    
%    
%     
%     accuracy
%     [ mat2, order2 ] = confusionMat(testLblVector, predictLblVector2);
%     

predictLblVector2=1;
mat2=0;
order2=0;
    %deleteData(mainDir);
end
