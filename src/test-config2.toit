import gpio
import gpio.pwm
import gpio.adc
import dhtxx
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


    
  // NeoPixelMatrix AX22-0028 #8
  NUM-PIXELS ::= 25
  pin := gpio.Pin (AX22.gpio 8 2) --output
  neopixels := PixelStrip.uart NUM-PIXELS --pin=pin --bytes-per-pixel=3
  r := ByteArray NUM-PIXELS
  g := ByteArray NUM-PIXELS
  b := ByteArray NUM-PIXELS

  task :: while true:
    (random 2 9).repeat:
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


  // KeyboardKey AX22-0027 #7
  print "KeyboardKey"
  keyboard-key := gpio.Pin (AX22.gpio 7 2) --input --pull-up=true
  keyboard-led := PixelStrip.uart 1 --pin=(gpio.Pin (AX22.gpio 7 3) --output) --bytes-per-pixel=3
  rgb := [ByteArray 1, ByteArray 1, ByteArray 1]
  3.repeat: rgb[it][0] = 255

  task :: while true:
    keyboard-led.output rgb[0] rgb[1] rgb[2]
    sleep --ms=500
    keyboard-led.output (ByteArray 1) (ByteArray 1) (ByteArray 1)
    sleep --ms=500

  task :: while true:
    keyboard-key.wait-for 0
    keyboard-key.wait-for 1
    print "- Keyboard key clicked" 
    r8 := random 1 7
    rgb[0][0] = (r8 & 1 != 0 ? 255 : 0)
    rgb[1][0] = (r8 & 2 != 0 ? 255 : 0)
    rgb[2][0] = (r8 & 4 != 0 ? 255 : 0)

    

  // D-Pad AX22-0016 #1 
  print "D-Pad"
  // NONE::=0; RIGHT::=1; CENTER::=2; DOWN::=3; UP::=4: LEFT ::=5
  BUTTON ::= ["", "▶", "●", "▼", "▲", "◀"]
  THRESHOLDS ::= [80,60,40,20,0]

  percent /int := 0
  dpad-state /int := 0
  adc := adc.Adc (gpio.Pin (AX22.gpio 1 1))
  get-percent := ( :: 
    percent = (adc.get --raw) * 100 / 4096; 
    percent
    )

  task :: while true:
    while (get-percent.call) > THRESHOLDS[0]: sleep --ms=100
    for dpad-state=0; dpad-state < BUTTON.size; dpad-state++:
      if percent >= THRESHOLDS[dpad-state]: break
    print "- D-Pad $BUTTON[dpad-state] clicked"
    while get-percent.call < THRESHOLDS[0]: sleep --ms=100  


  //