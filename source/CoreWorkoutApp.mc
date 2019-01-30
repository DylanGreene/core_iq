using Toybox.Application;
using Toybox.WatchUi;

class CoreWorkoutApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
    	view = new CoreWorkoutView();
    	delegate = new CoreWorkoutDelegate(view);
    	
    	view.loadSettings();
    
        return [ view, delegate ];
    }
    
    function onSettingsChanged() {
    	view.loadSettings();
    	WatchUi.requestUpdate();
    }
    
    hidden var view;
    hidden var delegate;

}
