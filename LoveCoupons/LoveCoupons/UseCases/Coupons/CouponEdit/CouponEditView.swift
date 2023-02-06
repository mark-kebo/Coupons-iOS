//
//  CouponEditView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 23/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct CouponEditView<ViewModel>: View where ViewModel: CouponEditViewModelProtocol {
    @State private var color: Color = Color(Constants.redColor)
    
    @ObservedObject private var viewModel: ViewModel
    @ObservedObject private var imageStore = CouponEditImageStore()

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        LoadingView(isShowing: $viewModel.isShowLoading) {
            ZStack {
                VStack {
                    Image(uiImage: imageStore.image ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(20)
                        .padding(16)
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                            viewModel.changeImageButtonSelected(image: $imageStore.image)
                        }
                    Spacer()
                    TextView(text: self.$viewModel.text)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                .onAppear(perform: self.onAppear)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding()
                .navigationBarTitle(Text(""),displayMode: .inline)
                .navigationBarItems(leading: Text(viewModel.state == .edit ?
                                                  "\(L10n.Coupon.title) #\(viewModel.id)".uppercased() :
                                                     L10n.Coupon.add.uppercased()).font(.custom(Constants.titleFont, size: 28)),
                                    trailing: PrimaryButton(title: viewModel.state == .edit ? L10n.Button.edit : L10n.Button.add, style: .fill, maxWidth: .none) {
                    viewModel.sendButtonPressed(image: imageStore.image)
                })
            }
        }
    }
    
    private func onAppear() {
        viewModel.updateImage(imageStore: imageStore)
    }
}

struct CouponEditView_Previews: PreviewProvider {
    static var previews: some View {
        CouponEditView(viewModel: CouponEditViewModel(coordinator: CouponEditCoordinator(rootNavigationController: nil,
                                                                                         tabNavigationController: nil,
                                                                                         coupon: Coupon(description: "Test", image: "https"),
                                                                                         id: 1,
                                                                                         state: .add)))
    }
}
