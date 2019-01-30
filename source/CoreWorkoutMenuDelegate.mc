using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;
using Toybox.Application;

class CoreWorkoutMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :interval_time) {
        	WatchUi.pushView(
        		new SingleNumberPicker(Rez.Strings.menu_interval_time_prompt, Settings.getIntervalDuration(), 5, 90),
                new IntervalDurationPickerDelegate(), WatchUi.SLIDE_RIGHT
            );
        } else if (item == :rest_time) {
        	WatchUi.pushView(
        		new SingleNumberPicker(Rez.Strings.menu_rest_time_prompt, Settings.getRestDuration(), 5, 90),
                new RestDurationPickerDelegate(), WatchUi.SLIDE_RIGHT
            );
        }
    }

}

module Settings {

	function setIntervalDuration(d) {
		Application.getApp().setProperty("interval_time", d);
	}
	function getIntervalDuration() {
		return getNumber("interval_time", 60, 5, 90);
	}
	function setRestDuration(d) {
		Application.getApp().setProperty("rest_time", d);
	}
	function getRestDuration() {
		return getNumber("rest_time", 10, 5, 90);
	}
	
	function getNumber(name, default_val, min, max) {
		var num = default_val;
        var app = Application.getApp();
        if (app != null) {
            num = app.getProperty(name);
            if (num != null) {
                if (num instanceof Toybox.Lang.String) {
                    try {
                        num = num.toNumber();
                    } catch(ex) {
                        num = null;
                    }
                }
            }
        }

        if (num == null || num < min || num > max) {
            num = default_val;
            app.setProperty(name, num);
        }
        return num;
    }
}

class NumberFactory extends WatchUi.PickerFactory {

    hidden var mStart;
    hidden var mStop;
    hidden var mIncrement;
    hidden var mFormatString;
    hidden var mFont;

    function getIndex(value) {
        var index = (value / mIncrement) - mStart;
        return index;
    }

    function initialize(start, stop, increment, options) {
        PickerFactory.initialize();

        mStart = start;
        mStop = stop;
        mIncrement = increment;

        if(options != null) {
            mFormatString = options.get(:format);
            mFont = options.get(:font);
        }

        if(mFont == null) {
            mFont = Graphics.FONT_NUMBER_HOT;
        }

        if(mFormatString == null) {
            mFormatString = "%d";
        }
    }

    function getDrawable(index, selected) {
        return new WatchUi.Text( { :text=>getValue(index).format(mFormatString), :color=>Graphics.COLOR_WHITE, :font=> mFont, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER } );
    }

    function getValue(index) {
        return mStart + (index * mIncrement);
    }

    function getSize() {
        return ( mStop - mStart ) / mIncrement + 1;
    }

}

class SingleNumberPicker extends WatchUi.Picker {

    function initialize(label, initialValue, minValue, maxValue) {
        var title = new WatchUi.Text(
        	{	:text=>label, 
        		:font=>Graphics.FONT_SMALL, 
        		:locX =>WatchUi.LAYOUT_HALIGN_CENTER, 
        		:locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, 
        		:color=>Graphics.COLOR_WHITE
        	}
        );
        var factory = new NumberFactory(minValue, maxValue, 1, {});
        var index = initialValue - minValue;
        Picker.initialize(
        	{	:title=>title, 
        		:defaults=>[index], 
        		:pattern=>[factory]
        	}
        );
    }
}


class IntervalDurationPickerDelegate extends WatchUi.PickerDelegate {

    function initialize() {
        PickerDelegate.initialize();
    }

    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_LEFT);
    }

    function onAccept(values) {
        var duration = values[0];
        Settings.setIntervalDuration(duration);
        WatchUi.popView(WatchUi.SLIDE_LEFT);
    }
}

class RestDurationPickerDelegate extends WatchUi.PickerDelegate {

	function initialize() {
        PickerDelegate.initialize();
    }

    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_LEFT);
    }

    function onAccept(values) {
        var duration = values[0];
        Settings.setRestDuration(duration);
        WatchUi.popView(WatchUi.SLIDE_LEFT);
    }
}

