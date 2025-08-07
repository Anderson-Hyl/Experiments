import Foundation
import RxSwift

public enum STError: Error {
    case workoutDataSubmitError,
        workoutPhotoSubmitError,
        workoutNotFoundError,
        invalidWorkoutError,
        imageForAssetError,
        imageDataForAssetError,
        videoDataForAssetError,
        exporterForVideoAssetError,
        storeWorkoutError,
        directoryCreationError,
        reachabilityError,
        invalidJSONError,
        invalidPinCodeError,
        tooManyPinRequestsError,
        decodingError,
        noSessionError,
        noAVAssetError,
        imageSubmitError,
        unknownError,
        invalidUrlError,
        outboxFatalError,
        outboxInternalError,
        outboxNetworkError,
        outboxPhotoReadError,
        missingWatchError,
        watchLoggingError,
        workoutSyncFailed,
        activityTrendStoreError,
        sleepTrendStoreError,
        momentsTrendStoreError,
        routeError,
        poiSyncError,
        watchNotConnected,
        sleepDataReadError,
        activityDataReadError,
        momentsDataReadError,
        gpsOptimizationError,
        gpsOptimizationFilesNotModified,
        dailyEnergyTargetReadError,
        dailyStepsTargetReadError,
        dailySleepTargetReadError,
        routeSyncErrorExceededMaximum,
        routeImportErrorCorruptedData,
        routeImportErrorParsingFails,
        routeImportErrorNoRoutePoints,
        routeImportErrorUnsupportedFormat,
        routeReverseGeocodeInvalidCoordinate,
        routeTileQueryInvalidCoordinate,
        gzipCompressionError,
        gzipDecompressionError,
        fitFileDownloadError,
        jsonFileDownloadError,
        outboxReturnedUnsyncedWorkout,
        smlDataParserError,
        signupWithPhoneNumberDataError,
        workoutCacheUpdateFailedInvalidWorkoutKey,
        workoutCacheNotInitialized,
        workoutSyncServiceNotInitialized,
        emailAlreadyExists,
        invalidEmail,
        feedCacheServiceNotInitialized,
        phoneNumberAlreadyExists,
        dataNotLoadedError,
        noActivityDataToUploadError,
        fetchOpenweatherServiceError,
        shareFailError,
        invalidPhoneNum,
        phoneNumPinCodeVerifyTooManyTimes,
        emailPinCodeVerifyTooManyTimes,
        loginupWithNumPhoneError,
        universalLoginError,
        invalidPassword,
        phoneNumNotRegister,
        phoneAlreadyExists,
        imageReviewFailed,
        watchEventsUploadError,
        sportModeError,
        sportModeDataEncodeError,
        fetchPersonalRecordIncompleteError,
        saveUserSettingsError,
        containsSensitiveWordsError
}

public enum STNetworkError: Error {
    case nonHTTPResponse(response: URLResponse)
}

public enum GDPRExportError: Error {
    case tooManyRequest(TimeInterval)
}

public enum TOTPError: Error {
    case secretKeyDecodeError,
        generatorInitError,
        passwordGenerationError,
        timeOffsetKeychainError,
        serverTimeFetchError,
        loginError,
        signupError,
        saveUserSettingsError,
        requestVerifyCodeError,
        verifyPinCodeError,
        updatePhoneNumberError,
        bindEmailError,
        changeEmailError,
        resetPasswordError,
        emailAuthenticationError,
        delAccountError
}

public enum STDetailedError: Error {
    case decodingFromGzipFailed(String)
    case moveDataDecoderError(String)
    case momentsDataFromDateRangeError(Error, ClosedRange<Date>)
    case activityDataParseError
    case sleepDataParseError
    case sleepStagesParseError
    case momentsDataParseError
    case activityDataMigrationError(TimeInterval)
    case sleepDataMigrationError(TimeInterval)
    case sleepStagesMigrationError(TimeInterval)
    case momentsDataMigrationError(TimeInterval)
}

public enum MoveDataParserError: Error {
    case failedToConvertJsonToDictionary
    case failedToParseDataFromLegacySML
    case failedToParseSummaryFromLegacySML
}

public enum StreamingJsonParserError: Error {
    case failedToInitPathForCachesDirectory
    case failedToCreateInputStreamFromData
    case failedToCreateInputStream(url: URL)
    case noBytesAvailableFromInputStream
}

public enum DiaryUpdateError: Error {
    case workoutModelNotFound
    case tableCellCastFailed
    case modelCastFailed
}

public enum WorkoutServiceError: Error {
    case failedToReloadFromDB
}

public enum SuuntoSyncError: Error {
    case getEntriesNoElementsError
    case summaryParseError
    case moveParseError
    case legacyMoveParseError
    case diveParseError
}

public enum FeedError: Error {
    case unknownFeedItem(String)
}

public enum AchievementsError: Error {
    case unsupportedDisplayValues(String)
    case failedToStoreAchievementsToDb(Error)
    case failedToSendAchievementsToServer(Error)
    case failedToFetchUserAchievementsFromServer(Error)
}

public enum AppleSignInError: Error {
    case appleAuthorizationFailed,
        conflictWithEmailUser,
        emailOrNameNotProvided,
        unknownError
}

public enum GmailSignInError: Error {
    case gmailAuthorizationFailed
}

public enum StorageServiceError: Error {
    case routeUpdateEffectedMultiple
    case routeUpdateFailed
    case outboxInvalidLocalId(String)
    case instanceDeallocated
}

public enum WorkoutOutboxError: Error {
    case failedToCreateWorkoutFiles(String)
    case debugErrorUploadingWorkoutFromDB
}

public enum SQLiteInitError: Error {
    case failedToEnableExtendedErrorCodes
}

public enum SMCUpdateError: Error {
    case previousFileWasNotRemoved
}

public enum OTAUpdateError: Error {
    case errorWithCode(Int, String)
    
    public func isFatal() -> Bool {
        if case .errorWithCode(let code, _) = self {
            switch code {
            // Error codes from POST to /MDS/Firmware/Transfer/{serial}:
            // 404: Device not connected
            // 409: Device is busy
            // 503: Failed to communicate with the device
            // Error codes from /MDS/Firmware/Transfer/{serial}/Status
            // SERVICE_UNAVAILABLE = 503
            case 404, 409, 503:
                return false
            // Error codes from POST to /MDS/Firmware/Transfer/{serial}:
            // 400: Can't open the image file, file is not SOF
            // 405: Request URL is invalid
            // 500: Internal error
            // Error codes from /MDS/Firmware/Transfer/{serial}/Status
            // BAD_REQUEST = 400
            // INSUFFICIENT_STORAGE = 507
            // INTERNAL_SERVER_ERROR = 500
            default:
                return true
            }
        }
        return true
    }
}

func enforceDecoded<T>(_ value: T?) throws -> T {
    guard let value = value else {
        throw STError.decodingError
    }
    return value
}

public enum STWeChatError: Error {
    case bindToWeChatFail
    case noPairedDevice
    case notSupportBindToWeChat
    /// The key of the server is used up. The user needs to wait for some time before using this function
    case bindToWeChatPending
    case notInstalledWeChat
    case changeUploadStatusFail
    case requestFail
}

public enum SuuntoLongScreenError: Error {
    case createScreenshotFail
}
