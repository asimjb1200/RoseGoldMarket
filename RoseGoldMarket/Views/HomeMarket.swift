//
//  HomeMarket.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import SwiftUI

struct HomeMarket: View {
    @Binding var tab: Int
    @State var firstAppear = true
    @State var locationLoaded = false
    @EnvironmentObject var user:UserModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = HomeMarketViewModel()
    @StateObject var locationManager = LocationManager()

    var categoryMapper = CategoryMapper()
    let columns = [ // I want two columns of equal width on this view
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]

    var userGeolocation: String {
        return "(\(locationManager.lastLocation?.coordinate.longitude ?? 0), \(locationManager.lastLocation?.coordinate.latitude ?? 0))"
    }

    init(tab: Binding<Int>) {// changing the color of the nav bar title
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(named: "MainColor")!]
        self._tab = tab
    }

    var body: some View {
        if locationManager.lastLocation == nil && locationManager.databaseLocation == nil {
            Text("We need to access your location in order to use this application. Your location is used to connect you to people in your area.")
                .padding()
        } else {
        NavigationView {
            VStack {
                VStack {
                    HStack {
                        Button("Filters") {
                            viewModel.showFilterSheet = true
                        }
                        .padding()
                        .sheet(isPresented: $viewModel.showFilterSheet) {
                            Text("Choose Your Filters")
                                .fontWeight(.bold)
                                .foregroundColor(Color("MainColor"))
                                .padding([.top, .bottom])
                                
                            ForEach($viewModel.categoryHolder) { $cat in
                                Toggle("\(categoryMapper.categories[cat.category]!)", isOn: $cat.isActive)
                                    .tint(Color("MainColor"))
                                    .padding([.leading, .trailing])
                            }
                            Spacer()
                        }
                        Spacer()
                        Text("Search Radius: ")
                        Picker("Search Radius", selection: $viewModel.searchRadius) {
                            ForEach(viewModel.mileOptions, id: \.self) {
                                Text("\($0)")
                            }
                        }.pickerStyle(MenuPickerStyle()).padding()
                    }.frame(height: 30)
                    
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(Color("MainColor")).padding(.leading)
                        TextField("", text: $viewModel.searchTerm).padding([.top, .bottom], 2.0).textFieldStyle(OvalTextFieldStyle())
                    }
                    .padding(5.0)
                    
                    
                    Button("Search") {
                        viewModel.searchButtonPressed = true
                        viewModel.getFilteredItems(user: user, geoLocation: userGeolocation)
                    }
                    .padding(.horizontal)
                    .onAppear() {
                        if firstAppear {
                            firstAppear = false
                            determineUserLocation()
                        }
                    }
                    
                    Divider().shadow(radius: 5)
                }
                .padding(.bottom, 2.0)
                .background(
                    colorScheme == .dark ? Color.gray.opacity(0.5) : Color.white
                )
                .shadow(radius: 5)
                
                
                
                if viewModel.items.isEmpty {
                    Text("No items in your area")
                        .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(viewModel.items, id: \.self) { x in
                                NavigationLink(destination: ItemDetails(item: x, viewingFromAccountDetails: false)) {
                                    ItemPreview(itemId: x.id, itemTitle: x.name, itemImageLink: x.image1)
                                    .shadow(radius: 5)
                                    .onAppear() {
                                        if x == viewModel.items.last, viewModel.allDataLoaded == false {
                                            determineUserLocation()
                                        }
                                    }
                                }
                            }
                            if viewModel.isLoadingPage {
                                ProgressView()
                            }
                        }
                    }
                }
            }.navigationBarTitle(Text("RoseGold"), displayMode: .inline)
        }
        }
    }
    
    func determineUserLocation() {
        if locationManager.lastLocation != nil {
            viewModel.getFilteredItems(user: user, geoLocation: userGeolocation)
        } else {
            guard let databaseLocation = locationManager.databaseLocation else {
                return
            }
            viewModel.getFilteredItems(user: user, geoLocation: databaseLocation)
        }
    }
}

struct HomeMarket_Previews: PreviewProvider {
    static var previews: some View {
        HomeMarket(tab: Binding.constant(2))
    }
}
