all:
	nasm boot.s -l dbg
	bochs -q -f bs