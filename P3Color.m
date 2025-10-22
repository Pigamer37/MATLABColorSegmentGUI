clear,clc;
img = imread("..\OID_Cropped.png");
HSV = rgb2hsv(img);
YCbCr = rgb2ycbcr(img);
LAB = rgb2lab(img);
XYZ = rgb2xyz(img);
%% Plotting
RGBC = PlotChannels(img,"R","G","B");
HSVC = PlotChannels(HSV,"H","S","V");
YCbCrC = PlotChannels(YCbCr,"Y","Cb","Cr");
LABC=PlotChannels(LAB,"L","A","B");
XYZC=PlotChannels(XYZ,"X","Y","Z");
%% Funcs
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