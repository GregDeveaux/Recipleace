//
//  SignUpViewController.swift
//  Reciplease
//
//  Created by Greg-Mini on 01/01/2023.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

        // -------------------------------------------------------
        // MARK: - database Firebase
        // -------------------------------------------------------

    let referenceDatabase: DatabaseReference = Database.database().reference()
    let authentification: Auth = .auth()
    

        // -------------------------------------------------------
        // MARK: - properties
        // -------------------------------------------------------
        // logo top
    lazy var logoReciplease: UIImageView = setupImage(named: "logoRecipleaseText",
                                                      accessibilityText: "Welcome to ReciPlease, this app offers you recipes with stuffs from the fridge")
        // dish picture bottom
    lazy var dishLogin: UIImageView = setupImage(named: "DishLogin",
                                                 accessibilityText: "This page present dish of mushrooms and broccoli")

    lazy var emailTextField: UITextField = .setupTextFields(placeholder: "Email",
                                                               isSecure: false,
                                                               accessibilityMessage: "write here your email address")

    lazy var passwordTextField: UITextField = .setupTextFields(placeholder: "Password",
                                                               isSecure: true,
                                                               accessibilityMessage: "Write your password here")

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
                print("✅ User is log in")
            }, for: .touchUpInside)
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
        myButton.addAction(
            UIAction { _ in
                self.handleGoSignUp()
                print("✅ User go sign up")
            }, for: .touchUpInside)
        return myButton
    }()

        // used to action activity indicator is button
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


        // -------------------------------------------------------
        //MARK: - actions
        // -------------------------------------------------------

    func handleLogin() {
        guard let email = emailTextField.text?.lowercased(), !email.isEmpty else {
            presentAlert(with: "Oh no! you just forget\n to write your email")
            return
        }
        guard let password = passwordTextField.text, password.count >= 6 else {
            presentAlert(with: "Oh no! you just forget\n to write your password\n or the password not contains\n 6 min characters")
            return
        }

        authentification.signIn(withEmail: email, password: password) { [weak self] user, error in
            guard let strongSelf = self else { return }
            if let error = error, user == nil {
                strongSelf.presentAlert(with: "Sign In failed: \(error.localizedDescription)")
            }
            strongSelf.performSegue(withIdentifier: "LoginSegueTabBar", sender: self)
        }
    }

    func handleGoSignUp() {
        self.performSegue(withIdentifier: "LoginSegueSignUp", sender: self)
    }

        // -------------------------------------------------------
        //MARK: - cycle of view
        // -------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    @IBAction func unwindToLogin(segue:UIStoryboardSegue) { }

        // -------------------------------------------------------
        //MARK: - design
        // -------------------------------------------------------
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
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, signUpButton])
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

        /// A method to create image
        /// - Parameters:
        ///   - named: name of image used
        ///   - accessibilityText: description text for VoiceOver
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
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
}
