% -------------------------------------------------------------------------------------------------------------------- %
% function MapFibBuzzCallback(varargin)
% This function maps FibBuzz.mlapp callbacks dynamically to allow for direct review.
%
% Inputs:
%     varargin - Optional inputs necessary for the specified callback.
%
% Outputs:
%     varargout - Outputs based on the provided callback.
% -------------------------------------------------------------------------------------------------------------------- %

function varargout = MapFibBuzzCallback(callbackName, varargin)
    % Convert the callback string into a handle (must be done inside this function for proper scoping).
    try
        Callback = str2func(callbackName);

        if (nargout(Callback))
            varargout = Callback(varargin{:});
        else
            Callback(varargin{:});
        end
    catch Error
        % Attempt to gracefully recover and display the error.
        if (length(varargin) >= 1 && isprop(varargin{1}, 'UIFigure'))
            warning(getReport(Error));
            uialert(varargin{1}.UIFigure, sprintf('Error encountered during callback:\n%s', getReport(Error)), ...
                'Error', 'icon', 'error');
        else
            rethrow(Error);
        end
    end
end

% -------------------------------------------------------------------------------------------------------------------- %
% Direct callback functions:

function Startup(app, varargin)
    if (~isempty(varargin))
        if (isnumeric(varargin{1}))
            app.Spinner_X.Value = varargin{1};
        else
            uialert(app.UIFigure, 'Unable to process non-numeric input parameter.', 'Warning', 'icon', 'warning');
        end
    end

    % Populate default values:
    app.Field_Divisor1.Value = GetValue(app, app.Field_Divisor1);
    app.Field_Divisor2.Value = GetValue(app, app.Field_Divisor2);
    app.Field_Y.Value        = GetValue(app, app.Field_Y);
    app.Field_Z.Value        = GetValue(app, app.Field_Z);
    app.Field_Phrase1.Value  = GetValue(app, app.Field_Phrase1);
    app.Field_Phrase2.Value  = GetValue(app, app.Field_Phrase2);

    UpdateFunctionText(app);

    % Update the HTML element:
    app.HTML.HTMLSource = 'displayData.html';
    Callback_InputValidation(app);
end

function Callback_InputValidation(app, event)
    if ((nargin > 1) && ~isempty(event))
        switch (event.Source)
            case {app.Field_Divisor1, app.Field_Divisor2}
                ValidateInteger(app, event.Source, true);
            case app.Spinner_X
                UpdateFunctionText(app);
            case {app.Field_Y, app.Field_Z}
                if (ValidateInteger(app, event.Source, true))
                    UpdateFunctionText(app);
                end
            otherwise
                % String inputs need not be validated.
        end
    end

    [input, sequence] = deal(app.Spinner_X.Value);

    [fizzResults, fibonacciResults, combinedResults] = ...
        deal('<center><error>Unable to process invalid inputs.</error></center>');
    runCombined = true;
    if (ValidateInteger(app, app.Field_Y) && ValidateInteger(app, app.Field_Z))
        y = str2double(GetValue(app, app.Field_Y));
        z = str2double(GetValue(app, app.Field_Z));

        sequence         = Fibonacci(input, y, z);
        fibonacciResults = regexprep(sprintf('%d, ', sequence), ', $', '');
    else
        % Invalid inputs.
        runCombined = false;
    end

    % The fizz-buzz algorithm uses placeholder phrases that are replaced below.
    % This helps distinguish between duplicate values when coloring.
    phrase1 = sprintf('<phrase1>%s</phrase1>', GetValue(app, app.Field_Phrase1));
    phrase2 = sprintf('<phrase2>%s</phrase2>', GetValue(app, app.Field_Phrase2));
    phrase3 = sprintf('<phrase3>%s</phrase3>', ...
        sprintf('%s%s', GetValue(app, app.Field_Phrase1), GetValue(app, app.Field_Phrase2)));

    if (ValidateInteger(app, app.Field_Divisor1) && ValidateInteger(app, app.Field_Divisor2))
        divisor1 = str2double(GetValue(app, app.Field_Divisor1));
        divisor2 = str2double(GetValue(app, app.Field_Divisor2));

        fizzResults = FizzBuzz(input, divisor1, divisor2, 'phrase1', 'phrase2');

        if (runCombined)
            combinedResults = FizzBuzz(sequence, divisor1, divisor2, 'phrase1', 'phrase2');
        end
    else
        % Invalid inputs.
    end

    % To prevent matching the combined phrase, look for instances of phrase1 or phrase2 matching the following pattern:
    % 1) Following either the beginning of the string or a space (?<= |^).
    % 2) Followed by either a comma or the end of the string (?=,|$).
    % Replace them with their respective values, and the combined phrase with the appropriate combined form.
    AddStyling = @(s) regexprep(s, ...
        {'(?<= |^)phrase1(?=,|$)', '(?<= |^)phrase2(?=,|$)', '(?<= |^)phrase1phrase2(?=,|$)'}, ...
        {phrase1, phrase2, phrase3});

    app.HTML.Data = sprintf(['<div class="label">Fizz-Buzz</div><div class="content">%s</div>', ...
        '<div class="label">Fibonacci</div><div class="content">%s</div>', ...
        '<div class="label">Combined</div><div class="content">%s</div>'], ...
        AddStyling(fizzResults), fibonacciResults, AddStyling(combinedResults));
end

% -------------------------------------------------------------------------------------------------------------------- %
% Utility functions:

function value = GetValue(app, Handle)
    % Return the current handle value if it is valid, or the default value otherwise.
    switch (Handle)
        case app.Field_Divisor1
            defaultValue = '3';
        case app.Field_Divisor2
            defaultValue = '5';
        case app.Field_Phrase1
            defaultValue = 'fizz';
        case app.Field_Phrase2
            defaultValue = 'buzz';
        case app.Field_Y
            defaultValue = '1';
        case app.Field_Z
            defaultValue = '2';
    end

    value = Handle.Value;
    if (isempty(value))
        value = defaultValue;
    end
end

function UpdateFunctionText(app)
    % The spinner element already forces numeric integer values, so determine the sign and update the Fibonacci
    % function definition appropriately.
    if (sign(app.Spinner_X.Value) >= 0)
        app.Label_Function.Text = sprintf('F(x) = F(x - %s) + F(x - %s)', ...
            GetValue(app, app.Field_Y), GetValue(app, app.Field_Z));
    else
        app.Label_Function.Text = sprintf('F(x) = F(x + %s) + F(x - %s + %s)', ...
            GetValue(app, app.Field_Z), GetValue(app, app.Field_Y), GetValue(app, app.Field_Z));
    end
end

function success = ValidateInteger(app, Handle, displayError)
    % The edit field attributes contain strings - validate that they represent integers.
    value   = fix(str2double(Handle.Value)); % Remove any decimal values.
    success = isempty(Handle.Value) || (~isnan(value) && isreal(value));
    if (success)
        Handle.FontColor       = [0, 0, 0];
        Handle.BackgroundColor = [1, 1, 1];

        if (~isempty(Handle.Value))
            Handle.Value = num2str(value); % Reassign fixed value.
        end
    else
        Handle.FontColor       = [0.35, 0, 0];
        Handle.BackgroundColor = [1, 0.68, 0.79];

        % Only display the error dialogue when the user changes this field.
        if (exist('displayError', 'var') && displayError)
            uialert(app.UIFigure, sprintf('Please enter a valid integer value for the %s field.', lower(Handle.Tag)), ...
                'Invalid Input', 'icon', 'error');
        end
    end
end

% -------------------------------------------------------------------------------------------------------------------- %