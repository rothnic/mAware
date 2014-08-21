classdef histogram < data_view
    %HISTOGRAM -a wrapper of the nhist plotting function
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
        PLOT_TYPE = 'Histogram';
        REQUIRED_AES = {'values', 'groups'}
        OPTIONS = {'samebins', 'smooth', 'box', 'noerror'}
    end
    
    %% Methods
    methods
        % SCATTER_VIEW Constructor
        function self = histogram(id, parent, gui)
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
            val_col = self.aes_mapping('values');
            group_col = self.aes_mapping('groups');

            % We just call a regular plotting function at this point that
            % can take columns of data for each input
            if ~isempty(data)
                
                % Make sure this isn't categorical type data
                if ~utils.is_categorical(data{:, val_col})
                    
                    xlab = data.Properties.VariableNames{val_col};
                    if utils.is_categorical(data{:, group_col})
                        
                        % Get each unique item and group the data, then store
                        % it into a cell array
                        items = unique(data{:, group_col});
                        hist_data = repmat({}, 1, length(items));
                        for i = 1:length(items)
                            hist_data{i} = data{data{:, group_col} == items(i), val_col};
                        end
                        
                        % Convert the items to strings for plot labels
                        items = utils.toString(items);
                        
                        % Plot the data
                        self.nhist(axis_handle, hist_data, ...
                            'legend', cellstr(items), 'xlabel', cellstr(xlab));
                          
                    else
                        
                        % Use all values
                        hist_data = data{:, val_col};
                        
                        self.nhist(axis_handle, hist_data, ...
                            'xlabel', cellstr(xlab));
                    end
                end
            end
        end
        
        function update_axis()
            %Override and do nothing
        end
        
    end
    
    methods (Static)
        % This sets the external function under this classes namespace, so
        % it can only be accessed with histogram.nhist
        nhist(ax, data, varargin);
    end

end
