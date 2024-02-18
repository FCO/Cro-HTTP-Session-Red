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


