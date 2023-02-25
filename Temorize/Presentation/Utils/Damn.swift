//
//  Damn.swift
//  Temorize
//
//  Created by ardalan on 2/9/23.
//

import Foundation
import Combine
import Darwin

final class DemandBuffer<S: Subscriber>: @unchecked Sendable {
  private var buffer = [S.Input]()
  private let subscriber: S
  private var completion: Subscribers.Completion<S.Failure>?
  private var demandState = Demand()
  private let lock: os_unfair_lock_t

  init(subscriber: S) {
    self.subscriber = subscriber
    self.lock = os_unfair_lock_t.allocate(capacity: 1)
    self.lock.initialize(to: os_unfair_lock())
  }

  deinit {
    self.lock.deinitialize(count: 1)
    self.lock.deallocate()
  }

  func buffer(value: S.Input) -> Subscribers.Demand {
    precondition(
      self.completion == nil, "How could a completed publisher sent values?! Beats me 🤷‍♂️")

    switch demandState.requested {
    case .unlimited:
      return subscriber.receive(value)
    default:
      buffer.append(value)
      return flush()
    }
  }

  func complete(completion: Subscribers.Completion<S.Failure>) {
    precondition(
      self.completion == nil, "Completion have already occurred, which is quite awkward 🥺")

    self.completion = completion
    _ = flush()
  }

  func demand(_ demand: Subscribers.Demand) -> Subscribers.Demand {
    flush(adding: demand)
  }

  private func flush(adding newDemand: Subscribers.Demand? = nil) -> Subscribers.Demand {
    self.lock.sync {

      if let newDemand = newDemand {
        demandState.requested += newDemand
      }

      // If buffer isn't ready for flushing, return immediately
      guard demandState.requested > 0 || newDemand == Subscribers.Demand.none else { return .none }

      while !buffer.isEmpty && demandState.processed < demandState.requested {
        demandState.requested += subscriber.receive(buffer.remove(at: 0))
        demandState.processed += 1
      }

      if let completion = completion {
        // Completion event was already sent
        buffer = []
        demandState = .init()
        self.completion = nil
        subscriber.receive(completion: completion)
        return .none
      }

      let sentDemand = demandState.requested - demandState.sent
      demandState.sent += sentDemand
      return sentDemand
    }
  }

  struct Demand {
    var processed: Subscribers.Demand = .none
    var requested: Subscribers.Demand = .none
    var sent: Subscribers.Demand = .none
  }
}
