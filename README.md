Niezbędne:
- nodejs
- android sdk, ios sdk etc.
- cordova 4.3.0 -> npm install -g cordova@4.3.0
- ripple -> npm install -g ripple-emulator

Pamiętać o dodaniu apikey do googlemaps w config.xml (android i ios) i w app/config/vars.yaml (js api v3)

Za pierwszym razem:
- npm install

Instalacja na telefonie (emulatorze/symulatorze):
- npm run build
- cordova platform add android [ios]
- cordova run android [ios]

Podgląd w przeglądarce:
- npm run ripple

