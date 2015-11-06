%%
%   MTD3 - metodo com janela deslizante para deteccao de BEP e EEP de segmentos
%	utilizando variacao total                           		
%                                                                
% Argumentos: (para mais detalhes, refira a descricao do MTD3)                                                   
%   x - matriz cujas colunas sao canais do sinal a ser segmentado
%	W - comprimento da janela deslizante utilizada pelo metodo
%       (deve ser inteiro maior que zero)
%   B - valor limite para declividade media que determina um BEP
%       (deve ser maior que zero)
%   C - valor limite para variacao total que determina um EEP
%       (deve ser maior que zero)
%                                                                
% Retorno:                                                       
%   x_seg - cell array com os canais segmentados
%   centerLocs - posicoes centrais dos segmentos
%%

function x_seg = seg_mtd3(x, W, B, C)

%% Preprocessamento

% Obtem comprimento do sinal e numero de canais
[L, numberOfChannels] = size(x);

% Retificacao
x_ret = abs(x);

% Normalizacao
x_norm = zeros(L, numberOfChannels);
for currentChannel = 1:numberOfChannels
    x_norm(:,currentChannel) = ...
        x_ret(:,currentChannel)./max(x_ret(:,currentChannel));
end

%% Metodo

% Arrays lógicos para armazenar posicoes dos segmentos identificados
BEPsLocsFlags = false(L,numberOfChannels);
EEPsLocsFlags = false(L,numberOfChannels);
meanSlope = zeros(L,numberOfChannels);

for currentChannel = 1:1    
    fprintf('currentChannel = %i\n', currentChannel)
    searchBEP = true; % indicador se o método busca por BEP ou EEP
    for w0 = 1:L-W % janela deslizante
        meanSlope(w0, currentChannel) = sum(diff(x_norm(w0:w0+W)));
        switch searchBEP
            case true % deteccao de BEP
                if(meanSlope(w0, currentChannel) > B)
                    fprintf('BEP detected.\n')
                    BEPsLocsFlags(w0, currentChannel) = true;
                    searchBEP = false;
                end
            case false % deteccao de EEP
                if(meanSlope(w0, currentChannel) < C) 
                    fprintf('EEP detected.\n')
                    EEPsLocsFlags(w0+W, currentChannel) = true;
                    searchBEP = true;
                end
        end 
    end
end

% Posicoes de EEPs e BEPs
BEPsLocs = find(BEPsLocsFlags);
EEPsLocs = find(EEPsLocsFlags);

% Caso tenha sido detectada uma BEP sem respectivo EEP, elimina ultimo BEP
numberOfSegments = length(BEPsLocs);
if( numBEPs > length(EEPsLocs))
    BEPsLocs(end) = [];
end

% Segmentacao dos canais
x_seg = cell(numberOfSegments,numberOfChannels);
for currentChannel = 1:numberOfChannels
    for currentSegment = 1:numberOfSegments
        x_seg{currentSegment,currentChannel} = ...
            x(BEPsLocs(currentSegment):EEPsLocs(currentSegment));
    end
end

end
