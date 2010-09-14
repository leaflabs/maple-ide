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

TwoWire::rx_buf[WIRE_BUFSIZ];
TwoWire::rx_buf_idx = 0;
TwoWire::rx_buf_len = WIRE_BUFSIZ;

TwoWire::tx_addr = 0;
TwoWire::tx_buf[WIRE_BUFSIZ]
TwoWire::tx_buf_idx = 0;
TwoWire::tx_buf_len = WIRE_BUFSIZ;

TwoWire::TwoWire() {
}

/*
 * Sets pins SDA and SCL to OUPTUT_OPEN_DRAIN, joining I2C bus as
 * master..  This will steal them from you.  If you want them to be
 * some other pins, use begin(uint8, uint8);
 */
void TwoWire::begin() {
    begin(SDA, SCL);
}

/*
 * Joins I2C bus as master on given SDA and SCL pins.
 */
void TwoWire::begin(uint8 sda, uint8 scl) {
    port = Port {
        .scl = scl,
        .sda = sda
    };
    pinMode(sda, OUTPUT_OPEN_DRAIN);
    pinMode(scl, OUTPUT_OPEN_DRAIN);
    digitalWrite(sda, HIGH);
    digitalWrite(scl, HIGH);
}

void TwoWire::beginTransmission(uint8 slave_address) {
    tx_addr = slave_address;
    tx_buf_idx = 0;
    rx_buf_idx = 0;
}

void TwoWire::beginTransmission(int slave_address) {
    beginTransmission((uint8)slave_address);
}

uint8 TwoWire::endTransmission(void) {
    if (tx_buf_idx == tx_buf_len) return EDATA;

    // shift out the address we're transmitting to
    for (uint8 i = 0; i < tx_buf_idx; i++) {
        uint8 ret = writeOneByte(tx_addr, tx_buf[i]);
        if (ret) return ret;    // SUCCESS is 0
    }
    tx_buf_idx = 0;
    return SUCCESS;
}

// private methods

uint8 TwoWire::writeOneByte(uint8 address, uint8 byte) {
    i2c_start(port);

    i2c_shift_out(port, (tx_addr << 1) | I2C_WRITE);
    if (!i2c_get_ack(port)) return ENACKADDR;

    i2c_shift_out(port, byte);
    if (!i2c_get_ack(port)) return ENACKTRANS;

    i2c_stop(port);
    return SUCCESS;
}

uint8 TwoWire::readOneByte(uint8 address, uint8* byte) {
    i2c_start(port);

    i2c_shift_out(port, (rx_addr << 1) | I2C_READ);
    if (!i2c_get_ack(port)) return ENACKADDR;

    *byte = i2c_shift_in(port);

    i2c_send_nack(port);
    i2c_stop(port);

    return SUCCESS;      // no real way of knowing, but be optimistic!
}
