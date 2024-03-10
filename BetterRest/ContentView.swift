//
//  ContentView.swift
//  BetterRest
//
//  Created by Margarita Mayer on 20/12/23.
//
import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeUpTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var goToSleepTime = defaultGoToSleepTime
    
//    @State private var alertTitle = ""
//    @State private var alertMessage = ""
//    @State private var showingAlert = false
    
    static var defaultWakeUpTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    static var defaultGoToSleepTime: Date {
        var components = DateComponents()
        components.hour = 23
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        
        NavigationStack {
            Form {
               Section {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .onChange(of: wakeUp) {
                            calculateBedtime()
                        }
                }
               
                
               Section {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                       .onChange(of: sleepAmount) {
                           calculateBedtime()
                       }
                }
                
                Section {
                    Text("Daily coffee intake")
                        .font(.headline)
                    /*Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)*/
                    Picker("^[\(coffeeAmount) cup](inflect: true)", selection: $coffeeAmount) {
                        ForEach(0..<20) {
                            Text("\($0)")
                        }
                    }
                    .onChange(of: coffeeAmount) {
                        calculateBedtime()
                    }
                }
                
                Section {
                    Text("Your ideal bedtime is \(calculateBedtime().formatted(date: .omitted, time: .shortened))")
                        .font(.title2)
                }
            }
            .navigationTitle("BetterRest")
//            .toolbar {
//                Button("Calculate", action: calculateBedtime)
//            }
//            .alert(alertTitle, isPresented: $showingAlert) {
//                Button("Ok") {}
//            } message: {
//                Text(alertMessage)
//            }
        }
    }
    
    func calculateBedtime() -> Date {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            goToSleepTime = sleepTime
//            alertTitle = "Your idel bedtime is..."
//            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
//            alertTitle = "Error"
//            alertMessage = "Sorry, there was a problem"
        }
        
//        showingAlert = true
        return goToSleepTime
    }
    
}

#Preview {
    ContentView()
}
