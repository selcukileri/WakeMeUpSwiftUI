//
//  LocationSearchView.swift
//  WakeMeUpSwiftUI
//
//  Created by Selçuk İleri on 5.11.2025.
//

import SwiftUI
import MapKit

@Observable
class LocationSearchService: NSObject, MKLocalSearchCompleterDelegate {
    var searchQuery = ""
    var searchResults: [MKLocalSearchCompletion] = []
    private let completer = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }
    
    func updateSearch(_ query: String) {
        searchQuery = query
        
        if query.isEmpty {
            searchResults = []
            return
        }
        
        completer.queryFragment = query
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search error: \(error.localizedDescription)")
    }
}
