# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Daniel Schmidt <danischm@cisco.com>

import atexit

try:
    from pyVim.connect import Disconnect, SmartConnect
    from pyVim.task import WaitForTask
except ImportError:
    from pyvim.connect import Disconnect, SmartConnect
    from pyvim.task import WaitForTask

from pyVmomi import vim

# USB HID scancode mapping: char -> (hid_code, needs_shift)
_CHAR_TO_HID = {}
for _i, _c in enumerate("abcdefghijklmnopqrstuvwxyz"):
    _CHAR_TO_HID[_c] = (0x04 + _i, False)
    _CHAR_TO_HID[_c.upper()] = (0x04 + _i, True)
for _i, _c in enumerate("1234567890"):
    _CHAR_TO_HID[_c] = (0x1E + _i, False)
_CHAR_TO_HID["\n"] = (0x28, False)  # Enter
_CHAR_TO_HID[" "] = (0x2C, False)
_CHAR_TO_HID["-"] = (0x2D, False)
_CHAR_TO_HID["."] = (0x37, False)
_CHAR_TO_HID["/"] = (0x38, False)
_CHAR_TO_HID["!"] = (0x1E, True)  # Shift+1
_CHAR_TO_HID["_"] = (0x2D, True)  # Shift+-


class Vsphere:
    def __init__(self, host: str, username: str, password: str, port: int = 443):
        self.host = host
        self.username = username
        self.password = password
        self.port = port

        self.instance = SmartConnect(
            host=self.host,
            user=self.username,
            pwd=self.password,
            port=self.port,
            disableSslCertValidation=True,
        )
        atexit.register(Disconnect, self.instance)

    def _get_snapshots_by_name_recursively(self, snapshots, snapname):
        """Helper function to find snapshot by name"""
        snap_obj = []
        for snapshot in snapshots:
            if snapshot.name == snapname:
                snap_obj.append(snapshot)
            else:
                snap_obj = snap_obj + self._get_snapshots_by_name_recursively(
                    snapshot.childSnapshotList, snapname
                )
        return snap_obj

    def vmware_revert_snapshot(self, vm_name, snapshot_name):
        """Revert VM snapshot"""
        content = self.instance.RetrieveContent()

        # Find VM
        folder = content.rootFolder
        vm = None
        container = content.viewManager.CreateContainerView(
            folder, [vim.VirtualMachine], True
        )

        for managed_object_ref in container.view:
            if managed_object_ref.name == vm_name:
                vm = managed_object_ref
                break
        container.Destroy()

        # Find snapshot
        snap_obj = self._get_snapshots_by_name_recursively(
            vm.snapshot.rootSnapshotList, snapshot_name
        )

        WaitForTask(snap_obj[0].snapshot.RevertToSnapshot_Task())

    def _get_vm_by_name(self, vm_name):
        """Find VM object by name.

        Args:
            vm_name: Name of the virtual machine.

        Returns:
            vim.VirtualMachine object.

        Raises:
            ValueError: If VM is not found.
        """
        content = self.instance.RetrieveContent()
        container = content.viewManager.CreateContainerView(
            content.rootFolder, [vim.VirtualMachine], True
        )
        vm = None
        for managed_object_ref in container.view:
            if managed_object_ref.name == vm_name:
                vm = managed_object_ref
                break
        container.Destroy()

        if vm is None:
            raise ValueError(f"VM '{vm_name}' not found in vCenter")
        return vm

    def vmware_reset_vm(self, vm_name):
        """Reset a VM by powering it off and back on.

        Args:
            vm_name: Name of the virtual machine.
        """
        vm = self._get_vm_by_name(vm_name)

        # Power off if running
        if vm.runtime.powerState == vim.VirtualMachinePowerState.poweredOn:
            WaitForTask(vm.PowerOffVM_Task())

        # Power on
        WaitForTask(vm.PowerOnVM_Task())

    def vmware_type_text(self, vm_name, text):
        """Type text into VM console using USB scan codes.

        Converts each character to a USB HID scan code and sends it
        to the VM via PutUsbScanCodes. Use '\\n' for Enter key.
        """
        vm = self._get_vm_by_name(vm_name)
        key_events = []

        for char in text:
            if char not in _CHAR_TO_HID:
                raise ValueError(f"Unsupported character: '{char}'")
            hid_code, shift = _CHAR_TO_HID[char]
            key_event = vim.UsbScanCodeSpec.KeyEvent()
            key_event.usbHidCode = (hid_code << 16) | 7
            if shift:
                modifiers = vim.UsbScanCodeSpec.ModifierType()
                modifiers.leftShift = True
                key_event.modifiers = modifiers
            key_events.append(key_event)

        spec = vim.UsbScanCodeSpec(keyEvents=key_events)
        vm.PutUsbScanCodes(spec)
