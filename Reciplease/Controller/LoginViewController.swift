//
//  LoginViewController.swift
//  Reciplease
//
//  Created by Greg Deveaux on 29/12/2022.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    //MARK: - properties

    lazy var plusPhotoButton: UIButton = {
        let photoButton = UIButton(type: .system)
        photoButton.translatesAutoresizingMaskIntoConstraints = false
        photoButton.backgroundColor = .white
        photoButton.layer.cornerRadius = 70
        photoButton.titleLabel?.font = .systemFont(ofSize: 55)
        photoButton.setTitle("+", for: .normal)
        photoButton.setTitleColor(.simpleRGB(red: 89, green: 146, blue: 98), for: .normal)
        return photoButton
    }()

    lazy var emaiTextField: UITextField = {
        setupTextFields(placeholder: "Email", isSecure: false)
    }()

    lazy var userTextField: UITextField = {
        setupTextFields(placeholder: "Username", isSecure: false)
    }()

    lazy var passwordTextField: UITextField = {
        setupTextFields(placeholder: "Password", isSecure: true)
    }()

    lazy var loginButton: UIButton = {
        let loginButton = UIButton(type: .system)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.backgroundColor = .simpleRGB(red: 89, green: 146, blue: 98)
        loginButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 5

        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return loginButton
    }()

    @objc func handleLogin() {
        guard let email = emaiTextField.text?.lowercased(), !email.isEmpty else {
            presentAlert(with: "Oh no! you just forget\n to write your email")
            return
        }
        guard let username = userTextField.text, !username.isEmpty else {
            presentAlert(with: "Oh no! you just forget\n to write your username")
            return
        }
        guard let password = passwordTextField.text, password.count >= 6 else {
            presentAlert(with: "Oh no! you just forget\n to write your password\n or the password not contains\n 6 min characters")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            guard let user = user, error == nil else {
                if let error = error {
                    print("🛑 LOGIN_VC/FIREBASE: Failed to create login, \(error)")
                }
                return
            }

            let userId = user.user.uid
            print("✅ LOGIN_VC/FIREBASE: The user has been create: \(userId)")
            let values = [userId: 1]

            Database.database().reference().child("users").setValue(values) { error, reference in
                if let error = error {
                    print("🛑 LOGIN_VC/FIREBASE: Failed to save data of user, \(error)")
                }
                print("✅ LOGIN_VC/FIREBASE: Save the user datas has been success")
            }
        }

        print("✅ LOGIN_VC: \(userTextField.text ?? "Nothing") has logged")
    }

        //MARK: - view did load

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupButtonPhoto()
        setupTextFieldsStackView()
    }

    private func setupView() {
        view.backgroundColor = UIColor.simpleRGB(red: 54, green: 51, blue: 50)
    }

    private func setupButtonPhoto() {
        view.addSubview(plusPhotoButton)
        plusPhotoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        plusPhotoButton.heightAnchor.constraint(equalToConstant: 140).isActive = true
        plusPhotoButton.widthAnchor.constraint(equalToConstant: 140).isActive = true
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    private func setupTextFieldsStackView() {
        let stackView = UIStackView(arrangedSubviews: [emaiTextField, userTextField, passwordTextField, loginButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: plusPhotoButton.bottomAnchor, constant: 20),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            stackView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func setupTextFields(placeholder: String, isSecure: Bool) -> UITextField {
        let myTextField = UITextField()
        myTextField.translatesAutoresizingMaskIntoConstraints = false
        myTextField.placeholder = placeholder
        myTextField.backgroundColor = .white
        myTextField.borderStyle = .roundedRect
        myTextField.font = .systemFont(ofSize: 14)
        if isSecure {
            myTextField.isSecureTextEntry = true
        }
        return myTextField
    }


}
