import Foundation

class Calculations {
    static func calculateBoxesAndMissing(total: Decimal, capacity: Decimal) -> (boxes: Int, missing: Decimal) {
        guard capacity > 0 else { return (0, 0) }

        let fullBoxes = Int(total / capacity)
        let remainder = total.truncatingRemainder(dividingBy: capacity)
        let missing = remainder == 0 ? 0 : capacity - remainder

        return (fullBoxes, missing)
    }
}