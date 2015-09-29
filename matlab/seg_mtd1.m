%%
% MTD1 - método iterativo utilizando thresholding para detecção de centros
% de segmentos de comprimento constante
%
%   Argumentos:
%   x - matriz column-wise com os sinais a serem segmentados
%   l - comprimento desejado para os segmentos
%   q - razão de atualização entre iterações para valor de threshold
%   r_target - ..
%   T_lim - valor de limite inferior para Threshold

function x_seg = seg_mtd1(x, l, q, r_target, T_lim)
    % Valor inicial de threshold corresponde aos máximos dos sinais
    T0 = max(x);
    % Obtém número de canais
    [L, num_canais] = size(x);
        
    % Realiza segmentação para cada um dos canais
    for current_channel = 1:num_canais
        % Threshold inicial
        T_k = T0(current_channel);
        
        % Variável lógica para determinar o final do método iterativo
        target_reached = false;
        while ~target_reached
            % Calcula threshold desta iteração
            T_k = q*T_k;
            % Limite de valor de threshold atingido
            if T_k < T_lim
                break;
            end
                
            % Identifica os possíveis candidatos para centros de segmentos
            [~, centers_locs_current_channel] = findpeaks(x(:,current_channel), ...
               'MinPeakHeight', T_k, 'MinPeakDistance',l);
           
            % Verificação do número de candidatos a centro identificados
            if(length(centers_locs_current_channel) > N)
                error('Número de possíveis centros identificados maior que o N fornecido.')
            end
            
            % Determina o encerramento do processo iterativo
             target_reached = (length(centers_locs_current_channel)/L > N);
        end
        
        % Armazena os centros de segmentos para o canal atual
        index = zeros(length(centers_locs_current_channel),1);
        index(:) = current_channel;
        centers_locs = [centers_locs; index centers_locs_current_channel];
    end
end