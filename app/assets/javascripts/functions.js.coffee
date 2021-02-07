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


$(".slug_form").on("ajax:success", (e, data, status, xhr) ->
    Swal.fire({
      title: 'Success!',
      text: 'Updated successfully',
      icon: 'success',
      confirmButtonText: 'Ok'
    })

    setTimeout (->
      location.reload()
      return
    ), 2000

  ).on "ajax:error", (e, xhr, status, error) ->
    alert error


$('#hpp-sms').change ->
  formdata = {notify_sms_hpp : $(this).is(":checked")}
  saveNotif(formdata)
$('#chk-tips').change ->
  formdata = {tips : $(this).is(":checked")}
  saveKioskPref(formdata)
$('.dark-switch').click ->
  dark_mode = false
  if $(this).hasClass('active')
    dark_mode = true
  formdata = {dark_mode : !dark_mode}
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




clipboard = new ClipboardJS('#btnTerminalSetup', text: (trigger) ->
  result = $("#cbtext").html()
)


$("#phone-no,#emp").change ->

  phone = $("#phone-no").val()
  emp = $("#emp").val()
  kiosk_id = $("#hid-kiosk-id").val()
  link = "https://mobile.paynow.io/?hpp="+kiosk_id+"&emp="+emp+"&sms="+phone
  $("#cbtext").html(link)
 
  #new ClipboardJS('#btnTerminalSetup', text: (trigger) ->
  


$('#input_hpp_amt').inputmask('currency', {
    rightAlign: false
  });

$('.phone-format').inputmask({regex: "\\d{10}"});




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



# clipboard = new ClipboardJS('#btnTerminalSetup');

clipboard.on('success', (e) ->
  sms = $('#com-sms').prop("checked") ? 1 : 0 ;
  formdata = {emp : $("#emp").val(), phone: $("#phone-no").val(), sms : sms}
  contactlessTerminalSetup (formdata)
)

#$('#btnTerminalSetup').click ->
  
  






contactlessTerminalSetup = (formdata) ->
  $.ajax
    url: '/dashboard/terminalsetup'
    type: 'POST'
    beforeSend: (xhr) ->
      xhr.setRequestHeader 'X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')
      return
    data: formdata
    success: (response) ->
      if formdata.sms 
        Swal.fire({
          title: 'Success!',
          text: 'Generated and shared successfully',
          icon: 'success',
          confirmButtonText: 'Ok'
        })
      else
         Swal.fire({
          title: 'Success!',
          text: 'Generated successfully',
          icon: 'success',
          confirmButtonText: 'Ok'
        }) 
      return




saveKioskPref = (formdata) ->
  $.ajax
    url: '/dashboard/update_kiosk_pref'
    type: 'POST'
    beforeSend: (xhr) ->
      xhr.setRequestHeader 'X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')
      return
    data: kiosk: formdata
    success: (response) ->
      Swal.fire({
        title: 'Success!',
        text: 'Updated successfully',
        icon: 'success',
        confirmButtonText: 'Ok'
      })
      return
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
