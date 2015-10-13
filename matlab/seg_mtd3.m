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

function x_seg = seg_mtd3(x, B, C)

%% Preprocessamento

	% Obtem comprimento do sinal e numero de canais
    [L, numberOfChannels] = size(x);
    
    % Retificacao de sinal
    x_ret = abs(x);
     
 	% Suavizacao utilizando media movel
	x_smooth = reshape(smooth(x_ret, 32), L, numberOfChannels);
    
%% Metodo

    % Array logico para BEPs e EEPs detectados
    BEPsFlags = false(L,1);
    EEPsFlags = false(L,1);
    
    % Indicador se a janela procura por BEP ou EEP
    searchBEP = true;
    
	% Janela deslizante
	for w0 = 1:L-W
        if( (mean(diff(x_filt(w0:w0+W-1))) > B) && searchBEP ) % Deteccao de BEP
            BEPsFlags(w0) = 1;
            searchBEP = false;
        end
        if( (sum(diff(x_filt(w0:w0+W-1))) < C) && ~searchBEP ) % Deteccao de EEP
            EEPsFlags(w0+W-1) = 1;
            searchBEP = true;
        end
	end
    
    % Posicoes de EEPs e BEPs
    BEPsLocs = find(BEPsFlags);
    EEPsLocs = find(EEPsFlags);
    
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