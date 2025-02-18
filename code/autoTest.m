function [  ] = autoTest( mainDir ,imgCount )
for pyramidLevels = [3 5]
    for k = [ 5]
        for numTextonImages = [50 100]
            for isKer = [1 0]  %dont modify
                for patchSize =[16 32 8]
                    for gridSpacing =[8 16 4]
                        for dictionarySize = [2048 1024]
                            
                            %                     MainSuper( mainDir ,imgCount, testName, useLLC, useKer, ...
                            %                            delOld, dictionarySize, pyramidLevels, ...
                            %                            numTextonImages, patchSize, gridSpacing, k)
                            
                            %                     MainSuper('/u/s/a/saikat/public/html/Sp13/cs766/P3-LLC/scene_categories',
                            %                                 100,'srgtest1',0,1,
                            %                                 1,1024,3,
                            %                                 50,16,8,5);
                            
                            timeStamp=datestr(now,'HH-MM-SS');
                            
                            testName=strcat('srg_N_D',num2str(dictionarySize), ...
                                '_P',num2str(pyramidLevels), ...
                                '_k',num2str(k), ...
                                '_N',num2str(numTextonImages), ...
                                '_p',num2str(patchSize), ...
                                '_g',num2str(gridSpacing), ...
                                '_Ker',num2str(isKer), ...
                                '_T',timeStamp);
                            
                            display(strcat(datestr(now,'HH:MM:SS'),' [INFO] test case "',testName,'"'));
                            MainSuper( mainDir ,imgCount, testName, 0, isKer, ...
                                1, dictionarySize, pyramidLevels, ...
                                numTextonImages, patchSize, gridSpacing, k);
                            
                            
                            % % % % % % % % %         timeStamp=datestr(now,'HH-MM-SS');
                            % % % % % % % % %
                            % % % % % % % % %         testName=strcat('L_D',num2str(dictionarySize), ...
                            % % % % % % % % %             '_P',num2str(pyramidLevels), ...
                            % % % % % % % % %             '_k',num2str(k), ...
                            % % % % % % % % %             '_N',num2str(numTextonImages), ...
                            % % % % % % % % %             '_p',num2str(patchSize), ...
                            % % % % % % % % %             '_g',num2str(gridSpacing), ...
                            % % % % % % % % %             '_Ker',num2str(isKer), ...
                            % % % % % % % % %             '_T',timeStamp);
                            % % % % % % % % %
                            % % % % % % % % %         display(strcat(datestr(now,'HH:MM:SS'),' [INFO] test case "',testName,'"'));
                            % % % % % % % % %         MainSuper( mainDir ,imgCount, testName, 1, isKer, ...
                            % % % % % % % % %                    1, dictionarySize, pyramidLevels, ...
                            % % % % % % % % %                    numTextonImages, patchSize, gridSpacing, k);
                            
                            
                        end
                    end
                end
            end
        end
    end
end
end

