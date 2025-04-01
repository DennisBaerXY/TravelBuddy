mport Foundation
import SwiftData

@Model
class PackItem {
    var id: UUID
    var name: String
    var category: String
    var isPacked: Bool
    var isEssential: Bool
    var quantity: Int
    
    init(
        name: String,
        category: ItemCategory,
        isPacked: Bool = false,
        isEssential: Bool = false,
        quantity: Int = 1
    ) {
        self.id = UUID()
        self.name = name
        self.category = category.rawValue
        self.isPacked = isPacked
        self.isEssential = isEssential
        self.quantity = quantity
    }
    
    // Hilfsmethode für Enum-Konvertierung
    var categoryEnum: ItemCategory {
        ItemCategory(rawValue: category) ?? .other
    }
}
