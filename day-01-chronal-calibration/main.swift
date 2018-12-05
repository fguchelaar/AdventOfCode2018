import Foundation

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)
let changes = input.components(separatedBy: .newlines).map { Int($0)! }

// part 1
let frequency = changes.reduce(0, +)
print("Part 1:")
print(frequency)

// part 2
var frequencies = Set<Int>()
var current = 0

outer: while true {
    for val in changes {
        if !frequencies.insert(current).inserted {
            break outer
        }
        current += val
    }
}

print("Part 2:")
print(current)
