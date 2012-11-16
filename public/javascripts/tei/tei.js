$(function(){
      $('.collapse_td').on('click', function(e){

        e.preventDefault();
        var par = $(this).parents("tr").eq(0);
        var col_cont = par.find('.collapse_content');
        col_cont.toggle();
        var tog_img= par.find('img');
        if (col_cont.is(':visible'))
        {

            tog_img.attr('src','/assets/img/button_collapse.png');
        }
        else
        {
            tog_img.attr('src','/assets/img/button_expand.png');
        }
      });


      //add modals to the thumbnails

      $('.thumbnail').attr('href','#myImageOverlay');
      $('.thumbnail').on('click', function(e){
            e.preventDefault();

          var template = $('#image_overlay_template').html();
          var overlay_data = "";
          var html = Mustache.to_html(template, overlay_data);
          $('#myImageOverlay').html(html);


      });

  });