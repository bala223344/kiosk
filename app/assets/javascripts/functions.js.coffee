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
    $amtandfee =  $amt * 1.035
    $fee = $amtandfee - $amt
    $amt = $amt.toFixed(2)
    $amtandfee = $amtandfee.toFixed(2)
    $fee = $fee.toFixed(2)
    $('#amount').val($amt)
    $('#fee_amt').val($fee)

    $('#actual_amt').html(formatter.format($amt))
    $('#display_amt').html(formatter.format($amtandfee))

    $('#fee').html(formatter.format($fee))
#    alert($amt)

  $('.wysihtml5').each ->
        $(this).wysihtml5();
