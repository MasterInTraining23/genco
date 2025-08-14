import dbus
import sys

def toggle_bluetooth_motor(device_name):
    try:
        # D-Bus session bus
        bus = dbus.SessionBus()

        # PWM service
        obj = bus.get_object('com.example.BluetoothService', '/com/example/BluetoothService')

        bluetooth_dispense = obj.get_dbus_method('bluetooth_dispense', 'com.example.BluetoothService')

        # duty cycle
        response = bluetooth_dispense(device_name)
        print(response)
    except dbus.DBusException as e:
        print(f"Error toggling motor: {e}")
        sys.exit(1)


if __name__ == '__main__':
    if len(sys.argv) < 1:
        print("Usage: python toggle_bluetooth_motor.py <Genco1|Genco2>")
        sys.exit(1)

    # Dispense via bluetooth
    toggle_bluetooth_motor(sys.argv[1])
