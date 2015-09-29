%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% MTD1 - método iterativo utilizando thresholding para detecção de centros    %
% 	de segmentos de comprimento constante                                     %
%                                                                             %
% Argumentos:                                                                 %
%   x - matriz column-wise com os sinais a serem segmentados                  %
%   l - comprimento desejado para os segmentos                                %
%   q - razão de atualização entre iterações para valor de threshold          %
%   r_target - razão mínima esperada entre número de segmentos e comprimento  %
%		total de sinal                                                        %
%   T_lim - valor de limite inferior para threshold                           %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x_seg = seg_mtd1(x, l, q, r_target, T_lim)

    T0 = max(x); % Máximo dos canais é o valor inicial de threshold
    [L, num_channels] = size(x); % Obtém comprimento de sinais e número de canais
        
    for current_channel = 1:num_canais % Segmentação para cada um dos canais

		T_k = T0(current_channel); % Threshold inicial
        
		% Processo iterativo:
        target_reached = false;
		while ~target_reached
		
            T_k = q*T_k; % Calcula threshold desta iteração
            
            if T_k < T_lim % Limite de valor de threshold atingido
                break
            end
                
            % Identifica os possíveis candidatos para centros de segmentos
            [~, centers_locs_current_channel] = findpeaks(x(:,current_channel), ...
               'MinPeakHeight', T_k, 'MinPeakDistance',l);
            
            % Determina o encerramento do processo iterativo
             target_reached = (length(centers_locs_current_channel)/L > N);

		end
    end
end