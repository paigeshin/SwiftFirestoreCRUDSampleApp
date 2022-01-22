//
//  StoreListViewModel.swift
//  GroceryApp
//
//  Created by Mohammad Azam on 10/25/20.
//

import Foundation

class StoreListViewModel: ObservableObject {
    
    private var firestoreManager: FirestoreManager
    @Published var stores: [StoreViewModel] = []
    
    init() {
        firestoreManager = FirestoreManager()
    }
    
    func getAll() {
        
        firestoreManager.getAllStores { result in
            switch result {
                case .success(let stores):
                    if let stores = stores {
                        DispatchQueue.main.async {
                            self.stores = stores.map(StoreViewModel.init)
                        }
                    }
                
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        
    }
    
}

struct StoreViewModel {
    let store: Store
    
    var storeId: String {
        store.id ?? ""
    }
    
    var name: String {
        store.name
    }
    
    var address: String {
        store.address
    }
    
}

