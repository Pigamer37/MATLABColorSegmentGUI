clear,clc;
img = imread("..\OID_Cropped.png");
HSV = rgb2hsv(img);
YCbCr = rgb2ycbcr(img);
LAB = rgb2lab(img);
XYZ = rgb2xyz(img);
% channel1Min = 0.892; %H
% channel1Max = 0.135;
% channel2Min = 0.000; %S
% channel2Max = 1.000;
% channel3Min = 0.245; %V
% channel3Max = 1.000;
%% Plotting
RGBC = PlotChannels(img,"R","G","B");
HSVC = PlotChannels(HSV,"H","S","V");
YCbCrC = PlotChannels(YCbCr,"Y","Cb","Cr");
LABC=PlotChannels(LAB,"L","A","B");
XYZC=PlotChannels(XYZ,"X","Y","Z");
%% Create the GUI
f = uifigure("Name","Channel Slider GUI");
g = uigridlayout(f,[2,1],"RowHeight",{'0.7x','0.3x'});
gi = uigridlayout(g,"ColumnSpacing",0,"RowSpacing",0,"Padding",[0 0 0 0]);
ax = [uiaxes(gi),uiaxes(gi),uiaxes(gi)];
ax(1).Layout.Row=1;ax(2).Layout.Row=1;ax(3).Layout.Row=1;
ax(1).Layout.Column=1;ax(2).Layout.Column=2;ax(1).Layout.Column=3;
img2 = img;
imshow(img,"Parent",ax(3));
imshow(uint8(zeros(size(img))),"Parent",ax(2));
imshow(img2,"Parent",ax(1));
handles.i = img2;handles.o = img;handles.ax = ax;handles.cs = HSV;
%im = uiimage(f,ImageSource=img2);
p = uigridlayout(g,[1,2],"ColumnWidth","fit");
chan1 = uislider(p,"range","Value",[0 1],"Limits",[0 1]);
chan2 = uislider(p,"range","Value",[0 1],"Limits",[0 1]);
chan3 = uislider(p,"range","Value",[0 1],"Limits",[0 1]);
chan1.Layout.Row=1;chan2.Layout.Row=1;chan3.Layout.Row=1;
chan1.Layout.Column=1;chan2.Layout.Column=2;chan3.Layout.Column=3;
handles.chan1=chan1;handles.chan2=chan2;handles.chan3=chan3;
chan1.ValueChangedFcn=@(src,event) updateCh(src,event,handles);
chan2.ValueChangedFcn=@(src,event) updateCh(src,event,handles);
chan3.ValueChangedFcn=@(src,event) updateCh(src,event,handles);
%% Funcs
function updateCh(src,event,handles)
    mask2 = (handles.cs(:,:,1) >= handles.chan1.Value(1) ) & (handles.cs(:,:,1) <= handles.chan1.Value(2)) & ...
        (handles.cs(:,:,2) >= handles.chan2.Value(1) ) & (handles.cs(:,:,2) <= handles.chan2.Value(2)) & ... 
        (handles.cs(:,:,3) >= handles.chan3.Value(1) ) & (handles.cs(:,:,3) <= handles.chan3.Value(2));
    mask2 = cast(mask2,class(handles.o));
    handles.i=handles.o.*repmat(mask2,[1,1,3]);

    imshow(handles.o,"Parent",handles.ax(3));
    imshow(255*mask2,"Parent",handles.ax(2));
    imshow(handles.i,"Parent",handles.ax(1));
    guidata(src, handles);
end
function [channels] = PlotChannels(img, chan1Name, chan2Name, chan3Name)
    f=figure("Name",chan1Name+chan2Name+chan3Name);
    tiledlayout("horizontal","TileSpacing","none","Padding","tight");
    %subplot(1,3,1);
    nexttile;
    imshow(img(:,:,1)); title(chan1Name);
    %subplot(1,3,2);
    nexttile;
    imshow(img(:,:,2)); title(chan2Name);
    %subplot(1,3,3);
    nexttile;
    imshow(img(:,:,3)); title(chan3Name);
    channels = frame2im(getframe(f));
end