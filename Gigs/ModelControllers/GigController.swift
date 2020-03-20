//
//  APIController.swift
//  Gigs
//
//  Created by Chris Price on 3/17/20.
//  Copyright © 2020 com.chrispriiice. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum NetworkError: Error {
    case noAuth
    case unauthorized
    case otherError(Error)
    case noData
    case decodeFailed
    case encodeFailed
}

class GigController {
    // MARK: - Public Properties
    var bearer: Bearer?
    var gigs: [Gig] = []
    
    // MARK: - Private Properties
    private let baseUrl = URL(string: "https://lambdagigapi.herokuapp.com/api")!
    
    // MARK: - Public Methods
    
    // Sign-up
    func signUp(with user: User, completion: @escaping (Error?) -> Void) {
        let signUpUrl = baseUrl.appendingPathComponent("users/signup")
        var request = URLRequest(url: signUpUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user object: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            guard error == nil else {
                completion(error)
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    // Sign-in
    func signIn(with user: User, completion: @escaping (Error?) -> Void) {
        let loginUrl = baseUrl.appendingPathComponent("users/login")
        
        var request = URLRequest(url: loginUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user object: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(error)
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            guard let data = data else {
                completion(NSError())
                return
            }
            
            let decoder = JSONDecoder()
            do {
                self.bearer = try decoder.decode(Bearer.self, from: data)
            } catch {
                print("Error decoding bearer object: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    // Fetch gigs
    func fetchGigs(completion: @escaping (Result<[Gig], NetworkError>) -> Void) {
        guard let bearer = bearer else {
            completion(.failure(.noAuth))
            return
        }
        
        let fetchUrl = baseUrl.appendingPathComponent("/gigs/")
        var request = URLRequest(url: fetchUrl)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.unauthorized))
                return
            }
            
            guard error == nil else {
                completion(.failure(.otherError(error!)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let decodedGigs = try decoder.decode([Gig].self, from: data)
                completion(.success(decodedGigs))
            } catch {
                completion(.failure(.decodeFailed))
            }
        }.resume()
    }
    
    // Create gigs
    func createGig(gig: Gig, completion: @escaping (NetworkError?) -> Void) {
        guard let bearer = bearer else {
            completion(.noAuth)
            return
        }
        
        let createGigUrl = baseUrl.appendingPathComponent("/gigs/")
        
        var request = URLRequest(url: createGigUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        do {
            let jsonData = try jsonEncoder.encode(gig)
            request.httpBody = jsonData
        } catch {
            print("Error encoding gig object: \(error)")
            completion(.encodeFailed)
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Error posting gig data: \(error)")
                completion(.otherError(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.unauthorized)
                return
            }
            
            self.gigs.append(gig)
            completion(nil)
        }.resume()
    }
}
