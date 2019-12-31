//
//  PhotoResponse.swift
//  Virtual Tourist
//
//  Created by بشاير الخليفه on 14/04/1441 AH.
//  Copyright © 1441 -. All rights reserved.
//

import Foundation

struct PhotoResponse: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}
struct PhotosResponse: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [PhotoResponse]
}

struct Response: Codable {
    let photos: PhotosResponse
}
