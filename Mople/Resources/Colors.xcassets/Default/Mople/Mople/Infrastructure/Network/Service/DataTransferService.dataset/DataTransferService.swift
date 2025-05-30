//
//  DataTransferService.swift
//  Group
//
//  Created by CatSlave on 8/19/24.
//

import Foundation
import RxSwift

enum DataTransferError: Error {
    case parsing(Error)
    case networkFailure(NetworkError)
    case expiredToken
    case noResponse
    case unknownError(Error)
    case badRequest
}

protocol DataTransferService {
    typealias CompletionHandler<T> = (Result<T, DataTransferError>) -> Void

    @discardableResult
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E
    ) -> Single<T> where E.Response == T

    @discardableResult
    func request<E: ResponseRequestable>(
        with endpoint: E
    ) -> Single<Void> where E.Response == Void
}

protocol DataTransferErrorResolver {
    func resolve(error: NetworkError) -> DataTransferError
}

protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

protocol DataTransferErrorLogger {
    func log(error: Error)
}

final class DefaultDataTransferService {
    
    // config, session, error를 처리한 서비스
    private let networkService: NetworkService
    
    private let errorResolver: DataTransferErrorResolver
    
    private let errorLogger: DataTransferErrorLogger
    
    init(
        with networkService: NetworkService,
        errorResolver: DataTransferErrorResolver = DefaultDataTransferErrorResolver(),
        errorLogger: DataTransferErrorLogger = DefaultDataTransferErrorLogger()
    ) {
        self.networkService = networkService
        self.errorResolver = errorResolver
        self.errorLogger = errorLogger
    }
}

extension DefaultDataTransferService: DataTransferService {

    /// 리턴값이 있는 요청
    func request<E: ResponseRequestable>(
        with endpoint: E
    ) -> Single<E.Response> where E.Response: Decodable {
        return performBaseRequest(endpoint: endpoint) { data in
            try self.decode(data: data, decoder: endpoint.responseDecoder)
        }
    }

    /// 응답만 있는 요청
    func request<E: ResponseRequestable>(
        with endpoint: E
    ) -> Single<Void> where E.Response == Void {
        return performBaseRequest(endpoint: endpoint) { _ in }
    }
    
    private func performBaseRequest<E: ResponseRequestable, T>(endpoint: E,
                                                               transform: @escaping (Data?) throws -> T) -> Single<T> {
        self.networkService.request(endpoint: endpoint)
            .map(transform)
            .catch { err in
                if let err = err as? NetworkError {
                    throw self.errorResolver.resolve(error: err)
                } else {
                    throw err
                }
            }
    }
    
    private func decode<T: Decodable>(data: Data?, decoder: ResponseDecoder) throws -> T {
        guard let data = data, !data.isEmpty else {
            throw DataTransferError.noResponse
        }
        
        do {
            let result: T = try decoder.decode(data)
            return result
        } catch {
            self.errorLogger.log(error: error)
            throw DataTransferError.parsing(error)
        }
    }
}

// MARK: - Logger
final class DefaultDataTransferErrorLogger: DataTransferErrorLogger {
    init() { }
    
    func log(error: Error) {
        printIfDebug("-------------")
        printIfDebug("\(error)")
    }
}

// MARK: - Error Resolver
class DefaultDataTransferErrorResolver: DataTransferErrorResolver {
    func resolve(error: NetworkError) -> DataTransferError {
        switch error {
        case let .error(statusCode, data):
            _ = try? JSONDecoder().decode(ErrorResponse.self, from: data) // 서버에서 전달하는 메세지 (현재 사용 X)
            return handleErrorStatus(code: statusCode, err: error)
        default:
            return .networkFailure(error)
        }
    }
    
    private func handleErrorStatus(code: Int, err: Error) -> DataTransferError {
        switch code {
        case 400: .badRequest
        case 401: .expiredToken
        case 404: .noResponse
        default : .unknownError(err)
        }
    }
}

// MARK: - Response Decoders
class JSONResponseDecoder: ResponseDecoder {
    private let jsonDecoder = JSONDecoder()
    
    init() { }
 
    func decode<T: Decodable>(_ data: Data) throws -> T {
        
        return try jsonDecoder.decode(T.self, from: data)
    }
}

class RawDataResponseDecoder: ResponseDecoder {
   
    init() { }
    
    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }
    func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.default],
                debugDescription: "Expected Data type"
            )
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}






