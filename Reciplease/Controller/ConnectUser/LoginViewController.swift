//
//  SignUpViewController.swift
//  Reciplease
//
//  Created by Greg-Mini on 01/01/2023.
//

import UIKit

class LoginViewController: UIViewController {

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
                                              accessibilityMessage: "the button launches receipt of recipes",
                                              activity: isLogin)
        myButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return myButton
    }()

    lazy var signUpButton: UIButton = {
        var configuration = UIButton.Configuration.tinted()
        let myButton: UIButton = .setupButton(style: configuration,
                                              title: "Sign up",
                                              colorText: .greenColor,
                                              colorBackground: .greenColor,
                                              image: "person.fill.questionmark",
                                              accessibilityMessage: "the button launches receipt of recipes",
                                              activity: isSignUp)
        myButton.addTarget(self, action: #selector(handleGoSignUp), for: .touchUpInside)
        return myButton
    }()

    @objc func handleLogin() {
        self.performSegue(withIdentifier: "LoginSegueTabBar", sender: self)
    }

    @objc func handleGoSignUp() {
        self.performSegue(withIdentifier: "LoginSegueSignUp", sender: self)
    }


        //MARK: - view did load

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        view.backgroundColor = .darkBlue
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

}
