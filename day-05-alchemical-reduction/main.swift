import Foundation

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)

func length(for polymer: String) -> Int {
    var string = polymer
    var finished = false
    while !finished {
        finished = true
        
        for idx in string.indices.reversed() {
            if (idx >= string.index(string.endIndex, offsetBy: -1)) {
                continue
            }
            let next = string.index(after: idx)
            let a = String(string[idx])
            let b = String(string[next])
            
            if a.lowercased() == b.lowercased()
                && a != b {
                string.removeSubrange(idx...next)
                finished = false
            }
        }
    }
    return string.count
}

print("Part 1:")
print(length(for: input))

let shortest: [Int] = (97...122)
    .map {
        let lower = Character(UnicodeScalar($0)!)
        let upper = Character(UnicodeScalar($0 - 32)!)
        return length(for: input.replacingOccurrences(of: String(lower), with: "").replacingOccurrences(of: String(upper), with: ""))
    }

print("Part 2:")
print(shortest.min()!)
