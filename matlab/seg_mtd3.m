function [x_seg, finalCenterLocs] = seg_mtd3(x, l_min, l_max, W, B, C)
%   MTD3 - metodo com janela deslizante para deteccao de BEP e EEP de segmentos
%	utilizando variacao total                           		
%                                                                
% Argumentos: (para mais detalhes, refira a descricao do MTD3)                                                   
%   x - matriz cujas colunas sao canais do sinal a ser segmentado
%   l_min - compimento mínimo para segmentos
%   l_max - compimento máximo para segmentos
%	W - comprimento da janela deslizante utilizada pelo metodo
%       (deve ser inteiro maior que zero)
%   B - valor limite para variacao total que determina um BEP
%       (deve ser maior que zero)
%   C - valor limite para variacao total que determina um EEP
%       (deve ser menor que zero)
%                                                                
% Retorno:                                                       
%   x_seg - cell array com os canais segmentados
%   finalCenterLocs - posicoes centrais dos segmentos

%% Preprocessamento

[L, numberOfChannels] = size(x); % comprimento do sinal e numero de canais
x_ret = abs(x); % retificacao
x_norm = zeros(L, numberOfChannels); % normalizacao
for currentChannel = 1:numberOfChannels
    x_norm(:,currentChannel) = ...
        x_ret(:,currentChannel)./max(x_ret(:,currentChannel));
end

%% Metodo

totalVariation = zeros(L-W,numberOfChannels);
BEPsLocsFlags = false(W,numberOfChannels);
EEPsLocsFlags = false(W,numberOfChannels);
BEPsLocsCell = cell(1,numberOfChannels);
EEPsLocsCell = cell(1,numberOfChannels);
searchBEP = true(numberOfChannels,1);
lastBEPloc = zeros(numberOfChannels,1);
for w0 = 1:L-W % janela deslizante para cálculo de variação total
    for currentChannel = 1:numberOfChannels
        totalVariation(w0, currentChannel) =...
            sum(diff(x_norm(w0:w0+W, currentChannel)));
        % Identificação de BEPs e EEPs
        switch searchBEP(currentChannel)
            case true % deteccao de BEPs
                if totalVariation(w0, currentChannel) > B
                    BEPsLocsFlags(w0,currentChannel) = true;
                    lastBEPloc(currentChannel) = w0;
                    searchBEP(currentChannel) = false;
                end
            case false % deteccao de EEPs
                if (w0+W-lastBEPloc(currentChannel))>l_max
                    % segmento excederia comprimento máximo
                    BEPsLocsFlags(lastBEPloc(currentChannel),currentChannel) = false;
                    searchBEP(currentChannel) = true;
                else if (totalVariation(w0, currentChannel) < C) && ...
                            (w0+W-lastBEPloc(currentChannel)>l_min)
                        EEPsLocsFlags(w0+W,currentChannel)=true;
                        searchBEP(currentChannel) = true;
                    end
                end
        end
    end
end
for currentChannel = 1:numberOfChannels
    BEPsLocsCell{1,currentChannel} = ...
        find(BEPsLocsFlags(:,currentChannel,currentCombination));
    EEPsLocsCell{1,currentChannel} = ...
        find(EEPsLocsFlags(:,currentChannel,currentCombination));
end

%% Clustering

BEPsLocsArray = sort(cell2mat(BEPsLocsCell'));
EEPsLocsArray = sort(cell2mat(EEPsLocsCell'));
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
endReached = false;
currentLoc = 1;
while ~endReached
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
    if currentLoc > length(allLocs)
        endReached = true;
    end
end
if lastLocWasBEP % detecção de BEP sem EEP ao final do sinal
    allLocs(end,:) = [];
end
finalBEPs = allLocs(allLocs(:,2) == true, 1);
finalEEPs = allLocs(allLocs(:,2) == false, 1);

%% Segmentacao dos canais

numberOfSegments = length(finalBEPs);
finalCenterLocs = zeros(numberOfSegments,1);
x_seg = cell(numberOfSegments,numberOfChannels);
for currentChannel = 1:numberOfChannels
    for currentSegment = 1:numberOfSegments
        x_seg{currentSegment,currentChannel} = ...
            x(finalBEPs(currentSegment):finalEEPs(currentSegment));
        finalCenterLocs(currentSegment) = ...
            round(mean([finalBEPs(currentSegment),finalEEPs(currentSegment)]));
    end
end

end
