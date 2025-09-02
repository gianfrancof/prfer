%% pRF tutorial for the Summer School in Sensory Neuroscience 2025, Pisa, IT
%Data used in this tutorial has been published in:
%
%   Centanino, V., Fortunato, G. & Bueti, D. 
%   The neural link between stimulus duration and spatial location in the human visual hierarchy.
%   Nat Commun 15, 10720 (2024). 
%   https://doi.org/10.1038/s41467-024-54336-5 
%
%This software is released under MIT license (see LICENCE file) and is
%intended for teaching purposes only.
%
% Version: 0.1.1
% Date: Sep 2025
% Authors: Valeria Centanino, Gianfranco Fortunato
% International School for Advanced Studies (SISSA), Trieste, IT

%% Add the code directory to Matlab paths
addpath(fullfile('.','do_prf'));
addpath(fullfile('.','plot_prf'));

%% Data & Stimulus Space
% Load data
data_dir = fullfile('.','data');
load(fullfile(data_dir,'lh_V1.mat'), 'bold_data', 'surf_data', 'curv_data');
load(fullfile(data_dir,'apertures_conv.mat'),'apt');

%Visualize the data
plot_data(bold_data, curv_data, surf_data);

% Define the stimulus space
[x,y] = meshgrid(1:1:size(apt,1));
stimulus_space = {x,y};

%% Tuning function

% Define prf model
gauss2d = @(x,y,mu_x,mu_y,sigma) exp(-((x-mu_x).^2 + (y-mu_y).^2)./sigma.^2);

%% Grid fit

% Define parameters' grid
mu_x_range = [1, size(apt,1)];
mu_y_range = mu_x_range;
sigma_range = [.5, size(apt,1)/2];
params_range = {mu_x_range, mu_y_range, sigma_range};
grid_resolution = size(apt,1)/20;
grid_parameters = create_grid(params_range, grid_resolution);

% Generate grid predictions
[grid_predictions, grid_parameters] = generate_grid_predictions(grid_parameters,...
                                                                apt,...
                                                                stimulus_space,...
                                                                gauss2d);

% Organise the vertices in batches to optimise the fit
batch_size = 1000; % num. of vertices included in each batch
indices = 1:size(bold_data,1);
batch_rows = [repmat(batch_size,1, fix(length(indices)/batch_size)),...
              mod(length(indices), batch_size)];
batches = mat2cell(indices', batch_rows,1);

% Perform the fit
results.grid = grid_fit(bold_data,...
                        grid_predictions,...
                        grid_parameters,...
                        batches,...
                        batch_rows);
 
%% Iterative fit

% Optimizer options
opt.tol = 1e-3;
opt.maxiter = 5000;

% Variance explained threshold
opt.r2_thr = 0.2; % Perform iterative fit only for grid parameters with variance explained above the threshold.

% Optimization upper and lower bounds
opt.upper_bound = [max(mu_x_range), max(mu_y_range), max(sigma_range),... % \mu_x, \mu_y, \sigma
                   Inf, Inf];                                             % slope, intercept 
opt.lower_bound = [min(mu_x_range), min(mu_y_range), min(sigma_range),... % \mu_x, \mu_y, \sigma
                   0,-Inf];                                               % slope, intercept

opt.model_fun = gauss2d;
opt.stimulus_space = stimulus_space;

% With the data provided this can take up to half an hour on an old laptop with r2_th of .2 
results.iterative = iterative_fit(bold_data,...
                                  results.grid.parameters,...
                                  apt,...
                                  batches,...
                                  batch_rows,...
                                  opt);

results.iterative.fixed_params = fix_bad_fits(results);

%% Results

opt.params_range = params_range;
results.opt = opt;
results.predictions = grid_predictions;
results.parameters = grid_parameters;

% Convert prf parameters from arbitrary units to eccentricity and polarity
results.iterative.ret_params = prf2ret(results.iterative.fixed_params,...
                                       size(apt,1));

% Plot fit results
vertex_index = 1000;
plot_fit_results(bold_data, results, apt, vertex_index)

% Plot maps
% Eccentricity
plot_map(results.iterative,'eccentricity',surf_data,curv_data,.2);
% Polarity
plot_map(results.iterative,'polarity',surf_data,curv_data,.2);


% Save results
out_dir = fullfile(data_dir,'prf_results');
    if ~exist(out_dir,'dir')
        mkdir(out_dir);
    end
save_fname = fullfile(out_dir,'prf_gauss2d.mat');
fprintf('Saving results as %s\n',save_fname);
save(save_fname,'results');