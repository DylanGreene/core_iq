using Toybox.WatchUi;

class EndConfirmationMenuDelegate extends WatchUi.MenuInputDelegate {

	hidden var session = null;
	hidden var view = null;
	
	function initialize(s, v) {
		MenuInputDelegate.initialize();
		session = s;
		view = v;
	}
	
	function onMenuItem(item) {
        if (item == :resume) {
            view.resumeActivity();
        } else if (item == :save) {
            view.saveActivity();
        } else if (item == :discard) {
        	session.discard();
        	view.exitApp();
        }
    }
	
}

class WorkoutCompleteMenuDelegate extends WatchUi.MenuInputDelegate {

	hidden var session = null;
	hidden var view = null;
	
	function initialize(s, v) {
		MenuInputDelegate.initialize();
		session = s;
		view = v;
	}
	
	function onMenuItem(item) {
        if (item == :save) {
            view.saveActivity();
        } else if (item == :discard) {
        	session.discard();
        	view.exitApp();
        }
    }
	
}