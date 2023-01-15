//
//  SignUpViewController.swift
//  Reciplease
//
//  Created by Greg Deveaux on 29/12/2022.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    //MARK: - properties

    lazy var logoReciplease: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Fridge")
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = .image
        imageView.accessibilityHint = "Welcome to ReciPlease, this app offers you recipes with stuffs from the fridge"
        return imageView
    }()

    lazy var emaiTextField: UITextField = .setupTextFields(placeholder: "Email",
                                                           isSecure: false,
                                                           accessibilityMessage: "write here your email address")

    lazy var usernameTextField: UITextField = .setupTextFields(placeholder: "Username",
                                                           isSecure: false,
                                                           accessibilityMessage: "write here your username")

    lazy var passwordTextField: UITextField = .setupTextFields(placeholder: "Password",
                                                               isSecure: true,
                                                               accessibilityMessage: "write here your password")
    private var isSignUp = false {
        didSet {
            signUpButton.setNeedsUpdateConfiguration()
        }
    }

    lazy var signUpButton: UIButton = {
        let myButton: UIButton = .setupButton(style: UIButton.Configuration.filled(),
                                              title: "Sign up",
                                              colorText: .white,
                                              colorBackground: .simpleRGB(red: 89, green: 146, blue: 98),
                                              image: "person.fill.questionmark",
                                              accessibilityMessage: "the button launches receipt of recipes",
                                              activity: isSignUp)
        myButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return myButton
    }()

        //MARK: Database Firebase
    let refDatabase: DatabaseReference = Database.database().reference()
    let authentification: Auth = .auth()

    @objc func handleSignUp() {
        guard let email = emaiTextField.text?.lowercased(), !email.isEmpty else {
            presentAlert(with: "Oh no! you just forget\n to write your email")
            return
        }
        guard let username = usernameTextField.text, !username.isEmpty else {
            presentAlert(with: "Oh no! you just forget\n to write your username")
            return
        }
        guard let password = passwordTextField.text, password.count >= 6 else {
            presentAlert(with: "Oh no! you just forget\n to write your password\n or the password not contains\n 6 min characters")
            return
        }

        authentification.createUser(withEmail: email, password: password) { user, error in
            guard let user = user, error == nil else {
                if let error = error {
                    print("🛑 LOGIN_VC/FIREBASE_AUTH: Failed to create login, \(error)")
                }
                return
            }

            let userUid = user.user.uid
            print("✅ LOGIN_VC/FIREBASE_AUTH: The user has been create: \(userUid)")

            let target = "users/\(userUid)/username"
            let usernameReference = self.refDatabase.child(target)

            usernameReference.setValue(username) { error, reference in
                if let error = error {
                    print("🛑 LOGIN_VC/FIREBASE_DATABASE: Failed to save data of user, \(error)")
                    return
                }
                print("✅ LOGIN_VC/FIREBASE_DATABASE: Save the user datas has been success")
            }

            self.performSegue(withIdentifier: "SignUpSegueTabBar", sender: self)
            print("✅ LOGIN_VC/FIREBASE_AUTH: \(self.usernameTextField.text ?? "Nothing") has logged")
        }
    }


        //MARK: - view did load

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        view.backgroundColor = UIColor.simpleRGB(red: 54, green: 51, blue: 50)
        setupLogo()
        setupTextFieldsStackView()
    }

    private func setupLogo() {
        view.addSubview(logoReciplease)
        logoReciplease.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        logoReciplease.heightAnchor.constraint(equalToConstant: 140).isActive = true
        logoReciplease.widthAnchor.constraint(equalToConstant: 140).isActive = true
        logoReciplease.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    private func setupTextFieldsStackView() {
        let stackView = UIStackView(arrangedSubviews: [emaiTextField, usernameTextField, passwordTextField, signUpButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: logoReciplease.bottomAnchor, constant: 20),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            stackView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}
