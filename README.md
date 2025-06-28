# 🎫 Tixly — From Ticket to Memory

Tixly è un'app mobile in sviluppo, costruita con **Flutter + Firebase**, pensata per trasformare ogni biglietto in un ricordo indimenticabile.  
Non è solo un wallet digitale: è un diario, una community e un modo nuovo di vivere gli eventi.

---

## 🚀 Vision

> Un'unica app per salvare i tuoi biglietti, rivivere i tuoi momenti preferiti e connetterti con chi ama la musica dal vivo quanto te.

---

## ✨ Funzionalità principali (MVP)

- 📥 Caricamento biglietti (immagine o PDF)
- 📅 Reminder automatici per gli eventi futuri
- 📔 Diario multimediale post-evento (foto, note, valutazioni)
- 🧾 Feed social pubblico con like, commenti e post
- 🔐 Autenticazione Firebase (email + Google)
- 💾 Archiviazione sicura su Firebase Firestore & Storage

---

## 📱 UI e Design

Tixly segue una UI moderna, colorata e accessibile:
- Bottom navigation a 4 schede + FAB
- Onboarding interattivo (mostrato solo alla prima apertura)
- Design sviluppato con Figma, pensato per la Gen Z e Millennials

---

## 📦 Tech Stack

| Area | Tecnologie |
|------|------------|
| Frontend | Flutter 3.x |
| State Management | Provider (→ Riverpod v2 in arrivo) |
| Backend | Firebase (Auth, Firestore, Storage, Cloud Functions) |
| Notifiche | flutter_local_notifications |
| Design | Figma, Illustrator (branding, logo) |

---

## 📂 Struttura del Progetto

```bash
lib/
├── models/         # Modelli dati (User, Post, Ticket, Event)
├── providers/      # State management (Provider)
├── services/       # Autenticazione, Firestore, Storage
├── screens/        # Schermate principali dell’app
├── widgets/        # Componenti UI riutilizzabili
└── main.dart       # Entry point + init Firebase
