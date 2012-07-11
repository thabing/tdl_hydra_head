
function SortAndPerPageControls(sort_fields) {
    this.perpage_count = 25;
    this.sort_col = $('#sort').find('option:selected').val().split(" ",1)[0];
    this.sort_fields = sort_fields;


    var a = this.getParameterByName("per_page");
    if (a != "")
        this.perpage_count = a;

    a = this.getParameterByName("sort");
    if (a != "score" && a != "") {
        this.sort_col = a;
    }

    this.updatePerPageButton('#perpage_button');
    this.updateSortButton('#sort_button');


}


SortAndPerPageControls.prototype.getParameterByName = function (name) {
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regexS = "[\\?&]" + name + "=([^&#]*)";
    var regex = new RegExp(regexS);
    var results = regex.exec(window.location.search);
    if (results == null)
        return "";
    else
        return decodeURIComponent(results[1].replace(/\+/g, " "));
};

SortAndPerPageControls.prototype.updatePerPageButton = function () {

    $('#perpage_button').html(this.perpage_count + " per page" + "&nbsp;<span class=caret></span>");
    $('#per_page').val(this.perpage_count);
};

SortAndPerPageControls.prototype.updateSortButton = function () {

    var sort = $('#sort');
    var sort_type = this.sort_col.split(" ",1)[0];
    switch (sort_type)
    {
        case "score":
        case "Relevance":
          this.updateSortText('relevance');
          sort.find("option:contains('relevance')").prop("selected", "selected");
          break;
        case "title_sort":
        case "Title":
          this.updateSortText('title');
          sort.find("option:contains('title')").prop("selected", "selected");
          break;
        case "author_sort":
        case "Creator":
          this.updateSortText('creator');
          sort.find("option:contains('author')").prop("selected", "selected");
          break;
        case "pub_date_sort":
        case "Date":
          this.updateSortText('date');
          sort.find("option:contains('year')").prop("selected", "selected");
          break;
    }

};

SortAndPerPageControls.prototype.updateSortText = function (text) {
    $('#sort_button').html("Sort by " + text + "&nbsp;<span class=caret></span>");

};
