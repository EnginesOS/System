class GalleryController < ApplicationController
  before_action :authenticate_user!
end
