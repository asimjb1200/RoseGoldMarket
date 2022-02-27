//
//  HomeMarket.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import SwiftUI

struct HomeMarket: View {
    @Binding var tab: Int
    @StateObject var viewModel = HomeMarketViewModel()
    
    var categoryMapper = CategoryMapper()
    let columns = [ // I want two columns of equal width on this view
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    init(tab: Binding<Int>) {// changing the color of the nav bar title
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(named: "MainColor")!]
        self._tab = tab
    }
    var body: some View {
        NavigationView {
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
                    TextField("", text: $viewModel.searchTerm).padding([.top, .bottom], 2.0)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color("MainColor"))
                )
                .padding()
                
                Button("Search") {
                    viewModel.searchButtonPressed = true
                    viewModel.getFilteredItems()
                }

                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(viewModel.items, id: \.self) { x in
                            NavigationLink(destination: ItemDetails(item: x, viewingFromAccountDetails: false)) {
                                ItemPreview(itemId: x.id, itemTitle: x.name, itemImageLink: x.image1)
                                .onAppear() {
                                    print("on appear for home")
                                    if x == viewModel.items.last, viewModel.allDataLoaded == false {
                                        viewModel.getFilteredItems()
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
            .navigationBarTitle(Text("RoseGold"))
        }
    }
}

struct HomeMarket_Previews: PreviewProvider {
    static var previews: some View {
        HomeMarket(tab: Binding.constant(2))
    }
}
