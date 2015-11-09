% Implementação do MTD3 com variação de parâmetros 
% e medida do número de segmentos obtidos por movimento
close all
clear

%% Parâmetros utilizados

% Predeterminados
l_min = 7.5e3;
l_max = 12.5e3;
W = 5e3;
step = 500;

% Combinações a serem testadas
B = [0.01 0.02 0.03 0.04];
C = [-0.01 -0.02 -0.03 -0.04];
combinations = combvec(B, C)';
numberOfCombinations = length(combinations);

%% Base de dados Ninapro

ninaproList = ls('database/ninapro2/S*_E1*');
numberOfSubjects = length(ninaproList);
numberOfClasses = 17;

%% Teste das diferentes combinações

segMeanNumber = zeros(numberOfCombinations,numberOfSubjects,numberOfClasses);
for currentSubject = 1:numberOfSubjects
    fprintf('currentSubject = %i / %i\n', currentSubject, numberOfSubjects)
    load (['database/ninapro2/' ninaproList(currentSubject,:)])
    clear acc glove inclin
    
    %% Preprocessamento
    
    [L, numberOfChannels] = size(emg); % comprimento do sinal e numero de canais
    x_ret = abs(emg); % retificacao
    x_norm = zeros(L, numberOfChannels); % normalizacao
    for currentChannel = 1:numberOfChannels
        x_norm(:,currentChannel) = ...
            x_ret(:,currentChannel)./max(x_ret(:,currentChannel));
    end
    
    %% Metodo
    
    BEPsLocsFlags = false(W,numberOfChannels,numberOfCombinations);
    EEPsLocsFlags = false(W,numberOfChannels,numberOfCombinations);
    BEPsLocsCell = cell(numberOfCombinations,numberOfChannels);
    EEPsLocsCell = cell(numberOfCombinations,numberOfChannels);
    searchBEP = true(numberOfCombinations,numberOfChannels);
    lastBEPloc = zeros(numberOfCombinations,numberOfChannels);
   
    for w0 = 1:step:L-W % janela deslizante para cálculo de variação total
        fprintf('w0 = %i / %i\n', w0, L-W)
        for currentChannel = 1:numberOfChannels
            for currentCombination = 1:numberOfCombinations
                switch searchBEP(currentCombination,currentChannel)
                    case true % deteccao de BEPs
                        if  sum(diff(x_norm(w0:w0+W, currentChannel))) > ...
                                combinations(currentCombination,1)
                            BEPsLocsFlags(w0,currentChannel,currentCombination) = true;
                            lastBEPloc(currentCombination,currentChannel) = w0;
                            searchBEP(currentCombination,currentChannel) = false;
                        end
                    case false % deteccao de EEPs
                        if (w0+W-lastBEPloc(currentCombination,currentChannel))>l_max
                            % segmento excederia comprimento máximo
                            BEPsLocsFlags(lastBEPloc(currentCombination,currentChannel),...
                                currentChannel,currentCombination) = false;
                            searchBEP(currentCombination,currentChannel) = true;
                        else if (sum(diff(x_norm(w0:w0+W, currentChannel))) < ...
                                    combinations(currentCombination,2)) && ...
                                    (w0+W-lastBEPloc(currentCombination,currentChannel)>l_min)
                                EEPsLocsFlags(w0+W,currentChannel,currentCombination)=true;
                                searchBEP(currentCombination,currentChannel) = true;
                            end
                        end
                end
            end
        end
    end
    
    for currentChannel = 1:numberOfChannels
        for currentCombination = 1:numberOfCombinations
            BEPsLocsCell{currentCombination,currentChannel} = ...
                find(BEPsLocsFlags(:,currentChannel,currentCombination));
            EEPsLocsCell{currentCombination,currentChannel} = ...
                find(EEPsLocsFlags(:,currentChannel,currentCombination));
        end
    end
    
    %% Clustering
    
    for currentCombination = 1:numberOfCombinations
        fprintf('\tcurrentCombination = %i / %i\n', ...
            currentCombination,numberOfCombinations)
        BEPsLocsArray = sort(cell2mat(BEPsLocsCell(currentCombination,:)'));
        EEPsLocsArray = sort(cell2mat(EEPsLocsCell(currentCombination,:)'));
        [~, labscoreBEPs] = dbscan(BEPsLocsArray,2000,3);
        [~, labscoreEEPs] = dbscan(EEPsLocsArray,2000,3);
        numberOfBEPs = max(labscoreBEPs);
        numberOfEEPs = max(labscoreEEPs);
        % medias internas aos clusters
        meanBEPs = zeros(numberOfBEPs,1);
        for currentCluster = 1:numberOfBEPs
            meanBEPs(currentCluster) = ...
                round(mean(BEPsLocsArray(labscoreBEPs == currentCluster)));
        end
        meanEEPs = zeros(numberOfEEPs,1);
        for currentCluster = 1:numberOfEEPs
            meanEEPs(currentCluster) = ...
                round(mean(EEPsLocsArray(labscoreEEPs == currentCluster)));
        end
        
        %% Pareamento final de BEPs e EEPs (devem ocorrer alternadamente)
        
        allLocs = sortrows([meanBEPs,true(length(meanBEPs),1); ...
            meanEEPs,false(length(meanEEPs),1)]);
        lastLocWasBEP = false;
        currentLoc = 1;
        while true
            if currentLoc > length(allLocs(:,1))
                break;
            end
            currentLocIsBEP = allLocs(currentLoc,2);
            if currentLocIsBEP && lastLocWasBEP % BEPs repetidos
                allLocs(currentLoc-1,:) = [];
            else if ~currentLocIsBEP && ~lastLocWasBEP % EEPs repetidos
                    allLocs(currentLoc,:) = [];
                else
                    currentLoc = currentLoc + 1; % avança índice
                end
            end
            lastLocWasBEP = currentLocIsBEP;
        end
        if lastLocWasBEP % detecção de BEP sem EEP ao final do sinal
            allLocs(end,:) = [];
        end
        finalBEPs = allLocs(allLocs(:,2) == true, 1);
        finalEEPs = allLocs(allLocs(:,2) == false, 1);
        
        %% Segmentacao
        
        numberOfSegments = length(finalBEPs);
        finalCenterLocs = zeros(numberOfSegments,1);
        x_seg = cell(numberOfSegments,numberOfChannels);
        for currentChannel = 1:numberOfChannels
            for currentSegment = 1:numberOfSegments
                x_seg{currentSegment,currentChannel} = ...
                    emg(finalBEPs(currentSegment):finalEEPs(currentSegment));
                finalCenterLocs(currentSegment) = ...
                    round(mean([finalBEPs(currentSegment),finalEEPs(currentSegment)]));
            end
        end
        
        %% Identificacao do movimento correspondente a cada segmento
        
        targetClasses = identifyClasses(finalCenterLocs, stimulus);
        % numero de segmentos obtidos por movimento
        for currentClass = 1:numberOfClasses
            segMeanNumber(currentCombination,currentSubject,currentClass) = ...
                length(find(targetClasses(:,currentClass)));
        end
    end
end
save('./out/workspace/number_MTD3_part2.mat') % salva a workspace atual
