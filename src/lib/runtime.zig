const std = @import("std");
const logger = @import("logger.zig");
const op = @import("op.zig");

/// some memory accesses try to read/jump to/write/etc. to addresses over
/// 0xf000, which are translated to just the most significant 13 bits
///
/// also, the cpu only has that amount of address lines
const address_mask = 0x1fff;

/// the reset vector address is a 16 bit pointer at 0xFFFC-0xFFFD
const start_vector_addr = 0xfffc;

/// according to some
/// [documentation](https://web.archive.org/web/20221112220344if_/http://archive.6502.org/datasheets/synertek_programming_manual.pdf),
/// this is the expected address to search for the interrupt vector from, say, a
/// BRK instruction
const interrupt_vector_addr = 0xfffe;

const Context = struct {
    SP: u8 = 0,

    REG: packed struct {
        A: u8 = 0,
        X: u8 = 0,
        Y: u8 = 0,
    } = .{},

    STATUS: packed struct {
        pad: u1 = 0, // unused illegal field, its a bitpad to fit into a u8
        carry: u1 = 0,
        zero: u1 = 0,
        interrupt_disable: u1 = 0,
        decimal_mode: u1 = 0,
        break_cmd: u1 = 0,
        overflow: u1 = 0,
        negative: u1 = 0,
    } = .{},

    PC: u16 = 0,
};

const Command = enum {
    PrintCurrentOp,
    PrintCurrentCtx,

    ExecNextOp,
    Quit,
};

fn parseInput(input: []u8) !Command {
    if (std.mem.eql(u8, input, "p")) {
        return .PrintCurrentOp;
    } else if (std.mem.eql(u8, input, "n")) {
        return .ExecNextOp;
    } else if (std.mem.eql(u8, input, "ctx")) {
        return .PrintCurrentCtx;
    } else if (std.mem.eql(u8, input, "q")) {
        return .Quit;
    }

    return error.Unsupported;
}

/// resolves the arguments of a specific addressing mode into:
/// a) an absolute address to fetch memory at
/// b) a panic (since it shouldn't be called from .relative and .implicit modes)
/// c) the arg itself in immediate mode
inline fn resolveArg(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) u16 {
    return switch (addr_mode) {
        // both relative and implicit mean that you are not supposed to call
        // this function at all
        .relative, .implicit, .accumulator => {
            logger.simpleLogWithArgs("why did you even call this function on a {s} addressed  op", .{
                @tagName(addr_mode),
            });

            unreachable;
        },

        .immediate => arg.arg_1b,
        .zero_page => arg.arg_1b,

        // the wrap-around sum only applies for zero-page addresses, i.e., those
        // which are in the first 256 bytes range
        //
        // TODO: there must be a faster way to do this
        .zero_page_x => zp_x_value: {
            break :zp_x_value arg.arg_1b +% @as(u16, ctx.REG.X);
        },

        .zero_page_y => zp_y_value: {
            break :zp_y_value arg.arg_1b +% @as(u16, ctx.REG.Y);
        },

        .absolute => arg.arg_2b,
        .absolute_x => arg.arg_2b + @as(u16, ctx.REG.X),
        .absolute_y => arg.arg_2b + @as(u16, ctx.REG.Y),

        .indirect => ind_value: {
            const ptr = std.mem.readInt(u16, &.{
                memory[arg.arg_1b],
                memory[arg.arg_1b + 1],
            }, .little);

            break :ind_value ptr;
        },

        // wrap-around here because arg is supposed to be a zp ptr
        .indexed_indirect => idx_ind_value: {
            const fake_ptr = arg.arg_1b +% ctx.REG.X;
            const real_ptr = std.mem.readInt(u16, &.{
                memory[fake_ptr],
                memory[fake_ptr +% 1],
            }, .little);

            break :idx_ind_value real_ptr;
        },

        .indirect_indexed => idx_ind_value: {
            const fake_ptr = arg.arg_1b;
            const real_ptr = std.mem.readInt(u16, &.{
                memory[fake_ptr],
                memory[fake_ptr +% 1],
            }, .little) +% @as(u16, ctx.REG.Y);

            break :idx_ind_value real_ptr;
        },
    };
}

const ExecNextError = error {
    OpNotFound,
    InvalidArgSize,
};

const ExecArg = union {
    arg_0b: void,
    arg_1b: u8,
    arg_2b: u16
};

fn execADC(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const acum = ctx.REG.A;
    const additive_ptr = resolveArg(ctx, memory, arg, addr_mode);
    const additive = memory[additive_ptr];
    const add_result = @addWithOverflow(acum, additive);

    ctx.REG.A = add_result[0];

    // to get the overflow bit, we assume both the argument and the additive are
    // i8's
    ctx.STATUS.overflow =
        if (acum & 0x80 == additive & 0x80)
            @intFromBool(add_result[0] & 0x80 != acum & 0x80)
        else
            0;

    ctx.STATUS.carry = add_result[1];
    ctx.STATUS.zero = @intFromBool(add_result[0] == 0);
    ctx.STATUS.negative = @truncate(add_result[0] >> 7);
}

fn execAND(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const acum = ctx.REG.A;
    const comparer_ptr = resolveArg(ctx, memory, arg, addr_mode);
    const comparer = memory[comparer_ptr];
    const result = acum & comparer;

    ctx.REG.A = result;

    ctx.STATUS.zero = @intFromBool(result == 0);
    ctx.STATUS.negative = @truncate(result >> 7);
}

fn execASL(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    if (addr_mode == .accumulator) {
        const result = @shlWithOverflow(ctx.REG.A, 1);

        ctx.REG.A = result[0];

        ctx.STATUS.carry = result[1];
        ctx.STATUS.zero = @intFromBool(result[0] == 0);
        ctx.STATUS.negative = @truncate(result[0] >> 7);
    } else {
        const ptr_or_value = resolveArg(ctx, memory, arg, addr_mode);
        const result = @shlWithOverflow(memory[ptr_or_value], 1);

        memory[ptr_or_value] = result[0];

        ctx.STATUS.carry = result[1];
        ctx.STATUS.zero = @intFromBool(result[0] == 0);
        ctx.STATUS.negative = @truncate(result[0] >> 7);
    }
}

fn execBIT(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const ptr = resolveArg(ctx, memory, arg, addr_mode);
    const mask = ctx.REG.A & memory[ptr];

    ctx.STATUS.zero = @intFromBool(mask == 0);
    ctx.STATUS.overflow = @truncate(mask & 0b00100000 >> 5);
    ctx.STATUS.negative = @truncate(mask & 0b01000000 >> 6);
}

// branch instructions
// ===
fn execBPL(ctx: *Context, arg: u8) void {
    if (ctx.STATUS.negative == 1) return;

    const signed_arg: i8 = @bitCast(arg);
    if (signed_arg > 0) {
        ctx.PC += @as(u16, @intCast(signed_arg));
    } else {
        ctx.PC -= @as(u16, @intCast(-signed_arg));
    }
}

fn execBMI(ctx: *Context, arg: u8) void {
    if (ctx.STATUS.negative == 0) return;

    const signed_arg: i8 = @bitCast(arg);
    if (signed_arg > 0) {
        ctx.PC += @as(u16, @intCast(signed_arg));
    } else {
        ctx.PC -= @as(u16, @intCast(-signed_arg));
    }
}

fn execBCC(ctx: *Context, arg: u8) void {
    if (ctx.STATUS.carry == 1) return;

    const signed_arg: i8 = @bitCast(arg);
    if (signed_arg > 0) {
        ctx.PC += @as(u16, @intCast(signed_arg));
    } else {
        ctx.PC -= @as(u16, @intCast(-signed_arg));
    }
}

fn execBCS(ctx: *Context, arg: u8) void {
    if (ctx.STATUS.carry == 0) return;

    const signed_arg: i8 = @bitCast(arg);
    if (signed_arg > 0) {
        ctx.PC += @as(u16, @intCast(signed_arg));
    } else {
        ctx.PC -= @as(u16, @intCast(-signed_arg));
    }
}

fn execBNE(ctx: *Context, arg: u8) void {
    if (ctx.STATUS.zero == 1) return;

    const signed_arg: i8 = @bitCast(arg);
    if (signed_arg > 0) {
        ctx.PC += @as(u16, @intCast(signed_arg));
    } else {
        ctx.PC -= @as(u16, @intCast(-signed_arg));
    }
}

fn execBEQ(ctx: *Context, arg: u8) void {
    if (ctx.STATUS.zero == 0) return;

    const signed_arg: i8 = @bitCast(arg);
    if (signed_arg > 0) {
        ctx.PC += @as(u16, @intCast(signed_arg));
    } else {
        ctx.PC -= @as(u16, @intCast(-signed_arg));
    }
}

fn execBVC(ctx: *Context, arg: u8) void {
    if (ctx.STATUS.overflow == 1) return;

    const signed_arg: i8 = @bitCast(arg);
    if (signed_arg > 0) {
        ctx.PC += @as(u16, @intCast(signed_arg));
    } else {
        ctx.PC -= @as(u16, @intCast(-signed_arg));
    }
}

fn execBVS(ctx: *Context, arg: u8) void {
    if (ctx.STATUS.overflow == 0) return;

    const signed_arg: i8 = @bitCast(arg);
    if (signed_arg > 0) {
        ctx.PC += @as(u16, @intCast(signed_arg));
    } else {
        ctx.PC -= @as(u16, @intCast(-signed_arg));
    }
}
// ===

fn execBRK(ctx: *Context, memory: []u8) void {
    const status_byte: u8 = @bitCast(ctx.STATUS);
    const rti_pc = ctx.PC + 1;
    var stack_ptr = ctx.SP;

    const interrupt_vector = std.mem.readInt(u16, &.{
        memory[(start_vector_addr & address_mask)],
        memory[((start_vector_addr + 1) & address_mask)],
    }, .little);

    var buffer = [_]u8{ 0 } ** 2;
    std.mem.writeInt(u16, buffer[0..], rti_pc, .little);

    memory[stack_ptr] = buffer[1];
    stack_ptr -= 1;

    memory[stack_ptr] = buffer[0];
    stack_ptr -= 1;

    memory[stack_ptr] = status_byte;
    stack_ptr -= 1;

    ctx.SP = stack_ptr;
    ctx.PC = interrupt_vector;
    ctx.STATUS.break_cmd = 1;
}


// flag clearing instructions
// ===
fn execCLC(ctx: *Context) void {
    ctx.STATUS.carry = 0;
}

fn execCLD(ctx: *Context) void {
    ctx.STATUS.decimal_mode = 0;
}

fn execCLI(ctx: *Context) void {
    ctx.STATUS.interrupt_disable = 0;
}

fn execCLV(ctx: *Context) void {
    ctx.STATUS.overflow = 0;
}
// ===

// compare instructions
// ===
fn execCMP(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const ptr = resolveArg(ctx, memory, arg, addr_mode);
    const val = memory[ptr];
    const cmp = ctx.REG.A;

    if (cmp >= val) {
        ctx.STATUS.carry = 1;
    }

    if (cmp == val) {
        ctx.STATUS.zero = 1;
    }

    ctx.STATUS.negative = @truncate(cmp >> 7);
}

fn execCPX(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const ptr = resolveArg(ctx, memory, arg, addr_mode);
    const val = memory[ptr];
    const cmp = ctx.REG.X;

    if (cmp >= val) {
        ctx.STATUS.carry = 1;
    }

    if (cmp == val) {
        ctx.STATUS.zero = 1;
    }

    ctx.STATUS.negative = @truncate(cmp >> 7);
}

fn execCPY(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const ptr = resolveArg(ctx, memory, arg, addr_mode);
    const val = memory[ptr];
    const cmp = ctx.REG.Y;

    if (cmp >= val) {
        ctx.STATUS.carry = 1;
    }

    if (cmp == val) {
        ctx.STATUS.zero = 1;
    }

    ctx.STATUS.negative = @truncate(cmp >> 7);
}
// ===

// decrement instructions
// ===
fn execDEC(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const ptr = resolveArg(ctx, memory, arg, addr_mode);
    const val = memory[ptr];
    const n_val = val - 1;

    memory[ptr] = n_val;

    ctx.STATUS.zero = @intFromBool(n_val == 0);
    ctx.STATUS.negative = @truncate(n_val >> 7);
}

fn execDEX(ctx: *Context) void {
    const val = ctx.REG.X - 1;

    ctx.REG.X = val;
    ctx.STATUS.zero = @intFromBool(val == 0);
    ctx.STATUS.negative = @truncate(val >> 7);
}

fn execDEY(ctx: *Context) void {
    const val = ctx.REG.Y - 1;

    ctx.REG.Y = val;
    ctx.STATUS.zero = @intFromBool(val == 0);
    ctx.STATUS.negative = @truncate(val >> 7);
}
// ===

fn execEOR(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const ptr = resolveArg(ctx, memory, arg, addr_mode);
    const memval = memory[ptr];
    const accum = ctx.REG.A;
    const result = accum ^ memval;

    ctx.REG.A = result;
    ctx.STATUS.zero = @intFromBool(result == 0);
    ctx.STATUS.negative = @truncate(result >> 7);
}

fn execINC(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const ptr = resolveArg(ctx, memory, arg, addr_mode);
    const memval = memory[ptr];
    const result = memval + 1;

    memory[ptr] = result;

    ctx.STATUS.zero = @intFromBool(result == 0);
    ctx.STATUS.negative = @truncate(result >> 7);
}

fn execINX(ctx: *Context) void {
    const regstr = ctx.REG.X;
    const result = regstr + 1;

    ctx.REG.X = result;

    ctx.STATUS.zero = @intFromBool(result == 0);
    ctx.STATUS.negative = @truncate(result >> 7);
}

fn execINY(ctx: *Context) void {
    const regstr = ctx.REG.Y;
    const result = regstr + 1;

    ctx.REG.X = result;

    ctx.STATUS.zero = @intFromBool(result == 0);
    ctx.STATUS.negative = @truncate(result >> 7);
}

fn execJMP(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const ptr = resolveArg(ctx, memory, arg, addr_mode);

    ctx.PC = ptr;
}

fn execJSR(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const jmp_ptr = resolveArg(ctx, memory, arg, addr_mode);
    const rts_ptr = ctx.PC - 1;
    var stack_ptr = ctx.SP;

    const jmp_addr = std.mem.readInt(u16, &.{
        memory[(jmp_ptr & address_mask)],
        memory[((jmp_ptr + 1) & address_mask)],
    }, .little);

    var buffer = [_]u8{ 0 } ** 2;
    std.mem.writeInt(u16, buffer[0..], rts_ptr, .little);

    memory[stack_ptr] = buffer[1];
    stack_ptr -= 1;

    memory[stack_ptr] = buffer[0];
    stack_ptr -= 1;

    ctx.SP = stack_ptr;
    ctx.PC = jmp_addr;
}

fn execLDA(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const ptr = resolveArg(ctx, memory, arg, addr_mode);
    const new_value = memory[ptr];

    ctx.REG.A = new_value;
    ctx.STATUS.zero = @intFromBool(new_value == 0);
    ctx.STATUS.negative = @truncate(new_value >> 7);
}

fn execLDX(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const ptr = resolveArg(ctx, memory, arg, addr_mode);
    const new_value = memory[ptr];

    ctx.REG.X = new_value;
    ctx.STATUS.zero = @intFromBool(new_value == 0);
    ctx.STATUS.negative = @truncate(new_value >> 7);
}

fn execLDY(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const ptr = resolveArg(ctx, memory, arg, addr_mode);
    const new_value = memory[ptr];

    ctx.REG.Y = new_value;
    ctx.STATUS.zero = @intFromBool(new_value == 0);
    ctx.STATUS.negative = @truncate(new_value >> 7);
}

fn execLSR(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    if (addr_mode == .accumulator) {
        const fetched_value = ctx.REG.A;
        const new_value = fetched_value >> 1;

        // since there is no "shr with overflow", we have to mask the ls bit
        // individually
        const lower_bit: u1 = @truncate(fetched_value);

        ctx.REG.A = new_value;

        ctx.STATUS.carry = lower_bit;
        ctx.STATUS.zero = @intFromBool(new_value == 0);
        ctx.STATUS.negative = @truncate(new_value >> 7);
    } else {
        const ptr = resolveArg(ctx, memory, arg, addr_mode);
        const fetched_value = memory[ptr];
        const new_value = fetched_value >> 1;

        // since there is no "shr with overflow", we have to mask the ls bit
        // individually
        const lower_bit: u1 = @truncate(fetched_value);

        memory[ptr] = new_value;

        ctx.STATUS.carry = lower_bit;
        ctx.STATUS.zero = @intFromBool(new_value == 0);
        ctx.STATUS.negative = @truncate(new_value >> 7);
    }
}

fn execORA(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const ptr = resolveArg(ctx, memory, arg, addr_mode);
    const fetched_value = memory[ptr];
    const accum = ctx.REG.A;
    const new_value = accum | fetched_value;

    ctx.REG.A = new_value;
    ctx.STATUS.zero = @intFromBool(new_value == 0);
    ctx.STATUS.negative = @truncate(new_value >> 7);
}

fn execPHA(ctx: *Context, memory: []u8) void {
    const accum = ctx.REG.A;
    var stack_ptr = ctx.SP;

    memory[stack_ptr] = accum;
    stack_ptr -= 1;

    ctx.SP = stack_ptr;
}

fn execPHP(ctx: *Context, memory: []u8) void {
    const status: u8 = @bitCast(ctx.STATUS);
    var stack_ptr = ctx.SP;

    memory[stack_ptr] = status;
    stack_ptr -= 1;

    ctx.SP = stack_ptr;
}

fn execPLA(ctx: *Context, memory: []u8) void {
    var stack_ptr = ctx.SP;

    const new_accum = memory[stack_ptr];
    stack_ptr += 1;

    ctx.SP = stack_ptr;
    ctx.REG.A = new_accum;
    ctx.STATUS.zero = @intFromBool(new_accum == 0);
    ctx.STATUS.negative = @truncate(new_accum >> 7);
}

fn execPLP(ctx: *Context, memory: []u8) void {
    var stack_ptr = ctx.SP;

    const new_status = memory[stack_ptr];
    stack_ptr += 1;

    ctx.SP = stack_ptr;
    ctx.STATUS = @bitCast(new_status);
}

fn execROL(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    if (addr_mode == .accumulator) {
        const fetched_value = ctx.REG.A;
        const old_carry: u8 = @intCast(ctx.STATUS.carry);
        const new_value = (fetched_value << 1) | old_carry;
        const new_carry: u1 = @truncate(fetched_value >> 7);

        ctx.REG.A = new_value;

        ctx.STATUS.carry = new_carry;
        ctx.STATUS.zero = @intFromBool(new_value == 0);
        ctx.STATUS.negative = @truncate(new_value >> 7);
    } else {
        const ptr = resolveArg(ctx, memory, arg, addr_mode);
        const fetched_value = memory[ptr];

        // old carry is used to fill the rotational gap
        const old_carry: u8 = @intCast(ctx.STATUS.carry);

        // old bit 7 becomes new carry
        const new_carry: u1 = @truncate(fetched_value >> 7);
        const new_value = (fetched_value << 1) | old_carry;

        memory[ptr] = new_value;

        ctx.STATUS.carry = new_carry;
        ctx.STATUS.zero = @intFromBool(new_value == 0);
        ctx.STATUS.negative = @truncate(new_value >> 7);
    }
}

fn execROR(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    if (addr_mode == .accumulator) {
        const fetched_value = ctx.REG.A;

        const old_carry: u8 = @intCast(ctx.STATUS.carry);
        const new_carry: u1 = @truncate(fetched_value);

        const new_value = (fetched_value >> 1) | (old_carry << 7);

        ctx.REG.A = new_value;

        ctx.STATUS.carry = new_carry;
        ctx.STATUS.zero = @intFromBool(new_value == 0);
        ctx.STATUS.negative = @truncate(new_value >> 7);
    } else {
        const ptr = resolveArg(ctx, memory, arg, addr_mode);
        const fetched_value = memory[ptr];

        // old carry is used to fill the rotational gap
        const old_carry: u8 = @intCast(ctx.STATUS.carry);

        // old bit 7 becomes new carry
        const new_carry: u1 = @truncate(fetched_value);
        const new_value = (fetched_value >> 1) | (old_carry << 7);

        memory[ptr] = new_value;

        ctx.STATUS.carry = new_carry;
        ctx.STATUS.zero = @intFromBool(new_value == 0);
        ctx.STATUS.negative = @truncate(new_value >> 7);
    }
}

fn execRTI(ctx: *Context, memory: []u8) void {
    var stack_ptr = ctx.SP;

    const status_byte = memory[stack_ptr];
    stack_ptr += 1;

    var addr_ptr_buffer = [_]u8{ 0 } ** 2;
    addr_ptr_buffer[0] = memory[stack_ptr];
    stack_ptr += 1;

    addr_ptr_buffer[1] = memory[stack_ptr];
    stack_ptr += 1;

    const addr_ptr = std.mem.readInt(u16, addr_ptr_buffer[0..], .little);

    ctx.SP = stack_ptr;
    ctx.PC = addr_ptr;
    ctx.STATUS = @bitCast(status_byte);
}

fn execRTS(ctx: *Context, memory: []u8) void {
    var stack_ptr = ctx.SP;

    var addr_ptr_buffer = [_]u8{ 0 } ** 2;
    addr_ptr_buffer[0] = memory[stack_ptr];
    stack_ptr += 1;

    addr_ptr_buffer[1] = memory[stack_ptr];
    stack_ptr += 1;

    const addr_ptr = std.mem.readInt(u16, addr_ptr_buffer[0..], .little);

    ctx.SP = stack_ptr;
    ctx.PC = addr_ptr + 1;
}

fn execSBC(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const mem_idx = resolveArg(ctx, memory, arg, addr_mode);
    const mem_value = memory[mem_idx];
    const accum = ctx.REG.A;
    const result = @subWithOverflow(accum, mem_value);
    const new_accum = result[0];

    ctx.REG.A = new_accum - @as(u8, @intCast(~ctx.STATUS.carry));
    ctx.STATUS.carry = ~result[1];
    ctx.STATUS.zero = @intFromBool(new_accum == 0);
    ctx.STATUS.negative = @truncate(new_accum >> 7);
}

fn execSEC(ctx: *Context) void {
    ctx.STATUS.carry = 1;
}

fn execSED(ctx: *Context) void {
    ctx.STATUS.decimal_mode = 1;
}

fn execSEI(ctx: *Context) void {
    ctx.STATUS.interrupt_disable = 1;
}

fn execSTA(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const mem_idx = resolveArg(ctx, memory, arg, addr_mode);

    memory[mem_idx] = ctx.REG.A;
}

fn execSTX(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const mem_idx = resolveArg(ctx, memory, arg, addr_mode);

    memory[mem_idx] = ctx.REG.X;
}

fn execSTY(ctx: *Context, memory: []u8, arg: ExecArg, addr_mode: op.ADDRMode) void {
    const mem_idx = resolveArg(ctx, memory, arg, addr_mode);

    memory[mem_idx] = ctx.REG.Y;
}

fn execTAX(ctx: *Context) void {
    const accum = ctx.REG.A;

    ctx.REG.X = accum;
    ctx.STATUS.zero = @intFromBool(accum == 0);
    ctx.STATUS.negative = @truncate(accum >> 7);
}

fn execTAY(ctx: *Context) void {
    const accum = ctx.REG.A;

    ctx.REG.Y = accum;
    ctx.STATUS.zero = @intFromBool(accum == 0);
    ctx.STATUS.negative = @truncate(accum >> 7);
}

fn execTSX(ctx: *Context) void {
    const stack_ptr = ctx.SP;

    ctx.REG.X = stack_ptr;
    ctx.STATUS.zero = @intFromBool(stack_ptr == 0);
    ctx.STATUS.negative = @truncate(stack_ptr >> 7);
}

fn execTXA(ctx: *Context) void {
    const x_reg = ctx.REG.X;

    ctx.REG.A = x_reg;
    ctx.STATUS.zero = @intFromBool(x_reg == 0);
    ctx.STATUS.negative = @truncate(x_reg >> 7);
}

fn execTXS(ctx: *Context) void {
    const x_reg = ctx.REG.X;

    ctx.SP = x_reg;
}

fn execTYA(ctx: *Context) void {
    const y_reg = ctx.REG.X;

    ctx.REG.A = y_reg;
    ctx.STATUS.zero = @intFromBool(y_reg == 0);
    ctx.STATUS.negative = @truncate(y_reg >> 7);
}

fn execNext(ctx: *Context, memory: []u8) ExecNextError!void {
    // we first "fetch" the current PC state so instructions like `jmp` won't
    // get their address argument modified after the jump
    const pc_fetch = ctx.PC;

    const rom_op_addr = pc_fetch & address_mask;

    const rom_op = op.optable[memory[rom_op_addr]] orelse {
        logger.simpleLogWithArgs("instruction byte {x} was not found", .{
            memory[rom_op_addr],
        });

        return ExecNextError.OpNotFound;
    };

    const rom_op_addr_mode = rom_op.addressing_mode;

    // the actual PC, however, does increase for the next call of this function
    ctx.PC += 1 + rom_op.argsize;

    // instructions have *at most* 1 argument of either 8 or 16 bits (0 when no
    // argument is needed like in most NOPs)
    const arg: ExecArg = switch (rom_op.argsize) {
        0 => ExecArg{ .arg_0b = void{} },
        1 => ExecArg{ .arg_2b = memory[rom_op_addr + 1]},
        2 => ExecArg{ .arg_2b = std.mem.readInt(u16, &.{
            memory[rom_op_addr + 1],
            memory[rom_op_addr + 2],
        }, .little)},

        else => {
            logger.simpleLog("invalid argsize");
            return ExecNextError.InvalidArgSize;
        }
    };

    std.debug.print("{}", .{ rom_op });
    switch (rom_op.op_code) {
        .ADC => execADC(ctx, memory, arg, rom_op_addr_mode),
        .AND => execAND(ctx, memory, arg, rom_op_addr_mode),
        .ASL => execASL(ctx, memory, arg, rom_op_addr_mode),
        .BCC => execBCC(ctx, arg.arg_1b),
        .BCS => execBCS(ctx, arg.arg_1b),
        .BEQ => execBEQ(ctx, arg.arg_1b),
        .BIT => execBIT(ctx, memory, arg, rom_op_addr_mode),
        .BMI => execBMI(ctx, arg.arg_1b),
        .BNE => execBNE(ctx, arg.arg_1b),
        .BPL => execBPL(ctx, arg.arg_1b),
        .BRK => execBRK(ctx, memory),
        .BVC => execBVC(ctx, arg.arg_1b),
        .BVS => execBVS(ctx, arg.arg_1b),
        .CLC => execCLC(ctx),
        .CLD => execCLD(ctx),
        .CLI => execCLI(ctx),
        .CLV => execCLV(ctx),
        .CMP => execCMP(ctx, memory, arg, rom_op_addr_mode),
        .CPX => execCPX(ctx, memory, arg, rom_op_addr_mode),
        .CPY => execCPY(ctx, memory, arg, rom_op_addr_mode),
        .DEC => execDEC(ctx, memory, arg, rom_op_addr_mode),
        .DEX => execDEX(ctx),
        .DEY => execDEY(ctx),
        .EOR => execEOR(ctx, memory, arg, rom_op_addr_mode),
        .INC => execINC(ctx, memory, arg, rom_op_addr_mode),
        .INX => execINX(ctx),
        .INY => execINY(ctx),
        .JMP => execJMP(ctx, memory, arg, rom_op_addr_mode),
        .JSR => execJSR(ctx, memory, arg, rom_op_addr_mode),
        .LDA => execLDA(ctx, memory, arg, rom_op_addr_mode),
        .LDX => execLDX(ctx, memory, arg, rom_op_addr_mode),
        .LDY => execLDY(ctx, memory, arg, rom_op_addr_mode),
        .LSR => execLSR(ctx, memory, arg, rom_op_addr_mode),
        .NOP => {},
        .ORA => execORA(ctx, memory, arg, rom_op_addr_mode),
        .PHA => execPHA(ctx, memory),
        .PHP => execPHP(ctx, memory),
        .PLA => execPLA(ctx, memory),
        .PLP => execPLP(ctx, memory),
        .ROL => execROL(ctx, memory, arg, rom_op_addr_mode),
        .ROR => execROR(ctx, memory, arg, rom_op_addr_mode),
        .RTI => execRTI(ctx, memory),
        .RTS => execRTS(ctx, memory),
        .SBC => execSBC(ctx, memory, arg, rom_op_addr_mode),
        .SEC => execSEC(ctx),
        .SED => execSED(ctx),
        .SEI => execSEI(ctx),
        .STA => execSTA(ctx, memory, arg, rom_op_addr_mode),
        .STX => execSTX(ctx, memory, arg, rom_op_addr_mode),
        .STY => execSTY(ctx, memory, arg, rom_op_addr_mode),
        .TAX => execTAX(ctx),
        .TAY => execTAY(ctx),
        .TSX => execTSX(ctx),
        .TXA => execTXA(ctx),
        .TXS => execTXS(ctx),
        .TYA => execTYA(ctx),
        .ALR => {},
        .ANC => {},
        .ANC2 => {},
        .ANE => {},
        .ARR => {},
        .DCP => {},
        .ISC => {},
        .LAS => {},
        .LAX => {},
        .LXA => {},
        .RLA => {},
        .RRA => {},
        .SAX => {},
        .SBX => {},
        .SHA => {},
        .SHX => {},
        .SHY => {},
        .SLO => {},
        .SRE => {},
        .TAS => {},
        .USBC => {},
        .NOP2 => {},
        .HLT => {},
    }

}

/// returns on error
pub fn start(rom_reader: *std.io.AnyReader) !void {
    const input_buffer_size = 512;

    const stdout = std.io.getStdOut().writer().any();
    const stdin = std.io.getStdIn().reader();

    var mem_buffer = [_]u8{ 0 } ** (std.math.maxInt(u13) + 1);
    const rom_memory_size = rom_reader.read(mem_buffer[0x1000..]) catch {
        logger.simpleLog("there was an error reading the cartridge");
        unreachable;
    };

    // TODO: add some way to detect what kind of bank switching happens
    //
    // 2k cartridges memdup
    if (rom_memory_size == 0x800) {
        @memcpy(mem_buffer[0x1800..], mem_buffer[0x1000..0x1800]);
    }

    const memory: []u8 = mem_buffer[0..];

    const entrypoint_mem = [_]u8{
        memory[(start_vector_addr & address_mask)],
        memory[((start_vector_addr + 1) & address_mask)],
    };

    const entrypoint = std.mem.readInt(u16, &entrypoint_mem, .little);

    // startup info
    try stdout.print(
        \\>> rom size: {}
        \\>> entrypoint address: {}
        \\---
        \\
    , .{
        rom_memory_size,
        entrypoint & address_mask,
    });


    // execution context
    var exec_ctx: Context = .{
        .PC = entrypoint,
    };

    // execution debug loop
    var input_buffer = [_]u8{ 0 } ** input_buffer_size;
    while (true) : (try stdout.writeByte('\n')) {
        // prompt
        _ = try stdout.write("% ");

        // actual received input
        const input_slice = try stdin.readUntilDelimiter(&input_buffer, '\n');
        const cmd = parseInput(input_slice) catch {
            _ = try stdout.write("invalid command!");
            continue;
        };

        switch (cmd) {
            .Quit => return,

            .ExecNextOp => execNext(&exec_ctx, memory) catch |err| {
                logger.errorLog(err);
                return err;
            },

            .PrintCurrentOp => std.debug.print("{any}", .{
                op.optable[memory[exec_ctx.PC & address_mask]],
            }),

            .PrintCurrentCtx => std.debug.print("{any}", .{
                exec_ctx,
            })
        }
    }
}





