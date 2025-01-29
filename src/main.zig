const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var operations_hash = std.StringHashMap(Operation).init(allocator);
    defer operations_hash.deinit();
    try operations_hash.put("ADD", Operation.Add);

    const file_data = "ADD R0, R0, R3";

    const instructions = try parseString(file_data, operations_hash, allocator);
    defer instructions.deinit();

    var registers = std.mem.zeroes([7]i16);
    registers[3] = 7;

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

fn parseString(source: []const u8, operations_hash: std.StringHashMap(Operation), allocator: std.mem.Allocator) !std.ArrayList(Instruction) {
    var instructions = std.ArrayList(Instruction).init(allocator);

    // this won't work on instructions that are not 3 characters, but we can fix that later
    const operation = operations_hash.get(source[0..3]).?;
    var instruction = Instruction.new(operation);

    switch (operation) {
        Operation.Add => {
            instruction.first_3 = @intCast(source[5] - 48);
            instruction.second_3 = @intCast(source[9] - 48);
            if (source[12] == 'R') {
                instruction.rest = Rest{ .third_reg = @intCast(source[13] - 48) };
            } else {
                instruction.rest = Rest{ .immediate = @intCast(source[12] - 48) };
            }
        },
    }

    try instructions.append(instruction);
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
