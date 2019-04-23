use v6.d;
use Red::Model;
use Cro::HTTP::Session::Persistent;
unit role Cro::HTTP::Session::Red:ver<0.0.1>:auth<cpan:FCO>[::Model Red::Model];
also does Cro::HTTP::Session::Persistent[Model];

submethod TWEAK(|) { note "AQUI!!!" }
method load($session-id) {
    CATCH {
        default {
            .say;
            .rethrow
        }
    }
    note "load -> ", $session-id;
    my $loaded = Model.^load: $session-id;
    note "loaded: ", $loaded;
    $loaded // Model
}

method create($id) {
    Model.^new-with-id: $id
}

method save($id, Model:D $session --> Nil) {
    CATCH {
        default {
            .say;
            .rethrow
        }
    }
    note "save: ", $session;
    $session.^save if $session.^is-dirty
}

method clear(--> Nil) {
    CATCH {
        default {
            .say;
            .rethrow
        }
    }
    note "clear";
    Model.clear if Model.^can: "clear"
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
