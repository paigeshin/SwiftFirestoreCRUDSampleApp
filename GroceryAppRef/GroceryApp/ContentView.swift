//
//  ContentView.swift
//  GroceryApp
//
//  Created by Mohammad Azam on 10/23/20.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isPresented: Bool = false
    @ObservedObject private var storeListVM = StoreListViewModel() 
    
    var body: some View {
        VStack {
            List(storeListVM.stores, id: \.name) { store in
                NavigationLink(
                    destination: StoreItemsListView(store: store),
                    label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(store.name)
                                .font(.headline)
                            Text(store.address)
                                .font(.body)
                        }
                    })
            }.listStyle(PlainListStyle())
        }
        .sheet(isPresented: $isPresented, onDismiss: {
            storeListVM.getAll()
        }, content: {
            AddStoreView()
        })
        .navigationBarItems(trailing: Button(action: {
            isPresented = true
        }, label: {
            Image(systemName: "plus")
        }))
        .navigationTitle("GroceryApp")
        .embedInNavigationView()
        
        .onAppear(perform: {
            storeListVM.getAll()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
