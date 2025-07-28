# 🧩 FreshTally Connector

FreshTally Connector is a lightweight Windows desktop app that automatically syncs supermarket or shop sales data from various POS systems (CSV, MySQL, SQLite, APIs) to the FreshTally cloud for insights, reporting, and decision-making.It is working in conjuction with the Freshtally mbile app and the data collected from the POS is used by the app to suggest better ways of going about with supermarket stock eg it suggets promotions, shows trends of sales pf different goods etc. The data collected by the light weight connector app is greatly needed for this cause.

---

## 📦 Features

✅ Connects to popular POS data sources:
- CSV/Excel
- SQLite
- MySQL
- HTTP APIs

✅ Easy Configuration Wizard:
- One-time setup with your store ID and data source type
- Editable settings if your POS changes

✅ Secure & Automatic:
- Stores your configuration locally
- Auto-runs silently in the background on Windows startup
- Sends only required sales data to FreshTally securely

✅ Custom Field Mapping:
- Match your POS fields (e.g. `item_code`, `price`) to the format FreshTally expects

✅ Visual Feedback:
- Upload status (success/failure) displayed after every sync
- Sync history saved to a log file for audit

---

## ⚙️ How It Works

1. **Install the app** using the provided installer `.exe`.
2. **On first launch**, a wizard lets you:
   - Enter your store name and ID
   - Choose data source (CSV, SQLite, MySQL, API)
   - Select and map fields
3. Once saved, the app:
   - Starts syncing every few minutes in the background
   - Uploads sales data to FreshTally automatically
4. You can **edit settings anytime** by reopening the app.

---

## 📁 Files & Folders

| File / Folder     | Purpose                                      |
|-------------------|----------------------------------------------|
| `yourapp.exe`     | The main executable connector app            |
| `config.json`     | Stores your connection info and field mapping|
| `sync_log.txt`    | Shows upload history and errors              |
| `icon.ico`        | App icon used in the tray and installer      |
| `README.md`       | This file                                    |

---

## 🔐 Privacy & Security

- Your data is stored **locally** on your PC.
- Only the selected fields are sent to FreshTally.
- No personal data is collected unless explicitly configured.

---

## 🛠 Requirements

- Windows 10 or later
- Python environment is embedded inside `.exe`
- Internet connection for uploading to FreshTally

---

## 🚀 Run on Startup

Once configured, the app automatically adds itself to your Windows startup. It runs silently in the background and uploads data periodically — no user input needed.

---

## 📞 Support

For help, reach out to the FreshTally team:

- 📧 Email: support@freshtally.com
- 🌐 Website: [www.freshtally.com](https://www.freshtally.com)

---

## 📄 License

FreshTally Connector is distributed under a limited license. By using this software, you agree to the Terms of Use provided during installation.
