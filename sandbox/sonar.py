#!/usr/bin/python3

import RPi.GPIO as GPIO
import os
import time

# Define GPIO to use on Pi
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO_TRIGGER = 23
GPIO_ECHO = 22

TRIGGER_TIME = 0.00001
MAX_TIME = 0.004  # max time waiting for response in case something is missed
GPIO.setup(GPIO_TRIGGER, GPIO.OUT)  # Trigger
GPIO.setup(GPIO_ECHO, GPIO.IN, pull_up_down=GPIO.PUD_UP)  # Echo

GPIO.output(GPIO_TRIGGER, False)

# This function measures a distance

NB_CM_IN_INCH = 2.54

def convert_cm_in_inch(val):
    return val / NB_CM_IN_INCH


def measure():
    # Pulse the trigger/echo line to initiate a measurement
    GPIO.output(GPIO_TRIGGER, True)
    time.sleep(TRIGGER_TIME)
    GPIO.output(GPIO_TRIGGER, False)

    # ensure start time is set in case of very quick return
    start = time.time()
    timeout = start + MAX_TIME

    # set line to input to check for start of echo response
    while GPIO.input(GPIO_ECHO) == 0 and start <= timeout:
        start = time.time()

    if(start > timeout):
        return -1

    stop = time.time()
    timeout = stop + MAX_TIME
    # Wait for end of echo response
    while GPIO.input(GPIO_ECHO) == 1 and stop <= timeout:
        stop = time.time()

    if(stop <= timeout):
        elapsed = stop-start
        distance = float(elapsed * 34300)/2.0
    else:
        return -1
    return distance


if __name__ == '__main__':
    try:
        while True:
            distance = measure()
            if(distance > -1):
                print("Measured Distance = %.1f cm,  %.1f in" % (distance, convert_cm_in_inch(distance)))
            else:
                print("#")
            time.sleep(0.5)
        # Reset by pressing CTRL + C
    except KeyboardInterrupt:
        print("Measurement stopped by User")
        GPIO.cleanup()
        
