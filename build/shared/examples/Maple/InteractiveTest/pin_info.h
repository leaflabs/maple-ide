/*
  Defines arrays for the PWM- and ADC-capable pins on each board, as
  well as providing an array containing pins to leave alone (because
  they're connected to the LED or the USB data lines).
 */

#include "wirish.h"

#if defined(BOARD_maple) || defined(BOARD_maple_RET6)
const uint8 pwm_pins[] =
    {0, 1, 2, 3, 5, 6, 7, 8, 9, 11, 12, 14, 24, 25, 27, 28};
const uint8 adc_pins[] =
    {0, 1, 2, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20, 27, 28};
const uint8 pins_to_skip[] = {BOARD_LED_PIN};

#elif defined(BOARD_maple_mini)
#define USB_DP 23
#define USB_DM 24
const uint8 pwm_pins[] = {3, 4, 5, 8, 9, 10, 11, 15, 16, 25, 26, 27};
const uint8 adc_pins[] = {3, 4, 5, 6, 7, 8, 9, 10, 11, 33}; // NB: 33 is LED
const uint8 pins_to_skip[] = {BOARD_LED_PIN, USB_DP, USB_DM};

#elif defined(BOARD_maple_native)
const uint8 pwm_pins[] = {
    12, 13, 14, 15, 22, 23, 24, 25, 37, 38, 45, 46, 47, 48, 49, 50, 53, 54};
const uint8 adc_pins[] = {
    6, 7, 8, 9, 10, 11,
    /* FIXME These are on ADC3, which lacks support:
       39, 40, 41, 42, 43, 45, */
    46, 47, 48, 49, 50, 51, 52, 53, 54};
const uint8 pins_to_skip[] = {BOARD_LED_PIN};

#else
#error "Board type has not been selected correctly."
#endif
