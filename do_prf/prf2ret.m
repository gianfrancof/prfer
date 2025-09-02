function ret_parameters = prf2ret(parameters, apertures_size, tot_screen_dva)
%prf2ret transforms pRF parameters from stimulus space to retinotopic
%coordinates.
%
%prf2ret
% input arguments
%  parameters: a matrix containing the best fitted parameters for each
%              vertex/voxels (rows) resulting from either grid_fit or
%              iterative_fit functions
%
%  apertures_size: size of the stimulus space
%
%  tot_screen_dva: size of the stimulus space in degrees of visual angle 
%
% output:
%  ret_parameters: structure containig the converted pRF parameters
%                  .dva_parameters - parameters converted in degrees of
%                                    visual angle (dva)
%                  .eccentricity - eccentricity representation for each
%                                  vertex/voxels
%                  .polarity - polarity representation for each
%                              vertex/voxel
%
%This software is released under MIT license (see LICENCE file).
%
% Version: 0.1.1
% Date: Sep 2025
% Authors: Valeria Centanino, Gianfranco Fortunato
% International School for Advanced Studies (SISSA), Trieste, IT

if nargin < 3 || isempty(tot_screen_dva)
    tot_screen_dva = 10.6; 
end

% Convert parameters into degrees of visual angle starting from the center
% of the screen
c = tot_screen_dva/apertures_size;
dva_parameters = parameters(:,1:3).*c;
dva_parameters(:,1:2) = dva_parameters(:,1:2) - tot_screen_dva/2;

% Derive eccentricity
eccentricity = sqrt(dva_parameters(:,1).^2 + dva_parameters(:,2).^2);

% Derive polarity
% the sign of y values need to be changed because of the apertures space;
% y varies from 0 to 768 from top left corner to bottom left corner.
polarity = rad2deg(atan2(-dva_parameters(:,2),dva_parameters(:,1)));

ret_parameters.dva_parameters = dva_parameters;
ret_parameters.eccentricity = eccentricity;
ret_parameters.polarity = polarity;