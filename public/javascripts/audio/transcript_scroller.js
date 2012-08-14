	var currentlyHighlightedDiv = null;	
	var lastSeconds = -1;

	function playerReady() {
		YAHOO.MediaPlayer.onProgress.subscribe(scrollTranscript);
	}


	function scrollTranscript(progressArray) {

		if (resumeTime != 0) {
			// This means that the pause button was clicked and now the play button has been clicked.
			// The default behavior is to start over at time 0;  that behavior has been changed in
			// audio_player.js by skipping the player to resumeTime (defined in audio_player.js),
			// but on onProgress event will still be generated for time 0.  Ignore that event
			// (otherwise the transcript would be scrolled back to the beginning briefly).
			return;
		}

		//progressArray includes keys 'elapsed' and 'duration', both in ms
		var elapsedTime = progressArray['elapsed'];
		var seconds = Math.floor(elapsedTime / 1000);

		// Only proceed if the time is different than when this function was last called.
		if (seconds != lastSeconds) {
			lastSeconds = seconds;

			var div = null;

			// Search backwards to find the first div that would contain the transcript at timepoint "seconds".
			while (div == null & seconds > -1) {
				div = document.getElementById("chunk" + seconds);
				seconds -= 1;
			}

			// Found the right div -- scroll to it and highlight it if it isn't already highlighted
			if (div != null && div != currentlyHighlightedDiv) {
				if (currentlyHighlightedDiv != null) {
					currentlyHighlightedDiv.style.backgroundColor = 'white';
				}

				currentlyHighlightedDiv = div;
				currentlyHighlightedDiv.style.backgroundColor = '#F1F7FF';
				currentlyHighlightedDiv.scrollIntoView(true);
			}
		}
	}

	YAHOO.MediaPlayer.onAPIReady.subscribe(playerReady);

	function jumpPlayerTo(milliseconds) {
		// set audio_player.js variable resumeTime before calling MediaPlayer.play();
		// thisMediaObj is also an audio_player.js variable.
		resumeTime = milliseconds;
		YAHOO.MediaPlayer.play(thisMediaObj.track, milliseconds);
	}
