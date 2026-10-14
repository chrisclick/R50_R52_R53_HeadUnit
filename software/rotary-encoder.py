import time
import threading
from pyky040 import pyky040
import RPi.GPIO as GPIO
import os
from pynput.keyboard import Key, Controller
from evdev import list_devices, InputDevice
import tkinter as tk
from threading import Timer, Thread
import queue

# Define the GPIO pins
LCD_BACKLIGHT_PIN = 12
PWM_PIN = 13
SWITCH_PIN = 24
MODE_SWITCH_PIN = 27

# Initialize global variables
long_press_active = False
current_menu = 'main'  # Track the current menu state

class NotificationHandler:
    def __init__(self):
        self.queue = queue.Queue()
        self.root = tk.Tk()
        self.root.overrideredirect(1)
        self.root.attributes("-topmost", True)
        self.root.geometry("+{}+{}".format(
            (self.root.winfo_screenwidth() - 300) // 2,
            (self.root.winfo_screenheight() - 100) // 2))
        self.label = tk.Label(self.root, font=("Helvetica", 12))
        self.label.pack(expand=True)
        self.root.withdraw()  # Hide the window initially

        # Poll the queue to check for new messages
        self.poll_queue()

    def poll_queue(self):
        try:
            message = self.queue.get_nowait()
            self.show_notification(message)
        except queue.Empty:
            pass
        self.root.after(100, self.poll_queue)  # Check the queue every 100 ms

    def show_notification(self, message):
        self.label.config(text=message)
        self.root.deiconify()  # Show the window

        def close_notification():
            self.root.withdraw()

        Timer(2.0, close_notification).start()

    def notify(self, message):
        self.queue.put(message)

def start_notification_handler():
    global notification_handler
    notification_handler = NotificationHandler()
    notification_handler.root.mainloop()

notification_thread = Thread(target=start_notification_handler)
notification_thread.start()

def mode_switch_callback():
    global keystroke_mode
    keystroke_mode = not keystroke_mode
    mode_str = "Scroll Mode" if keystroke_mode else "Backlight Mode"
    print(f'Mode switched to {mode_str}.')

    # Send the notification message to the main thread
    notification_handler.notify(f'Mode Switched: {mode_str}')

    if keystroke_mode:
        GPIO.output(LCD_BACKLIGHT_PIN, GPIO.HIGH)
        print("Backlight turned ON (Scroll Mode)")

def mode_switch_press_handler(channel):
    start_time = time.time()

    while GPIO.input(channel) == GPIO.LOW:
        time.sleep(0.02)

    duration = time.time() - start_time
    if duration > 1:  # 1 second for mode switch
        mode_switch_callback()
    else:
        short_press_handler()

def short_press_handler():
    global long_press_active, current_menu
    if not long_press_active:
        keyboard.press('h')
        keyboard.release('h')
        print("Key 'h' pressed")
        current_menu = 'main'  # Reset to main menu when 'h' is pressed

def toggle_menu():
    global current_menu, long_press_active
    long_press_active = True
    if current_menu == 'main':
        keyboard.press(Key.down)
        keyboard.release(Key.down)
        current_menu = 'secondary'
    else:
        keyboard.press(Key.up)
        keyboard.release(Key.up)
        current_menu = 'main'
    print(f"Switched to {current_menu} menu")
    long_press_active = False

# Set up the GPIO pins
GPIO.setmode(GPIO.BCM)
GPIO.setup(PWM_PIN, GPIO.OUT)
GPIO.setup(LCD_BACKLIGHT_PIN, GPIO.OUT)
GPIO.setup(MODE_SWITCH_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(SWITCH_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)

# Turn on the backlight immediately
GPIO.output(LCD_BACKLIGHT_PIN, GPIO.HIGH)
print("Backlight turned ON at script start")

pwm_led = GPIO.PWM(PWM_PIN, 30000)
pwm_led.start(100)  # Initialize PWM with 100%

MODE_SWITCH_DURATION = 1  # seconds for mode switch
ESCAPE_SWITCH_DURATION = 0.3  # seconds for escape key
MENU_TOGGLE_DURATION = 0.8  # seconds for toggling menu

power_levels = [100, 95, 90, 85, 80, 75, 70, 65, 60, 55, 50, 45, 40, 35, 30, 25, 20, 15, 10, 5, 1, 0]  # Add 0 for OFF state
power_index = len(power_levels) - 5
prev_power_index = power_index
backlight_off = False  # Track backlight state

counter_inc = 0
counter_dec = 0

keyboard = Controller()

keystroke_mode = True  # Default to text control mode

devices = [InputDevice(path) for path in list_devices()]
encoder_device = None
for device in devices:
    if device.name.lower().startswith("rotary"):
        encoder_device = device.path
        break

if not encoder_device:
    print("Rotary encoder device not found")
    exit()

print(f'Found rotary encoder device at {encoder_device}')

def check_power():
    global power_index, prev_power_index, backlight_off
    if power_levels[power_index] == 100:
        GPIO.output(LCD_BACKLIGHT_PIN, GPIO.LOW)
        print("Backlight turned OFF")
    else:
        GPIO.output(LCD_BACKLIGHT_PIN, GPIO.HIGH)
        pwm_led.ChangeDutyCycle(power_levels[power_index])
        print('Power is now {}%'.format(power_levels[power_index]))
        if power_levels[power_index] <= 5:
            backlight_off = True
        else:
            backlight_off = False

def inc_callback(scale_position):
    global power_index, prev_power_index, keystroke_mode, counter_inc, backlight_off
    if keystroke_mode:
        counter_inc += 1
        if counter_inc % 2 == 0:
            keyboard.press('1')
            keyboard.release('1')
            print("Key '1' pressed")
    else:
        if power_index > 0:
            prev_power_index = power_index
            power_index -= 1  # Decrease power_index for increasing brightness
            backlight_off = False
            check_power()

def dec_callback(scale_position):
    global power_index, prev_power_index, keystroke_mode, counter_dec, backlight_off
    if keystroke_mode:
        counter_dec += 1
        if counter_dec % 2 == 0:
            keyboard.press('2')
            keyboard.release('2')
            print("Key '2' pressed")
    else:
        if power_index < len(power_levels) - 1:
            prev_power_index = power_index
            power_index += 1  # Increase power_index for decreasing brightness
            if power_levels[power_index] == 100:
                backlight_off = True
            check_power()

def switch_press_handler(channel):
    start_time = time.time()
    global long_press_active
    long_press_active = False

    while GPIO.input(channel) == GPIO.LOW:
        time.sleep(0.02)

    duration = time.time() - start_time
    if duration > MENU_TOGGLE_DURATION:  # 0.8 seconds for menu toggle
        toggle_menu()
    elif duration > ESCAPE_SWITCH_DURATION:  # 0.3 seconds for escape
        sw_escape_press_callback(None)
    else:
        sw_short_press_callback(None)

def sw_short_press_callback(scale_position):
    global power_index, prev_power_index, keystroke_mode, long_press_active
    if keystroke_mode and not long_press_active:
        keyboard.press(Key.enter)
        keyboard.release(Key.enter)
        print("Key 'enter' pressed")
    else:
        if power_index != 0:
            prev_power_index = power_index
            power_index = 0
        else:
            power_index = prev_power_index
        pwm_led.ChangeDutyCycle(power_levels[power_index])
        print('Switch short pressed. Power is now {}%'.format(power_levels[power_index]))
        check_power()

def sw_escape_press_callback(scale_position):
    if keystroke_mode:
        keyboard.press(Key.esc)
        keyboard.release(Key.esc)
        print("Key 'esc' pressed")

GPIO.add_event_detect(SWITCH_PIN, GPIO.FALLING, callback=switch_press_handler, bouncetime=300)
GPIO.add_event_detect(MODE_SWITCH_PIN, GPIO.FALLING, callback=mode_switch_press_handler, bouncetime=300)

my_encoder = pyky040.Encoder(device=encoder_device)

my_encoder.setup(scale_min=0, scale_max=4,
                 inc_callback=inc_callback,
                 dec_callback=dec_callback)

my_thread = threading.Thread(target=my_encoder.watch)

# Initialize power to 100%
check_power()

try:
    my_thread.start()
    while True:
        time.sleep(10)
except KeyboardInterrupt:
    print("\nCleaning up GPIO and exiting.")
finally:
    pwm_led.stop()
    GPIO.cleanup()
