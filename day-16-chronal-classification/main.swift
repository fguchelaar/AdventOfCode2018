import Foundation

typealias registers = [Int]
typealias instruction = (opcode: Int, a: Int, b: Int, c: Int)

typealias opcode = (Int, Int, Int, registers) -> registers?

/// (add register) stores into register C the result of adding register A and register B
let addr: opcode = { (a, b, c, registers) in
    guard [a, b, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] + copy[b]
    return copy
}

/// (add immediate) stores into register C the result of adding register A and value B
let addi: opcode = { (a, b, c, registers) in
    guard [a, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] + b
    return copy
}

/// (multiply register) stores into register C the result of multiplying register A and register B
let mulr: opcode = { (a, b, c, registers) in
    guard [a, b, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] * copy[b]
    return copy
}

/// (multiply immediate) stores into register C the result of multiplying register A and value B
let muli: opcode = { (a, b, c, registers) in
    guard [a, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] * b
    return copy
}

/// (bitwise AND register) stores into register C the result of the bitwise AND of register A and register B
let banr: opcode = { (a, b, c, registers) in
    guard [a, b, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] & copy[b]
    return copy
}

/// (bitwise AND immediate) stores into register C the result of the bitwise AND of register A and value B
let bani: opcode = { (a, b, c, registers) in
    guard [a, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] & b
    return copy
}

/// (bitwise OR register) stores into register C the result of the bitwise OR of register A and register B
let borr: opcode = { (a, b, c, registers) in
    guard [a, b, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] | copy[b]
    return copy
}

/// (bitwise OR immediate) stores into register C the result of the bitwise OR of register A and value B
let bori: opcode = { (a, b, c, registers) in
    guard [a, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] | b
    return copy
}

/// (set register) copies the contents of register A into register C. (Input B is ignored.)
let setr: opcode = { (a, b, c, registers) in
    guard [a, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a]
    return copy
}

/// (set immediate) stores value A into register C. (Input B is ignored.)
let seti: opcode = { (a, b, c, registers) in
    guard [c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = a
    return copy
}

/// (greater-than immediate/register) sets register C to 1 if value A is greater than register B. Otherwise, register C is set to 0.
let gtir: opcode = { (a, b, c, registers) in
    guard [b, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = a > copy[b] ? 1 : 0
    return copy
}

/// (greater-than register/immediate) sets register C to 1 if register A is greater than value B. Otherwise, register C is set to 0
let gtri: opcode = { (a, b, c, registers) in
    guard [a, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] > b ? 1 : 0
    return copy
}

/// gtrr (greater-than register/register) sets register C to 1 if register A is greater than register B. Otherwise, register C is set to 0
let gtrr: opcode = { (a, b, c, registers) in
    guard [a, b, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] > copy[b] ? 1 : 0
    return copy
}

/// (equal immediate/register) sets register C to 1 if value A is equal to register B. Otherwise, register C is set to 0.
let eqir: opcode = { (a, b, c, registers) in
    guard [b, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = a == copy[b] ? 1 : 0
    return copy
}

/// (equal register/immediate) sets register C to 1 if register A is equal to value B. Otherwise, register C is set to 0.
let eqri: opcode = { (a, b, c, registers) in
    guard [a, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] == b ? 1 : 0
    return copy
}

/// (equal register/register) sets register C to 1 if register A is equal to register B. Otherwise, register C is set to 0.
let eqrr: opcode = { (a, b, c, registers) in
    guard [a, b, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] == copy[b] ? 1 : 0
    return copy
}

let opcodes = ["addr": addr, "addi": addi, "mulr": mulr, "muli": muli, "banr": banr, "bani": bani, "borr": borr, "bori": bori, "setr": setr, "seti": seti, "gtir": gtir, "gtri": gtri, "gtrr": gtrr, "eqir": eqir, "eqri": eqri, "eqrr": eqrr]

var opcodesById = Array<[String]>(repeatElement(opcodes.keys.map { $0 }, count: 16))

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)

var samples = input
    .components(separatedBy: "\n\n\n\n")[0]
    .components(separatedBy: .newlines)
    .filter { !$0.isEmpty }

extension String {
    func extractInts() -> [Int] {
        return self.split(whereSeparator: { !"-1234567890".contains($0) }).compactMap { Int($0) }
    }
}

var part1 = 0
while !samples.isEmpty {
    let input = samples.removeFirst().extractInts()
    let opcode = samples.removeFirst().extractInts()
    let output = samples.removeFirst().extractInts()

    let eligible = opcodes
        .filter { op in
            op.value(opcode[1], opcode[2], opcode[3], input) == output
        }.keys.map { $0 }

    // Preperation for part 2: remove incompatible opcodes from the list
    opcodesById[opcode[0]] = opcodesById[opcode[0]].filter { eligible.contains($0) }

    if eligible.count >= 3 {
        part1 += 1
    }
}

print("Part 1:")
print(part1)

// let's deduce all possible ops
while opcodesById.contains(where: { $0.count > 1 }) {
    let ones = opcodesById.filter { $0.count == 1 }.flatMap { $0 }
    opcodesById.enumerated()
        .filter { $0.element.count > 1 }
        .forEach { opcodesById[$0.offset] = opcodesById[$0.offset].filter { !ones.contains($0) } }
}

var instructions = input
    .components(separatedBy: "\n\n\n\n")[1]
    .components(separatedBy: .newlines)

var register = [0, 0, 0, 0]

for op in instructions {
    let opcode = op.extractInts()
    let op = opcodes[opcodesById[opcode[0]].first!]!
    register = op(opcode[1], opcode[2], opcode[3], register)!
}

print("Part 2:")
print(register[0])
