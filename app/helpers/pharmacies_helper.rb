module PharmaciesHelper
    
    def url
        request.original_url
    end
    
    def check_website(website)
        begin
            website.start_with?('www') ? website : website.prepend('www.')
        rescue
            'no website listed'
        end
    end
    
    def card_content
        if url.include?('settings/account-info')
            'form'
        elsif url.include?('settings/billing-info')
            if current_pharmacy.card_token
                'pharmacies/card_data'
            else
                'pharmacies/card_form'
            end
        elsif url.include?('settings/password')
            'devise/registrations/edit'
        elsif url.include?('settings/advanced')
            'advanced'
        else
            'form'
        end
    end
    
    # def home
    #     url.include?("/batches")
    # end
    
    def home
        url.include?("/dashboard") || url.ends_with?('https://udemy-class-demo07.c9users.io/') || url == 'https://www.rxcarriers.com'
    end
    
    def request_path
        url.include?('/requests') 
    end
    
    def account_path
        url.include?('/settings') || url.include?('/choose_subscription') 
    end
    
    def history_path
        url.include?('/payment-history') || url.include?('/transaction') 
    end
    
    def bag_history_path
        url.include?('/bag-history')
    end
    
    def bags_path
        url.include?('/bags') 
    end
    
    def payments_path
        url.include?('/transactions') 
    end
    
    def transaction_path
        url.include?('/transactions') 
    end
    
    def unprocessed_order
        Order.exists?(pharmacy_id: current_pharmacy.id, processed: false, status: 'pending') 
    end
    
    def processed_order
        !Order.where('pharmacy_id = ? AND processed = ? AND delivered = ? AND status != ?', current_pharmacy.id, true, false, 'cancelled').blank?
    end
    
    def processed_order_count
        Order.where('pharmacy_id = ? AND processed = ? AND delivered = ? AND status != ?', current_pharmacy.id, true, false, 'cancelled').count
    end
    
    def check_current_plan(plan)
        @plan = StripePlan.find_by(pharmacy_id: current_pharmacy.id)
        if !@plan.nil?
            name = @plan.name
        end
        if name == plan
            'Cancel subscription'
        else
            'Change subscription'
        end
    end
    
    def check_active(item_id)
        if Item.find_by(id: item_id).active == false
            'background-lightred'
        end
    end
    
    def stripe_account_missing
        current_pharmacy.has_stripe_account_setup == false 
    end
    
    def present_cart
        @cart = Cart.find_by(shopper_email: guest_shopper.email, pending: true, completed: false)
        if @cart.nil?
            @cart = Cart.create(shopper_email: guest_shopper.email, pending: true, completed: false, item_list: '', item_list_count: '', instructions_list: '', tip: '10%', tip_amount: 0.0)
        end
        @cart
    end
    
    def get_item(id)
        return Item.find_by(id: id) 
    end
    
    def notifications_are_present
        !current_pharmacy.notifications.select {|n| n.not_read }.empty?
    end
    
    def checkout_link
        "/checkout?guest_shopper=true&temp_id=#{ guest_shopper.email }" 
    end
    
    def current_day?(day)
        if Date.today.strftime("%A").include? day[0..3]
            'bold'
        end
    end
    
    def pharmacy_is_closed(pharmacy)
        if !Date.today.strftime("%A").downcase.include?('sat') || !Date.today.strftime("%A").downcase.include?('sun')
            if pharmacy.weekday_hours == 'Closed' || (Time.zone.now - 4.hours) > ((Time.zone.now.strftime('20%y-%m-%d ') + pharmacy.weekday_hours.upcase[-7..-1].strip).to_datetime)
                'show'
            end
        elsif Date.today.strftime("%A").downcase.include?('sat')
            if pharmacy.saturday_hours == 'Closed' || (Time.zone.now - 4.hours) > ((Time.zone.now.strftime('20%y-%m-%d ') + pharmacy.saturday_hours.upcase[-7..-1].strip).to_datetime)
                'show'
            end
        elsif Date.today.strftime("%A").downcase.include?('sun')
            if pharmacy.sunday_hours == 'Closed' || (Time.zone.now - 4.hours) > ((Time.zone.now.strftime('20%y-%m-%d ') + pharmacy.sunday_hours.upcase[-7..-1].strip).to_datetime)
                'show'
            end
        end
    end
    
    def is_a_location(parameter)
        Pharmacy.near(parameter).size == 0 
    end
    
    def disable_empty_cart
        if present_cart.is_empty? || present_cart.get_total_cost == 0.0
            'disabled'
        end
    end
    
    def orders
        url.include?('orders') 
    end
    
    def order_queue
        url.include?('order_queue') 
    end
    
    def inventory
        url.include?('inventory') 
    end
    
    def refill_count_today
        id = current_pharmacy.id
        @deliveries = Order.where(pharmacy_id: id, ordered_at: DateTime.now.at_beginning_of_day.utc..Time.now.utc, processed: true)
        @deliveries.count if @deliveries
    end
    
    def refill_count_this_week
        id = current_pharmacy.id
        @deliveries = Order.where(pharmacy_id: id, ordered_at: DateTime.now.at_beginning_of_week.utc..Time.now.utc, processed: true)
        @deliveries.count if @deliveries
    end
    
    def refill_count_this_month
        id = current_pharmacy.id
        @deliveries = Order.where(pharmacy_id: id, ordered_at: DateTime.now.at_beginning_of_month.utc..Time.now.utc, processed: true)
        @deliveries.count if @deliveries
    end
    
    def check_count_threshold(count)
        count = count.to_i
        if count < 10
            'theme-red'
        else
            'theme-green'
        end
    end
    
    def check_expiration(expiration)
        if (((expiration.to_time - DateTime.now)/86400).round / 30) < 6
            'theme-red'
        end
    end
    
    def all_categories
        ItemCategory.all 
    end
    
    def hours
        ['Closed', '12:00AM', '12:30AM', '1:00AM', '1:30AM', '2:00AM', '2:30AM', '3:00AM', '3:30AM', '4:00AM', '4:30AM', '5:00AM', '5:30AM', '6:00AM', '6:30AM',
        '7:00AM', '7:30AM', '8:00AM', '8:30AM', '9:00AM', '9:30AM', '10:00AM', '10:30AM', '11:00AM', '11:30AM', '12:00PM', '12:30PM', '1:00PM', '1:30PM',
        '2:00PM', '2:30PM', '3:00PM', '3:30PM', '4:00PM', '4:30PM', '5:00PM', '5:30PM', '6:00PM', '6:30PM',
        '7:00PM', '7:30PM', '8:00PM', '8:30PM', '9:00PM', '9:30PM', '10:00PM', '10:30PM', '11:00PM', '11:30PM'] 
    end
    
    def current_pharmacy_orders(period=nil)
        case period
        when 'this month'
            Order.this_month.where(pharmacy_id: current_pharmacy.id).all
        when 'last month'
            Order.last_month.where(pharmacy_id: current_pharmacy.id).all
        when 'this week'
            Order.this_week.where(pharmacy_id: current_pharmacy.id).all
        when 'last week'
            Order.last_week.where(pharmacy_id: current_pharmacy.id).all
        when 'week 3'
            Order.three_weeks_ago.where(pharmacy_id: current_pharmacy.id).all
        when 'week 4'
            Order.four_weeks_ago.where(pharmacy_id: current_pharmacy.id).all
        when 'week 5'
            Order.five_weeks_ago.where(pharmacy_id: current_pharmacy.id).all
        when 'this year'
            Order.this_year.where(pharmacy_id: current_pharmacy.id).all
        when 'last year'
            Order.last_year.where(pharmacy_id: current_pharmacy.id).all
        else
            Order.where(pharmacy_id: current_pharmacy.id).all
        end
    end
    
    def total_orders(period=nil)
        case period
        when 'this month'
            Order.where(pharmacy_id: current_pharmacy.id, ordered_at: DateTime.now.at_beginning_of_month.utc..Time.now.utc)
        when 'this week'
            Order.where(pharmacy_id: current_pharmacy.id, ordered_at: DateTime.now.at_beginning_of_week.utc..Time.now.utc)
        when 'last week'
            Order.where(pharmacy_id: current_pharmacy.id, ordered_at: DateTime.now.at_beginning_of_week.last_week.utc..DateTime.now.last_week.at_end_of_week.utc)
        when 'week 3'
            Order.where(pharmacy_id: current_pharmacy.id, ordered_at: DateTime.now.at_beginning_of_week.last_week.last_week.utc..Time.now.last_week.last_week.at_end_of_week.utc)
        when 'week 4'
            Order.where(pharmacy_id: current_pharmacy.id, ordered_at: DateTime.now.at_beginning_of_week.last_week.last_week.last_week.utc..Time.now.last_week.last_week.last_week.at_end_of_week.utc)
        when 'week 5'
            Order.where(pharmacy_id: current_pharmacy.id, ordered_at: DateTime.now.at_beginning_of_week.last_week.last_week.last_week.last_week.utc..Time.now.last_week.last_week.last_week.last_week.at_end_of_week.utc)
        when 'this year'
            Order.where(pharmacy_id: current_pharmacy.id, ordered_at: DateTime.now.at_beginning_of_year.utc..Time.now.utc)
        else
            Order.where(pharmacy_id: current_pharmacy.id)
        end
    end
    
    def online_orders(period=nil)
        case period
        when 'this month'
            Order.where(pharmacy_id: current_pharmacy.id, ordered_at: DateTime.now.at_beginning_of_month.utc..Time.now.utc, online: true)
        when 'this week'
            Order.where(pharmacy_id: current_pharmacy.id, ordered_at: DateTime.now.at_beginning_of_week.utc..Time.now.utc, online: true)
        when 'this year'
            Order.where(pharmacy_id: current_pharmacy.id, ordered_at: DateTime.now.at_beginning_of_year.utc..Time.now.utc, online: true)
        else
            Order.where(pharmacy_id: current_pharmacy.id, online: true)
        end
    end
    
    def in_store_orders(period=nil)
        case period
        when 'this month'
            Order.where(pharmacy_id: current_pharmacy.id, ordered_at: DateTime.now.at_beginning_of_month.utc..Time.now.utc, online: false)
        when 'this week'
            Order.where(pharmacy_id: current_pharmacy.id, ordered_at: DateTime.now.at_beginning_of_week.utc..Time.now.utc, online: false)
        when 'this year'
            Order.where(pharmacy_id: current_pharmacy.id, ordered_at: DateTime.now.at_beginning_of_year.utc..Time.now.utc, online: false)
        else
            Order.where(pharmacy_id: current_pharmacy.id, online: false)
        end
    end
    
    def total_sales
        total_orders.add
    end
    
    def totals_to_array(id, period=nil)
        Order.totals_to_array(id, period).sum.round(2)
    end
    
    def totals_to_array_last_month(id)
        Order.totals_to_array_last_month(id).sum.round(2)
    end
    
    def totals_to_array_last_week(id)
        Order.totals_to_array_last_week(id).sum.round(2)
    end
    
    def totals_to_array_last_year(id)
        Order.totals_to_array_last_year(id).sum.round(2)
    end
    
    def total_items(id)
        Order.total_items(id).sum
    end
    
    def item_price_for(item)
        Item.find_by(id: item).price 
    end
    
    def revenue_per_item(id, period=nil)
        rev = totals_to_array(id, period)/total_units_sold(period)
        if rev.nan?
            return 'n/a'
        end
        return '$' + rev.round(2).to_s
    end
    
    def month_to_day(period=nil)
        percent = ((totals_to_array(current_pharmacy.id, period) - totals_to_array_last_month(current_pharmacy.id))/totals_to_array(current_pharmacy.id, period)).round(2) * 100
        if percent.nan?
            return 'n/a'
        end
        return percent.to_s + '%'
    end
    
    def week_to_day(period=nil)
        percent = ((totals_to_array(current_pharmacy.id, period) - totals_to_array_last_week(current_pharmacy.id))/totals_to_array(current_pharmacy.id, period)).round(2) * 100
        if percent.nan?
            return 'n/a'
        end
        return percent.to_s + '%'
    end
    
    def year_to_day(period=nil)
        percent = ((totals_to_array(current_pharmacy.id, period) - totals_to_array_last_year(current_pharmacy.id))/totals_to_array(current_pharmacy.id, period)).round(2) * 100
        if percent.nan?
            return 'n/a'
        end
        return percent.to_s + '%'
    end
    
    def units_sold_for(item, period=nil)
        orders = current_pharmacy_orders(period).select {|o| o.item_list_array.include?(item.to_s)}
        item_count = 0
        orders.each do |o|
            item_count += o.item_list_count_array[o.item_list_array.index(item.to_s)].to_i
        end
        return item_count
    end
    
    def total_units_sold(period=nil)
        total = 0
        current_pharmacy.inventory.items.each do |i|
            total += units_sold_for(i.id, period)
        end
        return total
    end
    
    def revenue_per_unit_for(item, period=nil)
        units_sold_for(item, period) * item_price_for(item).to_f.round(2)
    end
    
    def last_order_for(item)
        order = current_pharmacy_orders.select {|o| o.item_list_array.include?(item.to_s) && o.status == 'delivered'}.last
        if order.nil?
            return 'n/a'
        end
        order.ordered_at.strftime('%-m/%e/%y')
    end
    
    def popular_items(period=nil)
        item_list = Order.popular_items(period)
        item_list = item_list.map {|i| i if Item.exists?(id: i) }.compact
        return Item.find(item_list).sort_by {|i| i.units_sold_for(current_pharmacy, i.id, period)}.reverse
    end
    
    def mom(item, period1=nil, period2=nil)
        mom = (((revenue_per_unit_for(item, period1) - revenue_per_unit_for(item, period2))/revenue_per_unit_for(item, period1)) * 100).round(2)
        if mom.nan? || (!mom.is_a?(Float) && mom.include?('Infinity'))
            return 'n/a'
        end
        return mom
    end
    
    def trend_color(value)
        if value.to_s.include?('-')
            'theme-red'
        else
            'theme-green'
        end
    end
    
    ## ADD WEEK_START FOR GROUP_BY
    def orders_grouped_by_month
        Order.where(pharmacy_id: current_pharmacy.id).group_by_month(:created_at, format: "%b %Y").count
    end
    
    def orders_grouped_by_week
        Order.where(pharmacy_id: current_pharmacy.id).group_by_week(:created_at, format: "%b %d").count
    end
    
    def orders_grouped_by_year
        Order.where(pharmacy_id: current_pharmacy.id).group_by_year(:created_at, format: "%Y").count
    end
    
    def total_refund_count(period=nil)
        case period
        when 'this week'
            return Refund.where(pharmacy_id: current_pharmacy.id, completed: true, created_at: DateTime.now.at_beginning_of_week.utc..Time.now.utc).count
        when 'this month'
            return Refund.where(pharmacy_id: current_pharmacy.id, completed: true, created_at: DateTime.now.at_beginning_of_month.utc..Time.now.utc).count
        when 'this year'
            return Refund.where(pharmacy_id: current_pharmacy.id, completed: true, created_at: DateTime.now.at_beginning_of_year.utc..Time.now.utc).count
        else
            return Refund.where(pharmacy_id: current_pharmacy.id, completed: true).count
        end
    end
    
    def map_data_total_orders(array)
        array.map do |a|
            total_orders(a).count
        end
    end
    
    def map_data_total_units(array)
        array.map do |a|
            total_units_sold(a)
        end
    end
end
