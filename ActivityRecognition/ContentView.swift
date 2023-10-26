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
    
    func activityTypeString(activity: CMMotionActivity) -> String {
        if activity.running {
            return "Running"
        } else if activity.walking {
            return "Walking"
        } else if activity.automotive {
            return "Automotive"
        } else if activity.cycling {
            return "Cycling"
        } else if activity.stationary {
            return "Stationary"
        } else {
            return "Unknown"
        }
    }
    
    var body: some View {
        VStack {
            
            Text("Activity recognition").font(.largeTitle)
            Button("Clear", role: .destructive) {
                self.motionManager.activities.removeAll()
            }
            List(motionManager.activities.sorted(by: { $0.startDate > $1.startDate
            }), id: \.startDate) { activity in
                HStack {
                    VStack(alignment: .leading) {
                        Text(activityTypeString(activity: activity))
                        Text(activity.startDate.description).font(.footnote).foregroundColor(.gray)
                    }
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
