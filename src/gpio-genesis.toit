/*
Defines GPIO's of the AXIOMETA genesis system.
*/

GPIO-BOOT ::= 0   // identical with port 1 of module 1
GPIO-LED ::= 13

GPIO-SDA ::= 47   // I2C
GPIO-SCL ::= 48   // I2C

GPIO-MOSI ::= 11
GPIO-MISO ::= 12
GPIO-SCK ::= 13

GPIO-AX22 ::= [
  [5,0,46], [4,17,21], [3,16,38], [8,15,45],
  [9,6,42], [7,10,41], [2,18,40], [1,14,39]
  ]

GPIO-UART-TX ::= 43
GPIO-UART-RX ::= 44

GPIO-USB-M ::= 19
GPIO-USB-P ::= 20  


class AX22:
  static M1/int ::= 0
  static M2/int ::= 1
  static M3/int ::= 2
  static M4/int ::= 3
  static M5/int ::= 4
  static M6/int ::= 5
  static M7/int ::= 6
  static M8/int ::= 7

  static P1/int ::= 0
  static P2/int ::= 1
  static P3/int ::= 2

  // 1 <= module <= 8
  // 1 <= port <= 2
  static gpio module/int port/int -> int:
    if module < 1 or module > 8: throw "wrong module position"
    if port < 1 or port > 3: throw "wrong module port number"
    return GPIO-AX22[module - 1][port - 1]