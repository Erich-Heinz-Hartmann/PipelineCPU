# 五级流水线 MIPS CPU

简易的流水线 CPU 项目。

## 特性

- IF / ID / EX / MEM / WB 五级流水
- 分支在 ID 级解析，带延迟槽（`jal` 写回 `PC+8`）
- 采用 A-T 法（T_use / T_new）做转发与停顿控制，GRF 内部转发
- 支持指令：`add`、`sub`、`and`、`or`、`ori`、`lw`、`sw`、`beq`、`lui`、`jal`、`jr`、`nop`

## 文件说明

```
PipelineCPU/
├── mips.v              # 顶层
├── controller.v        # 控制器（含各指令 T_use / T_new）
├── forwarding_unit.v   # A-T 法转发 + 停顿
├── IF_ID.v / ID_EX.v / EX_MEM.v / MEM_WB.v   # 流水线寄存器
├── pc.v / npc.v        # PC 与下一地址逻辑
├── IM.v / DM.v         # 指令存储器 / 数据存储器
├── grf.v / alu.v       # 寄存器堆 / ALU
├── extender.v / splitter.v / branch_equal.v
└── README.md
```

## 使用方法

用 ISim 或其他 Verilog 仿真器编译全部 `.v`，顶层为 `mips`。仓库仅包含 RTL 源码，需自备 testbench；IM 从仿真工作目录的 `code.txt` 读入程序（起始地址 `0x3000`）。

## 已知注意

- DM 当前会忽略对地址 `0x00000000` 的 `sw`，且对 `0x3000` 以上地址无越界保护
- 未实现 `j`、`addi` 等指令；ALU 的 `shamt` 端口未接入（如需现场添加移位指令，需扩展）
