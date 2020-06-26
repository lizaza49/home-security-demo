//
//  ErrorsHandler.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 02/09/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import HomeSecurityAPI

protocol ErrorsHandler {
    func handleError(error: ErrorType) -> ()
}

protocol ErrorAlertConstructor {
    func alert(forError error: ErrorType) -> UIAlertController?
}

protocol ErrorAlertPresenter {
    func presentAlert(alert: UIAlertController) -> ()
}

extension UIViewController: ErrorAlertPresenter {
    func presentAlert(alert: UIAlertController) {
        presentViewController(alert, animated: true, completion: nil)
    }
}

extension ErrorsHandler where Self: protocol<ErrorAlertConstructor, ErrorAlertPresenter> {
    func handleError(error: ErrorType) -> () {
        let alertMaybe = self.alert(forError: error)
        if let alert = alertMaybe {
            self.presentAlert(alert)
        }
    }
}

extension ErrorAlertConstructor {
    func alert(forError error: ErrorType) -> UIAlertController? {
        guard let error = error as? CustomStringConvertible else { return nil }
        let alert = UIAlertController(title: "Error", message: error.description, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        return alert
    }
}

extension Status: CustomStringConvertible {
    public var description: String {
        switch self {
        case Ok:
            return "Ok"
        case NoSession:
            return "Session does not exist"
        case NoAuth:
            return "Not authorized"
        case WrongOrigin:
            return "Wrong origin"
        case WrongSyntax:
            return "Wrong syntax"
        case MissingElement:
            return "Missing element"
        case Fail:
            return "Request failed"
        case ResourceThrottle:
            return "Resourse throttled"
        case WrongSession:
            return "Wrong session"
        case WrongCredentials:
            return "Wrong credentials"
        case AlreadyAuth:
            return "Already authorized"
        case WrongUser:
            return "Wrong user"
        case WrongTag:
            return "Wrong tag"
        case WrongSensor:
            return "Wrong sensor"
        case DuplicateSensor:
            return "Sensor already exists"
        case PoolDepleted:
            return "Pool depleted"
        case AddressMissing:
            return "Adress missing"
        case PhoneLimit:
            return "Phone limit"
        case WrongPhone:
            return "Wrong phone"
        case WrongAnnouncement:
            return "Wrong announcemenet"
        case WrongDialplan:
            return "Wrong dialplan"
        case ConcurrentAccess:
            return "Concurrent access"
        case PhoneForbidden:
            return "Phone forbidden"
        case WrongCode:
            return "Wrong code"
        case AccessDenied:
            return "Access denied"
        case WrongObject:
            return "Wrong object"
        case AlreadyTag:
            return "Already tagged"
        case NoTag:
            return "No tag"
        case DuplicateUsername:
            return "User already exists"
        case UnknownVerification:
            return "Unknown verification"
        case AlreadyExist:
            return "Already exists"
        case MemberNotExists:
            return "Family member does not exist"
        case DuplicatedDeviceID:
            return "This device already registered within family"
        }
    }
}

extension ServiceError: CustomStringConvertible {
    public var description: String {
        switch self {
        case SensorUUIDInvalid:
            return "Sensor UUID invalid (nil)"
        case SensorInvalid:
            return "Sensor invalid (nil) or sensor.sdevice invalid (nil)"
        case SecuredModePermissionsError:
            return "You are not allowed to enable Alert mode"
        case XobjectInvalid:
            return "XObject invalid (nil)"
        case XobjectUUIDInvalid:
            return "XObject UUID invalid (nil)"
        case TagInvalid:
            return "Tag UUID invalid (nil)"
        case NotAllSensorsClosed(let sensors):
            let sensorsDestText = sensors.reduce("", combine: { (part, sensor) in
                guard let desc = sensor.description else { return part }
                return part + desc + "\n"
            })
            let errortext = "Some of your doors/windows are open" + (sensorsDestText.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 ? ":\n" + sensorsDestText : ".")
            return errortext
        case NoSensors:
            return "You don't have any sensors yet"
        case UserTagInvalid:
            return "User tag_all invalid"
        case DuplicatePhone:
            return "Phone already exists"
        case PhoneNotFound:
            return "Phone not found"
        case AuthPartnerMismatch(actial: let actual, expected: let expected):
            return "Your authentification partner mismatches the extected value. (Expected: \"\(expected)\", got: \"\(actual ?? "nil")\")"
        case InternalError(let error):
            print(error)
            return "Something bad happened. Check your internet connection and try again"
        case BadStatus(let status, _):
            return "Server returned: \(status.description)"
        case ImageInvalid:
            return "Invalid image"
        case FamilyMemberInvalid:
            return "Invalid family member"
        case SessionCredentialsInvalid:
            return "Failed to get session ID and server URL"
        case FamilyMemberAlreadyExists:
            return "You've already registered as family member"
        case UserInvalid:
            return "Invalid user"
        }
    }
}

extension ValidationError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Empty(let name):
            return name + " field is empty"
        case .TooShort(let name, let min):
            return name + " field should contain minimum " + String(min) + " symbols"
        case .TooLong(let name, let max):
            return name + " field should contain maximum " + String(max) + " symbols"
        case .CanContainLettersAndNumbersOnly(let name):
            return name + " field should contain only letters or numbers"
        }
    }
}
