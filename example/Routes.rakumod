# lib/Routes.rakumod

use Cro::HTTP::Router;
use Cro::HTTP::Session::Red;
use Red;
use UserSession;
use User;

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
                given User.^find: :$email {
                    if .?check-password: $password {
                        $session.user = $_;
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
