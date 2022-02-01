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
    let columns = [ // I want two columns of equal width on this view
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(tab: Binding<Int>) {// changing the color of the nav bar title
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(named: "MainColor") ?? .black]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(named: "MainColor") ?? .black]
        UITextView.appearance().backgroundColor = .clear
        self._tab = tab
    }
    var body: some View {
        NavigationView {
            VStack {
                Button("Filters") {
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(Color("MainColor")).padding(.leading)
                    TextField("", text: $viewModel.searchTerm).padding([.top, .bottom], 2.0)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color("MainColor"))
                )
                .padding([.leading, .trailing, .bottom])
                

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                            
                        ForEach(viewModel.items, id: \.self) {x in
                            NavigationLink(destination: Text("Detail View")) {
                                ItemPreview(itemId: x.id, itemTitle: x.name, itemImageLink: x.image1)
                            }
                        }
                    }.onAppear() {
                        if viewModel.items.isEmpty {
                            viewModel.getFilteredItems()
                        }
                    }
                }
            }.navigationTitle("RoseGold")
        }
        
        
    }
}

struct HomeMarket_Previews: PreviewProvider {
    static var previews: some View {
        HomeMarket(tab: Binding.constant(5))
    }
}
