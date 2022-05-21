# AyaTsuki —— 基于Risc-V的CPU

## 分支简介

该分支将CPU修正为五级流水线以求获得更好的WNS效果:

1. 当前流水线层面为：IF ID EX MEM WB
2. 修正了trans和ctrl模块以兼容五级流水线和后续时序差分处理
3. 修正了