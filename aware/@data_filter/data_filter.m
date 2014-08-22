classdef (Abstract) data_filter < handle
    %DATA_FILTER - One line summary of this class goes here
    %   DATA_FILTER has a first line of the description of myClass, but
    %   descriptions can include multiple lines of text if needed.
    %
    % SYNTAX:
    %   myselfect = data_filter( requiredProp )
    %   myselfect = data_filter( requiredProp, 'optionalInput1', 'optionalInputValue' )
    %   myselfect = data_filter( requiredInput, 'optionalInput2', 50 )
    %
    % Description:
    %   myselfect = data_filter( requiredProp ) further description about the use
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
    properties (Abstract, Constant)
        EQUALITIES
        COMPONENTS
    end
    
    properties
        % state
        enabled
    end
    
    %% Methods
    methods (Abstract)
        validate(self, data)
        execute(self, data)
    end

    %% Getter/Setter Methods
    methods
        function set.enabled(self, state)
            %SET.ENABLED - sets our state, making sure it is logical
            
            self.enabled = logical(state);
        end
    end

    %% Private Methods
    methods
        function data = apply(self, data)
            %APPLY - applies the filter using the children methods
            
            self.validate(self, data);
            self.execute(self, data);
        end
        
        function toggle(self)
            %TOGGLE - toggles filter state
            
            self.enabled = ~self.enabled;
        end
    end

end
