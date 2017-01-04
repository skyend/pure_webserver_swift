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
#else
    import Darwin
let s_socket = Darwin.socket
#endif

typealias FileDescriptor = Int32


let socket : FileDescriptor = s_socket(AF_INET, SOCK_STREAM, 0)
if( socket < 0){
    print("Error : fail create socket")
    exit(1)
}

var sockOptVal :Int32 = 1

setsockopt(socket, SOL_SOCKET, SO_REUSEADDR, &sockOptVal, socklen_t(MemoryLayout<Int32>.stride))

var serv_addr = sockaddr_in()

print("\(serv_addr)")

serv_addr.sin_family = sa_family_t(AF_INET)

var a:Int32 = 0x0000001
// http://swiftlang.ng.bluemix.net/#/repl/586cc931004de625865e6242
