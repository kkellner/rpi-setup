#!/usr/bin/python3

# interrupt-based GPIO example using LEDs and pushbuttons

import RPi.GPIO as GPIO
import time
import threading
import logging, logging.handlers


logger = logging.getLogger('monitor')

# Docs: https://docs.python.org/3/library/logging.html
# Docs on config: https://docs.python.org/3/library/logging.config.html
FORMAT = '%(asctime)-15s %(threadName)-10s %(levelname)6s %(message)s'
logging.basicConfig(level=logging.NOTSET, format=FORMAT)

GPIO.setmode(GPIO.BOARD)

BTN_G = 11 # G17

GPIO.setwarnings(True) # because I'm using the pins for other things too!
GPIO.setup([BTN_G], GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
#GPIO.setup([LED_G, LED_R, LED_Y, LED_B], GPIO.OUT, initial=GPIO.HIGH)

def handle(pin):
    # light corresponding LED when pushbutton of same color is pressed
    #GPIO.output(btn2led[pin], not GPIO.input(pin))

    if GPIO.input(BTN_G):
        logger.info("Rising edge detected")
    else:
        logger.info("Falling edge detected")


GPIO.add_event_detect(BTN_G, GPIO.BOTH, handle)

logger.info("Monitor for pin state change")


try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
        logger.info("Exit")
        GPIO.cleanup()
