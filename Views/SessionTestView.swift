// SessionTestView.swift (assumed file)
import SwiftUI

struct SessionTestView: View {
    @StateObject private var tester: SessionTester
    
    init(sessionManager: SessionManager = .shared) {
        _tester = StateObject(wrappedValue: SessionTester(sessionManager: sessionManager))
    }
    
    var body: some View {
        VStack {
            Button("Run Session Test") {
                tester.runSessionTest()
            }
            Text("Session Test Status: \(tester.status)")
        }
    }
}

#Preview {
    SessionTestView()
}
