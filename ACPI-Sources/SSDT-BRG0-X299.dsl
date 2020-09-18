/*
 * This SSDT enforces an ACPI path to the dGPU present in the top slot, and is required for
 * concistent DeviceProperty injection to the device
 */
DefinitionBlock ("", "SSDT", 2, "Slav", "BRG0", 0x00000000)
{
    External (_SB_.PC02.BR2A.PEGP, DeviceObj)
    External (_SB_.PC02.BR2A.SL05, DeviceObj)

    Scope (\_SB.PC02.BR2A.SL05)
    {
        Device (BRG0)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Device (GFX0) // Creates a GFX0 device for your GPU
            {
                Name (_ADR, Zero)  // _ADR: Address
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    If (_OSI ("Darwin"))
                    {
                        Return (0x0F)
                    }
                    Else
                    {
                        Return (Zero)
                    }
                }
            }

            Device (HDAU) // Creates an HDAU device for your GPU's HDMI Audio Controller
            {
                Name (_ADR, One)  // _ADR: Address
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    If (_OSI ("Darwin"))
                    {
                        Return (0x0F)
                    }
                    Else
                    {
                        Return (Zero)
                    }
                }
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }
    }

    Scope (\_SB.PC02.BR2A.PEGP)
    {
        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            If (_OSI ("Darwin"))
            {
                Return (Zero)
            }
            Else
            {
                Return (0x0F)
            }
        }
    }
}

