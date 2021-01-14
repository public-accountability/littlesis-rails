function scrollAnimation() {
  $('html, body').scrollTop(0)
  $('#btn-scroll').addClass('ratspin').prop('disabled', true)

  const properties = {
    scrollTop: $('.rats p').last().offset().top - $('.header-image').first().height()
  }

  const duration = 22000

  const onComplete = () => $('#btn-scroll').removeClass('ratspin').prop('disabled', false)

  $('html, body').animate(properties, duration, 'linear', onComplete)
}

function setupEvents() {
  $("#btn-scroll").click(function() { scrollAnimation() })
  $("#btn-about").click(function() { window.$('#modal-about').modal() })
  $("#btn-tip").click(function() { window.$('#modal-tip').modal() })
}

window.addEventListener('DOMContentLoaded', setupEvents)
window.addEventListener('load', scrollAnimation)
