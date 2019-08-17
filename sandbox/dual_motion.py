#!/usr/bin/python3

# interrupt-based GPIO example using LEDs and pushbuttons

import RPi.GPIO as GPIO
import time
import threading
import logging, logging.handlers
import neopixel
import board

logger = logging.getLogger('monitor')

# Docs: https://docs.python.org/3/library/logging.html
# Docs on config: https://docs.python.org/3/library/logging.config.html
FORMAT = '%(asctime)-15s %(threadName)-10s %(levelname)6s %(message)s'
logging.basicConfig(level=logging.NOTSET, format=FORMAT)

# for GPIO numbering, choose BCM  
GPIO.setmode(GPIO.BCM) 

pixel_pin = board.D18
ORDER = neopixel.GRBW
num_pixels = 16
pixels = neopixel.NeoPixel(pixel_pin, num_pixels, brightness=1.0, auto_write=False,
                           pixel_order=ORDER)


pixels.fill((0, 0, 0, 0))
pixels.show()
#time.sleep(1)


PIR_PIN = 17 # 11 # G17
MICROWAVE_PIN = 27 # 13 # G27

GPIO.setwarnings(True)
GPIO.setup([PIR_PIN,MICROWAVE_PIN], GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
#GPIO.setup([LED_G, LED_R, LED_Y, LED_B], GPIO.OUT, initial=GPIO.HIGH)

def handle(pin):
    # light corresponding LED when pushbutton of same color is pressed
    #GPIO.output(btn2led[pin], not GPIO.input(pin))

    if GPIO.input(pin):
        logger.info("Rising edge detected: %d PIR:%d MW:%d",pin,GPIO.input(PIR_PIN),GPIO.input(MICROWAVE_PIN))
    else:
        logger.info("Falling edge detected: %d PIR:%d MW:%d",pin,GPIO.input(PIR_PIN),GPIO.input(MICROWAVE_PIN))

    if GPIO.input(PIR_PIN) and GPIO.input(MICROWAVE_PIN):
        logger.info("BOTH triggered!!") 
        pixels.fill((32, 0, 0, 0))
        pixels.show()
    elif GPIO.input(PIR_PIN):
        pixels.fill((0, 0, 0, 0))
        pixels[0] = (0, 32, 0, 0)
        pixels.show()
    elif GPIO.input(MICROWAVE_PIN):
        pixels.fill((0, 0, 0, 0))
        pixels[num_pixels-1] = (0, 0, 32, 0)
        pixels.show()
    else:
        pixels.fill((0, 0, 0, 0))
        pixels.show()


GPIO.add_event_detect(PIR_PIN, GPIO.BOTH, handle)
GPIO.add_event_detect(MICROWAVE_PIN, GPIO.BOTH, handle)

logger.info("Monitor for pin state change")


try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
        logger.info("Exit")
        pixels.fill((0, 0, 0, 0))
        pixels.show()
        GPIO.cleanup()
