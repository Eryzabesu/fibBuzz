% -------------------------------------------------------------------------------------------------------------------- %
% resultString = FizzBuzz(input, divisor1, divisor2, phrase1, phrase2)
% Constructs a string based on the input value or sequence where entries that are divisible by divisor1 print phrase1,
% entries divisible by divisor2 print phrase2, and values divisible by both print phrase1 + phrase2.
% Entries that are not divisible by either value print their value.
%
% Inputs:
%     input    - A single value or sequence of values to process.
%                    If a single value is provided, this functions steps from 0 to input.
%                    If a sequence is provided, this function processes the sequence directly.
%     divisor1 - Integer value for the first divisor - maps to phrase1.
%     divisor2 - Integer value for the first divisor - maps to phrase2.
%     phrase1  - String printed for values divisible by divisor1.
%     phrase2  - String printed for values divisible by divisor2.
%
% Outputs:
%     resultString - The resulting sequence with divisible entries replaced by provided phrases.
% -------------------------------------------------------------------------------------------------------------------- %

function resultString = FizzBuzz(input, divisor1, divisor2, phrase1, phrase2)
    assert(nargin == nargin(@FizzBuzz), 'Invalid number of inputs for %s().', mfilename());
    ValidateNumeric = @(x) assert(isnumeric(x), 'Invalid value for "%s".', inputname(1));
    ValidatePhrase  = @(x) assert(isstring(x) || ischar(x), 'Invalid value for "%s".', inputname(1));

    ValidateNumeric(input);
    ValidateNumeric(divisor1);
    ValidateNumeric(divisor2);
    ValidatePhrase(phrase1);
    ValidatePhrase(phrase2);

    sequence = input;
    if (length(sequence) == 1 && sequence ~= 0)
        stepValue = sign(input); % Allow for negative integers and step in increments of 1 or -1.
        sequence  = 0:stepValue:input;
    end

    processedValues = cell(length(sequence), 1);
    combinedPhrase  = sprintf('%s%s', phrase1, phrase2);
    combinedDivisor = divisor1 * divisor2;

    for i = 1:length(sequence)
        sequenceIndex = sequence(i);

        % MATLAB switch statements have no fallthrough, and so must be listed in order.
        switch (0)
            case sequenceIndex
                % Do not consider 0 to be divisible.
                processedValues{i} = '0';
            case mod(sequenceIndex, combinedDivisor)
                processedValues{i} = combinedPhrase;
            case mod(sequenceIndex, divisor1)
                processedValues{i} = phrase1;
            case mod(sequenceIndex, divisor2)
                processedValues{i} = phrase2;
            otherwise
                % No valid divisors, print the number directly.
                processedValues{i} = num2str(sequenceIndex);
        end
    end

    resultString = strjoin(processedValues, ', ');
end

% -------------------------------------------------------------------------------------------------------------------- %