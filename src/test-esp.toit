import gpio

GPIO-BOOT ::= 0
GPIO-LED ::= 13

blink-time := 500

main:
  print "\n\nAxiometa Genesis ESP32-S3:"

  user-led := gpio.Pin GPIO-LED --output
  task :: while true: 
    user-led.set 1
    sleep --ms=blink-time
    
    user-led.set 0
    sleep --ms=blink-time*3

    print "- onboard LED white blink"


  boot-button := gpio.Pin GPIO-BOOT --input --pull-up=true
  task :: while true:

    boot-button.wait_for 0
    blink-time = 125
    print "\n- boot button pressed"

    boot-button.wait_for 1
    blink-time = 500
    print "\n- boot button released"
