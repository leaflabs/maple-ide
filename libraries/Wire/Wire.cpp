/* *****************************************************************************
 * The MIT License
 *
 * Copyright (c) 2010 LeafLabs LLC.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * ****************************************************************************/

/**
 *  @brief Wire library, ported from Arduino. Provides a lean interface to i2c
 */

#include "Wire.h"
#include "wirish.h"

/* low level conventions:
   - SDA/SCL idle high (expected high) 
   - always start with i2c_delay rather than end
*/
static void i2c_start(Port port) {
  delayMicroseconds(i2c_delay);
  digitalWrite(port.sda,LOW);
  delayMicroseconds(i2c_delay);
  digitalWrite(port.scl,LOW);
}

static void i2c_stop(Port port) {
  delayMicroseconds(i2c_delay);
  digitalWrite(port.scl,HIGH);
  delayMicroseconds(i2c_delay);
  digitalWrite(port.sda,HIGH);
}

static boolean i2c_get_ack(Port port) {
  delayMicroseconds(i2c_delay);
  digitalWrite(port.sda,HIGH);
  delayMicroseconds(i2c_delay);
  digitalWrite(port.scl,HIGH);
  delayMicroseconds(i2c_delay);

  if (!digitalRead(port.sda)) {
    delayMicroseconds(i2c_delay);
    digitalWrite(port.scl,LOW);
    return true;
  } else {
    return false;
  }
}

static void i2c_send_ack(Port port) {
  delayMicroseconds(i2c_delay);
  digitalWrite(port.sda,LOW);
  delayMicroseconds(i2c_delay);
  digitalWrite(port.scl,HIGH);
  delayMicroseconds(i2c_delay);
  digitalWrite(port.scl,LOW);
}

static void i2c_send_nack(Port port) {
  delayMicroseconds(i2c_delay);
  digitalWrite(port.sda,HIGH);
  delayMicroseconds(i2c_delay);
  digitalWrite(port.scl,HIGH);
}

static uint8 i2c_shift_in(Port port) {
  uint8 data;

  int i;
  for (i=0;i<8;i++) {
    delayMicroseconds(i2c_delay);
    digitalWrite(port.scl,HIGH);
    delayMicroseconds(i2c_delay);
    data += digitalRead(port.sda) << (7-i);
    delayMicroseconds(i2c_delay);
    digitalWrite(port.scl,LOW);
  }

  return data;
}

static void i2c_shift_out(Port port, uint8 val) {
  int i;
  for (i=0;i<8;i++) {
    delayMicroseconds(i2c_delay);
    digitalWrite(port.sda, !!(val & (1 << (7 - i))));
    delayMicroseconds(i2c_delay);
    digitalWrite(port.scl, HIGH);
    delayMicroseconds(i2c_delay);
    digitalWrite(port.scl, LOW);
  }
}
