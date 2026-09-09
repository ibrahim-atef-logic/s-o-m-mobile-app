# Honeywell ScanPal EDA51

Hardware scans use the native decode engine (`honeywell_scanner`), not the
camera. Camera remains an optional fallback on the add-item sheet.

## Device setup

1. Settings → Honeywell Settings → Scanning → Internal Scanner → **Enabled**
2. Enable retail symbologies (EAN-13/8, UPC-A/E, Code 128, Code 39, Data
   Matrix, PDF417, Codabar, I2of5, Aztec).
3. Prefer **SDK / API** scan profile (not Keystroke-only if the SDK path is
   used). Keyboard wedge still works as a fallback while the barcode field is
   focused.
4. Confirm a raw decode in Honeywell’s scan test tool before testing this app.

## App logs (debug)

When a scan screen opens on a real EDA51 you should see:

```
HardwareScannerService: Initialized
HardwareScannerService: Listener attached
HardwareScannerService: isSupported=true
HardwareScannerService: startScanner() => true
HardwareScannerService: Scanner properties configured
HardwareScannerService: Decoded value="..." codeId="..."
```

On phones / emulators: `isSupported=false` — camera and the focused TextField
continue to work. No error UI.

## Permission

`com.honeywell.decode.permission.DECODE` is declared in AndroidManifest.
The Honeywell `.aar` lives in `android/honeywell` (required by the plugin).
