//
//  ContentView.swift
//  ActivityRecognition
//
//  Created by Mathieu Vandeginste on 26/10/2023.
//

import SwiftUI
import CoreMotion
import Charts

class MotionManager: ObservableObject {
    private var motionActivityManager = CMMotionActivityManager()
    
    @Published var activities: [CMMotionActivity] = []
    
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            print("Activity data is not available.")
            return
        }
        
        motionActivityManager.startActivityUpdates(to: OperationQueue.main) { (activity) in
            guard let activity = activity else { return }
            
            // Ajouter l'activité à la liste
            self.activities.append(activity)
        }
    }
    
    func stopMonitoring() {
        motionActivityManager.stopActivityUpdates()
    }
}


struct ContentView: View {
    
    @ObservedObject var motionManager = MotionManager()
    @State var sorting: Sorting = .all
    private let formatter = DateFormatter()
    
    enum Sorting: String, CaseIterable, Equatable {
        case all, low, medium, high
        var localized: String { self.rawValue }
    }
    
    func display(activity: CMMotionActivity) -> Bool {
        switch activity.confidence {
        case .low:
            sorting == .all || sorting == .low
        case .medium:
            sorting == .all || sorting == .medium
        case .high:
            sorting == .all || sorting == .high
        @unknown default:
            sorting == .all
        }
    }
    func activityType(activity: CMMotionActivity) -> Image {
        if activity.running {
            return Image(systemName: "figure.run")
        } else if activity.walking {
            return Image(systemName: "figure.walk")
        } else if activity.automotive {
            return Image(systemName: "car.side")
        } else if activity.cycling {
            return Image(systemName: "figure.outdoor.cycle")
        } else if activity.stationary {
            return Image(systemName: "figure.stand")
        } else {
            return Image(systemName: "questionmark.circle")
        }
    }
    
    func dateString(activity: CMMotionActivity) -> String {
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: activity.startDate)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            
            
            Text("Activity recognition").font(.largeTitle)
            
            
            Button("Clear", role: .destructive) {
                self.motionManager.activities.removeAll()
            }
            
            HStack {
                Text("accuracy:")
                Picker(selection: $sorting, label: Text("")) {
                    ForEach(Sorting.allCases, id: \.self) { sort in
                        Text(LocalizedStringKey(sort.rawValue))
                    }
                }.pickerStyle(.segmented)
            }
            List(motionManager.activities
                .sorted(by: { $0.startDate > $1.startDate
            }).filter({
                display(activity: $0)
            }), id: \.startDate) { activity in
                HStack {
                    activityType(activity: activity)
                    Text(dateString(activity: activity))
                    Spacer()
                    ConfidenceView(confidence: activity.confidence)
                }
                
            }
            .navigationTitle("Core Motion Activities")
            
        }
    }
}

#Preview {
    ContentView()
}


struct ConfidenceView: View {
    
    var confidence: CMMotionActivityConfidence
    
    var body: some View {
        
        HStack(spacing: 3) {
            
            switch confidence {
            case .low:
                Circle().foregroundColor(.red)
            case .medium:
                Circle().foregroundColor(.orange)
            case .high:
                Circle().foregroundColor(.green)
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 60, height: 10, alignment: .center)
        
    }
    
}
