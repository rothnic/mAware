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
    
    %% Properties
    properties
        
        % data source configuration
        data_source = 'Configure Data Source'
        filters
        
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
            self.parent = p.Results.parent;
            self.gui = p.Results.gui;
            
            self.viewBox = uiextras.BoxPanel( ...
                'Parent', self.parent, ...
                'Title', self.getPanelTitle(id,'Configure Data Source'));
            self.viewBoxHandle = self.viewBox.double;
            self.axis = axes( 'Parent', self.viewBox, ...
                'ButtonDownFcn', @(h,vars)data_view.button_handler(h,vars,self));
            
            self.setup_plot()
        end
        
        function setup_plot(self)
            line('XData',[],'YData',[],'Parent',self.axis);
        end
        
        function add_axis(self, ax)
            %ADD_AXIS - appends axis to data interface object
            self.axis = ax;
        end
        
        function filters_view(self)
        end
        
        function set.data_source(self, sourceName)
            self.data_source = sourceName;
            self.boxTitle = sourceName;
            
        end
        
        function set.boxTitle(self, data_source)
            %GET.BOXTITLE - getter method for view title
            
            tempTitle = strcat('(',num2str(self.id),')-[',data_source,']');
            self.viewBox.Title = tempTitle;
        end
        
        function update_data_source(self, data_source)
            self.data_source = data_source;
            self.boxTitle = self.data_source;
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
        
    end

    %% Private Methods
    methods (Access = private)
        % Methods that should not be seen by the user

    end

end
