import FirebaseFirestore

class DatabaseManager {
    private let db = Firestore.firestore()
    
    func addDocument<T: Encodable>(_ data: T, to collection: String) async throws {
        try await db.collection(collection).addDocument(data: try JSONEncoder().encode(data) as! [String : Any])
    }
    
    func getDocuments<T: Decodable>(from collection: String) async throws -> [T] {
        let snapshot = try await db.collection(collection).getDocuments()
        return try snapshot.documents.compactMap { document in
            try document.data(as: T.self)
        }
    }
}
