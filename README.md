niezbedne:
- nodejs
- android sdk, ios sdk etc.
- phonegap -> npm install -g phonegap
- ripple -> npm install -g ripple-emulator

instalacja na telefonie (emulatorze/symulatorze):
- phonegap platform add android [ios]
- phonegap plugin add https://github.com/JulianWielga/phonegap-googlemaps-plugin.git --variable API_KEY_FOR_ANDROID="..." --variable API_KEY_FOR_IOS="..."
- npm run build
- phonegap run android [ios]

podglad w przegladarce:
- npm run ripple