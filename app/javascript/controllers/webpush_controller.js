import { Controller } from "@hotwired/stimulus"
import { patch } from '@rails/request.js'
import { initializeApp } from "@firebase/app";
import { getMessaging, getToken } from "@firebase/messaging";

const app = initializeApp(window.firebaseConfig);
const messaging = getMessaging(app);

export default class extends Controller {
  static values = { vapid: String }
  static targets = ["loadingIcon"]

  async subscribe(e) {
    this.loadingIconTarget.classList.remove("hidden")
    e.currentTarget.disabled = true;

    if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
      alert("申し訳ありませんがお使いのブラウザではプッシュ通知がサポートされていないようです。。")
      return;
    }

    try {
      const permission = await Notification.requestPermission();
      if (permission !== 'granted') {
        alert("プッシュ通知がブロックされています。ブラウザの設定でプッシュ通知を許可してください。")
        return;
      }

      const token = await getToken(messaging, {vapidKey: this.vapidValue});
      await this.updateSubscription({token: token});
      alert("通知設定が完了しました！")
      location.reload();
    } catch (error) {
      console.error('Failed to subscribe push notification:', error);
      alert("通知設定に失敗しました。。")
      return;
    } finally {
      this.loadingIconTarget.classList.add("hidden")
      e.currentTarget.disabled = false;
    }
  }

  async unsubscribe(e) {
    this.loadingIconTarget.classList.remove("hidden")
    e.currentTarget.disabled = true;

    try {
      await this.updateSubscription({token: null});
      alert("通知設定を解除しました！")
      location.reload();
    } catch (error) {
      console.error('Failed to unsubscribe push notification:', error);
      alert("通知設定の解除に失敗しました。。")
      return;
    } finally {
      this.loadingIconTarget.classList.add("hidden")
      e.currentTarget.disabled = false;
    }
  }

  async updateSubscription(params) {
    await patch('/user', {
      body: JSON.stringify(params)
    })
  }
}
