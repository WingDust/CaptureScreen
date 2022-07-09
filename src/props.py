import pythoncom
from win32com.propsys import propsys,pscon
from win32com.shell import shellcon
import ctypes
from ctypes import windll

# pk = propsys.PSGetPropertyKeyFromName("System.Keywords")
# ps = propsys.SHGetPropertyStoreFromParsingName("H:/image/123.jpg", None, shellcon.GPS_READWRITE, propsys.IID_IPropertyStore)
r"""
[parameter error](https://github.com/mhammond/pywin32/issues/1360)
[pscon.py](https://github.com/SublimeText/Pywin32/blob/master/lib/x64/win32comext/propsys/pscon.py)
[PyIPropertyStore.cpp](https://github.com/mhammond/pywin32/blob/master/com/win32comext/propsys/src/PyIPropertyStore.cpp)
"""
# ps = propsys.SHGetPropertyStoreFromParsingName("H:\\image\\123.jpg")
# title = ps.GetValue(pscon.PKEY_Comment).GetValue()
# keywords = ps.GetValue(pk).GetValue()
# print(keywords)
# print(title)

# qq = ps.GetAt(23)

# print(qq)

# newValue = propsys.PROPVARIANTType(["hello", "world"], pythoncom.VT_VECTOR | pythoncom.VT_BSTR)

# write property
# ps.SetValue(pk, newValue)
# ps.Commit()

# [set_ime_status](https://github.com/qy-zhang/Sublime-Text-3/blob/31d8e56bfdf3b7a29f676d9c6ef30e0c6de72961/Packages/IMESupport/imesupportplugin.py)
hIMC = ctypes.windll.imm32.ImmGetContext()








