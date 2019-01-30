using Toybox.WatchUi;
using Toybox.ActivityRecording;
using Toybox.Attention;
using Toybox.Lang;
using Toybox.Sensor;
using Toybox.SensorHistory;
using Toybox.System;
using Toybox.Time;
using Toybox.Timer;

class CoreWorkoutView extends WatchUi.View {

	// System varibales
    hidden var backlight_timer = null;
    hidden var session = null;
    hidden var progress_indicator = null;
    hidden var progress_timer = null;
    
    // Activity variables
    hidden var timer = null;
    hidden var running = false;
    hidden var resting = false;
    hidden var exercise_count = 0;
    hidden var interval_time = 0;
    hidden var interval_duration = 50;
    hidden var rest_duration = 10;
	hidden var max_exercise_count = 13;
	hidden var activity_complete = false;

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
    	var view;
    	
    	view = View.findDrawableById("CurrentExercise");
    	drawCurrentExercise(view);
    	
    	view = View.findDrawableById("ExerciseNum");
    	drawExerciseNum(view);
    	
    	view = View.findDrawableById("Timer");
    	drawTimer(view);
    	
    	view = View.findDrawableById("NextExercise");
    	drawNextExercise(view);
    
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
    
    function loadSettings() {
    	interval_duration = Settings.getIntervalDuration();
    	rest_duration = Settings.getRestDuration();
    }
    
    // Workout Logic
    function startActivity(s) {
    	session = s;
  
    	loadSettings();
    	running = true;
    	resting = true;
    	exercise_count = 0;
    	interval_time = 0;
    	
    	Attention.playTone(Attention.TONE_START);
		Attention.vibrate([new Attention.VibeProfile(100, 1000)]);
    	
    	timer = new Timer.Timer();
    	timer.start(method(:timerAction), 1000, true);
    	
    	WatchUi.requestUpdate();
    }
    function timerAction() {
    	// Timer event to switch between active and rest
    	if (running) {
    		interval_time++;
    		if (resting) {
    			if (interval_time >= rest_duration) {
    				exercise();
    			}
    		} else {
    			if (interval_time >= interval_duration) {
    				rest();
    			}
    		}
    	}
    	WatchUi.requestUpdate();
    }
    hidden function exercise() {
    	exercise_count++;
    	interval_time = 0;
    	resting = false;
    	
    	if (session != null) {
    		if (!session.isRecording()) {
    			session.start();
    		} else {
    			session.addLap();
    		}
    	}
    	
    	turnOnBacklight();
    	notifyInterval();
    }
    hidden function rest() {
    	interval_time = 0;
    	resting = true;
    	
    	if (session != null && session.isRecording()) {
    		session.addLap();
    	}
    	
    	turnOnBacklight();
    	notifyInterval();
    	
    	if ((!running) || (exercise_count >= max_exercise_count)) {
    		session.stop();
    		timer.stop();
    		activity_complete = true;
			var workout_complete_menu_delegate = new WorkoutCompleteMenuDelegate(session, self);
			WatchUi.pushView(new Rez.Menus.WorkoutCompleteMenu(), workout_complete_menu_delegate, WatchUi.SLIDE_UP);
    	}
    }
    
    // Pause, close, save, and clearnup operations
    function pauseActivity() {
    	timer.stop();
    	Attention.playTone(Attention.TONE_STOP);
		Attention.vibrate([new Attention.VibeProfile(100, 1000)]);
    }
	function resumeActivity() {
		if (!running && (exercise_count >= max_exercise_count)) {
			
		}
		Attention.playTone(Attention.TONE_START);
		Attention.vibrate([new Attention.VibeProfile(100, 1000)]);
		session.start();
    	timer.start(method(:timerAction), 1000, true);
    }
    function isRunning() {
		return running;
	}
	function isActivityComplete() {
		return activity_complete;
	}
    function saveActivity() {
		progress_indicator = new WatchUi.ProgressBar("Saving...", null);
		WatchUi.pushView(progress_indicator, null, WatchUi.SLIDE_IMMEDIATE);
		session.save();
		progress_timer  = new Timer.Timer();
		progress_timer.start(method(:exitApp), 1000, false);
    }
    function exitApp() {
    	session = null;
    	if (progress_indicator != null) {
	    	progress_timer.stop();
	    	WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    		progress_timer = null;
    		progress_indicator = null;
    	}
    	Attention.playTone(Attention.TONE_SUCCESS);
		Attention.vibrate([new Attention.VibeProfile(100, 1000)]);
    	System.exit();
    }
    
    // Handle notification events
    hidden function notifyInterval() {
    	turnOnBacklight();
    	if (exercise_count <= max_exercise_count) {
			Attention.playTone(Attention.TONE_INTERVAL_ALERT);
			Attention.vibrate([new Attention.VibeProfile(100, 1000)]);
		} else {
			Attention.playTone(Attention.TONE_TIME_ALERT);
			Attention.vibrate([new Attention.VibeProfile(100, 2000)]);
		}
    }
    
    
    // Take care of backlight related tasks such as timeout
    hidden function backlight(on) {
    	if (Attention has :backlight) {
    		Attention.backlight(on);
		}
	}
	function onBacklightTimer() {
		backlight(false);
		backlight_timer = null;
	}
	function turnOnBacklight() {
		if (backlight_timer == null) {
			backlight(true);
			backlight_timer = new Timer.Timer();
			backlight_timer.start(method(:onBacklightTimer), 3000, false);
		}
	}
	
	
	// Draw screen elements
	hidden function drawCurrentExercise(view) {
		var text = "";
		if (running) {
			if (resting) {
				if (exercise_count < 1) {
					text = WatchUi.loadResource(Rez.Strings.get_ready);
				} else {
					text = WatchUi.loadResource(Rez.Strings.rest);
				}
			} else {
				text = exercises[(exercise_count - 1) % exercises.size()];
			}
		} else {
			text = WatchUi.loadResource(Rez.Strings.press_start);
		}
		view.setText(text);
	}
	hidden function drawExerciseNum(view) {
		if (running && exercise_count > 0) {
            view.setText(Lang.format("$1$ / $2$", [exercise_count.format("%d"), max_exercise_count.format("%d")]));
        } else {
            view.setText(WatchUi.loadResource(Rez.Strings.null_value));
        }
	}
	hidden function drawTimer(view) {
		if (running) {
			var t = resting ? (rest_duration-interval_time-1) : (interval_duration-interval_time-1);
			view.setText(t.format("%d"));
		} else {
			view.setText(WatchUi.loadResource(Rez.Strings.null_value));
		}
	}
	hidden function drawNextExercise(view) {
		var text = "";
		if (exercise_count < max_exercise_count) {
			text = exercises[exercise_count % exercises.size()];
		} else if (running && exercise_count == max_exercise_count) {
			text = "Finish";
		}
		view.setText(text);
	}
    
    // Exercises
	hidden var exercises = [
		WatchUi.loadResource(Rez.Strings.exercise_1),
		WatchUi.loadResource(Rez.Strings.exercise_2),
		WatchUi.loadResource(Rez.Strings.exercise_3),
		WatchUi.loadResource(Rez.Strings.exercise_4),
		WatchUi.loadResource(Rez.Strings.exercise_5),
		WatchUi.loadResource(Rez.Strings.exercise_6),
		WatchUi.loadResource(Rez.Strings.exercise_7),
		WatchUi.loadResource(Rez.Strings.exercise_8),
		WatchUi.loadResource(Rez.Strings.exercise_9),
		WatchUi.loadResource(Rez.Strings.exercise_10),
		WatchUi.loadResource(Rez.Strings.exercise_11),
		WatchUi.loadResource(Rez.Strings.exercise_12),
		WatchUi.loadResource(Rez.Strings.exercise_13)
	];

}
