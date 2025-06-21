import Foundation
import GoogleSignIn
import SafariServices

struct GoogleAuthService {
    static func sendTokenToBackend(idToken: String, completion: @escaping (Result<User, Error>) -> Void) {
        // server endpoint
        guard let url = URL(string: "http://192.168.0.103:5050/api/auth/login") else { return }

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
    
    
    static func handleLogout(userSession: UserSession) {
        // logging user out from their account on device
        GIDSignIn.sharedInstance.signOut()
        
        // check the endpoint and assign it url
        guard let url = URL(string: "http://192.168.0.103:5050/api/auth/logout") else {
            print("Invalid URL")
            return
        }
        
        // GET request to backend preparation
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            if let error = error {
                print("Network error: \(error)")
            }
            
            // parse response from server
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let logoutURLString = json["logout_url"] as? String,
               let logoutURL = URL(string: logoutURLString) {
                
                // clearing info about user session
                DispatchQueue.main.async {
                    UIApplication.shared.open(logoutURL)
                    userSession.user = nil
                    userSession.isLoggedIn = false
                }
            } else {
                DispatchQueue.main.async {
                    userSession.user = nil
                    userSession.isLoggedIn = false
                }
            }
        }.resume()
    }
}
