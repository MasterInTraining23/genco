import dbus
import dbus.service
import dbus.mainloop.glib
import sys
import asyncio
import traceback
import json
import os
import logging
from gi.repository import GLib
from bluepy.btle import Peripheral, Scanner

SERVICE_UUID = "180A"
CHAR_UUID = "2A57"
DEVICE_NAMES = ["Genco1", "Genco2"]
DEVICE_ADDR_FILE = "devices.json"

dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

# logging.basicConfig(level=logging.DEBUG)

class BluetoothService(dbus.service.Object):
    def __init__(self, loop, bus_name):
        super().__init__()
        self.devices = {}
        self.clients = {}
        self.connection_lock = asyncio.Lock()
        self.loop = loop
        dbus.service.Object.__init__(self, bus_name, '/com/example/BluetoothService')

    async def setup_devices(self):
        print("Loading known devices...")

        with open(DEVICE_ADDR_FILE, 'r') as file:
            self.devices = json.load(file)
        print(self.devices)
        
        #Scanner().scan(10)

        await self.connect_devices()

    async def discover_devices(self, target_names):
        print("Discovering devices...")
        devices = Scanner().scan(10)
        for d in devices:
            print(d.getValueText(9))
            device_name = d.getValueText(9)
            if device_name in target_names:
                self.devices[device_name] = d.addr
                self.full_ble_devices[device_name] = d

        print(self.full_ble_devices)

        with open(DEVICE_ADDR_FILE, 'w') as f:
            json.dump(self.devices, f)

    async def connect_devices(self):
        async with self.connection_lock:
            print("Connecting devices...")
            print (self.devices)
            for name, address in self.devices.items():
                client = self.clients.get(name)
                print(client)
                if not client:
                    print("storing client within table")
                    client = Peripheral(address)
                    for ch in client.getCharacteristics():
                        print(f"Char {ch.uuid} - handle {ch.getHandle()} - properties {ch.propertiesToString()}")
                    self.clients[name] = client
                    print(f"Connected to {name}")
            print(self.clients)
            print("Ready")

    def disconnect_devices(self):
        for device_name in self.clients:
            client = self.clients[device_name]
            client.disconnect()
        self.clients = {}

    @dbus.service.method('com.example.BluetoothService', in_signature='s', out_signature='')
    def bluetooth_dispense(self, device_name):
        print("I have arrived for " + device_name)
        self.loop.call_soon_threadsafe(asyncio.create_task,self._do_dispense(device_name))
        print("Signal was sent")

    async def _do_dispense(self, device_name):
        async with self.connection_lock:
            print("dispensing in progress")
            print(self.clients)
            client = self.clients[str(device_name)]
            if not client:
                print(f"Device {device_name} disconnected! Reconnecting...")
                await self.connect_devices()
                client = self.clients[device_name]
            
            print(client)
            if client:
                print(f"Dispensing from {device_name}...")
                try:
                    client.writeCharacteristic(12, b"dispense", withResponse=True)
                    print(f"Dispensed from {device_name}")
                except Exception as e:
                    print(f"Error dispensing {device_name}")
                    print(traceback.format_exc())
            else:
                print(f"Could not reconnect {device_name}")

    async def auto_reconnect_loop(self):
        while True:
            self.disconnect_devices()
            await self.connect_devices()
            await asyncio.sleep(10)

    async def start(self):
        """ Starts the dbus service and starts listening for messages."""
        print("DBus service for bluetooth interaction starting...")
        
        await asyncio.gather(
            self.setup_devices(),
            self.auto_reconnect_loop(),
        )
        

