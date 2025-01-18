import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { color: String }
  static targets = [ "banner" ]

  colorValueChanged(value, previousValue) {
    console.log("-----")
    this.bannerTarget.classList.remove(`bg-${previousValue}-700`)
    this.bannerTarget.classList.add(`bg-${value}-700`)
  }
}
