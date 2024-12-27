import dbus
import dbus.service
import dbus.mainloop.glib
import RPi.GPIO as GPIO
from gi.repository import GLib
import time

# Initialize GPIO (assuming Raspberry Pi)
GPIO.setmode(GPIO.BCM)
GPIO.setup(17, GPIO.OUT)  # Pin 17 for PWM
GPIO.setup(18, GPIO.OUT)  # Pin 18 for PWM

dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

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

    @dbus.service.method('com.example.PWMService', in_signature='ii', out_signature='s')
    def set_pwm_frequency(self, channel, frequency):
        """Sets PWM frequency"""
        if frequency > 0:
            pwm = GPIO.PWM(channel, frequency)
            pwm.start(50)  # Start with a default 50% duty cycle
            return f"PWM frequency set to {frequency} Hz"
        else:
            return "Error: Frequency must be greater than 0."

    def start(self):
        """ Starts the dbus service and starts listening for messages."""
        print("DBus service starting...")
        GLib.MainLoop().run()



def main():
    bus_name = dbus.service.BusName('com.example.PWMService', bus=dbus.SessionBus())
    pwm_service = PWMService(bus_name)
    pwm_service.start()

if __name__ == '__main__':
    main()
