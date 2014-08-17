classdef aware < handle
    %AWARE - One line summary of this class goes here
    %   AWARE has a first line of the description of myClass, but
    %   descriptions can include multiple lines of text if needed.
    %
    % SYNTAX:
    %   myselfect = aware( requiredProp )
    %   myselfect = aware( requiredProp, 'optionalInput1', 'optionalInputValue' )
    %   myselfect = aware( requiredInput, 'optionalInput2', 50 )
    %
    % Description:
    %   myselfect = aware( requiredProp ) further description about the use
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
    properties (Access = private)
        data_if                % Required property of aware
        root_path
    end
    
    %% Methods
    methods
        % AWARE Constructor
        function self = aware(varargin)
            
            % Load native views
            self.root_path = self.get_aware_path();
            native_path = fullfile(self.root_path, 'aware', 'data_views');
            native_views = what(native_path);
            
            % Load plugin views
            plugin_path = fullfile(self.root_path, 'plugins');
            plugins = what(plugin_path);
            
            % Start data interface with views
            views = vertcat(cellstr(native_views.classes), ...
                cellstr(plugins.classes));
            self.data_if = data_interface(views);
        end
        
        function out = get_plots(self)
            out = self.data_interface.views;
        end
    end

    %% Static Methods
    methods (Static)
        % Methods unrelated to a single object
        function aware_path = get_aware_path()
             aware_path = which('aware');
            [aware_path,~,~]=fileparts(aware_path);
            [aware_path,~,~]=fileparts(aware_path);
            [aware_path,~,~]=fileparts(aware_path);
        end
    end

    %% Private Methods
    methods (Access = private)
        % Methods that should not be seen by the user
    end

end
