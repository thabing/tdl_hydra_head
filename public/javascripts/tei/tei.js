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



          var pid = $(this).data('pid');
          $.getJSON('/file_assets/image_overlay/' + pid , function(data)
          {
            var template = $('#image_overlay_template').html();
            var html = Mustache.to_html(template, data);
            $('#myImageOverlay').html(html).modal('show');

          });




      });

      $('.myImageGalleryLauncher').on('click', function(e) {
        e.preventDefault();
          var pid = $(this).data('pid');
          $.getJSON('/file_assets/image_gallery/' + pid , function(data)
            {
                var template = $('#gallery_overlay_template').html();

                var html = Mustache.to_html(template, data);
                $('#myImageGallery').html(html).modal('show');
            });

      });

  });