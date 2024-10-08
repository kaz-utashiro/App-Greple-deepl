requires 'perl', 'v5.18.2';

requires 'JSON';
requires 'List::Util', '1.56';
requires 'Hash::Util';
requires 'Clipboard';
requires 'File::Share';
requires 'App::Greple', '9.15';
requires 'App::Greple::msdoc', '1.05';
requires 'App::Greple::stripe';
requires 'Getopt::EX::termcolor';
requires 'App::optex::textconv', '1.04';
requires 'App::sdif', '4.29';
requires 'Text::ANSI::Fold', '2.2104';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

on 'develop' => sub {
    recommends 'Pod::Markdown';
    recommends 'App::Greple::xp', '0.04';
    recommends 'App::Greple::subst::desumasu';
};
