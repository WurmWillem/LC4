const std = @import("std");

pub fn main() !void {
    // const opcodes = std.ArrayHashMap([]const u8, Operation, bool, 1).init();
    // opcodes.put("ADD", Operation.Add);
    //
    // rework this
    // var buffer: [1000]u8 = undefined;
    const allocator = std.heap.page_allocator;
    // var fba = std.heap.FixedBufferAllocator.init(&buffer);
    // const allocator = fba.allocator();

    var map = std.StringHashMap(Operation).init(
        allocator,
    );
    defer map.deinit();

    try map.put("ADD", Operation.Add);

    const file_data = "ADD R0, R0, 3";

    const operation = map.get(file_data[0..3]).?;
    var first_3: u3 = 0;
    var second_3: u3 = 0;
    var rest = Rest{ .immediate = 0 }; // will be changed later

    switch (operation) {
        Operation.Add => {
            first_3 = file_data[5] - 48;
            second_3 = file_data[9] - 48;
            rest = Rest{ .immediate = file_data[12] - 48 };
        },
    }
    const instruction = Instruction{
        .operation = operation,
        .first_3 = first_3,
        .second_3 = second_3,
        .rest = rest,
    };

    var instructions: [1]Instruction = undefined;
    instructions[0] = instruction;

    // var registers: [7]i16 = [_]i16{0};
    var registers = std.mem.zeroes([7]i16);

    std.debug.print("R0: {d}\n", .{registers[0]});
    for (instructions) |inst| {
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

const Operation = enum { Add };
const MemoryMember = union {
    operation: Operation,
    value: i16,
};

const Instruction = struct { operation: Operation, first_3: u3, second_3: u3, rest: Rest };

const Rest = union(enum) {
    third_reg: u3,
    immediate: i5,
};
