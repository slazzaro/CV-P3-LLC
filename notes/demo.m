% demo code to solve Eq.7 in the LLC paper
clear; clc; close all;

N = 100;  % feature dimension
K = 5;  % number of nearest neighbours

% construct codebook
B = randn( K, N);

% create truth code
c = randn(K, 1);
c = c /sum(c);

% compute feature
x = B'*c;
one = ones(K, 1);

% compute data covariance matrix
B_1x = B - one *x';
C = B_1x * B_1x';

% reconstruct LLC code
c_hat = C \ one;
c_hat = c_hat /sum(c_hat);

c
c_hat
% compute reconstruction error
diff = norm(c-c_hat)





