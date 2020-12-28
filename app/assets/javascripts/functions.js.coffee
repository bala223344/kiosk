

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


$('#hpp-sms').change ->
  formdata = {notify_sms_hpp : $(this).is(":checked")}
  saveNotif(formdata)
$('#hpp-email').change ->
  formdata = {notify_email_hpp : $(this).is(":checked")}
  saveNotif(formdata)
$('#hpp-daily').change ->
  formdata = {notify_email_daily : $(this).is(":checked")}
  saveNotif(formdata)
$('#hpp-monthly').change ->
  formdata = {notify_email_monthly : $(this).is(":checked")}
  saveNotif(formdata)
  
  


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
   




   
saveNotif = (formdata) ->
  $.ajax
    url: '/dashboard/update_notif_pref'
    type: 'POST'
    beforeSend: (xhr) ->
      xhr.setRequestHeader 'X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')
      return
    data: user: formdata
    success: (response) ->
      Swal.fire({
        title: 'Success!',
        text: 'Updated successfully',
        icon: 'success',
        confirmButtonText: 'Ok'
      })
      return

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
