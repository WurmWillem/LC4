pub const Operation = enum { Add, And, Not };
const MemoryMember = union {
    operation: Operation,
    value: i16,
};

pub const Instruction = struct {
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

pub const Rest = union(enum) {
    third_reg: u3,
    immediate: i5,
};
