NAME
====

Cro::HTTP::Session::Red - Plugin for Cro to use Red as session manager

SYNOPSIS
========

```perl6
# service.raku

use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Red;
use Routes;

red-defaults "SQLite";

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


# lib/Routes.rakumod

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
    has UInt $.uid        is referencing(*.id, :model(User));
    has User $.user       is relationship{ .uid } is rw;
}

subset LoggedInSession is sub-model of UserSession where .user.defined;

sub routes is export {
    route {
        before Cro::HTTP::Session::Red[UserSession].new: cookie-name => 'MY_SESSION_COOKIE_NAME';
        get -> LoggedInSession $session (User :$user, |) {
            content 'text/html', "<h1> Logged User: { $user.name } </h1>";
        }

        get {
            redirect '/login', :see-other;
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
                given User.^load: :$email {
                    if .?check-password: $password {
                        $session.user = $_;
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
}
```

DESCRIPTION
===========

Cro::HTTP::Session::Red is a Plugin for Cro to use Red as session manager. You can create any custom Red model to store the Cro session, but its id must be a Str and the generated session string will be used as the id.

AUTHOR
======

Fernando Correa de Oliveira <fernandocorrea@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2019 Fernando Correa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

