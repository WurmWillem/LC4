const std = @import("std");

pub fn main() !void {
    // get this into a file later on
    const file_data = "ADD R0, R0, 1\n ADD R0, R3";

    const values = std.ArrayHashMap([]const u8, u32, 1).init();

    // parsing is boring
    for (file_data) |char| {
        std.debug.print("{c}", .{char});
    }

    // var instructions: [100]Instruction = undefined;
    // const instruction = Instruction{
    //     .operation = Operation.Add,
    //     .first_3 = 0,
    //     .second_3 = 0,
    //     .rest = 1,
    // };
    // instructions[0] = instruction;
    //
    // // var registers: [7]i16 = [_]i16{0};
    // var registers = std.mem.zeroes([7]i16);
    //
    // std.debug.print("R0: {d}\n", .{registers[0]});
    // for (instructions) |inst| {
    //     switch (inst.operation) {
    //         Operation.Add => {
    //             registers[inst.first_3] = registers[inst.second_3] + inst.rest;
    //         },
    //     }
    // }
    //
    // std.debug.print("R0: {d}\n", .{registers[0]});
}

const MemoryMember = union {
    operation: Operation,
    value: i16,
};

const Operation = enum { Add };
const Instruction = struct { operation: Operation, first_3: u3, second_3: u3, rest: Rest };

const Rest = union {
    third_reg: u3,
    immediate: i5,
};
