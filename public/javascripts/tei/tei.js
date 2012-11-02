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

  });