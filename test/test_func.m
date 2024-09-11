function out = test_func(x, y)

    if nargin < 2
        y = 0;
    end

    fprintf('input x: %d, y: %d\n', x, y);
    out = x^2;
    fprintf('Hello from test_func! The answer is %d\n', out);

end
