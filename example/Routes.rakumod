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

