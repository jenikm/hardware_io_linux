# encoding: utf-8

class HardwareIO < Sinatra::Application
  get "/read_weight.json" do
    weight = settings.scale.read_with_retry
    content_type :json
   wrap_with_callback( { :WEIGHT => weight }.to_json )
  end

  get "/print_item_label.json" do
    order_item_id = params[:order_item_id]
    label = CGI.unescape(params[:label].to_s)
    settings.printer.print_item_label(label)
    content_type :json
    wrap_with_callback( { :STATUS => "SUCCESS", :ORDER_ITEM_ID => order_item_id }.to_json )
  end


  def wrap_with_callback(result)
    "#{params[:callback]}(#{ result })"
  end

end
