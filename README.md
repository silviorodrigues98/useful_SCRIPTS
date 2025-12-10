# Useful Scripts Collection

A comprehensive collection of Windows and Linux scripts for identifying product keys, system maintenance, network troubleshooting, and software installation.

## 📂 Project Structure

### 🪟 Windows

Scripts related to Windows OS, organized by function:

- **Activation**: Tools to retrieve or manage Windows and Office product keys.
  - `discover_windows_product_key.ps1`
  - `discover_office_key.bat`
- **Maintenance**: Utilities for cleaning, repairing, and managing system updates.
  - `clean_and_repair.bat`: Comprehensive system cleanup and repair.
  - `disable_windows_updates.bat/ps1`: Scripts to toggle Windows Updates.
- **Network**: Scripts for network configuration and password recovery.
  - `see_wifi_passwords.ps1`: Recover saved WiFi passwords.
  - `reset_network_config.bat`: Reset network stack settings.
- **Installation**: Quick installers for common software and drivers.
  - `install_programs.bat`: Batch installer for standard apps.
  - `manage_printers.ps1`: Printer management utility.
- **DevTools**: Helper scripts for developers.
  - `new_esp_project.bat`: Setup for ESP projects.
  - `purge_docker_files.ps1`: Clean up Docker resources.
- **PowerManagement**: Shutdown timers and power profile settings.

### 🐧 Linux

Scripts for Linux (Shell scripts):

- **Installation**: Automated installers for tools like Docker, Git, Google Drive, etc.
  - `install_docker_cli.sh`
  - `install_terminator.sh`
- **System**: internal system configuration and fixes.
  - `setup_ufw.sh`: Configure Uncomplicated Firewall.
  - `clean_linux.sh`: System cleanup script.

## 🚀 Usage

### Windows
- **Batch Files (.bat)**: Double-click or run from Command Prompt. Most require **Run as Administrator**.
- **PowerShell (.ps1)**: Right-click and select "Run with PowerShell", or run from a PowerShell terminal. You may need to set execution policy:
  ```powershell
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

### Linux
- **Shell Scripts (.sh)**:
  Make the script executable:
  ```bash
  chmod +x ScriptName.sh
  ```
  Run it:
  ```bash
  ./ScriptName.sh
  ```

## ⚠️ Disclaimer

These scripts are provided "as is". specific scripts (especially those modifying system files or registry) should be reviewed before running. Always create a system restore point before running maintenance scripts.