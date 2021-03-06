function [PathName] = trackfly(flylength,multip,darker,ptThresh)
% Finds flies positions for shacking video every second and writes down in
% file

%   in:     multip      multiplies the difference between reference frame and 
%                       background frame for flies track (deffault = 10). Use
%                       higher multip if some flies are not found
%           darker      make background darker for better difference
%                       (deffault = 0.93). Use smaller darker if there is too
%                       much noise on onelog and false object found.
%           ptThresh    Threshold for video stabilization (deffault = 0.1). Use
%                       smaller ptThresh if there are few objects on video and
%                       stabilization is not good
%
%   out:    PathName    location of the ouput files
%           
%           coordinates are stored in xls files in PathName location


if nargin<1; flylength = 18; end
if nargin<2; multip = 10; end
if nargin<3; darker = 0.93; end
if nargin<4; ptThresh = 0.1; end
flyarea_min = floor(flylength*1.5);                                         % Objects with area of >=flyarea_min pixels are considered to be candidates to be a fly (default flysize = 5)
tube_diameter = floor(flylength*1.5);                                       % Width of tubes used to limit to one fly in a tube (default width = 15)
framerate = 1;                                                             % Framerate for color preference 1 frame per seconds*framerate (default framerate = 60)

T1 = [];
T2 = [];
T3 = [];

coord = [];

%LOAD VIDEO FILES
[FileName, PathName] = uigetfile('*.*' , 'Select video files','MultiSelect','on');
filename = fullfile(PathName, FileName);

% k = 1;
%LOAD MASKS
[name,path]=uigetfile('.mat','Select masks',PathName,'Multiselect','on');
masks = fullfile(path,name);


masks = cellstr(masks);

for masknum = 1:length(masks)
    [~,name,~]=fileparts(char(masks(masknum)));
    path = [PathName,'coord',name(5:end)]; 
    mkdir(path);

end


% Determine how many video files you selected
if iscell(filename)
    NumberOfFiles=length(filename);
elseif filename ~= 0
    NumberOfFiles = 1;
    filename = cellstr(filename);
else
    NumberOfFiles = 0;
end
vidname = {};
for videonumber = 1:NumberOfFiles
    [~,abc,~]=fileparts(char(filename(videonumber)));
    vidname(videonumber,:) = {abc};
end





% Choose first frame to orient others
[name_imgA,path_imgA]=uigetfile('*.*','Select video with initial frame',PathName);
filename_imgA = fullfile(path_imgA, name_imgA);
vid_imgA = VideoReader(char(filename_imgA));
base = readFrame(vid_imgA);
imgA = im2single(base(:,:,1));

pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh);
[featuresA, pointsA] = extractFeatures(imgA, pointsA);

videonumber = 1;

for videonumber = 1:NumberOfFiles
    videoname = filename(videonumber);
    t=1;
    frame = struct('cdata',[],'colormap',[]);
    
    vidObj = VideoReader(char(videoname));
    vidObj.CurrentTime = 0;
    
    % Construct background
    background = [];
    for Time=vidObj.Duration/20:vidObj.Duration/20-1:vidObj.Duration*(19/20)   % Use multiple fames from video for background
        
        vidObj.CurrentTime = Time;
        frame(t).cdata = readFrame(vidObj);
        imgB = im2single(frame(t).cdata(:,:,1));
        
        pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);
        [featuresB, pointsB] = extractFeatures(imgB, pointsB);
        indexPairs = matchFeatures(featuresA, featuresB);
        pointsA2 = pointsA(indexPairs(:, 1), :);
        pointsB = pointsB(indexPairs(:, 2), :);
        [tform, pointsBm, pointsAm] = estimateGeometricTransform(...
            pointsB, pointsA2, 'affine');
        
        imgBold = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
        frame(t).cdata = imgBold;
        if isempty(background)
            background = imgBold;
        end
        
        
        [x_coor,y_coor]=find(frame(t).cdata(:,:,1)>frame(1).cdata(:,:,1));
        for i=1:length(x_coor)
            background(x_coor(i),y_coor(i),:) = frame(t).cdata(x_coor(i),y_coor(i),:);
        end
        t=t+1;
        
        
    end
    
    
    
    
    
    
    
    
    t=1;
    Time = 0;
    while Time<vidObj.Duration
        
        
        vidObj.CurrentTime = Time;
        
        
        frame(t).cdata = readFrame(vidObj);
        
        
        imgB = im2single(frame(t).cdata(:,:,1));
        pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);
        [featuresB, pointsB] = extractFeatures(imgB, pointsB);
        indexPairs = matchFeatures(featuresA, featuresB);
        pointsA2 = pointsA(indexPairs(:, 1), :);
        pointsB = pointsB(indexPairs(:, 2), :);
        [tform, pointsBm, pointsAm] = estimateGeometricTransform(...
            pointsB, pointsA2, 'affine');
        imgBold = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
        frame(t).cdata = imgBold;
        
        
        
        
        
        bg = background*darker;
        differ = (im2uint8(bg(:,:,1)-frame(t).cdata(:,:,1)))*multip;
        
       for masknum = 1:length(masks)
            asdf = load(char(masks(masknum)));
            maskobj = bwconncomp(asdf.maskall, 8);
            numflies = maskobj.NumObjects;
            [~,name,~]=fileparts(char(masks(masknum)));
            box=false(size(asdf.mask3));
            box(maskobj.PixelIdxList{1,1}) = 1;
            [rows, columns] = find(box);
            topRow = min(rows);
            bottomRow = max(rows);
            leftColumn = min(columns);
            rightColumn = max(columns);
            orient = (bottomRow-topRow)-(rightColumn-leftColumn);
            
            onelog = differ;
            onelog(onelog<254) = 0;
            bw = onelog.*uint8(asdf.maskall);
            bw = bwareaopen(bw, flyarea_min);                               % Delete objects smaller than permitted fly size
            cc = bwconncomp(bw, 8);                                         % Find all permitted objects
            
            stats = regionprops('table',cc,'MajorAxisLength');              % Delete large objects 
            x = find (table2array(stats(:,{'MajorAxisLength'}))>flylength*1.5);
            
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
            % Find if there more than one object per tube and leave only biggest
            if orient>=0                                                    % find orientation of tubes
                indexing = 1;
            elseif orient<0
                indexing = 2;
            end
            sametube=[];
            bw = false(size(bw));
            ab = cellfun(@numel,cc.PixelIdxList);                           %find size of objects
            sametube(:,1)=centroids(:,indexing);
            sametube(:,2)=ab;
            for tubenumber = 1:size(sametube,1)
                near_flies = find(sametube(:,1)>(sametube(tubenumber,1)-tube_diameter)&sametube(:,1)<(sametube(tubenumber,1)+tube_diameter));
                [~,ind2] = max(sametube(near_flies,2));
                real_fly = near_flies(ind2);
                
                bw(cc.PixelIdxList{real_fly}) = true;
            end
            cc = bwconncomp(bw, 8);
            ar = regionprops(cc,'Centroid');
            centroids = cat(1, ar.Centroid);
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
            
            
            
         cc = bwconncomp(bw, 8);
            ar = regionprops(cc,'Centroid');
            centroids2 = cat(1, ar.Centroid);
            num2 = min(size(centroids2,1),numflies);
            centroids2 = [centroids2(1:min(size(centroids2,1),numflies),:);zeros((36-num2),2)];
            centroids2 = round(centroids2);
            
           path = [PathName,'coord',name(5:end)];
            openfilename = [path,'\','coord',name(5:end),'_',char(vidname(videonumber,:)),'.csv'];
            fid = fopen(openfilename,'a+'); %Opens the file
            fprintf(fid, '%d,', centroids2(1:end-1,1));
            fprintf(fid, '%d\r\n',centroids2(end,1));
            fprintf(fid, '%d,', centroids2(1:end-1,2));
            fprintf(fid, '%d\r\n',centroids2(end,2));
            fclose(fid);

       end
       Time = floor(vidObj.CurrentTime + framerate);
       if Time>vidObj.Duration && Time<vidObj.Duration+30
           Time = vidObj.Duration;
       end
    end
    t=t+1;
end

