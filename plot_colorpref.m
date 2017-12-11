function colornorm = plot_colorpref(bin,skip,color_preference)

% Function to plot color preferences and additional tools. Uses file from
% colorpref.m for input. The color_preference file from workspace can be 
% used. 
%   in: bin         bin data in # minutes (default bin = 60)
%
%       skip        skip first # bins (default skip = 0)
%

if nargin<1; bin = 60; end
if nargin<2; skip = 0; end
if nargin<3
    if exist ('color_preference','var')==0
        [FileName, PathName] = uigetfile('*.*' , 'Select color_preference file','MultiSelect','off');
        filename = fullfile(PathName, FileName);
        load(filename);
    end
end
disp(color_preference())
color_preference_names = fieldnames(color_preference);
fly_strain = input('choose flies to show or type "all" to show all: #');


% Plotting color distribution

color = color_preference.(char(color_preference_names(fly_strain)));

if size(color,2) == 3                                                       %For 3 color experiment
    hour = size(color,1)-mod(size(color,1),bin);
    
    color2(:,1) = sum(reshape(color(1:hour,1),bin,[]));                     %bin from framerate of colorpref.m to bin (default bin = 60, 1 hour)
    color2(:,2) = sum(reshape(color(1:hour,2),bin,[]));
    color2(:,3) = sum(reshape(color(1:hour,3),bin,[]));
    
    norm = sum(color2,2);
    colornorm(:,1) = color2(:,1)./norm;                                     %normalize
    colornorm(:,2) = color2(:,2)./norm;
    colornorm(:,3) = color2(:,3)./norm;
    %
    %
%     figure('units','normalized','outerposition',[0 0.2 1 0.475])                  %plot
            
    figure
    if skip>=0
        plot(colornorm(skip+1:end,2),'b');                                           %plot blue preference
        hold on
        plot(colornorm(skip+1:end,3),'r');                                           %plot red preference
        plot(colornorm(skip+1:end,1),'g');                                           %plot green preference
    else
        colornorm = [zeros(-skip,3);colornorm];
        plot(colornorm(:,2),'b');                                           %plot blue preference
        hold on
        plot(colornorm(:,3),'r');                                           %plot red preference
        plot(colornorm(:,1),'g');                                           %plot green preference
    end
    set(gca,'XTick',0:6:length(colornorm))
    set(gca,'Xlim',[0,length(colornorm)])
    % set(gca,'Xlim',[0,81])
    set(gca,'Ylim',[0,1])
    set(gca,'Xgrid','on')
%        plot([0,length(colornorm)*bin],[1/2,1/2],'k');
    plot([0,length(colornorm)],[1/3,1/3],'k');                                                %line of 1/3
    %
%     err(:,1) = std(reshape(color(1:hour,1),60,[]));                       %error bin from 1 minute to 1 hour
%     err(:,2) = std(reshape(color(1:hour,2),60,[]));
%     err(:,3) = std(reshape(color(1:hour,3),60,[]));
%     
%     errnorm(:,1) = err(:,1)./24;
%     errnorm(:,2) = err(:,2)./24;
%     errnorm(:,3) = err(:,3)./24;
%     
%     errorbar(colornorm(1:end,1),errnorm(:,1),'g')
%     errorbar(colornorm(1:end,2),errnorm(:,2),'b')
%     errorbar(colornorm(1:end,3),errnorm(:,3),'r')
    % plot([0,length(colornorm)],[0.399,0.399],'--');                                           %lines of 1 standard deviation
    % plot([0,length(colornorm)],[0.2677,0.2677],'--');                                           %and 2 standard deviations
    % plot([0,length(colornorm)],[0.212,0.212],'--');                                           %found from DD data of 09/22/2015
    % plot([0,length(colornorm)],[0.448,0.448],'--');

elseif size(color,2) == 2                                                   % For 2 color experiment
    hour = size(color,1)-mod(size(color,1),bin);
    
    color2(:,1) = sum(reshape(color(1:hour,1),bin,[]));                          %bin from 1 minut to 1 hour
    color2(:,2) = sum(reshape(color(1:hour,2),bin,[]));
    
    norm = sum(color2,2);
    colornorm(:,1) = color2(:,1)./norm;                                         %normalize
    colornorm(:,2) = color2(:,2)./norm;
    figure('units','normalized','outerposition',[0 0.25 1 0.5])                  %plot
    plot(bin/60:bin/60:(length(colornorm)-skip)*bin/60,colornorm(skip+1:end,2),'r');                                           %plot red preference
    hold on
    plot(bin/60:bin/60:(length(colornorm)-skip)*bin/60,colornorm(skip+1:end,1),'b');                                           %plot blue preference
    set(gca,'XTick',0:0.5:length(colornorm)*bin)
%     set(gca,'Xlim',[0,length(colornorm)*bin])
    set(gca,'Ylim',[0,1])
    set(gca,'Xgrid','on')
%     plot([0,length(colornorm)*bin],[1/2,1/2],'k');                                                %line of 1/2
elseif size(color,2) == 4
    hour = size(color,1)-mod(size(color,1),bin);
    
    color2(:,1) = sum(reshape(color(1:hour,1),bin,[]));                     %bin from 1 minute to 1 hour
    color2(:,2) = sum(reshape(color(1:hour,2),bin,[]));
    color2(:,3) = sum(reshape(color(1:hour,3),bin,[]));
     color2(:,4) = sum(reshape(color(1:hour,4),bin,[]));
    norm = sum(color2,2);
    colornorm(:,1) = color2(:,1)./norm;                                     %normalize
    colornorm(:,2) = color2(:,2)./norm;
    colornorm(:,3) = color2(:,3)./norm;
    colornorm(:,4) = color2(:,4)./norm;
    %
    % err(:,1) = std(reshape(color(1:hour,1),60,[]));                       %error bin from 1 minute to 1 hour
    % err(:,2) = std(reshape(color(1:hour,2),60,[]));
    % err(:,3) = std(reshape(color(1:hour,3),60,[]));
    %
    % errnorm(:,1) = err(:,1)./24;
    % errnorm(:,2) = err(:,2)./24;
    % errnorm(:,3) = err(:,3)./24;
    %
    total_frac = sum(color2,2)/(25*60);
    figure                                                                  %plot
    plot(bin/60:bin/60:(length(colornorm)-skip)*bin/60,colornorm(skip+1:end,2),'b');                                           %plot blue preference
    hold on
    plot(bin/60:bin/60:(length(colornorm)-skip)*bin/60,colornorm(skip+1:end,3),'r');                                           %plot red preference
    plot(bin/60:bin/60:(length(colornorm)-skip)*bin/60,colornorm(skip+1:end,1),'g');                                           %plot green preference
    plot(bin/60:bin/60:(length(colornorm)-skip)*bin/60,colornorm(skip+1:end,4),'k'); 
    plot(bin/60:bin/60:(length(colornorm)-skip)*bin/60,total_frac(skip+1:end),'c');
    %     set(gca,'XTick',0:1:length(colornorm)*bin)
%     set(gca,'Xlim',[0,length(colornorm)*bin/60])
    % set(gca,'Xlim',[0,81])
    set(gca,'XTick',0:6:length(colornorm))
    set(gca,'Xlim',[0,length(colornorm)])
    set(gca,'Ylim',[0,1])
    set(gca,'Xgrid','on')
   
    plot([0,length(colornorm)*bin],[1/4,1/4],'k');      
    
end