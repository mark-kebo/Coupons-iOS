//
//  CouponEditView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 23/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

enum CouponEditState {
    case edit
    case add
}

struct CouponEditView: View {
    private let apiManager = APIManager.sharedInstance
    @State private var color: Color = Color("AppRed")
    @State private var image: UIImage = UIImage(asset: Asset.addImage)
    @State private var text: String = ""

    var coupon: Coupon
    var id: Int
    var state: CouponEditState

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(20)
                .padding(16)
            Spacer()
            TextView(text: $text)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding()
        .onAppear(perform: onAppear)
        .navigationBarTitle(Text(state == .edit ? "\(L10n.Coupon.title) #\(id)" : L10n.Coupon.add).font(.title), displayMode: .inline)
        .navigationBarItems(trailing: PrimaryButton(title: state == .edit ? L10n.Button.edit : L10n.Button.add, style: .fill, maxWidth: .none) {

        })
    }
    
    private func onAppear() {
        text = coupon.description ?? ""
        apiManager.getImage(by: coupon.image) { (image, error) in
            if error != nil {
                self.image = UIImage(asset: Asset.addImage)
            } else if let image = image {
                self.image = image
            }
        }
    }
}

struct CouponEditView_Previews: PreviewProvider {
    static var previews: some View {
        CouponEditView(coupon: Coupon(description: "Test", image: "https"), id: 1, state: .edit)
    }
}
