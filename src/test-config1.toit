import gpio
import .gpio-genesis

blink-time := 500

main:
  print "\n" *5 + "Axiometa Genesis ESP32-S3:"

  user-led := gpio.Pin GPIO-LED --output
  task :: while true: 
    user-led.set 1
    sleep --ms=blink-time
    
    user-led.set 0
    sleep --ms=blink-time*3


  boot-button := gpio.Pin GPIO-BOOT --input --pull-up=true
  task :: while true:

    boot-button.wait_for 0
    blink-time = 125
    print "- boot button pressed"

    boot-button.wait_for 1
    blink-time = 500
    print "- boot button released"


  // ToggleSwitch AX22-0022 #8 uses port 2
  print "ToggleSwitch: gpio $(AX22.gpio 8 2)"
  toggle-switch := gpio.Pin (AX22.gpio 8 2) --input --pull-up=true
  task :: while true:
    if toggle-switch.get == 1:
      print "- toggle-switch off"
      toggle-switch.wait_for 0
    print "- toggle-switch on"
    toggle-switch.wait_for 1
 

