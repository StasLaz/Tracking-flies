function [average_preference,blue_avoidance] = preference_calculation(bin,skip,daylength,color_preference)

% Function to calculate average color preference and additional tools. Uses file from
% colorpref.m for input. The color_preference file from workspace can be 
% used. 
%   in: bin                 bin data in # minutes (default bin = 60)
%
%       skip                skip first # bins (default skip = 0)
%
%   out:average_preference  
%       




if nargin<1; bin = 60; end
if nargin<2; skip = 0; end
if nargin<3; daylength = 24; end
if nargin<4
    if exist ('color_preference','var')==0
        [FileName, PathName] = uigetfile('*.*' , 'Select color_preference file','MultiSelect','off');
        filename = fullfile(PathName, FileName);
        load(filename);
    end
end
disp(color_preference())
color_preference_names = fieldnames(color_preference);
fly_strain = input('Choose flies to show: #');
color = color_preference.(char(color_preference_names(fly_strain)));




colornorm=[];
norm=[];
color2=[];
err = [];
errnorm = [];
y=[];
average_preference=[];
yerr = [];
dayerr =[];
% Bin data into intervals defined by bin
hour = size(color,1)-mod(size(color,1),bin);
    
color2(:,1) = sum(reshape(color(1:hour,1),bin,[]));                         %bin from 1 minute to 1 hour
color2(:,2) = sum(reshape(color(1:hour,2),bin,[]));
color2(:,3) = sum(reshape(color(1:hour,3),bin,[]));

norm = sum(color2,2);
colornorm(:,1) = color2(:,1)./norm;                                         %normalize
colornorm(:,2) = color2(:,2)./norm;
colornorm(:,3) = color2(:,3)./norm;

figure                                                                      %plot

plot(colornorm(skip+1:end,2),'b');                                          %plot blue preference
hold on
plot(colornorm(skip+1:end,3),'r');                                          %plot red preference
plot(colornorm(skip+1:end,1),'g');                                          %plot green preference
set(gca,'XTick',0:2:length(colornorm))
set(gca,'Xlim',[0,length(colornorm)])
set(gca,'Ylim',[0,1])
set(gca,'Xgrid','on')

plot([0,length(colornorm)],[1/3,1/3],'k');                                  %line at 1/3
title(['Color preference for ',char(color_preference_names(fly_strain)), ' choose interval for averaging'],'interpreter','none');
err(:,1) = std(reshape(color(1:hour,1),bin,[]));                            %standard deviations in bins
err(:,2) = std(reshape(color(1:hour,2),bin,[]));
err(:,3) = std(reshape(color(1:hour,3),bin,[]));

errnorm(:,1) = err(:,1)./24;
errnorm(:,2) = err(:,2)./24;
errnorm(:,3) = err(:,3)./24;





%choose from 6 hours before lights on to any point. Will average using full
%days between the interval
[a,~]=ginput(2);    
t=(a(2)-a(1))-mod((a(2)-a(1)),daylength)-1;

color_cut=color2(a(1)+skip:a(1)+skip+t,:);

color_resh = reshape(color_cut,daylength,[]);                               %separate data into days
n=size(color_resh,2)/3;                                                     %nomber of days
y(:,1)=sum(color_resh(:,1:n),2);
y(:,2)=sum(color_resh(:,n+1:2*n),2);
y(:,3)=sum(color_resh(:,2*n+1:3*n),2);

norm = sum(y,2);
average_preference(:,1) = y(:,1)./norm;                                                 %normalize
average_preference(:,2) = y(:,2)./norm;
average_preference(:,3) = y(:,3)./norm;
xerr=errnorm(a(1)+skip:a(1)+skip+t,:);
resherr = reshape(xerr,daylength,[]);
yerr(:,1)=sum(resherr(:,1:n),2)/n;
yerr(:,2)=sum(resherr(:,n+1:2*n),2)/n;
yerr(:,3)=sum(resherr(:,2*n+1:3*n),2)/n;

dayerr(:,1) = std(color_resh(:,1:n),0,2)./norm;                             %deviations between days
dayerr(:,2) = std(color_resh(:,n+1:2*n),0,2)./norm;
dayerr(:,3) = std(color_resh(:,2*n+1:3*n),0,2)./norm;
average_preference(:,4) = dayerr(:,1);
average_preference(:,5) = dayerr(:,2);
average_preference(:,6) = dayerr(:,3);

figure                                                                      %plot averaged color preference with deviations 
plot(average_preference(1:end,2),'b');
hold on
plot(average_preference(1:end,3),'r');
plot(average_preference(1:end,1),'g');
errorbar(average_preference(1:end,1),dayerr(:,1),'g')
errorbar(average_preference(1:end,2),dayerr(:,2),'b')
errorbar(average_preference(1:end,3),dayerr(:,3),'r')
title('Specify time for avergare blue avoidance');
% Choose time points to calculate average blue avoidance
[T,~]=ginput(2);                                                            
blue_avoidance(1) = mean(average_preference(T(1):T(2),2));                              %average fraction of flies in blue (second color)
blue_avoidance(2) = mean(dayerr(T(1):T(2),2));                              %average deviation between hours of avoidance
blue_avoidance(3) = (mean(average_preference(T(1):T(2),1))...                        %alternate blue avoidance index
    +mean(average_preference(T(1):T(2),3))-mean(average_preference(T(1):T(2),2))-1/3)*3/2;          % Index = (green+red-blue-1/3)*3/2 = 1-3*blue

end