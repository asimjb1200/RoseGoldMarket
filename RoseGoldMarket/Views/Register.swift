//
//  Register.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/12/22.
//

import SwiftUI
import CoreLocation

struct Register: View {
    @Environment(\.presentationMode) var presentation
    @State var username = ""
    @State var email = ""
    @State var password = ""
    @State var address = ""
    @State var zipCode = ""
    @State var state = ""
    @State var city = ""
    @State var avatar:UIImage? = UIImage(named: "default")!
    @State var dataPosted = false
    @State var imageEnum: PlantOptions = .imageOne
    @State var isShowingPhotoPicker = false
    @State var spacesFoundInField = false
    @State var fieldsEmpty = false
    @State var statePicker: [String] = ["Select A State","AL","AK","AZ","AR","AS","CA","CO","CT","DE","DC","FL","GA","GU","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","CM","OH","OK","OR","PA","PR","RI","SC","SD","TN","TX","TT","UT","VT","VI","WA","WV","WI","WY"]
    
    var body: some View {
        VStack {
            Text("Profile Picture and Information")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("AccentColor"))
                .alert(isPresented: $spacesFoundInField) {
                    Alert(title: Text("Check Your Info"), message: Text("You can only have spaces in the City and Address fields. Every other field should not have spaces between words and characters."), dismissButton: .default(Text("Got It")))
                }
            
            Image(uiImage: avatar!)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 150, height: 150)
                    .onTapGesture {
                        imageEnum = .imageOne
                        isShowingPhotoPicker = true
                    }
            
            ScrollView {
                HStack {
                    Image(systemName: "pencil").foregroundColor(Color("MainColor"))
                    TextField("Username", text: $username).textInputAutocapitalization(.never).disableAutocorrection(true)
                }.padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color("MainColor"))
                )
                .padding()
                .alert(isPresented: $fieldsEmpty) {
                    Alert(title: Text("Check Your Info"), message: Text("Fill out every field in the form to sign up."), dismissButton: .default(Text("Got It")))
                }
                
                HStack {
                    Image(systemName: "key.fill").foregroundColor(Color("MainColor"))
                    SecureField("Password", text: $password).textInputAutocapitalization(.never).disableAutocorrection(true)
                }.padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color("MainColor"))
                )
                .padding()
                
                HStack {
                    Text("@").foregroundColor(Color("MainColor"))
                    TextField("Email", text: $email).textInputAutocapitalization(.never).disableAutocorrection(true)
                }.padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color("MainColor"))
                )
                .padding()
                
                HStack {
                    Image(systemName: "signpost.right.fill").foregroundColor(Color("MainColor"))
                    TextField("Address", text: $address).textInputAutocapitalization(.never).disableAutocorrection(true)
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
                
                HStack {
                    Image(systemName: "map.fill").foregroundColor(Color("MainColor"))
                    Picker("State", selection: $state) {
                        ForEach(statePicker, id:\.self) {
                            Text($0)
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth:.infinity)
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
                
                Button("Register") {
                    // perform make sure all fields aren't empty
                    guard textFieldsEmpty() == false else {
                        fieldsEmpty = true
                        return
                    }
                    
                    guard state != "Select A State" else {
                        return
                    }
                    
                    // the only fields that should have spaces are city and address
                    guard spacesFound() == false else {
                        spacesFoundInField = true
                        return
                    }
                    
                    // unwrap the avatar optional
                    guard avatar == avatar else {
                        return
                    }
                    
                    getAndSaveUserLocation()
                }.alert(isPresented: $dataPosted) {
                    Alert(title: Text("Success"), message: Text("You've now been signed up, go back and log in."), dismissButton: .default(Text("OK"), action: { self.presentation.wrappedValue.dismiss() }))
                }
                Spacer()
            }
            
        }.sheet(isPresented: $isShowingPhotoPicker, content: {
            PhotoPicker(plantImage: $avatar, plantImage2: Binding.constant(nil), plantImage3: Binding.constant(nil), plantEnum: $imageEnum)
        })
    }
    
    func getAndSaveUserLocation() {
        let geocoder = CLGeocoder()
        let checkAddressForGeoLo = "\(address), \(city), \(state) \(zipCode)"
        geocoder.geocodeAddressString(checkAddressForGeoLo) { placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            
            if let lon = lon, let lat = lat { // unwrap the optionals
                // (long, lat) for database now send new addy and long/lat to the database
                let geoLocation = "(\(lon),\(lat))"
                
                // register the new user
                self.registerUser(geolocation: geoLocation)
            }
        }
    }
    
    func registerUser(geolocation:String) -> () {
        UserNetworking.shared.registerUser(username: self.username, email: self.email, pw: self.password, addy: self.address, zip: UInt(self.zipCode)!, state: self.state, city: self.city, geolocation: geolocation, avi: self.avatar!.jpegData(compressionQuality: 0.5)!) { registerResponse in
            switch registerResponse {
                case .success(let res):
                    DispatchQueue.main.async {
                        self.dataPosted = res
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        print(err)
                    }
            }
        }
    }
    
    func textFieldsEmpty() -> Bool {
        var fieldIsEmpty = false
        for field in [username, email, password, address, zipCode, state, city] {
            if field.isEmpty {
                if fieldIsEmpty == false {
                    fieldIsEmpty = true
                }
            }
        }
        return fieldIsEmpty
    }
    
    func spacesFound() -> Bool {
        var spacesFound = false
        for field in [username, email, password, zipCode, state] {
            if field.contains(" ") {
                if spacesFound == false {
                    spacesFound = true
                }
            }
        }
        return spacesFound
    }
}

struct Register_Previews: PreviewProvider {
    static var previews: some View {
        Register()
    }
}
