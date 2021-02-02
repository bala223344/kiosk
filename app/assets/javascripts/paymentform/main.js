
function loading(vis) {
	if(vis) {
		$("#modal-overlay").removeClass('d-none')
	}else {
		$("#modal-overlay").addClass('d-none')
	}
}
$(function () {
	var retref = null
	var tip_amt = 0
	var is_async_step = false;
	var formdata = null
	var tip_per = 0


	


	$("#wizard").steps({
		headerTag: "h4",
		bodyTag: "section",
		transitionEffect: "fade",
		enableAllSteps: true,
		transitionEffectSpeed: 500,
		saveState: true,
		onStepChanging: function (event, currentIndex, newIndex) {

			

			if (is_async_step) {
                is_async_step = false;
                //ALLOW NEXT STEP
                return true;
			}



			if (newIndex === 1) {







				if (!$("#amount").val()) {
					$("#amount").addClass('is-invalid')
					return false
				} else {

				formatter = new (Intl.NumberFormat)('en-US',{style: 'currency', currency: 'USD'})
				formatter2 = new (Intl.NumberFormat)('en-US',{style: 'percent', minimumFractionDigits:2}) // Dan
				var res = $('#amount').val().replace(/\$|\,/gi, "");
				$percent = parseFloat($("#scharge_percent").val())
				scharge_percent
				$amt = parseFloat(res)
				$amt += 0.00
				$percent = parseFloat($("#scharge_percent").val())
				$percent = ($percent / 100)
				$fee =  $amt * $percent
				$amtandfee =  $amt +  $fee
				$amt = $amt.toFixed(3)
				$('#display_org').html(formatter.format($amt)) // Dan

				$('#display_percent').html(formatter2.format($percent)) // Dan

				$('#display_fee').html(formatter.format($fee))

				$('#display_amt').html(formatter.format($amtandfee))
				$('#display_amt2').html(formatter.format($amtandfee)) // Dan

					$("#amount").removeClass('is-invalid')

					$('.steps ul').addClass('step-2');
					return true;
				}

				//		$('.container').removeClass('hidden'); // DAN

			} else {
				$('.steps ul').removeClass('step-2');
			}
			if (newIndex === 2) {

				const form = document.querySelector('form');
				formdata = Object.fromEntries(new FormData(form).entries());

		

				if (!$("#name").val()) {
					$("#name").addClass('is-invalid')
					return false
				}
				if (!$("#zip").val()) {
					$("#zip").addClass('is-invalid')
					return false
				}if (!$("#email").val()) {
					$("#email").addClass('is-invalid')
					return false
				}


				loading(true)

				$.ajax({ url: '/dashboard/ajx_charge_s1',
				type: 'POST',
				beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
				data: formdata,
				success: function(response) {

					if(response.amount ) {
						// $("#step2-error").addClass("d-none")
						// formatter = new (Intl.NumberFormat)('en-US',{style: 'currency', currency: 'USD'})
						 amt = parseFloat(response.amount)
						 final_amt = formatter.format(amt)
						 $(".final_amt").html(formatter.format(amt))
						// 
						 formdata["orig_amt"] =  parseFloat(response.orig_amt)
						 formdata["fee"] =  parseFloat(response.fee)


						loading(false)
						is_async_step =  true
						$("#wizard").steps("next");

					}else {
						error = "Declined: "+response.resptext
						$("#step2-error").removeClass("d-none").html(error)
						loading(false)
						return false;
					}


				}
				});




				$('.steps ul').addClass('step-3');
			} else {
				$('.steps ul').removeClass('step-3');
			}
			if (newIndex === 3) {

				formdata['tip_amt'] = tip_amt
				formdata["tip_percent"] =  tip_per
				loading(true)

				$.ajax({ url: '/dashboard/ajx_charge_s2',
				type: 'POST',
				beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
				data: formdata,
				success: function(response) {

					if(response.setlstat == 'Approved') {
						$("#step3-error").addClass("d-none")
						retref = response.retref
						$("#retref").html(retref)
						loading(false)
						is_async_step =  true
						$("#wizard").steps("next");
						setTimeout(function () {
							window.location.reload()
						  }, 10000);
					}else {
						$("#step3-error").removeClass("d-none").html(response.setlstat)
						loading(false)
						return false;
					}




				}
				});


				$('.steps ul').addClass('step-4');
				$('.actions ul').addClass('step-last');
			}

			if (currentIndex === 4) {
				$('.steps ul').removeClass('step-4');
				$('.actions ul').removeClass('step-last');

			}
			return false;
		},
		labels: {
			finish: "Finish",
			next: "Continue",
			previous: "Previous"
		}
	});
	$('.wizard > .steps li a').click(function () {
		$(this).parent().addClass('checked');
		$(this).parent().prevAll().addClass('checked');
		$(this).parent().nextAll().removeClass('checked');
	});
	$('.forward').click(function () {
		$("#wizard").steps('next');
	})
	$('.backward').click(function () {
		$("#wizard").steps('previous');
	})
	$('.checkbox-circle label').click(function () {
		$('.checkbox-circle label').removeClass('active');
		$(this).addClass('active');
	})

	$(".btn_tips").click(function () {
		tip_per =  parseInt($(this).data('val'))

		amt = formdata['orig_amt']
		fee = formdata['fee']
		tip_amt = (tip_per / 100) * amt
		final_amt = (amt + fee + tip_amt)
		$(".final_amt").html(formatter.format(final_amt))
		
	})

}(jQuery)); // Dan Added jQuery ending from };



//}) // remove if using JQ




// window.addEventListener('message', function(event) {

// 	var mytoken = document.getElementById('mytoken');
// 	mytoken.value = ""
// 	document.getElementById('mytoken').value = JSON.parse(event.data);

// 	var token = JSON.parse(event.data);

// 	mytoken.value = token.message;

// }, false);
