

$ ->
  if typeof window.ClipboardJS != 'undefined'
    clipboard = new ClipboardJS('#copy-button')
  
    #disable onclick disable
  $(".refund_form").on("ajax:success", (e, data, status, xhr) ->
    $(this).find('.badge').addClass('.badge-success').html 'Processed.redirecting..'

    setTimeout (->
      location.reload()
      return
    ), 3000

    



  ).on "ajax:error", (e, xhr, status, error) ->
    $(this).find('.badge').addClass('badge-danger').html error


$(".receipt_form").on("ajax:success", (e, data, status, xhr) ->
    $(this).find('.badge').addClass('badge-success').html 'Sent.'
  ).on "ajax:error", (e, xhr, status, error) ->
    $(this).find('.badge').addClass('badge-danger').html error



$(".update_password").on("ajax:success", (e, data, status, xhr) ->
    $('#profile-pwd').modal('hide')
    #(this).find('.badge').addClass('badge-success').html 'Sent.'
    Swal.fire({
      title: 'Success!',
      text: 'Updated successfully',
      icon: 'success',
      confirmButtonText: 'Ok'
    })
    
  ).on "ajax:error", (e, xhr, status, error) ->
      error = ''
      i = 0
      field = ''
      for key of xhr.responseJSON.error
        if xhr.responseJSON.error.hasOwnProperty(key)
          val = xhr.responseJSON.error[key]
          field = key.replace("_", " ")
          str =field + ' '+val
          error += '<p>'+str+'</p>'
          #'+ key +' ' + val +'

      # while i < xhr.responseJSON.error.length
      #   error += '<p>'+xhr.responseJSON.error[i]+'</p>'
      #   i++
      $(this).find('#pwd-err').removeClass('d-none').html error




    

    


 





$('#btnsend').click ->
  setTimeout (->
    $('#online-modal').modal('hide');
    return
  ), 2000
   




   


window.loading = (vis,txt='') ->
  if vis == 'show'
     $("#loadingModal").modal({
      backdrop: 'static',
      keyboard: false
    })
  $("#loadingModal").modal(vis)
  $("#loadingContent").html(txt)
 
window.submitToCC = ->
  loading("show",' Your card will be charged now. Please wait.')
  $("#edit_kiosk").submit()
  return


  $('.wysihtml5').each ->
        $(this).wysihtml5();
