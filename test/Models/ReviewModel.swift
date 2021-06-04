//
//  ProposedMoneyModel.swift
//  test
//
//  Created by Rana Muneeb on 18/11/2020.
//

import Foundation

class ReviewModel {

    var review:String,review_type:String,review_by:String;
    var rating:Double;
    
    init(review:String,type:String,review_by:String,rating:Double) {
        self.review=review;
        self.review_type=type;
        self.review_by=review_by;
        self.rating=rating
    }
}
