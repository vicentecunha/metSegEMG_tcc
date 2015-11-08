function [x_seg, finalCenterLocs] = seg_mtd3(x, l_min, l_max, W, B, C)
%   MTD3 - metodo com janela deslizante para deteccao de BEP e EEP de segmentos
%	utilizando variacao total                           		
%                                                                
% Argumentos: (para mais detalhes, refira a descricao do MTD3)                                                   
%   x - matriz cujas colunas sao canais do sinal a ser segmentado
%   l_min - compimento m�nimo para segmentos
%   l_max - compimento m�ximo para segmentos
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
for currentChannel = 1:numberOfChannels
    searchBEP = true;
    for w0 = 1:L-W % janela deslizante para c�lculo de varia��o total
        totalVariation(w0, currentChannel) =...
            sum(diff(x_norm(w0:w0+W, currentChannel)));
        % Identifica��o de BEPs e EEPs
        switch searchBEP
            case true % deteccao de BEPs
                if(totalVariation(w0, currentChannel) > B)
                    BEPsLocsFlags(w0, currentChannel) = true;
                    lastBEPloc = w0;
                    searchBEP = false;
                end
            case false % deteccao de EEPs
                if w0+W - lastBEPloc > l_max
                    % segmento excederia comprimento m�ximo
                    BEPsLocsFlags(lastBEPloc, currentChannel) = false;
                    searchBEP = true;
                else if (totalVariation(w0, currentChannel) < C) && ...
                            (w0+W - lastBEPloc > l_min)
                        EEPsLocsFlags(w0+W, currentChannel) = true;
                        searchBEP = true;
                    end
                end
        end
    end
    BEPsLocsCell{1,currentChannel} = find(BEPsLocsFlags(:,currentChannel));
    EEPsLocsCell{1,currentChannel} = find(EEPsLocsFlags(:,currentChannel));
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

%% Segmentacao

% Pareamento final de BEPs e EEPs (devem ocorrer alternadamente)
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
            currentLoc = currentLoc + 1; % avan�a �ndice
        end
    end
    lastLocWasBEP = currentLocIsBEP;
    if currentLoc > length(allLocs)
        endReached = true;
    end
end
if lastLocWasBEP % detec��o de BEP sem EEP ao final do sinal
    allLocs(end,:) = [];
end
finalBEPs = allLocs(allLocs(:,2) == true, 1);
finalEEPs = allLocs(allLocs(:,2) == false, 1);

% Segmentacao dos canais
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
