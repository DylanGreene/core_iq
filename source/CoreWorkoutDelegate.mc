using Toybox.WatchUi;
using Toybox.ActivityRecording;
using Toybox.Attention;

class CoreWorkoutDelegate extends WatchUi.BehaviorDelegate {

	var session = null;
	hidden var view = null;

    function initialize(v) {
        BehaviorDelegate.initialize();
        view = v;
    }

    function onMenu() {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new CoreWorkoutMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
    
    function onBack() {
    	if (view == null) {
            return false;
        } else if (view.isRunning()) {
        	if (!session.isRecording()){
        		if (!view.isActivityComplete()) {
        			view.resumeActivity();
        		} else {
        			var workout_complete_menu_delegate = new WorkoutCompleteMenuDelegate(session, view);
					WatchUi.pushView(new Rez.Menus.WorkoutCompleteMenu(), workout_complete_menu_delegate, WatchUi.SLIDE_UP);
        		}
        	}	
            return true;
        }
        return false;
    }
    
    function onSelect() {
		if (Toybox has :ActivityRecording) {
	    	if (session == null) {
				session = ActivityRecording.createSession(
	                {
	                 :name=>"Core Workout",
	                 :sport=>ActivityRecording.SPORT_GENERIC,
	                 :subSport=>ActivityRecording.SUB_SPORT_GENERIC
	                }
				);
				session.start();
				view.startActivity(session);
			} else if (session.isRecording()) {
				session.stop();
				view.pauseActivity();
				var conf_menu_delegate = new EndConfirmationMenuDelegate(session, view);
				WatchUi.pushView(new Rez.Menus.EndConfirmationMenu(), conf_menu_delegate, WatchUi.SLIDE_UP);
			} else if (session != null && !session.isRecording()) {
				if (!view.isActivityComplete()){
					view.resumeActivity();
				} else {
	       			var workout_complete_menu_delegate = new WorkoutCompleteMenuDelegate(session, view);
					WatchUi.pushView(new Rez.Menus.WorkoutCompleteMenu(), workout_complete_menu_delegate, WatchUi.SLIDE_UP);
	       		}
	       	}
		}
		return true;
	}

	function setView(v) {
		view = v;
	}

}