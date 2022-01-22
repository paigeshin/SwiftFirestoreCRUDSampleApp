//
//  StoreItemListViewModel.swift
//  GroceryApp
//
//  Created by Mohammad Azam on 10/26/20.
//

import Foundation

struct StoreItemViewState {
    var name: String = ""
    var price: String = ""
    var quantity: String = ""
}

struct StoreItemViewModel {
    
    let storeItem: StoreItem
    
    var storeItemId: String {
        storeItem.id ?? "" 
    }
    
    var name: String {
        storeItem.name
    }
}

class StoreItemListViewModel: ObservableObject {
    
    private var firestoreManager: FirestoreManager
    var storeItemName: String = ""
    @Published var storeItems: [StoreItemViewModel] = []
    
    //var storeItemVS = StoreItemViewState()
    
    init() {
        firestoreManager = FirestoreManager()
    }
    
    func deleteStoreItem(storeId: String, storeItemId: String) {
        firestoreManager.deleteStoreItem(storeId: storeId, storeItemId: storeItemId) { error in
            // get the store items
            self.getStoreItemsBy(storeId: storeId)
        }
    }
    
    func getStoreItemsBy(storeId: String) {
        firestoreManager.getStoreItemsBy(storeId: storeId) { result in
            switch result {
                case .success(let items):
                    if let items = items {
                        self.storeItems = items.map(StoreItemViewModel.init)
                    }
                case .failure(_):
                    print("error")
            }
        }
    }
        
    func addItemToStore(storeId: String, storeItemVS: StoreItemViewState, completion: @escaping (Error?) -> Void) {
        let storeItemModel = StoreItem.from(storeItemVS)
        firestoreManager.updateStore(storeId: storeId, storeItem: storeItemModel) { result in
            switch result {
                case .success(_):
                    completion(nil)
                case .failure(let error):
                    completion(error)
            }
        }
    }
    
}
