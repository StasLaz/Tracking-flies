function [color_preference,T1,T2,T3,filename,masks,background,vidObj,imgA] = new_colorpref_shake(flysize,multip,darker,ptThresh)
% For shacking video every minute

%       flysize     approximate length of flies in videos in pixels. 
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
if nargin<2; flysize = 18; end
if nargin<3; multip = 10; end
if nargin<4; darker = 0.93; end
if nargin<5; ptThresh = 0.1; end

% multip = 20;                                                                % multiplier for flies track (default = 10)
% ptThresh = 0.1;                                                             % thrashold for stabilization (default = 0.1)
% flysize = 30;                                                               % size of fly (default = 18, for old video use 30)
% darker = 0.93;                                                              % make background darker(deffault = 0.93)
color_preference = [];
T1 = [];
T2 = [];
T3 = [];
t=1;
coord = [];
frame = [];
%Load video files
[FileName, PathName] = uigetfile('*.*' , 'Select video files','MultiSelect','on');
filename = fullfile(PathName, FileName);

% Determine how many video files you selected
if iscell(filename)
    NumberOfFiles=length(filename);
elseif filename ~= 0
    NumberOfFiles = 1;
    filename = cellstr(filename);
else
    NumberOfFiles = 0;
end

%first frame
[name_imgA,path_imgA]=uigetfile('*.*','Select video with initial frame',PathName);
filename_imgA = fullfile(path_imgA, name_imgA);
vid_imgA = VideoReader(char(filename_imgA));
base = readFrame(vid_imgA);
imgA = im2single(base(:,:,1));

pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh);
[featuresA, pointsA] = extractFeatures(imgA, pointsA);

%Load masks
[name,path]=uigetfile('.mat','Select masks',PathName,'Multiselect','on');
masks = fullfile(path,name);
masks = cellstr(masks);
videonumber = 1;

%Find color preference for each video
while videonumber <= NumberOfFiles
    videoname = filename(videonumber);
    %     [background_frame2,vidObj] = ExtractBackground_two(videoname);
    
    %     [T_green,T_blue,T_red] = checkflies_three_manyflies(background,vidObj,masks);
    
    
    
    
    
    vidObj = VideoReader(char(videoname));
    
    
    vidObj.CurrentTime = 0;
    
%     Time = vidObj.CurrentTime;
%     background = imgA;
    background = [];
    for Time=vidObj.Duration/20:vidObj.Duration/20-1:vidObj.Duration-3600
        
        vidObj.CurrentTime = Time;
        frame = readFrame(vidObj);
        imgB = im2single(frame(:,:,1));
        
        
        pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);
        
        [featuresB, pointsB] = extractFeatures(imgB, pointsB);
        indexPairs = matchFeatures(featuresA, featuresB);
        pointsA2 = pointsA(indexPairs(:, 1), :);
        pointsB = pointsB(indexPairs(:, 2), :);
        try
            [tform, pointsBm, pointsAm] = estimateGeometricTransform(pointsB, pointsA2, 'affine');
        catch
            disp(['Bad frame ', vidObj.Name,' ',num2str(Time)])
            continue
        end
        %         imgBp = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
        %         pointsBmp = transformPointsForward(tform, pointsBm.Location);
%         H = tform.T;
%         R = H(1:2,1:2);
%         % Compute theta from mean of two possible arctangents
%         theta = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);
%         % Compute scale from mean of two stable mean calculations
%         scale = mean(R([1 4])/cos(theta));
%         % Translation remains the same:
%         translation = H(3, 1:2);
%         % Reconstitute new s-R-t transform:
%         HsRt = [[scale*[cos(theta) -sin(theta); sin(theta) cos(theta)]; ...
%             translation], [0 0 1]'];
%         tformsRT = affine2d(HsRt);
        imgBold = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
        %         imshow(imgBold);
        frame = imgBold;
        if isempty(background)
            background = imgBold;
        end
        
        
        [x_coor,y_coor]=find(frame>background);
        for i=1:length(x_coor)
            background(x_coor(i),y_coor(i)) = frame(x_coor(i),y_coor(i));
        end
        
        
        
    end
    
    
    
    
    
    
    
    
    %     vidNumber = ceil((n+1)/(480));
    
    Time = 0;
    while Time<vidObj.Duration
        
        
       
        vidObj.CurrentTime = Time;
        
        
        frame = readFrame(vidObj);
        
%         Time = Time + 60;
        imgB = im2single(frame(:,:,1));
        
        pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);
        
        [featuresB, pointsB] = extractFeatures(imgB, pointsB);
        indexPairs = matchFeatures(featuresA, featuresB);
        pointsA2 = pointsA(indexPairs(:, 1), :);
        pointsB = pointsB(indexPairs(:, 2), :);
        try
            [tform, pointsBm, pointsAm] = estimateGeometricTransform(pointsB, pointsA2, 'affine');
        catch
            disp(['Bad frame ', vidObj.Name,' ',num2str(Time)])
            Time = floor(vidObj.CurrentTime + 60);
            if Time>vidObj.Duration && Time<vidObj.Duration+30
                Time = vidObj.Duration;
            end
            t=t+1;
            continue
        end
        
        %         imgBp = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
        %         pointsBmp = transformPointsForward(tform, pointsBm.Location);
%         H = tform.T;
%         R = H(1:2,1:2);
%         % Compute theta from mean of two possible arctangents
%         theta = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);
%         % Compute scale from mean of two stable mean calculations
%         scale = mean(R([1 4])/cos(theta));
%         % Translation remains the same:
%         translation = H(3, 1:2);
%         % Reconstitute new s-R-t transform:
%         HsRt = [[scale*[cos(theta) -sin(theta); sin(theta) cos(theta)]; ...
%             translation], [0 0 1]'];
%         tformsRT = affine2d(HsRt);
        imgBold = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
        %         imshow(imgBold);
        frame = imgBold;
        
        
        
        
        
        bg = background*darker;
        %                 differ = imfuse(frame(ttt).cdata,bg,'diff');
        %                 differ(differ>250) = 0;
        differ = (im2uint8(bg-frame))*multip;
        
        % I=differ;
        % se = strel('disk', 3);
        % Ie = imerode(I, se);
        % Iobr = imreconstruct(Ie, I);
        % Iobrd = imdilate(Iobr, se);
        % Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
        % Iobrcbr = imcomplement(Iobrcbr);
        allbw=false(960,1280);
        for masknum = 1:length(masks)
            load(char(masks(masknum)));
            maskobj = bwconncomp(mask3, 8);
            numflies = maskobj.NumObjects;
            [~,name,~]=fileparts(char(masks(masknum)));
            Var(masknum) = cellstr(name);
            box=false(size(mask3));
            box(maskobj.PixelIdxList{1,1}) = 1;
            [rows, columns] = find(box);
            topRow = min(rows);
            bottomRow = max(rows);
            leftColumn = min(columns);
            rightColumn = max(columns);
            orient = (bottomRow-topRow)-(rightColumn-leftColumn);
            
            %                     onelog = false(size(differ));
            %                     onelog(differ>20) = true;
            %                     bw = onelog.*maskall;
            onelog = differ;
            onelog(onelog<254) = 0;
            bw = onelog.*uint8(maskall);
            bw = bwareaopen(bw, 5);
            cc = bwconncomp(bw, 8);
            your_count = sum(cellfun(@(x) numel(x),cc.PixelIdxList));
            %                     if your_count>numflies*125
            %                         onelog = false(size(differ));
            %                         onelog(differ>40) = true;
            %                         bw = onelog.*maskall;
            %                         bw = bwareaopen(bw, 5);
            %                         cc = bwconncomp(bw, 8);
            %                     end
            stats = regionprops('table',cc,'MajorAxisLength');
            
            x = find (table2array(stats(:,{'MajorAxisLength'}))>flysize);
            
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
%             cc = bwconncomp(bw, 8);
%             ar = regionprops(cc,'Centroid');
%             centroids2 = cat(1, ar.Centroid);
%             num2 = min(size(centroids2,1),numflies);
%             centroids2 = [centroids2(1:min(size(centroids2,1),numflies),:);zeros((36-num2),2)];
%             centroids2 = round(centroids2);
%             
%             coord = [coord,centroids2];
%             openfilename = ['coord',name(5:end),'.csv'];
%             fid = fopen(openfilename,'a+'); %Opens the file
%             fprintf(fid, '%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\r\n', centroids2);
%             fclose(fid);
            allbw = allbw+bw;
        end
        
        
        
        
        Time = floor(vidObj.CurrentTime + 60);
        if Time>vidObj.Duration && Time<vidObj.Duration+30
            Time = vidObj.Duration;
        end
        t=t+1;
        %     Color = [Color;color];
    end
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
    
    
    
    
    
    t=1;
    
    
    
    
    
    videonumber = videonumber+1;
    % total = sum(Color,2);
    % colornorm(:,1) = Color(:,1)./total;
    % colornorm(:,2) = Color(:,2)./total;
    % colornorm(:,3) = Color(:,3)./total;
    
    %     colorfile = fullfile(PathName,['color_pref_', savefile]);
    % colorfile_norm = fullfile(PathName,['color_pref_','norm_', savefile]);
    %     save(colorfile,'color');
    % save(colorfile_norm,'colornorm');
    
    
    
end
for i=1:length(Var)
color_preference = setfield(color_preference, ['color_',Var{i}(7:end)],...
    [table2array(T1(:,i)),table2array(T2(:,i)),table2array(T3(:,i))]);
end
