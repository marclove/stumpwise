class ManageController < ApplicationController
  layout 'manage'
  before_filter :require_administrator
end