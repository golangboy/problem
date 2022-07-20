# 运行
安装好nasm、bochs、make后，执行make即可运行
# 问题
利用iret指令进去到ring3后，我想尝试用中断调用门，从ring3进入到ring0的，但是发现进入到中断调用程序后，CPL没有发生改变，此时还是在ring3特权级？