function grid_parameters = create_grid(parameters_range, grid_resolution)
%create_grid creates all parameters combinations for performing a grid 
%search in the parameters space.
%
%create_grid 
% input arguments:
%
%   parameter_range: cell array contaning the two-element vector of ranges 
%                    (min and max) for each receptive field parameter 
%                 
%   grid_resolution: a scalar that defines the density of the grid search
%
% output:
%   
%   grid_parameters: cell array contaning the parameters for performing the
%                    grid search.
%
%This software is released under MIT license (see LICENCE file).
%
% Version: 0.1.1
% Date: Sep 2025
% Authors: Valeria Centanino, Gianfranco Fortunato
% International School for Advanced Studies (SISSA), Trieste, IT

grid_parameters = cellfun(@(x) linspace(min(x),max(x), grid_resolution),...
                          parameters_range, 'UniformOutput', false);
[grid_parameters{:}] = ndgrid(grid_parameters{:});
grid_parameters = cellfun(@(x) x(:),grid_parameters,'UniformOutput',false);