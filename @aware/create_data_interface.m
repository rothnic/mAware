function [ out ] = create_data_interface( obj, demoList )
%CREATE_DATA_INTERFACE - One line description of what the function or script performs (H1 line)
%   CREATE_DATA_INTERFACE has a second line of description that can go on to additional
%   lines if needed, for a more detailed description
%
% SYNTAX:
%   [ output1 ] = create_data_interface( requiredInput )
%   create_data_interface( requiredInput, 'optionalInput1', 'optionalInputValue' )
%   create_data_interface( requiredInput, 'optionalInput2', 50 )
%
% Description:
%   [ output_args ] = create_data_interface( requiredInput ) further description about
%        the use of the function can be added here.
%
% INPUTS:
%   requiredInput - Description
%   optionalInput1 - Description
%   optionalInput2 - Description
%
% OUTPUTS:
%   output1 - Description
%
% EXAMPLES:
%   Line 1 of multi-line use case goes here
%   Line 2...
%
% M-FILES required: none
%
% MAT-FILES required: none
%
% SEE ALSO: OTHER_FUNCTION1, OTHER_FUNCTION2
%
% Author:       nick roth
% email:        nick.roth@nou-systems.com
% Matlab ver.:  8.3.0.532 (R2014a)
% Date:         07-Aug-2014
% Update:

%% Input Parsing
%     % Setup input parsing
%     p = inputParser;
%     p.FunctionName = 'create_data_interface';
%     p.addRequired('requiredInput');
%     p.addParameter('optionalInput1', 'myDefaultValue', @isstr);
%     p.addParameter('optionalInput2', 100, @isscalar);
%     p.parse(requiredInput, varargin{:});
%
%     % Assign function variables
%     requiredInput = requiredProp;
%     optionalInput1 = p.Results.optionalInput1;
%     optionalInput2 = p.Results.optionalInput2;

%% Primary function logic begins here
% Create the user interface for the application and return a
% structure of handles for global use.
gui = struct();
% Open a window and add some menus
gui.Window = figure( ...
    'Name', 'Gallery browser', ...
    'NumberTitle', 'off', ...
    'MenuBar', 'none', ...
    'Toolbar', 'none', ...
    'HandleVisibility', 'off' );

% Set default panel color
uiextras.set( gui.Window, 'DefaultBoxPanelTitleColor', [0.7 1.0 0.7] );

% + File menu
gui.FileMenu = uimenu( gui.Window, 'Label', 'File' );
uimenu( gui.FileMenu, 'Label', 'Exit', 'Callback', @onExit );

% + View menu
gui.ViewMenu = uimenu( gui.Window, 'Label', 'View' );
for ii=1:numel( demoList )
    uimenu( gui.ViewMenu, 'Label', demoList{ii}, 'Callback', @onMenuSelection );
end

% + Help menu
helpMenu = uimenu( gui.Window, 'Label', 'Help' );
uimenu( helpMenu, 'Label', 'Documentation', 'Callback', @onHelp );


% Arrange the main interface
mainLayout = uiextras.HBoxFlex( 'Parent', gui.Window, 'Spacing', 3 );

% + Create the panels
controlPanel1 = uiextras.BoxPanel( ...
    'Parent', mainLayout, ...
    'Title', 'Select a demo:' );
controlPanel2 = uiextras.BoxPanel( ...
    'Parent', mainLayout, ...
    'Title', 'Select a demo:' );
gui.ViewPanel = uiextras.BoxPanel( ...
    'Parent', mainLayout, ...
    'Title', 'Viewing: ???', ...
    'HelpFcn', @onDemoHelp );

% + Adjust the main layout
set( mainLayout, 'Sizes', [-1 -2 -3]  );


% + Create the controls
controlLayout1 = uiextras.VBox( 'Parent', controlPanel1, ...
    'Padding', 3, 'Spacing', 3 );
controlLayout2 = uiextras.VBox( 'Parent', controlPanel2, ...
    'Padding', 3, 'Spacing', 3 );
gui.ListBox1 = uicontrol( 'Style', 'list', ...
    'BackgroundColor', 'w', ...
    'Parent', controlLayout1, ...
    'String', demoList(:), ...
    'Value', 1, ...
    'Callback', @onListSelection);
gui.ListBox2 = uicontrol( 'Style', 'list', ...
    'BackgroundColor', 'w', ...
    'Parent', controlLayout2, ...
    'String', demoList(:), ...
    'Value', 1, ...
    'Callback', @onListSelection);
gui.HelpButton = uicontrol( 'Style', 'PushButton', ...
    'Parent', controlLayout1, ...
    'String', 'Help for <demo>', ...
    'Callback', @onDemoHelp );
set( controlLayout1, 'Sizes', [-1 28] ); % Make the list fill the space
set( controlLayout2, 'Sizes', [-1] );

% + Create the view
p = gui.ViewPanel;
gui.ViewAxes = axes( 'Parent', p );

    function onListSelection( source, ~)
        disp(source);
        ctrlPanel = uiextras.BoxPanel( ...
        'Parent', mainLayout, ...
        'Title', 'Select a demo:' );
    end


end % createInterface

