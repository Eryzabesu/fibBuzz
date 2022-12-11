% -------------------------------------------------------------------------------------------------------------------- %
% sequence = Fibonacci(x, y, z)
% Calculates the Fibonacci sequence for the first x values with the index offsets y and z.
% Indices that do not exist in the current sequence return 1.
%
% F(0) = 0
% F(1) = 1
% For positive x: F(x) = F(x - y) + F(x - z)
% For negative x: F(x) = F(x + z) - F(x - y + z)
%
% Inputs:
%     x - The sequence length to be generated.
%     y - Index offset applied to the first recursive function call.
%     z - Index offset applied to the second recursive function call.
%
% Outputs:
%     sequence - Array of integers for the first 0:x sequence values.
% -------------------------------------------------------------------------------------------------------------------- %

function sequence = Fibonacci(x, y, z)
    assert(nargin == nargin(@Fibonacci), 'Invalid number of inputs for %s().', mfilename());
    ValidateNumeric = @(x) assert(isnumeric(x) && rem(x, 1) == 0, 'Invalid value for "%s".', inputname(1));

    ValidateNumeric(x);
    ValidateNumeric(y);
    ValidateNumeric(z);

    stepValue = sign(x); % Allow for negative integers and step in increments of 1 or -1.

    % Initialize the array before computing any values.
    sequence    = ones(abs(x) + 1, 1);
    sequence(1) = 0; % Include the zero index.

    for i = 0:stepValue:x
        arrayIndex = abs(i) + 1;
        if (i == 0 || i == 1)
            % Base case, F(0) or F(1).
        elseif (i < 0)
            first  = GetValue(sequence, stepValue, i + z);     % F(x + z)
            second = GetValue(sequence, stepValue, i - y + z); % F(x - y + z)

            sequence(arrayIndex) = first - second;
        else
            first  = GetValue(sequence, stepValue, i - y); % F(x - y)
            second = GetValue(sequence, stepValue, i - z); % F(x - z)

            sequence(arrayIndex) = first + second;
        end
    end
end

function value = GetValue(array, expectedSign, currentIndex)
    % F(0) and F(1) represent seed values and are assigned 0 and 1, respectively.
    switch (currentIndex)
        case 0
            value = 0; % F(0) by definition.
        case 1
            value = 1; % F(1) by definition.
        otherwise
            % Values that are not yet computed or exist outside of this sequence are assigned a value of 1.
            defaultValue = 1;

            value = defaultValue;
            if (expectedSign == sign(currentIndex) && abs(currentIndex) < length(array))
                value = array(abs(currentIndex) + 1);
            end
    end
end

% -------------------------------------------------------------------------------------------------------------------- %