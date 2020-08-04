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
    @State private var image: UIImage? = UIImage(asset: Asset.addImage)
    @State private var text: String = ""
    @State var coupon: Coupon
    var id: Int
    var state: CouponEditState
    @State private var alertString: String = ""
    @State private var alertTitle: String = ""
    @State private var showingAlert = false
    @State private var showCaptureImageView = false
    @State private var isShowLoading = false
    @Environment(\.presentationMode) private var presentationMode
    
    init(coupon: Coupon, id: Int, state: CouponEditState) {
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "3dumb", size: 28)!]
        self._coupon = State(initialValue: coupon)
        self.id = id
        self.state = state
    }
    
    var body: some View {
        LoadingView(isShowing: $isShowLoading) {
            ZStack {
                VStack {
                    Image(uiImage: self.image ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(20)
                        .padding(16)
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                            self.showCaptureImageView.toggle()
                        }
                    Spacer()
                    TextView(text: self.$text)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                .onAppear(perform: self.onAppear)
                .alert(isPresented: self.$showingAlert) { () -> Alert in
                    Alert(title: Text(self.alertTitle), message: Text(self.alertString))
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding()
                .navigationBarHidden(false)
                .navigationBarTitle(Text(self.state == .edit ? "\(L10n.Coupon.title) #\(self.id)".uppercased() : L10n.Coupon.add.uppercased()), displayMode: .inline)
                .navigationBarItems(trailing: PrimaryButton(title: self.state == .edit ? L10n.Button.edit : L10n.Button.add, style: .fill, maxWidth: .none) {
                    self.isShowLoading.toggle()
                    self.coupon.description = self.text

                    self.apiManager.updateCoupon(self.coupon, data: self.image != UIImage(asset: Asset.addImage) ? self.image?.jpegData(compressionQuality: 0.5) : nil) { error in
                            self.isShowLoading.toggle()
                            if let error = error?.localizedDescription {
                                self.alertString = error
                                self.showingAlert = true
                            } else {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    })
                .navigationBarBackButtonHidden(false)

                if (self.showCaptureImageView) {
                    CaptureImageView(isShown: self.$showCaptureImageView, image: self.$image)
                    .navigationBarHidden(true)
                }
            }
        }
    }
    
    private func onAppear() {
        text = coupon.description
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
        CouponEditView(coupon: Coupon(description: "Test", image: "https"), id: 1, state: .add)
    }
}
