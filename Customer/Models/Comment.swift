//
//  Comment.swift
//  SuggestBusStation
//
//  Created by Macbook Pro on 04/10/2023.
//

import Foundation

struct Comment : Codable{
    //var id: String?
    var suggestion: String
    var date: String
    var rating: Int
    init( suggestion: String, date: String, rating: Int) {
       
        self.suggestion = suggestion
        self.date = date
        self.rating = rating
    }
}

struct returnComment : Codable {
    // test trường hợp return comments[0].suggestion, comments[0].date, comments[0].rating
    // ở chỗ response của server thành công
    // -> muốn trả về nhiều thì chỗ returnComment này có lẽ sẽ làm 1 mảng Comment
    // var comments: Comment[]
}
