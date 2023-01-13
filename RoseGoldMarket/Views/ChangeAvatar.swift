//
//  ChangeAvatar.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/2/22.
//
import SwiftUI

struct ChangeAvatar: View {
    @EnvironmentObject var user:UserModel
    @Environment(\.dismiss) private var dismiss
    @State var userImage:UIImage? = nil
    @State var isShowingPhotoPicker = false
    @State var useCamera = false
    @State var imageEnum: PlantOptions = .imageOne
    @State var dataPosted = false
    @State var problemOccurred = false
    @State var loading = true
    
    var body: some View {
        VStack {
            if loading {
                ProgressView()
                    .foregroundColor(.blue)
                    .onAppear() { getAvatarImage() }
            } else {
                Menu {
                    Button("Take Photo") {
                        useCamera = true
                        isShowingPhotoPicker.toggle()
                    }
                    Button("Choose From Library") {
                        useCamera = false
                        isShowingPhotoPicker.toggle()
                    }
                }
                label: {
                    ZStack {
                        Circle()
                            .frame(width: 200, height: 200)
                            .foregroundColor(Color(.systemGray6))
                            .shadow(radius: 25)
                        
                        if userImage != nil {
                            Image(uiImage: userImage!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 190, height: 190)
                                .clipShape(Circle())
                                .padding()
                                .alert(isPresented: $problemOccurred) {
                                    Alert(title: Text("Problem Occurred"), message:Text("There was a problem on our end. Try again later."), dismissButton: .destructive(Text("OK!")))
                                }
                        } else {
                            Circle()
                                .frame(width: 190, height: 190)
                                .foregroundColor(Color(.systemGray6))
                                .padding()
                                .shadow(radius: 25)
                        }
                    }
                }  
                
                Text(user.username).font(.title).padding()
                
                Button("Submit") {
                    saveImage()
                }
                .padding()
                .alert(isPresented: $dataPosted) {
                    Alert(title: Text("Avatar Updated!"), dismissButton: .destructive(Text("OK!"), action: { dismiss() }))
                }
                Spacer()
            }
        }.sheet(isPresented: $isShowingPhotoPicker) {
            if useCamera {
                CameraAccessor(selectedImage: $userImage)
            } else {
                ImageSelector(image: $userImage, canSelectMultipleImages: false, images: Binding.constant([]))
            }
        }
    }
}

extension ChangeAvatar {
    func getAvatarImage() {
        if let url = URL(string: "https://rosegoldgardens.com/api/images/avatars/\(user.username).jpg") {
            // had to load image this way to prevent the image from stalling the main thread while it loads
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                guard err == nil
                else {
                    print("problem fetching image from server")
                    problemOccurred = true
                    return
                }
                
                guard let imageData = data
                else {
                    print("problem decoding the image")
                    problemOccurred = true
                    return
                }
                
                DispatchQueue.main.async {
                    self.loading = false
                    self.userImage = UIImage(data: imageData)
                }
            }.resume()
        } else {
            print("couldn't get the url")
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
