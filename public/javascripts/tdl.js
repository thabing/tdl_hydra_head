function extractPageName(hrefString)
{
	var arr = hrefString.split('/');
	return  (arr.length < 2) ? hrefString : arr[arr.length-1].toLowerCase();
}
 
function setActiveMenu(arr, crtPage)
{
	for (var i=0; i < arr.length; i++)
	{
		if(extractPageName(arr[i].href) == crtPage)
		{
			if (arr[i].parentNode.tagName != "DIV")
			{
				arr[i].className = "current";
				arr[i].parentNode.className = "current";
                return;
			}
		}
	}
    setActiveMenu(document.getElementById("navigation").getElementsByTagName("a"), "catalog");
}
 
function setPage()
{
	hrefString = document.location.href ? document.location.href : document.location;
 
	if (document.getElementById("navigation") !=null )
	setActiveMenu(document.getElementById("navigation").getElementsByTagName("a"), extractPageName(hrefString));
}

$(document).ready(function(){
  setPage();
});

Blacklight.facet_expand_contract = function () {
    $(this).next("ul, div").each(function () {
        var f_content = $(this);
        $(f_content).prev('h3').addClass('twiddle-open');
        // find all f_content's that don't have any span descendants with a class of "selected"
        //if ($('span.selected', f_content).length == 0) {
        //    // hide it
        //    f_content.hide();
        //} else {
        //    $(this).prev('h3').addClass('twiddle-open');
        //}

        // attach the toggle behavior to the h3 tag
        $('h3', f_content.parent()).click(function () {
            // toggle the content
            $(this).toggleClass('twiddle-open');
            $(f_content).slideToggle();
        });
    });
};