const VAPID_PUBLIC_KEY = document.querySelector('meta[name="vapid-public-key"]')?.content

function urlBase64ToUint8Array(base64String) {
  const padding = '='.repeat((4 - base64String.length % 4) % 4)
  const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/')
  const rawData = atob(base64)
  return Uint8Array.from([...rawData].map(c => c.charCodeAt(0)))
}

async function subscribePush() {
  if (!('serviceWorker' in navigator) || !('PushManager' in window)) return

  const reg = await navigator.serviceWorker.register('/sw.js')
  const permission = await Notification.requestPermission()
  if (permission !== 'granted') return

  const subscription = await reg.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: urlBase64ToUint8Array(VAPID_PUBLIC_KEY)
  })

  const key  = subscription.getKey('p256dh')
  const auth = subscription.getKey('auth')

  await fetch('/push_subscriptions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content },
    body: JSON.stringify({
      endpoint:    subscription.endpoint,
      p256dh_key:  btoa(String.fromCharCode(...new Uint8Array(key))),
      auth_key:    btoa(String.fromCharCode(...new Uint8Array(auth)))
    })
  })

  updateButton(true)
}

async function unsubscribePush() {
  const reg = await navigator.serviceWorker.getRegistration('/sw.js')
  if (!reg) return
  const subscription = await reg.pushManager.getSubscription()
  if (!subscription) return

  await fetch('/push_subscriptions', {
    method: 'DELETE',
    headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content },
    body: JSON.stringify({ endpoint: subscription.endpoint })
  })

  await subscription.unsubscribe()
  updateButton(false)
}

function updateButton(subscribed) {
  const btn = document.getElementById('push-toggle-btn')
  if (!btn) return
  btn.dataset.subscribed = subscribed ? 'true' : 'false'
  btn.textContent = subscribed ? '🔔 通知ON' : '🔕 通知OFF'
  btn.classList.toggle('push-btn--on', subscribed)
}

async function initPushButton() {
  const btn = document.getElementById('push-toggle-btn')
  if (!btn || !VAPID_PUBLIC_KEY) return

  if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
    btn.textContent = '通知非対応'
    btn.disabled = true
    return
  }

  const reg = await navigator.serviceWorker.register('/sw.js')
  const subscription = await reg.pushManager.getSubscription()
  updateButton(!!subscription)

  btn.addEventListener('click', () => {
    btn.dataset.subscribed === 'true' ? unsubscribePush() : subscribePush()
  })
}

document.addEventListener('turbo:load', initPushButton)
