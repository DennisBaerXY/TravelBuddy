import SwiftUI

struct PackItemRow: View {
	let item: PackItem
	let onUpdate: (PackItem) -> Void
		
	var body: some View {
		HStack {
			Button(action: {
				var updatedItem = item
				updatedItem.isPacked.toggle()
				onUpdate(updatedItem)
			}) {
				Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
					.foregroundColor(item.isPacked ? .green : .blue)
					.font(.title2)
			}
				
			VStack(alignment: .leading, spacing: 4) {
				HStack {
					Text(item.name)
						.strikethrough(item.isPacked)
						.fontWeight(item.isEssential ? .semibold : .regular)
						
					if item.isEssential {
						Image(systemName: "exclamationmark.circle")
							.foregroundColor(.red)
							.font(.caption)
					}
				}
					
				Text(item.category)
					.font(.caption)
					.foregroundColor(.secondary)
			}
				
			Spacer()
				
			if item.quantity > 1 {
				Text("× \(item.quantity)")
					.font(.body)
					.foregroundColor(.secondary)
			}
		}
		.padding(.vertical, 10)
		.padding(.horizontal, 12)
		.background(
			RoundedRectangle(cornerRadius: 10)
				.fill(item.isPacked ? Color(.systemGray6) : Color(.systemBackground))
		)
		.overlay(
			RoundedRectangle(cornerRadius: 10)
				.stroke(Color.gray.opacity(0.2), lineWidth: 1)
		)
	}
}