classdef filter_interface < handle
    %FILTER_INTERFACE - One line summary of this class goes here
    %   FILTER_INTERFACE has a first line of the description of myClass, but
    %   descriptions can include multiple lines of text if needed.
    %
    % SYNTAX:
    %   myObject = filter_interface( requiredProp )
    %   myObject = filter_interface( requiredProp, 'optionalInput1', 'optionalInputValue' )
    %   myObject = filter_interface( requiredInput, 'optionalInput2', 50 )
    %
    % Description:
    %   myObject = filter_interface( requiredProp ) further description about the use
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
    % email:        nick.roth@nou-systems.com
    % Matlab ver.:  8.3.0.532 (R2014a)
    % Date:         21-Aug-2014
    % Update:
    
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
        
        % Filters
        less_filters
        greater_filters
        equal_filters
        not_equal_filters
        
        % State
        current_fields = {}
        
        % Data
        data
        filtered_data
    end
    
    properties (Dependent)
        current_values = {}
    end
    
    %% Properties
    properties (Access = private)
        backgroundColor
        headerColor
        buttonColor
        buttonTextColor
    end
    
    %% Methods
    methods
        % FILTER_INTERFACE Constructor
        function self = filter_interface(data, varargin)
            import tools.*
            
            self.data = data;
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
                'CloseRequestFcn', @(h,args)filter_interface.on_exit(h,args,self) );
            
            self.backgroundColor = rgbd(252, 252, 252);
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
            mainLayout = uiextras.HBoxFlex( 'Parent', self.Window, 'Spacing', 3 );
            
            %% Create the main panels
            % Fields Panel
            self.FieldsPanel = uiextras.BoxPanel( ...
                'Parent', mainLayout, ...
                'Title', 'Fields' );
            
            % Values Panel
            self.ValuesPanel = uiextras.BoxPanel( ...
                'Parent', mainLayout, ...
                'Title', 'Values' );
            
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
                'String', {}, 'BackgroundColor', self.buttonColor, ...
                'Callback', @(h,vars)filter_interface.update_fields_callback(h,vars,self));
            
            %% Add the contents to the Values Panel
            
            self.ValuesMenu = uicontrol('Style', 'listbox',...
                'Parent', self.ValuesPanel, ...
                'String', {}, 'BackgroundColor', self.buttonColor, ...
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
            NumButtonPanel = uiextras.VBox( 'Parent', self.LessThanPanel );
            
            % Add to Less Than Button
            btn_handle_add = self.create_button(NumButtonPanel, '+');
            btn_handle_remove = self.create_button(NumButtonPanel, '-');
            
            % Less Than Menu
            self.LessThanMenu = uicontrol('Style', 'listbox',...
                'Parent', self.LessThanPanel, ...
                'String', {''}, 'BackgroundColor', self.buttonColor, ...
                'Min',1,'Max',200);
            
            % Create map between buttons and menu
            self.button_map(num2str(btn_handle_add)) = self.LessThanMenu;
            self.button_map(num2str(btn_handle_remove)) = self.LessThanMenu;
            
            % Add Greater Than Panel
            self.GreaterThanPanel = uiextras.HBoxFlex( 'Parent', NumPanel_Greater );
            
            % Add Button Container
            NumButtonPanel2 = uiextras.VBox( 'Parent', self.GreaterThanPanel );
            
            % Add to Greater Than Button
            btn_handle_add = self.create_button(NumButtonPanel2, '+');
            btn_handle_remove = self.create_button(NumButtonPanel2, '-');
            
            % Greater Than Menu
            self.GreaterThanMenu = uicontrol('Style', 'listbox',...
                'Parent', self.GreaterThanPanel, ...
                'String', {''}, 'BackgroundColor', self.buttonColor, ...
                'Min',1,'Max',200);
            
            % Create map between buttons and menu
            self.button_map(num2str(btn_handle_add)) = self.GreaterThanMenu;
            self.button_map(num2str(btn_handle_remove)) = self.GreaterThanMenu;
            
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
            btn_handle_add = self.create_button(ItemsButtonPanel, '+');
            btn_handle_remove = self.create_button(ItemsButtonPanel, '-');
            
            % Add Equal Menu
            self.EqualToMenu = uicontrol('Style', 'listbox',...
                'Parent', self.EqualToPanel, ...
                'String', {''}, 'BackgroundColor', self.buttonColor, ...
                'Min',1,'Max',200);
            
            % Create map between buttons and menu
            self.button_map(num2str(btn_handle_add)) = self.EqualToMenu;
            self.button_map(num2str(btn_handle_remove)) = self.EqualToMenu;
            
            % Add Not Equal Panel
            self.NotEqualPanel = uiextras.HBoxFlex( 'Parent', ItemsPanel_NotEqual );
            
            % Add Button Container
            ItemsButtonPanel2 = uiextras.VBox( 'Parent', self.NotEqualPanel );
            
            % Add to Not Equal Button
            btn_handle_add = self.create_button(ItemsButtonPanel2, '+');
            btn_handle_remove = self.create_button(ItemsButtonPanel2, '-');
            
            % Greater Than Menu
            self.NotEqualMenu = uicontrol('Style', 'listbox',...
                'Parent', self.NotEqualPanel, ...
                'String', {''}, 'BackgroundColor', self.buttonColor, ...
                'Min',1,'Max',200);
            
            % Create map between buttons and menu
            self.button_map(num2str(btn_handle_add)) = self.NotEqualMenu;
            self.button_map(num2str(btn_handle_remove)) = self.NotEqualMenu;
            
            set( self.EqualToPanel, 'Sizes', [15 -1] );
            set( self.NotEqualPanel, 'Sizes', [15 -1] );
            
            %% Add the Options to the Options Panel
            
            
            %% Initialize State
            self.update_fields();
            
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
        
        function update_fields(self)
            %UPDATE_FIELDS - update the fields in the menu
            
            fm = handle(self.FieldsMenu);
            vm = handle(self.ValuesMenu);
            
            fm.String = self.current_fields;
            filt_vals = self.get_all_filter_values();
            vm.String = self.current_values;
            if ~isempty(vm.String)
                vm.Value = 1;
            end
            
        end
        
        function lf = get_all_filter_values(self)
            
            lf = self.less_filters.values;
            gf = self.greater_filters.values;
            ef = self.equal_filters.values;
            nef = self.not_equal_filters.values;
            
        end
        
        function apply_filters(self)
            
            self.apply_num_filters();
            self.apply_item_filters();
        end
        
        function apply_num_filters(self)
            
            self.less_filters
            self.greater_filters
            
        end
        
        function apply_item_filters(self)
            
            self.equal_filters
            self.not_equal_filters
        end
    end
    
    % Getters/Setters
    methods
        
        function col_name = get_current_field(self)
            %GET_CURRENT_FIELD - returns the selected field/column name
            
            fields = self.current_fields;
            fm = handle(self.FieldsMenu);
            col_name = fields{fm.Value};
            
        end
        
        function fields_out = get.current_fields(self)
            %SET.CURRENT_FIELDS - performs sanity checking on fieldnames
            %before storing them into current_fields
            
            flds = self.data.Properties.VariableNames;
            
            if iscellstr(flds)
                fields_out = flds;
            else
                fields_out = {'Error'};
                warning('Problem with field formatting');
            end
        end
        
        function values = get.current_values(self)
            %SET.CURRENT_FIELDS - performs sanity checking on values
            %before storing them into current_values
            
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
                vm.String = setdiff(vm.String, sel);
                
                % Set selection to the nearest value, so it doesn't look
                % strange that we have a bunch of stuff still highlighted
                vm.Value = self.get_valid_selection(val_idx);
            else
                sel = [];
            end
        end
        
        function sel = get_current_filter(self, menu_handle)
            %GET_CURRENT_FILTER - returns the current selected value from
            %the values menu, and pops it from the cell array
            
            fm = handle(menu_handle);
            val_idx = fm.Value;
            if ~isempty(fm.String) && (sum(val_idx ~= 0) == length(val_idx))
                sel = fm.String{val_idx};
                fm.String = setdiff(fm.String, sel);
                
                fm.Value = self.get_valid_selection(val_idx);
            else
                sel = [];
            end
        end
        
        function set.data(self, data)
            %SET.DATA - sanitizes the data before storing it
            
            if istable(data)
                
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
    end
    
    
    methods (Static)
        
        function add_filter(source, ~, self)
            %ADD_FILTER - handles adding selected value/values to
            %associated filter menu
            
            menu_han = self.get_menu_from_button(source);
            col_name = self.get_current_field();
            
            % Numerical Menus
            if menu_han == self.LessThanMenu
                val = self.get_current_value();
                for i = 1:length(val)     
                    filter_data = {val{i}, col_name};
                    filter_name = self.append_col_to_filter(col_name, val{i});
                    self.less_filters(filter_name) = filter_data;
                end
                han = handle(self.LessThanMenu);
                han.String = self.less_filters.keys;
                
            elseif menu_han == self.GreaterThanMenu
                val = self.get_current_value();
                for i = 1:length(val)     
                    filter_data = {val{i}, col_name};
                    filter_name = self.append_col_to_filter(col_name, val{i});
                    self.greater_filters(filter_name) = filter_data;
                end
                han = handle(self.GreaterThanMenu);
                han.String = self.greater_filters.keys;
                
                % Item Menus
            elseif menu_han == self.EqualToMenu
                val = self.get_current_value();
                for i = 1:length(val)     
                    filter_data = {val{i}, col_name};
                    filter_name = self.append_col_to_filter(col_name, val{i});
                    self.equal_filters(filter_name) = filter_data;
                end
                han = handle(self.EqualToMenu);
                han.String = self.equal_filters.keys;
                
            elseif menu_han == self.NotEqualMenu
                val = self.get_current_value();
                for i = 1:length(val)     
                    filter_data = {val{i}, col_name};
                    filter_name = self.append_col_to_filter(col_name, val{i});
                    self.not_equal_filters(filter_name) = filter_data;
                end
                han = handle(self.NotEqualMenu);
                han.String = self.not_equal_filters.keys;
                
            end
        end
        
        function filter = append_col_to_filter(col, val)
            %APPEND_COL_TO_FILTER - creates a combined string for both the
            %filtered value and the column
            
            if isnumeric(val)
                val = cellstr(num2str(val));
            end
            filter = strcat(val, ' (', col, ')');
        end
        
        function [val, col] = parse_filter(filter, type)
            %PARSE_FILTER - takes the given filter that is shown in the
            %menu and returns retrieves the cell array from the associated
            %map. It then parses and returns the value and column name that
            %was associated with the filter name, where the filter name was
            %<value> (<column>).
            
            switch type
                case 'LessThan'
                    out = self.less_filters(filter);
                case 'GreaterThan'
                    out = self.greater_filters(filter);
                case 'Equal'
                    out = self.equal_filters(filter);
                case 'NotEqual'
                    out = self.not_equal_filters(filter);
            end
            
            val = out{1};
            col = out{1};
            
        end
        
        function remove_filter(source, ~, self)
            %REMOVE_FILTER - handles removing selected value/values from
            %associated filter menu           
            
            menu_han = self.get_menu_from_button(source);
            
            % Numerical Menus
            if menu_han == self.LessThanMenu
                
                out = self.get_current_filter(self.LessThanMenu);
                self.less_filters.remove(out);
                
            elseif menu_han == self.GreaterThanMenu
                
                out = self.get_current_filter(self.GreaterThanMenu);
                self.greater_filters.remove(out);
                
            % Item Menus
            elseif menu_han == self.EqualToMenu
                
                out = self.get_current_filter(self.EqualToMenu);
                self.equal_filters.remove(out);
                
            elseif menu_han == self.NotEqualMenu
                
                out = self.get_current_filter(self.NotEqualMenu);
                self.not_equal_filters.remove(out);
                
            end
        end
        
        function sel = get_valid_selection(init_sel)
            %GET_VALID_SELECTION - returns the correct value to select
            %after a filtering operation based on the current selection or
            %selections
            
            if min(init_sel) > 1
                sel = min(init_sel) - 1;
            else 
                sel = 1;
            end
            
        end
        
        function update_fields_callback(~, ~, self)
            self.update_fields();
        end
        
        function on_help(~, ~)
            pass;
        end
        
        function save_data(source,~,self)
            pass;
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
