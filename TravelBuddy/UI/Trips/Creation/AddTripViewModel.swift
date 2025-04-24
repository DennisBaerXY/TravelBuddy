//
//  AddTripViewModel.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//


import Foundation
import SwiftUI
import Combine

/// View model responsible for managing the trip creation flow
class AddTripViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // Step tracking
    @Published var currentStep = 0
    let totalSteps = 4
    
    // Trip data
    @Published var tripName = ""
    @Published var destination = ""
    @Published var startDate = Date()
    @Published var endDate = Date().addingTimeInterval(86400 * 7) // One week from now
    @Published var selectedTransport: [TransportType] = []
    @Published var selectedAccommodation: AccommodationType = .hotel
    @Published var selectedActivities: [Activity] = []
    @Published var isBusinessTrip = false
    @Published var numberOfPeople = 1
    @Published var selectedClimate: Climate = .moderate
    
    // UI state
    @Published var validationMessage: String? = nil
    @Published var showingClimateInfo = false
    @Published var isKeyboardVisible = false
    
    // MARK: - Dependencies
    
    private let repository: TripRepository
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(repository: TripRepository) {
        self.repository = repository
    }
    
    // MARK: - Navigation
    
    /// Title for the current step
    var navigationTitle: LocalizedStringKey {
        switch currentStep {
        case 0: return "new_trip_step1_title" // Trip details
        case 1: return "new_trip_step2_title" // Transport & Accommodation
        case 2: return "new_trip_step3_title" // Activities & Details
        case 3: return "new_trip_step4_title" // Review
        default: return "new_trip"
        }
    }
    
    /// Moves to the next step after validation
    func goToNextStep() {
        if validateCurrentStep() {
            withAnimation {
                isKeyboardVisible = false
                currentStep += 1
                validationMessage = nil
            }
        }
    }
    
    /// Moves to the previous step
    func goToPreviousStep() {
        withAnimation {
            currentStep -= 1
            validationMessage = nil
        }
    }
    
    // MARK: - Validation
    
    /// Validates the current step data
    /// - Returns: Whether the current step is valid
    func validateCurrentStep() -> Bool {
        var isValid = true
        var message: String? = nil
        
        switch currentStep {
        case 0: // Trip details
            if tripName.isEmpty {
                isValid = false
                message = String(localized: "validation_missing_trip_name")
            } else if destination.isEmpty {
                isValid = false
                message = String(localized: "validation_missing_destination")
            }
            
        case 1: // Transport & Accommodation
            if selectedTransport.isEmpty {
                isValid = false
                message = String(localized: "validation_missing_transport")
            }
            
        case 2: // Activities & Details
            // No mandatory fields in this step
            break
            
        case 3: // Review
            // Review step doesn't need validation
            break
            
        default:
            break
        }
        
        // Update validation message
        validationMessage = isValid ? nil : message
        return isValid
    }
    
    // MARK: - Trip Creation
    
    /// Creates a new trip with the current data
    /// - Returns: Whether the trip was created successfully
    func createTrip() -> Bool {
        // Create the trip in the repository
        let trip = repository.createTrip(
            name: tripName,
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            transportTypes: selectedTransport,
            accommodationType: selectedAccommodation,
            activities: selectedActivities,
            isBusinessTrip: isBusinessTrip,
            numberOfPeople: numberOfPeople,
            climate: selectedClimate
        )
        
        return trip.id != UUID()
    }
    
    // MARK: - Computed Properties
    
    /// Returns true if the current step has validation errors
    var hasValidationError: Bool {
        validationMessage != nil
    }
    
    /// Returns true if the back button should be displayed
    var shouldShowBackButton: Bool {
        currentStep > 0
    }
    
    /// Returns true if this is the last step
    var isLastStep: Bool {
        currentStep == totalSteps - 1
    }
}