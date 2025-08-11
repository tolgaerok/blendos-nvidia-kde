#!/bin/bash
# tolga's SSD scheduler and power tweaks
# Converts udev rules into a standalone file

RULES_FILE="/etc/udev/rules.d/99-tolga-ssd-powertweaks.rules"

cat << 'EOF' | sudo tee "$RULES_FILE" > /dev/null
# Sound devices to audio group
KERNEL=="rtc0", GROUP="audio"
KERNEL=="hpet", GROUP="audio"

# Set scheduler to 'none' for SSDs (SATA, eMMC, NVMe)
ACTION=="add|change", KERNEL=="sd[a-z]", TEST=="queue/scheduler", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="mmcblk[0-9]", TEST=="queue/scheduler", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", TEST=="queue/scheduler", ATTR{queue/scheduler}="none"

# Power saving tweaks
ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="off"
ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="off"
EOF

# Reload udev to apply new rules
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "udev rules applied: $RULES_FILE"
