function [ gui ] = create_data_interface( obj, demoList )
%CREATE_DATA_INTERFACE - Sets up interface for exploring multivariate data
%
% SYNTAX:
%   [ guiStruct ] = create_data_interface( obj, demoList )
%
% Description:
%
% INPUTS:
%
% OUTPUTS:
%   output1 - Description
%
% EXAMPLES:
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

%% Primary function logic begins here
import tools.*

% Create the user interface for the application and return a
% structure of handles for global use.
gui = struct();

% Globals
gui.selectedPanel = 0;

% Open a window and add some menus
gui.Window = figure( ...
    'Name', 'aware', ...
    'NumberTitle', 'off', ...
    'MenuBar', 'none', ...
    'Toolbar', 'none', ...
    'HandleVisibility', 'off' );

% Set default panel color
uiextras.set( gui.Window, 'DefaultBoxPanelTitleColor', [0.7 1.0 0.7] );

%% Setup Menus
% Setup File menu
gui.FileMenu = uimenu( gui.Window, 'Label', 'File' );
uimenu( gui.FileMenu, 'Label', 'Exit', 'Callback', @onExit );

% Setup View menu
gui.ViewMenu = uimenu( gui.Window, 'Label', 'View' );
for ii=1:numel( demoList )
    uimenu( gui.ViewMenu, 'Label', demoList{ii}, 'Callback', @onMenuSelection );
end

% Setup Help menu
helpMenu = uimenu( gui.Window, 'Label', 'Help' );
uimenu( helpMenu, 'Label', 'Documentation', 'Callback', @onHelp );

%% Setup the main interface as a horizontal layout
mainLayout = uiextras.HBoxFlex( 'Parent', gui.Window, 'Spacing', 3 );

%% Create the main panels
% Control Panels
controlPanel1 = uiextras.BoxPanel( ...
    'Parent', mainLayout, ...
    'Title', 'Select a demo:' );

% Plots are contained in a verticle layout panel
gui.ViewPanelVert = uiextras.VBoxFlex( 'Parent', mainLayout, ...
    'Padding', 3, 'Spacing', 3 );

% There is one button at the top to add more rows
gui.NewVertViewButton = uicontrol('Parent', gui.ViewPanelVert, ...
    'String', '+', 'Callback', @addRow);

% Each row is a HBox
gui.ViewPanel = uiextras.HBoxFlex( 'Parent', gui.ViewPanelVert );

% Each row has a button to add more views
gui.NewHorzViewButton = uicontrol('Parent', gui.ViewPanel, ...
    'String', '+', 'Callback', @addPlot);

% Each plot requires a box panel to sit in
gui.viewArea = uiextras.BoxPanel( ...
    'Parent', gui.ViewPanel, ...
    'Title', 'Viewing: ???', ...
    'HelpFcn', @onDemoHelp );

% Set Button and initial View sizes
set( gui.ViewPanel, 'Sizes', [15 -1]  );
set( gui.ViewPanelVert, 'Sizes', [15, -1]  );

%% Adjust the main layout
set( mainLayout, 'Sizes', [-1 -3]  );

%% Create the data source configuration components
controlLayout1 = uiextras.VBox( 'Parent', controlPanel1, ...
    'Padding', 3, 'Spacing', 3 );
gui.dataButton = uicontrol( 'Style', 'PushButton', ...
    'Parent', controlLayout1, ...
    'String', 'Data Source', ...
    'Callback', @getData );
gui.ListBox1 = uicontrol( 'Style', 'list', ...
    'BackgroundColor', 'w', ...
    'Parent', controlLayout1, ...
    'String', demoList(:), ...
    'Value', 1, ...
    'Callback', @onListSelection);
gui.HelpButton = uicontrol( 'Style', 'PushButton', ...
    'Parent', controlLayout1, ...
    'String', 'Help for <demo>', ...
    'Callback', @onDemoHelp );

% Set the layout wieghts
% Negative numbers vary with resize with a weight, constant numbers don't
set( controlLayout1, 'Sizes', [28 -1 28] ); % List1 and help button

%% Create the initial plot view
gui.ViewAxes = setup_axes(gui.viewArea);

%% Callback Functions
    function getData( source, ~)
        datasource = uigetvariables('Data Source', 'InputTypes', 'table');
    end

    function addRow( source, ~)
        %ADDVERTVIEW - Adds a new row to the graph grid
        
        newHorzViewPanel = uiextras.HBoxFlex( ...
            'Parent', gui.ViewPanelVert );
        NewHorzViewButton = uicontrol('Parent', newHorzViewPanel, ...
            'String', '+', 'Callback', @addPlot);
        newAxisContainer = uiextras.BoxPanel( ...
            'Parent', newHorzViewPanel, ...
            'Title', 'Select a demo:' );
        newView = setup_axes(newAxisContainer);
        
        set( newHorzViewPanel, 'Sizes', [15 -1]  );
    end

    function addPlot( source, ~)
        %ADDHVIEW - Adds a new graph to the associated rows
        
        srcObj = get(source);
        parent = srcObj.Parent;
        ctrlPanel = uiextras.BoxPanel( ...
        'Parent', parent, ...
        'Title', 'Select a demo:');
        newView = setup_axes(ctrlPanel);
    end

    function button_handler(source, ~)
        %BUTTON_HANDLER - Handles mouse clicks on the graphs
        
        % Get the object that was pressed
        thisObj = get(source);
        parent = get(source, 'Parent'); % parent of current object
        
        % If we have a selection, loop through them and reset
        if gui.selectedPanel ~= 0
            for i = 1:length(gui.selectedPanel)
                set(gui.selectedPanel, 'BorderType', 'etchedin')
            end
        end
        
        % Get button press type
        buttonType = get(gui.Window, 'SelectionType');
        
        % Do different things for each button press
        switch buttonType
            case 'normal'
                gui.selectedPanel = parent;
            case 'extend'
                pass;
            case 'alt'
                len = length(gui.selectedPanel);
                gui.selectedPanel(len+1) = parent;
            case 'open'
                pass;
        end  
        
        % Loop through each selected panel and set their style
        for i = 1:length(gui.selectedPanel)
            set(gui.selectedPanel, 'BorderType', 'beveledin');
        end
    end

%% Helper Functions
    function ax = setup_axes(panel)
        %SETUP_AXES - Creates a standard axis for the given panel
        
        ax = axes( 'Parent', panel, ...
            'ButtonDownFcn', @button_handler);
    end

end % createInterface

