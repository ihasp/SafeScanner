# Crypto Scanner - Flutter

Scanner app that scans regular qr codes and crypto qr codes

## Contributing

Certain api keys has to be set in windows' enviornments:
`VIRUSTOTAL_API_KEY` and `TATUM_API_KEY`

Valid app has to pass all of these:

```pwsh
dart format lib
dart analyze
dcm analyze lib
flutter test

```

this script `./scripts/check.ps1` runs these checks

Update to Powershell 7 to use the scripts.

To build the app run the build scripts from `/scripts` folder
