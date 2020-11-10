//
//  Transaction.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation
import TweetNacl

public extension SolanaSDK {
    struct Transaction: Decodable {
        public var signatures: [UInt8]
        public var message: Message
        
        enum CodingKeys: String, CodingKey {
            case message, signatures
        }
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            message = try values.decode(Message.self, forKey: .message)
            let strings = try values.decode([String].self, forKey: .signatures)
            signatures = strings.compactMap {UInt8($0)}
        }
        
        public init() {
            message = Message()
            signatures = []
        }
        
        public mutating func sign(signer: Account) throws {
            let serializedMessage = try message.serialize()
            signatures = try NaclSign.signDetached(message: Data(serializedMessage), secretKey: signer.secretKey).bytes
        }
        
        public func serialize() throws -> [UInt8] {
            let serializedMessage = try message.serialize()
            
            // TODO: - signature list
            let signaturesLength = Data.encodeLength(UInt(1)) // change "1" later
            
            var data = Data(capacity: signaturesLength.count + signatures.count + serializedMessage.count)
            data.append(signaturesLength)
            data.append(contentsOf: signatures)
            data.append(contentsOf: serializedMessage)
            return data.bytes
        }
    }
}

public extension SolanaSDK.Transaction {
    struct Instruction: Decodable {
        public let keys: [SolanaSDK.Account.Meta]
        public let programId: SolanaSDK.PublicKey
        public let data: [UInt8]
    }
    
    struct Error: Decodable {
        
    }
    
    struct Meta: Decodable {
        public let err: Error?
        public let fee: UInt64
        public let preBalances: [UInt64]
        public let postBalances: [UInt64]
    }
    
    struct Info: Decodable {
        public let meta: Meta?
        public let transaction: SolanaSDK.Transaction
        public let slot: UInt64?
    }
    
    struct SignatureInfo: Decodable {
        public let signature: String
        public let slot: UInt64
        public let err: Error?
        public let memo: String?
    }
    
    struct Status: Decodable {
        public let err: Error?
        public let logs: [String]
    }
}