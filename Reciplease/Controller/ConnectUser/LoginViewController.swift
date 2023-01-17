//
//  SignUpViewController.swift
//  Reciplease
//
//  Created by Greg-Mini on 01/01/2023.
//

import UIKit

class LoginViewController: UIViewController {

        //MARK: - properties

    lazy var logoReciplease: UIImageView = setupImage(named: "logoRecipleaseText",
                                                      accessibilityText: "Welcome to ReciPlease, this app offers you recipes with stuffs from the fridge")

    lazy var dishLogin: UIImageView = setupImage(named: "DishLogin",
                                                 accessibilityText: "This page present dish of mushrooms and broccoli")

    lazy var usernameTextField: UITextField = .setupTextFields(placeholder: "Username",
                                                               isSecure: false,
                                                               accessibilityMessage: "Write your username here")

    lazy var passwordTextField: UITextField = .setupTextFields(placeholder: "Password",
                                                               isSecure: true,
                                                               accessibilityMessage: "Write your password here")

    private var isLogin = false {
        didSet {
            loginButton.setNeedsUpdateConfiguration()
        }
    }
    private var isSignUp = false {
        didSet {
            signUpButton.setNeedsUpdateConfiguration()
        }
    }
    lazy var loginButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        let myButton: UIButton = .setupButton(style: configuration,
                                              title: "Log in",
                                              colorText: .darkBlue,
                                              colorBackground: .greenColor,
                                              image: "person.fill.checkmark",
                                              accessibilityMessage: "used the button to log into existing account",
                                              activity: isLogin)

        myButton.addAction(
            UIAction { _ in
                self.handleLogin()
            }, for: .touchUpInside)
//        myButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return myButton
    }()

    lazy var signUpButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        let myButton: UIButton = .setupButton(style: configuration,
                                              title: "Sign up",
                                              colorText: .greenColor,
                                              colorBackground: .darkGreen,
                                              image: "person.fill.questionmark",
                                              accessibilityMessage: "used the button to register your account",
                                              activity: isSignUp)
        myButton.addTarget(self, action: #selector(handleGoSignUp), for: .touchUpInside)
        return myButton
    }()

    func handleLogin() {
        self.performSegue(withIdentifier: "LoginSegueTabBar", sender: self)
    }

    @objc func handleGoSignUp() {
        self.performSegue(withIdentifier: "LoginSegueSignUp", sender: self)
    }


        //MARK: - cycle of view

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }


        //MARK: - design
        // background color
    private func setupView() {
        view.backgroundColor = .darkBlue
        setupLogo()
        setupDish()
        setupTextFieldsStackView()
    }
        // logo of the top
    private func setupLogo() {
        view.addSubview(logoReciplease)
        logoReciplease.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        logoReciplease.heightAnchor.constraint(equalToConstant: 100).isActive = true
        logoReciplease.widthAnchor.constraint(equalToConstant: 300).isActive = true
        logoReciplease.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

        // text fields of the middle
    private func setupTextFieldsStackView() {
        let stackView = UIStackView(arrangedSubviews: [usernameTextField, passwordTextField, loginButton, signUpButton])
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
        // dish of the bottom
    private func setupDish() {
        view.addSubview(dishLogin)
        dishLogin.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 20).isActive = true
        dishLogin.heightAnchor.constraint(equalToConstant: 400).isActive = true
        dishLogin.widthAnchor.constraint(equalToConstant: 400).isActive = true
        dishLogin.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    private func setupImage(named: String, accessibilityText: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: named)
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = .image
        imageView.accessibilityHint = accessibilityText
        return imageView
    }
}

    // -------------------------------------------------------
    // MARK: Keyboard setup dismiss
    // -------------------------------------------------------

extension LoginViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
}
