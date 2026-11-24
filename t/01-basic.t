use v6.d;
use Test;
use Red;
use Cro::HTTP::Auth;
use Cro::HTTP::Router;
use Cro::HTTP::Session::Red;
use Cro::HTTP::Test;

model Bla does Cro::HTTP::Auth {
    has Str $.id is id;
    has Str $.a is rw is column{ :nullable }
}

red-defaults "SQLite";
Bla.^create-table: :if-not-exists;

my Cro::HTTP::Session::Red[Bla] $session .= new: cookie-name => "bla";

throws-like { $session.load("abc") },
    Exception,
    "attempt to load non-existing session throws",
    :message(/<< ID \s abc >>/);

my $created = Bla.^create: :id<abc>;
isa-ok $created, Bla;

my $s = $session.load("abc");
isa-ok $s, Bla;
ok $s.defined;
is-deeply $s, $created;

$s = Bla.new;
isa-ok $s, Bla;
$s.a = "bla";
ok $s.^is-dirty;
$session.create: "cde";
$session.save: "cde", $s;
is $s.id, "cde", "save assigns the generated session ID";
ok not $s.^is-dirty;
is $session.load("cde").a, "bla", "saved session can be loaded again";
$session.save: "cde", $s;
ok not $s.^is-dirty;

$session.clear;

my $application = route {
    before Cro::HTTP::Session::Red[Bla].new: cookie-name => "bla";

    get -> Bla $current-session {
        my $previous-value = $current-session.a // "new";
        $current-session.a = "updated";
        content "text/plain", $previous-value;
    }
}

Bla.^create: :id<known>, :a<before>;

test-service $application, {
    test get("/"),
        status => 200,
        headers => "set-cookie" => /^ "bla=" /,
        body-text => "new";

    is Bla.^all.grep(*.a eq "updated").elems, 1,
        "middleware saves data on a newly created session";

    test get("/", headers => ["Cookie" => "bla=known"]),
        status => 200,
        body-text => "before";

    is Bla.^load("known").a, "updated", "middleware saves changes to the session";

    test get("/", headers => ["Cookie" => "bla=known"]),
        status => 200,
        body-text => "updated";
}

done-testing;
