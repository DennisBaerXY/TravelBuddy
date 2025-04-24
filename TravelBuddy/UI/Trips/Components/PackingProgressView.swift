import SwiftUI

/// A view that displays packing progress with a customizable appearance
struct PackingProgressView: View {
	// MARK: - Properties
	
	/// The progress value (0.0 to 1.0)
	let progress: Double
	
	/// Whether to show a compact version of the progress bar
	var isCompact: Bool = false
	
	/// The color of the progress track (background)
	var trackColor: Color = Color.tripBuddyPrimary.opacity(0.1)
	
	/// The color of the progress indicator
	var progressColor: Color?
	
	/// The height of the progress bar
	var height: CGFloat = 0
	
	/// Animation duration for progress changes
	var animationDuration: Double = 0.3
	
	/// Whether to show a percentage label
	var showPercentage: Bool = false
	
	/// Whether to show a completion icon when progress is 100%
	var showCompletionIcon: Bool = false
	
	// MARK: - Initialization
	
	/// Creates a new packing progress view
	/// - Parameters:
	///   - progress: The progress value (0.0 to 1.0)
	///   - isCompact: Whether to show a compact version
	///   - trackColor: The color of the progress track
	///   - progressColor: The color of the progress indicator (nil for automatic)
	///   - height: The height of the progress bar (0 for automatic)
	///   - animationDuration: Animation duration for progress changes
	///   - showPercentage: Whether to show a percentage label
	///   - showCompletionIcon: Whether to show a completion icon when progress is 100%
	init(
		progress: Double,
		isCompact: Bool = false,
		trackColor: Color = Color.tripBuddyPrimary.opacity(0.1),
		progressColor: Color? = nil,
		height: CGFloat = 0,
		animationDuration: Double = 0.3,
		showPercentage: Bool = false,
		showCompletionIcon: Bool = false
	) {
		self.progress = progress
		self.isCompact = isCompact
		self.trackColor = trackColor
		self.progressColor = progressColor
		self.height = height
		self.animationDuration = animationDuration
		self.showPercentage = showPercentage
		self.showCompletionIcon = showCompletionIcon
	}
	
	// MARK: - Body
	
	var body: some View {
		progressLayout
	}
	
	// MARK: - Computed Properties
	
	/// The calculated progress color based on the progress value
	private var calculatedProgressColor: Color {
		if let color = progressColor {
			return color
		}
		
		return determineProgressColor(for: progress)
	}
	
	/// The calculated height of the progress bar
	private var barHeight: CGFloat {
		if height > 0 {
			return height
		}
		
		return isCompact ? 5 : 8
	}
	
	// MARK: - UI Components
	
	/// The progress bar layout
	private var progressLayout: some View {
		VStack(spacing: 4) {
			ZStack(alignment: .leading) {
				// Background track
				Capsule()
					.fill(trackColor)
					.frame(height: barHeight)
				
				// Progress fill
				Capsule()
					.fill(calculatedProgressColor)
					.frame(width: progressWidth(for: progress), height: barHeight)
					.animation(.easeInOut(duration: animationDuration), value: progress)
				
				// Optional completion icon
				if showCompletionIcon && progress >= 1.0 {
					completionCheckmark
				}
			}
			
			// Optional percentage label
			if showPercentage {
				Text("\(Int(progress * 100))%")
					.font(.caption)
					.foregroundColor(calculatedProgressColor)
					.animation(.easeInOut(duration: animationDuration), value: progress)
			}
		}
	}
	
	/// The checkmark shown when progress is complete
	private var completionCheckmark: some View {
		HStack {
			Spacer()
			
			Image(systemName: "checkmark.circle.fill")
				.foregroundColor(.tripBuddySuccess)
				.font(.system(size: barHeight * 2))
				.shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
				.transition(.scale.combined(with: .opacity))
		}
		.padding(.trailing, barHeight / 2)
	}
	
	// MARK: - Helper Methods
	
	/// Determines the appropriate color for a progress value
	/// - Parameter value: Progress value between 0.0 and 1.0
	/// - Returns: Color for the progress
	private func determineProgressColor(for value: Double) -> Color {
		if value < 0.3 {
			return .tripBuddyAlert.opacity(0.8)
		} else if value < 1 {
			return .tripBuddyAccent.opacity(0.8)
		} else {
			return .tripBuddySuccess
		}
	}
	
	/// Calculates the width of the progress bar based on the progress value
	/// - Parameter progress: The progress value (0.0 to 1.0)
	/// - Returns: The width of the progress bar
	private func progressWidth(for progress: Double) -> CGFloat? {
		// Return nil for full width when progress is 100%
		if progress >= 1.0 {
			return nil
		}
		
		// Calculate proportional width
		return progress * 100.0
	}
}

// MARK: - Alternative Styles

extension PackingProgressView {
	/// Creates a stepped progress view showing discrete progress steps
	/// - Parameters:
	///   - currentStep: The current step (1-based)
	///   - totalSteps: The total number of steps
	///   - stepColors: Colors for the steps (optional)
	///   - spacing: Spacing between steps
	/// - Returns: A discrete step progress view
	static func stepped(
		currentStep: Int,
		totalSteps: Int,
		stepColors: [Color]? = nil,
		spacing: CGFloat = 4
	) -> some View {
		HStack(spacing: spacing) {
			ForEach(0 ..< totalSteps, id: \.self) { index in
				let isCompleted = index < currentStep
				
				RoundedRectangle(cornerRadius: 4)
					.fill(stepColor(for: index, isCompleted: isCompleted, colors: stepColors))
					.frame(height: 8)
			}
		}
	}
	
	/// Determines the color for a step in the stepped progress view
	/// - Parameters:
	///   - index: The step index
	///   - isCompleted: Whether the step is completed
	///   - colors: Custom colors for steps
	/// - Returns: The color for the step
	private static func stepColor(
		for index: Int,
		isCompleted: Bool,
		colors: [Color]?
	) -> Color {
		if isCompleted {
			if let colors = colors, index < colors.count {
				return colors[index]
			} else {
				return .tripBuddyPrimary
			}
		} else {
			return Color.tripBuddyPrimary.opacity(0.2)
		}
	}
	
	/// Creates a circular progress indicator
	/// - Parameters:
	///   - progress: The progress value (0.0 to 1.0)
	///   - size: The size of the circle
	///   - lineWidth: The width of the progress line
	///   - backgroundColor: The background color
	///   - foregroundColor: The foreground color
	///   - showPercentage: Whether to show the percentage
	/// - Returns: A circular progress view
	static func circular(
		progress: Double,
		size: CGFloat = 60,
		lineWidth: CGFloat = 8,
		backgroundColor: Color = Color.tripBuddyPrimary.opacity(0.2),
		foregroundColor: Color? = nil,
		showPercentage: Bool = true
	) -> some View {
		// Determine the progress color based on the progress value
		let color: Color
		if let customColor = foregroundColor {
			color = customColor
		} else {
			if progress < 0.3 {
				color = .tripBuddyAlert.opacity(0.8)
			} else if progress < 1 {
				color = .tripBuddyAccent.opacity(0.8)
			} else {
				color = .tripBuddySuccess
			}
		}
		
		return ZStack {
			// Background circle
			Circle()
				.stroke(backgroundColor, lineWidth: lineWidth)
			
			// Progress circle
			Circle()
				.trim(from: 0, to: CGFloat(min(progress, 1.0)))
				.stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
				.rotationEffect(.degrees(-90))
				.animation(.easeInOut(duration: 0.3), value: progress)
			
			// Percentage label
			if showPercentage {
				Text("\(Int(progress * 100))%")
					.font(.system(size: size / 4))
					.fontWeight(.bold)
					.foregroundColor(color)
			}
		}
		.frame(width: size, height: size)
	}
	
	/// Creates a detailed progress view with label, percentage, and fraction
	/// - Parameters:
	///   - progress: The progress value (0.0 to 1.0)
	///   - label: The label for the progress
	///   - currentCount: The current count (e.g., packed items)
	///   - totalCount: The total count (e.g., total items)
	/// - Returns: A detailed progress view
	static func detailed(
		progress: Double,
		label: String,
		currentCount: Int,
		totalCount: Int
	) -> some View {
		// Determine the progress color based on the progress value
		let progressColor: Color
		if progress < 0.3 {
			progressColor = .tripBuddyAlert.opacity(0.8)
		} else if progress < 1 {
			progressColor = .tripBuddyAccent.opacity(0.8)
		} else {
			progressColor = .tripBuddySuccess
		}
		
		return VStack(alignment: .leading, spacing: 6) {
			// Label and percentage
			HStack {
				Text(label)
					.font(.headline)
				
				Spacer()
				
				Text("\(Int(progress * 100))%")
					.font(.subheadline)
					.fontWeight(.semibold)
					.foregroundColor(progressColor)
			}
			
			// Progress bar
			PackingProgressView(progress: progress)
			
			// Item count
			Text("\(currentCount)/\(totalCount) items")
				.font(.caption)
				.foregroundColor(.tripBuddyTextSecondary)
		}
	}
}

// MARK: - Preview

#Preview {
	VStack(spacing: 30) {
		Group {
			// Standard progress view
			PackingProgressView(progress: 0.3)
				.padding(.horizontal)
			
			// Compact progress view
			PackingProgressView(progress: 0.7, isCompact: true)
				.padding(.horizontal)
			
			// Custom color progress view
			PackingProgressView(
				progress: 0.5,
				progressColor: .blue,
				height: 12,
				showPercentage: true
			)
			.padding(.horizontal)
			
			// Complete progress with checkmark
			PackingProgressView(
				progress: 1.0,
				showCompletionIcon: true
			)
			.padding(.horizontal)
		}
		
		Group {
			// Stepped progress view
			PackingProgressView.stepped(currentStep: 3, totalSteps: 5)
				.padding(.horizontal)
			
			// Stepped progress with custom colors
			PackingProgressView.stepped(
				currentStep: 2,
				totalSteps: 4,
				stepColors: [.green, .orange, .red, .purple]
			)
			.padding(.horizontal)
			
			// Circular progress view
			PackingProgressView.circular(progress: 0.65)
			
			// Detailed progress view
			PackingProgressView.detailed(
				progress: 0.42,
				label: "Packing Progress",
				currentCount: 5,
				totalCount: 12
			)
			.padding(.horizontal)
		}
	}
	.padding(.vertical)
	.background(Color.tripBuddyBackground)
}
