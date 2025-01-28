const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;

const Registers = struct {
    R0: i16,
};

pub fn main() !void {
    // get this into a file later on
    const file_data =
        "ADD R0, R0, 1";

    for (file_data) |char| {
        switch (char) {}
    }
}

const Operation = enum { Add };
const Instruction = struct {
    operation: Operation,
    first_3: u3,
    second_3: u3,
    rest: i7,
};
