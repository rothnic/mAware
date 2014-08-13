classdef data_interface < handle
    %DATA_INTERFACE - One line summary of this class goes here
    %   DATA_INTERFACE has a first line of the description of myClass, but
    %   descriptions can include multiple lines of text if needed.
    %
    % SYNTAX:
    %   myObject = data_interface( requiredProp )
    %   myObject = data_interface( requiredProp, 'optionalInput1', 'optionalInputValue' )
    %   myObject = data_interface( requiredInput, 'optionalInput2', 50 )
    %
    % Description:
    %   myObject = data_interface( requiredProp ) further description about the use
    %       of the function can be added here.
    %
    % PROPERTIES:
    %   requiredProp - Description of requiredProp
    %   optionalProp1 - Description of optionalProp1
    %   optionalProp2 - Description of optionalProp2
    %
    % METHODS:
    %   doThis - Description of doThis
    %   doThat - Description of doThat
    %
    % EXAMPLES:
    %   Line 1 of multi-line use case goes here
    %   A class can use this area for further explaining methods.
    %
    % SEE ALSO: OTHER_CLASS1, OTHER_FUNCTION1
    %
    % Author:       nick roth
    % email:        nick.roth@data_interface.nou-systems.com
    % Matlab ver.:  8.3.0.532 (R2014a)
    % Date:         11-Aug-2014
    % Update:
    %TODO: Set plot header based on data source
    %TODO: Add configuration for mapping column to color
    %TODO: Add configuration for mapping column to size
    %TODO: Add macro for generating lots of plots quickly
    %TODO: Add bar chart type of plot as option
    %TODO: Add histogram type of plot as option
    %TODO: Add boxplot plot as an option
    %TODO: Fix exit callback
    
    %% Properties
    properties
        selectedPanel = 0
        listValues = {'Select Data'}
        selectedX = 1
        selectedY = 1
        Window
        FileMenu
        ViewPanelVert
        NewVertViewButton
        ViewPanel
        NewHorzViewButton
        viewArea
        dataButton
        xMenu
        yMenu
        ViewAxes
        dataSource
        Tag = 'data_interface'
    end
    
    %% Methods
    methods
        % DATA_INTERFACE Constructor
        function gui = data_interface( )

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
            uimenu( gui.FileMenu, 'Label', 'Exit', 'Callback', @data_interface.onExit );
            
            % Setup Help menu
            helpMenu = uimenu( gui.Window, 'Label', 'Help' );
            uimenu( helpMenu, 'Label', 'Documentation', 'Callback', @data_interface.onHelp );
            
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
                'String', '+', 'Callback', @(h,vars)data_interface.addRow(h,vars,gui));
            
            % Each row is a HBox
            gui.ViewPanel = uiextras.HBoxFlex( 'Parent', gui.ViewPanelVert );
            
            % Each row has a button to add more views
            gui.NewHorzViewButton = uicontrol('Parent', gui.ViewPanel, ...
                'String', '+', 'Callback', @(h,vars)data_interface.addPlot(h,vars,gui));
            
            % Each plot requires a box panel to sit in
            gui.viewArea = uiextras.BoxPanel( ...
                'Parent', gui.ViewPanel, ...
                'Title', 'Viewing: ???', ...
                'HelpFcn', @data_interface.onDemoHelp );
            
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
                'Callback', @(h,vars)data_interface.getData(h,vars,gui) );
            gui.xMenu = uicontrol('Style', 'popup',...
                'Parent', controlLayout1, ...
                'String', gui.listValues,...
                'Callback', @(h,vars)data_interface.updatePlot(h,vars,gui));
            gui.yMenu = uicontrol('Style', 'popup',...
                'Parent', controlLayout1, ...
                'String', gui.listValues,...
                'Callback', @(h,vars)data_interface.updatePlot(h,vars,gui));
            
            % Set the layout wieghts
            % Negative numbers vary with resize with a weight, constant numbers don't
            set( controlLayout1, 'Sizes', [28 20 20] ); % List1 and help button
            
            %% Create the initial plot view
            gui.ViewAxes = gui.setup_axes(gui.viewArea);
            gui.selectedPanel = get(gui.ViewAxes, 'Parent');
        end
        
        function ax = setup_axes(obj, panel)
            %SETUP_AXES - Creates a standard axis for the given panel
            
            ax = axes( 'Parent', panel, ...
                'ButtonDownFcn', @(h,vars)data_interface.button_handler(h,vars,obj));
            line('XData',[],'YData',[],'Parent',ax);
        end

    end

    %% Static Methods
    methods (Static)
        %% Callback Functions
        function getData( ~, ~, gui )
            %GETDATA - Allows user to select a data source for plotting
            
            [dataSources, dsNames] = uigetvariables('Data Source', 'InputTypes', 'table');
            %TODO: implement plot to data source mapping
            
            if ~isempty(dataSources)
                gui.dataSource = dataSources{1,1}; %TODO: handle multiple data sources?
                gui.listValues = gui.dataSource.Properties.VariableNames;
                set(gui.xMenu, 'String', gui.listValues);
                set(gui.yMenu, 'String', gui.listValues);
            end
        end
        
        function updatePlot( source, ~, gui )
            %UPDATEPLOT - Updates the plot when configuration changes
            
            if source == gui.xMenu
                gui.selectedX = get(source,'Value');
            else
                gui.selectedY = get(source, 'Value');
            end
            
            for i = 1:length(gui.selectedPanel)
                pan = gui.selectedPanel(i);
                childs = get(pan, 'Children');
                lin = get(childs, 'Children');
                
                xVals = gui.dataSource{:, gui.selectedX};
                yVals = gui.dataSource{:, gui.selectedY};
                if isnumeric(xVals) && isnumeric(yVals)
                    set(lin, 'XData', gui.dataSource{:, gui.selectedX}, ...
                        'YData', gui.dataSource{:, gui.selectedY}, ...
                        'LineStyle', 'none', 'Marker', '.');
                else
                    warndlg('Only numeric values at this time')
                end
            end
            
        end
        
        function addRow( ~, ~, gui )
            %ADDVERTVIEW - Adds a new row to the graph grid
            
            newHorzViewPanel = uiextras.HBoxFlex( ...
                'Parent', gui.ViewPanelVert );
            NewHorzViewButton = uicontrol('Parent', newHorzViewPanel, ...
                'String', '+', 'Callback', @(h,vars)data_interface.addPlot(h,vars,gui));
            newAxisContainer = uiextras.BoxPanel( ...
                'Parent', newHorzViewPanel, ...
                'Title', 'Configure Data Source' );
            newView = gui.setup_axes(newAxisContainer);
            
            set( newHorzViewPanel, 'Sizes', [15 -1]  );
        end
        
        function addPlot( source, ~, gui )
            %ADDHVIEW - Adds a new graph to the associated rows
            
            srcObj = get(source);
            parent = srcObj.Parent;
            ctrlPanel = uiextras.BoxPanel( ...
                'Parent', parent, ...
                'Title', 'Select a demo:');
            newView = gui.setup_axes(ctrlPanel);
        end
        
        function button_handler(source, ~, gui)
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
        

    end

    %% Private Methods
    methods (Access = private)
        % Methods that should not be seen by the user

        % Functions stored in a separate 'm' file listed out
        separateMfileFunction(input1, input2)
        % Now can be used with data_interface.separateMfileFunction(input1, input2)
    end

end