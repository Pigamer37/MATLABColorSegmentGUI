clear, clc;
img = imread("peppers.png");

%% Create the GUI
f = uifigure('Name', 'Color Space Channel Filter', 'WindowState', 'maximized');
g = uigridlayout(f, [4, 3], 'RowHeight', {'fit', '2x', 'fit', 'fit'}, ...
    'ColumnWidth', {'1x', '1x', '1x'}, 'Padding', 10, 'RowSpacing', 10, 'ColumnSpacing', 10);

% Title and dropdown
titleLabel = uilabel(g, 'Text', 'Color Space:', 'FontSize', 14, 'FontWeight', 'bold');
titleLabel.Layout.Row = 1;
titleLabel.Layout.Column = 1;

dd = uidropdown(g, 'Items', ["HSV", "YCbCr", "LAB", "XYZ"], 'Value', "HSV", 'FontSize', 12);
dd.Layout.Row = 1;
dd.Layout.Column = 2;

resetBtn = uibutton(g, 'Text', 'Reset', 'FontSize', 12);
resetBtn.Layout.Row = 1;
resetBtn.Layout.Column = 3;

% Create image axes with titles
ax1 = uiaxes(g);
ax1.Layout.Row = 2;
ax1.Layout.Column = 1;
title(ax1, 'Original Image', 'FontSize', 12, 'FontWeight', 'bold');
axis(ax1, 'off');

ax2 = uiaxes(g);
ax2.Layout.Row = 2;
ax2.Layout.Column = 2;
title(ax2, 'Binary Mask', 'FontSize', 12, 'FontWeight', 'bold');
axis(ax2, 'off');

ax3 = uiaxes(g);
ax3.Layout.Row = 2;
ax3.Layout.Column = 3;
title(ax3, 'Filtered Result', 'FontSize', 12, 'FontWeight', 'bold');
axis(ax3, 'off');

% Channel labels
chanLabel1 = uilabel(g, 'Text', 'H (Hue)', 'FontSize', 11, 'FontWeight', 'bold');
chanLabel1.Layout.Row = 3;
chanLabel1.Layout.Column = 1;

chanLabel2 = uilabel(g, 'Text', 'S (Saturation)', 'FontSize', 11, 'FontWeight', 'bold');
chanLabel2.Layout.Row = 3;
chanLabel2.Layout.Column = 2;

chanLabel3 = uilabel(g, 'Text', 'V (Value)', 'FontSize', 11, 'FontWeight', 'bold');
chanLabel3.Layout.Row = 3;
chanLabel3.Layout.Column = 3;

% Sliders
chan1 = uislider(g, 'range', 'Value', [0 1], 'Limits', [0 1]);
chan1.Layout.Row = 4;
chan1.Layout.Column = 1;

chan2 = uislider(g, 'range', 'Value', [0 1], 'Limits', [0 1]);
chan2.Layout.Row = 4;
chan2.Layout.Column = 2;

chan3 = uislider(g, 'range', 'Value', [0 1], 'Limits', [0 1]);
chan3.Layout.Row = 4;
chan3.Layout.Column = 3;

% Store handles in UserData
handles.originalImg = img;
handles.convertedImg = rgb2hsv(img); % Defaut value
handles.ax = [ax1, ax2, ax3];
handles.dd = dd;
handles.chan1 = chan1;
handles.chan2 = chan2;
handles.chan3 = chan3;
handles.chanLabels = [chanLabel1, chanLabel2, chanLabel3];
f.UserData = handles;

% Set callback functions for each interactive element of the GUI
dd.ValueChangedFcn = @(src, event) convertColorspace(src, event, src.Parent.Parent.UserData);
chan1.ValueChangedFcn = @(src, event) update(src, event, src.Parent.Parent.UserData);
chan2.ValueChangedFcn = @(src, event) update(src, event, src.Parent.Parent.UserData);
chan3.ValueChangedFcn = @(src, event) update(src, event, src.Parent.Parent.UserData);
resetBtn.ButtonPushedFcn = @(src, event) reset(src, event, src.Parent.Parent.UserData);

% Initialize the app for the very first time
convertColorspace(dd, [], f.UserData);

%% Helper functions
function convertColorspace(src, ~, handles)
    % Update channel labels based on color space
    switch handles.dd.Value
        case "HSV"
            % Even though HUE goes from 0 to 360
            % MATLAB represents this channel from 0 to 1.
            handles.convertedImg = rgb2hsv(handles.originalImg);
            labels = ["H (Hue)", "S (Saturation)", "V (Value)"];
            limits = [0 1; 0 1; 0 1];
        case "YCbCr"
            % Convert to double to work with floating point values [0, 255]
            handles.convertedImg = double(rgb2ycbcr(handles.originalImg));
            labels = ["Y (Luma)", "Cb (Blue-diff)", "Cr (Red-diff)"];
            limits = [0 255; 0 255; 0 255];
        case "LAB"
            handles.convertedImg = rgb2lab(handles.originalImg);
            labels = ["L (Lightness)", "a (Green-Red)", "b (Blue-Yellow)"];
            limits = [0 100; -127 127; -127 127];
        case "XYZ"
            handles.convertedImg = rgb2xyz(handles.originalImg);
            labels = ["X", "Y", "Z"];
            limits = [0 1; 0 1; 0 1];
    end

    % Update labels, limits, and ticks for each channel
    for i = 1:3
        handles.chanLabels(i).Text = labels(i);
        slider = handles.(['chan' num2str(i)]);
        slider.Limits = limits(i, :);
        slider.Value = limits(i, :);

        % Set appropriate tick marks based on range
        range = limits(i, 2) - limits(i, 1);
        if range <= 2
            tickStep = 0.2;
        elseif range <= 10
            tickStep = 1;
        elseif range <= 50
            tickStep = 10;
        else
            tickStep = 20;
        end
        slider.MajorTicks = limits(i, 1):tickStep:limits(i, 2);
        slider.MinorTicks = [];
    end

    src.Parent.Parent.UserData = handles;

    update(src, [], handles);
end

function update(~, ~, handles)
    cs_image = handles.convertedImg;

    % Create mask based on slider values
    mask = (cs_image(:, :, 1) >= handles.chan1.Value(1)) & ...
           (cs_image(:, :, 1) <= handles.chan1.Value(2)) & ...
           (cs_image(:, :, 2) >= handles.chan2.Value(1)) & ...
           (cs_image(:, :, 2) <= handles.chan2.Value(2)) & ...
           (cs_image(:, :, 3) >= handles.chan3.Value(1)) & ...
           (cs_image(:, :, 3) <= handles.chan3.Value(2));

    % Apply mask to original image. 
    % We're using repmat to replicate the mask in the in the third
    % dimension which is the channels. (H, W, C).
    filteredImg = handles.originalImg .* uint8(repmat(mask, [1, 1, 3]));

    % displayImg = cs_image;
    % switch handles.dd.Value
    %     case "YCbCr"
    %         % Normalize to [0, 1] for display
    %         displayImg = cs_image / 255;
    %     case "LAB"
    %         % Normalize LAB to [0, 1] all channels for display
    %         displayImg(:,:,1) = cs_image(:,:,1) / 100;
    %         displayImg(:,:,2) = (cs_image(:,:,2) + 127) / 254;
    %         displayImg(:,:,3) = (cs_image(:,:,3) + 127) / 254;
    %     case "XYZ"
    %         % XYZ is already in [0, 1] (kind of)
    %         displayImg = max(0, min(1, cs_image));
    %     case "HSV"
    %         % HSV is already in [0, 1]
    %         displayImg = cs_image;
    % end
    
    % Display images
    imshow(handles.originalImg, 'Parent', handles.ax(1));
    imshow(mask, 'Parent', handles.ax(2));
    imshow(filteredImg, 'Parent', handles.ax(3));
end

function reset(~, ~, handles)
    % Reset the whole app to its default values
    handles.dd.Value = "HSV";
    fig = handles.dd.Parent.Parent;
    convertColorspace(handles.dd, [], handles);
    fig.UserData = handles;
end
