import Foundation

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)

struct BoxId {
    var id: String
    var map = [Character: Int]()
    
    init(id: String) {
        self.id = id
        id.forEach { (char) in
            map[char] = (map[char] ?? 0) + 1
        }
    }
    
    var hasDouble: Bool {
        return map.contains(where: { (char, count) -> Bool in
            return count == 2
        })
    }

    var hasTriple: Bool {
        return map.contains(where: { (char, count) -> Bool in
            return count == 3
        })
    }
}

var boxIds = input
    .components(separatedBy: .newlines)
    .map { BoxId(id: $0) }

let doubles = boxIds
    .filter { $0.hasDouble }
    .count

let triples = boxIds
    .filter { $0.hasTriple }
    .count

let checksum = doubles * triples

print("Part 1:")
print(checksum)
