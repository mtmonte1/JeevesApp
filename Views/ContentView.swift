// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var coordinator: AIAgentCoordinator
    @StateObject private var sessionTester: SessionTester
    @State private var userInput: String = ""
    @State private var responseText: String = "Waiting for command..."
    @State private var parsedIntent: String = ""
    
    private let intentParser = LocalIntentParser()
    
    init(sessionManager: SessionManager = .shared) {
        let coordinator = AIAgentCoordinator(sessionManager: sessionManager)
        let sessionTester = SessionTester(sessionManager: sessionManager)
        _coordinator = StateObject(wrappedValue: coordinator)
        _sessionTester = StateObject(wrappedValue: sessionTester)
        NSLog("ContentView init called")
        coordinator.registerAgent(MockAgent())
        NSLog("MockAgent registered in init")
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Pomodoro Coach")
                .font(.largeTitle)
                .padding()
            
            Text("Parsed Intent: \(parsedIntent)")
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Text(responseText)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            HStack {
                TextField("Enter command (e.g., start timer, mute, deep focus)", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: processCommand) {
                    Text("Send")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            Button("Run Session Test") {
                NSLog("Run Session Test button pressed")
                sessionTester.runSessionTest()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Text("Session Test Status: \(sessionTester.status)")
                .padding()
        }
        .padding()
        .onAppear {
            NSLog("ContentView onAppear called")
            coordinator.registerAgent(MockAgent())
            NSLog("MockAgent registered in onAppear")
        }
    }
    
    private func processCommand() {
        guard !userInput.isEmpty else {
            responseText = "Please enter a command."
            NSLog("Empty command entered")
            return
        }
        
        if let intent = intentParser.parse(userInput) {
            parsedIntent = intent.description
            NSLog("Parsed intent: \(intent.description)")
            let agentInput = convertIntentToAgentInput(intent)
            NSLog("Converted to AgentInput: \(agentInput.data)")
            
            DispatchQueue.global().async {
                do {
                    let context = try self.coordinator.sessionManager.loadSession()
                    NSLog("Loaded context, processing input: \(agentInput.data)")
                    self.coordinator.process(input: agentInput, context: context) { response in
                        DispatchQueue.main.async {
                            self.responseText = response.text
                            if let error = response.error {
                                self.responseText += "\nError: \(error.message)"
                            }
                            NSLog("Response received: \(response.text)")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.responseText = "Error loading session: \(error.localizedDescription)"
                    }
                    NSLog("Error loading session: \(error.localizedDescription)")
                }
            }
        } else {
            responseText = "Unrecognized command: \(userInput)"
            parsedIntent = "N/A"
            NSLog("Failed to parse: \(userInput)")
        }
        userInput = ""
    }
    
    private func convertIntentToAgentInput(_ intent: Intent) -> AgentInput {
        switch intent.action {
        case .startTimer(let duration):
            return AgentInput(source: .text, data: "start_timer\(duration.map { "_\($0)" } ?? "")")
        case .stopTimer:
            return AgentInput(source: .text, data: "stop_timer")
        case .pauseTimer:
            return AgentInput(source: .text, data: "pause_timer")
        case .resumeTimer:
            return AgentInput(source: .text, data: "resume_timer")
        case .mute:
            return AgentInput(source: .text, data: "mute")
        case .unmute:
            return AgentInput(source: .text, data: "unmute")
        case .deepFocus(let enabled):
            return AgentInput(source: .text, data: "deep_focus_\(enabled)")
        case .summarizeSession:
            return AgentInput(source: .text, data: "summarize_session")
        case .triggerAgent(let name, let command):
            return AgentInput(source: .text, data: "trigger_\(name)_\(command)")
        }
    }
}

#Preview {
    ContentView()
}
