#!/usr/bin/python3

import time

import melopero_vl53l1x as mp
import statistics

sensor = mp.VL53L1X()
#sensor = mp.VL53L1X(i2c_bus=1, i2c_address=0x29)
#sensor.set_measurement_timing_budget(40)
#sensor.set_intermeasurement_period(250) 
#sensor.set_intermeasurement_period(100) 
#sensor.setROI(6, 12, 9, 9)

#sensor.start_ranging(mp.VL53L1X.MEDIUM_DST_MODE)
#sensor.start_ranging(mp.VL53L1X.LONG_DST_MODE)

sensor.setROI(6, 11, 10, 7)  # 177 - 181  (4 variance)
#sensor.setROI(7, 11, 11, 7)   # 183 - 187  (4 variance)
#sensor.setROI(6, 11, 9, 7)    #  174 - 178   (4 variance)
#sensor.setROI(0, 15, 15, 0)  #  190 - 196mm (6 variance)

sensor.start_ranging(mp.VL53L1X.SHORT_DST_MODE)
print('start water depth check')

def getWaterDepth(center=False):

    # if center == True: 
    #     sensor.setROI(6, 11, 9, 7)
    # else:
    #     sensor.setROI(0, 15, 15, 0)
    list = [ ]
    samples=15
    for x in range(samples):
       value_mm = sensor.get_measurement()
       list.append(value_mm)
       time.sleep(0.01)

    middle_value_mm = statistics.median(list)
    return middle_value_mm
    #print('values: ', list)
    #value_inches = (1/25.4) * middle_value_mm
    #return value_inches

    #print('%.1f inches' % (value_inches), end="")
    #sensor.setROI(6, 11, 9, 7)
    #value_mm = sensor.get_measurement()
    #value_inches = (1/25.4) * value_mm
    #print('  Center: %.1f inches' % (value_inches))
    #time.sleep(0.5)


while True: 
    print('%.1f ' % getWaterDepth(False), end="")
    #print('  center: %.1f' % getWaterDepth(True))
    print('')

sensor.stop_ranging()
sensor.close_connection()

