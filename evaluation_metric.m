% This file is to compare the influence of evaluation metirc
%% Load data
% This data set cannot be made public. If you need to access, please contact the authors.
load("eco_old_original.mat")

ecodataoriginal( ~any(ecodataoriginal,2), : ) = [];% clean the row with no data
ecodataoriginal(  :, ~any(ecodataoriginal,1)) = [];% clean the column with no data
data = ecodataoriginal.';
[m,n]=size(data); % process*flow

% the parameter to be changed to calculate different percentage of missing data
s=2; 
% define the percentage of missing data
p=[0.01,0.05,0.1,0.2,0.5,0.8];

% missing number of data under 5%
x0=ceil(p(s)*n); 
rng default
mi_ind = randperm(n,x0);
data_mi=data(:,mi_ind);
data_re=data;
% Remove data at missing data positions
data_re(:,mi_ind)=[];

%% choose 2046 processes ofr trainingset and 500 processes for testset
sample_size = 500;
rng default
sample_ind = randperm(m,sample_size);

data(sample_ind,:) = [];
data_mi(sample_ind,:)=[];
data_re(sample_ind,:)=[];

%% Construct missing data' structure
% missing-data's structure
data_mi_str = (data_mi~=0);
data_mi_str = data_mi_str.';

%% Find the model's MPE under each set of (q,k)
q = 0.01:0.01:0.2;
% Test the quantity of process 'k' that is most similar
l = 1:50; 


MPE_mean = zeros(length(q),length(l));
MPE_median = zeros(length(q),length(l));

for t = 1:size(q, 2)
    % Calculate the Minkowski distance between data_re and itself using parameter q(t)
    D = pdist2(data_re, data_re, 'minkowski', q(t));
    S = 1.0 ./ (1 + D);

    % Initialize matrices for storing results
    [B, I] = sort(S, 1, 'descend'); % Sort values in descending order in each column
    B(1, :) = []; % Remove the top row (self-comparison)
    I(1, :) = []; % Remove the top row (self-comparison)
    E = zeros(x0, length(l), m - sample_size); % Matrix for storing results
    E_1 = zeros(x0, m - sample_size);

    % Loop through the data
    for w = 1:size(data, 1)
        count = 1;
        for k = l
            % Calculate Extimation of nonzero values
            E_1(:, w) = data(I(1:k, w), mi_ind)' * B(1:k, w) ./ sum(B(1:k, w), 1);
            E(:, count, w) = E_1(:, w) .* data_mi_str(:, w);
            % Calculate MPE of nonzero values
            MPE(w, count) = sqrt(sum((E(:, count, w)' - data_mi(w, :)).^2)) / sqrt(sum(data_mi(w, :).^2));
            count = count + 1;
        end
    end

    % Remove rows in MPE that are all zeros (i.e., processes with no variation)
    MPE_t = MPE(any(MPE, 2), :);
    % Remove rows in MPE_t where all values are NaN (k=1, processes with no variation)
    MPE_t(isnan(MPE_t(:, 1)), :) = [];
    % Remove rows in MPE_t where all values are Inf (k=1, processes with no variation)
    MPE_t(isinf(MPE_t(:, 1)), :) = [];
    % Calculate mean and median values for MPE_t
    MPE_mean(t, :) = mean(MPE_t, 1, 'omitnan'); % An overall evaluation of predictions for all processes
    MPE_median(t, :) = median(MPE_t, 1, 'omitnan'); % An overall evaluation of predictions for all processes
end


%% Plot the graph for Mean MPE

% Find the parameters (q,k) of the best model
[x1,y1]=find(MPE_mean==min(min(MPE_mean)));

% Plot the graph
imagesc(MPE_mean)
set(gca,'YDir','normal')
hold on
plot(y1,x1,'r*')

% Set axis and title
xticks([1 10 20 30 40 50])
set(gca,'YTick',50:50:250)
set(gca,'YTickLabel',q(50):0.0200:q(250))
colorbar
xlabel('k','FontSize', 20);
ylabel('q','FontSize', 20);
title('Nonzero 5% missing: mean','FontSize', 22);
set(gca, 'FontSize', 12);

%% Plot the graph for Median MPE
% Find the parameters (q,k) of the best model
[x2,y2]=find(MPE_median==min(min(MPE_median)));

% Plot the graph
imagesc(MPE_median)
set(gca,'YDir','normal')
hold on
plot(y2,x2,'r*')

% Set axis and title
xticks([1 10 20 30 40 50])
set(gca,'YTick',50:50:250)
set(gca,'YTickLabel',q(50):0.0200:q(250))
colorbar
caxis([0 1])
xlabel('k','FontSize', 20);
ylabel('q','FontSize', 20);
title('Nonzero 5% missing: median','FontSize', 22);
set(gca, 'FontSize', 12);









