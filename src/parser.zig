const std = @import("std");

// there's got to be a better way of importing this
const memoryMember = @import("memory_member.zig");
const Operation = memoryMember.Operation;
const Instruction = memoryMember.Instruction;
const Rest = memoryMember.Rest;

const ArrayList = std.ArrayList;

pub fn parseString(source: []const u8, operations_hash: std.StringHashMap(Operation), allocator: std.mem.Allocator) !ArrayList(Instruction) {
    var instructions = ArrayList(Instruction).init(allocator);

    var current: u32 = 0;
    while (current < source.len) {
        skipWhiteSpace(source, &current);

        var operation_index = current;
        while (operation_index < source.len and source[operation_index] != ' ') : (operation_index += 1) {}

        // std.debug.print("{d}\n", .{operation_index});
        // std.debug.print("{d}\n", .{source.len});
        // std.debug.print("{s}\n", .{source[current..operation_index]});

        const operation = operations_hash.get(source[current..operation_index]).?;
        var instruction = Instruction.new(operation);

        current = operation_index;
        skipWhiteSpace(source, &current);

        // current is on first R
        instruction.first_3 = @intCast(source[current + 1] - '0');

        current += 3;
        skipWhiteSpace(source, &current);

        // current is on second R
        instruction.second_3 = @intCast(source[current + 1] - '0');

        switch (instruction.operation) {
            Operation.Add => {
                current += 3;
                skipWhiteSpace(source, &current);

                if (source[current] == 'R') {
                    instruction.rest = Rest{ .third_reg = @intCast(source[current + 1] - '0') };
                } else {
                    instruction.rest = Rest{ .immediate = @intCast(source[current + 1] - '0') };
                }
            },
            Operation.And => {
                current += 3;
                skipWhiteSpace(source, &current);
                instruction.rest = Rest{ .immediate = @intCast(source[current + 1] - '0') };
            },
            Operation.Not => {},
        }
        try instructions.append(instruction);

        // make current go to start of next line
        while (current < source.len and source[current] != '\n') : (current += 1) {}
        current += 1;
    }
    return instructions;
}

// increases current until a char is found which is not whitespace
fn skipWhiteSpace(source: []const u8, current: *u32) void {
    while (current.* < source.len and source[current.*] == ' ') : (current.* += 1) {}
}
