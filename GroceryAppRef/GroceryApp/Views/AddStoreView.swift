//
//  AddStoreView.swift
//  GroceryApp
//
//  Created by Mohammad Azam on 10/23/20.
//

import SwiftUI

struct AddStoreView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var addStoreVM = AddStoreViewModel()
    
    var body: some View {
        Form {
            Section {
                
                TextField("Name", text: $addStoreVM.name)
                TextField("Address", text: $addStoreVM.address)
                HStack {
                    Spacer()
                    Button("Save") {
                        addStoreVM.save()
                    }.onChange(of: addStoreVM.saved, perform: { saved in
                        if saved {
                            // dismiss the presentation model
                            presentationMode.wrappedValue.dismiss()
                        }
                    })
                    
                    Spacer()
                }
                
                Text(addStoreVM.message)
            }
        }
        .navigationBarItems(leading: Button(action: {
            // close the modal
            presentationMode.wrappedValue.dismiss()
            
        }, label: {
            Image(systemName: "xmark")
        }))
        .navigationTitle("Add New Store")
        .embedInNavigationView()
    }
}

struct AddStoreView_Previews: PreviewProvider {
    static var previews: some View {
        AddStoreView()
    }
}
