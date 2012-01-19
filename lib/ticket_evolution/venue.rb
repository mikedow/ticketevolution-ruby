module TicketEvolution
  class Venue < TicketEvolution::Base
    attr_accessor :name, :address, :location, :updated_at, :url, :id, :upcoming_events

    def initialize(response)
      super(response)
      self.name            = @attrs_for_object["name"]
      self.address         = @attrs_for_object["address"]
      self.location        = @attrs_for_object["location"]
      self.updated_at      = @attrs_for_object["ipdated_at"]
      self.url             = @attrs_for_object["url"]
      self.id              = @attrs_for_object["id"]
      self.upcoming_events = @attrs_for_object["upcoming_events"]
    end

    def events; TicketEvolution::Event.find_by_venue(id); end
    
    def find_by_performer(id)
      events_for_performer = TicketEvolution::Event.find_by_performer(id)
    end

    class << self

      def list(params_hash)
        response = TicketEvolution::Base.get(build_call_path("venues?",build_params_for_get(params_hash)))
        response = process_response(TicketEvolution::Venue,response)
      end

      def search(query)
        path     = "#{api_base}/venues/search?q=#{query}"
        response = TicketEvolution::Base.get(build_call_path("venues/search?q=",query.encoded))
        response = process_response(TicketEvolution::Venue,response)
      end

      def show(id)
        response  = TicketEvolution::Base.get(build_call_path("venues/",id))
        Venue.new(response)
      end

      # Association Proxy Dynamic Methods
      %w(performer configuration category occurs_at name).each do |facet|
        parameter_name = ["name","occurs_at"].include?(facet) ? facet : "#{facet}_id"
        define_method("find_by_#{facet}") do |parameter|
          self.list({parameter_name.intern => parameter})
        end
      end

      # Builders For Array Responses , Template for Object
      def raw_from_json(venue)
        ActiveSupport::HashWithIndifferentAccess.new({
          :name            => venue['name'],
          :address         => venue['address'],
          :location        => venue['location'],
          :updated_at      => venue['updated_at'],
          :url             => venue['url'],
          :id              => venue['id'],
          :upcoming_events => venue['upcoming_events']
        })
      end

      # Acutal api endpoints are matched 1-to-1 but for AR style convience AR type method naming is aliased into existance
      alias :find :show
    end
  end
end