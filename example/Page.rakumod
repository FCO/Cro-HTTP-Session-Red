use Cromponent;
use UserSession;
use User;

class Page does Cromponent {
	has User $.user;

	multi method LOAD(LoggedInSession $session) {
		$.new: :user($session.user)
	}

	multi method LOAD(UnloggedInSession $session) {
		$.new
	}

	method RENDER {
		q:c:to/END/;

		END
	}
}

sub EXPORT() { Page.^exports }
