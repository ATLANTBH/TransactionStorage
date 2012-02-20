############################
#
# Base controller for everithing else.
#
#  Inherit this for controllers that dont nead API authentication
#  Inherit from api_controller for API authentication
#

require 'utils'
require 'config/configuration'
require 'digest/sha2'

class ApplicationController < ActionController::Base
end
