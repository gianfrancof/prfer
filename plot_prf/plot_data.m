function plot_data(bold_data, curvature, coordinates, color_map)
%plot_data shows a representation of the cortical surface and a carpet plot
%showing the BOLD data for each vertex.
%
%plot_data
% input arguments:
%
%       bold_data: a matrix [N x T] containing the BOLD response for each
%                  vertex/voxel (rows) for each time point (columns)
%
%       curvature: a vector [N x 1] of curvature data as computed by
%                  anatomical images segmentation softwares (e.g., Freesurfer)
%
%       coordinates: a matrix [N x 3] of superficial coordinates (x, y, z)
%                    as computed by anatomical images segmentation
%                    softwares (e.g., Freesurfer)
%
%       color_map: your favorite colormap for displying BOLD responses
%                  (default: copper)
%
%This software is released under MIT license (see LICENCE file) and is
%intended for teaching purposes only.
%
% Version: 0.1.1
% Date: Sep 2025
% Authors: Valeria Centanino, Gianfranco Fortunato
% International School for Advanced Studies (SISSA), Trieste, IT

if nargin < 4 || isempty(color_map)
    color_map = copper;
end

curvature_colors = ones(length(curvature),3) * .2;
curvature_colors(curvature <= 0,:)  = repmat(.5, sum(curvature <= 0), 3);


figure('Units','normalized','OuterPosition', [.3,.5,.6,.4])
tiledlayout(1,3);
nexttile;
scatter3(coordinates(:,1), coordinates(:,2), coordinates(:,3),...
         50, curvature_colors, 'filled');
view(80,15);
xlabel('x (mm)');
ylabel('y (mm)');
zlabel('z (mm)');
title('Surface data render');
set(gca,'Color','none');
nexttile([1,2]);
imagesc(bold_data);
ylabel('Vertices');
yticks([]);
xlabel('time (TRs)');
colormap(color_map);
c_bar = colorbar('Location','eastoutside');
c_bar.Label.String = 'BOLD response';
