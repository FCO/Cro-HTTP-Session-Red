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
    my $loaded = Model.^load: $session-id;
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

Cro::HTTP::Session::Red - Plugin for Cro to use Red as session manager

=head1 SYNOPSIS

=begin code :lang<perl6>

# service.pl

use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Routes;
use Red;

$GLOBAL::RED-DB = database "SQLite", :database("{%*ENV<HOME>}/test.db");
$GLOBAL::RED-DEBUG = so %*ENV<RED_DEBUG>;

User.^create-table: :if-not-exists;
UserSession.^create-table: :if-not-exists;

try User.^create: :name<CookieMonster>, :email<cookie@monster.com>, :password("1234");

my Cro::Service $http = Cro::HTTP::Server.new(
    http => <1.1>,
    host => %*ENV<CLASSIFIED_HOST> ||
        die("Missing CLASSIFIED_HOST in environment"),
    port => %*ENV<CLASSIFIED_PORT> ||
        die("Missing CLASSIFIED_PORT in environment"),
    application => routes(),
    after => [
        Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
    ]
);
$http.start;
say "Listening at http://%*ENV<CLASSIFIED_HOST>:%*ENV<CLASSIFIED_PORT>";
react {
    whenever signal(SIGINT) {
        say "Shutting down...";
        $http.stop;
        done;
    }
}


# lib/Routes.pm6

use Cro::HTTP::Router;
use Cro::HTTP::Session::Red;
use Red;

model UserSession { ... }

model User is table<account> {
    has UInt            $!id       is serial;
    has Str             $.name     is column;
    has Str             $.email    is column{ :unique };
    has Str             $.password is column;
    has UserSession     @.sessions is relationship{ .uid }

    method check-password($password) {
        $password eq $!password
    }
}

model UserSession is table<logged_user> does Cro::HTTP::Auth {
    has Str  $.id         is id;
    has UInt $.uid        is referencing{ User.id };
    has User $.user       is relationship{ .uid } is rw;
}

sub routes() is export {
    route {
        before Cro::HTTP::Session::Red[UserSession].new: cookie-name => 'MY_SESSION_COOKIE_NAME';
        get -> UserSession $session {
            content 'text/html', "<h1> Logged User: $session.user.name() </h1>";
        }

        get -> 'login' {
            content 'text/html', q:to/HTML/;
                <form method="POST" action="/login">
                    <div>
                        Username: <input type="text" name="email" />
                    </div>
                    <div>
                        Password: <input type="password" name="password" />
                    </div>
                    <input type="submit" value="Log In" />
                </form>
            HTML
        }

        post -> UserSession $session, 'login' {
            request-body -> (Str() :$email, Str() :$password, *%) {
                my $user = User.^load: :$email;
                if $user.?check-password: $password {
                    $session.user = $user;
                    $session.^save;
                    redirect '/', :see-other;
                }
                else {
                    content 'text/html', "Bad username/password";
                }
            }
        }
    }
}

=end code

=head1 DESCRIPTION

Cro::HTTP::Session::Red is ...

=head1 AUTHOR

Fernando Correa de Oliveira <fernandocorrea@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2019 Fernando Correa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
