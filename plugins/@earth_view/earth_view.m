classdef earth_view < data_view
    %HISTOGRAM -a wrapper of the draw_earth plotting tool
    %
    % PROPERTIES:
    %   PLOT_TYPE - Plot type string
    %   REQUIRED_AES - The attributes of the plot that can be mapped to a
    %   column of the data structure
    %
    % METHODS:
    %   setup_plot - called once at initial plot setup
    %   update - called each time the state of the view configuration
    %   changes.
    %
    % EXAMPLES:
    %
    % SEE ALSO: data_view, data_interface, scatter_view
    %
    % Author:       nick roth
    % email:        nick.roth@nou-systems.com
    % Matlab ver.:  8.3.0.532 (R2014a)
    % Date:         13-Aug-2014
    
    %% A subclass of data_view must set these properties
    properties (Constant)
        PLOT_TYPE = 'Earth';
        REQUIRED_AES = {'values', 'groups'}
        OPTIONS = {'samebins', 'smooth', 'box', 'noerror'}
    end
    
    %% Methods
    methods
        % SCATTER_VIEW Constructor
        function self = earth_view(id, parent, gui)
            %SCATTER_VIEW - constructor for the scatter view class, which
            %is a wrapper of the scatter plotting function, written as a
            %plugin for aware.
            
            % This must be here to initialize the parent class that handles
            % most of the complexity of interacting with the gui
            self@data_view(id, parent, gui);
        end

        function setup_plot(self, varargin)
            %SETUP_PLOT - Redefines parent plotting method
            
            % This is called once at initial view creation in case some
            % setup is required
        end

        function update(self, varargin)
            %UPDATE - draws plot with current settings without overwriting
            %the axis.
            
            import components.colors.*;
            import utils.*;
            
            % Use inputParser to get the correct axis to plot to. If gui
            % passes ext_axis, then we plot to a new axis instead
            p = inputParser;
            p.FunctionName = 'data_view.update';
            p.addOptional('ext_axis', self.axis);
            p.parse(varargin{:});
            axis_handle = p.Results.ext_axis;
            
            % Gui sets the name of the data source, so here we go grab the
            % current version of it, currently unused
            data = self.gui.getDataByName(self.data_source);
            
            self.draw_earth(axis_handle);
            % Call our own axis update method
            self.update_axis();
            
        end
        
        function update_axis(self)
            %Override parent function since nhist handles most of the axis
            %labeling
            
            % Turn on 3d rotation
            rotate3d(self.axis, 'on');
            self.update_button_handler();
        end
        
    end
    
    methods (Static)
        % This sets the external function under this classes namespace, so
        % it can only be accessed with histogram.nhist
        draw_earth(ax);
    end

end
