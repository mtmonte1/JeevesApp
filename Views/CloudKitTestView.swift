//
//  CloudKitTestView.swift
//  JeevesApp
//
//  Created by Mitch Montelaro on 3/4/25.
//


// CloudKitTestView.swift
import SwiftUI

struct CloudKitTestView: View {
    @StateObject private var tester = CloudKitTester()
    
    var body: some View {
        NavigationStack {
            VStack {
                // Test buttons
                HStack {
                    Button("Create Test Data") {
                        tester.runTest()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("List Test Data") {
                        tester.listAllTestData()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Clear All Tests") {
                        tester.clearAllTestData()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .padding()
                
                // Test tasks list
                List {
                    Section("Found Test Tasks") {
                        ForEach(tester.testTasks) { task in
                            VStack(alignment: .leading) {
                                Text(task.title ?? "Untitled")
                                    .font(.headline)
                                Text("Created: \(task.createdAt?.formatted() ?? "Unknown date")")
                                    .font(.caption)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        if tester.testTasks.isEmpty {
                            Text("No test tasks found")
                                .italic()
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Results console
                ScrollView {
                    Text(tester.testResults)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding()
            }
            .navigationTitle("CloudKit Test")
        }
    }
}

#Preview {
    CloudKitTestView()
}