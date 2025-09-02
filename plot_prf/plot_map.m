function plot_map(iterative_results, map_type, coordinates, curvature, r2_threshold)
%plot_map renders pRF results on the cortical surface 
%
%plot_map
% input arguments:
%
%   iterative_results: a structure containing the results of the iterative 
%                      pRF fit presented in prf_tutorial.m
%
%   map_type: character array indicating either polarity or eccentricity
%
%   coordinates: a matrix [N x 3] of superficial coordinates (x, y, z) as
%                 computed by anatomical images segmentation softwares 
%                 (e.g., Freesurfer)
%   
%   curvature: a vector [N x 1] of curvature data as computed by
%              anatomical images segmentation softwares (e.g., Freesurfer)
%
%   r2_threshold: variance explained threshold for plotting 
%
%This software is released under MIT license (see LICENCE file) and is
%intended for teaching purposes only.
%
% Version: 0.1.1
% Date: Sep 2025
% Authors: Valeria Centanino, Gianfranco Fortunato
% International School for Advanced Studies (SISSA), Trieste, IT

if nargin < 5 || isempty(r2_threshold)
    r2_threshold = .2;
end

vx_color = ones(size(iterative_results.fixed_params,1),3) *.2;
if ~isempty(curvature)
    vx_color(curvature <= 0,:)  = repmat(.5,sum(curvature <= 0),3);
end

% r2 mask
r2_mask = iterative_results.fixed_params(:,end) >= r2_threshold;
switch map_type
    case {'eccentricity','Eccentricity'}
        cmap = flipud(jet());
        round_c_tick = 1; 
    case {'polarity', 'Polarity'}
        cmap = hsv();
        round_c_tick = 0;
    otherwise
        error('Map type: %s not recognized\nUse eccentricity or polarity',...
              map_type);
end
q = discretize(iterative_results.ret_params.(map_type)(r2_mask),size(cmap,1));
vx_color(r2_mask,:) = cmap(q,:);
figure;
scatter3(coordinates(:,1),...
         coordinates(:,2),...
         coordinates(:,3),...
         50,...
         vx_color,...
         'filled');
view(50,5);
xlabel('x (mm)');
ylabel('y (mm)');
zlabel('z (mm)');
title([upper(map_type), ' Map']);
set(gca, 'Color','none')
colormap(cmap);
c_bar = colorbar('Location','eastoutside');
c_bar.TickLabels = round(linspace(min(iterative_results.ret_params.(map_type)(r2_mask)),...
                            max(iterative_results.ret_params.(map_type)(r2_mask)),...
                            11),round_c_tick);
c_bar.Label.String = [upper(map_type), ' (\circ)'];
end