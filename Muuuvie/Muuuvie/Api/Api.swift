//
//  Placeholder.swift
//  Muuuvie
//
//  Created by Emilio Heinzmann on 29/10/20.
//

import Foundation

typealias RequestCallback<T> = (Result<T, APIError>) -> Void

struct Api {
    static let instance = Api()
        
    let baseUrl: String = "https://api.themoviedb.org/3/"
    let apiKey: String = "37186ddc43254f76799f9204ff25251c"
    
    private init() {}
    
    func request<T: Decodable>(with endpoint: Endpoint, completion: @escaping RequestCallback<T>) {
        let fullUrlString = "\(baseUrl)\(endpoint.url)?api_key=\(apiKey)"
        
        guard let fullUrl = URL(string: fullUrlString) else {
            completion(.failure(.malformedURL))
            return
        }
        
        URLSession.shared.dataTask(with: fullUrl) { result in
            switch result {
            case .success(let (response, data)):
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                do {
                    let values = try decoder.decode(T.self, from: data)
                    completion(.success(values))
                } catch {
                    completion(.failure(.decodeError))
                }
            case .failure(_):
                completion(.failure(.apiError))
            }
        }.resume()
    }
}

