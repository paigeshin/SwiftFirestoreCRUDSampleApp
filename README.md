### Firestore Manager

```swift
//
//  FirestoreManager.swift
//  GroceryApp
//
//  Created by Mohammad Azam on 10/24/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirestoreManager {

    private var db: Firestore

    init() {
        db = Firestore.firestore()
    }


    func deleteStoreItem(storeId: String, storeItemId: String, completion: @escaping (Error?) -> Void) {

        db.collection("stores")
            .document(storeId)
            .collection("items")
            .document(storeItemId)
            .delete { (error) in
                completion(error)
            }
    }

    func getStoreItemsBy(storeId: String, completion: @escaping (Result<[StoreItem]?, Error>) -> Void) {

        db.collection("stores")
            .document(storeId)
            .collection("items")
            .getDocuments { (snapshot, error) in

                if let error = error {
                    completion(.failure(error))
                } else {
                    if let snapshot = snapshot {
                        let items: [StoreItem]? = snapshot.documents.compactMap { doc in

                            var storeItem = try? doc.data(as: StoreItem.self)
                            storeItem?.id = doc.documentID
                            return storeItem
                        }

                        completion(.success(items))
                    }
                }

            }
    }


    func getStoreById(storeId: String, completion: @escaping (Result<Store?, Error>) -> Void) {

        db.collection("stores").document(storeId)
            .collection("items")
            .getDocuments { (snapshot, error) in
                if let snapshot = snapshot {
                    let items = snapshot.documents.compactMap { doc in
                        try? doc.data(as: StoreItem.self)
                    }

                    print(items)
                }
            }

        let ref = db.collection("stores").document(storeId)

        ref.getDocument { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                if let snapshot = snapshot {
                    print(snapshot)

                    var store: Store? = try? snapshot.data(as: Store.self)
                    store?.id = snapshot.documentID
                    completion(.success(store))

                }
            }
        }
    }

    func updateStore(storeId: String, storeItem: StoreItem, completion: @escaping (Result<Store?, Error>) -> Void) {

        do {
            let _ = try db.collection("stores").document(storeId)
                .collection("items").addDocument(from: storeItem)

            self.getStoreById(storeId: storeId) { result in
                switch result {
                case .success(let store):
                    completion(.success(store))
                case .failure(let error):
                    completion(.failure(error))
                }
            }

        } catch let error {
            completion(.failure(error))
        }



    }

    /*
    func updateStore(storeId: String, values: [AnyHashable: Any], completion: @escaping (Result<Store?, Error>) -> Void) {

        let ref = db.collection("stores").document(storeId)

        ref.updateData([
            "items": FieldValue.arrayUnion((values["items"] as? [String]) ?? [])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {

                self.getStoreById(storeId: storeId) { result in
                    switch result {
                    case .success(let store):
                        completion(.success(store))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }

            }
        }

    } */

    func getAllStores(completion: @escaping (Result<[Store]?, Error>) -> Void) {

        db.collection("stores")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    if let snapshot = snapshot {
                        let stores: [Store]? = snapshot.documents.compactMap { doc in

                            var store = try? doc.data(as: Store.self)
                            if store != nil {
                                store!.id = doc.documentID
                            }
                            return store
                        }

                        completion(.success(stores))
                    }
                }
            }

    }

    func save(store: Store, completion: @escaping (Result<Store?, Error>) -> Void) {

        do {
            let ref = try db.collection("stores").addDocument(from: store)
            ref.getDocument { (snapshot, error) in
                guard let snapshot = snapshot, error == nil else {
                    completion(.failure(error!))
                    return
                }

                let store = try? snapshot.data(as: Store.self)
                completion(.success(store))
            }

        } catch let error {
            completion(.failure(error))
        }
    }
}
```

### ViewModels

- Add Store ViewModel

```swift
//
//  AddStoreView.swift
//  GroceryApp
//
//  Created by Mohammad Azam on 10/23/20.
//

import Foundation

class AddStoreViewModel: ObservableObject {

    private var firestoreManager: FirestoreManager
    @Published var saved: Bool = false
    @Published var message: String = ""

    var name: String = ""
    var address: String = ""

    init() {
        firestoreManager = FirestoreManager()
    }

    func save() {

        let store = Store(name: name, address: address)
        firestoreManager.save(store: store) { result in
            switch result {
                case .success(let store):
                    DispatchQueue.main.async {
                        self.saved = store == nil ? false: true
                    }
            case .failure(_):
                    DispatchQueue.main.async {
                        self.message = Constants.Messages.storeSavedFailure
                    }
            }
        }
    }
}
```

- StoreListViewModel

```swift
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
```

- StoreItemListViewModel

```swift
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
```
