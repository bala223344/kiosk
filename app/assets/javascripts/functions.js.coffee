

$ ->
  if typeof window.ClipboardJS != 'undefined'
    clipboard = new ClipboardJS('#copy-button')
  
    #disable onclick disable
  $(".refund_form").on("ajax:success", (e, data, status, xhr) ->
    $(this).find('.badge').addClass('.badge-success').html 'Processed'
  ).on "ajax:error", (e, xhr, status, error) ->
    $(this).find('.badge').addClass('.badge-danger').html 'Declined'





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
