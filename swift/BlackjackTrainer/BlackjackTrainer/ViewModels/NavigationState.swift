import Foundation
import SwiftUI
import Observation

// MARK: - Navigation Destination

enum NavigationDestination: Hashable {
    case trainingSession(SessionConfiguration)
    case dealerGroupSelection
    case handTypeSelection
    case statistics
    case strategyGuide
}

// MARK: - Navigation State

@MainActor
@Observable
public class NavigationState {
    var path = NavigationPath()
    
    public init() {}
    
    func navigateToSession(_ config: SessionConfiguration) {
        path.append(NavigationDestination.trainingSession(config))
    }
    
    func navigateToDealerGroups() {
        path.append(NavigationDestination.dealerGroupSelection)
    }
    
    func navigateToHandTypes() {
        path.append(NavigationDestination.handTypeSelection)
    }
    
    func navigateToStatistics() {
        path.append(NavigationDestination.statistics)
    }
    
    func navigateToStrategyGuide() {
        path.append(NavigationDestination.strategyGuide)
    }
    
    func navigateBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
}

