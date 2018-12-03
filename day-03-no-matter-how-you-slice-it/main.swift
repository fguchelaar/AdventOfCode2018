import Foundation

let input = try! String(contentsOfFile: "input.txt").trimmingCharacters(in: .whitespacesAndNewlines)

extension CGPoint: Hashable {
    public var hashValue: Int {
        return x.hashValue << 32 ^ y.hashValue
    }
}

struct Claim {
    var id: Int
    var rect: CGRect
    
    init(string: String) {
        let parts = string
            .components(separatedBy: CharacterSet(charactersIn: "#@,:x "))
            .filter { !$0.isEmpty }
            .map { Int($0)! }
        
        id = parts[0]
        rect = CGRect(x: parts[1], y: parts[2], width: parts[3], height: parts[4])
    }
    
    func maxCount(in map: [CGPoint: Int]) -> Int {
        var result = 0
        for x in Int(rect.minX)..<Int(rect.maxX) {
            for y in Int(rect.minY)..<Int(rect.maxY) {
                let point = CGPoint(x: x, y: y)
                result = max(result, (map[point] ?? 0))
            }
        }
        return result
    }
}

let claims = input
    .components(separatedBy: .newlines)
    .map { Claim(string: $0) }

var map = [CGPoint: Int]()

for claim in claims {
    for x in Int(claim.rect.minX)..<Int(claim.rect.maxX) {
        for y in Int(claim.rect.minY)..<Int(claim.rect.maxY) {
            let point = CGPoint(x: x, y: y)
            map[point] = (map[point] ?? 0) + 1
        }
    }
}

let overlapCount = map
    .filter { $0.value > 1 }
    .count

print("Part 1:")
print(overlapCount)

let nonOverlapping = claims
    .first { $0.maxCount(in: map) ==  1 }!

print("Part 2:")
print(nonOverlapping.id)

