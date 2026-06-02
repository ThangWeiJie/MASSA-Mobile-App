importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyAjU8Nc9hOKjKT3vQ90WZqGEARaEuo4FWY",
  authDomain: "mobile-app-development-b304f.firebaseapp.com",
  projectId: "mobile-app-development-b304f",
  storageBucket: "mobile-app-development-b304f.firebasestorage.app",
  messagingSenderId: "624999107309",
  appId: "1:624999107309:web:706e48aaeaf51e41e19ae4"
});

const messaging = firebase.messaging();