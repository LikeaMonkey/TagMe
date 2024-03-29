//
//  RequestCenter.swift
//  TagMe
//
//  Created by Stanimir Hristov on 6/19/19.
//  Copyright © 2019 Stanimir Hristov. All rights reserved.
//

import Foundation

let URL_BASE = "https://d3028a1e.ngrok.io"

class RequestCenter {
  static let instance = RequestCenter()

  private init() {}

  func postRequest(request: URLRequest, completion: @escaping (Data, URLResponse) -> Void) {
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let data = data, let response = response, error == nil {
        completion(data, response)
      }
    }

    task.resume()
  }

  func registerUser(email: String, password: String, completion: @escaping (Data, URLResponse) -> Void) {
    var request = createRegisterRequest()
    request.httpBody = getJSONData(for: email, and: password)
    postRequest(request: request, completion: completion)
  }

  func loginUser(email: String, password: String, completion: @escaping (Data, URLResponse) -> Void) {
    var request = createLoginRequest()
    request.httpBody = getJSONData(for: email, and: password)
    postRequest(request: request, completion: completion)
  }

  func getImages(for link: String, completion: @escaping (Data, URLResponse) -> Void) {
    let request = createGetRequest(for: link)
    postRequest(request: request, completion: completion)
  }

  func uploadImage(imageData: Data, completion: @escaping (Data, URLResponse) -> Void) {
    let boundary = generateBoundaryString()
    var request = createUploadImageRequest(withBoundary: boundary)
    let body = getUploadRequestBodyWith(imageData: imageData, andBoundary: boundary)
    request.httpBody = body

    // TODO: Make a limit of the uploading image size
    request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")

    postRequest(request: request, completion: completion)
  }
}

//MARK: Request Helpers

extension RequestCenter {
  private func createRequest(for link: String) -> URLRequest {
    let url = URL(string: URL_BASE + link)!
    return URLRequest(url: url)
  }

  private func createPostRequest(for link: String) -> URLRequest {
    var request = createRequest(for: link)
    request.httpMethod = "POST"
    request.AddJSONField()

    return request;
  }

  private func createGetRequest(for link: String) -> URLRequest {
    var request = createRequest(for: link)
    request.httpMethod = "GET"
    request.AddAuthorizationField()

    return request
  }

  private func createUploadImageRequest(withBoundary boundary: String) -> URLRequest {
    var request = createRequest(for: URL_BASE + "/api/pictures")
    request.httpMethod = "POST"
    request.AddMultipartField(boundary: boundary)
    request.AddAuthorizationField()

    return request
  }

  private func getJSONData(for email: String, and password: String) -> Data? {
    let json: [String: Any] = ["email": email, "password": password]
    let jsonData = try? JSONSerialization.data(withJSONObject: json)

    return jsonData;
  }
}

//MARK: Register User Request

extension RequestCenter {
  private func createRegisterRequest() -> URLRequest {
    return createPostRequest(for: "/api/auth/signup")
  }
}

//MARK: Login Request

extension RequestCenter {
  private func createLoginRequest() -> URLRequest {
    return createPostRequest(for: "/api/auth/signin")
  }
}

// MARK: Upload Image

extension RequestCenter {
  private func getUploadRequestBodyWith(imageData: Data, andBoundary boundary: String) -> Data {
    let body = NSMutableData()
    let fname = "image.jpeg"
    let mimetype = "image/jpeg"
    let encoding = String.Encoding.utf8

    body.append("--\(boundary)\r\n".data(using: encoding)!)
    body.append("Content-Disposition:form-data; name=\"file\"\r\n\r\n".data(using: encoding)!)
    body.append("hi\r\n".data(using: encoding)!)
    body.append("--\(boundary)\r\n".data(using: encoding)!)
    body.append(
      "Content-Disposition:form-data; name=\"file\"; filename=\"\(fname)\"\r\n".data(
        using: encoding
      )!
    )
    body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: encoding)!)
    body.append(imageData)
    body.append("\r\n".data(using: encoding)!)
    body.append("--\(boundary)--\r\n".data(using: encoding)!)

    return body as Data
  }
}

// MARK: Boundary Helping Functio

extension RequestCenter {
  private func generateBoundaryString() -> String {
    return "Boundary-\(NSUUID().uuidString)"
  }
}

// MARK: URLRequest Add Field

extension URLRequest {
  mutating func AddJSONField() {
    self.setValue("application/json", forHTTPHeaderField: "Content-Type")
  }

  mutating func AddMultipartField(boundary: String) {
    let multipart = "multipart/form-data; boundary=\(boundary)"
    self.setValue(multipart, forHTTPHeaderField: "Content-Type")
  }

  mutating func AddAuthorizationField() {
    // assert(!JWT.instance.isEmpty)
    let accessToken = "\(JWT.instance.tokenType) \(JWT.instance.accessToken)"
    self.setValue(accessToken, forHTTPHeaderField: "Authorization")
  }
}
