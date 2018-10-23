# Scripts for ersky9x and Betaflight
Thanks @MikeBland for this <s>crap</s> awesome scripting language. JK, we all know 9XR Pro can't run Lua. <br>
Now supports FPort.
## What is already done
* PID control (Thanks @midelic, yout code formatting sucks. Basically this is his (or her?) file with readable indentation and stuff. Just look https://github.com/midelic/Ersky9x-Tx-bas-scripts)
* VTX control. Tested only with SmartAudio (the only thing I have), should work with Tramp, I hope it works with RTC6705. Even if it doesn't I won't be able to fix it because I don't have any RTC6705 hardware.
* Push RSSI value (Lua scripts can push real time as well but @MikeBland didn't give us a function for that). <b>You don't need this script if using FPort because FPort transmits RSSI itself.</b>
## What is yet to be done
* Crossfire support
* Push real time
* Many things when Mike releases a new stable version of ersky9x with many new features. I don't feel like using test versions although they're stable enough.
