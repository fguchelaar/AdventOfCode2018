import Foundation

let input = "074501"
let recipeCount = Int(input)!

var elf1 = 0
var elf2 = 1

var recipes = [3, 7]

func part2Solved() -> Bool {
    if recipes.count >= input.count {
        let recipe = recipes[(recipes.count-input.count)..<recipes.count].map { "\($0)" }.joined()
        if recipe == input {
            print ("Part 2:")
            print (recipes.count-input.count)
            return true
        }
    }
    return false
}

// Attemp #1 - naive approach with an array
while true {
    let sum = recipes[elf1] + recipes[elf2]
    let digit = (sum / 10)
    if digit != 0 {
        recipes.append(digit)
        if part2Solved() { break }
    }

    recipes.append(sum % 10)
    if part2Solved() { break }

    elf1 = (elf1 + recipes[elf1] + 1) % recipes.count
    elf2 = (elf2 + recipes[elf2] + 1) % recipes.count
    
    if recipes.count == recipeCount + 10 {
        print ("Part 1:")
        print (recipes[(recipeCount..<recipeCount+10)].map { "\($0)" }.joined())
    }
}
