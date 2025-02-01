const std = @import("std");

const parser = @import("parser.zig");
const memoryMember = @import("memory_member.zig");
const Operation = memoryMember.Operation;
// const parseString = parser.parseString();

const ArrayList = std.ArrayList;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile("file.asm", .{});
    defer file.close();

    const file_len = try file.stat();
    const file_data = try allocator.alloc(u8, file_len.size);
    defer allocator.free(file_data);

    _ = try file.readAll(file_data);
    // std.debug.print("File contents: {s}\n", .{file_data});

    var operations_hash = std.StringHashMap(Operation).init(allocator);
    defer operations_hash.deinit();
    try operations_hash.put("ADD", Operation.Add);
    try operations_hash.put("NOT", Operation.Not);
    try operations_hash.put("AND", Operation.And);

    // const file_data = "ADD R0, R0, #1";

    const instructions = try parser.parseString(file_data, operations_hash, allocator);
    defer instructions.deinit();

    var registers = std.mem.zeroes([8]i16);
    registers[0] = 5;
    registers[1] = 12;

    for (0.., registers) |i, reg| {
        if (reg != 0) {
            std.debug.print("R{d}: {d}\n", .{ i, reg });
        }
    }
    std.debug.print("\n", .{});

    // std.debug.print("{d} {d}\n", .{ registers[0], ~registers[0] });
    // std.debug.print("R0: {d}\n", .{registers[0]});

    for (instructions.items) |inst| {
        // std.debug.print("{d} {d}\n", .{ inst.first_3, inst.second_3 });
        switch (inst.operation) {
            Operation.Add => {
                switch (inst.rest) {
                    .third_reg => |value| registers[inst.first_3] = registers[inst.second_3] + registers[value],
                    .immediate => |immediate| registers[inst.first_3] = registers[inst.second_3] + immediate,
                }
            },
            Operation.Not => {
                registers[inst.first_3] = ~registers[inst.second_3];
            },
            Operation.And => {
                registers[inst.first_3] = registers[inst.second_3] & inst.rest.immediate;
            },
        }
    }

    for (0.., registers) |i, reg| {
        if (reg != 0) {
            std.debug.print("R{d}: {d}\n", .{ i, reg });
        }
    }
}
