#lang rhombus/scribble/manual
@(import:
    meta_label:
      rhombus open
      rhombus/network
      rhombus/collect
      ssl)

@(def ref_doc: ModulePath'lib("scribblings/reference/reference.scrbl")')

@(def ALPN:
    @hyperlink("https://en.wikipedia.org/wiki/Application-Layer_Protocol_Negotiation"){ALPN})

@title{Rhombus SSL: Secure Communication}

@docmodule(ssl)

The @rhombusmodname(ssl) library supports secure network communication
via the OpenSSL API and libraries that are included with Racket or
provided by the operating system.

@table_of_contents()

@// ------------------------------------------------------------
@section(~tag: "port"){Secure Ports}

@doc(
  annot.macro 'ssl.Port'
  annot.macro 'ssl.Port.Input'
  annot.macro 'ssl.Port.Output'
){

 Satisfied by an input port or output that represents an SSL connection.
 An SSL port also satisifies @rhombus(Port, ~annot), and it also
 satisfies either @rhombus(Port.Input, ~annot) or
 @rhombus(Port.Putput, ~annot).

 A pair of @rhombus(ssl.Port, ~annot)s is typically created by
 @rhombus(ssl.connect) or @rhombus(ssl.Listener.accept), but
 @rhombus(ssl.Port, ~annot)s can also be created as a layer on existing
 ports via @rhombus(ssl.Port.from_ports).

}

@doc(
  fun ssl.Port.from_ports(
    in :: Port.Input,
    out :: Port.Output,
    ~mode: mode :: ssl.Port.Mode = #'connect,
    ~context: context :: ssl.Context = (if mode == #'connect
                                        | ssl.Context.Client()
                                        | ssl.Context.Server()),
    ~host: host :: maybe(String) = #false,
    ~alpn_protocols: alpn_protocols :: List.of(Bytes) = [],
    ~close_original: close_original = #false,
    ~shutdown_on_close: shutdown_on_close = #false,
    ~exn: exn :: (String, Continuation.Marks) -> Any = Exn.Fail
  ) :~ values(ssl.Port.Input, ssl.Port.Output)

  enum ssl.Port.Mode:
    connect
    accept
){

 Wraps existing ports to use the SSL protocol. The @rhombus(ssl.connect)
 and @rhombus(ssl.Listener.accept) functions are convenience wrappers on
 @rhombus(network.TCP.connect) and @rhombus(network.TCPListener.accept),
 respectively, plus @rhombus(ssl.Port.from_ports).

 The @rhombus(mode) argument determines whether the given @rhombus(in)
 and @rhombus(out) are wrapped to use the client (@rhombus(#'connect)) or
 server (@rhombus(#'accept)) half of the protocol.

 The @rhombus(context) argument configures properties of the connection,
 and the kind of context must be consistent with @rhombus(mode). See
 @rhombus(ssl.Context.Client) and @rhombus(ssl.Context.Server) for more
 information.

 If hostname verification is enabled (see
 @rhombus(ssl.Context.set_verify_hostname)), the peer’s certificate is
 checked against @rhombus(host).

 A non-empty @rhombus(alpn_protocols) argument is used in
 @rhombus(#'connect) mode, in which case the client attempts to use
 @ALPN; see also @rhombus(ssl.connect) and
 @rhombus(ssl.Port.selected_alpn). If @rhombus(mode) is
 @rhombus(#'accept), then @rhombus(alpn_protocols) must be empty; use
 @rhombus(ssl.Context.Server.set_server_alpn) to set the ALPN protocols for a
 server context.

 If @rhombus(close_original) is a true value, then @rhombus(in) and
 @rhombus(out) are closed when both of the returned ports are closed.

 If @rhombus(shutdown_on_close) is a true value, then when @rhombus(out)
 is closed before @rhombus(in) is closed, then a shutdown message is sent
 to the connection peer. Otherwise, an early close of @rhombus(out) is
 not reported to the connection peer.

 If an error is encountered during the protocol initialization, then
 @rhombus(exn) is used to construct the exception that is raised.
 Supplying @rhombus(Exn.Fail.Network) as @rhombus(exn) might be useful,
 for example.

}


@doc(
  method (port :: ssl.Port).set_verify(
    mode :: ssl.Context.VerifyMode = #'always
  )
){

}

@doc(
  method (port :: ssl.Port).peer_certificate_hostnames()
    :: List.of(String)

  method (port :: ssl.Port).peer_check_hostnames(host :: String)

  method (port :: ssl.Port).peer_subject_name() :: maybe(Bytes)
  method (port :: ssl.Port).peer_issuer_name() :: maybe(Bytes)

  method (port :: ssl.Port).is_peer_verifies() :: Boolean

  method (port :: ssl.Port).selected_alpn() :~ maybe(Bytes)

  method (port :: ssl.Port).addresses()
    :: values(String, network.PortNumber, String, network.ListenPortNumber)
){

}

@doc(
  method (port :: ssl.Port).abandon()
){

}


@// ------------------------------------------------------------
@section(~tag: "client"){Secure Clients}

@doc(
  fun ssl.connect(
    ~host: host :: String,
    ~port: port :: network.PortNumber,
    ~context: context :: ssl.Context.Client = ssl.Context.Client(),
    ~alpn_protcols: alpn_protocols :: List.of(Bytes) = []
  ) :~ values(ssl.Port.Input, ss.Port.Output)
){

 Connects to @rhombus(host) at @rhombus(port), similiar to (and building
 on) @rhombus(network.TCP.connect), but for a secure connection. The
 @rhombus(context) argument along with @rhombus(alpn_protocols)
 configures the connection. By default, @rhombus(context) is a secure
 connection that checks a certificate that @rhombus(host) provides as
 part of the SSL protocol.

 If @rhombus(alpn_protocols) is not empty, the client attempts to use
 @ALPN to negotiate the connection protocol. Protocols should be listed
 in order of preference, and each protocol must be a byte string with a
 length between 1 and 255 (inclusive). See also
 @rhombus(ssl.Port.selected_alpn).

 Closing the resulting output port does not send a shutdown message to
 the server. See also @rhombus(ssl.Port.from_ports) and its
 @rhombus(~shutdown_on_close) argument.

}

@// ------------------------------------------------------------
@section(~tag: "server"){Secure Servers}

@doc(
 annot.macro 'ssl.Listener'
){

 Satisfied by an SSL listener as created by @rhombus(ssl.listen).

}

@doc(
  fun ssl.listen(
    ~host: host :: maybe(String) = #false,
    ~port: port :: network.PortNumber,
    ~context: context :: ssl.Context.Server = ssl.Context.Server(),
    ~reuse: reuse :: Any = #false,
    ~max_allow_wait: max_allow_wait :: Nat = 5,
  ) :~ ssl.Listener
){

 Like @rhombus(network.TCP.listen), but the result is an SSL listener.
 The server is configured via @rhombus(context), while the
 @rhombus(reuse) and @rhombus(max_allow_wait) arguments are as for
 @rhombus(network.TCP.listen).

 Call @rhombus(TCPListener.load_certificate_chain) and
 @rhombus(TCPListener.load_private_key) to avoid a ``no shared cipher''
 error on accepting connections. The file whose path is
 @rhombus(collect.file_path(~collect: "openssl", ~file: "test.pem")) is a
 suitable argument for both calls when testing. Since @filepath{test.pem}
 is public, however, such a test configuration obviously provides no
 security.

 An SSL listener is a @tech(~doc: ref_doc){synchronizable event}. It is
 ready---with itself as its value---when the underlying TCP listener is
 ready. At that point, however, accepting a connection with
 @rhombus(ssl.Listener.accept) may not complete immediately, because
 further communication is needed to establish the connection.

}

@doc(
  method (lnr :: ssl.Listener).close()
){

  @rhombus(Closeable, ~class)

}

@doc(
  method (lnr :: ssl.Listener).accept(
    ~wait: wait :: network.NetworkWait = #'all
  ) :: values(ssl.Port.Input, ssl.Port.Output)
){
}

@doc(
  method (lnr :: ssl.Listener).addresses()
    :: values(String, network.PortNumber, String, network.ListenPortNumber)
){
}

@doc(
  method (lnr :: ssl.Listener).load_certificate_chain(
    path :: PathString
  )

  method (lnr :: ssl.Listener)
    .load_suggested_certificate_authorities(path :: PathString)

  method (lnr :: ssl.Listener).load_private_key(
    key :: ssl.Context.PrivateKey,
    ~kind: kind :: ssl.Context.KeyKind = #'rsa
  )
){
}

@// ------------------------------------------------------------
@section(~tag: "context"){Secure Contexts}

@doc(
  annot.macro 'ssl.Context'
  annot.macro 'ssl.Context.Client'
  annot.macro 'ssl.Context.Server'

  fun ssl.Context.Client(~secure = #true)
    :: ssl.Context.Client

  fun ssl.Context.Server(
    ~private_key: private_key :: maybe(ssl.Context.PrivateKey) = #false,
    ~certificate_chain: certificate_chain :: maybe(Path) = #false
  ) :: ssl.Context.Server  
){

}

@doc(
  method (ctx :: ssl.Context).load_verify_source(
    src :: PathString || ssl.Context.VerifySource,
    ~try: just_try = #false
  )

  annot.macro 'ssl.Context.VerifySource'
  
  fun ssl.Context.VerifySource.default()
    :: ssl.Context.VerifySource
  fun ssl.Context.VerifySource.directory(path :: PathString)
    :: ssl.Context.VerifySource
  fun ssl.Context.VerifySource.win_store(bstr :: Bytes)
    :: ssl.Context.VerifySource
  fun ssl.Context.VerifySource.mac_keychain(path :: PathString)
    :: ssl.Context.VerifySource

  property (vs :: ssl.Context.VerifySource).handle  
){
}

@doc(
  method (ctx :: ssl.Context).load_certificate_chain(
    path :: PathString
  )
  method (ctx :: ssl.Context)
    .load_suggested_certificate_authorities(path :: PathString)
){
}

@doc(
  method (ctx :: ssl.Context).load_private_key(
    key :: ssl.Context.PrivateKey,
    ~kind: kind :: ssl.Context.KeyKind = #'rsa
  )

  annot.macro 'ssl.Context.PrivateKey'
  
  fun ssl.Context.PrivateKey.pem(path :: PathString)
    :: ssl.Context.PrivateKey
  fun ssl.Context.PrivateKey.pem_bytes(bstr :: Bytes)
    :: ssl.Context.PrivateKey
  fun ssl.Context.PrivateKey.der(path :: PathString)
    :: ssl.Context.PrivateKey

  property (vs :: ssl.Context.PrivateKey).handle  
  
  enum ssl.Context.KeyKind:
    rsa
    any
){
}


@doc(
  method (ctx :: ssl.Context).set_verify(
    mode :: ssl.Context.VerifyMode = #'always
  )

  method (ctx :: ssl.Context).set_verify_hostname(on = #true)

  enum ssl.Context.VerifyMode:
    never
    try
    always
){

}


@doc(
  method (ctx :: ssl.Context).set_ciphers(cipher_spec :: String)

  method (ctx :: ssl.Context.Server).set_server_alpn(
    alpn :: List.of(Bytes),
    ~allow_no_match = #true
  ) :: Void

  method (ctx :: ssl.Context).seal() :: Void
){
}

@// ------------------------------------------------------------
@section(~tag: "util"){SSL Utilities}

@doc(
  def ssl.is_available :: Boolean
  def ssl.unavailable_reason :: maybe(String)
){

 Reports whether SSL functionality is available, and if not, an
 explanation of why.

}

