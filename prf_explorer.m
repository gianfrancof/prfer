function prf_explorer(data_dir,true_mu_x, true_mu_y, true_sigma)
%pRF_explorer is an interactive tool that allows to see how population
%receptive field (pRF) predictions change with different combinations of
%tuning function parameters. The tuning function, an isotropic 2D
%gaussian, is represented in the upper left panel; its
%parameters \mu_x, \mu_y, \sigma in the upper right panel can be modified
%through the corresponding slider. The bottom plot shows a syntetic BOLD
%response (in black) and the predicted response (in green).
%To find the best pRF, the user can push the 'optimize pRF' button.
%The function depends on hrf-convolved stimulus apertures (apt) see line 37.
%
%
%pRF_explorer
% input arguments:
%
%   data_dir: directory where 'apertures_conv.mat' is located
%
%   true_mu_x: value of the parameter \mu_x to generate syntetic BOLD 
%              data [default: -3] 
%
%   true_mu_y: value of the parameter \mu_y to generate syntetic BOLD
%              data [default: 2]
%
%   true_sigma:  value of the parameter \sigma to generate syntetic BOLD
%                data [default: 1]
%
%
%This software is released under MIT license (see LICENCE file) and is
%intended for teaching purposes only.
%
% Version: 0.1.1
% Date: Sep 2025
% Authors: Valeria Centanino, Gianfranco Fortunato
% International School for Advanced Studies (SISSA), Trieste, IT

if nargin < 4 || isempty(true_sigma)
    true_sigma=1;
end
if nargin < 3 || isempty(true_mu_y)
    true_mu_y = 2;
end
if nargin < 2 || isempty(true_mu_x)
    true_mu_x = -3;
end
if nargin < 1 || isempty(data_dir)
    data_dir = fullfile('.','data');
end

% Set prf space and starting parameters
[x,y] = meshgrid(-5:0.1:5);
y = flipud(y);
mu_x = 0;
mu_y = 0;
sigma = 3;

% Initialize prf
prf = gauss2D(x,y,mu_x,mu_y,sigma);

% 
true_prf = gauss2D(x,y,true_mu_x,true_mu_y,true_sigma);

% Simulate data
load(fullfile(data_dir,'apertures_conv.mat'),'apt');
bold = single(squeeze(sum(sum(apt.*true_prf))));
bold = rescale(bold,0,1);
noise = randn(size(apt,3),1).*.1;
bold = bold + noise;

% Create prediction
prediction = single(squeeze(sum(sum(apt.*prf))));
prediction = lfit(prediction,bold);

% Create figure
f = figure('Name','pRF Explorer','units','normalized','Position',[0,0,0.60,0.8]);
tiledlayout(2,2);

% Plot prf
t1 = nexttile(1);
im1 = imagesc(prf);
xticks(1:10:101)
xticklabels({'-5','-4','-3','-2','-1','0','1','2','3','4','5'})
yticks(1:10:101)
yticklabels({'5','4','3','2','1','0','-1','-2','-3','-4','-5'})
hold on
xline(50,'LineWidth',2,'Color','w')
hold on
yline(50,'LineWidth',2,'Color','w')
xlabel('visual field (x)','Fontsize',12);
ylabel('visual field (y)','Fontsize',12);
title(t1,'population receptive field (pRF)')

% Plot predicted response
nexttile(3,[1 2]);
plot(bold,'LineStyle','-','LineWidth',1.5,'Color',[.5,.5,.5],...
    'Marker','o','MarkerFaceColor',[.3,.3,.3],'MarkerEdgeColor',[.3,.3,.3])
hold on
im2 = plot(prediction,'LineWidth',2.5,'Color','#77AC30');
box off
xlim([0 size(apt,3)+1])
ylim([min(bold-.1) max(bold)+.25])
xlabel('time (volumes)','Fontsize',12)
ylabel('BOLD response','Fontsize',12)
legend('real','predicted','box','off','Fontsize',12,'Location','north','orientation','horizontal')

% Add slider
mu_min = min(min(x));
mu_max = max(max(x));
sigma_min = .1;
sigma_max = max(max(x))*2;
mu_range = mu_max - mu_min;
sigma_range = sigma_max - sigma_min;
step = 0.1;
mu_step = step/mu_range;
sigma_step = step/sigma_range;
% mu_x
b1 = uicontrol('Parent',f,'Style','slider','Units','normalized',...
               'InnerPosition',[.6,.87,.3,.025],...
              'value',mu_x, 'min',mu_min, 'max',mu_max,...
              'SliderStep', [mu_step, mu_step*10]);
slider_label_1 = uicontrol('Parent', f, 'Style', 'text', ...
                         'Units','normalized','InnerPosition',[.7,.9,.1,.02], ...
                         'String', sprintf('mu_x: %.1f', mu_x),'FontSize',12);
% mu_y
b2 = uicontrol('Parent',f,'Style','slider','Units','normalized',...
               'InnerPosition',[.6,.79,.3,.025],...
              'value',mu_y, 'min',mu_min, 'max',mu_max,...
              'SliderStep', [mu_step, mu_step*10]);
slider_label_2 = uicontrol('Parent', f, 'Style', 'text', ...
                         'Units','normalized','InnerPosition', [.7,.82,.1,.02], ...
                         'String', sprintf('mu_y: %.1f', mu_y),'FontSize',12);
% sigma
b3 = uicontrol('Parent',f,'Style','slider','Units','normalized',...
               'InnerPosition',[.6,.72,.3,.025],...
              'value',sigma, 'min',sigma_min, 'max',sigma_max,...
              'SliderStep', [sigma_step, sigma_step*10]);
slider_label_3 = uicontrol('Parent', f, 'Style', 'text', ...
                         'Units','normalized','InnerPosition', [.7,.75,.1,.02], ...
                         'String', sprintf('sigma: %.1f', sigma),'FontSize',12);
% Add button
b4 = uicontrol('Parent',f,'Style','pushbutton','Units','normalized',...
               'InnerPosition',[.69,.6,.13,.07],...
               'String','optimise prf','FontSize',12);

% Update slider
% mu_x
b1.Callback = @(es, ed) update_slider(es,...
                                      x,y,b1.Value,b2.Value,b3.Value,...
                                      apt,bold,...
                                      'mu_x',...
                                      im1,im2,slider_label_1);
% mu_y
b2.Callback = @(es, ed) update_slider(es,...    
                                      x,y,b1.Value,b2.Value,b3.Value,...
                                      apt,bold,...
                                      'mu_y',...
                                      im1,im2,slider_label_2);
% sigma
b3.Callback = @(es, ed) update_slider(es,...
                                      x,y,b1.Value,b2.Value,b3.Value,...
                                      apt,bold,...
                                      'sigma',...
                                      im1,im2,slider_label_3);
% Push button
b4.Callback = {@push_button,...
               b1,b2,b3,...
               slider_label_1,slider_label_2,slider_label_3,...
               x,y,true_mu_x,true_mu_y,true_sigma,apt,bold,...
               im1,im2};

end

function update_slider(es,x,y,mu_x,mu_y,sigma,apt,data,which_param,im1,im2,slider_label)
val = es.Value;
if strcmpi(which_param,'mu_x')
    prf = gauss2D(x,y,val,mu_y,sigma);
elseif strcmpi(which_param,'mu_y')
    prf = gauss2D(x,y,mu_x,val,sigma);
elseif strcmpi(which_param,'sigma')
    prf = gauss2D(x,y,mu_x,mu_y,val);
end
set(im1,'CData',prf);
slider_label.String = sprintf('%s: %.1f',which_param,val);
prediction = single(squeeze(sum(sum(apt.*prf))));
prediction = lfit(prediction,data);
set(im2,'YData',prediction)
end

function push_button(~,~,b1,b2,b3,sl1,sl2,sl3,x,y,mux,muy,sigma,apt,data,im1,im2)
prf = gauss2D(x,y,mux,muy,sigma);
pred = single(squeeze(sum(sum(apt.*prf))));
pred = lfit(pred,data);
set(im1,'CData',prf);
set(im2,'YData',pred)
b1.Value = mux;
b2.Value = muy;
b3.Value = sigma;
sl1.String = sprintf('mu_x: %.1f',mux);
sl2.String = sprintf('mu_y: %.1f',muy);
sl3.String = sprintf('sigma: %.1f',sigma);
end

function rf = gauss2D(x,y,mux,muy,sigma)
mu = [mux,muy];
rf = exp(-((x-mu(1)).^2 + (y-mu(2)).^2)./sigma.^2);
end

function new_prediction = lfit(prediction,data)
if size(prediction,1) > 1
    prediction = prediction';
end
if size(data,1) > 1
    data = data';
end
[slope,interc] = coeff_estimate(prediction,data);
new_prediction = prediction.*slope+interc;
end

function [slope,interc] = coeff_estimate(prediction,data)
sm = prediction-mean(prediction);
sb = data-mean(data);
slope = sum(sm.*sb)/sum(sm.^2);
interc = mean(data)-slope*mean(prediction);
if slope < 0
    slope =0;
end
end