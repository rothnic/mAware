classdef data_view < handle
    %DATA_VIEW - Is a generic container for a type of plot in aware
    %
    % SYNTAX:
    %   myObject = data_source_view( data_source )
    %
    % Description:
    %   myObject = data_source_view( data_source ) further description about the use
    %       of the function can be added here.
    %
    % PROPERTIES:
    %   data_source - the data_source object used for the data_view
    %   parent - handle for the panel the data_view is attached to
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
    % Date:         11-Aug-2014
    % Update:
    
    %% Configuration Properties
    properties (Constant = true)
        DEFAULT_TYPE = 'Default'
        DEFAULT_AES = {'x','y'}
    end
    
    properties
        
        % data source configuration
        filters
        data_source = 'Configure Data Source'
        
        % the box containing the plot
        gui
        parent
        viewBox
        viewBoxHandle
        id
        
        % the axis the data is plotted on
        axis
        title
        xLabel
        yLabel
        legend
        
        % state
        aes_mapping
        selected = false
    end
    
    properties (Dependent)
        boxTitle
    end
    
    %% Methods
    methods
        % data_source_VIEW Constructor
        function self = data_view(id, parent, gui, varargin)
            % Setup input parsing
            p = inputParser;
            p.FunctionName = 'data_view';
            p.addRequired('id');
            p.addRequired('parent');
            p.addRequired('gui');
            p.parse(id, parent, gui, varargin{:});
            
            % Add inputs to object properties
            self.id = p.Results.id;
            poss_parent = p.Results.parent;
            self.gui = p.Results.gui;
            
            % Kill the children of parent
            %self.clear_parent();
            
            % Check for the kind of container
            rowBox = intersect(gui.ViewPanels.keys, num2str(poss_parent));
            
            if ~isempty(rowBox)
                self.parent = poss_parent;
                
                % Build the view box
                self.viewBox = uiextras.BoxPanel( ...
                    'Parent', self.parent, ...
                    'Title', self.getPanelTitle(id,'Configure Data Source'));
                self.viewBoxHandle = self.viewBox.double;
            else
                self.viewBoxHandle = poss_parent;
                self.parent = get(self.viewBoxHandle, 'Parent');
            end
            % Build the axes with click button handler
            self.axis = axes( 'Parent', self.viewBoxHandle, ...
                'ButtonDownFcn', @(h,vars)data_view.button_handler(h,vars,self));
            
            % Initialize aes mapping to menu number in data interface 
            self.setup_aes_mapping();
            
            % Initialize plot
            self.setup_plot()
        end
        
        function setup_plot(self, varargin)
            p = inputParser;
            p.FunctionName = 'data_view.setup_plot';
            p.addOptional('ext_axis', self.axis);
            p.parse(varargin{:});
            axis_handle = p.Results.ext_axis;
            
            line('XData',[],'YData',[],'Parent', axis_handle);
        end
        
        function clear_parent(self)
            childs = get(self.parent, 'Children');
            
            for i = 1:length(childs)
                delete(get(self.parent, 'Children'));
            end
        end
        
        function setup_aes_mapping(self)
            %SETUP_AES_MAPPING - initializes aes mapping to initial value
            %so that we have valid mapping from the beginning
            
            self.aes_mapping = containers.Map();
            aes_vals = self.get_aes(class(self));
            for i = 1:length(aes_vals)
                self.aes_mapping(aes_vals{i}) = 1;
            end
        end
        
        
        function update(self, varargin)
            %UPDATE - draws plot with current settings without overwriting
            %the axis.
            
            p = inputParser;
            p.FunctionName = 'data_view.update';
            p.addOptional('ext_axis', self.axis);
            p.parse(varargin{:});
            temp_axis = p.Results.ext_axis;
            
            data = self.gui.getDataByName(self.data_source);
            self.boxTitle = self.data_source;
            
            the_line = get(temp_axis, 'Children');
            x_col = self.aes_mapping('x');
            y_col = self.aes_mapping('y');
            
            if ~isempty(data)
                if (isnumeric(data{:,x_col}) && isnumeric(data{:,y_col}))
                    set(the_line, 'XData', data{:, x_col}, ...
                        'YData', data{:, y_col}, ...
                        'LineStyle', 'none', 'Marker', '.');
                else
                    warndlg('Only numeric values at this time')
                end
                
                update_axis(self, data, 'x');
                update_axis(self, data, 'y');
            end
        end
        
        function setup_external(self, fig, axis)
            
        end
        
        function update_axis(self, data, axis_name, varargin)
            %UPDATE_AXIS - sets up the ticks, labels, and button handler on
            %each update of the view. This method uses some helper
            %functions that could be reused if you must redefine this
            %method for some reason.
            %
            % PARAMETERS
            %   data - the matlab table data structure
            %   axis_name - the string
            %   axis_handle (Optional) - other axis
            
            p = inputParser();
            p.FunctionName = 'data_view.update';
            p.addRequired('data');
            p.addRequired('axis_name');
            p.addOptional('axis_handle', self.axis);
            p.parse(data, axis_name, varargin{:});
            axis_handle = p.Results.axis_handle;
            
            col_num = self.aes_mapping(axis_name);
            col_name = self.gui.listValues{col_num};
            col_data = data{:, col_num};
            lim_str = strcat(upper(axis_name), 'Lim');
            
            % check for categorical data
            if utils.is_categorical(data{:, col_num})
                
                % get axis info based on categorical data
                [ limits, ticks, labels ] = scales.utils.cats_to_axis(col_data);
                
                % generate property strings for x,y,z
                tick_str = strcat(upper(axis_name), 'Tick');
                lab_str = strcat(upper(axis_name), 'TickLabel');
                
                % set axis values
                set(axis_handle, tick_str, ticks);
                set(axis_handle, lab_str, labels);
                
            else % we have numerical data
                [ ~, limits ] = scales.utils.calc_axis_breaks_and_limits(...
                    min(col_data), max(col_data), 'nlabs', length(col_data)); 
            end
            
            set(axis_handle, lim_str, limits);
            
            % all column types should set labels
            label_fun = str2func(strcat(lower(axis_name), 'label'));
            label_fun(axis_handle, col_name);
            
            % Update click handler
            self.update_button_handler();
        end
        
        function update_button_handler(self)
            %UPDATE_BUTTON_HANDLER - required to reset this each time the
            %axis is updated
            
            % don't set button handler on external axis, always use
            % self.axis
            set(self.axis, 'ButtonDownFcn', ...
                @(h,vars)data_view.button_handler(h,vars,self));
        end
        
        function add_axis(self, ax)
            %ADD_AXIS - appends axis to data interface object
            self.axis = ax;
        end
        
        function filters_view(self)
        end
        
        function set.data_source(self, sourceName)
            %SET.DATA_SOURCE - setter for data source to update box title
            %as well
            
            self.data_source = sourceName;
            self.boxTitle = sourceName;
        end
        
        function set.boxTitle(self, data_source)
            %GET.BOXTITLE - getter method for view title
            
            tempTitle = strcat('ID:',num2str(self.id),'-Data:',data_source,'-Axis:', num2str(self.axis));
            self.viewBox.Title = tempTitle;
        end
        
    end

    %% Static Methods
    methods (Static)
        % Methods unrelated to a single object
        function out = getPanelTitle(id, titleStr)
            out = strcat('(',num2str(id),')-[',titleStr,']');
        end
        
        function button_handler(source,vars,self)
            data_interface.button_handler(source,vars,self.gui);
        end
        
        function aes_out = get_aes(classString)
            %GET_AES - return aes based on class
            
            if strcmp(classString, 'data_view')
                aes_out = data_view.DEFAULT_AES;
            else
                req_cmd = strcat(classString, '.REQUIRED_AES');
                aes_out = eval(req_cmd);
            end
        end
        
        function type_out = get_plot_type(classString)
            %GET_AES - return type constant based on class
            
            if strcmp(classString, 'data_view')
                type_out = data_view.DEFAULT_TYPE;
            else
                req_cmd = strcat(classString, '.PLOT_TYPE');
                type_out = eval(req_cmd);
            end
        end
        
    end

    %% Private Methods
    methods (Access = private)
        % Methods that should not be seen by the user

    end

end
