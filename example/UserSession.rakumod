use Red;
use Cro::HTTP::Auth;

model UserSession is table<logged_user> does Cro::HTTP::Auth {
    has Str  $.id         is id;
    has UInt $.uid        is referencing(*.id, :model<User>);
    has      $.user       is relationship( *.uid, :model<User> ) is rw;
}

subset LoggedInSession is sub-model of UserSession where .user.defined;
subset UnloggedInSession is sub-model of UserSession where !.user.defined;
