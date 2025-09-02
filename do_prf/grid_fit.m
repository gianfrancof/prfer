function results = grid_fit(data, predictions, parameters, batches, batch_rows)
%grid_fit finds for each vertex the set of parameters in the grid
%that best explains the data (i.e., the best prediction) using linear
%regression.
%
%grid_fit
% input arguments:
%
%   data: a 2D matrix contaning the BOLD data, where each row represents a
%         vertex/voxel and each column a time point
%                 
%   predictions: a 2D matrix where each column represents the predicted BOLD 
%                response for each set of parameters in the grid.
%
%   parameters: cell array containg the stimulus space
%
%   model_fun: function handle specifing the receptive field (i.e., tuning)
%              function
%
%   batches: cell array containing a set of indices to perform grid search
%            for smaller groups of vertices/voxels in parallel
%
%   batch_row: the number of vertices/voxels contained in each batch
%
% output:
%   
%  results: a structure containing the results of the grid fit
%           .parameters: a matrix containing for each vertex/voxel the best
%                        parameters that fitted the data as well as the
%                        variance explained by those parameters
%           .best_model: a vector contaning the index of the prediction
%                        (in the prediction matrix) that best
%                        explained the data for each vertex/voxel 
%
%This software is released under MIT license (see LICENCE file).
%
% Version: 0.1.1
% Date: Sep 2025
% Authors: Valeria Centanino, Gianfranco Fortunato
% International School for Advanced Studies (SISSA), Trieste, IT

grid_best_parameters = zeros(size(data,1), length(parameters)+3);
grid_best_indx = zeros(size(data,1), 1);
grid_best_parameters = mat2cell(grid_best_parameters,...
                                batch_rows,...
                                length(parameters)+3);
grid_best_indx = mat2cell(grid_best_indx, batch_rows);
results = struct();

for bb = 1:length(batches)
    batch_data = data(batches{bb},:);
    [grid_best_parameters{bb},grid_best_indx{bb}] = fit_lm(batch_data,...
                                                           predictions,...
                                                           parameters);
    fprintf('Batch nr: %d completed -grid_fit-\n',bb);
end
results.parameters = cat(1,grid_best_parameters{:});
results.best_model = cat(1,grid_best_indx{:});
end

function [best_params,best_indx] = fit_lm(data,pred,params)
pred = ipermute(pred, [2,3,1]); % the 1st dim goes 2nd, the 2nd goes 3rd, and the 3rd goes 1st
pred = repmat(pred,size(data,1), 1, 1); % add num of vertices
centered_pred = pred - mean(pred, 2);
centered_data = data - mean(data, 2);
slope = sum(centered_pred .* repmat(centered_data, 1, 1, size(centered_pred,3)), 2) ./ sum(centered_pred.^2, 2);
intercept = repmat(mean(data,2), 1, size(centered_pred,3)) - squeeze(slope .* mean(pred,2));
slope = repmat(slope, 1, size(data,2), 1);
intercept = repmat(ipermute(intercept,[1,3,2]), 1, size(data,2), 1);
pred = pred.*slope + intercept;

numerator = squeeze(sum((repmat(data,1,1,size(pred,3))-pred).^2, 2));
denominator = repmat(sum(centered_data.^2, 2), 1, size(pred,3));

r2 = 1 - numerator./denominator;
[best_params,best_indx] = get_best(r2, slope, intercept, params);
end

function [best_params,best_indx] = get_best(r2,slp,intr,params)
[best_r2,best_indx] = max(r2, [], 2);
[best_slp,best_intr] = deal(zeros(size(best_r2)));
for vv = 1:size(best_r2,1)
    best_slp(vv) = slp(vv, 1, best_indx(vv));
    best_intr(vv) = intr(vv, 1, best_indx(vv));
end
best_params = cellfun(@(x) x(best_indx), params, 'UniformOutput', false);
best_params = [cat(2,best_params{:}), best_slp, best_intr, best_r2];
end

% Verbose version of the fit_lm function :)
function [best_params,best_indx] = verbose_fit_lm(data,pred,params)
best_indx = zeros(size(data,1),1);
best_params = single(zeros(size(data,1), length(params)+3));
for vv = 1:size(data,1)
    this_ver = data(vv,:);
    r2 = zeros(size(pred,1), 1);
    slope = zeros(size(pred,1), 1);
    intercept = zeros(size(pred,1), 1);
    for pp = 1:size(pred,2)
        this_pred = pred(:,pp)';
        sm = this_pred-mean(this_pred);
        sb = this_ver-mean(this_ver);
        slope(pp) = sum(sm.*sb)/sum(sm.^2);
        intercept(pp) = mean(this_ver)-slope(pp)*mean(this_pred);
        new_pred = this_pred.*slope(pp)+intercept(pp);
        r2(pp) = 1 - ((sum((this_ver-new_pred).^2))/...
                     (sum((this_ver-mean(this_ver)).^2)));

    end
    [best_r2,best_indx(vv)] = max(r2);
    best_slope = slope(best_indx(vv));
    best_intercept = intercept(best_indx(vv));
    these_best_params = cellfun(@(x) x(best_indx(vv)), params,...
                                'UniformOutput',false);
    best_params(vv,:) = [cat(2,these_best_params{:}),...
                         best_slope,...
                         best_intercept,...
                         best_r2];
end
end
