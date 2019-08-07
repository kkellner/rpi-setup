#!/usr/bin/python3

from w1thermsensor import W1ThermSensor

sensor = W1ThermSensor()

while True:
    for sensor in W1ThermSensor.get_available_sensors():
        print("Sensor %s has temperature %.1f" % (sensor.id, sensor.get_temperature(W1ThermSensor.DEGREES_F)))

