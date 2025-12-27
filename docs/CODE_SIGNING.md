# Code Signing Setup Guide

This document explains how to set up code signing for Lighten Up across different platforms.

## Why Code Signing?

**Benefits:**

- ✅ Eliminates "Unknown Publisher" warnings
- ✅ Enables Tauri auto-updater functionality
- ✅ Builds trust with enterprise/healthcare customers
- ✅ Required for HIPAA compliance (software integrity)
- ✅ Prevents tampering and malware warnings

**When to implement:**

- **Now (Development):** Not needed
- **Beta Testing:** Optional (helps with trust)
- **Production Release:** Highly recommended
- **Enterprise/Healthcare:** Required

---

## Tauri Updater Signing (Cross-Platform)

Tauri has its own lightweight signing system for secure auto-updates. This is **free** and **platform-agnostic**.

### Step 1: Generate Signing Keys

```bash
# Generate a new keypair
pnpm tauri signer generate -w ~/.tauri/lighten-up.key

# Output will show:
# Private key: dW50cnVzdGVkIGNvbW1lbnQ6IHJzaWduIGVuY3J5cHRlZCBzZWNyZXQga2V5...
# Public key: dW50cnVzdGVkIGNvbW1lbnQ6IG1pbmlzaWduIHB1YmxpYyBrZXk6IEZCNUI1...
# Password: <randomly generated password>
```

### Step 2: Add to GitHub Secrets

1. Go to your GitHub repository
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add two secrets:

**Secret 1:**

- Name: `TAURI_SIGNING_PRIVATE_KEY`
- Value: The private key string (starts with `dW50cnVzdGVk...`)

**Secret 2:**

- Name: `TAURI_SIGNING_PRIVATE_KEY_PASSWORD`
- Value: The password shown in output

### Step 3: Update tauri.conf.json

Add the public key to your Tauri config:

```json
{
  "bundle": {
    "active": true,
    "targets": ["deb", "rpm"],
    "publisher": "Your Company Name",
    "icon": [...],
    "updater": {
      "active": true,
      "endpoints": ["https://yourdomain.com/updates/{{target}}/{{current_version}}"],
      "dialog": true,
      "pubkey": "YOUR_PUBLIC_KEY_HERE"
    }
  }
}
```

### Step 4: Update GitHub Actions Workflow

Uncomment the signing environment variables in `.github/workflows/build.yml`:

```yaml
- name: Build Tauri app
  run: pnpm tauri build --target ${{ matrix.target }}
  env:
    TAURI_SIGNING_PRIVATE_KEY: ${{ secrets.TAURI_SIGNING_PRIVATE_KEY }}
    TAURI_SIGNING_PRIVATE_KEY_PASSWORD: ${{ secrets.TAURI_SIGNING_PRIVATE_KEY_PASSWORD }}
```

**Important:** The public key goes in the config file (safe to commit), the private key stays in GitHub secrets (never commit).

---

## Windows Code Signing (Authenticode)

Windows code signing prevents SmartScreen warnings and shows your company as the verified publisher.

### Requirements

- Windows code signing certificate (~$100-400/year)
- Certificate providers: DigiCert, Sectigo, SSL.com, GlobalSign

### Step 1: Purchase Certificate

**Recommended providers for businesses:**

- **DigiCert** ($474/year) - Industry standard, high trust
- **Sectigo** ($199/year) - Good balance of price/trust
- **SSL.com** ($299/year) - Good for small businesses

**For open source/individuals:**

- Consider Microsoft Store distribution (free signing)
- Or self-sign for internal use only

### Step 2: Export Certificate

After purchasing, you'll receive a `.pfx` or `.p12` file with a password.

### Step 3: Add to GitHub Secrets

Convert certificate to base64:

```bash
# On Linux/macOS
cat certificate.pfx | base64 -w 0 > certificate.txt

# On Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("certificate.pfx")) > certificate.txt
```

Add to GitHub Secrets:

- Name: `WINDOWS_CERTIFICATE`
- Value: Contents of `certificate.txt`

- Name: `WINDOWS_CERTIFICATE_PASSWORD`
- Value: Your certificate password

### Step 4: Update GitHub Actions Workflow

Add Windows signing step:

```yaml
- name: Import Windows certificate
  if: matrix.platform == 'windows-latest'
  run: |
    $pfxPath = "certificate.pfx"
    $base64 = "${{ secrets.WINDOWS_CERTIFICATE }}"
    [System.IO.File]::WriteAllBytes($pfxPath, [System.Convert]::FromBase64String($base64))
    Import-PfxCertificate -FilePath $pfxPath -CertStoreLocation Cert:\CurrentUser\My -Password (ConvertTo-SecureString "${{ secrets.WINDOWS_CERTIFICATE_PASSWORD }}" -AsPlainText -Force)
  shell: pwsh

- name: Build Tauri app (Windows)
  if: matrix.platform == 'windows-latest'
  run: pnpm tauri build --target ${{ matrix.target }}
  env:
    TAURI_SIGNING_PRIVATE_KEY: ${{ secrets.TAURI_SIGNING_PRIVATE_KEY }}
    TAURI_SIGNING_PRIVATE_KEY_PASSWORD: ${{ secrets.TAURI_SIGNING_PRIVATE_KEY_PASSWORD }}
    WINDOWS_SIGN_THUMBPRINT: ${{ secrets.WINDOWS_SIGN_THUMBPRINT }}
```

### Step 5: Update tauri.conf.json for Windows

```json
{
  "bundle": {
    "windows": {
      "certificateThumbprint": null,
      "digestAlgorithm": "sha256",
      "timestampUrl": "http://timestamp.digicert.com"
    }
  }
}
```

---

## macOS Code Signing & Notarization

macOS requires both code signing AND notarization by Apple for apps distributed outside the App Store.

### Requirements

- Apple Developer account ($99/year)
- macOS machine (for initial certificate setup)
- Xcode or Xcode Command Line Tools

### Step 1: Join Apple Developer Program

1. Go to https://developer.apple.com/programs/
2. Enroll ($99/year)
3. Complete verification (1-2 days)

### Step 2: Create App-Specific Password

1. Go to https://appleid.apple.com/
2. Sign in with your Apple ID
3. Navigate to **Security** → **App-Specific Passwords**
4. Click **Generate Password**
5. Label it "Lighten Up Notarization"
6. Save the generated password (you'll need it for GitHub)

### Step 3: Create Certificates in Xcode

On your macOS machine:

1. Open **Xcode** → **Settings** → **Accounts**
2. Add your Apple ID
3. Select your team → **Manage Certificates**
4. Click **+** → **Developer ID Application**
5. This creates and installs the certificate

### Step 4: Export Certificates for CI

```bash
# Export certificate to file
security find-identity -v -p codesigning

# Note the identity hash (e.g., "ABC123DEF456...")
# Export with that identity
security export -k login.keychain -t identities -f pkcs12 -o certificate.p12
# You'll be prompted to set an export password

# Convert to base64
cat certificate.p12 | base64 -w 0 > certificate.txt
```

### Step 5: Add to GitHub Secrets

- Name: `APPLE_CERTIFICATE`
- Value: Contents of `certificate.txt`

- Name: `APPLE_CERTIFICATE_PASSWORD`
- Value: Export password you set

- Name: `APPLE_ID`
- Value: Your Apple ID email

- Name: `APPLE_PASSWORD`
- Value: App-specific password from Step 2

- Name: `APPLE_TEAM_ID`
- Value: Your team ID (find at https://developer.apple.com/account)

### Step 6: Update GitHub Actions Workflow

```yaml
- name: Import Apple certificate
  if: matrix.platform == 'macos-latest'
  run: |
    CERTIFICATE_PATH=$RUNNER_TEMP/certificate.p12
    KEYCHAIN_PATH=$RUNNER_TEMP/app-signing.keychain-db
    KEYCHAIN_PASSWORD=$(openssl rand -base64 32)

    echo -n "${{ secrets.APPLE_CERTIFICATE }}" | base64 --decode -o $CERTIFICATE_PATH

    security create-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
    security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
    security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH

    security import $CERTIFICATE_PATH -P "${{ secrets.APPLE_CERTIFICATE_PASSWORD }}" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
    security list-keychain -d user -s $KEYCHAIN_PATH

    rm $CERTIFICATE_PATH

- name: Build and sign Tauri app (macOS)
  if: matrix.platform == 'macos-latest'
  run: pnpm tauri build --target ${{ matrix.target }}
  env:
    APPLE_CERTIFICATE: ${{ secrets.APPLE_CERTIFICATE }}
    APPLE_CERTIFICATE_PASSWORD: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}
    APPLE_ID: ${{ secrets.APPLE_ID }}
    APPLE_PASSWORD: ${{ secrets.APPLE_PASSWORD }}
    APPLE_TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
    TAURI_SIGNING_PRIVATE_KEY: ${{ secrets.TAURI_SIGNING_PRIVATE_KEY }}
    TAURI_SIGNING_PRIVATE_KEY_PASSWORD: ${{ secrets.TAURI_SIGNING_PRIVATE_KEY_PASSWORD }}
```

### Step 7: Update tauri.conf.json for macOS

```json
{
  "bundle": {
    "macOS": {
      "signingIdentity": "Developer ID Application: Your Company Name (TEAM_ID)",
      "entitlements": null,
      "exceptionDomain": null,
      "frameworks": [],
      "providerShortName": null
    }
  }
}
```

---

## Linux (No Code Signing Required)

Linux distributions use package repository signing rather than individual app signing. No additional setup needed.

**For enterprise Linux deployments:**

- Sign your deb/rpm packages with your organization's GPG key
- Distribute via your own package repository
- Users add your repository's public key to their trusted keys

---

## Testing Signed Builds

### Windows

```powershell
# Check signature
Get-AuthenticodeSignature .\lighten-up.exe

# Should show: SignatureType = Authenticode, Status = Valid
```

### macOS

```bash
# Check code signature
codesign -dv --verbose=4 lighten-up.app

# Check notarization
spctl -a -vv lighten-up.app

# Should show: accepted, source=Notarized Developer ID
```

### Tauri Updater

```bash
# Verify signed update
pnpm tauri signer verify <path-to-update-file> <path-to-signature>
```

---

## Cost Summary

| Platform      | Cost      | Frequency | Required For                   |
| ------------- | --------- | --------- | ------------------------------ |
| Tauri Updater | **FREE**  | One-time  | Auto-updates                   |
| Windows       | $100-$474 | Annual    | Trusted installer              |
| macOS         | $99       | Annual    | Distribution outside App Store |
| Linux         | **FREE**  | -         | -                              |
| iOS           | $99\*     | Annual    | App Store                      |
| Android       | $25       | One-time  | Google Play Store              |

\* _Same Apple Developer account for macOS and iOS_

**Recommended priority:**

1. Tauri updater signing (free, enables updates)
2. Windows Authenticode (most important for enterprise)
3. macOS notarization (if targeting Mac users)
4. Mobile store signing (when mobile apps ready)

---

## Troubleshooting

### "Certificate not found" on Windows

- Ensure certificate is imported to `Cert:\CurrentUser\My`
- Check thumbprint matches in config
- Verify certificate hasn't expired

### "Unable to verify" on macOS

- Ensure you're using "Developer ID Application" not "Mac Development"
- Check that notarization completed successfully
- May take 10-30 minutes for notarization to complete

### Tauri updater signature mismatch

- Ensure public key in `tauri.conf.json` matches generated private key
- Verify you're using the correct password
- Check that signature file was generated during build

### GitHub Actions certificate import fails

- Verify base64 encoding doesn't have line breaks
- Check that secrets are set correctly
- Ensure certificate password is correct

---

## Security Best Practices

1. **Never commit certificates or private keys** to version control
2. **Rotate signing keys annually** or if compromised
3. **Use strong passwords** for certificate protection
4. **Limit access** to GitHub secrets to maintainers only
5. **Enable 2FA** on Apple/Microsoft developer accounts
6. **Keep certificates backed up** securely (encrypted storage)
7. **Document certificate expiration dates** and set renewal reminders

---

## HIPAA Compliance Notes

For healthcare deployments, code signing helps meet HIPAA requirements:

- **Integrity (§164.312(c)(1))**: Proves software hasn't been altered
- **Authentication (§164.312(d))**: Verifies software source
- **Audit Controls (§164.312(b))**: Timestamp services provide audit trail

**Recommendation:** Implement full code signing (Windows + macOS + Tauri) before deploying to healthcare environments.

---

## Resources

- [Tauri Updater Documentation](https://v2.tauri.app/plugin/updater/)
- [Tauri Code Signing Guide](https://v2.tauri.app/distribute/sign/)
- [Windows Code Signing](https://learn.microsoft.com/en-us/windows/win32/seccrypto/cryptography-tools)
- [Apple Notarization](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [DigiCert Code Signing](https://www.digicert.com/code-signing)

---

**Last Updated:** 2025-12-25  
**Lighten Up Version:** 0.1.0
