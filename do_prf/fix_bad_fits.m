function fixed = fix_bad_fits(results)
%fix_bad_fits checks the goodness of the iterative fit parameters and
%replaces with grid parameters those in which the optimization went wrong.
%
%fix_bad_fits
% input arguments:
%
%   results: a structure containig the results of the grid_fit and
%            iterative_fit functions
% output:
%
%   fixed: a matrix containing for each vertex/voxel the fixed parameters 
%
%This software is released under MIT license (see LICENCE file).
%
% Version: 0.1.1
% Date: Sep 2025
% Authors: Valeria Centanino, Gianfranco Fortunato
% International School for Advanced Studies (SISSA), Trieste, IT

fixed = results.iterative.parameters;
bad_fit_mask = results.iterative.parameters(:,end) < results.grid.parameters(:,end) |...
               results.iterative.exit_vals < 1;
fixed(bad_fit_mask,:) = results.grid.parameters(bad_fit_mask,:);
