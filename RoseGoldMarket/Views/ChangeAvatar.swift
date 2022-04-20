//
//  ChangeAvatar.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/2/22.
//
import SwiftUI

struct ChangeAvatar: View {
    @EnvironmentObject var user:UserModel
    @Environment(\.presentationMode) var presentation
    @State var userImage:UIImage? = nil
    @State var isShowingPhotoPicker = false
    @State var imageEnum: PlantOptions = .imageOne
    @State var dataPosted = false
    @State var problemOccurred = false
    var body: some View {
        VStack {
            Text("Tap To Upload A New Picture")
                .padding()
                .onAppear() {
                    getAvatarImage()
                }
            if userImage != nil {
                Image(uiImage: userImage!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .padding()
                    .onTapGesture {
                        isShowingPhotoPicker = true
                    }
                    .alert(isPresented: $problemOccurred) {
                        Alert(title: Text("Problem Occurred"), message:Text("There was a problem on our end. Try again later."), dismissButton: .destructive(Text("OK!")))
                    }
            } else {
                ProgressView()
            }
            Text(user.username).font(.title).padding()
            
            Button("Submit") {
                saveImage()
            }
            .padding()
            .alert(isPresented: $dataPosted) {
                Alert(title: Text("Avatar Updated!"), dismissButton: .destructive(Text("OK!"), action: { self.presentation.wrappedValue.dismiss() }))
            }
            Spacer()
        }.sheet(isPresented: $isShowingPhotoPicker, content: {
            PhotoPicker(plantImage: $userImage, plantImage2: Binding.constant(nil), plantImage3: Binding.constant(nil), plantEnum: $imageEnum)
        })
    }
}

extension ChangeAvatar {
    func getAvatarImage() {
        do {
            let avatarUrl = URL(string: "https://rosegoldgardens.com/api/images/avatars/\(user.username).jpg")!
            let avatarPicData = try Data(contentsOf: avatarUrl)
            self.userImage = UIImage(data: avatarPicData)
        } catch let error {
            DispatchQueue.main.async {
                print(error)
                self.problemOccurred = true
            }
        }
    }
    
    func saveImage() {
        guard let img = userImage, let imgData = img.jpegData(compressionQuality: 0.5) else {
            DispatchQueue.main.async {
                self.problemOccurred = true
            }
            return
        }
        UserNetworking.shared.changeAvatar(imgJpgData: imgData, username: user.username, token: user.accessToken) { serverRes in
            switch serverRes {
            case .success(let data):
                DispatchQueue.main.async {
                    if data.newToken != nil {
                        self.user.accessToken = data.newToken!
                    }
                    if data.data {
                        self.dataPosted = true
                    }
                }
            case .failure(let fail):
                DispatchQueue.main.async {
                    if fail == .tokenExpired {
                        self.user.logout()
                    }
                    self.problemOccurred = true
                    print(fail)
                }
            }
        }
    }
}

struct ChangeAvatar_Previews: PreviewProvider {
    static var previews: some View {
        ChangeAvatar()
            .environmentObject(UserModel.shared)
    }
}
