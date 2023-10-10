% This file is to check the performance of the 100 different subset (300 processes) of testsets
%%
% Set the seed for trainingsets
seed_range = 1:100;
for r = seed_range

    load("eco_old_original.mat") 
    ecodataoriginal( ~any(ecodataoriginal,2), : ) = [];% clean the row with no data
    ecodataoriginal(  :, ~any(ecodataoriginal,1)) = [];% clean the column with no data
    data = ecodataoriginal.';
    [m,n]=size(data); % process*flow
    
    s=1; % the parameter to be changed to calculate different percentage of missing data
    p=[0.01,0.05,0.1,0.2,0.5,0.8]; % define the percentage of missing data
    
    x0=ceil(p(s)*n); % missing number of x data

    rng default;
    mi_ind = randperm(n,x0);
    data_mi=data(:,mi_ind);
    data_re=data;
    data_re(:,mi_ind)=[];% Remove data at missing data positions

    % randomly choose 300 from the fixed 500 sample processes
    sample_size = 500;
    rng default
    sample_ind0 = randperm(m,sample_size);
    rng(r)
    sample_ind = sample_ind0(randperm(500,300));

    data = data(sample_ind,:);
    data_mi = data_mi(sample_ind,:);
    data_re = data_re(sample_ind,:);

    % missing-data's structure
    data_mi_str = (data_mi~=0);
    data_mi_str = data_mi_str.';

    % best parameters obtained from trainingset under rng default
    q=0.19;
    k=4;

    D = pdist2(data_re,data_re,'minkowski',q);% Minkowski
    S=1.0./(1+D); 
    %RMSE = zeros(m,m-1);
    
    [B,I] = sort(S,1,'descend');% sort in each column, B is the value, I is the index of the value
    B(1,:)=[];  % Remove the top row (self-comparison)
    I(1,:)=[];  % Remove the top row (self-comparison)
    E = zeros (x0,m-sample_size);% missing_flow * all_processes
    E_1 = zeros (x0,m-sample_size);

    for w = 1:size(data,1)
         E_1(:,w)= data(I(1:k,w),mi_ind)'*B(1:k,w)./sum(B(1:k,w),1);%.*nonzero_ind(i,:)'; 
         E(:,w)= E_1 (:,w).*data_mi_str(:,w);
         MPE(r,w) = sqrt(sum((E (:,w)'-data_mi(w,:)).^2))/sqrt(sum(data_mi(w,:).^2));
    end
end

        


MPE_median = median(MPE,2,'omitnan');
MPE_mean = mean(MPE,2,'omitnan');


%% Plot the Median MPE of each subset with an average line
mean_y = mean(MPE_median);
scatter(seed_range, MPE_median)
hold on
line([min(seed_range), max(seed_range)], [mean_y, mean_y], 'Color', 'r', 'LineStyle', '--');
hold off

title('5% missing: median MPE of 100 sub-testset, q=0.19 k=3', 'FontSize', 18, 'Units', 'normalized', 'Position', [0.5, 1.04]);
xlabel('Random selection of 300 processes', 'FontSize', 16);
ylabel('Median MPE', 'FontSize', 16);
set(gca, 'FontSize', 14);

