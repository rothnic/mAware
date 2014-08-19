classdef scatter_view < data_view
    %SCATTER_VIEW -a wrapper of the scatter plotting function
    %   SCATTER_VIEW a wrapper of the scatter plotting function, written as a
    %   plugin for aware. This serves as an example for how to write a
    %   compatible plotting plugin for aware. A plugin view must be a
    %   subclass of data_view.
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
    % SEE ALSO: data_view, data_interface
    %
    % Author:       nick roth
    % email:        nick.roth@nou-systems.com
    % Matlab ver.:  8.3.0.532 (R2014a)
    % Date:         13-Aug-2014
    
    %% A subclass of data_view must set these properties
    properties (Constant)
        PLOT_TYPE = 'Scatter';
        REQUIRED_AES = {'x', 'y', 'color', 'size'}
    end
    
    %% Methods
    methods
        % SCATTER_VIEW Constructor
        function self = scatter_view(id, parent, gui)
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
            % current version of it
            data = self.gui.getDataByName(self.data_source);

            % The gui sets into our AES Map the index of each column in the
            % current data source that map to the current aesthetic
            cols.x_col = self.aes_mapping('x');
            cols.y_col = self.aes_mapping('y');
            cols.color_col = self.aes_mapping('color');
            cols.size_col = self.aes_mapping('size');

            % We just call a regular plotting function at this point that
            % can take columns of data for each input
            if ~isempty(data)
                
                % Helper function to assign colors based on unique values
                % within the column associated with color
                [colors_index, the_colors, ~] = assign_colors(data,...
                    cols.color_col);
                colormap(axis_handle, the_colors);
                
                % Helper function to scale size based on values
                size_data = scale_data(data{:, cols.size_col}, 20, 50);
                
                % The actual plotting function
                scatter(axis_handle, data{:, cols.x_col}, data{:, cols.y_col}, ...
                    size_data, colors_index, 'fill');
                
                % These calls update the x and y axis labels/ticks on each
                % update, while ensuring the callbacks aren't overwritten
                self.update_axis(data, 'x', axis_handle);
                self.update_axis(data, 'y', axis_handle);
            end
        end
        
    end

end
