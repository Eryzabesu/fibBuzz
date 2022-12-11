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
end

function Callback_Run(app, event)
    runFib  = event.Source == app.Button_Fibonacci || event.Source == app.Button_Combined;
    runFizz = event.Source == app.Button_FizzBuzz  || event.Source == app.Button_Combined;

    [input, sequence] = deal(app.Spinner_X.Value);

    if (runFib)
        if (ValidateInteger(app, app.Field_Y) && ValidateInteger(app, app.Field_Z))
            y = str2double(GetValue(app, app.Field_Y));
            z = str2double(GetValue(app, app.Field_Z));

            sequence     = Fibonacci(input, y, z);
            resultString = strtrim(sprintf('%d ', sequence));
        else
            return; % Invalid inputs.
        end
    end

    if (runFizz)
        if (ValidateInteger(app, app.Field_Divisor1) && ValidateInteger(app, app.Field_Divisor2))
            divisor1 = str2double(GetValue(app, app.Field_Divisor1));
            divisor2 = str2double(GetValue(app, app.Field_Divisor2));
            phrase1  = GetValue(app, app.Field_Phrase1);
            phrase2  = GetValue(app, app.Field_Phrase2);

            resultString = FizzBuzz(sequence, divisor1, divisor2, phrase1, phrase2);
        else
            return; % Invalid inputs.
        end
    end

    app.Text_Main.Value = resultString;
end

function Callback_InputValidation(app, event)
    switch (event.Source)
        case {app.Field_Divisor1, app.Field_Divisor2}
            ValidateInteger(app, event.Source);
        case app.Spinner_X
            UpdateFunctionText(app);
        case {app.Field_Y, app.Field_Z}
            if (ValidateInteger(app, event.Source))
                UpdateFunctionText(app);
            end
        otherwise
            % String inputs need not be validated.
    end
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

function success = ValidateInteger(app, Handle)
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

        uialert(app.UIFigure, sprintf('Please enter a valid integer value for the %s field.', lower(Handle.Tag)), ...
            'Invalid Input', 'icon', 'error');
    end
end

% -------------------------------------------------------------------------------------------------------------------- %