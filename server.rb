# GET /healthz - API Healthz, response status 200 with json
class HealthzController
  def call req
    require 'json'
    [ 200, { }, [ { name: "barcode-service", author: "tunnm" }.to_json ] ]
  end
end
require 'rack'

# GET /generate - API generate barcode, param: { text: <text for generate barcode> }
class BarcodeGenerateController
  def call req
    require 'barby'
    require 'barby/barcode/code_128'
    require 'barby/outputter/png_outputter'
    require 'chunky_png'
    text = Rack::Request.new(req).params['text'].to_s.strip
    output = text == "" ?  "" : Barby::Code128B.new( text ).to_png( :height => 40, :margin => 10 )
    [ 200, { }, [ output ] ]
  end
end

# POST /recognize - API recognize barcode, param: { file: <png image for recognize barcode images> }
class BarcodeRecognizeController
  def call req
    require 'zxing'
    file = Rack::Request.new(req).params['file'][:tempfile]
    result = ZXing.decode! file
    [ 200, { }, [ result ] ]
  end
end

require 'agoo'
Agoo::Server.init( 3000, 'root' )
routing = [
  [ :GET, "/", HealthzController.new ],
  [ :GET, "/healthz", HealthzController.new ],
  [ :GET, "/generate", BarcodeGenerateController.new ],
  [ :POST, "/recognize", BarcodeRecognizeController.new ]
]
routing.each do |r|
  Agoo::Server.handle r[0], r[1], r[2]
end
Agoo::Server.start()
