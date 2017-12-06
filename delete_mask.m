function [mask1,mask2,mask3,maskall] = delete_mask(bg,PathName)
% function to delete tubes with dead flies from masks. Uses bg from
% readfr.m or colorpref.m
% left click on zones you want to delete, right click to delete, then any
% button to close window. New masks will have those zones deleted


if nargin<2; PathName=[]; end

[name,path]=uigetfile('.mat','Select masks',PathName);
masks = fullfile(path,name);
load(char(masks));
masks_to_write = {};
figure(100)
if exist('bg','var')==1
    imshow(bg);
    waitforbuttonpress;
else
    error('bg not found');
end
warning('off','all')
bw = bwselect(maskall,4);
maskall = maskall-bw;
if exist ('mask1','var')==1
    mask1 = mask1-double(bw);
    mask1(mask1<0)=0;
    masks_to_write = {'mask1'};
end
if exist ('mask2','var')==1
    mask2 = mask2-double(bw);
    mask2(mask2<0)=0;
    masks_to_write = [masks_to_write,'mask2'];
end
if exist ('mask3','var')==1
    mask3 = mask3-double(bw);
    mask3(mask3<0)=0;
    masks_to_write = [masks_to_write,'mask3'];
end
if exist ('mask4','var')==1
    mask4 = mask4-double(bw);
    mask4(mask4<0)=0;
    masks_to_write = [masks_to_write,'mask4'];
end




maskall = logical(maskall);
masks_to_write = [masks_to_write,'maskall'];
imshow(maskall);
waitforbuttonpress;
close (figure(100))
defaultans = {name};
f_name = inputdlg('Write fly name','Edited mask',1,defaultans);
    f_name = char(f_name);
    filename=char(fullfile(path,f_name));
    
    save(filename,masks_to_write{:});
