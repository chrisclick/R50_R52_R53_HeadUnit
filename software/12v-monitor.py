import RPi.GPIO as GPIO
import time

# Define GPIO pins
Ilum_Sense = 26
Ilum_led = 16
Rvrs_Trig = 6
Acc_Sense = 5

# Setup GPIO
GPIO.setmode(GPIO.BCM)
GPIO.setup(Ilum_Sense, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
GPIO.setup(Ilum_led, GPIO.OUT)
GPIO.setup(Rvrs_Trig, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
GPIO.setup(Acc_Sense, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)

# Initialize the LED state
GPIO.output(Ilum_led, GPIO.LOW)

# Callback functions
def acc_sense_callback(channel):
    if GPIO.input(Acc_Sense):
        print("Accessory is on!")
    else:
        print("Accessory is off!")

def ilum_sense_callback(channel):
    if GPIO.input(Ilum_Sense):
        print("12V signal detected!")
        GPIO.output(Ilum_led, GPIO.HIGH)
    else:
        GPIO.output(Ilum_led, GPIO.LOW)

def rvrs_trig_callback(channel):
    if GPIO.input(Rvrs_Trig):
        print("Car is in reverse!")
        # Code to activate backup camera

# Add event detection
GPIO.add_event_detect(Acc_Sense, GPIO.BOTH, callback=acc_sense_callback, bouncetime=200)
GPIO.add_event_detect(Ilum_Sense, GPIO.BOTH, callback=ilum_sense_callback, bouncetime=200)
GPIO.add_event_detect(Rvrs_Trig, GPIO.BOTH, callback=rvrs_trig_callback, bouncetime=200)

try:
    # Main loop to keep the script running
    while True:
        time.sleep(1)

except KeyboardInterrupt:
    print("Script terminated by user")

finally:
    GPIO.cleanup()
