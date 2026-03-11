# Mounting and Unmounting drives
m() {
  udisksctl mount -b /dev/"$1" && notify-send "HDD Mounted"
}

um() {
  udisksctl unmount -b /dev/"$1" && notify-send "HDD Unmounted"
}

# Open an app in terminal without linking it to it (i mean i background)
o() {
    nohup "$@" </dev/null &>/dev/null & disown
}

# Some docs made by me
raddocs
(you can see it in the functions hh)


