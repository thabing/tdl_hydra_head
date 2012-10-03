	var currentlyHighlightedDiv = null;	
	var lastSeconds = -1;


	function scrollTranscript() {
		var seconds = jwplayer().getPosition();

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


	function jumpPlayerTo(milliseconds) {
		jwplayer().seek(milliseconds / 1000);
	}
