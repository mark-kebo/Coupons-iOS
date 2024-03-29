//
//  CouponView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 17/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI
import Combine

struct CouponView: View {
    @State private var image: UIImage = UIImage(asset: Asset.logo)
    @State private var isShowingImagesLoading: Bool = false
    @State private var color: Color = Color(Constants.redColor)
    @State private var cancellable: AnyCancellable?

    private let imageSize: CGSize = CGSize(width: 130, height: 180)
    var coupon: Coupon
    var id: Int
    @State var isShowingLoading: Bool = false

    var body: some View {
        HStack {
            if isShowingImagesLoading && image == UIImage(asset: Asset.logo) {
                ActivityIndicator(isAnimating: $isShowingImagesLoading, style: .large)
                    .frame(width: imageSize.width, height: imageSize.height)
                    .clipped()
            } else {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fill)
                    .frame(width: imageSize.width, height: imageSize.height)
                    .clipped()
            }
            VStack {
                Text("\(L10n.Coupon.title) #\(id)".uppercased())
                    .font(.custom(Constants.titleFont, size: 28))
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 56, alignment: .topLeading)
                    .padding(.bottom, 4)
                    .foregroundColor(color)
                Text(coupon.description)
                    .font(.custom(Constants.textFont, size: 20))
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 80, alignment: .topLeading)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 8)
        }
        .frame(minWidth: 0, maxWidth: .infinity, maxHeight: imageSize.height, alignment: .leading)
        .padding(.trailing, 16)
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(20)
        .shadow(color: .gray, radius: 5)
        .onAppear(perform: setImage)
        .redacted(reason: isShowingLoading ? .placeholder : [])
        .allowsHitTesting(!isShowingLoading)
    }
    
    private func setImage() {
        isShowingImagesLoading = true
        cancellable = MediaLoadingService.shared.getMediaData(coupon.image)
            .sink(receiveValue: { image in
                self.image = image ?? UIImage(asset: Asset.logo)
                isShowingImagesLoading = false
            })
    }
}

struct CouponView_Previews: PreviewProvider {
    static var previews: some View {
        CouponView(coupon: Coupon(description: "Test", image: "https"), id: 1)
    }
}
