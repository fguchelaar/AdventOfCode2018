import Foundation

typealias registers = [Int]
typealias instruction = (opcode: Int, a: Int, b: Int, c: Int)

typealias opcode = (Int, Int, Int, registers) -> registers?

// (add register) stores into register C the result of adding register A and register B
let addr: opcode = { (a, b, c, registers) in
    guard [a, b, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] + copy[b]
    return copy
}

// (add immediate) stores into register C the result of adding register A and value B
let addi: opcode = { (a, b, c, registers) in
    guard [a, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] + b
    return copy
}

// (multiply register) stores into register C the result of multiplying register A and register B
let mulr: opcode = { (a, b, c, registers) in
    guard [a, b, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] * copy[b]
    return copy
}

// (multiply immediate) stores into register C the result of multiplying register A and value B
let muli: opcode = { (a, b, c, registers) in
    guard [a, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] * b
    return copy
}

// (bitwise AND register) stores into register C the result of the bitwise AND of register A and register B
let banr: opcode = { (a, b, c, registers) in
    guard [a, b, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] & copy[b]
    return copy
}

// (bitwise AND immediate) stores into register C the result of the bitwise AND of register A and value B
let bani: opcode = { (a, b, c, registers) in
    guard [a, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] & b
    return copy
}

// (bitwise OR register) stores into register C the result of the bitwise OR of register A and register B
let borr: opcode = { (a, b, c, registers) in
    guard [a, b, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] | copy[b]
    return copy
}

// (bitwise OR immediate) stores into register C the result of the bitwise OR of register A and value B
let bori: opcode = { (a, b, c, registers) in
    guard [a, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] | b
    return copy
}

// (set register) copies the contents of register A into register C. (Input B is ignored.)
let setr: opcode = { (a, b, c, registers) in
    guard [a, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a]
    return copy
}

// (set immediate) stores value A into register C. (Input B is ignored.)
let seti: opcode = { (a, b, c, registers) in
    guard [c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = a
    return copy
}

// (greater-than immediate//register) sets register C to 1 if value A is greater than register B. Otherwise, register C is set to 0.
let gtir: opcode = { (a, b, c, registers) in
    guard [b, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = a > copy[b] ? 1 : 0
    return copy
}

// (greater-than register//immediate) sets register C to 1 if register A is greater than value B. Otherwise, register C is set to 0
let gtri: opcode = { (a, b, c, registers) in
    guard [a, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] > b ? 1 : 0
    return copy
}

// gtrr (greater-than register//register) sets register C to 1 if register A is greater than register B. Otherwise, register C is set to 0
let gtrr: opcode = { (a, b, c, registers) in
    guard [a, b, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] > copy[b] ? 1 : 0
    return copy
}

// (equal immediate//register) sets register C to 1 if value A is equal to register B. Otherwise, register C is set to 0.
let eqir: opcode = { (a, b, c, registers) in
    guard [b, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = a == copy[b] ? 1 : 0
    return copy
}

// (equal register//immediate) sets register C to 1 if register A is equal to value B. Otherwise, register C is set to 0.
let eqri: opcode = { (a, b, c, registers) in
    guard [a, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] == b ? 1 : 0
    return copy
}

// (equal register//register) sets register C to 1 if register A is equal to register B. Otherwise, register C is set to 0.
let eqrr: opcode = { (a, b, c, registers) in
    guard [a, b, c].allSatisfy({$0 < registers.count}) else {
        return nil
    }
    var copy = registers
    copy[c] = copy[a] == copy[b] ? 1 : 0
    return copy
}

let opcodes = ["addr": addr, "addi": addi, "mulr": mulr, "muli": muli, "banr": banr, "bani": bani, "borr": borr, "bori": bori, "setr": setr, "seti": seti, "gtir": gtir, "gtri": gtri, "gtrr": gtrr, "eqir": eqir, "eqri": eqri, "eqrr": eqrr]

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)

extension String {
    func extractInts() -> [Int] {
        return self.split(whereSeparator: { !"-1234567890".contains($0) }).compactMap { Int($0) }
    }
}

var instructions = input
    .components(separatedBy: .newlines)

var ipRegister =  instructions.removeFirst().extractInts()[0]
var ip = 0
var register = [0, 0, 0, 0, 0, 0]
var counter = 0

var ins = [Int: (opcode, Int, Int, Int)]()

for i in instructions.enumerated() {
    let ints = i.element.extractInts()
    let opcode = opcodes[String(i.element.split(separator: " ")[0])]!
    ins[i.offset] = (opcode, ints[0], ints[1], ints[2])
}

while ip < ins.count {

    let opcode = ins[ip]!
    register[ipRegister] = ip
    register = opcode.0(opcode.1, opcode.2, opcode.3, register)!
    ip = register[ipRegister] + 1

    counter += 1
}

print("Part 1:")
print(register)

print("Part 2:")
// Okay, so it's the sum of its divisors. After running the code with a 1 in
// register 0 for a couple of instructions, 10551287 ends up in r2
let x = 10551287
var sum = 0
for i in 1...x {
    if x % i == 0 {
        sum += i
    }
}
print(sum)
