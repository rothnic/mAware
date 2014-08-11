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
        data_source
        parent
    end
    
    %% Methods
    methods
        % data_source_VIEW Constructor
        function obj = data_source_view(data_source, parent, varargin)
            % Setup input parsing
            p = inputParser;
            p.FunctionName = 'data_source_view';
            p.addRequired('data_source');
            p.parse(data_source, parent, varargin{:});
            
            % Add inputs to object properties
            obj.data_source = p.Results.data_source;
            obj.parent = p.Results.parent;
        end

        function doThis(obj)
        % doThis - Do this thing
        %   Here is some help text for the doThis method.
        %
        %   See also DOTHAT.

        end

        function doThat(obj)
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
