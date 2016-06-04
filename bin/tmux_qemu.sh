#!/bin/bash

LDIR=$(pwd)

#if [ -z "$1" -o ! -d "$KDIR" ]; then
#	echo "Please specify existing kernel directory under $LDIR"
#i	exit 1
#fi

VD="$LDIR/os.img"
#BI="$KDIR/arch/x86/boot/bzImage"
#VL="$KDIR/vmlinux"

#if ! [ -r "$VD" -a -r "$BI" -a -r "$VL" ]; then
#	echo -e "At least one of files:\n$VD\n$BI\n$VL\ncannot be read"
#	exit 1
#fi

if tmux has-session -t vm 2>/dev/null; then
	echo "vm session already running"
	exit 1
else 
	echo "create vm session"
fi


#export PATH="$HOME/+/builds/gdb/gdb:$HOME/+/builds/qemu/x86_64-softmmu:$PATH"

LOGFILE="$LDIR/serial_$(date +%s).log"

(
	echo $VL
	uname -a
	qemu --version
	gdb --version | sed 1q
	echo
) >> "$LOGFILE"

#EMU_CMD="qemu-system-x86_64 -hda $VD file:$LOGFILE"
EMU_CMD="qemu-system-x86_64 -hda $VD -kernel $BI -append 'root=\"/dev/hda\" ro console=ttyS0 no-kvmclock' -net nic,model=e1000 -net user,hostfwd=tcp::10022-:22 -m 128 -nographic -no-hpet -rtc clock=vm -s -enable-kvm -serial file:$LOGFILE"
LOG_CMD="tail -f $LOGFILE"
GDB_CMD="gdb"

echo "$EMU_CMD"

# SSH_CMD="ssh qemu"

tmux start-server
tmux new-session -d -s vm
tmux set-option -g history-limit 10000
tmux new-window -n log -t vm:1 "$LOG_CMD"
tmux new-window -n gdb -t vm:2 "$GDB_CMD"
#tmux new-window -n ssh -t vm:3
tmux new-window -n emu -t vm:4 "$EMU_CMD"
tmux select-window -t vm:log
tmux set-window-option -g monitor-activity on
tmux send-keys -t vm:ssh "$SSH_CMD"
exec tmux attach -t vm
