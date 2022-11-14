import { createConsumer } from "@rails/actioncable"

const consumer = createConsumer()
window.consumer = consumer

consumer.subscriptions.create("OligrapherChannel", {
  connected() {
    console.log("Connected to OligrapherChannel")
  },

  disconnected() {
    console.log("disconnected from OligrapherChannel")
  },

  receive(data) {
    console.log("Received data", ata)
  },

  lock: function () {
    // return this.perform("lock")
  },
})
