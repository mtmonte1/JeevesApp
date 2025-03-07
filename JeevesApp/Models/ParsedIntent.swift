//
//  ParsedIntent.swift
//  JeevesApp
//
//  Created by Mitch Montelaro on 3/4/25.
//


import Foundation

struct ParsedIntent {
    let domain: String
    let intent: String
    let params: [String: Any]
    let confidence: Float?
    let rawInput: String
    
    init(domain: String, intent: String, params: [String: Any] = [:], confidence: Float? = nil, rawInput: String) {
        self.domain = domain
        self.intent = intent
        self.params = params
        self.confidence = confidence
        self.rawInput = rawInput
    }
}