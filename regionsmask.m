function [mask1,mask2,mask3,maskall] = regionsmask(num,imgBold)
%   regionmasks is used to make masks of regions of interest in videos. Automatically saves masks in folder
%   with videos. Defines rectangular regions of interest using two points.
%   Mask1 - mask of green filter
%   Mask2 - mask of blue filter
%   Mask3 - mask of red filter
%
%   in:     num         number of flies, which defines number of filters of
%                       each color
%           imgBold     reference frame to define masks in video. Asks to
%                       select video for the frame if it does not exist
%                       from readfr function

if nargin<1; num = 18;   end            %number of regions for each color (tubes)
% Choose combination of filters
filter_number = inputdlg('write # of filter combination 1 - three filters, 2 - red/blue, 3 - red/green, 4 - wholetube, 5 - 2D Arena',...
    'Filter combination',[1 40],{'1'});
filter_number = str2double(filter_number);
[FileName, PathName] = uigetfile('*.*' , 'Select video file');
% Choose video for masking
if exist ('imgBold','var')==0
    filename = fullfile(PathName, FileName);
    vidObj =  VideoReader(filename);
    vidObj.CurrentTime = 1;
    frames(1).cdata = readFrame(vidObj);
    imgBold = frames(1).cdata;
end
% Show frame
figure;
imshow(imgBold);
title('Choose smaller region');
% Choose smaler region in frame
[a,b] = ginput(2);
set(gca,'Xlim',[a(1),a(2)]);
set(gca,'Ylim',[b(1),b(2)]);
hold on
% Define all masks
% Combination 1- three filters
if filter_number == 1
    for x = 1:num
        title(['Region: ',num2str(x),'/',num2str(num),' Color: ', num2str(1)]);
        disp (x)
        [a,b] = myginput(2,'crosshair');
        plot([a(1);a(1);a(2);a(2); a(1)],[b(1);b(2);b(2);b(1); b(1)],'g','LineWidth',2);
        coord(:,:,x) = roipoly(imgBold,[a(1);a(1);a(2);a(2)],[b(1);b(2);b(2);b(1)]);
        mask1 = sum(coord,3);
        
    end
    for x = 1:num
        title(['Region: ',num2str(x),'/',num2str(num),' Color: ', num2str(2)]);
        disp (x)
        [a,b] = myginput(2,'crosshair');
        plot([a(1);a(1);a(2);a(2); a(1)],[b(1);b(2);b(2);b(1); b(1)],'b','LineWidth',2);
        coord(:,:,x) = roipoly(imgBold,[a(1);a(1);a(2);a(2)],[b(1);b(2);b(2);b(1)]);
        mask2 = sum(coord,3);
        
    end
    for x = 1:num
        title(['Region: ',num2str(x),'/',num2str(num),' Color: ', num2str(3)]);
        disp (x)
        [a,b] = myginput(2,'crosshair');
        plot([a(1);a(1);a(2);a(2); a(1)],[b(1);b(2);b(2);b(1); b(1)],'r','LineWidth',2);
        coord(:,:,x) = roipoly(imgBold,[a(1);a(1);a(2);a(2)],[b(1);b(2);b(2);b(1)]);
        mask3 = sum(coord,3);
        
    end
    % Save masks
    maskall = mask1+mask2+mask3;
    maskall = logical(maskall);
    f_name = inputdlg('Write fly name');
    f_name = char(f_name);
    filename=char(fullfile(PathName,f_name));
    
    save(filename,'mask1','mask2','mask3','maskall');
    
% Combination 2 - red/blue
elseif filter_number == 2
    for x = 1:num
        title(['Region: ',num2str(x),'/',num2str(num),' Color: ', num2str(1)]);
        disp (x)
        [a,b] = myginput(2,'crosshair');
        plot([a(1);a(1);a(2);a(2); a(1)],[b(1);b(2);b(2);b(1); b(1)],'b','LineWidth',2);
        coord(:,:,x) = roipoly(imgBold,[a(1);a(1);a(2);a(2)],[b(1);b(2);b(2);b(1)]);
        mask2 = sum(coord,3);
        
    end
    for x = 1:num
        title(['Region: ',num2str(x),'/',num2str(num),' Color: ', num2str(2)]);
        disp (x)
        [a,b] = myginput(2,'crosshair');
        plot([a(1);a(1);a(2);a(2); a(1)],[b(1);b(2);b(2);b(1); b(1)],'r','LineWidth',2);
        coord(:,:,x) = roipoly(imgBold,[a(1);a(1);a(2);a(2)],[b(1);b(2);b(2);b(1)]);
        mask3 = sum(coord,3);
        
    end
    % Save masks
    maskall = mask2+mask3;
    maskall = logical(maskall);
    f_name = inputdlg('Write fly name');
    f_name = char(f_name);
    filename=char(fullfile(PathName,f_name));
    save(filename,'mask2','mask3','maskall');
% Combination 3 - red/green
elseif filter_number == 3
    for x = 1:num
        title(['Region: ',num2str(x),'/',num2str(num),' Color: ', num2str(1)]);
        disp (x)
        [a,b] = myginput(2,'crosshair');
        plot([a(1);a(1);a(2);a(2); a(1)],[b(1);b(2);b(2);b(1); b(1)],'g','LineWidth',2);
        coord(:,:,x) = roipoly(imgBold,[a(1);a(1);a(2);a(2)],[b(1);b(2);b(2);b(1)]);
        mask1 = sum(coord,3);
        
    end
    for x = 1:num
        title(['Region: ',num2str(x),'/',num2str(num),' Color: ', num2str(2)]);
        disp (x)
        [a,b] = myginput(2,'crosshair');
        plot([a(1);a(1);a(2);a(2); a(1)],[b(1);b(2);b(2);b(1); b(1)],'r','LineWidth',2);
        coord(:,:,x) = roipoly(imgBold,[a(1);a(1);a(2);a(2)],[b(1);b(2);b(2);b(1)]);
        mask3 = sum(coord,3);
        
    end
    % Save masks
    maskall = mask1+mask3;
    maskall = logical(maskall);
    f_name = inputdlg('Write fly name');
    f_name = char(f_name);
    filename=char(fullfile(PathName,f_name));
    save(filename,'mask1','mask3','maskall');
% Combination 4 - wholetube
elseif filter_number == 4
    for x = 1:num
        title(['Region: ',num2str(x),'/',num2str(num)]);
        disp (x)
        [a,b] = myginput(2,'crosshair');
        plot([a(1);a(1);a(2);a(2); a(1)],[b(1);b(2);b(2);b(1); b(1)],'r','LineWidth',2);
        coord(:,:,x) = roipoly(imgBold,[a(1);a(1);a(2);a(2)],[b(1);b(2);b(2);b(1)]);
        mask3 = sum(coord,3);
        
    end
    % Save masks
    maskall = logical(mask3);
    f_name = inputdlg('Write fly name');
    f_name = char(f_name);
    filename=char(fullfile(PathName,f_name));
    
    save(filename,'maskall');
% Combination 5 - 2D Arena
elseif filter_number == 5
    for x = 1:num
        title(['Region: ',num2str(x),'/',num2str(num),' Color: ', num2str(1)]);
        disp (x)
        [a,b] = myginput(2,'crosshair');
        plot([a(1);a(1);a(2);a(2); a(1)],[b(1);b(2);b(2);b(1); b(1)],'g','LineWidth',2);
        coord(:,:,x) = roipoly(imgBold,[a(1);a(1);a(2);a(2)],[b(1);b(2);b(2);b(1)]);
        mask1 = sum(coord,3);
        
    end
    for x = 1:num
        title(['Region: ',num2str(x),'/',num2str(num),' Color: ', num2str(2)]);
        disp (x)
        [a,b] = myginput(2,'crosshair');
        plot([a(1);a(1);a(2);a(2); a(1)],[b(1);b(2);b(2);b(1); b(1)],'b','LineWidth',2);
        coord(:,:,x) = roipoly(imgBold,[a(1);a(1);a(2);a(2)],[b(1);b(2);b(2);b(1)]);
        mask2 = sum(coord,3);
        
    end
    for x = 1:num
        title(['Region: ',num2str(x),'/',num2str(num),' Color: ', num2str(3)]);
        disp (x)
        [a,b] = myginput(2,'crosshair');
        plot([a(1);a(1);a(2);a(2); a(1)],[b(1);b(2);b(2);b(1); b(1)],'r','LineWidth',2);
        coord(:,:,x) = roipoly(imgBold,[a(1);a(1);a(2);a(2)],[b(1);b(2);b(2);b(1)]);
        mask3 = sum(coord,3);
        
    end
    for x = 1:num
        title(['Region: ',num2str(x),'/',num2str(num),' Color: ', num2str(4)]);
        disp (x)
        [a,b] = myginput(2,'crosshair');
        plot([a(1);a(1);a(2);a(2); a(1)],[b(1);b(2);b(2);b(1); b(1)],'w','LineWidth',2);
        coord(:,:,x) = roipoly(imgBold,[a(1);a(1);a(2);a(2)],[b(1);b(2);b(2);b(1)]);
        mask4 = sum(coord,3);
        
    end
    % Save masks
    maskall = mask1+mask2+mask3+mask4;
    maskall = logical(maskall);
    f_name = inputdlg('Write fly name');
    f_name = char(f_name);
    filename=char(fullfile(PathName,f_name));
    
    save(filename,'mask1','mask2','mask3','mask4','maskall');
end
    
