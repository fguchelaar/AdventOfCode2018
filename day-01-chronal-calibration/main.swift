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
var foundDoubleFrequency = false

repeat {
    for val in changes {
        current = current + val
        if frequencies.contains(current) {
            foundDoubleFrequency = true
            break
        }
        else {
            frequencies.insert(current)
        }
    }
} while !foundDoubleFrequency

print("Part 2:")
print(current)
