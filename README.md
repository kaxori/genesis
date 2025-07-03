# Axiometa genesis

Collected findings from experiments with axiometa genesis board.

Environment: PC Win11, Powershell, Visual Studio Code
Controller: ESP32-S3
Programming: Toit jaguar


## 1. setup controller with Toit jaguar
- Connect USB from ESP32-S3 OTG to PC
- press BOOT button
- flash **jaguar**: `jag flash -cesp32s3 -p COM8 --name GENESIS`
- check flashing: `jag scan GENESIS`
```
    Scanning for device with name: 'GENESIS'
    address: http://192.168.178.56:9000
    chip: esp32s3
    id: 00014523-f5c9-4595-86a9-930cbe63b6ca
    name: GENESIS
    proxied: false
    sdkVersion: v2.0.0-alpha.184
    wordSize: 4
```
- run **example**: `jag run .\test-esp.toit`
  - onboard led **blinks slowly**
  - if boot button is pressed then the led **blinks faster**
- monitor output: `jag monitor -a -p COM8`

## 2. checking AX22 modules

### 