# Values listed are the default values
RspecApiDocumentation.configure do |config|
  # Change how the post body is formatted by default, you can still override by `raw_post`
  # Can be :json, :xml, or a proc that will be passed the params
  config.request_body_formatter = Proc.new { |params| params }

  # Change how the response body is formatted by default
  # Is proc that will be called with the response_content_type & response_body
  # by default response_content_type of `application/json` are pretty formated.
  config.response_body_formatter = Proc.new { |response_content_type, response_body| JSON.pretty_generate(response_body) }
end
