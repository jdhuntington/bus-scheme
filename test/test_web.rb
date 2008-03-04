$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'
require 'open-uri'

module BusScheme
  module_function
  def web_server # need to expose this for MockRequest
    @web_server
  end
end

class WebTest < Test::Unit::TestCase
  def setup
    @response = nil

    @die_roboter = "User-agent: *\nAllow: *"
    eval "(resource \"/robots.txt\" \"#{@die_roboter}\")"
    
    eval '(define concourse-splash (quote (html
		(head
		 (title "Concourse"))
		(body
		 (div id "container"
		      (h1 "Welcome to Concourse!")
		      (p "Concourse is ...")
		      (form action "/login"
			    (input type "text" name "email")
			    (input type "password" name "password")
			    (input type "submit" value "Log in")))))))'
    eval '(resource "/" concourse-splash)'
  end
  
  def test_serves_string_resource
    get '/robots.txt'
    assert_response_code 200
    assert_response @die_roboter
  end

  def test_serves_list_resource
    get '/'
    assert_response_code 200
    assert_response ""
  end

  def test_serves_404
    get '/404'
    assert_response_code 404
    assert_response_match /not found/i
  end
  
  private
  
  def get path
    @response = Rack::MockRequest.new(BusScheme.web_server).get(path)
  end
  
  def assert_response expected, message = nil
    raise "No request has been made!" if @response.nil?
    assert_equal expected, @response.body, message
  end

  def assert_response_match expected, message = nil
    raise "No request has been made!" if @response.nil?
    assert_match expected, @response.body, message
  end

  def assert_response_code expected, message = nil
    raise "No request has been made!" if @response.nil?
    assert_equal expected, @response.status, message
  end
end