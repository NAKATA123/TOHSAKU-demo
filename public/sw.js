self.addEventListener('push', (event) => {
  const data = event.data ? event.data.json() : { title: '通知', body: '' }
  event.waitUntil(
    self.registration.showNotification(data.title, {
      body: data.body,
      icon: '/icon_32-removebg-preview.png'
    })
  )
})

self.addEventListener('notificationclick', (event) => {
  event.notification.close()
  event.waitUntil(clients.openWindow('/loaner_cars?tab=grid'))
})
