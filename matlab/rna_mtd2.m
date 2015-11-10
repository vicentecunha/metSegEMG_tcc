% Implementacao do MTD2 com parametros fixos
% e resultados de classificacao utilizando RNA
close all
clear

%% Parametros utilizados

l = 10e3;
A = 30;
B = 8;
C = 2;

%% Base de dados Ninapro

ninaproList = ls('database/ninapro2/S*_E1*');
numberOfSubjects = length(ninaproList);
numberOfChannels = 12;

%% Implementacao com treinamento interno a cada voluntario

numberOfFeatures = 3;
numberOfMoves = 17;
predictorsCellArray = cell(1, numberOfSubjects);
targetsCellArray = cell(1, numberOfSubjects);
internalClassificationCellArray = cell(1, numberOfSubjects);
centerLocsCellArray = cell(1, numberOfSubjects);
numberOfSegPerMove = zeros(numberOfSubjects,numberOfMoves);
trainingRecords = struct();
for currentSubject = 1:numberOfSubjects    
    fprintf('currentSubject = %i / %i\n', currentSubject, numberOfSubjects)
    % Carrega o voluntario atual
    load (['database/ninapro2/' ninaproList(currentSubject,:)])
    
    % Segmentacao
    [x_seg, centerLocsCellArray{1, currentSubject}] = ...
        seg_mtd2(emg, l, A, B,C);
    
    % Alvos para treinamento da rede neural
    targetsCellArray{1, currentSubject} = ...
        identifyClasses(centerLocsCellArray{1,currentSubject},stimulus);
    
    % Numero de segmentos por movimento
    numberOfSegPerMove(currentSubject,:) = sum(targetsCellArray{1, currentSubject});
    % Divisao de dados para treinamento
    numberOfSegments = length(centerLocsCellArray{1,currentSubject});
    trainIndFlags = false(numberOfSegments,1);
    valIndFlags = false(numberOfSegments,1);
    testIndFlags = false(numberOfSegments,1);
    for currentMove = 1:numberOfMoves
        counter = 0;
        for currentSegment = 1:numberOfSegments
            if targetsCellArray{1,currentSubject}(currentSegment,currentMove)
                counter = counter + 1;
                if counter < 5
                    trainIndFlags(currentSegment) = true;
                else if counter == 5
                        valIndFlags(currentSegment) = true;
                    else if counter > 5
                            testIndFlags(currentSegment) = true;
                        end
                    end
                end
            end
        end
    end
    trainInd = find(trainIndFlags);
    valInd = find(valIndFlags);
    testInd = find(testIndFlags);
    
    % Preditores da RNA   
    predictorsCellArray{1, currentSubject} = ...
        zeros(numberOfSegments, numberOfFeatures*numberOfChannels);
    for currentSegment = 1:numberOfSegments
        for currentChannel = 1:numberOfChannels
            % RMS
            predictorsCellArray{1, currentSubject}...
                (currentSegment, currentChannel + 0*numberOfChannels) = ...
                rms(x_seg{currentSegment, currentChannel});
            % Variancia
            predictorsCellArray{1, currentSubject} ...
                (currentSegment, currentChannel + 1*numberOfChannels) = ...
                var(x_seg{currentSegment, currentChannel});
            % Frequencia mediana
            predictorsCellArray{1, currentSubject} ...
                (currentSegment, currentChannel + 2*numberOfChannels) = ...
                medfreq(x_seg{currentSegment, currentChannel});
        end
    end
    
    % Treinamento de rede neural
    net = patternnet(10,'trainscg');
    net.divideFcn = 'divideind';
    net.divideParam.trainInd = trainInd;
    net.divideParam.valInd = valInd;
    net.divideParam.testInd = testInd;
    [internalTrainedNet, trainingRecords(currentSubject).tr] = train(net, ...
        predictorsCellArray{1, currentSubject}', ...
        targetsCellArray{1, currentSubject}');
    % Classificacao
    internalClassificationCellArray{1, currentSubject} = ...
        internalTrainedNet(predictorsCellArray{1,currentSubject}');

    % Plot da matriz de confusao
    plotconfusion(targetsCellArray{1, currentSubject}', ...
        internalClassificationCellArray{1, currentSubject}, ...
        ['Current Subject: ' num2str(currentSubject) ...
        ' Segmentation Method: MTD2'])
    savefig(['./out/confusion/S' num2str(currentSubject) '_MTD2.fig'])
end
save('./out/workspace/rna_MTD2.mat') % salva a workspace atual