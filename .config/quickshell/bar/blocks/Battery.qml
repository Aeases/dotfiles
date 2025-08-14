import QtQuick
import Quickshell.Io
import "../"

BarBlock {
  property string battery
  property bool hasBattery: false
  visible: hasBattery
  
  content: BarText {
    symbolText: battery
  }

  Process {
    id: batteryCheck
    command: ["sh", "-c", "test -d /sys/class/power_supply/BAT*"]
    running: true
    onExited: function(exitCode) { hasBattery = exitCode === 0 }
  }

  Process {
    id: batteryProc
    // Modify command to get both capacity and status in one call
    command: ["sh", "-c", "echo $(cat /sys/class/power_supply/BAT*/capacity),$(cat /sys/class/power_supply/BAT*/status)"]
    running: hasBattery

    stdout: SplitParser {
      onRead: function(data) {
        const [capacityStr, status] = data.trim().split(',')
        const capacity = parseInt(capacityStr)
        let batteryIcon = "󰂂"
        if (capacity <= 20) batteryIcon = "󰁺"
        else if (capacity <= 40) batteryIcon = "󰁽"
        else if (capacity <= 60) batteryIcon = "󰁿"
        else if (capacity <= 80) batteryIcon = "󰂁"
        else batteryIcon = "󰂂"
        
        const symbol = status === "Charging" ? "󰂄" : batteryIcon
        battery = `${symbol} ${capacity}%`
      }
    }
  }

  Timer {
    interval: 1000
    running: hasBattery
    repeat: true
    onTriggered: batteryProc.running = true
  }
}
