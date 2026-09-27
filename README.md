# MyApp

A SwiftUI iOS app that is built **on a real macOS machine (GitHub Actions runner)** from
this Windows host. There is no Mac VM involved.

## Quick build

```powershell
.\build.ps1 -m "describe your change"
```

That commits, pushes, waits for the workflow, and drops the `.ipa` in `dist\`.
It takes about 60 seconds end to end. Everything is already configured.

## How the build works

1. You edit Swift source in `Sources/`.
2. `project.yml` (XcodeGen spec) is the source of truth for the Xcode project.
   The `.xcodeproj` is *generated* at build time and never committed.
3. Push to GitHub -> `build-ios.yml` runs on a `macos-15` runner.
4. XcodeGen generates the project, `xcodebuild archive` compiles it,
   and the `.app` is zipped into an `.ipa`.
5. Download the `MyApp-unsigned-ipa` artifact from the Actions run.

## Local use (on Windows)

You can edit files normally. There is no local Xcode step - the runner does the compile.

## Running the workflow

- Push to `main` (or just run `.\build.ps1`), or
- Actions tab -> `Build iOS App` -> **Run workflow**

Workflow runs on a `macos-15` runner and takes roughly 30-40 seconds.

## The .ipa is unsigned

No certificate is configured, so the build produces an unsigned `.ipa`. To install it on a
physical iPhone you must re-sign it with your own Apple ID using one of:

- Sideloadly (Windows)
- AltStore / AltServer
- ESign

To produce signed builds for TestFlight/App Store, see "Signing" below.

## Signing (optional, for TestFlight / App Store)

1. Apple Developer Program membership ($99/year) is required.
2. Generate a certificate signing request on Windows:
   ```
   openssl req -nodes -new -newkey rsa:2048 -keyout ios_dist.key -out ios_dist.csr
   ```
3. Upload the CSR at developer.apple.com -> Certificates -> Apple Distribution.
4. Export the resulting `.p12` and base64 it:
   ```
   openssl pkcs12 -export -out ios_dist.p12 -inkey ios_dist.key -in ios_dist.cer
   openssl base64 -in ios_dist.p12 -out ios_dist.p12.b64
   ```
5. Create a provisioning profile + App Store Connect API key.
6. Store `IOS_CERTIFICATE`, `IOS_CERTIFICATE_PASSWORD`, `IOS_PROVISIONING_PROFILE`,
   `TEAM_ID` as repository secrets, then add a signing step to the workflow.

## Renaming things

- App display name / target: `project.yml` -> `targets.MyApp`
- Bundle identifier: `project.yml` -> `PRODUCT_BUNDLE_IDENTIFIER`
- Minimum iOS version: `project.yml` -> `deploymentTarget`
