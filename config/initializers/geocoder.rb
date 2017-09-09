Geocoder.configure(
  # Geocoding options
  timeout: 2,                 # geocoding service timeout (secs)
  lookup: :bing,            # name of geocoding service (symbol)
  api_key: 'AikLC4guhHB0rtQUqpp5BNTsjRHQnNkOne4LabG4cjXD5pbry4s7TuTiWhy4pzrD',               # API key for geocoding service
  # ip_lookup: :freegeoip,      # name of IP address geocoding service (symbol)
  # language: :en,              # ISO-639 language code
  # use_https: false,           # use HTTPS for lookup requests? (if supported)
  # http_proxy: nil,            # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,           # HTTPS proxy server (user:pass@host:port)
  # api_key: 'AIzaSyA-usiKOM9wCfNRSch1aQqai1MjqEQybgo'
  # cache: nil,                 # cache object (must respond to #[], #[]=, and #del)
  # cache_prefix: 'geocoder:',  # prefix (string) to use for all cache keys

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  # always_raise: [],

  # Calculation options
  # units: :mi,                 # :km for kilometers or :mi for miles
  # distances: :linear          # :spherical or :linear
)
