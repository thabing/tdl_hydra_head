	var volume = 0.5; //not too loud by default or you'll drown out screen readers
	var YMPParams =
		{
			volume:volume,
			displaystate:3
		}

	var ympObjectId = 'swfproxy'; //the id Yahoo assigns to the YMP <object>
	var playlistId = 'playlist';
	var controllerId = 'controls';
	var thisMediaObj;
	var controller;
	var playerState;
	var numSongs;
	var songTitle;
	var playpause;
	var seekForward;
	var seekBack;
	var stop;
	var timer;
	var currentTimeContainer;
	var durationContainer;
	var duration;
	var elapsedTime;
	var mute;
	var volumeUp;
	var volumeDown;
	var playlist;
	var statusSpan;
	var seekInterval = 15; //number of seconds to seek forward or back (for HTML5)
	var resumeTrack = null;
	var resumeTime = 0;

	// Once API ready handler is invoked, YAHOO.MediaPlayer class can be accessed safely
	var apiReadyHandler = function () {
		playlist = document.getElementById(playlistId);
		controller = document.getElementById(controllerId);

		playpause = document.createElement('input');
		playpause.setAttribute('type','button');
		playpause.setAttribute('id','playpause');
		playpause.setAttribute('value','');
		playpause.setAttribute('title','Play');
		playpause.setAttribute('accesskey','P');
		controller.appendChild(playpause);

		stop = document.createElement('input');
		stop.setAttribute('type','button');
		stop.setAttribute('id','stop');
		stop.setAttribute('value','');
		stop.setAttribute('title','Stop');
		stop.setAttribute('accesskey','S');
		controller.appendChild(stop);

		seekBack = document.createElement('input');
		seekBack.setAttribute('type','button');
		seekBack.setAttribute('id','seekBack');
		seekBack.setAttribute('value','');
		seekBack.setAttribute('title','Rewind ' + seekInterval + ' seconds');
		seekBack.setAttribute('accesskey','R');
		seekBack.disabled=true; //will be enabled after track begins to play
		seekBack.setAttribute('class','disabled');
		controller.appendChild(seekBack);

		seekForward = document.createElement('input');
		seekForward.setAttribute('type','button');
		seekForward.setAttribute('id','seekForward');
		seekForward.setAttribute('value','');
		seekForward.setAttribute('title','Forward ' + seekInterval + ' seconds');
		seekForward.setAttribute('accesskey','F');
		seekForward.disabled=true; //will be enabled after track begins to play
		seekForward.setAttribute('class','disabled');
		controller.appendChild(seekForward);

		timer = document.createElement('span');
		timer.setAttribute('id','timer');
		currentTimeContainer = document.createElement('span');
		currentTimeContainer.setAttribute('id','currentTime');
		var startTime = document.createTextNode('0:00');
		currentTimeContainer.appendChild(startTime);

		durationContainer = document.createElement('span');
		durationContainer.setAttribute('id','duration');
		timer.appendChild(currentTimeContainer);
		timer.appendChild(durationContainer);
		controller.appendChild(timer);

		mute = document.createElement('input');
		mute.setAttribute('type','button');
		mute.setAttribute('id','mute');
		mute.setAttribute('value','');
		mute.setAttribute('title','Mute');
		mute.setAttribute('accesskey','M');
		controller.appendChild(mute);

		volumeUp = document.createElement('input');
		volumeUp.setAttribute('type','button');
		volumeUp.setAttribute('id','volumeUp');
		volumeUp.setAttribute('value','');
		volumeUp.setAttribute('title','Volume Up');
		volumeUp.setAttribute('accesskey','U');
		controller.appendChild(volumeUp);

		volumeDown = document.createElement('input');
		volumeDown.setAttribute('type','button');
		volumeDown.setAttribute('id','volumeDown');
		volumeDown.setAttribute('value','');
		volumeDown.setAttribute('title','Volume Down');
		volumeDown.setAttribute('accesskey','D');
		controller.appendChild(volumeDown);

		//get and set default values
		YAHOO.MediaPlayer.setVolume(volume);

		// Add other listeners for Yahoo events
		YAHOO.MediaPlayer.onPlaylistUpdate.subscribe(onPlaylistUpateHandler);
		YAHOO.MediaPlayer.onTrackStart.subscribe(onTrackStartHandler);
		YAHOO.MediaPlayer.onTrackPause.subscribe(onTrackPauseHandler);
		YAHOO.MediaPlayer.onProgress.subscribe(onProgressHandler);

		//handle playpause click
		if (document.addEventListener) {
			playpause.addEventListener('click',function() {
				playAudio();
			}, false);
		}
		else if (document.attachEvent) { //IE 8 and below
			playpause.attachEvent('onclick',function () {
				playAudio();
			});
		}

		//handle stop click
		if (document.addEventListener) {
			stop.addEventListener('click',function() {
				YAHOO.MediaPlayer.stop();
				playpause.setAttribute('title','Play');
				playpause.style.backgroundImage="url('../images/audio_play.gif')";
				showTime(0,currentTimeContainer);
				resumeTrack = null;
				resumeTime = 0;
			}, false);
		}
		else if (document.attachEvent) { //IE 8 and below
			stop.attachEvent('onclick',function () {
				YAHOO.MediaPlayer.stop();
				playpause.setAttribute('title','Play');
				playpause.style.backgroundImage="url('../images/audio_play.gif')";
				showTime(0,currentTimeContainer);
				resumeTrack = null;
				resumeTime = 0;
			});
		}

		//handle seekForward click
		if (document.addEventListener) {
			seekForward.addEventListener('click',function() {
				seekAudio('forward');
			}, false);
		}
		else if (document.attachEvent) { //IE 8 and below
			seekForward.attachEvent('onclick',function () {
				seekAudio('forward');
			});
		}

		//handle seekBack click
		if (document.addEventListener) {
			seekBack.addEventListener('click',function() {
				seekAudio('back');
			}, false);
		}
		else if (document.attachEvent) { //IE 8 and below
			seekBack.attachEvent('onclick',function () {
				seekAudio('back');
			});
		}

		//handle mute click
		if (document.addEventListener) {
			mute.addEventListener('click',function() {
				toggleMute();
			}, false);
		}
		else if (document.attachEvent) { //IE 8 and below
			mute.attachEvent('onclick',function () {
				toggleMute();
			});
		}

		//handle volumeUp click
		if (document.addEventListener) {
			volumeUp.addEventListener('click',function() {
				updateVolume('up');
			}, false);
		}
		else if (document.attachEvent) { //IE 8 and below
			volumeUp.attachEvent('onclick',function () {
				updateVolume('up');
			});
		}

		//handle volumeDown click
		if (document.addEventListener) {
			volumeDown.addEventListener('click',function() {
				updateVolume('down');
			}, false);
		}
		else if (document.attachEvent) { //IE 8 and below
			volumeDown.attachEvent('onclick',function () {
				updateVolume('down');
			});
		}
	}

	var onPlaylistUpateHandler = function (playlistArray) {
		numSongs = YAHOO.MediaPlayer.getPlaylistCount();
		//set first track as "Now playing"
		var children = playlist.childNodes;
		var finished = false;
		for (var i=0; i < children.length; i++) {
			if (children[i].nodeName == 'LI' && finished == false) {
				songTitle = children[i].childNodes[0].innerHTML;
				finished = true;
			}
		}
	}

	function onTrackStartHandler (mediaObj) {
		//track has started playing, possible via a click in the playlist
		//be sure playpause button is in pause state
		var trackMeta = YAHOO.MediaPlayer.getMetaData();
		songTitle = trackMeta['title'];
		playpause.setAttribute('title','Pause');
		playpause.style.backgroundImage="url('../images/audio_pause.gif')";
		thisMediaObj = mediaObj;
		//at this point, ok to enable seek buttons
		seekBack.disabled=false;
		seekBack.removeAttribute('class');
		seekForward.disabled=false;
		seekForward.removeAttribute('class');

		if (resumeTrack == YAHOO.MediaPlayer.getMetaData().id && resumeTime != 0) {
			// Resume play where it was paused, not at the beginning.
			showTime(Math.floor(resumeTime), currentTimeContainer);
			YAHOO.MediaPlayer.play(mediaObj.track, resumeTime * 1000);
		}

		resumeTrack = null;
		resumeTime = 0;
	}

	function onTrackPauseHandler (mediaObj) {
		//track has been possed, possible via a click on a pause button in the playlist
		//be sure playpause button is in play state
		playpause.setAttribute('title','Play');
		playpause.style.backgroundImage="url('../images/audio_play.gif')";

		resumeTrack = YAHOO.MediaPlayer.getMetaData().id;
		resumeTime = YAHOO.MediaPlayer.getTrackPosition();
	}

	function onProgressHandler (progressArray) {
		//progressArray includes keys 'elapsed' and 'duration', both in ms
		elapsedTime = progressArray['elapsed'];
		if (elapsedTime > 0) showTime(elapsedTime/1000,currentTimeContainer);
		else showTime(0,currentTimeContainer);
		duration = progressArray['duration'];
		if (duration > 0) showTime(duration/1000,durationContainer);
		else showTime(0,durationContainer);
	}

	function playAudio() {
		playerState = YAHOO.MediaPlayer.getPlayerState();
		//values: STOPPED: 0, PAUSED: 1, PLAYING: 2, BUFFERING: 5, ENDED: 7
		if (playerState == 2) { //playing -- meaning you now want it to pause
			YAHOO.MediaPlayer.pause();
			playpause.setAttribute('title','Play');
			playpause.style.backgroundImage="url('../images/audio_play.gif')";
		}
		else {
			YAHOO.MediaPlayer.play();
			playpause.setAttribute('title','Pause');
			playpause.style.backgroundImage="url('../images/audio_pause.gif')";
		}
	}

	function seekAudio(direction) {
		//element is either seekForward or seekBack
		//this only works if a track has started playing
		//shouldn't be possible to call this function prior to that because seek buttons are disabled
		//but this if loop is here to prevent an error, just in case
		if (typeof thisMediaObj != 'undefined') {
			var trackPos = YAHOO.MediaPlayer.getTrackPosition();

			if (direction == 'forward') {
				//NOTE: API docs at http://mediaplayer.yahoo.com/api say getTrackPosition() returns value in ms
				//This is incorrect - it returns the current position in SECONDS!
				//Target time, however, must be passed to play() in ms
				var targetTime = Math.floor(trackPos + seekInterval) * 1000;
			}
			else if (direction == 'back') {
				var targetTime =  Math.floor(trackPos - seekInterval) * 1000;
			}

			YAHOO.MediaPlayer.play(thisMediaObj.track,targetTime);
		}
	}

	function showTime(time,elem,hasSlider) {
		if (elem == durationContainer && time == 0) {
			//duration is unknown. Don't display it
			//also, should disable seekBack and and seekForward buttons
		}
		else {
			var minutes = Math.floor(time/60);
			var seconds = Math.floor(time % 60);
			if (seconds < 10) seconds = '0' + seconds;
			var output = minutes + ':' + seconds;
			if (elem == currentTimeContainer) elem.innerHTML = output;
			else elem.innerHTML = ' / ' + output;
		}
	}

 	function updateVolume(direction) {
		//volume is a range between 0 and 1
		volume = YAHOO.MediaPlayer.getVolume();
		if (direction == 'up') {
			if (volume < 0.9) {
				if (volume == 0) toggleMute();
				volume = (volume + 0.1);
			}
			else volume = 1;
		}
		else { //direction is down
			if (volume > 0.1) volume = (volume - 0.1);
			else volume = 0;
		}
		YAHOO.MediaPlayer.setVolume(volume);
	}

	function toggleMute() {
		if (YAHOO.MediaPlayer.getVolume() == 0) { //muted, so unmute.
			mute.setAttribute('title','Mute');
			YAHOO.MediaPlayer.setVolume(volume); //volume should still be at pre-muted value
			mute.style.backgroundImage="url('../images/audio_volume.gif')";
		}
		else { //not muted, so mute
			mute.setAttribute('title','UnMute');
			//don't update var volume. Keep it at previous level
			//so we can return to it on unmute
			YAHOO.MediaPlayer.setVolume(0);
			mute.style.backgroundImage="url('../images/audio_mute.gif')";
		}
	}

	YAHOO.MediaPlayer.onAPIReady.subscribe(apiReadyHandler);
