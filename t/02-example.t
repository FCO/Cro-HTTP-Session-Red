use v6.d;
use Test;
use lib 'example';
use Red;
use Cro::HTTP::Test;
use User;
use UserSession;
use Routes;

red-defaults "SQLite";
User.^create-table: :if-not-exists;
UserSession.^create-table: :if-not-exists;
User.^create: :name<CookieMonster>, :email<cookie@monster.com>, :password("1234");

test-service routes(), {
    test get("/", follow => False),
        status => 303,
        headers => "location" => "/login";

    test get("/login"),
        status => 200,
        body-text => /"Log In"/;

    test post(
        "/login",
        content-type => "application/x-www-form-urlencoded",
        body => { email => "cookie@monster.com", password => "wrong" }
    ),
        status => 200,
        body-text => /"Bad username\/password"/;

    test post(
        "/login",
        content-type => "application/x-www-form-urlencoded",
        body => { email => "cookie@monster.com", password => "1234" },
        follow => False
    ),
        status => 303,
        headers => [
            "location" => "/",
            "set-cookie" => /^"MY_SESSION_COOKIE_NAME="/
        ];

    is UserSession.^all.grep(*.uid.defined).head.user.email, "cookie@monster.com",
        "login persists the user in a newly created session";
}

done-testing;
