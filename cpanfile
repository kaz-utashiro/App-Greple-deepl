requires 'perl', '5.014';

requires 'App::Greple', '9.01';
requires 'JSON';
requires 'App::sdif', '4.24.0';
requires 'Text::ANSI::Fold', '2.19';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
