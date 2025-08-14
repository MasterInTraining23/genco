import asyncio
from asyncio_glib import GLibEventLoopPolicy
import dbus
import dbus.service
import dbus.mainloop.glib
import RPi.GPIO as GPIO
from gi.repository import GLib
import time
import signal
import sys
from bluetooth_service import BluetoothService
from pwm_service import PWMService

dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
asyncio.set_event_loop_policy(GLibEventLoopPolicy())

bluetooth_service = None

async def main():
    if sys.argv[1].lower() == "pwm":
        bus_name = dbus.service.BusName('com.example.PWMService', bus=dbus.SessionBus())
        pwm_service = PWMService(bus_name)
        pwm_service.start()

    if sys.argv[1].lower() == "bluetooth":
        loop = asyncio.get_running_loop()
        bus_name = dbus.service.BusName('com.example.BluetoothService', bus=dbus.SessionBus())
        bluetooth_service = BluetoothService(loop, bus_name)
        await bluetooth_service.start()
    

if __name__ == '__main__':
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("Stopped by user.")

# signal.signal(signal.SIGINT, lambda signal, frame: bluetooth_service.disconnect_devices())
# signal.signal(signal.SIGTERM, lambda signal, frame: bluetooth_service.disconnect_devices())
