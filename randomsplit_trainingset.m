% This file is to first find the best parameters for 100 different training
% set and then calculate the performance on corresponding testsets.

%% Find the best parameters for 100 different training
C1 = cell(100, 2);
C2 = cell(100, 2);

% Set the seed for trainingsets
seed_range = 1:100;
for r = seed_range

% This data set cannot be made public. If you need to access, please contact the authors.
load("eco_old_original.mat")

ecodataoriginal( ~any(ecodataoriginal,2), : ) = [];% clean the row with no data
ecodataoriginal(  :, ~any(ecodataoriginal,1)) = [];% clean the column with no data
data = ecodataoriginal.';
[m,n]=size(data); % process*flow

s=2; % the parameter to be changed to calculate different percentage of missing data
p=[0.01,0.05,0.1,0.2,0.5,0.8]; % define the percentage of missing data

x=ceil(p(s)*n); % missing number of
rng default
mi_ind = randperm(n,x);
data_mi=data(:,mi_ind);
data_re=data;
data_re(:,mi_ind)=[];% Remove data at missing data positions

% Choose 2046 processes ofr trainingset and 500 processes for testset
sample_size = 500;
rng(r)
sample_ind = randperm(m,sample_size);

data(sample_ind,:) = [];
data_mi(sample_ind,:)=[];
data_re(sample_ind,:)=[];


% missing-data's structure
data_mi_str = (data_mi~=0);
data_mi_str = data_mi_str.';

% Set parameters range
q = 0.01:0.01:0.2;
l = 1:50; 


% C = cell(size(q,2),2);% col1: E, col2: MPE
% size(C)


MPE_mean = zeros(length(q),length(l));
MPE_median = zeros(length(q),length(l));

for t = 1:size(q,2)
     % Calculate the Minkowski distance between data_re and itself using parameter q(t)
    D = pdist2(data_re,data_re,'minkowski',q(t));% Minkowski
    S=1.0./(1+D); 

     % Initialize matrices for storing results
    [B,I] = sort(S,1,'descend');% sort in each column, B is the value, I is the index of the value
    B(1,:)=[]; % Remove the top row (self-comparison)
    I(1,:)=[]; % Remove the top row (self-comparison)
    E = zeros (x,length(l),m-sample_size); % missing_flow * k_similar * all_processes
    E_1 = zeros (x,m-sample_size);

    for w = 1:size(data,1)
        count = 1;
        for k=l 
            E_1 (:,w)= data(I(1:k,w),mi_ind)'*B(1:k,w)./sum(B(1:k,w),1);%.*nonzero_ind(i,:)'; 
            E (:,count,w)= E_1 (:,w).*data_mi_str(:,w);
            MPE(w,count) = sqrt(sum((E (:,count,w)'-data_mi(w,:)).^2))/sqrt(sum(data_mi(w,:).^2));
            count = count +1;
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

% Save the best parameters under mean MPE
[x1,y1]=find(MPE_mean==min(min(MPE_mean)));
C1{r,1} =x1;%q
C1{r,2} =y1;%k

% Save the best parameters under median MPE
[x2,y2]=find(MPE_median==min(min(MPE_median)));
C2{r,1} =x2;%q
C2{r,2} =y2;%k

end


%% Check the performance on testsets with obtained best parameters

q_all=[];
k_all=[];

for r = seed_range

load("eco_old_original.mat")
ecodataoriginal( ~any(ecodataoriginal,2), : ) = [];% clean the row with no data
ecodataoriginal(  :, ~any(ecodataoriginal,1)) = [];% clean the column with no data
data = ecodataoriginal.';
[m,n]=size(data); % process*flow

s=2; % the parameter to be changed to calculate different percentage of missing data
p=[0.01,0.05,0.1,0.2,0.5,0.8]; % define the percentage of missing data

x=ceil(p(s)*n); % missing number of x data
rng default
mi_ind = randperm(n,x);
data_mi=data(:,mi_ind);
data_re=data;
data_re(:,mi_ind)=[];%去掉missing data位置上的data

% choose the corresponding 500 sample processes
sample_size = 500;
rng(r)
sample_ind = randperm(m,sample_size);

data = data(sample_ind,:);
data_mi = data_mi(sample_ind,:);
data_re = data_re(sample_ind,:);

% missing-data's structure
data_mi_str = (data_mi~=0);
data_mi_str = data_mi_str.';


q = 0.01:0.01:0.2;
q = q(cell2mat(C2(r,1))); 
rand_ind = randi(length(q));
q=q(rand_ind);
q_all(end+1) = q;

k = C2{r,2};
k=k(rand_ind);
k_all(end+1)=k;



    D = pdist2(data_re,data_re,'minkowski',q);% Minkowski
    S=1.0./(1+D); 
    %RMSE = zeros(m,m-1);

    [B,I] = sort(S,1,'descend');
    B(1,:)=[];
    I(1,:)=[]; 
    E = zeros (x,length(k),m-sample_size); 
    E_1 = zeros (x,m-sample_size);

    for w = 1:size(data,1)
            E_1 (:,w)= data(I(1:k,w),mi_ind)'*B(1:k,w)./sum(B(1:k,w),1);%.*nonzero_ind(i,:)'; 
            E (:,w)= E_1 (:,w).*data_mi_str(:,w);
            MPE(r,w) = sqrt(sum((E (:,w)'-data_mi(w,:)).^2))/sqrt(sum(data_mi(w,:).^2));

    end

end

%% Plot the graph
values_1 = median(MPE, 2,'omitnan');
min_value = min(values_1);
max_value = max(values_1);
% Adjust the scale for desired point size
size_scale = 100;  % Adjust the scale for desired point size
% Choose any colormap
color_scale = jet(256);  


point_sizes = interp1(linspace(min_value, max_value, size_scale), linspace(40, 400, size_scale), values_1, 'nearest');
point_colors = interp1(linspace(min_value, max_value, 256), color_scale, values_1);

figure;
scatter(k_all, q_all, point_sizes, point_colors, 'filled');
colormap(color_scale);
colorbar;
title('5% missing: MPE on test set with corresponding best parameters', 'FontSize', 18, 'Units', 'normalized', 'Position', [0.5, 1.04]);
xlabel('k', 'FontSize', 16);
ylabel('q', 'FontSize', 16);
set(gca, 'FontSize', 14);  % Increase font size for axis labels and ticks
colorbar('FontSize', 14);   % Increase font size for colorbar labels









