//
//  CouponView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 17/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct CouponView: View {
    private let apiManager = APIManager.sharedInstance
    @State private var image: UIImage = UIImage(asset: Asset.spinner)
    @State private var color: Color = Color("AppRed")

    var coupon: Coupon
    
    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(20)
                .frame(height: 150)
            Spacer()
            Text(coupon.description ?? "")
                .font(.subheadline).italic()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 64, alignment: .trailing)
        }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 150, alignment: .leading)
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)
            .onAppear(perform: setImage)
    }
    
    private func setImage() {
        apiManager.getImage(by: coupon.image) { (image, error) in
            if error != nil {
                self.image = UIImage(asset: Asset.logo)
            } else if let image = image {
                self.image = image
            }
        }
    }
}

struct CouponView_Previews: PreviewProvider {
    static var previews: some View {
        CouponView(coupon: Coupon(description: "Test Test Test Test  Test Test Test Test", image: "https://firebasestorage.googleapis.com/v0/b/coupons-love.appspot.com/o/img%2Fc5edae4e-c68e-4582-b44a-b8a87c5f5eb1.jpg?alt=media&token=1a54d913-f41b-429e-b23a-2d7e8b37672f"))
    }
}
