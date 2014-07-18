$(function(){
    $('#blog-header').data('size','big');
});

$(window).scroll(function(){
    if($(document).scrollTop() > 0)
    {
        if($('#blog-header').data('size') == 'big')
        {
            $('#blog-header').data('size','small');
            $('#blog-header').stop().animate({
                height:'40px'
            },600);
        }
    }
    else
    {
        if($('#blog-header').data('size') == 'small')
        {
            $('#blog-header').data('size','big');
            $('#blog-header').stop().animate({
                height:'170px'
            },600);
        }  
    }
});
