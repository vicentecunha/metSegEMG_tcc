%% MTD2 - metodo nao iterativo utilizando thresholding para deteccao de
% 	centros de segmentos de comprimento constante                           
%                                                                           
% Argumentos:                                                               
%   x - matriz cujas colunas sao canais do sinal a ser segmentado           
%   l - comprimento desejado para os segmentos                              
%   A - coeficiente utilizado para decisao de metodo de calculo de threshold
%   B - multiplo da media aritmetica do sinal x para obtencao de threshold	
%   C - fracao do valor maximo do sinal x para calculo de threshold			
%                                                                           
% Retorno:                                                                   
%   x_seg - cell array com os canais segmentados                             
%%

function x_seg = seg_mtd2(x, l, A, B, C)

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
    
	% Calculo do threshold
    if(max(x_filt) > A*mean(x_filt))
		T = B*mean(x_filt);
	else
		T = max(x_filt)/C;
    end
	
	% Identifica centros de segmentos
    [centerValues, centerLocs] = findpeaks(x_filt, ...
        'MinPeakHeight', T, 'MinPeakDistance',l);
    
    % Eliminacao de centros que estao muito aos extremos do sinal
    if(centerLocs(1) < l/2)
        centerLocs(1) = [];
        centerValues(1) = [];
    end
    if(L - centerLocs(end) < l/2)
        centerLocs(end) = [];
        centerValues(end) = [];
    end
    
    % Segmentacao dos canais
    numberOfSegments = length(centerLocs);
    x_seg = cell(numberOfSegments,numberOfChannels);
    for currentChannel = 1:numberOfChannels
        for currentSegment = 1:numberOfSegments
            x_seg{currentSegment,currentChannel} = ...
                x(centerLocs - l/2: centerLocs+l/2-1,currentChannel);
        end
    end
    
end