function results = iterative_fit(data, grid_parameters, apertures, batches, batch_rows, opt)
%iterative_fit finds the best fitting parameters using Nelder-Mead
%optimization implemented in fminsearchbnd, using as initial guess 
%the grid fit best parameters
%
%iterative_fit
% input arguments:
%
%   data: a 2D matrix contaning the BOLD data, where each row represents a
%         vertex/voxel and each column a time point
%                 
%   grid_parameters: a 2D matrix containing grid fit best parameters (columns)
%                    for each vertex/voxel (rows)
%
%   apertures: a 3D matrix of hrf-convolved stimulus apertures
%
%
%   batches: cell array containing a set of indices to perform the fit
%            for smaller groups of vertices/voxels in parallel
%
%   batch_row: the number of vertices/voxels contained in each batch
%
%   opt: a structure containg optimset options
%           .tol - optimizer tolerance
%           .maxiter - maximum number of iterations allowed to the optimizer
%           .lower_bound - a vector of minimum parameters values
%           .upper_bound - a vector of maximum parameters values
%           .r2_thr - minimum variance explained for performing the fit
%
% output:
%   
%  results: a structure containing the results of the iterative fit
%           .parameters: a matrix containing for each vertex/voxel the best
%                        parameters that fitted the data as well as the
%                        variance explained by those parameters
%           .exit_vals: a vector contaning the optimizer exit values
%                       (see help fminsearchbnd) for each vertex/voxel 
%
%This software is released under MIT license (see LICENCE file).
%
% Version: 0.1.1
% Date: Sep 2025
% Authors: Valeria Centanino, Gianfranco Fortunato
% International School for Advanced Studies (SISSA), Trieste, IT

iterative_best_parameters = zeros(size(data,1),size(grid_parameters,2));
exit_vals = zeros(size(data,1),1);
iterative_best_parameters = mat2cell(iterative_best_parameters,batch_rows,size(grid_parameters,2));
exit_vals = mat2cell(exit_vals,batch_rows);
results = struct();

for bb = 1:length(batches) % Here you typically want to use a parfor
    these_data = data(batches{bb},:);
    these_grid_parameters = grid_parameters(batches{bb},:);
    [iterative_best_parameters{bb}, exit_vals{bb}] = fit_iter(these_data,...
                                                               these_grid_parameters,...
                                                               apertures,...
                                                               opt);
    fprintf('Batch nr: %d completed -iterative_fit-\n',bb);
end
results.parameters = cat(1,iterative_best_parameters{:});
results.exit_vals = cat(1,exit_vals{:});
end

function [winning_params,exit_vals] = fit_iter(data,grid_params,apts,opt)
winning_params = nan(size(grid_params));
exit_vals = zeros(size(data,1),1);

options = optimset('Display','none',...
                   'MaxIter',opt.maxiter,'MaxFunEvals',opt.maxiter,...
                   'TolX',opt.tol,'TolFun',opt.tol);

for vv = 1:size(data,1)
    if (grid_params(vv,end) < opt.r2_thr) || isnan(grid_params(vv,end))
        winning_params(vv,:) = grid_params(vv,:);
    else
        denominator = sum((data(vv,:) - mean(data(vv,:))).^2);
        [winning_params(vv,1:end-1),numerator,exit_vals(vv)] = ...
                                            fminsearchbnd(@error_fun,...
                                            double(grid_params(vv,1:end-1)),...
                                            opt.lower_bound, opt.upper_bound,...
                                            options,...
                                            double(data(vv,:)),double(apts),opt);
        winning_params(vv,end) = 1 - numerator/denominator;
    end
end
end

function to_be_min = error_fun(params, data, apts, opt)
model_params = num2cell(params(1:end-2));
rf = opt.model_fun(opt.stimulus_space{:},model_params{:});
prediction = squeeze(sum(sum(apts.*rf)))';
prediction = prediction.*params(end-1) + params(end);
to_be_min = sum((data-prediction).^2);
end
