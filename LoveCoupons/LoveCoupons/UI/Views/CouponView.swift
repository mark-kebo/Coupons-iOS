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
                .scaledToFit()
                .cornerRadius(20)
                .frame(height: 150)
            Spacer()
            VStack {
                Text("\(L10n.Coupon.title) #\(id)")
                    .font(.title)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 64, alignment: .trailing)
                Text(coupon.description ?? "")
                    .font(.subheadline).italic()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 64, alignment: .trailing)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 150, alignment: .leading)
        .padding()
        .background(Color(UIColor.systemBackground))
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
