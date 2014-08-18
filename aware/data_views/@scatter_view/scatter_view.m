classdef scatter_view < data_view
    %SCATTER_VIEW - One line summary of this class goes here
    %   SCATTER_VIEW has a first line of the description of myClass, but
    %   descriptions can include multiple lines of text if needed.
    %
    % SYNTAX:
    %   myObject = scatter_view( requiredProp )
    %   myObject = scatter_view( requiredProp, 'optionalInput1', 'optionalInputValue' )
    %   myObject = scatter_view( requiredInput, 'optionalInput2', 50 )
    %
    % Description:
    %   myObject = scatter_view( requiredProp ) further description about the use
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
    % Date:         13-Aug-2014
    % Update:
    
    %% Properties
    properties (Constant)
        PLOT_TYPE = 'Scatter';
        REQUIRED_AES = {'x','y','size'}
    end
    
    %% Methods
    methods
        % SCATTER_VIEW Constructor
        function self = scatter_view(id, parent, gui)
            self@data_view(id, parent, gui);
        end

        function setup_plot(self)
            %SETUP_PLOT - Redefines parent plotting method
            
            line('XData',[],'YData',[],'Parent',self.axis);
        end

        function update(self)
            %UPDATE - draws plot with current settings without overwriting
            %the axis.
            data = self.gui.getDataByName(self.data_source);

            cols.x_col = self.aes_mapping('x');
            cols.y_col = self.aes_mapping('y');
            cols.size_col = self.aes_mapping('size');
            col_fields = fieldnames(cols);
            if ~isempty(data)
                %utils.table.separate_items(data, {}
                
                scatter(self.axis, data{:, cols.x_col}, data{:, cols.y_col}, ...
                    data{:, cols.size_col});
                self.update_axis(data, 'x');
                self.update_axis(data, 'y');
                
                set(self.axis, 'ButtonDownFcn', ...
                    @(h,vars)data_view.button_handler(h,vars,self));
                
            end
        end
        
    end

end
