% This code implements Min-Sum decoding and finds a valid codeword 

clc;
clear;

% Generate a random parity-check matrix H
while true
    H = randi([0, 1], 3, 6); % Random binary matrix
    if all(sum(H, 1) >= 1) && all(sum(H, 2) >= 2) % Check valid connections
        break;
    end
end

% Assign random LLRs (Gaussian noise around 0)
L = randn(6, 1); % Random LLRs 


max_iter = 10;	% Max iterations


[num_cns, num_vns] = size(H);
R = zeros(num_cns, num_vns); % CN-to-VN messages
L_total = L; % Total LLR for each VN

fprintf('Random H matrix:\n'); disp(H);
fprintf('Initial LLR: '); disp(L_total');

% Min-Sum Decoding
for iter = 1:max_iter
    % Step 1 VN-to-CN messages 
    L_vn_to_cn = zeros(num_cns, num_vns);
    for i = 1:num_vns
        connected_cns = find(H(:, i));
        for j = connected_cns'
            other_cns = setdiff(connected_cns, j);
            L_vn_to_cn(j, i) = L(i) + sum(R(other_cns, i));
        end
    end

    % Step 2 CN-to-VN messages 
    for j = 1:num_cns
        connected_vns = find(H(j, :));
        for i = connected_vns
            other_vns = setdiff(connected_vns, i);
            signs = sign(L_vn_to_cn(j, other_vns));
            min_abs = min(abs(L_vn_to_cn(j, other_vns)));
            R(j, i) = prod(signs) * min_abs;
        end
    end

    % Step 3: Update total LLR 
    for i = 1:num_vns
        connected_cns = find(H(:, i));
        L_total(i) = L(i) + sum(R(connected_cns, i));
    end

    fprintf('Iter %d LLR: ', iter); disp(L_total');
    
    % Early termination if (H.c = zeros) condition is satisfied 
    c_hat = (L_total < 0);
    syndrome = mod(H * c_hat, 2);
    if all(syndrome == 0)
        fprintf('Valid codeword found!\n');
        fprintf('Final Codeword: '); disp(c_hat');
        break;
    end
end