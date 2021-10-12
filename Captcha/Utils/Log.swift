import Foundation

extension YoTest {
    public final class Log {
        public enum Level: Int {
            case none = 0
            case info = 1
            case error = 2
            case verbose = 3
        }
    }
}

func logI(_ items: Any...,
          separator: String = " ",
          terminator: String = "\n",
          method: String = #function,
          file: String = #file,
          line: Int = #line) {
    logA(flag: "I",
         level: .info,
         items,
         separator: separator,
         terminator: terminator,
         method: method,
         file: file,
         line: line)
}

func logE(_ items: Any...,
          separator: String = " ",
          terminator: String = "\n",
          method: String = #function,
          file: String = #file,
          line: Int = #line) {
    logA(flag: "E",
         level: .error,
         items,
         separator: separator,
         terminator: terminator,
         method: method,
         file: file,
         line: line)
}

func logV(_ items: Any...,
          separator: String = " ",
          terminator: String = "\n",
          method: String = #function,
          file: String = #file,
          line: Int = #line) {
    logA(flag: "V",
         level: .verbose,
         items,
         separator: separator,
         terminator: terminator,
         method: method,
         file: file,
         line: line)
}

private let formatter: DateFormatter = ({
    let x = DateFormatter()
    x.dateFormat = "YYYY-MM-dd HH:mm:ss zzz"
    return x
})()

private func now() -> String {
    let date = Date()
    let ms = String(format: "%03d", Int(date.timeIntervalSince1970 * 1000) % 1000)
    let time = formatter.string(from: date)
    return "\(time.prefix(19)).\(ms) \(time.dropFirst(20))"
}

private func logA(flag: String,
                  level: YoTest.Log.Level,
                  _ items: Any...,
                  separator: String = " ",
                  terminator: String = "\n",
                  method: String,
                  file: String,
                  line: Int) {
    guard YoTest.logLevel.rawValue >= level.rawValue else {
        return
    }
    let fileName = file.components(separatedBy: "/").last!
    print("\(now()) [YoTestCaptcha] \(flag): \(fileName) \(method) - \(line): ", items,
          separator: separator,
          terminator: terminator)
}

func logDeinit(_ cls: String,
               method: String = #function,
               file: String = #file,
               line: Int = #line) {
    logV("\(cls) did deinit",
         method: method,
         file: file,
         line: line)
}
