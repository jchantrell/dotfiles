function ueroll --description "Connect UE ROLL Bluetooth speaker"
    dbus-send --system --dest=org.bluez --print-reply \
        /org/bluez/hci0/dev_88_C6_26_60_D6_2B \
        org.bluez.Device1.ConnectProfile \
        string:"0000110b-0000-1000-8000-00805f9b34fb" >/dev/null 2>&1
    and echo "UE ROLL connected"
    or echo "UE ROLL failed to connect"
end
