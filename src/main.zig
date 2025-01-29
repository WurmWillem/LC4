const std = @import("std");
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

    // const file_data = "ADD R0, R0, 1";

    const instructions = try parseString(file_data, operations_hash, allocator);
    defer instructions.deinit();

    var registers = std.mem.zeroes([7]i16);

    std.debug.print("R0: {d}\n", .{registers[0]});
    for (instructions.items) |inst| {
        switch (inst.operation) {
            Operation.Add => {
                switch (inst.rest) {
                    .third_reg => |value| registers[inst.first_3] = registers[inst.second_3] + registers[value],
                    .immediate => |immediate| registers[inst.first_3] = registers[inst.second_3] + immediate,
                }
            },
        }
    }

    std.debug.print("R0: {d}\n", .{registers[0]});
}

fn parseString(source: []const u8, operations_hash: std.StringHashMap(Operation), allocator: std.mem.Allocator) !ArrayList(Instruction) {
    var instructions = ArrayList(Instruction).init(allocator);

    var current: u32 = 0;
    while (current < source.len) {
        var operation_index = current;
        while (operation_index < source.len and source[operation_index] != ' ') : (operation_index += 1) {}
        if (operation_index >= source.len) {
            return instructions;
        }

        // std.debug.print("{d}\n", .{operation_index});
        // std.debug.print("{d}\n", .{source.len});
        // std.debug.print("{s}\n", .{source[current..operation_index]});

        const operation = operations_hash.get(source[current..operation_index]).?;
        var instruction = Instruction.new(operation);
        current = operation_index + 1; // current is on first R

        instruction.first_3 = @intCast(source[current + 1] - 48);
        current += 4; // current is on second R
        instruction.second_3 = @intCast(source[current + 1] - 48);
        current += 4; // current is on third argument

        switch (instruction.operation) {
            Operation.Add => {
                if (source[current] == 'R') {
                    instruction.rest = Rest{ .third_reg = @intCast(source[current + 1] - 48) };
                } else {
                    instruction.rest = Rest{ .immediate = @intCast(source[current] - 48) };
                }
            },
        }
        try instructions.append(instruction);

        // make current go to start of next line
        while (current < source.len and source[current] != '\n') : (current += 1) {}
        current += 1;
    }
    return instructions;
}

const Operation = enum { Add };
const MemoryMember = union {
    operation: Operation,
    value: i16,
};

const Instruction = struct {
    operation: Operation,
    first_3: u3,
    second_3: u3,
    rest: Rest,

    pub fn new(operation: Operation) Instruction {
        return Instruction{
            .operation = operation,
            .first_3 = 0,
            .second_3 = 0,
            .rest = Rest{ .immediate = 0 },
        };
    }
};

const Rest = union(enum) {
    third_reg: u3,
    immediate: i5,
};
