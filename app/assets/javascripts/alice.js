// Unobtrusive example - http://wowkhmer.com/2011/09/19/unobtrusive-ajax-with-rails-31/
//
// TODO:
//
// 1. Закрывать форму комментирования, если открыта новая.

$(function() {
    $('form.alice-new_form')
      .live('ajax:success', function(evt, data, status, xhr){
              t = $(this);
              commentable = t.data('commentable');
              b = t.find('button'); // input[type=submit]
              remove_disabled(t);

              var tp = t.parent();
              if (tp.hasClass('alice-reply_form-container')) {
                tp.hide('fast');
                a = $("#alice-comment-reply_link-"+commentable);
                a.text(a.data('hidden-text') || 'комментировать');
              }

              b = $("#alice-replies_of-"+commentable);

              if (t.data('new-reply-placement')=='prepend') {
                b.prepend(JSON.parse(data)['html']);
              } else {
                b.append(JSON.parse(data)['html']);
              }

              counter = $('#alice-comments-counter');
              counter.html((parseInt(counter.text())+1).toString());
            })
      .live('ajax:error', function(data, xhr, status){
             if (xhr.responseText!=''){
               alert(xhr.responseText);
             }else{
               alert("Что-то пошло не так");
             }
             if(xhr.status==406){
                remove_disabled($(this));           
              }
            })
      .live('ajax:beforeSend', function(evt, data, status, xhr){
              t = $(this);
              t.find('textarea').attr('disabled','disabled');
              b = t.find('button'); // input[type=submit]
              b.attr('disabled', 'disabled');
              b.data('hidden-text', b.text());
              // b = t.find('button.alice-send-button');
              b.text('Отправляю..');
            });
    $('.alice-comment-reply_link').live('click', function(event){
              t = $(this);
              commentable = t.data('commentable');
              form = $("#alice-form-container-" + commentable)
              form.toggle();
              if (form.is(':visible')) {
                t.text(t.data('visible-text') || 'скрыть');
              } else {
                t.text(t.data('hidden-text') || 'комментировать');
              }
              return false;
        });

      function remove_disabled(form){
        form[0].reset();
        form.find('textarea').removeAttr('disabled');
        form.find('button').removeAttr('disabled');
        form.find('button').text(b.data('hidden-text') || 'комментировать');
        if (form.find('button').text() == 'Отправляем...') {
          form.find('button').text('Отправить');
        }
      }

    $('li.alice-comment a.comment-edit-link').live('click', function(event){
      var commentContainer = $(this).parent().parent().parent().parent();

      $(commentContainer.find("div.alice-comment-content")[0]).hide();
      $(commentContainer.find("div.alice-comment-edit")[0]).show();
      $(commentContainer.find("form.commentor-edit-form")[0]).focus();

      return false;
    });

    $('li.alice-comment form.alice-edit-form button.alice-cancel-button').live('click', function(event){
      var $this = $(this);

      var commentContainer = $($this.parents("li.alice-comment")[0]);

      commentContainer.find("div.alice-comment-content").show();
      commentContainer.find("div.alice-comment-edit").hide();

      return false;
    });

    $('form.alice-edit-form').live('ajax:success', function(evt, data, status, xhr){
      $this = $(this);
      //С bootstrap2 вроде не надо
      //$this.twipsy('hide'); // TODO Проверять на наличие twipsy

      var commentContainer = $($this.parents(".alice-comment-div")[0]);
      commentContainer.html(JSON.parse(data)['html']);
    });

    $('a.comment-remove-link').live('ajax:success', function(evt, data, status, xhr){
      $this = $(this);
      //С bootstrap2 вроде не надо
      // $this.twipsy('hide'); // TODO Проверять на наличие twipsy

      var commentContainer = $($this.parents(".alice-comment-div")[0]);
      commentContainer.html(JSON.parse(data['html']));

      return false;
    });

});
