import dbus
import dbus.service
import dbus.mainloop.glib
import sys
import asyncio
import traceback
import json
import os
import logging
from bleak import BleakClient, BleakScanner
from gi.repository import GLib

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
        self.full_ble_devices = {}
        self.clients = {}
        self.connection_lock = asyncio.Lock()
        self.loop = loop
        dbus.service.Object.__init__(self, bus_name, '/com/example/BluetoothService')

    async def setup_devices(self):
        print("Loading known devices...")
        self.scanner = BleakScanner()
        await self.scanner.start()
    
        missing_devices = [name for name in DEVICE_NAMES if name not in self.devices]
        if missing_devices:
            await self.discover_devices(missing_devices)

        await self.connect_devices()
        await self.scanner.stop()

    async def discover_devices(self, target_names):
        print("Discovering devices...")
        await asyncio.sleep(3)
        # devices = await BleakScanner.discover(timeout=10)
        devices = await self.scanner.get_discovered_devices()
        print(devices)
        for d in devices:
            if d.name in target_names:
                self.devices[d.name] = d.address
                self.full_ble_devices[d.name] = d

        with open(DEVICE_ADDR_FILE, 'w') as f:
            json.dump(self.devices, f)

    async def connect_devices(self):
        async with self.connection_lock:
            print("Connecting devices...")
            for name, address in self.devices.items():
                client = self.clients.get(name)
                if not client or not await client.is_connected:
                    print("storing client within table")
                    print(self.full_ble_devices[name])
                    client = BleakClient(self.full_ble_devices[name])
                    try:
                        print("initializing client connection")
                        await client.connect()
                        print("client is connected")
                        self.clients[name] = client
                        print(f"Connected to {name}")
                    except Exception as e:
                        print(f"Connection failed for {name}: {e}")

            print("Ready")

    @dbus.service.method('com.example.BluetoothService', in_signature='s', out_signature='')
    def bluetooth_dispense(self, device_name):
        print("I have arrived")
        self.loop.call_soon_threadsafe(asyncio.create_task,self._do_dispense(device_name))
        print("Signal was sent")

    async def _do_dispense(self, device_name):
        async with self.connection_lock:
            print("dispensing in progress")
            client = self.clients[device_name]
            if not client or not await client.is_connected:
                print(f"Device {device_name} disconnected! Reconnecting...")
                await self.connect_devices()
                client = self.clients[device_name]
            
            print(client)
            if client and await client.is_connected:
                print(f"Dispensing from {device_name}...")
                try:
                    await client.write_gatt_char(CHAR_UUID, b"dispense", response=True)
                    print(f"Dispensed from {device_name}")
                except Exception as e:
                    print(f"Error dispensing {device_name}")
                    print(traceback.format_exc())
            else:
                print(f"Could not reconnect {device_name}")

    async def auto_reconnect_loop(self):
        while True:
            await self.connect_devices()
            await asyncio.sleep(10)

    async def start(self):
        """ Starts the dbus service and starts listening for messages."""
        print("DBus service for bluetooth interaction starting...")
        
        await asyncio.gather(
            self.setup_devices(),
            self.auto_reconnect_loop(),
        )
        

