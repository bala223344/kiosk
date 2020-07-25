$ ->
  $('a[data-toggle=modal]').on 'click', ->
    $('.dropdown').removeClass('open')
  # $('[data-target=#ajax-modal]').on 'click', (e)->
  #    e.preventDefault()
  #    e.stopPropagation();
  #    $.rails.handleRemote( $(this) );
  $(document).on 'click', '[data-dismiss=modal], .modal-scrollable', ->
    $('.modal-body-content').empty()
  $(document).on 'click', '#ajax-modal', (e) ->
    e.stopPropagation();
    #price change on wizard



  $(".payment-amt").bind 'blur', ->
    formatter = new (Intl.NumberFormat)('en-US',
    style: 'currency'
    currency: 'USD')
    $amt = parseFloat($(this).val())
    $amt += 0.00
    $percent = parseFloat($("#scharge_percent").val())
    $percent = ($percent / 100) 
    $fee =  $amt * $percent
    $fee = parseFloat($fee.toFixed(2))

    $amtandfee =  $amt +  $fee
    $amt = $amt.toFixed(3)
   #$amtandfee = $amtandfee.toFixed(3)
    #$fee = $fee.toFixed(3)

    $('#amount').val($amt)
    $('#fee_amt').val($fee)

    $('#actual_amt').html(formatter.format($amt))
    $('#display_amt').html(formatter.format($amtandfee))

    $('#fee').html(formatter.format($fee))
#    alert($amt)

  $('.wysihtml5').each ->
        $(this).wysihtml5();
