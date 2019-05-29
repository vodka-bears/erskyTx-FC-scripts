# Scripts for erskyTx and <s>Betaflight</s> Cleanflight derivatives
erskyTx has scripts.
## What do scripts do
* scripts/pid_vtx.bas can change pids, rates and VTX settings.
* scripts/MODEL/rssi.bas pushes RSSI value in background to the FC via SmartPort. You don't need it if you use FPort.
## How to install them
Copy <i>scripts</i> directory into root of your microSD card.
## How to use them
To run a regular script hold menu, select <b>Run Script</b> and choose a script from the list. To activate a model script, set Model settings -> General -> Bg Script. To activate a telemetry script... ah, forget it I haven't written any yet.
## Wow, what else will be here
I plan to modify rssi.bas for it to push a RTC value from the radio to the FC. If I buy a Crossfire, I'll add support. There's also a plan for a killer-feature with Bluetooth, but alright then, i'll keep my secrets.
## I want a new feature or something is wrong with existing features
Open an issue or a pull request, or visit openrcforums.com
## Who to say thanks to
* @MikeBland for erskyTx and the script engine
* @Midelic for the first implementation of this. He also has a repo of scripts. https://github.com/midelic/Ersky9x-Tx-bas-scripts
