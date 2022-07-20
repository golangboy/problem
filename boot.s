org 0x7c00

;①进入保护模式
mov dx,0x92
in al,dx
or al,2
out dx,al

mov eax,cr0
or eax,1
mov cr0,eax

;②加载GDT
lgdt [gdt_pointer]
mov ax,0x10
mov ds,ax
mov ss,ax
jmp 0x8:flush


[bits 32]
flush:
;③加载中断
lidt [idt_pointer]

;④利用iret改变特权级，从ring0进入ring3特权级
push (4<<3) | (3)  ;;SS 对应到第五个GDT项，DPL=3的数据段
push 0xffff        ;;ESP
push 0             ;;EFLAGS
push (3<<3) | (3)  ;;CS 对应到第四个GDT项，DPL=3到代码段
push ring3         ;;EIP
iret
jmp $

ring3:
mov ax,4<<3        ;;DS 对应到第五个GDT项,DPL=3
mov ds,ax
;⑤使用中断尝试进入到ring0特权级
int 0
jmp $

idt_function:
;问题：上面中断调用后，此时CPU在这里执行了，但是CPL还是3，特权级还是没改变
nop
jmp $


;;=================数据区了==================
;;GDT
gdt_pointer:
dw 39
dd gdt_arrays

gdt_arrays:
dq 0
dq 0xCF9E000000FFFF ;代码段，可读可执行，一致性，DPL=0
dq 0xCF92000000FFFF ;数据段，可读可写，向上扩展，DPL=0
dq 0xCFFE000000FFFF ;代码段，可读可执行，一致性，DPL=3
dq 0xCFF2000000FFFF ;数据段，可读可写，向上扩展，DPL=3

;;IDT
idt_pointer:
dw 7
dd idt_arrays

idt_arrays:
;为了简单，这里只构造一个中断项
dw idt_function
dw 1<<3 ;;段选择子
db 0
db 0xee ;;DPL=3，系统段，中断门
dw 0


times 510-($-$$) db 0
db 0x55
db 0xaa
;;=================数据区了==================