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
    var id: Int
    
    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: ContentMode.fill)
                .frame(width: 130, height: 180)
                .clipped()
            VStack {
                Text("\(L10n.Coupon.title) #\(id)".uppercased())
                    .font(.custom("3dumb", size: 28))
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 56, alignment: .topLeading)
                    .padding(.bottom, 4)
                    .foregroundColor(color)
                Text(coupon.description)
                    .font(.custom("DRAguScript-Book", size: 20))
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 80, alignment: .topLeading)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 8)
        }
        .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 180, alignment: .leading)
        .padding(.trailing, 16)
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(20)
        .shadow(color: .gray, radius: 5)
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
        CouponView(coupon: Coupon(description: "Test", image: "https"), id: 1)
    }
}
