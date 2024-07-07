class Context

  class Actions
    ContactIndex = Data.define(:query, :contacts, :timestamp)
    ContactGet = Data.define(:uuid, :contact, :timestamp)
    ContactShow = Data.define(:uuid, :contact, :timestamp)
    PresentationIndex = Data.define(:query, :presentations, :timestamp)
    PresentationGet = Data.define(:uuid, :presentation, :timestamp)
    PresentationShow = Data.define(:uuid, :presentation, :timestamp)
    PresentationEmail = Data.define(:uuid, :presentation, :contact_uuid, :contact, :timestamp)
  end

  Current = Data.define(:datetime,:history,:actions) do

    def initialize(datetime: DateTime.now, history: [], actions: [])
      super(datetime:, history:, actions:)
    end
  end

end
