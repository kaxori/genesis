import gpio
import gpio.pwm
import pixel_strip show *
import bitmap show bytemap-zap
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
 


  // Buzzer AX22-0012 #6 
  print "Buzzer: gpio $(AX22.gpio 6 2)"
  buzzer := gpio.Pin (AX22.gpio 6 2)

  buzzer-beep := (:: | freq duration |
    generator := pwm.Pwm --frequency=freq
    channel := generator.start buzzer --duty-factor=0.5
    sleep --ms=duration
    channel.close
    generator.close
    )

  if false:
    buzzer-beep.call 2000 150
    sleep --ms= 50
    buzzer-beep.call 2000 150
    sleep --ms= 50
    buzzer-beep.call 2000 150
    sleep --ms= 50
    buzzer-beep.call 400 600

  
  // Traffic Light AX22-0024 #4
  print "Traffic light: gpio $(GPIO-AX22[3])"
  traffic-light := [
    gpio.Pin (AX22.gpio 4 1) --output, // red
    gpio.Pin (AX22.gpio 4 2) --output, // yellow
    gpio.Pin (AX22.gpio 4 3) --output // green
    ]


  task :: while true:
    // red
    traffic-light[0].set 1
    sleep --ms=3000

    // yellow red
    traffic-light[1].set 1
    sleep --ms=1000

    // green
    traffic-light[0].set 0
    traffic-light[1].set 0
    traffic-light[2].set 1
    sleep --ms=2000

    // yellow
    traffic-light[2].set 0
    traffic-light[1].set 1
    sleep --ms=1000
    traffic-light[1].set 0


  // RGB-Led AX22-0006 #3
  print "RGB-LED: gpio $(GPIO-AX22[2])"
  rgb-led := [
    gpio.Pin (AX22.gpio 3 1) --output, // red
    gpio.Pin (AX22.gpio 3 2) --output, // green
    gpio.Pin (AX22.gpio 3 3) --output  // blue
    ]

  task :: while true:
    8.repeat:
      rgb-led[0].set (it & 1 != 0 ? 1 : 0)
      rgb-led[1].set (it & 2  != 0 ? 1 : 0)
      rgb-led[2].set (it & 4 != 0  ? 1 : 0)
      sleep --ms=500

    
  // NeoPixelMatrix AX22-0028 #5
  NUM-PIXELS ::= 25
  pin := gpio.Pin (AX22.gpio 5 2) --output
  neopixels := PixelStrip.uart NUM-PIXELS --pin=pin --bytes-per-pixel=3
  r := ByteArray NUM-PIXELS
  g := ByteArray NUM-PIXELS
  b := ByteArray NUM-PIXELS

  task :: while true:
    (random 1 8).repeat:
      p := random NUM-PIXELS
      r[p] = random 1 256
      g[p] = random 1 256
      b[p] = random 1 256
      neopixels.output r g b
    
    256.repeat: 
      NUM-PIXELS.repeat:
        r[it] = max (r[it] - 1) 0
        g[it] = max (g[it] - 1) 0
        b[it] = max (b[it] - 1) 0

      neopixels.output r g b
      sleep --ms=1

