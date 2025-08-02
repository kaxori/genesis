import ble
import encoding.hex

class BleCamera:

  trigger-count /int := 0
  name_/string := "BLE Camera"
  report-char := ?

  constructor .name_:
    adapter := ble.Adapter
    peripheral := adapter.peripheral --bonding=true
    hid-service := peripheral.add-service HID-SERVICE-UUID
    
    report-map-char := hid-service.add-read-only-characteristic
      HID-REPORT-MAP-CHARACTERISTIC-UUID
      --value=HID-REPORT-MAP
    
    info-char := hid-service.add-read-only-characteristic
      HID-INFORMATION-CHARACTERISTIC-UUID
      --value=HID-INFORMATION
    
    control-point-char := hid-service.add-write-only-characteristic
      HID-CONTROL-POINT-CHARACTERISTIC-UUID
      --requires-response=false    

    report-char = hid-service.add-notification-characteristic
      HID-REPORT-CHARACTERISTIC-UUID
    
    peripheral.deploy
    
    advertisement := ble.Advertisement 
      --name=name_
      --services=[HID-SERVICE-UUID]
      --flags=(ble.BLE-CONNECT-MODE-DIRECTIONAL | ble.BLE-ADVERTISE-FLAGS-BREDR-UNSUPPORTED)
    
    peripheral.start-advertise advertisement --allow-connections
    

  trigger duration-ms=5:    
    trigger-count += 1
    report-char.write volume-up-report
    sleep --ms=duration-ms
    report-char.write release-report




//-------------------------
  static HID-SERVICE-UUID ::= ble.BleUuid "1812"
  static HID-REPORT-CHARACTERISTIC-UUID ::= ble.BleUuid "2A4D"
  static HID-REPORT-MAP-CHARACTERISTIC-UUID ::= ble.BleUuid "2A4B"
  static HID-INFORMATION-CHARACTERISTIC-UUID ::= ble.BleUuid "2A4A"
  static HID-CONTROL-POINT-CHARACTERISTIC-UUID ::= ble.BleUuid "2A4C"

  static HID-REPORT-MAP ::= #[
    0x05, 0x0C,        // Usage Page (Consumer)
    0x09, 0x01,        // Usage (Consumer Control)
    0xA1, 0x01,        // Collection (Application)
    0x85, 0x01,        // Report ID (1)
    0x19, 0x00,        // Usage Minimum (0)
    0x2A, 0x3C, 0x02,  // Usage Maximum (572)
    0x15, 0x00,        // Logical Minimum (0)
    0x26, 0x3C, 0x02,  // Logical Maximum (572)
    0x95, 0x01,        // Report Count (1)
    0x75, 0x10,        // Report Size (16)
    0x81, 0x00,        // Input (Data,Array,Abs)
    0xC0               // End Collection
  ]

  static HID-INFORMATION ::= #[0x11, 0x01, 0x00, 0x03]

  static VOLUME-UP-CODE ::= 0x00E9
  static NO-KEY-CODE ::= 0x0000
  static volume-up-report ::= #[0x01, VOLUME-UP-CODE & 0xFF, (VOLUME-UP-CODE >> 8) & 0xFF]
  static release-report ::= #[0x01, NO-KEY-CODE & 0xFF, (NO-KEY-CODE >> 8) & 0xFF]
  
//EOF.