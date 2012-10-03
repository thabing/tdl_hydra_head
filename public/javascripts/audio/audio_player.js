	var initialVolume = 50; // not too loud by default or you'll drown out screen readers
	var seekInterval = 15; // number of seconds by which to seek forward or back
	var controllerId = 'controls'; // id of div for controls
	var controller;
	var playpause;
	var stop;
	var seekBack;
	var seekForward;
	var currentTimeContainer;
	var durationContainer;
	var mute;
	var volumeUp;
	var volumeDown;

	function apiReadyHandler() {
		controller = document.getElementById(controllerId);

		playpause = document.createElement('input');
		playpause.setAttribute('type', 'button');
		playpause.setAttribute('id', 'playpause');
		playpause.setAttribute('value', '');
		playpause.setAttribute('title', 'Play');
		playpause.setAttribute('accesskey', 'P');
		controller.appendChild(playpause);

		stop = document.createElement('input');
		stop.setAttribute('type', 'button');
		stop.setAttribute('id', 'stop');
		stop.setAttribute('value', '');
		stop.setAttribute('title', 'Stop');
		stop.setAttribute('accesskey', 'S');
		controller.appendChild(stop);

		seekBack = document.createElement('input');
		seekBack.setAttribute('type', 'button');
		seekBack.setAttribute('id', 'seekBack');
		seekBack.setAttribute('value', '');
		seekBack.setAttribute('title', 'Rewind ' + seekInterval + ' seconds');
		seekBack.setAttribute('accesskey', 'R');
		seekBack.disabled = true; // will be enabled after track begins to play
		seekBack.setAttribute('class', 'disabled');
		controller.appendChild(seekBack);

		seekForward = document.createElement('input');
		seekForward.setAttribute('type', 'button');
		seekForward.setAttribute('id', 'seekForward');
		seekForward.setAttribute('value', '');
		seekForward.setAttribute('title', 'Forward ' + seekInterval + ' seconds');
		seekForward.setAttribute('accesskey', 'F');
		seekForward.disabled = true; // will be enabled after track begins to play
		seekForward.setAttribute('class', 'disabled');
		controller.appendChild(seekForward);

		var timer = document.createElement('span');
		timer.setAttribute('id', 'timer');
		currentTimeContainer = document.createElement('span');
		currentTimeContainer.setAttribute('id', 'currentTime');
		var startTime = document.createTextNode('0:00');
		currentTimeContainer.appendChild(startTime);

		durationContainer = document.createElement('span');
		durationContainer.setAttribute('id', 'duration');
		timer.appendChild(currentTimeContainer);
		timer.appendChild(durationContainer);
		controller.appendChild(timer);

		mute = document.createElement('input');
		mute.setAttribute('type', 'button');
		mute.setAttribute('id', 'mute');
		mute.setAttribute('value', '');
		mute.setAttribute('title', 'Mute');
		mute.setAttribute('accesskey', 'M');
		controller.appendChild(mute);

		volumeUp = document.createElement('input');
		volumeUp.setAttribute('type', 'button');
		volumeUp.setAttribute('id', 'volumeUp');
		volumeUp.setAttribute('value', '');
		volumeUp.setAttribute('title', 'Volume Up');
		volumeUp.setAttribute('accesskey', 'U');
		controller.appendChild(volumeUp);

		volumeDown = document.createElement('input');
		volumeDown.setAttribute('type', 'button');
		volumeDown.setAttribute('id', 'volumeDown');
		volumeDown.setAttribute('value', '');
		volumeDown.setAttribute('title', 'Volume Down');
		volumeDown.setAttribute('accesskey', 'D');
		controller.appendChild(volumeDown);

		// Set default values
		jwplayer().setVolume(initialVolume);

		// Add listeners for JW Player events
		jwplayer().onPlay(onTrackStartHandler);
		jwplayer().onPause(onTrackPauseHandler);
		jwplayer().onIdle(onTrackIdleHandler);
		jwplayer().onBufferChange(onBufferedHandler);
		jwplayer().onTime(onProgressHandler);
		jwplayer().onMute(onMuteHandler);

		// Add listeners for control clicks
		if (document.addEventListener) {
			playpause.addEventListener('click', playAudio, false);
			stop.addEventListener('click', stopAudio, false);
			seekForward.addEventListener('click', seekAudioForward, false);
			seekBack.addEventListener('click', seekAudioBack, false);
			mute.addEventListener('click', toggleMute, false);
			volumeUp.addEventListener('click', updateVolumeUp, false);
			volumeDown.addEventListener('click', updateVolumeDown, false);
		}
		else if (document.attachEvent) { // IE 8 and below
			playpause.attachEvent('onclick', playAudio);
			stop.attachEvent('onclick', stopAudio);
			seekForward.attachEvent('onclick', seekAudioForward);
			seekBack.attachEvent('onclick', seekAudioBack);
			mute.attachEvent('onclick', toggleMute);
			volumeUp.attachEvent('onclick', updateVolumeUp);
			volumeDown.attachEvent('onclick', updateVolumeDown);
		}
	}

	function onTrackStartHandler() {
		playpause.setAttribute('title', 'Pause');
		playpause.style.backgroundImage = "url('../images/audio/audio_pause.gif')";

		// Enable seek buttons
		seekBack.disabled = false;
		seekBack.removeAttribute('class');
		seekForward.disabled = false;
		seekForward.removeAttribute('class');
	}

	function onTrackPauseHandler() {
		playpause.setAttribute('title', 'Play');
		playpause.style.backgroundImage = "url('../images/audio/audio_play.gif')";
	}

	function onTrackIdleHandler() {
		playpause.setAttribute('title', 'Play');
		playpause.style.backgroundImage = "url('../images/audio/audio_play.gif')";

		// Disable seek buttons
		seekBack.disabled = true;
		seekBack.setAttribute('class', 'disabled');
		seekForward.disabled = true;
		seekForward.setAttribute('class', 'disabled');
	}

	function onBufferedHandler() {
		var duration = jwplayer().getDuration();

		if (duration < 0) duration = 0;

		showTime(duration, durationContainer);
	}

	function onProgressHandler() {
		var elapsedTime = jwplayer().getPosition();

		if (elapsedTime < 0) elapsedTime = 0;

		showTime(elapsedTime, currentTimeContainer);
	}

	function onMuteHandler(event) {
		if (event.mute) {
			mute.setAttribute('title', 'UnMute');
			mute.style.backgroundImage = "url('../images/audio/audio_mute.gif')";
		}
		else {
			mute.setAttribute('title', 'Mute');
			mute.style.backgroundImage = "url('../images/audio/audio_volume.gif')";
		}
	}

	function playAudio() {
		jwplayer().play(); // play() with no argument toggles playing/paused state
	}

	function stopAudio() {
		jwplayer().stop();
	}

	function seekAudioForward() {
		var trackPos = jwplayer().getPosition();
		var targetTime = Math.floor(trackPos + seekInterval);

		jwplayer().seek(targetTime);
	}

	function seekAudioBack() {
		var trackPos = jwplayer().getPosition();
		var targetTime = Math.floor(trackPos - seekInterval);

		jwplayer().seek(targetTime);
	}

 	function updateVolumeUp() {
		// volume is a range between 0 and 100
		var volume = jwplayer().getVolume();

		if (volume > 90) volume = 100;
		else volume += 10;			 

		jwplayer().setVolume(volume);
	}

 	function updateVolumeDown() {
		// volume is a range between 0 and 100
		var volume = jwplayer().getVolume();

		if (volume < 10) volume = 0;
		else volume -= 10;

		jwplayer().setVolume(volume);
	}

	function toggleMute() {
		jwplayer().setMute(); // setMute() with no argument toggles muted/unmuted state
	}

	function showTime(time, elem) {
		if (elem == durationContainer && time == 0) {
			// duration is unknown;  don't display it
		}
		else {
			var minutes = Math.floor(time / 60);
			var seconds = Math.floor(time % 60);

			if (seconds < 10) seconds = '0' + seconds;

			var output = minutes + ':' + seconds;

			if (elem == currentTimeContainer) elem.innerHTML = output;
			else elem.innerHTML = ' / ' + output;
		}
	}

$(document).ready(
	function() {
		jwplayer().onReady(apiReadyHandler);
	}
);
