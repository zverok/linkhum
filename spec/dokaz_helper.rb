# encoding: utf-8
require 'linkhum'

Dokaz.before{
  class User
    def initialize(name)
      @name = name
    end

    def exists?
      @name == 'dude'
    end

    def User.where(options)
      User.new(options.fetch(:name))
    end
  end
}
