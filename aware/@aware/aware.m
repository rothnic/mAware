classdef aware < handle
    %AWARE - One line summary of this class goes here
    %   AWARE has a first line of the description of myClass, but
    %   descriptions can include multiple lines of text if needed.
    %
    % SYNTAX:
    %   myObject = aware( requiredProp )
    %   myObject = aware( requiredProp, 'optionalInput1', 'optionalInputValue' )
    %   myObject = aware( requiredInput, 'optionalInput2', 50 )
    %
    % Description:
    %   myObject = aware( requiredProp ) further description about the use
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
    % Date:         07-Aug-2014
    % Update:
    
    %% Properties
    properties
        data_interface                % Required property of aware
    end
    
    %% Methods
    methods
        % AWARE Constructor
        function obj = aware(varargin)
            
            obj.data_interface = data_interface();
        end
    end

    %% Static Methods
    methods (Static)
        % Methods unrelated to a single object
    end

    %% Private Methods
    methods (Access = private)
        % Methods that should not be seen by the user
    end

end
