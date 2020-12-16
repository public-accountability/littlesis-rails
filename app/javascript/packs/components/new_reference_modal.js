window.addEventListener('DOMContentLoaded', function() {
  const fileInput = document.querySelector('#reference-form input[type="file"]')

  if (!fileInput) { return }

  fileInput.value = ''

  fileInput.addEventListener('change', function() {
    document.querySelector('#reference-form input[type="url"]').required = (this.value == '')
  })

})
