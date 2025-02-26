const std = @import("std");

pub const OPCode = enum(u8) {
    ADC,
    AND,
    ASL,
    BCC,
    BCS,
    BEQ,
    BIT,
    BMI,
    BNE,
    BPL,
    BRK,
    BVC,
    BVS,
    CLC,
    CLD,
    CLI,
    CLV,
    CMP,
    CPX,
    CPY,
    DEC,
    DEX,
    DEY,
    EOR,
    INC,
    INX,
    INY,
    JMP,
    JSR,
    LDA,
    LDX,
    LDY,
    LSR,
    NOP,
    ORA,
    PHA,
    PHP,
    PLA,
    PLP,
    ROL,
    ROR,
    RTI,
    RTS,
    SBC,
    SEC,
    SED,
    SEI,
    STA,
    STX,
    STY,
    TAX,
    TAY,
    TSX,
    TXA,
    TXS,
    TYA,

    // illegal operations
    ALR,
    ANC,
    ANC2,
    ANE,
    ARR,
    DCP,
    ISC,
    LAS,
    LAX,
    LXA,
    RLA,
    RRA,
    SAX,
    SBX,
    SHA,
    SHX,
    SHY,
    SLO,
    SRE,
    TAS,
    USBC,
    NOP2,
    HLT,
};

pub const ADDRMode = enum(u8) {
    implicit,
    accumulator,
    immediate,
    zero_page,
    zero_page_x,
    zero_page_y,
    relative,
    absolute,
    absolute_x,
    absolute_y,
    indirect,
    indexed_indirect,
    indirect_indexed,
};

pub const OP = packed struct {
    op_code: OPCode,
    addressing_mode: ADDRMode,
    argsize: u8,

    // TODO: fill all the cycles (to match the original instruction latency)
    cicles: u8 = 0,
};

fn genOptable() [std.math.maxInt(u8) + 1]?OP {
    var buffer = [_]?OP{null} ** (std.math.maxInt(u8) + 1);

    // formally documented /legal/ opcodes
    buffer[0x69] = OP{ .op_code = .ADC, .addressing_mode = .immediate, .argsize = 1 };
    buffer[0x65] = OP{ .op_code = .ADC, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x75] = OP{ .op_code = .ADC, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0x6d] = OP{ .op_code = .ADC, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0x7d] = OP{ .op_code = .ADC, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0x79] = OP{ .op_code = .ADC, .addressing_mode = .absolute_y, .argsize = 2 };
    buffer[0x61] = OP{ .op_code = .ADC, .addressing_mode = .indexed_indirect, .argsize = 1 };
    buffer[0x71] = OP{ .op_code = .ADC, .addressing_mode = .indirect_indexed, .argsize = 1 };

    buffer[0x29] = OP{ .op_code = .AND, .addressing_mode = .immediate, .argsize = 1 };
    buffer[0x25] = OP{ .op_code = .AND, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x35] = OP{ .op_code = .AND, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0x2d] = OP{ .op_code = .AND, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0x3d] = OP{ .op_code = .AND, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0x39] = OP{ .op_code = .AND, .addressing_mode = .absolute_y, .argsize = 2 };
    buffer[0x21] = OP{ .op_code = .AND, .addressing_mode = .indexed_indirect, .argsize = 1 };
    buffer[0x31] = OP{ .op_code = .AND, .addressing_mode = .indirect_indexed, .argsize = 1 };

    buffer[0x0a] = OP{ .op_code = .ASL, .addressing_mode = .accumulator, .argsize = 0 };
    buffer[0x06] = OP{ .op_code = .ASL, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x16] = OP{ .op_code = .ASL, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0x0e] = OP{ .op_code = .ASL, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0x1e] = OP{ .op_code = .ASL, .addressing_mode = .absolute_x, .argsize = 2 };

    buffer[0x90] = OP{ .op_code = .BCC, .addressing_mode = .relative, .argsize = 1 };

    buffer[0xb0] = OP{ .op_code = .BCS, .addressing_mode = .relative, .argsize = 1 };

    buffer[0xf0] = OP{ .op_code = .BEQ, .addressing_mode = .relative, .argsize = 1 };

    buffer[0x24] = OP{ .op_code = .BIT, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x2c] = OP{ .op_code = .BIT, .addressing_mode = .absolute, .argsize = 2 };

    buffer[0x30] = OP{ .op_code = .BMI, .addressing_mode = .relative, .argsize = 1 };

    buffer[0xd0] = OP{ .op_code = .BNE, .addressing_mode = .relative, .argsize = 1 };

    buffer[0x10] = OP{ .op_code = .BPL, .addressing_mode = .relative, .argsize = 1 };

    buffer[0x00] = OP{ .op_code = .BRK, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0x50] = OP{ .op_code = .BVC, .addressing_mode = .relative, .argsize = 1 };

    buffer[0x70] = OP{ .op_code = .BVS, .addressing_mode = .relative, .argsize = 1 };

    buffer[0x18] = OP{ .op_code = .CLC, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0xd8] = OP{ .op_code = .CLD, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0x58] = OP{ .op_code = .CLI, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0xb8] = OP{ .op_code = .CLV, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0xc9] = OP{ .op_code = .CMP, .addressing_mode = .immediate, .argsize = 1 };
    buffer[0xc5] = OP{ .op_code = .CMP, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0xd5] = OP{ .op_code = .CMP, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0xcd] = OP{ .op_code = .CMP, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0xdd] = OP{ .op_code = .CMP, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0xd9] = OP{ .op_code = .CMP, .addressing_mode = .absolute_y, .argsize = 2 };
    buffer[0xc1] = OP{ .op_code = .CMP, .addressing_mode = .indexed_indirect, .argsize = 1 };
    buffer[0xd1] = OP{ .op_code = .CMP, .addressing_mode = .indirect_indexed, .argsize = 1 };

    buffer[0xe0] = OP{ .op_code = .CPX, .addressing_mode = .immediate, .argsize = 1 };
    buffer[0xe4] = OP{ .op_code = .CPX, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0xec] = OP{ .op_code = .CPX, .addressing_mode = .absolute, .argsize = 2 };

    buffer[0xc0] = OP{ .op_code = .CPY, .addressing_mode = .immediate, .argsize = 1 };
    buffer[0xc4] = OP{ .op_code = .CPY, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0xcc] = OP{ .op_code = .CPY, .addressing_mode = .absolute, .argsize = 2 };

    buffer[0xc6] = OP{ .op_code = .DEC, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0xd6] = OP{ .op_code = .DEC, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0xce] = OP{ .op_code = .DEC, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0xde] = OP{ .op_code = .DEC, .addressing_mode = .absolute_x, .argsize = 2 };

    buffer[0xca] = OP{ .op_code = .DEX, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0x88] = OP{ .op_code = .DEY, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0x49] = OP{ .op_code = .EOR, .addressing_mode = .immediate, .argsize = 1 };
    buffer[0x45] = OP{ .op_code = .EOR, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x55] = OP{ .op_code = .EOR, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0x4d] = OP{ .op_code = .EOR, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0x5d] = OP{ .op_code = .EOR, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0x59] = OP{ .op_code = .EOR, .addressing_mode = .absolute_y, .argsize = 2 };
    buffer[0x41] = OP{ .op_code = .EOR, .addressing_mode = .indexed_indirect, .argsize = 1 };
    buffer[0x51] = OP{ .op_code = .EOR, .addressing_mode = .indirect_indexed, .argsize = 1 };

    buffer[0xe6] = OP{ .op_code = .INC, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0xf6] = OP{ .op_code = .INC, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0xee] = OP{ .op_code = .INC, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0xfe] = OP{ .op_code = .INC, .addressing_mode = .absolute_x, .argsize = 2 };

    buffer[0xe8] = OP{ .op_code = .INX, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0xc8] = OP{ .op_code = .INY, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0x4c] = OP{ .op_code = .JMP, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0x6c] = OP{ .op_code = .JMP, .addressing_mode = .indirect, .argsize = 2 };

    buffer[0x20] = OP{ .op_code = .JSR, .addressing_mode = .absolute, .argsize = 2 };

    buffer[0xa9] = OP{ .op_code = .LDA, .addressing_mode = .immediate, .argsize = 1 };
    buffer[0xa5] = OP{ .op_code = .LDA, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0xb5] = OP{ .op_code = .LDA, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0xad] = OP{ .op_code = .LDA, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0xbd] = OP{ .op_code = .LDA, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0xb9] = OP{ .op_code = .LDA, .addressing_mode = .absolute_y, .argsize = 2 };
    buffer[0xa1] = OP{ .op_code = .LDA, .addressing_mode = .indexed_indirect, .argsize = 1 };
    buffer[0xb1] = OP{ .op_code = .LDA, .addressing_mode = .indirect_indexed, .argsize = 1 };

    buffer[0xa2] = OP{ .op_code = .LDX, .addressing_mode = .immediate, .argsize = 1 };
    buffer[0xa6] = OP{ .op_code = .LDX, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0xb6] = OP{ .op_code = .LDX, .addressing_mode = .zero_page_y, .argsize = 1 };
    buffer[0xae] = OP{ .op_code = .LDX, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0xbe] = OP{ .op_code = .LDX, .addressing_mode = .absolute_y, .argsize = 2 };

    buffer[0xa0] = OP{ .op_code = .LDY, .addressing_mode = .immediate, .argsize = 1 };
    buffer[0xa4] = OP{ .op_code = .LDY, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0xb4] = OP{ .op_code = .LDY, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0xac] = OP{ .op_code = .LDY, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0xbc] = OP{ .op_code = .LDY, .addressing_mode = .absolute_x, .argsize = 2 };

    buffer[0x4a] = OP{ .op_code = .LSR, .addressing_mode = .accumulator, .argsize = 0 };
    buffer[0x46] = OP{ .op_code = .LSR, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x56] = OP{ .op_code = .LSR, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0x4e] = OP{ .op_code = .LSR, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0x5e] = OP{ .op_code = .LSR, .addressing_mode = .absolute_x, .argsize = 2 };

    buffer[0xea] = OP{ .op_code = .NOP, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0x09] = OP{ .op_code = .ORA, .addressing_mode = .immediate, .argsize = 1 };
    buffer[0x05] = OP{ .op_code = .ORA, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x15] = OP{ .op_code = .ORA, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0x0d] = OP{ .op_code = .ORA, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0x1d] = OP{ .op_code = .ORA, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0x19] = OP{ .op_code = .ORA, .addressing_mode = .absolute_y, .argsize = 2 };
    buffer[0x01] = OP{ .op_code = .ORA, .addressing_mode = .indexed_indirect, .argsize = 1 };
    buffer[0x11] = OP{ .op_code = .ORA, .addressing_mode = .indirect_indexed, .argsize = 1 };

    buffer[0x48] = OP{ .op_code = .PHA, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0x08] = OP{ .op_code = .PHP, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0x68] = OP{ .op_code = .PLA, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0x28] = OP{ .op_code = .PLP, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0x2a] = OP{ .op_code = .ROL, .addressing_mode = .accumulator, .argsize = 0 };
    buffer[0x26] = OP{ .op_code = .ROL, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x36] = OP{ .op_code = .ROL, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0x2e] = OP{ .op_code = .ROL, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0x3e] = OP{ .op_code = .ROL, .addressing_mode = .absolute_x, .argsize = 2 };

    buffer[0x6a] = OP{ .op_code = .ROR, .addressing_mode = .accumulator, .argsize = 0 };
    buffer[0x66] = OP{ .op_code = .ROR, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x76] = OP{ .op_code = .ROR, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0x6e] = OP{ .op_code = .ROR, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0x7e] = OP{ .op_code = .ROR, .addressing_mode = .absolute_x, .argsize = 2 };

    buffer[0x40] = OP{ .op_code = .RTI, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0x60] = OP{ .op_code = .RTS, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0xe9] = OP{ .op_code = .SBC, .addressing_mode = .immediate, .argsize = 1 };
    buffer[0xe5] = OP{ .op_code = .SBC, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0xf5] = OP{ .op_code = .SBC, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0xed] = OP{ .op_code = .SBC, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0xfd] = OP{ .op_code = .SBC, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0xf9] = OP{ .op_code = .SBC, .addressing_mode = .absolute_y, .argsize = 2 };
    buffer[0xe1] = OP{ .op_code = .SBC, .addressing_mode = .indexed_indirect, .argsize = 1 };
    buffer[0xf1] = OP{ .op_code = .SBC, .addressing_mode = .indirect_indexed, .argsize = 1 };

    buffer[0x38] = OP{ .op_code = .SEC, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0xf8] = OP{ .op_code = .SED, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0x78] = OP{ .op_code = .SEI, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0x85] = OP{ .op_code = .STA, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x95] = OP{ .op_code = .STA, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0x8d] = OP{ .op_code = .STA, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0x9d] = OP{ .op_code = .STA, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0x99] = OP{ .op_code = .STA, .addressing_mode = .absolute_y, .argsize = 2 };
    buffer[0x81] = OP{ .op_code = .STA, .addressing_mode = .indexed_indirect, .argsize = 1 };
    buffer[0x91] = OP{ .op_code = .STA, .addressing_mode = .indirect_indexed, .argsize = 1 };

    buffer[0x86] = OP{ .op_code = .STX, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x96] = OP{ .op_code = .STX, .addressing_mode = .zero_page_y, .argsize = 1 };
    buffer[0x8e] = OP{ .op_code = .STX, .addressing_mode = .absolute, .argsize = 2 };

    buffer[0x84] = OP{ .op_code = .STY, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x94] = OP{ .op_code = .STY, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0x8c] = OP{ .op_code = .STY, .addressing_mode = .absolute, .argsize = 2 };

    buffer[0xaa] = OP{ .op_code = .TAX, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0xa8] = OP{ .op_code = .TAY, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0xba] = OP{ .op_code = .TSX, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0x8a] = OP{ .op_code = .TXA, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0x9a] = OP{ .op_code = .TXS, .addressing_mode = .implicit, .argsize = 0 };

    buffer[0x98] = OP{ .op_code = .TYA, .addressing_mode = .implicit, .argsize = 0 };

    // not formally documented /illegal/ opcodes
    buffer[0x4b] = OP{ .op_code = .ALR, .addressing_mode = .immediate, .argsize = 1 };

    buffer[0x0b] = OP{ .op_code = .ANC, .addressing_mode = .immediate, .argsize = 1 };

    buffer[0x2b] = OP{ .op_code = .ANC2, .addressing_mode = .immediate, .argsize = 1 };

    buffer[0x8b] = OP{ .op_code = .ANE, .addressing_mode = .immediate, .argsize = 1 };

    buffer[0x6b] = OP{ .op_code = .ARR, .addressing_mode = .immediate, .argsize = 1 };

    buffer[0xc7] = OP{ .op_code = .DCP, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0xd7] = OP{ .op_code = .DCP, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0xcf] = OP{ .op_code = .DCP, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0xdf] = OP{ .op_code = .DCP, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0xdb] = OP{ .op_code = .DCP, .addressing_mode = .absolute_y, .argsize = 2 };
    buffer[0xc3] = OP{ .op_code = .DCP, .addressing_mode = .indexed_indirect, .argsize = 1 };
    buffer[0xd3] = OP{ .op_code = .DCP, .addressing_mode = .indirect_indexed, .argsize = 1 };

    buffer[0xe7] = OP{ .op_code = .ISC, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0xf7] = OP{ .op_code = .ISC, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0xef] = OP{ .op_code = .ISC, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0xff] = OP{ .op_code = .ISC, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0xfb] = OP{ .op_code = .ISC, .addressing_mode = .absolute_y, .argsize = 2 };
    buffer[0xe3] = OP{ .op_code = .ISC, .addressing_mode = .indexed_indirect, .argsize = 1 };
    buffer[0xf3] = OP{ .op_code = .ISC, .addressing_mode = .indirect_indexed, .argsize = 1 };

    buffer[0xbb] = OP{ .op_code = .LAS, .addressing_mode = .absolute_y, .argsize = 2 };

    buffer[0xa7] = OP{ .op_code = .LAX, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0xb7] = OP{ .op_code = .LAX, .addressing_mode = .zero_page_y, .argsize = 1 };
    buffer[0xaf] = OP{ .op_code = .LAX, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0xbf] = OP{ .op_code = .LAX, .addressing_mode = .absolute_y, .argsize = 2 };
    buffer[0xa3] = OP{ .op_code = .LAX, .addressing_mode = .indexed_indirect, .argsize = 1 };
    buffer[0xb3] = OP{ .op_code = .LAX, .addressing_mode = .indirect_indexed, .argsize = 1 };

    buffer[0xab] = OP{ .op_code = .LXA, .addressing_mode = .immediate, .argsize = 1 };

    buffer[0x27] = OP{ .op_code = .RLA, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x37] = OP{ .op_code = .RLA, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0x2f] = OP{ .op_code = .RLA, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0x3f] = OP{ .op_code = .RLA, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0x3b] = OP{ .op_code = .RLA, .addressing_mode = .absolute_y, .argsize = 2 };
    buffer[0x23] = OP{ .op_code = .RLA, .addressing_mode = .indexed_indirect, .argsize = 1 };
    buffer[0x33] = OP{ .op_code = .RLA, .addressing_mode = .indirect_indexed, .argsize = 1 };

    buffer[0x67] = OP{ .op_code = .RRA, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x77] = OP{ .op_code = .RRA, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0x6f] = OP{ .op_code = .RRA, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0x7f] = OP{ .op_code = .RRA, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0x7b] = OP{ .op_code = .RRA, .addressing_mode = .absolute_y, .argsize = 2 };
    buffer[0x63] = OP{ .op_code = .RRA, .addressing_mode = .indexed_indirect, .argsize = 1 };
    buffer[0x73] = OP{ .op_code = .RRA, .addressing_mode = .indirect_indexed, .argsize = 1 };

    buffer[0x87] = OP{ .op_code = .SAX, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x97] = OP{ .op_code = .SAX, .addressing_mode = .zero_page_y, .argsize = 1 };
    buffer[0x8f] = OP{ .op_code = .SAX, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0x83] = OP{ .op_code = .SAX, .addressing_mode = .indexed_indirect, .argsize = 1 };

    buffer[0xcb] = OP{ .op_code = .SBX, .addressing_mode =  .immediate, .argsize = 1 };

    buffer[0x9f] = OP{ .op_code = .SHA, .addressing_mode = .absolute_y, .argsize = 2 };
    buffer[0x93] = OP{ .op_code = .SHA, .addressing_mode = .indirect_indexed, .argsize = 2 };

    buffer[0x9e] = OP{ .op_code = .SHX, .addressing_mode = .absolute_y, .argsize = 2 };

    buffer[0x9c] = OP{ .op_code = .SHY, .addressing_mode = .absolute_x, .argsize = 2 };

    buffer[0x07] = OP{ .op_code = .SLO, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x17] = OP{ .op_code = .SLO, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0x0f] = OP{ .op_code = .SLO, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0x1f] = OP{ .op_code = .SLO, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0x1b] = OP{ .op_code = .SLO, .addressing_mode = .absolute_y, .argsize = 2 };
    buffer[0x03] = OP{ .op_code = .SLO, .addressing_mode = .indexed_indirect, .argsize = 1 };
    buffer[0x13] = OP{ .op_code = .SLO, .addressing_mode = .indirect_indexed, .argsize = 1 };

    buffer[0x47] = OP{ .op_code = .SRE, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x57] = OP{ .op_code = .SRE, .addressing_mode = .zero_page_x, .argsize = 1};
    buffer[0x4f] = OP{ .op_code = .SRE, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0x5f] = OP{ .op_code = .SRE, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0x5b] = OP{ .op_code = .SRE, .addressing_mode = .absolute_y, .argsize = 2 };
    buffer[0x43] = OP{ .op_code = .SRE, .addressing_mode = .indexed_indirect, .argsize = 1 };
    buffer[0x53] = OP{ .op_code = .SRE, .addressing_mode = .indirect_indexed, .argsize = 1 };

    buffer[0x9b] = OP{ .op_code = .TAS, .addressing_mode = .absolute_y, .argsize = 2 };

    buffer[0xeb] = OP{ .op_code = .USBC, .addressing_mode = .immediate, .argsize = 1 };

    buffer[0x1a] = OP{ .op_code = .NOP2, .addressing_mode = .implicit, .argsize = 0 };
    buffer[0x3a] = OP{ .op_code = .NOP2, .addressing_mode = .implicit, .argsize = 0 };
    buffer[0x5a] = OP{ .op_code = .NOP2, .addressing_mode = .implicit, .argsize = 0 };
    buffer[0x7a] = OP{ .op_code = .NOP2, .addressing_mode = .implicit, .argsize = 0 };
    buffer[0xda] = OP{ .op_code = .NOP2, .addressing_mode = .implicit, .argsize = 0 };
    buffer[0xfa] = OP{ .op_code = .NOP2, .addressing_mode = .implicit, .argsize = 0 };
    buffer[0x80] = OP{ .op_code = .NOP2, .addressing_mode = .immediate, .argsize = 1 };
    buffer[0x82] = OP{ .op_code = .NOP2, .addressing_mode = .immediate, .argsize = 1 };
    buffer[0x89] = OP{ .op_code = .NOP2, .addressing_mode = .immediate, .argsize = 1 };
    buffer[0xc2] = OP{ .op_code = .NOP2, .addressing_mode = .immediate, .argsize = 1 };
    buffer[0xe2] = OP{ .op_code = .NOP2, .addressing_mode = .immediate, .argsize = 1 };
    buffer[0x04] = OP{ .op_code = .NOP2, .addressing_mode = .zero_page, .argsize= 1 };
    buffer[0x44] = OP{ .op_code = .NOP2, .addressing_mode = .zero_page, .argsize= 1 };
    buffer[0x64] = OP{ .op_code = .NOP2, .addressing_mode = .zero_page, .argsize = 1 };
    buffer[0x14] = OP{ .op_code = .NOP2, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0x34] = OP{ .op_code = .NOP2, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0x54] = OP{ .op_code = .NOP2, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0x74] = OP{ .op_code = .NOP2, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0xd4] = OP{ .op_code = .NOP2, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0xf4] = OP{ .op_code = .NOP2, .addressing_mode = .zero_page_x, .argsize = 1 };
    buffer[0x0c] = OP{ .op_code = .NOP2, .addressing_mode = .absolute, .argsize = 2 };
    buffer[0x1c] = OP{ .op_code = .NOP2, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0x3c] = OP{ .op_code = .NOP2, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0x5c] = OP{ .op_code = .NOP2, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0x7c] = OP{ .op_code = .NOP2, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0xdc] = OP{ .op_code = .NOP2, .addressing_mode = .absolute_x, .argsize = 2 };
    buffer[0xfc] = OP{ .op_code = .NOP2, .addressing_mode = .absolute_x, .argsize = 2 };

    buffer[0x02] = OP{ .op_code = .HLT, .addressing_mode = .implicit, .argsize = 0 };
    buffer[0x12] = OP{ .op_code = .HLT, .addressing_mode = .implicit, .argsize = 0 };
    buffer[0x22] = OP{ .op_code = .HLT, .addressing_mode = .implicit, .argsize = 0 };
    buffer[0x32] = OP{ .op_code = .HLT, .addressing_mode = .implicit, .argsize = 0 };
    buffer[0x42] = OP{ .op_code = .HLT, .addressing_mode = .implicit, .argsize = 0 };
    buffer[0x52] = OP{ .op_code = .HLT, .addressing_mode = .implicit, .argsize = 0 };
    buffer[0x62] = OP{ .op_code = .HLT, .addressing_mode = .implicit, .argsize = 0 };
    buffer[0x72] = OP{ .op_code = .HLT, .addressing_mode = .implicit, .argsize = 0 };
    buffer[0x92] = OP{ .op_code = .HLT, .addressing_mode = .implicit, .argsize = 0 };
    buffer[0xb2] = OP{ .op_code = .HLT, .addressing_mode = .implicit, .argsize = 0 };
    buffer[0xd2] = OP{ .op_code = .HLT, .addressing_mode = .implicit, .argsize = 0 };
    buffer[0xf2] = OP{ .op_code = .HLT, .addressing_mode = .implicit, .argsize = 0 };

    return buffer;
}

pub const optable = genOptable();


pub fn decodeWrite(reader: *std.io.AnyReader, writer: *std.io.AnyWriter) !void {
    std.debug.assert(optable.len >= std.math.maxInt(u8));

    var offset: usize = 0;
    while (reader.readByte()) |byte| : (offset += 1) {
        const op_read = optable[byte] orelse {
            try std.fmt.format(writer.*, "{x}:\t??? {x}\n", .{
                offset,
                byte,
            });

            continue;
        };

        std.debug.assert(op_read.argsize <= 2);

        // OP tagname
        try std.fmt.format(writer.*, "{x}:\t{s}", .{
            offset,
            @tagName(op_read.op_code),
        });

        //args (depending on the addressing mode)
        var args_buf_mem = [_]u8{0} ** 2;
        const args_buf = args_buf_mem[0..op_read.argsize];

        if (op_read.argsize != 0) offset += try reader.read(args_buf);

        switch (op_read.addressing_mode) {
            .implicit => {
                _ = try writer.writeByte('\n');
            },

            .accumulator => {
                _ = try writer.write(" A\n");
            },

            .immediate => {
                try std.fmt.format(writer.*, " #{x}\n", .{ args_buf[0] });
            },

            .zero_page => {
                try std.fmt.format(writer.*, " ${x} zp\n", .{ args_buf[0] });
            },

            .zero_page_x => {
                try std.fmt.format(writer.*, " ${x},X zp\n", .{ args_buf[0] });
            },

            .zero_page_y => {
                try std.fmt.format(writer.*, " ${x},Y zp\n", .{ args_buf[0] });
            },

            .relative => {
                try std.fmt.format(writer.*, " ${} rel\n", .{ @as(i8, @bitCast(args_buf[0])) });
            },

            .absolute => {
                const arg: u16 = @as(u16, args_buf[1]) * 256 + @as(u16, args_buf[0]);
                try std.fmt.format(writer.*, " ${x} abs\n", .{ arg });
            },

            .absolute_x => {
                const arg: u16 = @as(u16, args_buf[1]) * 256 + @as(u16, args_buf[0]);
                try std.fmt.format(writer.*, " ${x},X abs\n", .{ arg });
            },

            .absolute_y => {
                const arg: u16 = @as(u16, args_buf[1]) * 256 + @as(u16, args_buf[0]);
                try std.fmt.format(writer.*, " ${x},Y abs\n", .{ arg });
            },

            .indirect => {
                const arg: u16 = @as(u16, args_buf[1]) * 256 + @as(u16, args_buf[0]);
                try std.fmt.format(writer.*, " (${x})ind\n", .{ arg });
            },

            .indexed_indirect => {
                try std.fmt.format(writer.*, " (${x},X)\n", .{ args_buf[0] });
            },

            .indirect_indexed => {
                try std.fmt.format(writer.*, " (${x},Y)\n", .{ args_buf[0] });
            },
        }
    } else |err| if (err != error.EndOfStream) return err;
}
