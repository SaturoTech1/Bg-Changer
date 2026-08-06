# 🎨 Saturo X Zentrix Custom Theme Installer

An interactive, lightweight Bash installer for **Pterodactyl Panel**. Easily add custom **video or image backgrounds** with glassmorphism card styling, login modal contrast fixes, and bandwidth chart optimizations—all without breaking your panel.

---

## 🌟 Features

* **🎥 Video & Image Background Support:** Accepts direct links (`.mp4`, `.png`, `.jpg`, `.webm`) and handles autostart, loops, and responsive formatting automatically.
* **💎 Glassmorphism Design:** Modern frosted-glass aesthetic applied to panel cards and container elements.
* **🔑 Login Modal Optimization:** Customized dark frosted container for the login interface to ensure clear readability regardless of background brightness.
* **📊 Chart & Bandwidth Fixes:** Semi-transparent dark backings on Chart.js canvas elements so server resource graphs remain easily readable.
* **🛠️ Full Management Menu:** 
  * Install Video Background
  * Install Image Background
  * Remove Custom Background & Styles
  * Restore Original `wrapper.blade.php` from backup
* **⚡ Zero Manual Caching Required:** Automatically clears Laravel view cache (`php artisan view:clear`) on every action.

---

## 🚀 Quick Installation

Run this single command in your server terminal as **root**:

```bash <(curl -s https://raw.githubusercontent.com/SaturoTech1/Bg-Changer/main/install.sh)```
