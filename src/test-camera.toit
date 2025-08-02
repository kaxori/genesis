/*
  Camera Remote Control :

  Modules used
  M1: 
  M2: 
  M3: 
  M4: 

  M5: 
  M6: 
  M7; Keyboard key, Led
  M8: 
*/


import gpio
import pixel_strip show *
import bitmap show bytemap-zap
import .gpio-genesis
import .ble-camera

blink-time := 500

ble-camera /BleCamera := ?

main:
  print "\n" *5 + "Axiometa Genesis ESP32-S3:"

  // animate onboard LED
  user-led := gpio.Pin GPIO-LED --output
  task :: while true: 
    user-led.set 1
    sleep --ms=blink-time
    
    user-led.set 0
    sleep --ms=blink-time*3


  ble-camera = BleCamera "BLE Camera"


  // boot button
  boot-button := gpio.Pin GPIO-BOOT --input --pull-up=true
  task :: while true:
    boot-button.wait_for 0

    ble-camera.trigger
    blink-time = 125
    print "- boot button pressed"

    boot-button.wait_for 1
    blink-time = 500
    print "- boot button released"



  // KeyboardKey AX22-0027 #7
  print "init KeyboardKey"

  keyboard-led := PixelStrip.uart 1 --pin=(gpio.Pin (AX22.gpio 7 3) --output) --bytes-per-pixel=3
  rgb := [ByteArray 1, ByteArray 1, ByteArray 1]
  3.repeat: rgb[it][0] = 8

  task :: while true:
    keyboard-led.output (rgb[0]) (rgb[1]) (rgb[2])
    sleep --ms=100

  setcolor := ( :: | r g b |
    rgb[0][0] = r
    rgb[1][0] = g
    rgb[2][0] = b
    )

  
  keyboard-key := gpio.Pin (AX22.gpio 7 2) --input --pull-up=true

  task :: while true:
    keyboard-key.wait-for 0

    ble-camera.trigger
    setcolor.call 0 0 255
    sleep --ms=50

    keyboard-key.wait-for 1
    setcolor.call 0 0 4
    

//EOF.