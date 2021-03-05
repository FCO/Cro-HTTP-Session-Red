use v6.c;
use Test;
use Red;
use Cro::HTTP::Session::Red;

plan 10;

model Bla { has Str $.id is id; has Str $.a is rw is column{ :nullable } }

my $*RED-DB = database "SQLite";
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

$s = $session.create: "cde";
isa-ok $s, Bla;
is $s.id, "cde";

$s.a = "bla";
ok $s.^is-dirty;
$session.save: "fgh", $s;
ok not $s.^is-dirty;
$session.save: "fgh", $s;
ok not $s.^is-dirty;

$session.clear;

done-testing;
