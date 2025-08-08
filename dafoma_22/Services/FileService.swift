import Foundation

final class FileService {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted]
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func url(for fileName: String) -> URL {
        FileManager.appSupportDirectory.appendingPathComponent(fileName)
    }

    func save<T: Encodable>(_ value: T, to fileName: String) throws {
        let url = url(for: fileName)
        let data = try encoder.encode(value)
        try data.write(to: url, options: [.atomic])
    }

    func load<T: Decodable>(_ type: T.Type, from fileName: String) throws -> T {
        let url = url(for: fileName)
        let data = try Data(contentsOf: url)
        return try decoder.decode(T.self, from: data)
    }

    func loadIfPresent<T: Decodable>(_ type: T.Type, from fileName: String, fallback: T) -> T {
        do { 
            return try load(type, from: fileName) 
        } catch { 
            return fallback 
        }
    }
    
    func fileExists(_ fileName: String) -> Bool {
        FileManager.default.fileExists(atPath: url(for: fileName).path)
    }
}
