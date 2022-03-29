//
//  ChangeLocation.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/2/22.
//

import SwiftUI
import CoreLocation

struct ChangeLocation: View {
    @State var address = ""
    @State var zipCode = ""
    @State var state = ""
    @State var city = ""
    @State var dataSaved = false
    @State var dataNotSaved = false
    @State var addressData = ""
    @State var addressNotFound = false
    @State var statePicker: [String] = ["Select A State","AL","AK","AZ","AR","AS","CA","CO","CT","DE","DC","FL","GA","GU","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","CM","OH","OK","OR","PA","PR","RI","SC","SD","TN","TX","TT","UT","VT","VI","WA","WV","WI","WY"]
    @EnvironmentObject var user:UserModel
    
    var body: some View {
        VStack {
            Text("Your Current Address")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(Color("AccentColor"))
            Text(addressData)
            HStack {
                Image(systemName: "signpost.right.fill").foregroundColor(Color("MainColor"))
                TextField("Address", text: $address)
            }.padding()
                .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .foregroundColor(Color("MainColor"))
            )
            .padding()
            
            HStack {
                Image(systemName: "building.2.fill").foregroundColor(Color("MainColor"))
                TextField("City", text: $city)
            }.padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .foregroundColor(Color("MainColor"))
            )
            .padding()
            .alert(isPresented: $addressNotFound) {
                Alert(title: Text("Your new address could not be verified."))
            }
            
            HStack {
                Image(systemName: "map.fill").foregroundColor(Color("MainColor"))
                Picker("State", selection: $state) {
                    ForEach(statePicker, id:\.self) {
                        Text($0)
                    }
                }
                Spacer()
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .foregroundColor(Color("MainColor"))
            )
            .padding()
            
            HStack {
                Image(systemName: "mappin.and.ellipse").foregroundColor(Color("MainColor"))
                TextField("Zip Code", text: $zipCode)
            }
            .padding()
                .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .foregroundColor(Color("MainColor"))
            )
            .padding().keyboardType(.decimalPad)
            .alert(isPresented: $dataNotSaved) {
                Alert(title: Text("Address Not Updated"), message: Text("There was a problem saving your data. Try again later."), dismissButton: .default(Text("OK")))
            }

            Button("Submit") {
                // check to make sure that each of the fields aren't 0 or blank
                guard
                    UInt(zipCode)! > 0,
                    !state.isEmpty,
                    !city.isEmpty,
                    !address.isEmpty
                else {
                    return
                }
                
                getAndSaveUserLocation()
            }
            .alert(isPresented: $dataSaved) {
                Alert(title: Text("Address Updated"), dismissButton: .default(Text("OK")))
            }
            
        }.onAppear() {
            // load in the user's current data
             fetchCurrentAddress(user: user)
        }
    }
    
    func getAndSaveUserLocation() {
        let geocoder = CLGeocoder()
        let checkAddressForGeoLo = "\(address), \(city), \(state) \(zipCode)"
        geocoder.geocodeAddressString(checkAddressForGeoLo) { placemarks, error in
            guard error == nil else {
                self.addressNotFound = true
                return
            }
            
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            
            if let lon = lon, let lat = lat { // unwrap the optionals
                // (long, lat) for database now send new addy and long/lat to the database
                let geoLocation = "(\(lon),\(lat))"
                
                // save their location
                saveNewUserLocation(geoLocation: geoLocation)
            }
        }
    }
    
    func saveNewUserLocation(geoLocation: String) {
        UserNetworking.shared.saveNewAddress(newAddress: address, newCity: city, newState: state, newZipCode: UInt(zipCode)!, newGeoLocation: geoLocation, token: user.accessToken, completion: { response in
            switch(response) {
                case .success(let isSaved):
                    DispatchQueue.main.async {
                        if isSaved.data {
                            self.dataSaved.toggle()
                        } else {
                            self.dataNotSaved.toggle()
                        }
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        print(err.localizedDescription)
                    }
            }
        })
    }
    
    func fetchCurrentAddress(user:UserModel) {
        print("fetching the address")
        UserNetworking.shared.fetchCurrentAddress(accountId: user.accountId, token: user.accessToken, completion: {addressData in
            switch addressData {
                case .success(let addressData):
                    DispatchQueue.main.async {
                        if addressData.newToken != nil {
                            user.accessToken = addressData.newToken!
                        }
                        self.addressData = "\(addressData.data.address) \(addressData.data.zipcode)"
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error)
                    }
            }
        })
    }
}

struct ChangeLocation_Previews: PreviewProvider {
    static var previews: some View {
        ChangeLocation()
    }
}
