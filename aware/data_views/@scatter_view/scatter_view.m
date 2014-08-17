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
            the_line = get(self.axis, 'Children');
            x_col = self.aes_mapping('x');
            y_col = self.aes_mapping('y');
            size_col = self.aes_mapping('size');
            
            if ~isempty(data)
                if (isnumeric(data{:,x_col}) && isnumeric(data{:,y_col}))
                    scatter(self.axis, data{:, x_col}, data{:, y_col}, ...
                        data{:, size_col});
                    set(self.axis, 'ButtonDownFcn', ...
                        @(h,vars)data_view.button_handler(h,vars,self));
                else
                    warndlg('Only numeric values at this time')
                end
            end
        end
    end

    %% Static Methods
    methods (Static)
        % Methods unrelated to a single object
    end

    %% Private Methods
    methods (Access = private)
        % Methods that should not be seen by the user

        % Functions stored in a separate 'm' file listed out
        separateMfileFunction(input1, input2)
        % Now can be used with scatter_view.separateMfileFunction(input1, input2)
    end

end
