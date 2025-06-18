import Foundation

struct GoogleSignIn {
    static func sendTokenToBackend(idToken: String, completion: @escaping (Result<User, Error>) -> Void) {
        // server endpoint
        guard let url = URL(string: "http://127.0.0.1:5000/api/auth/login") else { return }

        // JSON POST request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // packs the data in JSON format to send
        let body: [String: Any] = ["id_token": idToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        // sends request to server
        URLSession.shared.dataTask(with: request) { data, response, error in
            // handles errors
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -2)))
                return
            }

            do {
                let json = try JSONDecoder().decode(User.self, from: data)
                // create a current user profile
                completion(.success(json))
            } catch {
                completion(.failure(error))
            }
            
        }.resume()
    }
    
    static func handleLogOut(){}
}
