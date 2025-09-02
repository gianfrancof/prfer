function plot_fit_results(data, results, apertures, vertex)
%plot_fit_results shows the receptive field and the predicted response
%of the specified vertex/voxel
%
%plot_fit_results
% input arguments:
%
%   data: a 2D matrix contaning the BOLD data, where each row represent a
%         vertex/voxel and each column a time point
%
%   results: a structure containing the results of the pRF estimation
%            presented in prf_tutorial.m
%
%   apertures: a 3D matrix of hrf convolved stimulus apertures
%
%   vertex: the index of the vertex/voxel to be visualized
%
%This software is released under MIT license (see LICENCE file) and is
%intended for teaching purposes only.
%
% Version: 0.1.1
% Date: Sep 2025
% Authors: Valeria Centanino, Gianfranco Fortunato
% International School for Advanced Studies (SISSA), Trieste, IT

params = results.iterative.fixed_params(vertex,:);
eccentricity = results.iterative.ret_params.eccentricity(vertex);
polarity = results.iterative.ret_params.polarity(vertex);
sigma = results.iterative.ret_params.dva_parameters(vertex,3);
model_params = num2cell(params(1:3));
rf = single(results.opt.model_fun(results.opt.stimulus_space{:},model_params{:}));
prediction = squeeze(sum(sum(apertures.*rf)))';
prediction = prediction.*params(end-2) + params(end-1);

figure('units','normalized','Position',[0,.5,0.75,0.3]);
tiledlayout(1,3)

% Plot prf
t1 = nexttile(1);
imagesc(rf);
xticks([1 50 101])
xticklabels({'-7','0','7'})
yticks([1 50 101])
yticklabels({'7','0','-7'})
xlabel('visual field (dva)','Fontsize',12);
ylabel('visual field (dva)','Fontsize',12);
title(t1,'population receptive field (pRF)')

% Plot predicted response
nexttile(2,1:2);
plot(data(vertex,:),'LineStyle','-','LineWidth',1.5,'Color',[.5,.5,.5],...
    'Marker','o','MarkerFaceColor',[.3,.3,.3],'MarkerEdgeColor',[.3,.3,.3])
hold on
plot(prediction,'LineWidth',2.5,'Color','#77AC30');
box off
xlim([0 size(apertures,3)+1])
xlabel('time (volumes)','Fontsize',12)
ylabel('BOLD response','Fontsize',12)
t = sprintf('eccentricity = %.1f   polarity = %.1f   sigma = %.1f',eccentricity,polarity,sigma);
title(t)
legend('real','predicted','box','off','Fontsize',12,'Location','best','orientation','horizontal')