classdef example_plugin < data_view
    %SCATTER_VIEW - One line summary of this class goes here
    %   SCATTER_VIEW has a first line of the description of myClass, but
    %   descriptions can include multiple lines of text if needed.
    %
    % SYNTAX:
    %   myObject = example_plugin( requiredProp )
    %   myObject = example_plugin( requiredProp, 'optionalInput1', 'optionalInputValue' )
    %   myObject = example_plugin( requiredInput, 'optionalInput2', 50 )
    %
    % Description:
    %   myObject = example_plugin( requiredProp ) further description about the use
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
        PLOT_TYPE = 'Example';
        REQUIRED_AES = {'x','y','size'}
    end
    
    properties
       testprop 
    end
    %% Methods
    methods
        % SCATTER_VIEW Constructor
        function self = example_plugin(id, parent, gui)            % Setup input parsing
            self@data_view(id, parent, gui);
            self.testprop = 0;
        end

        function doThat(obj)
        end
    end

    %% Static Methods
    methods (Static)
        % Methods unrelated to a single object
    end

end
