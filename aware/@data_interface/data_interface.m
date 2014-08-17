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
        listValues = {'Load Data'}
        selectedX = 1
        selectedY = 1
        Window
        FileMenu
        uiMenu
        ViewPanelVert
        NewVertViewButton
        ViewPanel
        NewHorzViewButton
        viewArea
        dataButton
        dataSourceMenu
        aes_menus
        views
        view_aes
        selected_aes
        dataSources
        menu_mapping

    end
    
    properties (Access = private)
        currentDataSource
        
        % styling
        backgroundColor
        headerColor
        buttonColor
        buttonTextColor
    end
    
    %% Methods
    methods
        % DATA_INTERFACE Constructor
        function self = data_interface( views )
            import tools.*
            
            max_aes = self.setup_views(views);
            
            % Open a window and add some menus
            self.Window = figure( ...
                'Name', 'aware', ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Toolbar', 'none', ...
                'HandleVisibility', 'off', ...
                'CloseRequestFcn', @(h,args)data_interface.onExit(h,args,self) );
            
            self.backgroundColor = rgbd(252, 252, 252);
            self.headerColor = rgbd(91,192,222);
            self.buttonColor = rgbd(231,231,231);
            self.buttonTextColor = rgbd(255,255,255);
            self.views = containers.Map();
            self.dataSources = containers.Map();
            
            % Set default panel color
            uiextras.set( self.Window, 'DefaultBoxPanelTitleColor', self.headerColor );
            uiextras.set( self.Window, 'DefaultBoxPanelForegroundColor', self.buttonTextColor );
            uiextras.set( self.Window, 'DefaultBoxPanelFontWeight', 'bold' );
            uiextras.set( self.Window, 'DefaultBoxPanelBackgroundColor', self.backgroundColor);
            uiextras.set( self.Window, 'DefaultHBoxFlexBackgroundColor', self.backgroundColor);
            uiextras.set( self.Window, 'DefaultVBoxFlexBackgroundColor', self.backgroundColor);
            uiextras.set( self.Window, 'DefaultVBoxBackgroundColor', self.backgroundColor);
            
            %% Setup Menus
            % Setup File menu
            self.FileMenu = uimenu( self.Window, 'Label', 'File' );
            uimenu( self.FileMenu, 'Label', 'Exit', 'Callback', @(h,args)data_interface.onExit(h,args,self) );
            
            % Setup Help menu
            helpMenu = uimenu( self.Window, 'Label', 'Help' );
            uimenu( helpMenu, 'Label', 'Documentation', 'Callback', @data_interface.onHelp );
            
            %% Setup the main interface as a horizontal layout
            mainLayout = uiextras.HBoxFlex( 'Parent', self.Window, 'Spacing', 3 );
            
            %% Create the main panels
            % Control Panels
            controlPanel1 = uiextras.BoxPanel( ...
                'Parent', mainLayout, ...
                'Title', 'Configure Data Source' );
            
            % Plots are contained in a verticle layout panel
            self.ViewPanelVert = uiextras.VBoxFlex( 'Parent', mainLayout, ...
                'Padding', 3, 'Spacing', 3 );
            
            % There is one button at the top to add more rows
            self.NewVertViewButton = uicontrol('Parent', self.ViewPanelVert, ...
                'String', '+', 'BackgroundColor', self.buttonColor, ...
                'Callback', @(h,vars)data_interface.addRow(h,vars,self));
            
            % Each row is a HBox
            self.ViewPanel = uiextras.HBoxFlex( 'Parent', self.ViewPanelVert );
            
            % Each row has a button to add more views
            self.NewHorzViewButton = uicontrol('Parent', self.ViewPanel, ...
                'String', '+', 'BackgroundColor', self.buttonColor, ...
                'Callback', @(h,vars)data_interface.addPlot(h,vars,self));
            init_view = self.setup_view(self.ViewPanel.double);
            
            % Set Button and initial View sizes
            set( self.ViewPanel, 'Sizes', [15 -1]  );
            set( self.ViewPanelVert, 'Sizes', [15, -1]  );
            
            %% Adjust the main layout
            set( mainLayout, 'Sizes', [-1 -3]  );
            
            %% Create the data source configuration components
            configLayout = uiextras.VBox( 'Parent', controlPanel1, ...
                'Padding', 3, 'Spacing', 3 );
            self.dataButton = uicontrol( 'Style', 'PushButton', ...
                'Parent', configLayout, ...
                'String', 'Data Source', 'BackgroundColor', self.buttonColor, ...
                'Callback', @(h,vars)data_interface.getData(h,vars,self) );
            dataBox = uiextras.HBox( 'Parent', configLayout, ...
                'Padding', 1, 'Spacing', 1 );
            self.dataSourceMenu = uicontrol( 'Style', 'popup', ...
                'Parent', dataBox, ...
                'String', self.listValues, 'BackgroundColor', self.buttonColor, ...
                'Callback', @(h,vars)data_interface.updateDataSource(h,vars,self) );
            
            % Create as many config menus as necessary
            self.setup_menus(max_aes, configLayout);
            self.map_menus();
            
            self.selectedPanel = init_view.viewBoxHandle; % Set init view as selected
        end
        
        function dv = setup_view(self, parent)
            %SETUP_AXES - creates default axis to inject into new view
            
            id = length(self.views) + 1;
            dv = data_view(id, parent, self);
            self.add_view(dv);
        end
        
        function add_view(self, view)
            %ADD_VIEW - adds the view to Map
            
            self.views(num2str(view.viewBoxHandle)) = view;
        end
        
                
        function data = getDataByName(self, dataName)
            %GETDATABYNAME - returns the data table related to the name of
            %the data table loaded from the workspace.
            
            if ~strcmp(dataName, 'Configure Data Source')
                data = self.dataSources(dataName);
            else
                data = [];
            end
        end
        
        function max_aes = setup_views(self, views)
            %SETUP_VIEWS - collects setup information from native and
            %plugin views.
            
            self.view_aes = containers.Map();
            max_aes = 0;
            
            for i = 1:length(views)
                view_name = views{i};
                [~, req_aes] = self.get_view_info(view_name);
                if length(req_aes) > max_aes
                    max_aes = length(req_aes);
                end
                self.view_aes(view_name) = req_aes;
            end
        end
        
        
        function setup_menus(self, max_aes, parent)
            %SETUP_MENUS - Creates menus for each view aesthetic
            
            for i = 1:max_aes
                tempBox = uiextras.HBox( 'Parent', parent, ...
                    'Padding', 1, 'Spacing', 1 );
                self.aes_menus(i) = uicontrol('Style', 'popup',...
                    'Parent', tempBox, ...
                    'String', self.listValues, 'BackgroundColor', self.buttonColor, ...
                    'Callback', @(h,vars)data_interface.updatePlot(h,vars,self));
            end
            
            % Set the layout wieghts
            % Negative numbers vary with resize with a weight, constant numbers don't
            set( parent, 'Sizes', [28 repmat(20, 1, max_aes + 1)] ); % List1 and help button
        end
        
        function map_menus(self)
            %MAP_MENUS - Creates a mapping between each created menu and a
            %mapping between each loaded plot type and its associated
            %aesthetic for the specific menu type. This is a map of maps,
            %so we can easily update the column number when the menu
            %changes to the selected plot type.
            
            self.menu_mapping = containers.Map();
            
            plot_types = self.view_aes.keys;
            
            for i = 1:length(self.aes_menus)
                thisMap = containers.Map();
                for j = 1:length(plot_types)
                    this_aes = self.view_aes(plot_types{j});
                    if length(this_aes) >= i
                        % Create mapping between menu handle and view+aes
                        thisMap(plot_types{j}) = this_aes{i};
                    end
                end
                self.menu_mapping(num2str(self.aes_menus(i))) = thisMap;
            end
            
        end
        
        function update_menus(self, view)
            %UPDATE_MENUS - sets configuration panel/menu settings based on
            %the selected plot type
            
            view_name = class(view);
            [~, aes_vals] = self.get_view_info(view_name);
            
            for i = 1:length(self.aes_menus)
                if length(aes_vals) >= i
                    set(self.aes_menus(i), 'Visible', 'on');
                else
                    set(self.aes_menus(i), 'Visible', 'off');
                end
            end
        end

    end

    %% Static Methods
    methods (Static)
        %% Callback Functions
        
        function [view_type, req_aes] = get_view_info(view_name)
            %GET_VIEW_INFO - returns information based on the plot type
            
            % aes
            view_str = strcat(view_name, '.', 'get_aes(''', view_name, ''')');
            req_aes = eval(view_str); 
            
            % plot type
            type_str = strcat(view_name, '.', 'get_plot_type(''', view_name, ''')');
            view_type = eval(type_str);
        end
        
        function getData( ~, ~, gui )
            %GETDATA - Allows user to select a data source for plotting
            
            [dataSource, dsName] = uigetvariables('Data Source', 'InputTypes', 'table');
            
            if ~isempty(dataSource)
                gui.dataSources(dsName{1,1}) = dataSource{1,1};
                gui.currentDataSource = dsName{1,1};
                set(gui.dataSourceMenu, 'String', gui.dataSources.keys);
                gui.updateDataSource([],[],gui);
            end
        end
        
        function updateDataSource(~, ~, gui)
            tempData = gui.dataSources(gui.currentDataSource);
            gui.listValues = tempData.Properties.VariableNames;
            
            % Update aesthetic menus
            for i = 1:length(gui.aes_menus)
                set(gui.aes_menus(i), 'String', gui.listValues);
            end
            
            % Update view information
            for i = 1:length(gui.selectedPanel)
                thisView = gui.views(num2str(gui.selectedPanel(i)));
                thisView.data_source = gui.currentDataSource;
            end
        end
        
        function updatePlot( source, ~, gui )
            %UPDATEPLOT - Updates the plot when configuration changes
            
            for i = 1:length(gui.selectedPanel)
                pan = gui.views(num2str(gui.selectedPanel(i)));
                pan.data_source = gui.currentDataSource;
                view = gui.views(num2str(gui.selectedPanel(i)));
                view_type = class(view);
                
                % Get this menu map
                menu_map = gui.menu_mapping(num2str(source));
                this_aes = menu_map(view_type);
                view.aes_mapping(this_aes) = get(source, 'Value');
                view.update();
            end
            
            % Force updating of data source related properties
            gui.updateDataSource([],[],gui);
            
        end
        
        function addRow( ~, ~, gui )
            %ADDVERTVIEW - Adds a new row to the graph grid
            
            newHorzViewPanel = uiextras.HBoxFlex( ...
                'Parent', gui.ViewPanelVert );
            uicontrol('Parent', newHorzViewPanel, 'BackgroundColor', gui.buttonColor, ...
                'String', '+', 'Callback', @(h,vars)data_interface.addPlot(h,vars,gui));
            gui.setup_view(newHorzViewPanel.double);
            
            set( newHorzViewPanel, 'Sizes', [15 -1]  );
        end
        
        function addPlot( source, ~, gui )
            %ADDHVIEW - Adds a new graph to the associated rows
            
            parent = get(source, 'Parent');
            gui.setup_view(parent);
        end
        
        function button_handler(source, ~, gui)
            %BUTTON_HANDLER - Handles mouse clicks on the graphs
            
            % Get the object that was pressed
            parent = get(source, 'Parent'); % parent of current object
            view = gui.views(num2str(parent));
            
            % If we have a selection, loop through them and reset
            if gui.selectedPanel ~= 0
                for i = 1:length(gui.selectedPanel)
                    set(gui.selectedPanel(i), 'BorderType', 'etchedin');
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
                    view_name = class(view);
                    [this_view_type, ~] = gui.get_view_info(view_name);
                    
                    % make sure we are selecting the same plot types
                    type_diff = 0;
                    for i = 1:length(gui.selectedPanel)
                        sel_view = gui.views(num2str(gui.selectedPanel(i)));
                        view_name = class(sel_view);
                        [sel_view_type, ~] = gui.get_view_info(view_name);
                        if ~strcmp(this_view_type, sel_view_type)
                            type_diff = 1;
                        end
                    end
                    
                    % if there is no type difference append selection
                    if ~type_diff
                        len = length(gui.selectedPanel);
                        gui.selectedPanel(len+1) = parent;
                    else
                        gui.selectedPanel = parent;
                    end

                case 'open'
                    pass;
            end
            
            % Loop through each selected panel and set their style
            for i = 1:length(gui.selectedPanel)
                set(gui.selectedPanel(i), 'BorderType', 'beveledin');
            end
            
            gui.update_menus(view);
        end
        
        function onExit(source,~,self)
            %ONEXIT - Clears the aware object from workspace on exit
            delete(self);
            delete(source);
            try
                ansVal = evalin('base', 'ans');
                if isa(ansVal, 'aware')
                    evalin('base', 'clear(''ans'')');
                end
            catch
                pass;
            end

        end

    end

end