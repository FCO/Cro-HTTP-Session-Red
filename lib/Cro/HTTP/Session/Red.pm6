use v6.d;
use Red::Model;
use Cro::HTTP::Session::Persistent;
unit role Cro::HTTP::Session::Red:ver<0.0.1>:auth<cpan:FCO>[::Model Red::Model];
also does Cro::HTTP::Session::Persistent[Model];

method load($session-id --> Model) {
    Model.^load: $session-id
}

method save($, Model $session --> Nil) is rw {
    $session.^save
}

method clear(--> Nil) {
    Model.?clear
}

=begin pod

=head1 NAME

Cro::HTTP::Session::Red - blah blah blah

=head1 SYNOPSIS

=begin code :lang<perl6>

use Cro::HTTP::Session::Red;

=end code

=head1 DESCRIPTION

Cro::HTTP::Session::Red is ...

=head1 AUTHOR

Fernando Correa de Oliveira <fernandocorrea@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2019 Fernando Correa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
