//
//  ChangeLocation.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/2/22.
//

import SwiftUI
import CoreLocation

struct ChangeLocation: View {
    @EnvironmentObject var user:UserModel
    @StateObject var mapService:MapSearch = MapSearch()
    @State var address = ""
    @State var addressLineTwo = ""
    @State var dataSaved = false
    @State var dataNotSaved = false
    @State var addressData = ""
    @State var addressNotFound = false
    @State var addressInformation:AddressInformation? = nil
    @FocusState private var focusedField: LocationFields?
    var buttonWidth = UIScreen.main.bounds.width * 0.85
    private enum LocationFields: Int, CaseIterable {
        case address, addressLineTwo
    }
    
    
    var body: some View {
        VStack {
            Text("Your Current Address")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(Color("AccentColor"))
                .alert(isPresented: $addressNotFound) {
                    Alert(title: Text("Select your address from the list"), message: Text("We need you to select your address to validate it."))
                }
                
            if addressData.isEmpty {
                ProgressView().foregroundColor(.blue).frame(maxWidth: .infinity, alignment: .center)
            } else {
                Text(addressData)
            }
            
            HStack {
                Image(systemName: "signpost.right.fill").foregroundColor(focusedField == .address ? .blue : .gray)
                
                TextField("Address", text: $mapService.searchTerm).focused($focusedField, equals: .address)
                    .textContentType(UITextContentType.streetAddressLine1)
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            Button("Done") {
                                focusedField = nil
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .onChange(of: mapService.searchTerm) { [oldAddyString = mapService.searchTerm] newStr in
                        // if the new string is shorter than the old one, we know they are deleting and therefore suggestions should show up
                        
                        if newStr.count < oldAddyString.count {
                            mapService.addressFound = false
                        }
                    }
                
                TextField("Apt", text: $addressLineTwo)
                    .focused($focusedField, equals: .addressLineTwo)
                    .frame(width: 60, alignment: .trailing)
                    .textContentType(UITextContentType.streetAddressLine2)
            }
            .padding()
            .modifier(CustomTextBubble(isActive: focusedField == .address || focusedField == .addressLineTwo, accentColor: .blue))
            .padding()
            .alert(isPresented: $dataNotSaved) {
                Alert(title: Text("Address Not Updated"), message: Text("There was a problem saving your data. Try again later."), dismissButton: .default(Text("OK")))
            }
            
            if mapService.locationResults.isEmpty == false {
                ScrollView {
                    ForEach(mapService.locationResults, id: \.self) { location in
                        VStack(alignment: .center, spacing: 0.0) {
                            Text(location.title)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                            Text(location.subtitle)
                                .font(.system(.caption))
                                .frame(maxWidth: .infinity)
                        }.onTapGesture {
                            mapService.validateAddress(location: location) {(addressFound, addyInfo) in
                                DispatchQueue.main.async {
                                    if addressFound && addyInfo != nil {
                                        addressInformation = addyInfo
                                        mapService.searchTerm = "\(location.title)"
                                        mapService.addressFound = true
                                        
                                        // when they select a location clear out the search results and then...
                                        mapService.locationResults = []
                                    }
                                }
                            }
                        }
                        Divider()
                    }
                }
                .frame(maxHeight: 120)
            }

            Button(
                action: {
                    guard !address.isEmpty else {
                        focusedField = .address
                        return
                    }
                    
                    guard var addyInformation = addressInformation else {
                        addressNotFound.toggle()
                        return
                    }
                    
                    if !addressLineTwo.isEmpty {
                        addyInformation.address += " #\(addressLineTwo)"
                    }
                    
                    saveNewUserLocation(addressObject: addyInformation)
                },
                label: {
                    Text("Submit")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.white)
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color("AccentColor")).frame(width: buttonWidth, height: 50))
                        .padding()
                }
            )
            .alert(isPresented: $dataSaved) {
                Alert(title: Text("Address Updated"), dismissButton: .default(Text("OK")))
            }
            
            Spacer()
            
        }
        .navigationBarTitle(Text("Change Address"), displayMode: .inline)
        .onAppear() {
            // load in the user's current data
             fetchCurrentAddress(user: user)
        }
    }
    
    func saveNewUserLocation(addressObject:AddressInformation) {
        UserNetworking.shared.saveNewAddress(newAddress: addressObject.address, newCity: addressObject.city, newState: addressObject.state, newZipCode: UInt(addressObject.zipCode)!, newGeoLocation: addressObject.geolocation, token: user.accessToken, completion: { response in
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
        ChangeLocation().environmentObject(UserModel.shared)
    }
}
