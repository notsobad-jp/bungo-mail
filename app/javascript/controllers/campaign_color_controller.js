import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { color: String }
  static targets = [ "banner" ]

  colorValueChanged(value, previousValue) {
    if(previousValue) {
      this.bannerTarget.classList.remove(`bg-${previousValue}-700`)
    }
    this.bannerTarget.classList.add(`bg-${this.colorValue}-700`)
  }

  updateColor({ params: {color} }) {
    this.colorValue = color
  }
}
