use Red;

model User is table<account> {
    has UInt $!id       is serial;
    has Str  $.name     is column;
    has Str  $.email    is column{ :unique };
    has Str  $.password is column;
    has      @.sessions is relationship( *.uid, :model<UserSession> );

    method check-password($password) {
        $password eq $!password
    }
}

