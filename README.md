# AyaTsuki —— 基于Risc-V的CPU

## 项目简介

AyaTsuki是一款基于Risc-V指令集的CPU，具有四级流水线（IF-ID-EX-MEMWB）。AyaTsuki的命名取自本人所属开发团队 LingYue Studio。目前该CPU处于第一次迭代开发周期中。

## 项目完成度

* 当前已经兼容RV32I最小指令集
* RV32M的拓展兼容已经完成
* 外部总线的拓展兼容已经完成
* 已经完成了分支预测，预测准确率在70%左右。功能发布在version 0.1.1-alpha分支中
* 完成了BRAM的外部兼容，可以进一步对总线的时钟进行兼容匹配
* 完成了FPGA上移植，已经在Xilinx Spartan3E FPGA上成功运行
* 完成UART串口、TIM定时器的外设设计，大致确定了外设的总线机制
* 完成中断和CPU异常机制的初步设计（clint模块和ctrl模块兼容）

## 项目计划

* 兼容RV32M，并兼容多周期指令乱序处理（ctrl等待机制和乱序重排）
* 完善CPU权限状态，争取兼容类Unix操作系统（csr寄存器机制）
* 完成RIB总线机制，以支持外设的开发（ctrl模块等待机制）
* FFT快速傅里叶变换的外设
* 引入自行设计的CPU调试和监视模块

## 版本迭代

|日期|版本号|迭代内容|
|-|:-:|:-:|
|2022.05.06|version 0.2.0-Alpha|完成了CPU异常状态和中断功能|
|2022.04.04|version 0.1.1-Beta|完成了FPGA实机测试|
|2022.04.01|version 0.1.1-Alpha|完成了分支预测功能|
|2022.03.31|verison 0.1.0-Beta|完成了最小指令集兼容|

## 致谢

* 感谢 Ye LingDong 对本项目的技术支持
* 感谢 HF 老师执教的数字电路与系统
* 感谢 咸鱼 提供的计算机组成原理课程相关内容

## 说在最后

写一个自己的CPU，可以说是我做了六年的大梦。从初三刚刚学到电磁继电器，便开始想——能不能通过电流控制继电器的开关，从而完成逻辑上的计算？事实上这个设想早在40年代就已经实现了。
    
后来到了高中，便开始零散地学习数字电路的相关知识，在还不了解寄存器这个东西的时候，便自己动手在Minecraft里面做了一个并不完善的CPU，与其说是CPU，不如说那其实是一个计算器吧（笑）。

大学去了电子学院，但是后来才知道我们的电子学院完全不会教计算机的组成原理相关知识，于是连着两年都忙于学业，于是把它放下了。大三那会学了点数字电路，并且学了点verilog，做了几个实验，渐渐的放下了两年的东西又重新拿了起来。

最后鼓动我一鼓作气完成这个项目的还是一个契机：H 老师据说要在第二年的数字电路课的实验内容中加上CPU的制造。我便有了自己直接动手写一个CPU的动机。

最开始当然是困难的，但是有了 Ye LingDong 的鼓励，H老师为我打下的数字电路基础以及计算机学院同学的鼎力相助，我最终还是用了几天完成了这个CPU的初步构建。

当然了，距离完全完成还有很长的距离，这个项目在我并不完善的知识体系下到底还能走多远谁也不知道，只不过现在，我还是可以告慰六年前的自己：大梦终于到醒过来实现它的时候了。