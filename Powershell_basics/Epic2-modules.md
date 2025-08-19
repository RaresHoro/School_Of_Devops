# Epic 2: Modules

This document describes the steps required to work with PowerShell modules in a restricted environment (ThreatLocker blocking execution from OneDrive and default TEMP).

---

## Task 2.1. Find out the installed modules and the loaded modules in your PowerShell instance

- **List installed modules:**
  ```powershell
  Get-InstalledModule
  ```


* **List loaded modules in current session:**

  ```powershell
  Get-Module
  ```

* **List all available modules (installed but not necessarily loaded):**

  ```powershell
  Get-Module -ListAvailable
  ```

---

## Task 2.2. Install PS Modules

* **Install PSScriptAnalyzer for your user only (CurrentUser scope):**

  ```powershell
  Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force
  ```

* **Install PSWindowsUpdate for all users (requires Administrator):**

  ```powershell
  Install-Module -Name PSWindowsUpdate -Scope AllUsers -Force
  ```

  > ⚠️ If you do not have admin rights, use `-Scope CurrentUser` or a custom path.

---

## Task 2.3. Load the module PSScriptAnalyzer. Is it loaded/imported?

* **Load the module:**

  ```powershell
  Import-Module PSScriptAnalyzer
  ```

* **Check if loaded:**

  ```powershell
  Get-Module PSScriptAnalyzer
  ```

* **Quick test:**

  ```powershell
  Invoke-ScriptAnalyzer -ScriptDefinition 'Write-Host "Hello"'
  ```

---

## Task 2.4. Execute required actions to run `ConvertTo-Yaml -Data @{a = 1}` successfully

1. **Problem:**
   The command `ConvertTo-Yaml` is not native to PowerShell. It comes from the `powershell-yaml` module.
   Default installation places modules in OneDrive or `%TEMP%`, which are blocked by ThreatLocker.

2. **Solution:**

   * Redirect TEMP/TMP to a custom folder:

     * Create folder
     * Open **Edit environment variables for your account** in Windows.
     * Set both `TEMP` and `TMP` to:

       ```
       C:\Endava\EndevLocal\Temp
       ```
     * Restart PowerShell.

   * Save the module to the custom TEMP:

     ```powershell
     Save-Module -Name powershell-yaml -Path $env:TEMP -Force
     ```

   * Import the module (bypassing alias conflicts and execution policy):

     ```powershell
     Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
     $mod = Get-ChildItem (Join-Path $env:TEMP "powershell-yaml") -Directory |
            Sort-Object Name -Descending | Select-Object -First 1
     Import-Module (Join-Path $mod.FullName "powershell-yaml.psd1") -Force -DisableNameChecking
     ```

   * Run the test:

     ```powershell
     ConvertTo-Yaml -Data @{a = 1}
     ```

   ✅ Expected output:

   ```yaml
   a: 1
   ```

---

## Task 2.5. Unload powershell-yaml

* **Remove the module:**

  ```powershell
  Remove-Module powershell-yaml -Force
  ```

* **Verify:**

  ```powershell
  Get-Module powershell-yaml
  ```

* **Optional cleanup of functions/aliases:**

  ```powershell
  Remove-Item Function:\ConvertTo-Yaml -ErrorAction SilentlyContinue
  Remove-Item Function:\ConvertFrom-Yaml -ErrorAction SilentlyContinue
  Remove-Item Alias:\cty -ErrorAction SilentlyContinue
  Remove-Item Alias:\cfy -ErrorAction SilentlyContinue
  ```

---

## Task 2.6. Delete/Uninstall PSWindowsUpdate

* **Check installation:**

  ```powershell
  Get-InstalledModule PSWindowsUpdate
  ```

* **Uninstall (if installed via PowerShellGet):**

  ```powershell
  Uninstall-Module -Name PSWindowsUpdate -AllVersions -Force
  ```

* **Manual removal (if necessary):**

  * Delete folder from:

    * For all users:
      `C:\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate`
    * For current user:
      `C:\Users\<you>\Documents\WindowsPowerShell\Modules\PSWindowsUpdate`
      (sometimes redirected under OneDrive)

* **Verify removal:**

  ```powershell
  Get-Module PSWindowsUpdate -ListAvailable
  ```

---

## Why we changed TEMP/TMP

By default, PowerShell modules for CurrentUser scope are installed under:

```
C:\Users\<username>\OneDrive - Company\Documents\WindowsPowerShell\Modules
```

In this environment, ThreatLocker blocked execution of scripts/DLLs from OneDrive and also from the default `%TEMP%` folder.
To bypass this, we created a custom folder

Then we redirected the environment variables **TEMP** and **TMP** to this path.
This ensures modules saved via `Save-Module` or temporary scripts run from a location not blocked by security tools, allowing successful installation and execution.

---

