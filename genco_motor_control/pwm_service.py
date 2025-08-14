import dbus
import dbus.service
import dbus.mainloop.glib
import RPi.GPIO as GPIO
from gi.repository import GLib
import time

# Initialize GPIO (assuming Raspberry Pi)
GPIO.setmode(GPIO.BCM)
GPIO.setup(17, GPIO.OUT)  # Pin 17 for PWM
GPIO.setup(27, GPIO.OUT)  # Pin 27 for PWM

class PWMService(dbus.service.Object):
    def __init__(self, bus_name):
        dbus.service.Object.__init__(self, bus_name, '/com/example/PWMService')

    @dbus.service.method('com.example.PWMService', in_signature='bi', out_signature='s')
    def toggle_gpio(self, should_rotate, channel):
        """Sets PWM duty cycle"""
        if should_rotate:
            print("should be on. I'm sending power.")
            GPIO.output(channel, GPIO.HIGH)
            return "Power on, to turn motor on."
        else:
            print("should be off. I'm sending power.")
            GPIO.output(channel, GPIO.LOW)
            return "Power off, to turn motor off."

    def start(self):
        """ Starts the dbus service and starts listening for messages."""
        print("DBus service starting...")
        GLib.MainLoop().run()
