# QR Scanner - Flutter

Scanner app that scans regular qr codes and crypto qr codes

## Contributing

Rules:

- Every code change has to be made only with Flutter code
- Never ignore results from `scripts/check.ps1`

Certain api keys has to be set in windows' enviornment variables:
`VIRUSTOTAL_API_KEY`, `TATUM_API_KEY`, and `GEMINI_API_KEY`

Valid app has to pass all of these:

```pwsh
dart format lib
dart analyze
dcm analyze lib
flutter test

```

this script `./scripts/check.ps1` runs these checks

Scrips were made with Powershell 7 in mind 

To build the app run the build scripts from `/scripts` folder
