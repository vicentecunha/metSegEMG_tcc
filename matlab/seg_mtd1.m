%% MTD1 - metodo iterativo utilizando thresholding para deteccao de centros de
% 	 segmentos de comprimento constante                                   	
%                                                                           
% Argumentos:                                                               
%   x - matriz cujas colunas sao canais do sinal a ser segmentado           
%   l - comprimento desejado para os segmentos                              
%   q - razao de atualizacao entre iteracoes para valor de threshold        
%   r_target - razao minima esperada entre numero de segmentos e comprimento
%		total de sinal                                                      
%   T_lim - valor de limite inferior para threshold                         
%                                                                           
% Retorno:                                                                     
%   x_seg - cell array com os canais segmentados                               
%%                                                                           

function x_seg = seg_mtd1(x, l, q, r_target, T_lim)

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

    % Valor inicial de threshold corresponde ao maximo do sinal
    T_k = max(x_filt); 

	% Processo iterativo
    targetReached = false;
	while ~targetReached
	
		% Calcula threshold desta iteracao
        T_k = q*T_k; 
        
		% Verifica se limite de valor de threshold foi atingido
        if T_k < T_lim
            warning('Threshold limit reached. Stopping iterations.')
            break
        end
            
        % Identifica candidatos a centros de segmentos
        [centerValues, centerLocs] = findpeaks(double(x_filt), ...
           'MinPeakHeight', T_k, 'MinPeakDistance',l);
        
        % Determina o encerramento do processo iterativo
         targetReached = (length(centerLocs)/L > r_target);
		 
	end
    
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