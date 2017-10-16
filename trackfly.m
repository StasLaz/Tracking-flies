function [coord,filename,masks,background,vidObj] = trackfly(multip,darker,ptThresh)
% Finds flies positions for shacking video every second and writes down in
% file

%   in: multip      multiplies the difference between reference frame and 
%                   background frame for flies track (deffault = 10). Use
%                   higher multip if some flies are not found
%       darker      make background darker for better difference
%                   (deffault = 0.93). Use smaller darker if there is too
%                   much noise on onelog and false object found.
%       ptThresh    Threshold for video stabilization (deffault = 0.1). Use
%                   smaller ptThresh if there are few objects on video and
%                   stabilization is not good
%


if nargin<1; multip = 10; end
if nargin<2; darker = 0.93; end
if nargin<3; ptThresh = 0.1; end

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


% if masks ~= 0
masks = cellstr(masks);

for masknum = 1:length(masks)
    [~,name,~]=fileparts(char(masks(masknum)));
    path = [PathName,'coord',name(5:end)]; 
    mkdir(path);
%     openfilename = [path,'coord',name(5:end),'.csv'];
%     fid = fopen(openfilename,'a+');
%     fprintf(fid,'%s\r\n',path);
%     fprintf(fid,'%s\r\n',FileName(1:end));
%     fclose(fid);
end

% end

% Determin how many video files you selected
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




%first frame

if exist ('imgA','var')==0
    firstframe = VideoReader(char(filename(1)));
    base = readFrame(firstframe);
    imgA = im2single(base(:,:,1));
end
pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh);
[featuresA, pointsA] = extractFeatures(imgA, pointsA);
videonumber = 1;

parfor videonumber = 1:NumberOfFiles
    videoname = filename(videonumber);
    %     [background_frame2,vidObj] = ExtractBackground_two(videoname);
    
    %     [T_green,T_blue,T_red] = checkflies_three_manyflies(background,vidObj,masks);
    
    
    t=1;
    frame = struct('cdata',[],'colormap',[]);
    
    vidObj = VideoReader(char(videoname));
    
    
    vidObj.CurrentTime = 0;
    
%     Time = vidObj.CurrentTime;
    background = [];
    for Time=vidObj.Duration/20:vidObj.Duration/20-1:vidObj.Duration-1
        
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
    
    
    
    
    
    
    
    
    %     vidNumber = ceil((n+1)/(480));
    t=1;
    Time = 0;
    while Time<vidObj.Duration
        
        
        vidObj.CurrentTime = Time;
        
        
        frame(t).cdata = readFrame(vidObj);
        
        Time = Time + 1;
        imgB = im2single(frame(t).cdata(:,:,1));
%         ptThresh = 0.1;
%         pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh);
        pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);
%         [featuresA, pointsA] = extractFeatures(imgA, pointsA);
        [featuresB, pointsB] = extractFeatures(imgB, pointsB);
        indexPairs = matchFeatures(featuresA, featuresB);
        pointsA2 = pointsA(indexPairs(:, 1), :);
        pointsB = pointsB(indexPairs(:, 2), :);
        [tform, pointsBm, pointsAm] = estimateGeometricTransform(...
            pointsB, pointsA2, 'affine');
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
        frame(t).cdata = imgBold;
        
        
        
        
        
        bg = background*darker;
        %                 differ = imfuse(frame(ttt).cdata,bg,'diff');
        %                 differ(differ>250) = 0;
        differ = (im2uint8(bg(:,:,1)-frame(t).cdata(:,:,1)))*multip;
        
        % I=differ;
        % se = strel('disk', 3);
        % Ie = imerode(I, se);
        % Iobr = imreconstruct(Ie, I);
        % Iobrd = imdilate(Iobr, se);
        % Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
        % Iobrcbr = imcomplement(Iobrcbr);
        for masknum = 1:length(masks)
            asdf = load(char(masks(masknum)));
            maskobj = bwconncomp(asdf.maskall, 8);
            numflies = maskobj.NumObjects;
            [~,name,~]=fileparts(char(masks(masknum)));
%             Var(masknum) = cellstr(name);
            box=false(size(asdf.mask3));
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
            bw = onelog.*uint8(asdf.maskall);
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
            stats = regionprops('table',cc,'Centroid','MajorAxisLength','MinorAxisLength','BoundingBox');
            
            x = find (table2array(stats(:,{'MajorAxisLength'}))>18);
            
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
            if orient>0
                
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
            
            
            
            %                     bw1 = bw.*mask1;
            %                     cc1 = bwconncomp(bw1, 8);
            %                     obj1(masknum,ttt) = cc1.NumObjects;
            %                     bw2 = bw.*mask2;
            %                     cc2 = bwconncomp(bw2, 8);
            %                     obj2(masknum,ttt) = cc2.NumObjects;
            %                     bw3 = bw.*mask3;
            %                     cc3 = bwconncomp(bw3, 8);
            %                     obj3(masknum,ttt) = cc3.NumObjects;
            cc = bwconncomp(bw, 8);
            ar = regionprops(cc,'Centroid');
            centroids2 = cat(1, ar.Centroid);
            num2 = min(size(centroids2,1),numflies);
            centroids2 = [centroids2(1:min(size(centroids2,1),numflies),:);zeros((36-num2),2)];
            centroids2 = round(centroids2);
            
%             coord = [coord,centroids2];
%             openfilename = ['coord',name(5:end),'.csv'];
%             openfilename = [path,'coord',name(5:end),'.csv'];
            path = [PathName,'coord',name(5:end)];
            openfilename = [path,'\','coord',name(5:end),'_',char(vidname(videonumber,:)),'.csv'];
            fid = fopen(openfilename,'a+'); %Opens the file
%             fprintf(fid,'%s\r\n',path);
%             fprintf(fid,'%s\r\n',FileName);
            fprintf(fid, '%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\r\n', centroids2);
            fclose(fid);

        end
        
       
        
        
        
        
        %     Color = [Color;color];
    end
    %             T_green = array2table(obj1','VariableNames', Var);
    %             T_blue = array2table(obj2','VariableNames', Var);
    %             T_red = array2table(obj3','VariableNames', Var);
    %
    %
    %
    %             T1 = [T1;T_green];
    %             T2 = [T2;T_blue];
    %             T3 = [T3;T_red];
    
    
    t=t+1;
    
    
    
    % total = sum(Color,2);
    % colornorm(:,1) = Color(:,1)./total;
    % colornorm(:,2) = Color(:,2)./total;
    % colornorm(:,3) = Color(:,3)./total;
    
    %     colorfile = fullfile(PathName,['color_pref_', savefile]);
    % colorfile_norm = fullfile(PathName,['color_pref_','norm_', savefile]);
    %     save(colorfile,'color');
    % save(colorfile_norm,'colornorm');
    
    
    
end

