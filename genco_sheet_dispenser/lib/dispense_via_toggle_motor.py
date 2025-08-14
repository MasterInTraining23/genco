import dbus
import sys


def toggle_motor(should_rotate, channel):
    try:
        # D-Bus session bus
        bus = dbus.SessionBus()

        # PWM service
        obj = bus.get_object('com.example.PWMService', '/com/example/PWMService')

        toggle_gpio = obj.get_dbus_method('toggle_gpio', 'com.example.PWMService')

        # duty cycle
        response = toggle_gpio(should_rotate, channel)
        print(response)
    except dbus.DBusException as e:
        print(f"Error toggling motor: {e}")
        sys.exit(1)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python toggle_motor.py <true|false> <channel> [<duty_cycle>]")
        sys.exit(1)

    should_rotate = sys.argv[1].lower() == 'true'
    channel = int(sys.argv[2])

    # Toggle the motor
    toggle_motor(should_rotate, channel)