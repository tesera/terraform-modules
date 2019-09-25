variable "name" {
  description = "unique previx for names. alpha numeric only. ie uatAppname"
  default     = ""
}

variable "type" {
  type    = string
  default = "edge"
}

# IPs
variable "defaultAction" {
  default = "DENY"
}

variable "ipWhitelistId" {
  default = ""
}

variable "ipAdminlistId" {
  default = ""
}

# A4
variable "adminUrlPrefix" {
  description = "This is the URI path prefix (starting with '/') that identifies your administrative sub-site. You can add additional prefixes later directly in the set."
  type        = string
  default     = "/admin"
}

# A7-2013-SizeRestriction
variable "maxExpectedURISize" {
  description = "Maximum number of bytes allowed in the URI component of the HTTP request. Generally the maximum possible value is determined by the server operating system (maps to file system paths), the web server software, or other middleware components. Choose a value that accomodates the largest URI segment you use in practice in your web application."
  type        = number
  default     = 512
}

variable "maxExpectedQueryStringSize" {
  description = "Maximum number of bytes allowed in the query string component of the HTTP request. Normally the  of query string parameters following the \"?\" in a URL is much larger than the URI , but still bounded by the  of the parameters your web application uses and their values."
  type        = number
  default     = 1024
}

variable "maxExpectedBodySize" {
  description = "Maximum number of bytes allowed in the body of the request. If you do not plan to allow large uploads, set it to the largest payload value that makes sense for your web application. Accepting unnecessarily large values can cause performance issues, if large payloads are used as an attack vector against your web application."
  type        = number
  default     = 4096
}

variable "maxExpectedCookieSize" {
  description = "Maximum number of bytes allowed in the cookie header. The maximum size should be less than 4096, the size is determined by the amount of information your web application stores in cookies. If you only pass a session token via cookies, set the size to no larger than the serialized size of the session token and cookie metadata."
  type        = number
  default     = 4093
}

# A8-2013-CSRF
variable "csrfExpectedHeader" {
  description = "The custom HTTP request header, where the CSRF token value is expected to be encountered"
  type        = string
  default     = "x-csrf-token"
}

variable "csrfExpectedSize" {
  description = "The size in bytes of the CSRF token value. For example if it's a canonically formatted UUIDv4 value the expected size would be 36 bytes/ASCII characters"
  type        = number
  default     = 36
}

# A9
variable "includesPrefix" {
  description = "This is the URI path prefix (starting with '/') that identifies any files in your webroot that are server-side included components, and should not be invoked directly via URL. These can be headers, footers, 3rd party server side libraries or components. You can add additional prefixes later directly in the set."
  type        = string
  default     = "/includes"
}

# AWS
variable "requestThreshold" {
  description = "If you chose yes for the Activate HTTP Flood Protection parameter, enter the maximum acceptable requests per FIVE-minute period per IP address. Please note that AWS WAF rate based rule requires values greather than 2,000 (if you chose Lambda/Athena log parser options, you can use any value greather than zero). If you chose to deactivate this protection, ignore this parameter. Default to `2000`, min allowed: `2000`"
  type        = number
  default     = 2000
}

variable "errorThreshold" {
  description = "If you chose yes for the Activate Scanners & Probes Protection parameter, enter the maximum acceptable bad requests per minute per IP. If you chose to deactivate this protection protection, ignore this parameter."
  type        = number
  default     = 50
}

variable "blockPeriod" {
  description = "If you chose yes for the Activate Scanners & Probes Protection or HTTP Flood Lambda/Athena log parser parameters, enter the period (in minutes) to block applicable IP addresses. If you chose to deactivate log parsing, ignore this parameter."
  type        = number
  default     = 240
}

variable "logging_bucket" {
  description = ""
  default     = ""
}

