class DeliveryRequest < ActiveRecord::Base
    require 'color'
    
    def type
        'delivery'
    end
    
    def get_rx
        rx = self.rx
        pharmacy_id = self.pharmacy_id
        return Rx.find_by(rx: rx, pharmacy_id: pharmacy_id)
    end
    
end
