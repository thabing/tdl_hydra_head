
$(document).ready(
  function() {
  }
);

	var currentlyHighlightedDiv = null;
	var lastSeconds = -1;

	function playerReady() {
		YAHOO.MediaPlayer.onProgress.subscribe(scrollTranscript);
	}


	function scrollTranscript(progressArray) {
		//progressArray includes keys 'elapsed' and 'duration', both in ms
		var elapsedTime = progressArray['elapsed'];
		var seconds = Math.floor(elapsedTime / 1000);

		// Only proceed if time is at least one second greater than last time this was called.
		if (seconds != lastSeconds) {
			lastSeconds = seconds;

			var div = document.getElementById("chunk" + seconds);

			// Only proceed if a transcript chunk div exists for this number of seconds.
			if (div != null) {
				if (currentlyHighlightedDiv != null) {
					currentlyHighlightedDiv.style.backgroundColor = 'white';
				}
	
				currentlyHighlightedDiv = div;
				currentlyHighlightedDiv.style.backgroundColor = '#f4dca6';
				currentlyHighlightedDiv.scrollIntoView(true);
			}
		}
	}

	YAHOO.MediaPlayer.onAPIReady.subscribe(playerReady);
