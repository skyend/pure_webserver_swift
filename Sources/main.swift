//
//  main.swift
//  pure_webserver
//
//  Created by Jinwoong Han on 2017. 1. 3..
//
//

#if os(Linux)
    import Glibc
    let s_socket = Glibc.socket
    let s_bind = Glibc.bind
#else
    import Darwin
    let s_socket = Darwin.socket
    let s_bind = Darwin.bind
#endif

typealias FileDescriptor = Int32

extension Collection where Iterator.Element == UInt8 {
    
    public func toString() -> String {
        var utf = UTF8()
        var gen = self.makeIterator()
        var chars = String.UnicodeScalarView()
        while true {
            switch utf.decode(&gen) {
            case .emptyInput: //we're done
                return String(chars)
            case .error: break //error, can't describe what however
//                throw SocksError(.unparsableBytes)
            case .scalarValue(let unicodeScalar):
                chars.append(unicodeScalar)
            }
        }
    }
}




let socket : FileDescriptor = s_socket(AF_INET, SOCK_STREAM, 0)
guard socket > -1 else {
    print("Error : fail create socket")
    exit(1)
}

var sockOptVal :Int32 = 1

setsockopt(socket, SOL_SOCKET, SO_REUSEADDR, &sockOptVal, socklen_t(MemoryLayout<Int32>.stride))

var serv_sockaddr_in = sockaddr_in()
var serv_sockaddr_in_raw_ptr = UnsafeMutableRawPointer( &serv_sockaddr_in )
var serv_sockaddr = sockaddr()
var serv_sockaddr_ptr = UnsafePointer<sockaddr>(bitPattern: 0)

var sockaddr_in_buffer = UnsafeMutableRawBufferPointer(start: serv_sockaddr_in_raw_ptr, count: MemoryLayout<sockaddr_in>.stride)



print("\(serv_sockaddr_in) \(INADDR_ANY)")

memset(serv_sockaddr_in_raw_ptr, 0, MemoryLayout<sockaddr_in>.stride )

serv_sockaddr_in.sin_len = 0
serv_sockaddr_in.sin_family = sa_family_t(AF_INET)
serv_sockaddr_in.sin_addr.s_addr = in_addr_t(CUnsignedLong(INADDR_ANY).bigEndian)
serv_sockaddr_in.sin_port = CUnsignedShort(8080).bigEndian

serv_sockaddr_ptr = UnsafePointer<sockaddr>(OpaquePointer(serv_sockaddr_in_raw_ptr))


//serv_sockaddr_in.sin_zero = 0

print("\(serv_sockaddr_in)")

let bindRst = bind(socket, serv_sockaddr_ptr, socklen_t(MemoryLayout<sockaddr>.stride))
guard bindRst > -1 else {
    print("Bind error")
    exit(1)
}

guard listen(socket, 5) > -1 else {
    print("Listen error")
    exit(1)
}

print("listen 8080")
var clientSockAddr_ptr = UnsafeMutablePointer<sockaddr>(bitPattern:0)
var clientSockLen_ptr = UnsafeMutablePointer<socklen_t>(bitPattern:0)
var clientSock : Int32
var clientData : UnsafeMutablePointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 100000)
var chars = [UInt8](repeating:0,count:100000)

//var clientData_ptr = UnsafeMutableRawPointer(&clientData)
while( true ) {
    clientSock = accept(socket, clientSockAddr_ptr, clientSockLen_ptr)
    print("Client connected")
    print("\(clientSockAddr_ptr)")
    
    read(clientSock, clientData, 100000)
    memcpy(&chars, clientData, 100000)
    write(clientSock, clientData, 100000)
        print("\( chars.toString() )")
    
    
}



var a:Int32 = 0x0000001
// http://swiftlang.ng.bluemix.net/#/repl/586cc931004de625865e6242
