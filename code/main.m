%function [ imgTrain, imgTest, trainLblVector, testLblVector] = main( mainDir ,imgCount)
function [ testLblVector, predictLblVector1, predictLblVector2, mat1, mat2, order1, order2, decision_values] = main( mainDir ,imgCount, isSaved)

    if(isSaved==1)        
        load('vars/trainLblVector.mat');
        load('vars/testLblVector.mat');
        load('vars/testfeatureVector.mat');
        load('vars/trainfeatureVector.mat');
        load('vars/sceneNameList.mat');
    else
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

        save('vars/trainLblVector.mat','trainLblVector');
        save('vars/testLblVector.mat','testLblVector');
        save('vars/testfeatureVector.mat','testfeatureVector');
        save('vars/trainfeatureVector.mat','trainfeatureVector');
        save('vars/sceneNameList.mat','sceneNameList');
    end
        
    addpath('../liblinear/matlab');
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Training model on LIBLINEAR'));        
    model = train(trainLblVector, trainfeatureVector);        
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Predict on LIBLINEAR'));    
    [predictLblVector1, accuracy, decision_values] = predict(testLblVector, testfeatureVector, model);
    rmpath('../liblinear/matlab');
    
    accuracy
    [ mat1, order1 ] = confusionMat(testLblVector, predictLblVector1);  
    
    save('vars/predictLblVector1.mat','predictLblVector1');
    save('vars/mat1.mat','mat1');
    save('vars/order1.mat','order1');
        
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Training model on multiSVM'));    
    [predictLblVector2] = multiSVM(trainfeatureVector,trainLblVector,testfeatureVector);
    [ mat2, order2 ] = confusionMat(testLblVector, predictLblVector2);
    
    save('vars/predictLblVector2.mat','predictLblVector2');
    save('vars/mat2.mat','mat2');
    save('vars/order2.mat','order2');
    
    [ a1 ] = calcMeanAccuracy(15, testLblVector, predictLblVector1)
    [ a2 ] = calcMeanAccuracy(15, testLblVector, predictLblVector2)    
    
    save('vars/a1.mat','a1');
    save('vars/a2.mat','a2');
    
%     addpath('../multiSVM');
%     display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Training model on multiSVM'));    
%     [res] = multisvm(trainfeatureVector,trainLblVector,testfeatureVector) 
%     %predict(testLblVector, testfeatureVector, model);
%     rmpath('../multiSVM');
 

% predictLblVector2=1;
% mat2=0;
% order2=0;
    %deleteData(mainDir);
end
