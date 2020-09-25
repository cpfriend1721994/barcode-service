require 'rack'
require 'agoo'
require 'json'
require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'
require 'chunky_png'
require 'zxing'

# init constants
HEALTHZ_MSG = [ 200, { }, [ { name: "barcode-service", author: "tunnm" }.to_json ] ].freeze
PNG_OPTION = { :height => 40, :margin => 10 }.freeze

# GET /healthz - API Healthz, response status 200 with json
class HealthzController
  def call req
    HEALTHZ_MSG
  end
end

# GET /generate - API generate barcode, param: { text: <text for generate barcode> }
class BarcodeGenerateController
  def call req
    [ 200, { }, [ ( Barby::Code128B.new( Rack::Request.new(req).params['text'] ).to_png( PNG_OPTION ) rescue "" ) ] ]
  end
end

# POST /recognize - API recognize barcode, param: { file: <png image for recognize barcode images> }
class BarcodeRecognizeController
  def call req
    [ 200, { }, [ ( ZXing.decode! Rack::Request.new(req).params['file'][:tempfile] ) ] ]
  end
end

# start web server
Agoo::Server.init( 3000, 'root', thread_count: 0, worker_count: 4 )
Agoo::Server.handle :GET, "/", HealthzController.new
Agoo::Server.handle :GET, "/healthz", HealthzController.new
Agoo::Server.handle :GET, "/generate", BarcodeGenerateController.new
Agoo::Server.handle :POST, "/recognize", BarcodeRecognizeController.new
Agoo::Server.start()
