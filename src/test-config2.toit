import gpio
import gpio.pwm
import gpio.adc
import gpio
import i2c
import dhtxx
import pixel_strip show *
import bitmap show bytemap-zap
import .gpio-genesis


import .vl53l4.vl53l4cd show *




blink-time := 500

main:
  print "\n" *5 + "Axiometa Genesis ESP32-S3:"

  // onboard led
  user-led := gpio.Pin GPIO-LED --output
  task :: while true: 
    user-led.set 1
    sleep --ms=blink-time
    
    user-led.set 0
    sleep --ms=blink-time*3


  // boot button
  boot-button := gpio.Pin GPIO-BOOT --input --pull-up=true
  task :: while true:
    boot-button.wait_for 0
    blink-time = 125
    print "- boot button pressed"

    boot-button.wait_for 1
    blink-time = 500
    print "- boot button released"



  // =======================================================
  // Time of flight sensor ToF 0015 AX022-0015 #5 2 I2C
  print "ToF VL53L0X"

  //data := gpio.Pin (AX22.gpio 5 2)
  gpio-sda := gpio.Pin GPIO-SDA
  gpio-scl := gpio.Pin GPIO-SCL
  i2c-bus := i2c.Bus --sda=gpio-sda --scl=gpio-scl --frequency=100_000


  VL53_ADDR ::= 41
  //VL53_XSHUNT_1 ::= 47
  //VL53_INT_1 ::= 21

  xshunt-pin := (AX22.gpio 5 2)
  sensor := VL53L4CD i2c-bus "VL53L" xshunt-pin VL53-ADDR
  
  sensor.xshut-pin_.set 1
  print "Scan before: $i2c-bus.scan"
  print "Sensor ID: $sensor.get-id Module Type: $sensor.get-module-type"
  //sensor.init


  5.repeat:
    print "\n#$it"
    sensor.enable

    //sensor.set-mode MODE-DEFAULT
    //sensor.start-temperature-update
    //threashold-mm := sensor.get-height-trigger-threshold 25 10
    //sensor.set-mode MODE-LOW-POWER
    sensor.set-signal-threshold 500
    //sensor.set-sigma-threshold 10

    result/Result := sensor.get-result
    print "[$sensor.name]: Distance: $(%4d result.distance-mm) mm [$result.get-status-string]" 
    print "Clearing interrupt for $sensor.name"
    sensor.clear-interrupt
    sleep --ms=1000




  //
  print "WAIT"
  while true: sleep --ms=1000


  // =======================================================
  // MicroPhone AX22-0009 #2 1
  if false:
    print "MicroPhone"
    mic := adc.Adc (gpio.Pin (AX22.gpio 2 1))
    peak := 0
    task :: while true:
      value := (mic.get --raw )
      peak = max peak value
      if value > 2300:
        print "- noise $value"
      sleep --ms=10

    task :: while true:
      sleep --ms=5000
      print "peak: $peak"
      peak = 0



    
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
  dpad-value := adc.Adc (gpio.Pin (AX22.gpio 1 1))
  get-percent := ( :: 
    percent = (dpad-value.get --raw) * 100 / 4096; 
    percent
    )

  task :: while true:
    while (get-percent.call) > THRESHOLDS[0]: sleep --ms=100
    for dpad-state=0; dpad-state < BUTTON.size; dpad-state++:
      if percent >= THRESHOLDS[dpad-state]: break
    print "- D-Pad $BUTTON[dpad-state] clicked"
    while get-percent.call < THRESHOLDS[0]: sleep --ms=100  



  // ======== vibration ============

  // Vibration Switch AX22-0025 #4 2
  print "Vibration switch"
  vibration-switch := gpio.Pin (AX22.gpio 4 2) --input --pull-up=true
  task :: while true:
    vibration-switch.wait-for 0
    vibration-switch.wait-for 1
    print "- vibration" 
    sleep --ms=20

  // VibrationMotor AX22-0013 #3 2
  print "Vibration motor"
  vibration-motor := gpio.Pin (AX22.gpio 3 2) --output
  vibrate := (:: |  duration |
      vibration-motor.set 1
      sleep --ms=duration
      vibration-motor.set 0
      sleep --ms=duration
    )

  1.repeat: vibrate.call (random 150 500)


