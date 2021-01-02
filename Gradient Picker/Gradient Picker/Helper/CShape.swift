//
//  CShape.swift
//  Gradient Picker
//
//  Created by 中筋淳朗 on 2020/11/12.
//

import SwiftUI


struct CShape : Shape {
    
    func path(in rect: CGRect) -> Path {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topRight,.bottomLeft], cornerRadii: CGSize(width: 55, height: 55))
        
        return Path(path.cgPath)
    }
}
