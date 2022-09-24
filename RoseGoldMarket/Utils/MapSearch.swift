//
//  MapSearch.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 9/7/22.
//

import Foundation
import Combine
import MapKit

class MapSearch : NSObject, ObservableObject {
    @Published var locationResults : [MKLocalSearchCompletion] = []
    @Published var searchTerm = ""
    @Published var addressFound = false
    @Published private var coordinates:CLLocationCoordinate2D? //long and lat of a location
    @Published var addressInfo:AddressInformation? // this will hold all of the address info for the backend

    
    private var cancellables : Set<AnyCancellable> = []
    
    private var searchCompleter = MKLocalSearchCompleter() // this is what the query fragment will feed into
    private var currentPromise : ((Result<[MKLocalSearchCompletion], Error>) -> Void)?
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        
        $searchTerm
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap({ (currentSearchTerm) in // this gets rid of possible double optional types
                self.searchTermToResults(searchTerm: currentSearchTerm)
            })
            .sink(receiveCompletion: { (completion) in // we subscribe to the values from the publisher here
                //handle error
            }, receiveValue: { (results) in // this receives the values from the publisher that flat map creates, the published stream "sinks" into this method
                self.locationResults = results
            })
            .store(in: &cancellables)
    }
    
    func searchTermToResults(searchTerm: String) -> Future<[MKLocalSearchCompletion], Error> {
        return Future { promise in
            self.searchCompleter.queryFragment = searchTerm // this is where we pass the search term to map kit to be searched
            self.currentPromise = promise
        }
    }
    
    func validateAddress(location: MKLocalSearchCompletion) { // use this function to get the coordinates of the selected address
        let searchRequest = MKLocalSearch.Request(completion: location)
        let search = MKLocalSearch(request: searchRequest) // look up the location
        search.start { (response, error) in // process the results
            guard
                error == nil,
                let coordinate = response?.mapItems.first?.placemark.coordinate,
                let address = response?.mapItems.first?.placemark.thoroughfare,
                let numIdentifier = response?.mapItems.first?.placemark.subThoroughfare, // this will be the bldg # usually
                let city = response?.mapItems.first?.placemark.locality,
                let state = response?.mapItems.first?.placemark.administrativeArea,
                let zipCode = response?.mapItems.first?.placemark.postalCode
            else {
                print("an error occurred")
                return
            }
            
            self.addressInfo = AddressInformation(geolocation: "\(coordinate.longitude), \(coordinate.latitude)", address: "\(numIdentifier) \(address)", city: city, state: state, zipCode: zipCode)
        }
    }
    
    func validateAddress(locationString: String, completion: @escaping ((addressFound:Bool, addyInfo:AddressInformation?)) -> () ) {
        // attempt to locate the adddress by a natural language string
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = locationString
        
        // start the search
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in // process the results
            guard
                error == nil,
                let coordinate = response?.mapItems.first?.placemark.coordinate,
                let address = response?.mapItems.first?.placemark.thoroughfare,
                let numIdentifier = response?.mapItems.first?.placemark.subThoroughfare, // this will be the bldg # usually
                let city = response?.mapItems.first?.placemark.locality,
                let state = response?.mapItems.first?.placemark.administrativeArea,
                let zipCode = response?.mapItems.first?.placemark.postalCode
            else {
                print("an error occurred \(String(describing: error))")
                completion((addressFound: false, addyInfo: nil))
                return
            }

            self.addressInfo = AddressInformation(geolocation: "\(coordinate.longitude), \(coordinate.latitude)", address: "\(numIdentifier) \(address)", city: city, state: state, zipCode: zipCode)
            completion((addressFound: true, addyInfo: self.addressInfo))
        }
    }
}

extension MapSearch : MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) { // this is where we get the results of the map kit query
        if !addressFound {
            currentPromise?(.success(completer.results))
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        //could deal with the error here, but beware that it will finish the Combine publisher stream
        //currentPromise?(.failure(error))
    }
}
