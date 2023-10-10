% This file is to compute the model performance on USLCI dataset
%% Load data from USLCI data file
load('USLCIdata.mat') % obtained from USLCIdata.m

data_type = input - output; %flow*process

data_type( ~any(data_type,2), : ) = [];% clean the row with no data
data_type(  :, ~any(data_type,1)) = [];% clean the column with no data
data = data_type.';
[m,n]=size(data); % process*flow
% flow = 4074

s=2; % the parameter to be changed to calculate different percentage of missing data
p=[0.01,0.05,0.1,0.2,0.5,0.8]; % define the percentage of missing data

x=ceil(p(s)*n); % missing number of x data
rng default
mi_ind = randperm(n,x);
data_mi=data(:,mi_ind);
data_re=data;
data_re(:,mi_ind)=[];% Remove data at missing data positions

%% Choose 125 sample processes for testset
sample_size = 125;
rng default
sample_ind = randperm(m,sample_size);

data(sample_ind,:) = [];
data_mi(sample_ind,:)=[];
data_re(sample_ind,:)=[];

%% Missing-data's structure
data_mi_str = (data_mi~=0);
data_mi_str = data_mi_str.';

%%
% Set parameters range
q = 0.01:0.01:0.2;
l = 1:15; 

MPE_mean = zeros(length(q),length(l));
MPE_median = zeros(length(q),length(l));


for t = 1:size(q,2)

    D = pdist2(data_re,data_re,'minkowski',q(t));% Minkowski
    S=1.0./(1+D); 
    %RMSE = zeros(m,m-1);

    [B,I] = sort(S,1,'descend');% sort in each column, B is the value, I is the index of the value
    B(1,:)=[]; 
    I(1,:)=[];
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



%% Plot the graph for Median MPE
% Find the parameters (q,k) of the best model
[x1,y1]=find(MPE_median==min(min(MPE_median)));

% Plot the graph
imagesc(MPE_median)
set(gca,'YDir','normal')
hold on
plot(y1,x1,'r*')
yticklabels(q);

% Set axis and title
colorbar
caxis([0 1])
xlabel('k','FontSize', 20);
ylabel('q','FontSize', 20);
title('USLCI 5% missing: median','FontSize', 22);
set(gca, 'FontSize', 12);
