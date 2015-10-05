%% MTD4 - metodo com janela deslizante para deteccao de BEP e EEP de segmentos
%	utilizando thresholding                                		
%                                                                
% Argumentos:                                                    
%   x - matriz cujas colunas sao canais do sinal a ser segmentado
%	W - comprimento da janela deslizante utilizada pelo metodo	
%   T - valor de threshold                                      
%                                                                
% Retorno:                                                       
%   x_seg - cell array com os canais segmentados                 
%%

function x_seg = seg_mtd4(x, W, T)

%% Preprocessamento

	% Obtem comprimento do sinal e numero de canais
    [L, numberOfChannels] = size(x);
    
    % Retificacao de sinal
    x_ret = abs(x);
    
    % Soma dos canais
    x_sum = zeros(L,1);
    for currentChannel = 1:numberOfChannels
        x_sum = x_sum + x_ret(:,currentChannel);
    end
    
    % FIR passa-baixas em 20 Hz
    x_filt = filter(fir1(255,0.01),1,x_sum);
    
%% Metodo

    % Array logico para BEPs e EEPs detectados
    BEPsFlags = false(L,1);
    EEPsFlags = false(L,1);
    
    % Indicador se a janela procura por BEP ou EEP
    searchBEP = true;
    
	% Janela deslizante
	for w0 = 1:L-W
        if( ~(max(x_filt(w0:w0+W-1)) < T) && searchBEP ) % Deteccao de BEP
            BEPsFlags(w0) = 1;
            searchBEP = false;
        end
        if( (max(x_filt(w0:w0+W-1)) < T) && ~searchBEP ) % Deteccao de EEP
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