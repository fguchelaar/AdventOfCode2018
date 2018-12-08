import Foundation

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)

let ints = input.components(separatedBy: " ")
    .map { Int($0)! }

struct Node {
    var metadata: [Int]
    var children: [Node]
    
    func part1() -> Int {
        return metadata.reduce(0, +) + children.reduce(0, {a,c in a + c.part1()})
    }
    
    func part2() -> Int {
        if children.isEmpty {
            return metadata.reduce(0, +)
        } else {
            return metadata
                .filter { $0 != 0 && $0 <= self.children.count }
                .map { self.children[$0-1].part2() }
                .reduce(0, +)
        }
    }
}

var index = 0
func parseInput() -> Node {
    let numberOfChildren = ints[index]
    index += 1
    let numberOfMetadataEntries = ints[index]
    index += 1
    
    let children =  (0..<numberOfChildren).map { _ in
        return parseInput()
    }
    let metadataRange = index..<index+numberOfMetadataEntries
    
    let metadata = [Int](ints[metadataRange])
    index += numberOfMetadataEntries
    return Node(metadata: metadata, children: children)
}

let root = parseInput()

print("Part 1:")
print(root.part1())

print("Part 2:")
print(root.part2())
