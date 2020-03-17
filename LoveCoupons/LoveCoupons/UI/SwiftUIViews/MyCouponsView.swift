//
//  MyCouponsView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 04/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct MyCouponsView: View {
    private let apiManager = APIManager.sharedInstance
    
    @State private var alertString: String = ""
    @State private var alertTitle: String = ""
    @State private var showingAlert = false
    @State private var coupons: [Coupon] = []
    
    var body: some View {
        VStack(alignment: .center, spacing: Constants.stackSpacing) {
            HStack {
                Text(L10n.MyCoupons.title)
                    .font(.title)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 64, alignment: .leading)
                Spacer()
                PrimaryButton(title: L10n.Button.add, style: .fill, maxWidth: .none) {
                        
                }
            }
            .padding()
            
            List(coupons) { coupon in
                CouponView(coupon: coupon)
            }
        }
        .alert(isPresented: $showingAlert) { () -> Alert in
            Alert(title: Text(alertTitle), message: Text(alertString))
        }
        .onAppear(perform: setList)
    }
            
    private func setList() {
        apiManager.getMyCoupons { coupons, error in
            if let error = error?.localizedDescription {
                self.alertString = error
                self.showingAlert = true
            } else if let coupons = coupons {
                self.coupons = coupons.sorted { coupon1, coupon2 -> Bool in
                    coupon1.description ?? "" < coupon2.description ?? ""
                }
            }
        }
    }
}

struct MyCouponsView_Previews: PreviewProvider {
    static var previews: some View {
        MyCouponsView()
    }
}
