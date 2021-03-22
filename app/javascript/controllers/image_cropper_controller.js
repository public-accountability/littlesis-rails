import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'canvas' ]
  static values = { path: String, imageInfo: Object }

  rect = { startX: null, startY: null, w: null, h: null }
  cropData = { x: null, y: null, w: null, h: null }
  isDrawing = false
  ctx = null

  connect() {
    this.ctx = this.canvasTarget.getContext('2d')
  }

  submit() {
    const imageInfo = this.imageInfoValue
    const cropData = this.cropData

    return fetch(this.pathValue, {
      method: "POST",
      cache: "no-cache",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      }, 
      body: JSON.stringify({ "crop": Object.assign({}, imageInfo, cropData) }),
    })
      .then(function(res) { return res.json() })
      .then(function(json) { window.location.replace(json.url) })
  }

  startDrawing(e) {
    this.isDrawing = true
    const position = this.getCursorPosition(this.canvasTarget, e)
    this.rect = { startX: position.x, startY: position.y, w: null, h: null }
    this.cropData = { x: null, y: null, w: null, h: null }
  }

  endDrawing(e) {
    this.updateRect(e)
    const position = this.getCursorPosition(this.canvasTarget, e)

    // x,y     coordinates of the top left point of the rectancle
    // w,h     height and width (absolute value)
    this.cropData = {
      x: Math.min(this.rect.startX, position.x),
      y: Math.min(this.rect.startY, position.y),
      w: Math.abs(this.rect.w),
      h: Math.abs(this.rect.h)
    }

    this.isDrawing = false
  }

  getCursorPosition(canvas, event) {
    const rect = this.canvasTarget.getBoundingClientRect()
    const x = event.clientX - rect.left
    const y = event.clientY - rect.top
    return { x: x, y: y }
  }

  updateRect(e)  {
    const position = this.getCursorPosition(this.canvasTarget, e)
    this.rect.w = (position.x - this.rect.startX)
    this.rect.h = (position.y - this.rect.startY)
  }

  whileDrawing(e) {
    if (!this.isDrawing) {
      return
    }

    this.updateRect(e)

    this.ctx.clearRect(0,0, this.canvasTarget.width, this.canvasTarget.height)
    this.ctx.fillStyle = 'rgba(255, 255, 255, 0.5)'
    this.ctx.fillRect(this.rect.startX, this.rect.startY, this.rect.w, this.rect.h)
  }
}
