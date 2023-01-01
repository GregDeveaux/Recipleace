//
//  APIQueryService.swift
//  Reciplease
//
//  Created by Greg-Mini on 27/12/2022.
//

import UIKit

extension API {
    
    class QueryService {

        static let shared = QueryService()

        let urlSession: URLSession
        init(urlSession: URLSession = URLSession.shared) {
            self.urlSession = urlSession
        }

        private var task: URLSessionDataTask?

        func getData<Response: Decodable>(endpoint: API.EndPoint,
                                          method: API.Method = .GET,
                                          type: Response.Type,
                                          callback: @escaping (Result<Response, API.Error>) -> Void) {

            var request = URLRequest(url: endpoint.url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)

            request.httpMethod = method.rawValue
            print ("✅ QUERY_SERVICE: \(request)")

            task?.cancel()

            task = urlSession.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    guard let data = data, error == nil else {
                        callback(.failure(.generic(reason: "there is not datas!")))
                        return
                    }

                    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                        callback(.failure(.generic(reason: "there is not a response!")))
                        return
                    }

                    print("✅ QUERY_SERVICE: the task received \(String(data: data, encoding: .utf8)!)")

                    let decoder = JSONDecoder()

                    do {
                        let decodeData = try decoder.decode(Response.self, from: data)
                        DispatchQueue.main.async {
                            callback(.success(decodeData))
                        }
                    } catch {
                        print("🛑 Decoding error: \(error)")
                        callback(.failure(.internal(reason: "not decode data!")))
                    }
                }
            }

            task?.resume()
        }
    }

}
