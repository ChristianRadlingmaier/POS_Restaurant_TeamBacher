# Punkteapp Frontend

Ein einfaches HTML/CSS/JavaScript Frontend zum Testen aller Funktionen des Punkteapp-Backends.

## Features

### 🔐 Authentifizierung
- **Registrierung**: Neue Benutzer können sich mit Vorname, Nachname, Email und Passwort registrieren
- **Login**: Benutzer können sich mit Email und Passwort anmelden
- **Session Verwaltung**: Credentials werden lokal gespeichert für persistente Sessions

### 👤 Benutzer-Dashboard
- **Profilanzeige**: Zeigt aktuelle Benutzerdaten und Punkte an
- **Punkte hinzufügen**: Test-Button um Punkte via Invoice hinzuzufügen
- **Rewards anschauen**: Übersicht aller verfügbaren Rewards
- **Profil bearbeiten**: Änderung von Vorname, Nachname, Email und Passwort
- **Transaktionshistorie**: Anzeige aller Punkte- und Reward-Transaktionen

### 🎁 Rewards System
- **Rewards Liste**: Anzeige aller verfügbaren und nicht verfügbaren Rewards
- **Reward Details**: Punkte-Kosten und Status werden angezeigt
- **Einlösen**: Benutzer können Rewards mit ihren Punkten einlösen

### ⚙️ Admin Panel
- **Benutzerverwaltung**: 
  - Übersicht aller registrierten Benutzer
  - Direktes Ändern der Punkte für Benutzer
- **Reward Verwaltung**:
  - Neue Rewards erstellen
  - Existing Rewards bearbeiten
  - Rewards löschen

## Installation & Nutzung

### 1. Backend starten
```bash
cd backend
./mvnw spring-boot:run
```
Backend läuft dann auf `http://localhost:8080`

### 2. Frontend öffnen
Einfach die `index.html` im Browser öffnen:
- Mit Live Server: Rechtsklick auf `index.html` → "Open with Live Server"
- Direkt im Browser: `file:///path/to/frontend/index.html`

### 3. Admin-Benutzer erstellen (Optional)
Per URL:
```
http://localhost:8080/api/auth/register-admin?firstname=Admin&lastname=User&email=admin@test.com&password=123456
```

## API Endpoints im Frontend getestet

### Auth (`/api/auth`)
- ✅ `POST /register` - Benutzer registrieren
- ✅ `POST /register-admin` - Admin registrieren
- ✅ `POST /login` - Anmelden
- ✅ `GET /login?email=...&password=...` - Anmelden via URL

### User (`/api/user`)
- ✅ `GET /me?email=...&password=...` - Aktuellen Benutzer abrufen
- ✅ `GET /rewards` - Alle Rewards abrufen
- ✅ `POST /redeem?email=...&password=...` - Reward einlösen
- ✅ `POST /invoices?email=...&password=...` - Punkte hinzufügen
- ✅ `GET /history?email=...&password=...` - Transaktionshistorie
- ✅ `PUT /profile?email=...&password=...` - Profil aktualisieren

### Admin (`/api/admin`)
- ✅ `GET /users` - Alle Benutzer
- ✅ `PUT /users/{id}/points?points=...` - Punkte eines Benutzers setzen
- ✅ `POST /rewards` - Neues Reward erstellen
- ✅ `PUT /rewards/{id}` - Reward bearbeiten
- ✅ `DELETE /rewards/{id}` - Reward löschen

## Test-Szenarien

### Szenario 1: Normaler Benutzer
1. Registrierung durchführen
2. Mit den neuen Credentials anmelden
3. Dashboard ansehen (leere Punkte und History)
4. "Punkte hinzufügen" Button klicken (Test-Invoice)
5. Punkte sollten sich erhöhen
6. Rewards ansehen und versuchen einzulösen
7. Profil bearbeiten und speichern

### Szenario 2: Admin
1. Admin-Benutzer erstellen (via URL oder Registrierung)
2. Mit Admin-Credentials anmelden
3. Admin Panel aufrufen
4. Alle Benutzer und deren Punkte sehen
5. Punkte eines Benutzers direkt ändern
6. Neue Rewards erstellen
7. Bestehende Rewards bearbeiten/löschen

## Design & Features

- 🎨 **Modernes Design**: Gradient-Hintergrund, responsive Layout
- 📱 **Responsive**: Funktioniert auf Desktop, Tablet und Mobile
- 🎯 **Benutzerfreundlich**: Intuitive Navigation und klare UI
- 🔔 **Toast Notifications**: Rückmeldungen für alle Aktionen
- 💾 **Session-Speicher**: Credentials im LocalStorage für persistente Sessions
- ⌨️ **Keyboard-freundlich**: Alle Funktionen erreichbar

## Dateistruktur

```
frontend/
├── index.html      # HTML-Struktur mit allen Seiten
├── styles.css      # Responsive CSS-Styling
├── app.js          # JavaScript-Logik und API-Integration
└── README.md       # Diese Dokumentation
```

## Browser-Kompatibilität

Funktioniert mit allen modernen Browsern:
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Notes

- Das Backend läuft lokal auf Port 8080
- CORS ist im Backend konfiguriert
- E-Mails werden für Authentifizierung verwendet (keine echte Email-Validierung)
- Passwörter werden im Backend gehasht
- Die H2-Datenbank wird lokal gespeichert (`./src/main/resources/punkte`)

## Troubleshooting

### CORS Fehler?
Stelle sicher, dass das Backend mit CORS-Config läuft und die Ports korrekt sind.

### 404 auf Rewards?
Mindestens ein Reward muss im Admin Panel erstellt werden.

### Login schlägt fehl?
Überprüfe, dass Email und Passwort korrekt sind und dass das Backend läuft.

---

**Happy Testing! 🚀**
