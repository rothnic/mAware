classdef filter_interface < handle
    %FILTER_INTERFACE - a gui tool for filtering table formatted data
    %   FILTER_INTERFACE provides a gui for quickly filtering rows in a
    %   table formatted data structure. It provides the capability to
    %   generate a filter configuration on multiple columns simultaneously,
    %   then quickly view the results, and iterate on modifying the filters
    %   and viewing the results until the desired dataset is reached. The
    %   filtered data is saved into the workspace for further use.
    %
    % SYNTAX:
    %   filter_interface( data )
    %
    % Description:
    %   filter_interface( data ) opens the filter gui on the input data
    %
    % INPUTS:
    %   data - a table data structure
    %
    % EXAMPLES:
    %   data = readtable('my_data.csv');
    %   filter_interface(data);
    %   % Do what you want with data_temp
    %
    % SEE ALSO: AWARE, TABLE, FILTER_DATABASE
    %
    % Author:       nick roth
    % email:        nick.roth@nou-systems.com
    % Matlab ver.:  8.3.0.532 (R2014a)
    % Date:         21-Aug-2014
    
    %% Properties
    properties
        Window
        FileMenu
        DataMenu
        FieldsPanel
        ValuesPanel
        NumPanel
        ItemsPanel
        OptionsPanel
        
        % Filter Panels
        LessThanPanel
        GreaterThanPanel
        EqualToPanel
        NotEqualPanel
        
        % Filter Menus
        FieldsMenu
        ValuesMenu
        LessThanMenu
        GreaterThanMenu
        EqualToMenu
        NotEqualMenu
        
        % Button Map
        button_map
        btn_handle_add
        btn_handle_remove
        NumButtonPanelLess
        NumButtonPanelGreater
        
        % Filters
        less_filters
        greater_filters
        equal_filters
        not_equal_filters
        filters
        
        % State
        current_fields = {}
        
        % Data
        data
        data_orig
        data_name
        filtered_data
        table
    end
    
    %% Dependent Properties
    properties (Dependent)
        current_values = {}
    end
    
    %% Private Properties
    properties (Access = private)
        backgroundColor
        menuColor
        headerColor
        buttonColor
        buttonTextColor
    end
    
    %% Constructor
    methods
        % FILTER_INTERFACE Constructor
        function self = filter_interface(data, varargin)
            import tools.*
            
            self.data = data;
            self.data_name = inputname(1);
            self.filtered_data = data;
            self.button_map = containers.Map();
            self.less_filters = containers.Map();
            self.greater_filters = containers.Map();
            self.equal_filters = containers.Map();
            self.not_equal_filters = containers.Map();
            
            self.Window = figure( ...
                'Name', 'aware: filter', ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Toolbar', 'none', ...
                'HandleVisibility', 'off', ...
                'Position', [200 200 1024 600], ...
                'CloseRequestFcn', @(h,args)filter_interface.on_exit(h,args,self) );
            
            self.backgroundColor = rgbd(252, 252, 252);
            self.menuColor = rgbd(252, 252, 252);
            self.headerColor = rgbd(91,192,222);
            self.buttonColor = rgbd(231,231,231);
            self.buttonTextColor = rgbd(255,255,255);
            
            % Set default panel color
            uiextras.set( self.Window, 'DefaultBoxPanelTitleColor', self.headerColor );
            uiextras.set( self.Window, 'DefaultBoxPanelForegroundColor', self.buttonTextColor );
            uiextras.set( self.Window, 'DefaultBoxPanelFontWeight', 'bold' );
            uiextras.set( self.Window, 'DefaultBoxPanelBackgroundColor', self.backgroundColor);
            uiextras.set( self.Window, 'DefaultHBoxFlexBackgroundColor', self.backgroundColor);
            uiextras.set( self.Window, 'DefaultVBoxFlexBackgroundColor', self.backgroundColor);
            uiextras.set( self.Window, 'DefaultVBoxBackgroundColor', self.backgroundColor);
            uiextras.set( self.Window, 'DefaultUicontrolHorizontalAlignment', 'left' ); 
            
            %% Setup Menus
            % Setup File Menu
            self.FileMenu = uimenu( self.Window, 'Label', 'File' );
            uimenu( self.FileMenu, 'Label', 'Exit', 'Callback', ...
                @(h,args)filter_interface.on_exit(h,args,self) );
            % Setup Data Menu
            self.DataMenu = uimenu( self.Window, 'Label', 'Export Data' );
            uimenu( self.DataMenu, 'Label', 'Save to Workspace', 'Callback', ...
                @(h,vars)filter_interface.saveData(h,vars,self) );
            % Setup Help menu
            helpMenu = uimenu( self.Window, 'Label', 'Help' );
            uimenu( helpMenu, 'Label', 'Documentation', 'Callback', @filter_interface.on_help );
            
            %% Setup the main interface as a horizontal layout
            container = uiextras.VBox( 'Parent', self.Window, 'Spacing', 3 );
            mainLayout = uiextras.HBoxFlex( 'Parent', container, 'Spacing', 3 );
            tableLayout = uiextras.VBox( 'Parent', container);

            %% Create the main panels
            % Fields Panel
            self.FieldsPanel = uiextras.BoxPanel( ...
                'Parent', mainLayout, ...
                'Title', 'Fields' , 'MinimizeFcn', ...
                @(h,vars)filter_interface.sort_fields(h,vars,self));
            
            % Values Panel
            self.ValuesPanel = uiextras.BoxPanel( ...
                'Parent', mainLayout, ...
                'Title', 'Values', 'MinimizeFcn', ...
                @(h,vars)filter_interface.sort_values(h,vars,self));
            
            % Num Filters Panel
            self.NumPanel = uiextras.BoxPanel( ...
                'Parent', mainLayout, ...
                'Title', 'Numerical Filters' );
            
            % Item Filters Panel
            self.ItemsPanel = uiextras.BoxPanel( ...
                'Parent', mainLayout, ...
                'Title', 'Item Filters' );
            
            % Options Panel
            self.OptionsPanel = uiextras.BoxPanel( ...
                'Parent', mainLayout, ...
                'Title', 'Options' );
            
            set( mainLayout, 'Sizes', [-2 -2 -3 -3 -2]  );
            
            %% Add the contents to the Fields Panel
            
            self.FieldsMenu = uicontrol('Style', 'listbox',...
                'Parent', self.FieldsPanel, ...
                'String', {}, 'BackgroundColor', self.menuColor, ...
                'Callback', @(h,vars)filter_interface.update_values_callback(h,vars,self));
            
            %% Add the contents to the Values Panel
            
            self.ValuesMenu = uicontrol('Style', 'listbox',...
                'Parent', self.ValuesPanel, ...
                'String', {}, 'BackgroundColor', self.menuColor, ...,
                'HorizontalAlignment', 'Left', ...
                'Min',1,'Max',200);
            
            %% Add the contents to the Num Filters Panel
            
            % Set up internal Num Panel Structure
            NumVertPanel = uiextras.VBoxFlex( 'Parent', self.NumPanel );
            NumPanel_Less = uiextras.BoxPanel( ...
                'Parent', NumVertPanel, ...
                'Title', 'Less Than' );
            NumPanel_Greater = uiextras.BoxPanel( ...
                'Parent', NumVertPanel, ...
                'Title', 'Greater Than' );
            
            % Add Less Than Panel
            self.LessThanPanel = uiextras.HBoxFlex( 'Parent', NumPanel_Less );
            
            % Add Button Container
            self.NumButtonPanelLess = uiextras.VBox( 'Parent', self.LessThanPanel );
            
            % Add to Less Than Button
            self.btn_handle_add(1) = self.create_button(self.NumButtonPanelLess, '+');
            self.btn_handle_remove(1) = self.create_button(self.NumButtonPanelLess, '-');
            
            % Less Than Menu
            self.LessThanMenu = uicontrol('Style', 'listbox',...
                'Parent', self.LessThanPanel, ...
                'String', {''}, 'BackgroundColor', self.menuColor, ...
                'Min',1,'Max',200);
            
            % Create map between buttons and menu
            self.button_map(num2str(self.btn_handle_add(1))) = self.LessThanMenu;
            self.button_map(num2str(self.btn_handle_remove(1))) = self.LessThanMenu;
            
            % Add Greater Than Panel
            self.GreaterThanPanel = uiextras.HBoxFlex( 'Parent', NumPanel_Greater );
            
            % Add Button Container
            self.NumButtonPanelGreater = uiextras.VBox( 'Parent', self.GreaterThanPanel );
            
            % Add to Greater Than Button
            self.btn_handle_add(2) = self.create_button(self.NumButtonPanelGreater, '+');
            self.btn_handle_remove(2) = self.create_button(self.NumButtonPanelGreater, '-');
            
            % Greater Than Menu
            self.GreaterThanMenu = uicontrol('Style', 'listbox',...
                'Parent', self.GreaterThanPanel, ...
                'String', {''}, 'BackgroundColor', self.menuColor, ...
                'Min',1,'Max',200);
            
            % Create map between buttons and menu
            self.button_map(num2str(self.btn_handle_add(2))) = self.GreaterThanMenu;
            self.button_map(num2str(self.btn_handle_remove(2))) = self.GreaterThanMenu;
            
            set( self.LessThanPanel, 'Sizes', [15 -1] );
            set( self.GreaterThanPanel, 'Sizes', [15 -1] );
            
            %% Add the contents to the Item Filters Panel
            
            % Setup the Item Filters Panel Structure
            ItemsVertPanel = uiextras.VBoxFlex( 'Parent', self.ItemsPanel );
            ItemsPanel_Equal = uiextras.BoxPanel( ...
                'Parent', ItemsVertPanel, ...
                'Title', 'Equal To' );
            ItemsPanel_NotEqual = uiextras.BoxPanel( ...
                'Parent', ItemsVertPanel, ...
                'Title', 'Not Equal To' );
            
            % Add Equal To Panel
            self.EqualToPanel = uiextras.HBoxFlex( 'Parent', ItemsPanel_Equal );
            
            % Add Button Container
            ItemsButtonPanel = uiextras.VBox( 'Parent', self.EqualToPanel );
            
            % Add Equal To Button
            self.btn_handle_add(3) = self.create_button(ItemsButtonPanel, '+');
            self.btn_handle_remove(3) = self.create_button(ItemsButtonPanel, '-');
            
            % Add Equal Menu
            self.EqualToMenu = uicontrol('Style', 'listbox',...
                'Parent', self.EqualToPanel, ...
                'String', {''}, 'BackgroundColor', self.menuColor, ...
                'Min',1,'Max',200);
            
            % Create map between buttons and menu
            self.button_map(num2str(self.btn_handle_add(3))) = self.EqualToMenu;
            self.button_map(num2str(self.btn_handle_remove(3))) = self.EqualToMenu;
            
            % Add Not Equal Panel
            self.NotEqualPanel = uiextras.HBoxFlex( 'Parent', ItemsPanel_NotEqual );
            
            % Add Button Container
            ItemsButtonPanel2 = uiextras.VBox( 'Parent', self.NotEqualPanel );
            
            % Add to Not Equal Button
            self.btn_handle_add(4) = self.create_button(ItemsButtonPanel2, '+');
            self.btn_handle_remove(4) = self.create_button(ItemsButtonPanel2, '-');
            
            % Greater Than Menu
            self.NotEqualMenu = uicontrol('Style', 'listbox',...
                'Parent', self.NotEqualPanel, ...
                'String', {''}, 'BackgroundColor', self.menuColor, ...
                'Min',1,'Max',200);
            
            % Create map between buttons and menu
            self.button_map(num2str(self.btn_handle_add(4))) = self.NotEqualMenu;
            self.button_map(num2str(self.btn_handle_remove(4))) = self.NotEqualMenu;
            
            set( self.EqualToPanel, 'Sizes', [15 -1] );
            set( self.NotEqualPanel, 'Sizes', [15 -1] );
            
            %% Add the Options to the Options Panel
            control_panel = uiextras.VBox( 'Parent', self.OptionsPanel );
            
            % Setup buttons
            control_buttons = uiextras.HBox( 'Parent', control_panel );
            uicontrol( 'String', 'Reset', 'Parent', control_buttons, ...
                'Callback', @(h,vars)filter_interface.reset_filters(h,vars,self));
            uicontrol( 'String', 'View Data', 'Parent', control_buttons, ...
                'Callback', @(h,vars)filter_interface.view_data(h,vars,self));
            
            control_options = uiextras.HBox( 'Parent', control_panel );
            
            set(control_panel, 'Sizes', [50 -1]);
            
            %% Set menu alignment
            menus_list = [self.FieldsMenu, self.ValuesMenu, self.LessThanMenu, ...
                self.GreaterThanMenu, self.EqualToMenu, self.NotEqualMenu];
            align(menus_list,'Left','Top');
            
            %% Create Context Menu
            col_delete = uicontextmenu('Parent', self.Window);
            uimenu(col_delete,'Label','Delete Column','Callback',...
                @(h,vars)filter_interface.delete_col(h,vars,self));
            %set(self.FieldsMenu, 'uicontextmenu', col_delete);
            
            
            %% Initialize State
            self.init_fields();
            self.update_values();
            self.init_filters_table();
            self.update_filters();
            self.setup_table(tableLayout, col_delete);
            
        end
    end
    
    %% Public Methods
    methods
        function setup_table(self, parent, context_menu)
            
            % Add jar to path if it doesn't exist
            if ~any(ismember(javaclasspath, which('TableSorter.jar')))
                javaaddpath(which('TableSorter.jar'));
            end
            
            cols = self.current_fields;
            self.table = createTable(parent.double, cols', table2cell(self.data_orig), ...
                'Buttons', false, 'UIContextMenu', context_menu);
            set(self.table, 'Editable', 0);
            %uitable('Parent', tableLayout.double, 'Data', magic(3), 'ColumnName', {'A', 'B', 'C'});
            
        end
        
        function btn_handle = create_button(self, parent, str_label)
            %CREATE_BUTTON - generates the filter buttons
            
            if strcmp(str_label, '+')
                btn_handle = uicontrol('Parent', parent, 'String', '+', ...
                    'BackgroundColor', self.buttonColor, ...
                    'Callback', @(h,vars)filter_interface.add_filter(h,vars,self));
            else
                btn_handle = uicontrol('Parent', parent, 'String', '-', ...
                    'BackgroundColor', self.buttonColor, ...
                    'Callback', @(h,vars)filter_interface.remove_filter(h,vars,self));
            end
        end
        
        function init_fields(self)
            %INIT_FIELDS - initializes fields with table columns
            
            flds = self.data.Properties.VariableNames;
            
            if iscellstr(flds)
                fm = handle(self.FieldsMenu);
                fm.String = flds;
            else
                warning('Problem with field formatting');
            end
        end
        
        function update_values(self)
            %update_values - update the fields in the menu
            
            % Get handles of menu
            vm = handle(self.ValuesMenu);         
            
            % Setup menu strings
            vm.String = self.current_values;
            
            % Enable/Disable Buttons due to data type
            self.update_button_states();
            
            % Select first position if we have values
            if ~isempty(vm.String)
                vm.Value = 1;
            end
        end
        
        function update_button_states(self)

            % See if we have numerical values in this column
            vals = str2double(self.current_values);
            
            % Get the buttons that should be modified
            h = findobj(self.btn_handle_add, 'Parent', self.NumButtonPanelLess, ...
                '-or', 'Parent', self.NumButtonPanelGreater);
            
            % Strings shown up as NaNs, so disable numerical add buttons
            if any(isnan(vals))
                set(h, 'Enable', 'off');
                set(h, 'BackgroundColor', self.buttonColor * 0.9);
            else
                set(h, 'Enable', 'on');
                set(h, 'BackgroundColor', self.buttonColor);
            end
            
        end
        
        function init_filters_table(self)
            %INIT_FILTERS_TABLE - initializes the database object to hold the
            %filter configuration
            
            self.filters = filter_database();
        end
        
        function col = get_selected_col(self)
            %GET_SELECTED_COL - returns the name of the selected column
            %from the java table object
            
            h = get(self.table);
            h2 = get(h.Table);
            
            % Get the selected Java Table column
            col = h2.SelectedColumn + 1;
            cols = cellstr(char(h.ColumnNames));
            col = cols{col};
        end
        
        function update_table(self, varargin)
            
            [rows, cols] = self.filters.apply_filters(self.data);
            
            % Filter rows if we have row filters applied
            if sum(rows) < length(self.data_orig{:, 1}) || ~isempty(varargin)
                set(self.table, 'Data', table2cell(self.data_orig(rows, :)));
            end

        end
    end
    
    %% Getters/Setters
    methods
        
        function col_name = get_current_field(self)
            %GET_CURRENT_FIELD - returns the selected field/column name
            
            fields = self.current_fields;
            fm = handle(self.FieldsMenu);
            col_name = fields{fm.Value};
        end
        
        function fields_out = get.current_fields(self)
            %GET.CURRENT_FIELDS - performs sanity checking on fieldnames
            %before storing them into current_fields
            
            fm = handle(self.FieldsMenu);
            fields_out = fm.String;
        end
        
        function values = get.current_values(self)
            %GET.CURRENT_VALUES - returns the current values for the
            %current selected field
            
            col_name = get_current_field(self);
            vals = unique(self.data{:, col_name});   % Data for column sel
            vals = utils.toString(vals);
            
            if iscellstr(vals)
                values = vals;
            else
                values = {};
                warning('Problem with values formatting');
            end
        end
        
        function sel = get_current_value(self)
            %GET_CURRENT_VALUE - returns the current selected value from
            %the values menu, and pops it from the cell array
            
            vm = handle(self.ValuesMenu);
            val_idx = vm.Value;
            
            if ~isempty(vm.String) && (sum(val_idx ~= 0) == length(val_idx))
                sel = vm.String(val_idx);
            else
                sel = [];
            end
        end
        
        function sel = get_current_filter(self, menu_handle)
            %GET_CURRENT_FILTER - returns the current selected filter from
            %the filters menu, and pops it from the cell array
            
            fm = handle(menu_handle);
            val_idx = fm.Value;
            if ~isempty(fm.String) && (sum(val_idx ~= 0) == length(val_idx))
                sel = fm.String{val_idx};
                fm.String = setdiff(fm.String, sel);
                
                if ~isempty(fm.String)
                    fm.Value = 1;
                end
            else
                sel = [];
            end
        end
        
        function set.data(self, data)
            %SET.DATA - sanitizes the data before storing it
            
            if istable(data)
                self.data_orig = data;
                % Cast what we can to categorical so numerical and string
                % data is handled in the same way
                
                data = utils.table.to_categorical(data);
            else
                warning('Only tables supported at this time');
            end
            
            self.data = data;
        end
        
        function set.filtered_data(self, data)
            %SET.FILTERED_DATA - sanitizes the data before storing it
            
            self.filtered_data = data;
        end
        
        function menu_handle = get_menu_from_button(self, btn)
            %GET_MENU_FROM_BUTTON - returns the association menu handle
            %related to the button that was pressed
            
            menu_handle = self.button_map(num2str(btn));
        end
        
        function update_filters(self)
            %UPDATE_FILTERS - update each menu based on filter database
            
            db = self.filters;
            
            han = handle(self.LessThanMenu);
            han.String = db.get_by_type('LessThan', 'filter_type', 'filter_name');
            
            han = handle(self.GreaterThanMenu);
            han.String = db.get_by_type('GreaterThan', 'filter_type', 'filter_name');
            
            han = handle(self.EqualToMenu);
            han.String = db.get_by_type('Equal', 'filter_type', 'filter_name');
            
            han = handle(self.NotEqualMenu);
            han.String = db.get_by_type('NotEqual', 'filter_type', 'filter_name');
        end
    end
    
    %% Static Methods and Callbacks
    methods (Static)
        
        function add_filter(source, ~, self)
            %ADD_FILTER - handles adding selected value/values to
            %associated filter menu
            
            menu_han = self.get_menu_from_button(source);
            col_name = self.get_current_field();
            db = self.filters;
            vals = self.get_current_value();
            
            % Numerical Menus
            if menu_han == self.LessThanMenu
                db.add_filter(vals, col_name, 'LessThan');
                
            elseif menu_han == self.GreaterThanMenu
                db.add_filter(vals, col_name, 'GreaterThan');
                
            % Item Menus
            elseif menu_han == self.EqualToMenu
                db.add_filter(vals, col_name, 'Equal');
                
            elseif menu_han == self.NotEqualMenu
                db.add_filter(vals, col_name, 'NotEqual');
                
            end
            
            self.update_filters();
            self.update_table();
        end
        
        function remove_filter(source, ~, self)
            %REMOVE_FILTER - handles removing selected value/values from
            %associated filter menu
            
            menu_han = self.get_menu_from_button(source);
            db = self.filters;
            
            % Numerical Menus
            if menu_han == self.LessThanMenu  
                names = self.get_current_filter(self.LessThanMenu);
                db.remove_filter(names, 'filter_name', 'LessThan');
                
            elseif menu_han == self.GreaterThanMenu
                names = self.get_current_filter(self.GreaterThanMenu);
                db.remove_filter(names, 'filter_name', 'GreaterThan');
                
                % Item Menus
            elseif menu_han == self.EqualToMenu
                names = self.get_current_filter(self.EqualToMenu);
                db.remove_filter(names, 'filter_name', 'Equal');
                
            elseif menu_han == self.NotEqualMenu
                names = self.get_current_filter(self.NotEqualMenu);
                db.remove_filter(names, 'filter_name', 'NotEqual');
                
            end
            
            self.update_filters();
            self.update_table('force');
        end
        
        function reset_filters(~, ~, self)
            %RESET_FILTERS - resets all filters
            
            self.filters.reset();
            self.update_values();
            self.update_filters();
            self.update_table();
        end
        
        function view_data(~, ~, self)
            %VIEW_DATA - callback handler that opens the data with the
            %configured filters applied. It saves a temporary version into
            %the workspace, then opens it in the variable viewer.
            
            % Get the filtered data
            self.update_table();
            %filt_name = strcat(self.data_name, '_temp');
            
            % Store it into workspace, and open it
            %assignin('base', filt_name, filt_data);
            %openvar(filt_name);
        end
        
        function update_values_callback(~, ~, self)
            %update_values_CALLBACK - executes the update_values method of
            %the current filter_interface object
            
            self.update_values();
        end
        
        function on_help(~, ~)
            pass;
        end
        
        function save_data(source,~,self)
            pass;
        end
        
        function delete_col(~,~,self)
            
            h = get(self.table, 'table');
            sel = h.getColumnModel.getSelectedColumns;
            %tab_cols = cellstr(char(tbl.ColumnNames));
            
            % Loop through cols to delete and remove them from the jtable
            if ~isempty(sel)
                for i = 1:length(sel)
                    %[~, loc] = ismember(del_cols{i}, tab_cols);
                    col_mod = h.getColumnModel;
                    col = col_mod.getColumn(sel);
                    h.removeColumn(col);
                end
            end
            
        end
        
        function on_exit(source,~,self)
            %ONEXIT - Clears the aware object from workspace on exit
            
            delete(self);
            delete(source);
            try
                ansVal = evalin('base', 'ans');
                if isa(ansVal, 'filter_interface')
                    evalin('base', 'clear(''ans'')');
                end
            catch
                pass;
            end
            
            
        end
    end
end
