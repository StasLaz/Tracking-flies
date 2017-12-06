function [fl,imgA,imgBold,onelog,bg] = readfr(option,multip,darker,ptThresh)

% readfr is used to test video and masks for colorpref. 
% 
% 
%   in: option =    1 - read and show one frame.
%                       Function asks to chose video and specify time
%                       to find frame.
%                   2 - read frame and find flies.
%                       Function asks to chose video to find flies on, then
%                       video for first frame and then masks to find flies
%       multip      multiplies the difference between reference frame and 
%                   background frame for flies track (deffault = 10). Use
%                   higher multip if some flies are not found
%       darker      make background darker for better difference
%                   (deffault = 0.93). Use smaller darker if there is too
%                   much noise on onelog and false object found.
%       ptThresh    Threshold for video stabilization (deffault = 0.1). Use
%                   smaller ptThresh if there are few objects on video and
%                   stabilization is not good
%
%  out: frames      structure file with all the frames
%       filename    path for the tested video file
%       fl          binary image of found flies
%       imgA        first frame of the video
%       imgBold     b/w image with flies to find
%           


if nargin<2; multip = 10; end
if nargin<3; darker = 0.93; end
if nargin<4; ptThresh = 0.1; end
                                                                 
[FileName, PathName] = uigetfile('*.*' , 'Select video file','MultiSelect','off');
filename = fullfile(PathName, FileName);

T1 = [];
T2 = [];
T3 = [];
t=1;


%% READ AND SHOW FRAME
if option==1    
    vidObj = VideoReader(char(filename));
    Time = inputdlg({'Hour','Minute','Second'},'Time point', [1 7; 1 7; 1 7],{'2','0','0'});
    Time = str2double(Time);
    vidObj.CurrentTime = Time(1)*3600+Time(2)*60+Time(3);
    imgA = readFrame(vidObj);
    figure;
    imshow(uint8(imgA));
    fl=[];
    imgBold=[];
    onelog=[];

%% READ FRAME AND TEST MASKS FOR COLORPREF
elseif option==2                                                               
    [name_imgA,path_imgA]=uigetfile('*.*','Select video with initial frame',PathName);
    filename_imgA = fullfile(path_imgA, name_imgA);
    vid_imgA = VideoReader(char(filename_imgA));
    base = readFrame(vid_imgA);
    imgA = im2single(base(:,:,1));
    [name,path]=uigetfile('.mat','Select masks',PathName,'Multiselect','on');
    masks = fullfile(path,name);
    masks = cellstr(masks);
    vidObj = VideoReader(char(filename));
    background = zeros(vidObj.Height,vidObj.Width);
%     vidObj.CurrentTime = vidObj.Duration*(0.64);
    
        
    
    pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh);
    [featuresA, pointsA] = extractFeatures(imgA, pointsA);
%     background = imgA;
    %% CALCULATE BACKGROUND
    for Time=vidObj.Duration/20:vidObj.Duration/20-1:vidObj.Duration-1
        
        vidObj.CurrentTime = Time;
        frame = readFrame(vidObj);
        imgB = im2single(frame(:,:,1));
        
        
        pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);
        
        [featuresB, pointsB] = extractFeatures(imgB, pointsB);
        indexPairs = matchFeatures(featuresA, featuresB);
        pointsA2 = pointsA(indexPairs(:, 1), :);
        pointsB = pointsB(indexPairs(:, 2), :);
        [tform, ~, ~] = estimateGeometricTransform(pointsB, pointsA2, 'affine');
        imgBold = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
        frame = imgBold;
        if isempty(background)
            background = imgBold;
        end
        
        
        [x_coor,y_coor]=find(frame>background);
        for i=1:length(x_coor)
            background(x_coor(i),y_coor(i)) = frame(x_coor(i),y_coor(i));
        end
        
        
        
    end
    %% FIND FLIES
    vidObj.CurrentTime = vidObj.Duration*0.26;
%     vidObj.CurrentTime = 0.5;
    
    frame = readFrame(vidObj);
    
    imgB = im2single(frame(:,:,1));
    
    pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);
    
    [featuresB, pointsB] = extractFeatures(imgB, pointsB);
    indexPairs = matchFeatures(featuresA, featuresB);
    pointsA2 = pointsA(indexPairs(:, 1), :);
    pointsB = pointsB(indexPairs(:, 2), :);
    [tform, pointsBm, pointsAm] = estimateGeometricTransform(pointsB, pointsA2, 'affine');
    imgBold = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
    frame = imgBold;
    
    
    
    
    
    bg = background*darker;
    %                 differ = imfuse(frame(ttt).cdata,bg,'diff');
    %                 differ(differ>250) = 0;
    differ = (im2uint8(bg-frame))*multip;
    onelog = differ;
    onelog(onelog<254) = 0;
    fl = false(size(onelog));
    for masknum = 1:length(masks)
        load(char(masks(masknum)));
        maskobj = bwconncomp(maskall, 8);
        numflies = maskobj.NumObjects;
        [~,name,~]=fileparts(char(masks(masknum)));
        Var(masknum) = cellstr(name);
        box=false(size(maskall));
        box(maskobj.PixelIdxList{1,1}) = 1;
        [rows, columns] = find(box);
        topRow = min(rows);
        bottomRow = max(rows);
        leftColumn = min(columns);
        rightColumn = max(columns);
        orient = (bottomRow-topRow)-(rightColumn-leftColumn);
        
        bw = onelog.*uint8(maskall);
        bw = bwareaopen(bw, 5);
        cc = bwconncomp(bw, 8);
        stats = regionprops('table',cc,'MajorAxisLength');
        x = find (table2array(stats(:,{'MajorAxisLength'}))>30);
        
        for i=1:length(x)
            bw(cc.PixelIdxList{x(i)}) = 0;
        end
        cc = bwconncomp(bw, 8);
        ar = regionprops(cc,'Centroid');
        centroids = cat(1, ar.Centroid);
        ind=[];
        if isempty(centroids)==1
            disp('empty frame')
            disp(vidObj.CurrentTime)
            disp(masks(masknum))
            continue
        end
        if orient>=0
            
            indexing = 1;
            [centroids,ind] = sortrows(centroids,1);
        elseif orient<0
            [centroids,ind] = sortrows(centroids,2);
            indexing = 2;
        end
        del = [];
        dif = centroids(2:end,indexing)-centroids(1:end-1,indexing);
        sametube = find(dif<15);
        for tubenumber = 1:length(sametube)
            y = [sametube(tubenumber),sametube(tubenumber)+1];
            
            ab = zeros(length(cc.PixelIdxList),1);
            if isempty(ind)==1
                ab(y) = cellfun(@numel,cc.PixelIdxList(y));
            else
                ab(ind(y)) = cellfun(@numel,cc.PixelIdxList(ind(y)));
            end
            z = find(ab == min(ab(ab>0)));
            del = [del;z];
        end
        centroids(del,:)=[];
        if isempty(del)==0
            cc.PixelIdxList(del)=[];
        end
        num = min(size(centroids,1),numflies);
        
        if num ~= 0
            
            
            IDX = kmeans(centroids(:,indexing),num , 'EmptyAction','singleton');
            bw = false(size(bw));
            
            
            for m = 1:num
                y = find (IDX == m);
                ab = [];
                ab(y) = cellfun(@numel,cc.PixelIdxList(y));
                j = find(ab == max(ab));
                for l=1:length(j)
                    bw(cc.PixelIdxList{1,j(l)}) = true;
                end
            end
            
        end
        fl = fl+bw;
        if exist ('mask1','var')==1
            bw1 = bw.*mask1;
            cc1 = bwconncomp(bw1, 8);
            obj1(masknum,t) = cc1.NumObjects;
        end
        if exist ('mask2','var')==1
            bw2 = bw.*mask2;
            cc2 = bwconncomp(bw2, 8);
            obj2(masknum,t) = cc2.NumObjects;
        end
        if exist ('mask3','var')==1
            bw3 = bw.*mask3;
            cc3 = bwconncomp(bw3, 8);
            obj3(masknum,t) = cc3.NumObjects;
        end
    end
    figure;
    imshowpair(fl,imgBold);
    t=t+1;
    if exist ('obj1','var')==1
        T_green = array2table(obj1(:,1:t-1)','VariableNames', Var);
        T1 = [T1;T_green];
    end
    if exist ('obj2','var')==1
        T_blue = array2table(obj2(:,1:t-1)','VariableNames', Var);
        T2 = [T2;T_blue];
    end
    if exist ('obj3','var')==1
        T_red = array2table(obj3(:,1:t-1)','VariableNames', Var);
        T3 = [T3;T_red];
    end
 
end
