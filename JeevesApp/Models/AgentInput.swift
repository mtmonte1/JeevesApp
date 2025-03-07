//
//  AgentInput.swift
//  JeevesApp
//
//  Created by Mitch Montelaro on 3/4/25.
//


import Foundation

struct AgentInput {
    let source: InputSource
    let data: String
    let timestamp: Date
    
    init(source: InputSource, data: Any) {
        self.source = source
        self.data = data as! String
        self.timestamp = Date()
    }
}

enum InputSource {
    case text
    case audio
    case ui
}
