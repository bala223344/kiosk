window.populate_amt = ->
  formatter = new (Intl.NumberFormat)('en-US',
  style: 'currency'
  currency: 'USD')
  $amt = parseFloat($('.payment-amt').val())
  $amt += 0.00
  $percent = parseFloat($("#scharge_percent").val())
  $percent = ($percent / 100) 
  $fee =  $amt * $percent
  $fee = parseFloat($fee.toFixed(2))

  $amtandfee =  $amt +  $fee
  $amt = $amt.toFixed(3)

  $('#amount').val($amt)
  $('#fee_amt').val($fee)

  $('#actual_amt').html(formatter.format($amt))
  $('#display_amt').html(formatter.format($amtandfee))

  $('#fee').html(formatter.format($fee))
  return

  
$ ->
  if typeof window.ClipboardJS != 'undefined'
    clipboard = new ClipboardJS('#copy-button')




  $('.wysihtml5').each ->
        $(this).wysihtml5();
