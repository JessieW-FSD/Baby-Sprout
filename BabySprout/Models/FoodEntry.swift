import Foundation
import SwiftData

enum FoodCategory: String, Codable, CaseIterable {
    case puree = "Puree"
    case fingerFood = "Finger Food"
    case cereal = "Cereal"
    case snack = "Snack"
    case meal = "Meal"
    case other = "Other"

    var icon: String {
        switch self {
        case .puree: return "spoon"
        case .fingerFood: return "hand.point.up"
        case .cereal: return "bowl.fill"
        case .snack: return "apple.logo"
        case .meal: return "fork.knife"
        case .other: return "questionmark.circle"
        }
    }
}

enum AmountUnit: String, Codable, CaseIterable {
    case tablespoon = "tbsp"
    case ounce = "oz"
    case gram = "g"
    case milliliter = "mL"
    case serving = "serving"
}

enum FoodReaction: String, Codable, CaseIterable {
    case loved = "Loved"
    case liked = "Liked"
    case neutral = "Neutral"
    case disliked = "Disliked"
    case refused = "Refused"

    var icon: String {
        switch self {
        case .loved: return "😍"
        case .liked: return "😊"
        case .neutral: return "😐"
        case .disliked: return "😕"
        case .refused: return "🙅"
        }
    }
}

@Model
final class FoodEntry {
    var timestamp: Date
    var foodName: String
    var foodCategoryRaw: String
    var amount: Double?
    var amountUnitRaw: String
    var reactionRaw: String?
    var notes: String

    init(
        timestamp: Date = Date(),
        foodName: String,
        foodCategory: FoodCategory = .other,
        amount: Double? = nil,
        amountUnit: AmountUnit = .serving,
        reaction: FoodReaction? = nil,
        notes: String = ""
    ) {
        self.timestamp = timestamp
        self.foodName = foodName
        self.foodCategoryRaw = foodCategory.rawValue
        self.amount = amount
        self.amountUnitRaw = amountUnit.rawValue
        self.reactionRaw = reaction?.rawValue
        self.notes = notes
    }

    var foodCategory: FoodCategory {
        get { FoodCategory(rawValue: foodCategoryRaw) ?? .other }
        set { foodCategoryRaw = newValue.rawValue }
    }

    var amountUnit: AmountUnit {
        get { AmountUnit(rawValue: amountUnitRaw) ?? .serving }
        set { amountUnitRaw = newValue.rawValue }
    }

    var reaction: FoodReaction? {
        get {
            guard let reactionRaw else { return nil }
            return FoodReaction(rawValue: reactionRaw)
        }
        set { reactionRaw = newValue?.rawValue }
    }

    var summary: String {
        var parts: [String] = [foodCategory.rawValue]
        if let amount, let unit = AmountUnit(rawValue: amountUnitRaw) {
            let formatted = amount.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(amount))
                : String(format: "%.1f", amount)
            parts.append("\(formatted) \(unit.rawValue)")
        }
        if let reaction {
            parts.append(reaction.icon)
        }
        return parts.joined(separator: " · ")
    }
}
