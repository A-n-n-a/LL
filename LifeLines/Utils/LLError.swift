//
//  LLError.swift
//  LifeLines
//
//  Created by Anna on 7/6/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation

enum ErrorType {
    enum Validation: String {
        case validationNumberIncorrect = "validate_number_incorrect"
        case validationEmailIncorrect = "validate_email_incorrect"
        case validationPasswordTooShort = "validate_password_too_short"
        case validationPasswordTooLong = "validate_password_too_long"
        case validationPasswordShouldContainDigits = "validate_password_should_contain_digits"
        case validationPasswordShouldContainLetters = "validate_password_should_contain_letters"
        case validationPasswordAndLoginShouldMatch = "validate_password_and_login_should_match"
        case validationLoginTooShort = "validate_login_too_short"
        case validationLoginTooLong = "validate_login_too_long"
        case validationLoginContainsForbiddenChars = "validate_login_contains_forbidden_chars"
        case validationExpirationDateWrongFormat = "validate_expiration_date_wrong_format"
        case validationExpirationDateIsExpired = "validate_expiration_date_is_expired"
        case validationInputIncorrect = "validate_input_incorrect"
        case validationFieldContainsForbiddenChars = "validate_field_contains_forbidden_chars"
        case validationSumShouldContainOnlyDigits = "validate_sum_should_contain_only_digits"
        case validationEmptyField = "validate_empty_field"
        case validationAccountStartsZero = "account_starts_zero"
    }
    
    enum CostValidation: String {
        case validationSumShouldBeGreaterThen = "validate_sum_should_be_greater_then"
    }
    
    enum LengthValidation: String {
        case validationCardnameTooLongInfo = "validate_cardname_too_long_info"
        case validationCardnameTooShortInfo = "validate_cardname_too_short_info"
        case validationMinimumSymbolsInfo = "validate_minimum_symbols"
    }
    
    enum InternalInconsistency: String {
        case thisShouldntHappenReportBug = "this_shouldnt_happen_report_bug"
        case databaseError = "something_happend_with_database"
        case cardNotFound = "card_not_found"
    }
    
    enum Api: String {
        case apiUndefinedError = "api_undefined_error"
        case apiNoInternetConnectionError = "api_no_internet_connection_error"
        case apiSessionExpired = "api_session_expired"
    }
    
    enum ApiErrorCode: Int {
        case unknown = 0
        case sessionExpired = 401
        case registrationFailed = 403
        case noInternetConnection = -1009
        
        init(code: Int) {
            switch code {
            case -1009:
                self = .noInternetConnection
            case 401:
                self = .sessionExpired
            case 403:
                self = .registrationFailed
            default:
                self = .unknown
            }
        }
    }
    
    case apiError(error: ErrorType.ApiErrorCode)
    case costValidationError(error: ErrorType.CostValidation, minimumCost: Int)
    case internalError(error: ErrorType.InternalInconsistency)
    case lengthError(error: ErrorType.LengthValidation, length: Int)
    case validationError(error: ErrorType.Validation)
}

/// Errors for application
public class LLError: Error, Codable {
    var code: Int = 0
    var message: String = ""
    
    convenience init(errorType: ErrorType) {
        self.init()
        
        switch errorType {
        case .apiError(let error):
            message = apiErrorMessageBy(error)
        case .costValidationError(let error, let cost):
            message = String.init(format: NSLocalizedString(error.rawValue, comment: ""), cost)
        case .internalError(let error):
            message = NSLocalizedString(error.rawValue, comment: "")
        case .lengthError(let error, let length):
            message = String.init(format: NSLocalizedString(error.rawValue, comment: ""), length)
        case .validationError(let error):
            message = NSLocalizedString(error.rawValue, comment: "")
        }
    }
    
    convenience init(error: Error) {
        self.init()
        
        let errorObject = error as NSError
        self.code = errorObject.code
        self.message = errorObject.localizedDescription
        
    }
    
    convenience init(error: String) {
        self.init()
        
        self.code = 400
        self.message = error
        
    }
    
    private func apiErrorMessageBy(_ code: ErrorType.ApiErrorCode) -> String {
        switch code {
        case .noInternetConnection:
            return NSLocalizedString(ErrorType.Api.apiNoInternetConnectionError.rawValue, comment: "")
        case .sessionExpired:
            return NSLocalizedString(ErrorType.Api.apiSessionExpired.rawValue, comment: "")
        default:
            return NSLocalizedString(ErrorType.Api.apiUndefinedError.rawValue, comment: "")
        }
    }
}

extension LLError {
    static var unknown: LLError {
        return LLError(errorType: .internalError(error: .thisShouldntHappenReportBug))
    }
    
    static var dataBaseError: LLError {
        return LLError(errorType: .internalError(error: .databaseError))
    }
}

