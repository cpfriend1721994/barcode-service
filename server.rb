class HealthzController
  def call req
    require 'json'
    [ 200, { }, [ { name: "barcode-service", author: "tunnm" }.to_json ] ]
  end
end

class BarcodeGenerateController
  def call req
    require 'barby'
    require 'barby/barcode/code_128'
    require 'barby/outputter/png_outputter'
    require 'chunky_png'
    text = req['QUERY_STRING'].to_s.strip
    output = text == "" ?  "" : Barby::Code128B.new( text ).to_png( :height => 40, :margin => 10 )
    [ 200, { }, [ output ] ]
  end
end

require 'agoo'
Agoo::Server.init( 3000, 'root' )
routing = [
  [ :GET, "/", HealthzController.new ],
  [ :GET, "/healthz", HealthzController.new ],
  [ :GET, "/generate", BarcodeGenerateController.new ]
]
routing.each do |r|
  Agoo::Server.handle r[0], r[1], r[2]
end
Agoo::Server.start()
