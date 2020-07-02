//
//  BuildkiteService.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/25/20.
//

import Foundation
import Combine
import Buildkite

class BuildkiteService: ObservableObject {
    let client: BuildkiteClient = {
        $0.token = Env.buildkiteToken
        return $0
    }(BuildkiteClient())
    
    @Published private(set) var organization: String = "wayfair"
    
    fileprivate var cancellables: Set<AnyCancellable> = []
    
    func onCompletion<Failure>(_ completion: Subscribers.Completion<Failure>) {
        // TODO: unimplemented
        guard case let .failure(error) = completion else {
            return
        }
        print(error)
    }
}

extension BuildkiteService {
    func send<R: Resource>(resource: R, completion: @escaping (Result<R.Content, Error>) -> Void) where R.Content == Void {
        client.send(resource) { completion($0.map(\.content)) }
    }
    func sendPublisher<R: Resource>(resource: R) -> AnyPublisher<R.Content, Error> where R.Content == Void {
        client
            .sendPublisher(resource)
            .map(\.content)
            .eraseToAnyPublisher()
    }
    
    func send<R: Resource>(resource: R, completion: @escaping (Result<R.Content, Error>) -> Void) where R: HasResponseBody {
        client.send(resource) { completion($0.map(\.content)) }
    }
    func sendPublisher<R: Resource>(resource: R) -> AnyPublisher<R.Content, Error> where R: HasResponseBody {
        client
            .sendPublisher(resource)
            .map(\.content)
            .eraseToAnyPublisher()
    }
    
    func send<R: Resource>(resource: R, completion: @escaping (Result<R.Content, Error>) -> Void) where R: HasResponseBody & HasRequestBody {
        client.send(resource) { completion($0.map(\.content)) }
    }
    func sendPublisher<R: Resource>(resource: R) -> AnyPublisher<R.Content, Error> where R: HasResponseBody & HasRequestBody {
        client
            .sendPublisher(resource)
            .map(\.content)
            .eraseToAnyPublisher()
    }
    
    func singlePage<R: Resource>(resource: R, page: PageOptions, completion: @escaping (Result<R.Content, Error>) -> Void) where R: Paginated {
        client.send(resource, pageOptions: page) { completion($0.map(\.content)) }
    }
    func singlePagePublisher<R: Resource>(resource: R, page: PageOptions) -> AnyPublisher<R.Content, Error> where R: Paginated {
        client
            .sendPublisher(resource, pageOptions: page)
            .map(\.content)
            .eraseToAnyPublisher()
    }
    
    func allPages<R: Resource>(resource: R, perPage: Int, completion: @escaping (Result<[R.Content], Error>) -> Void) where R: Paginated {
        allPagesPublisher(resource: resource, perPage: perPage)
            .collect()
            .sink(completion: completion)
            .store(in: &cancellables)
    }
    func allPagesPublisher<R: Resource>(resource: R, perPage: Int) -> AnyPublisher<R.Content, Error> where R: Paginated {
        let subject = CurrentValueSubject<PageOptions, Error>(PageOptions(page: 1, perPage: perPage))
        return subject.flatMap { pageOptions in
            self.client
                .sendPublisher(resource, pageOptions: pageOptions)
                .handleEvents(receiveOutput: { response in
                    guard let nextPage = response.page?.nextPage else {
                        subject.send(completion: .finished)
                        return
                    }
                    subject.send(PageOptions(page: nextPage, perPage: perPage))
                })
                .map(\.content)
        }
        .eraseToAnyPublisher()
    }

    func followURL<T: Decodable>(_ url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        send(resource: AnyResource(url), completion: completion)
    }
    func followURLPublisher<T: Decodable>(_ url: URL) -> AnyPublisher<T, Error> {
        sendPublisher(resource: AnyResource(url))
    }
    
    func sendQuery<T: GraphQLQuery>(_ query: T, completion: @escaping (Result<GraphQL<T.Response>.Content, Error>) -> Void) {
        send(resource: GraphQL<T.Response>(rawQuery: T.query, variables: query.variables), completion: completion)
    }
    func sendQueryPublisher<T: GraphQLQuery>(_ query: T) -> AnyPublisher<GraphQL<T.Response>.Content, Error> {
        sendPublisher(resource: GraphQL<T.Response>(rawQuery: T.query, variables: query.variables))
    }
}

private struct AnyResource<T: Decodable>: Resource, HasResponseBody {
    typealias Content = T
    let path = ""
    
    var url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    func transformRequest(_ request: inout URLRequest) {
        request.url = self.url
    }
}

extension Publisher {
    func sink(into service: BuildkiteService, receiveValue: @escaping (Output) -> Void) {
        sink(receiveCompletion: service.onCompletion,
             receiveValue: receiveValue)
            .store(in: service)
    }
    
    func sink(completion: @escaping (Result<Output, Failure>) -> Void) -> AnyCancellable {
        sink(
            receiveCompletion: {
                guard case let .failure(error) = $0 else {
                    return
                }
                completion(.failure(error))
            },
            receiveValue: {
                completion(.success($0))
            }
        )
    }
}

extension Cancellable {
    func store(in service: BuildkiteService) {
        store(in: &service.cancellables)
    }
}
