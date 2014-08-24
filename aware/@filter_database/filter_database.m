classdef filter_database < handle
    %FILTER_DATABASE - One line summary of this class goes here
    %   FILTER_DATABASE has a first line of the description of myClass, but
    %   descriptions can include multiple lines of text if needed.
    %
    % SYNTAX:
    %   myObject = filter_database( requiredProp )
    %   myObject = filter_database( requiredProp, 'optionalInput1', 'optionalInputValue' )
    %   myObject = filter_database( requiredInput, 'optionalInput2', 50 )
    %
    % Description:
    %   myObject = filter_database( requiredProp ) further description about the use
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
    % Date:         22-Aug-2014
    % Update:
    
    %% Properties
    properties
        db
    end
    
    properties (Access = private)
        
    end
    
    %% Methods
    methods
        % FILTER_DATABASE Constructor
        function self = filter_database()
            
            % Create layout for the database
            self.init_table();
            
        end
        
        function init_table(self)
            fields = {'value', 'column', 'filter_type', 'filter_name', 'enabled'};
            init_data = {{}, {}, {}, {}, []};
            
            % Initialize database as a Table
            header = [];
            for i = 1:length(fields)
                header.(fields{i}) = init_data{i};
            end
            self.db = struct2table(header);
        end
        
        function add_filter(self, vals, col_name, filter_type)
            %ADD_MULT_FILTERS - for each value, it adds a new row to the
            %database
            
            for i = 1:length(vals)
                row = [];
                row.value = cellstr(vals{i});
                row.column = cellstr(col_name);
                row.filter_type = cellstr(filter_type);
                row.filter_name = cellstr(filter_database.append_col_to_filter(col_name, vals{i}));
                row.enabled = 1;
                self.db = [self.db; struct2table(row)];
                self.db = unique(self.db);
            end
        end
        
        function remove_filter(self, names, col_name, filter_type)
            %REMOVE_FILTER - removes the row corresponding to a filter
            
            self.db(strcmp(self.db.(col_name), names) & ...
                strcmp(self.db.filter_type, filter_type), :) = [];
        end
        
        function filters = get_by_type(self, filter_type, type_col, cols)
            %GET_BY_TYPE - return rows and columns based on input
            
            filters = self.db{strcmp(self.db.(type_col), filter_type), cols};
        end
        
        function data = apply_filters(self, data)
            
            if ~isempty(self.db)
                % Convert what we can to numerical data
                temp = str2double(self.db.value);
                
                % Apply numerical filters
                num_idx = filter_database.filter_numeric(self.db(~isnan(temp), :), data);
                
                % Apply character filters
                char_idx = filter_database.filter_char(self.db(isnan(temp), :), data);
                
                data = logical(num_idx .* char_idx);
            else
                data = true(length(data{:, 1}), 1);
            end
            
        end
        
        function reset(self)
            %RESET - reset to original state
            
            self.db = [];
            self.init_table();
        end

    end
    
    %% Static Methods
    methods (Static)
        
        function data = filter_char(char_filters, data)
            % Loop over the unique columns that we have filters configured
            % for
            cols = unique(char_filters.column);
            filter = ones(length(data{:,1}), 1);
            for i = 1:length(cols)
                col = data.(cols{i});
                col_idx = ones(length(col), 1);
                
                % Get indexes for elements in col equal to vals
                equal_idx = ismember(char_filters.filter_type, 'Equal');
                if any(equal_idx)
                    equal_vals = char_filters{equal_idx, 'value'};
                    col_idx = col_idx .* ismember(col, cellstr(equal_vals));
                end
                
                % Get indexes for elements in col not equal to vals
                not_equal_idx = ismember(char_filters.filter_type, 'NotEqual');
                if any(not_equal_idx)
                    not_equal_vals = char_filters{not_equal_idx, 'value'};
                    col_idx = col_idx .* ~ismember(col, cellstr(not_equal_vals));
                end
                filter = filter .* col_idx;
                %data = data(logical(col_idx), :);
            end
            data = filter;
        end
        
        function data = filter_numeric(num_filters, data)
            
            % Loop over the unique columns that we have filters configured
            % for
            cols = unique(num_filters.column);
            filter = ones(length(data{:,1}), 1);
            for i = 1:length(cols)
                col = data.(cols{i});
                col_idx = ones(length(col), 1);
                
                % Get indexes for elements in col less than min of vals
                less_idx = ismember(num_filters.filter_type, 'LessThan');
                if any(less_idx)
                    less_vals = num_filters{less_idx, 'value'};
                    less_val = min(str2double(less_vals));
                    col_idx = col_idx .* (col < less_val);
                end
                
                % Get indexes for elements in col greather than max of vals
                greater_idx = ismember(num_filters.filter_type, 'GreaterThan');
                if any(greater_idx)
                    greater_vals = num_filters{greater_idx, 'value'};
                    greater_val = max(str2double(greater_vals));
                    col_idx = col_idx .* (col > greater_val);
                end
                
                % Get indexes for elements in col equal to vals
                equal_idx = ismember(num_filters.filter_type, 'Equal');
                if any(equal_idx)
                    equal_vals = num_filters{equal_idx, 'value'};
                    col_idx = col_idx .* ismember(col, str2double(equal_vals));
                end
                
                % Get indexes for elements in col not equal to vals
                not_equal_idx = ismember(num_filters.filter_type, 'NotEqual');
                if any(not_equal_idx)
                    not_equal_vals = num_filters{not_equal_idx, 'value'};
                    col_idx = col_idx .* ~ismember(col, str2double(not_equal_vals));
                end
                
                filter = filter .* col_idx;
                %data = data(logical(col_idx), :);
            end
            data = filter;
            
        end
        
        function [val, col] = parse_filter(filter, type)
            %PARSE_FILTER - takes the given filter that is shown in the
            %menu and returns retrieves the cell array from the associated
            %map. It then parses and returns the value and column name that
            %was associated with the filter name, where the filter name was
            %<value> (<column>).
            
            switch type
                case 'LessThan'
                    out = self.less_filters(filter);
                case 'GreaterThan'
                    out = self.greater_filters(filter);
                case 'Equal'
                    out = self.equal_filters(filter);
                case 'NotEqual'
                    out = self.not_equal_filters(filter);
            end
            
            val = out{1};
            col = out{1};
            
        end
        
        function filter = append_col_to_filter(col, val)
            %APPEND_COL_TO_FILTER - creates a combined string for both the
            %filtered value and the column
            
            if isnumeric(val)
                val = cellstr(num2str(val));
            end
            filter = strcat(val, ' (', col, ')');
        end
    end
    
    %% Private Methods
    methods (Access = private)
        
        
    end
    
end
