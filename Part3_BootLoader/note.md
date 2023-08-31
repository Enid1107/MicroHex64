# BootLoader引导启动程序

## Boot引导程序

### 写一个Boot引导程序

#### 起始地址

```assembly
org 0x7c00
BaseOfStack equ 0x7c00
```

#### 初始化

```assembly
mov ax, cs
mov ds, ax
mov es, ax
mov ss, ax
mov sp, BaseOfStack
```

进行地址段寄存器（ds）、附加段寄存器（es）、堆栈段寄存器（ss）初始化，并将堆栈指针（sp）初始化为BaseOfStack，代表引导程序地址设在0x7c00处。

#### BIOS中断服务

使用x86汇编语言INT指令

该os常用的BIOS 中断向解释：

-    **INT 10h**

显示服务 - 由BIOS或操作系统设定以供软件调用。AH=00h 设定显示模式；AH=01h 设定游标形态；AH=02h 设置游标位置；AH=03h 获取光标位置与形态；AH=04h 获取光标位置；AH=05h 设置显示页；AH=06h 清除或滚动栏画面(上)；AH=07h 清除或滚动栏画面(下)；AH=08h 读取游标处字符与属性；AH=09h 更改游标处字符与属性；AH=0Ah 更改游标处字符；AH=0Bh 设定边界颜色；AH=0Eh 在TTY模式下写字符；AH=0Fh 获取当前显示模式；AH=13h 写字符串。

-   **INT 13h**

低级磁盘服务。AH=00h 复位磁盘驱动器；AH=01h 检查磁盘驱动器状态；AH=02h 读扇区；AH=03h 写扇区；AH=04h 校验扇区；AH=05h 格式化磁道；AH=08h 获取驱动器参数；AH=09h 初始化硬盘驱动器参数；AH=0Ch 寻道；AH=0Dh 复位硬盘控制器；AH=15h 获取驱动器类型；AH=16h 获取软驱中盘片的状态。

#### 清屏

```assembly
mov ax, 0600h  ;06，按指定范围滚动窗口
mov bx, 0700h 
mov cx, 0
mov dx, 0184fh
int 10h
```

在接下来程序中

**AX**: 用于指定调用哪个的子功能。

**BX**: 通常用于设置文本和背景的颜色属性。

**CX**: 通常用于指定要操作的字符数或其他数量。

**DX**: 通常用于设置光标的位置。



**AH=06h** 清除或滚动栏画面

**0700h=0000 0111**

依照BH=颜色属性

-   bit 0~2:字体颜色（0:黑，1:蓝，2:绿，3:青，4:红，5:紫，6:综，7:白)。
-   bit 3:字体亮度(0:字体正常，1:字体高亮度)
-   bit 4~6:背景颜色（0:黑，1:蓝，2:绿，3:青，4:红，5:紫，6:综，7:白)。
-   bit 7:字体闪烁(0:不闪烁，1:字体闪烁)。

bit 0~2为111，即白色字体；bit 3为0，即字体正常；bit 4~6为000，即黑色背景；bit 7为0，即字体不闪烁

#### 光标

```assembly
mov ax, 0200h
mov bx, 0000h
mov dx, 0000h
int 10h
```

**AH=02h** 设置游标位置

**mov bx, 0000h**、**mov dx, 0000h ** 代表光标位置位于屏幕左上角（0,0）处

#### 初始屏幕

```assembly
mov ax, 1301h
mov bx, 000fh
mov dx, 0000h
mov cx, 10
push ax
mov ax, ds
mov es, ax
pop ax
mov bp, StartBootMessage 
int 10h
```

**AH=13h **写字符串

**AL=01h** 光标会移到字符串尾端位置（**AL=00h** 光标会移到字符串前端位置）

**mov cx, 10** 字符串长度为10（该字符串是StartBootMessage）

**mov bp, StartBootMessage ** 将StartBootMessage 写入bp

#### 复位

```assembly
xor ah,ah
xor dl,dl
int 13h
	
jmp $
```

**xor**是异或，将ah和dl清0

#### 填充

```assembly
times 510-($-$$) db 0 ;$-$$ 
dw 0xaa55
```

将当前行被编译后的地址（机器码地址)减去本节 ( Section）程序的起始地址，将521B空间（扇区单位）填充

**0xaa55**引导扇区是以0xaa、0x55为结尾（默认），又因为Inter处理器是小段模式存储，所以这样写

### 创建虚拟软盘镜像

利用Bochs虚拟机自带的虚拟磁盘镜像创建工具bximage

运行命令

```bash
@ubuntu:~/Desktop$ bximage
========================================================================
                                bximage
  Disk Image Creation / Conversion / Resize and Commit Tool for Bochs
         $Id: bximage.cc 13069 2017-02-12 16:51:52Z vruppert $
========================================================================

1. Create new floppy or hard disk image
2. Convert hard disk image to other format (mode)
3. Resize hard disk image
4. Commit 'undoable' redolog to base image
5. Disk image info

0. Quit

Please choose one [0] 1

Create image

Do you want to create a floppy disk image or a hard disk image?
Please type hd or fd. [hd] fd

Choose the size of floppy disk image to create.
Please type 160k, 180k, 320k, 360k, 720k, 1.2M, 1.44M, 1.68M, 1.72M, or 2.88M.
 [1.44M] 

What should be the name of the image?
[a.img] boot.img

Creating floppy image 'boot.img' with 2880 sectors

The following line should appear in your bochsrc:
  floppya: image="boot.img", status=inserted
```

选择1，fd，软盘容量1.44MB是通用的3.5英寸软盘，然后对镜像文件取名

接下来可以选择5去查看磁盘信息，不过感觉内存少了点。查阅资料，正常3.5英寸软盘的容量是1.44 MB=1440×1024KB=1474560 B，软盘共包含2个磁头、80个磁道、18个扇区。此处的bximage工具只正确解析出虚拟磁盘容量是1474560 B，bximage工具是按照1MB进行计算的，确实不大对，不过应该不影响？

### 运行Boot程序

#### 编译引导程序

```bash
nasm boot.asm -o boot.bin
```

#### 使用dd命令把引导程序写入引导扇区

```bash
dd if=boot.bin of=./bochs-2.6.9/boot.img bs=512 count=1 conv=notrunc
```

运行成功

```bash
(root@localhost 1]# dd if=boot.bin of=./bochs-2.6.9/boot.img bs=512 count=1 conv=notrunc
1+0 records in
1+0 records out
512 bytes (512 B) copied, 0.000155041 s,2.2 MB/s 
```

成功的样子大概这样

#### bochs命令启动虚拟机

```bash
bochs -f ./bochsrc
```

这里的**bochsrc**我在**bochs-2.6.9**文件夹中没有找到，运行这个命令也会报错，我就上网搜了一下，发现这个**bochsrc**并不存在，需要自己写

#### bochsrc文件

终端输入生成文件

```bash
vi bochsrc
```

bochsrc内容为

```
megs:32
 
romimage:file=$BXSHARE/BIOS-bochs-latest
vgaromimage:file=$BXSHARE/VGABIOS-lgpl-latest
 
floppya:1_44=boot.img,status=inserted  //.img换成自己软盘的名字
 
boot:floppy
 
log:bochsout.txt
 
mouse:enabled=0
 
keyboard: keymap=$BXSHARE/keymaps/x11-pc-de.map
```

然后ESC输入”:wq“保存就可以了

然后运行

```bash
bochs -f ./bochsrc
```

生成成功后大概是这样

```bash
@ubuntu:~/bochs-2.6.9$ bochs -f ./bochsrc
========================================================================
                       Bochs x86 Emulator 2.6.9
               Built from SVN snapshot on April 9, 2017
                  Compiled on Aug 15 2023 at 23:59:28
========================================================================
00000000000i[      ] BXSHARE not set. using compile time default '/usr/local/share/bochs'
00000000000i[      ] reading configuration from ./bochsrc
------------------------------
Bochs Configuration: Main Menu
------------------------------

This is the Bochs Configuration Interface, where you can describe the
machine that you want to simulate.  Bochs has already searched for a
configuration file (typically called bochsrc.txt) and loaded it if it
could be found.  When you are satisfied with the configuration, go
ahead and start the simulation.

You can also start bochs with the -q option to skip these menus.

1. Restore factory default configuration
2. Read options from...
3. Edit options
4. Save options to...
5. Restore the Bochs state from...
6. Begin simulation
7. Quit now

Please choose one: [6] 

```

默认选择6（表示开始运行虚拟机）

#### 运行

刚开始就是黑框

![image-20230830205648163](https://raw.githubusercontent.com/Enid1107/TyporaImgBed/main/Img/202308302056266.png)

然后在终端输入c/cont/continue任意一个就行

![boot运行成功](https://raw.githubusercontent.com/Enid1107/TyporaImgBed/main/Img/202308302058605.png)

ok，引导程序运行成功

##加载Loader到内存

选择FAT12文件系统来装载Loader程序和内核程序

FAT类文件系统会对软盘里的扇区进行结构化处理，进而把软盘扇区划分成引导扇区、FAT表、根目录区和数据区4部分。

![软盘文件系统分配图](https://raw.githubusercontent.com/Enid1107/TyporaImgBed/main/Img/202308311250475.png)
